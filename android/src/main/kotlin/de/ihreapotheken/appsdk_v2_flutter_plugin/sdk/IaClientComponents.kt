package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.findViewTreeSavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
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

        val hasTapHandler = creationParams?.get("hasTapHandler") == true
        val composeView = ComposeView(context).apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
            setContent {
                when (identifier) {
                    IaComponentIdentifier.CartButton -> IaCartButton(
                        Modifier,
                        onClick = {
                            if (hasTapHandler) {
                                // With a Dart tap handler the tap is reported instead of opening the cart.
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
        val lifecycleOwner = IaComponentLifecycleOwner.installIfMissing(composeView, context)
        // The cart button has a fixed size, while the grid fills the width.
        val wrapsWidth = identifier == IaComponentIdentifier.CartButton
        return IaClientComponentPlatformView(composeView, viewId, componentsChannel, wrapsWidth, lifecycleOwner)
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
    viewId: Int,
    componentsChannel: MethodChannel,
    wrapsWidth: Boolean,
    private val lifecycleOwner: IaComponentLifecycleOwner?,
) : PlatformView {
    private val sizeReporter = IaComponentSizeReporter(viewId, componentsChannel, wrapsWidth)

    init {
        sizeReporter.attachTo(composeView)
    }

    override fun getView(): View = composeView

    override fun dispose() {
        sizeReporter.detach(composeView)
        lifecycleOwner?.destroy()
    }
}

/**
 * Lifecycle and saved state for a component whose activity doesn't provide them to its views, like
 * `FlutterActivity`; Compose needs both. The lifecycle follows the activity's when it has one.
 */
private class IaComponentLifecycleOwner private constructor(
    private val activityLifecycle: Lifecycle?,
) : SavedStateRegistryOwner {
    private val lifecycleRegistry = LifecycleRegistry(this)
    private val savedStateRegistryController = SavedStateRegistryController.create(this)
    private val activityObserver = LifecycleEventObserver { _, event -> lifecycleRegistry.handleLifecycleEvent(event) }

    override val lifecycle: Lifecycle
        get() = lifecycleRegistry

    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    private fun start() {
        savedStateRegistryController.performRestore(null)
        if (activityLifecycle != null) {
            // The observer first receives the events up to the activity's current state.
            activityLifecycle.addObserver(activityObserver)
        } else {
            lifecycleRegistry.currentState = Lifecycle.State.RESUMED
        }
    }

    fun destroy() {
        activityLifecycle?.removeObserver(activityObserver)
        if (lifecycleRegistry.currentState.isAtLeast(Lifecycle.State.CREATED)) {
            lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
        }
    }

    companion object {
        /** Returns the installed owner, or `null` when the activity's views already have both owners. */
        fun installIfMissing(view: View, context: Context): IaComponentLifecycleOwner? {
            val activity = context.findActivity()
            val decorView = activity?.window?.decorView
            if (decorView?.findViewTreeLifecycleOwner() != null && decorView.findViewTreeSavedStateRegistryOwner() != null) {
                return null
            }
            val owner = IaComponentLifecycleOwner((activity as? LifecycleOwner)?.lifecycle)
            owner.start()
            view.setViewTreeLifecycleOwner(owner)
            view.setViewTreeSavedStateRegistryOwner(owner)
            return owner
        }

        private fun Context.findActivity(): Activity? {
            var context: Context? = this
            while (context is ContextWrapper) {
                if (context is Activity) return context
                context = context.baseContext
            }
            return null
        }
    }
}

/**
 * Measures a [ComposeView] using "fill width, wrap content height" semantics, or its own width with
 * [wrapsWidth], and reports the resulting size to Flutter via the shared components MethodChannel.
 * Sizes are reported in logical pixels (dp).
 */
private class IaComponentSizeReporter(
    private val viewId: Int,
    private val channel: MethodChannel,
    private val wrapsWidth: Boolean,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastReportedWidth = -1
    private var lastReportedHeight = -1
    private var lastParentWidth = -1

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
            View.MeasureSpec.makeMeasureSpec(parentWidth, if (wrapsWidth) View.MeasureSpec.AT_MOST else View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
        )
        val width = view.measuredWidth
        val height = view.measuredHeight
        // A height of 0 is reported too, so an emptied component collapses in Flutter.
        if (width <= 0 || height < 0) return
        // Also reported again for a new layout width: Flutter widens the view when its available width changes,
        // and waits for the size measured against it.
        if (width == lastReportedWidth && height == lastReportedHeight && parentWidth == lastParentWidth) return
        lastReportedWidth = width
        lastReportedHeight = height
        lastParentWidth = parentWidth

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
