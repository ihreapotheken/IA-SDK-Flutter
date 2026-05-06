package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
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
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *>
        val identifier = IaComponentIdentifier.fromViewTypeId(creationParams?.get("viewId") as? String)
            ?: throw IllegalArgumentException("Unknown component viewId in args: $args")

        val composeView = ComposeView(context).apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
            setContent {
                when (identifier) {
                    IaComponentIdentifier.CartButton -> IaCartButton(Modifier)
                    IaComponentIdentifier.ProductGrid -> renderProductGrid(creationParams)
                }
            }
        }
        return IaClientComponentPlatformView(composeView, viewId, componentsChannel)
    }

    @androidx.compose.runtime.Composable
    private fun renderProductGrid(creationParams: Map<*, *>?) {
        val pzn = creationParams?.get("pzn") as? String
        val productType: ProductType = when (creationParams?.get("type") as? String) {
            "productsOfTheMonth" -> ProductType.ProductOfTheMonths
            "productRecommendations" -> ProductType.ProductRecommendations(pzn ?: "")
            "customersAlsoBought" -> ProductType.CustomersAlsoBought(pzn ?: "")
            else -> ProductType.CurrentOffers
        }
        val showLoading = creationParams?.get("shouldShowLoading") as? Boolean ?: true
        IaProductGrid(productType = productType, showLoading = showLoading)
    }
}

private class IaClientComponentPlatformView(
    private val composeView: ComposeView,
    viewId: Int,
    componentsChannel: MethodChannel,
) : PlatformView {
    private val sizeReporter = IaComponentSizeReporter(viewId, componentsChannel)

    init {
        sizeReporter.attachTo(composeView)
    }

    override fun getView(): View = composeView

    override fun dispose() {
        sizeReporter.detach(composeView)
    }
}

/**
 * Measures a [ComposeView] using "fill width, wrap content height" semantics
 * and reports the resulting size to Flutter via the shared components
 * MethodChannel. Sizes are reported in logical pixels (dp).
 */
private class IaComponentSizeReporter(
    private val viewId: Int,
    private val channel: MethodChannel,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastReportedWidth = -1
    private var lastReportedHeight = -1

    private val layoutListener = View.OnLayoutChangeListener { v, _, _, _, _, _, _, _, _ ->
        measureAndReport(v as ComposeView)
    }

    fun attachTo(view: ComposeView) {
        view.addOnLayoutChangeListener(layoutListener)
        view.post { measureAndReport(view) }
    }

    fun detach(view: View) {
        view.removeOnLayoutChangeListener(layoutListener)
    }

    private fun measureAndReport(view: ComposeView) {
        val parentWidth = view.width
        if (parentWidth <= 0) return

        view.measure(
            View.MeasureSpec.makeMeasureSpec(parentWidth, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
        )
        val width = view.measuredWidth
        val height = view.measuredHeight
        if (width <= 0 || height <= 0) return
        if (width == lastReportedWidth && height == lastReportedHeight) return
        lastReportedWidth = width
        lastReportedHeight = height

        val density = view.resources.displayMetrics.density
        val widthDp = width / density
        val heightDp = height / density

        mainHandler.post {
            channel.invokeMethod(
                "updateComponentSize",
                mapOf(
                    "viewId" to viewId,
                    "width" to widthDp.toDouble(),
                    "height" to heightDp.toDouble(),
                ),
            )
        }
    }
}
