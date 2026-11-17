package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.constrainHeight
import androidx.compose.ui.unit.constrainWidth
import kotlin.math.abs
import de.ihreapotheken.sdk.core.api.featureproviders.ProductType
import de.ihreapotheken.sdk.integrations.api.view.components.IaCartButton
import de.ihreapotheken.sdk.integrations.api.view.components.IaProductGrid
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Native identifiers for the inline component platform views Flutter can
 * embed via per-component widget classes (e.g. `IaCartButton`,
 * `IaProductGrid`). The raw value is the platform view type ID Flutter sends.
 */
internal enum class IaComponentIdentifier(val viewTypeId: String) {
    CartButton("CartButton"),
    ProductGrid("ProductGrid"),
    ;

    companion object {
        fun fromViewTypeId(id: String?): IaComponentIdentifier? {
            return entries.firstOrNull { it.viewTypeId == id }
        }
    }
}

/**
 * Single platform view factory that handles all component view types. Branches
 * on the `viewId` creation param to construct the appropriate Compose content.
 */
internal class IaClientComponentsViewFactory(
    private val componentsChannel: MethodChannel,
    private val onCartButtonClick: (Context) -> Unit,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *>
        val identifier = IaComponentIdentifier.fromViewTypeId(creationParams?.get("viewId") as? String)
            ?: throw IllegalArgumentException("Unknown component viewId in args: $args")

        // The SDK's components use what a ComponentActivity gives Compose: lifecycle, saved state and activity
        // results. Failing here reaches Dart as an error, where the component would otherwise crash the app.
        val activity = context.findActivity()
        check(activity is ComponentActivity) {
            "IaCartButton and IaProductGrid need the app's activity to be a ComponentActivity, such as " +
                "FlutterFragmentActivity; ${activity?.javaClass?.name} isn't one."
        }
        val hasTapHandler = creationParams?.get("hasTapHandler") == true
        val sizeReporter = IaComponentSizeReporter(viewId, componentsChannel, context.resources.displayMetrics.density)
        val composeView = ComposeView(context).apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
            setContent {
                // Measured in Compose's layout pass, which also runs when the content changes inside a view whose size
                // stays the same, such as a collapsed one. A layout listener on the view never sees that.
                Box(
                    modifier = Modifier.layout { measurable, constraints ->
                        val isSelfSized = sizeReporter.isSelfSized(constraints)
                        // A self-sizing component gets its own size, at most the view's width, which is reported. One
                        // with a height set by the app is laid out within it, as in a native layout.
                        val placeable = measurable.measure(
                            if (isSelfSized && constraints.hasBoundedHeight) {
                                constraints.copy(minWidth = 0, minHeight = 0, maxHeight = Constraints.Infinity)
                            } else {
                                constraints
                            },
                        )
                        if (isSelfSized) sizeReporter.report(placeable.width, placeable.height, constraints.maxWidth)
                        layout(constraints.constrainWidth(placeable.width), constraints.constrainHeight(placeable.height)) {
                            // At the start of a wider view, also for right-to-left layouts.
                            placeable.placeRelative(0, 0)
                        }
                    },
                ) {
                    when (identifier) {
                        IaComponentIdentifier.CartButton -> IaCartButton(
                            Modifier,
                            onClick = {
                                if (hasTapHandler) {
                                    componentsChannel.invokeMethod("componentTapped", mapOf("viewId" to viewId))
                                } else {
                                    // The SDK's own click opens the cart without asking onSdkWillNavigateToTarget.
                                    onCartButtonClick(context)
                                }
                            },
                        )
                        IaComponentIdentifier.ProductGrid -> renderProductGrid(creationParams)
                    }
                }
            }
        }
        return IaClientComponentPlatformView(composeView)
    }

    @androidx.compose.runtime.Composable
    private fun renderProductGrid(creationParams: Map<*, *>?) {
        val pzn = creationParams?.get("pzn") as? String
        val productType: ProductType = when (creationParams?.get("type") as? String) {
            "productsOfTheMonth" -> ProductType.ProductOfTheMonths
            "productRecommendations" -> ProductType.ProductRecommendations(pzn ?: "")
            "customersAlsoBought" -> ProductType.CustomersAlsoBought(pzn ?: "")
            "custom" -> ProductType.Custom(
                title = creationParams["title"] as? String ?: "",
                pzns = (creationParams["pzns"] as? List<*>)?.filterIsInstance<String>() ?: emptyList(),
            )
            else -> ProductType.CurrentOffers
        }
        val showLoading = creationParams?.get("shouldShowLoading") as? Boolean ?: true
        IaProductGrid(productType = productType, showLoading = showLoading)
    }
}

private class IaClientComponentPlatformView(
    private val composeView: ComposeView,
) : PlatformView {
    override fun getView(): View = composeView

    override fun dispose() {}
}

/**
 * Reports a component's size, as Compose measures it, to Flutter via the shared components MethodChannel, in logical
 * pixels (dp). The component can be as wide as the view; the SDK's components currently fill it, the cart button
 * included (IASDK-3121). A new width Flutter gives the view is reported too; Flutter waits for the size measured
 * against it.
 */
private class IaComponentSizeReporter(
    private val viewId: Int,
    private val channel: MethodChannel,
    private val density: Float,
) {
    private val mainHandler = Handler(Looper.getMainLooper())

    /** Last reported height in pixels, `null` before the first report. */
    private var reportedHeight: Int? = null
    private var reportedWidth = -1
    private var reportedLayoutWidth = -1

    /**
     * Whether Flutter lays the view out at the height the component reported: before the first report and while empty
     * that's a 1px placeholder, otherwise the reported height, give or take rounding. Any other height is set by the
     * app, for example with a `SizedBox`. While the reported height is pending, Flutter keeps the earlier one, so the
     * content is laid out within that, as before, until the new height arrives.
     */
    fun isSelfSized(constraints: Constraints): Boolean {
        val reported = reportedHeight ?: return true
        return reported == 0 || abs(constraints.maxHeight - reported) <= SIZE_TOLERANCE_PX
    }

    fun report(width: Int, height: Int, layoutWidth: Int) {
        // A height of 0 is reported too, so an emptied component collapses in Flutter.
        if (width <= 0 || height < 0) return
        // Also reported again for a new layout width: Flutter waits for the size measured against it.
        if (width == reportedWidth && height == reportedHeight && layoutWidth == reportedLayoutWidth) return
        reportedWidth = width
        reportedHeight = height
        reportedLayoutWidth = layoutWidth
        // Posted, as this runs during Compose's layout pass.
        mainHandler.post {
            channel.invokeMethod(
                "updateComponentSize",
                mapOf(
                    "viewId" to viewId,
                    "width" to (width / density).toDouble(),
                    "height" to (height / density).toDouble(),
                ),
            )
        }
    }

    private companion object {
        /** Flutter rounds the reported logical height to whole pixels when it lays out the view. */
        const val SIZE_TOLERANCE_PX = 2
    }
}
