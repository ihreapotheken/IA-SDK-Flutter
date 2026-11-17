package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.exclude
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.NavigationBarDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.ScaffoldDefaults
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import de.ihreapotheken.sdk.core.api.PresentationMode
import de.ihreapotheken.sdk.core.ui.theme.SdkTheme
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import de.ihreapotheken.sdk.integrations.api.view.IaSdkScreen
import de.ihreapotheken.sdk.integrations.api.view.SdkEntryPoint
import de.ihreapotheken.sdk.integrations.api.view.SdkNavigationTarget
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * An SDK screen shown as a Flutter platform view (Dart's `IaSdkScreenView`).
 *
 * Laid out like `IaSdkView.createView`, but built on `IaSdkScreen`, which also takes the presentation mode and the
 * callbacks that end the flow.
 */
internal class IaClientNativeView(
    activity: ComponentActivity,
    platformViewId: Int,
    creationParams: Map<*, *>?,
    callbacks: IaClientCallbacks,
    channel: MethodChannel,
) : PlatformView {
    private val nativeView: View

    init {
        val viewId = creationParams?.get("viewId")
        require(viewId is String) { "Provided creation parameter \"viewId\" is not a String: $viewId" }

        val entryPoint: SdkEntryPoint<*> = when (viewId) {
            IaScreen.StartScreen::class.simpleName -> IaScreen.StartScreen
            IaScreen.CartScreen::class.simpleName -> IaScreen.CartScreen
            IaScreen.SearchScreen::class.simpleName -> IaScreen.SearchScreen
            IaScreen.PharmacyScreen::class.simpleName -> IaScreen.PharmacyScreen
            IaScreen.ApofinderScreen::class.simpleName -> IaScreen.ApofinderScreen
            IaScreen.RedeemPrescription::class.simpleName -> IaScreen.RedeemPrescription
            else -> throw IllegalArgumentException("Unknown view ID: $viewId")
        }

        // An embed style makes the SDK show a back button on its first screen, as the Android SDK has no close
        // button. Without one the screen shows neither, as when it's embedded in a tab.
        val presentationMode = when (creationParams["embedStyle"]) {
            "navigation", "presentation" -> PresentationMode.FULL_FLOW
            else -> PresentationMode.EMBEDDED
        }
        // The SDK asks to close the screen for its back button and when its flow ends, and Dart closes the route.
        // Posted, so it comes after the pharmacy an Apofinder selection reports first, as on iOS.
        val mainHandler = Handler(Looper.getMainLooper())
        val onFinish: () -> Unit = {
            mainHandler.post {
                channel.invokeMethod("screenDismissed", mapOf("viewId" to platformViewId))
            }
        }
        val onNavigateToTarget: suspend (SdkNavigationTarget) -> Boolean = { target ->
            callbacks.handleNavigationTarget(target)
        }

        nativeView = ComposeView(activity).apply {
            setContent {
                SdkTheme {
                    Scaffold(
                        modifier = Modifier
                            .fillMaxSize()
                            .statusBarsPadding(),
                        contentWindowInsets = ScaffoldDefaults.contentWindowInsets
                            .exclude(NavigationBarDefaults.windowInsets),
                    ) { innerPadding ->
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(innerPadding),
                        ) {
                            if (entryPoint == IaScreen.ApofinderScreen) {
                                // With a result callback Apofinder leaves closing to its host, as on iOS, and the
                                // selection is reported like for a launched Apofinder. Other screens get none: the SDK
                                // would report a pharmacy change inside their flows to it instead of finishing it.
                                IaSdkScreen(
                                    sdkEntryPoint = IaScreen.ApofinderScreen,
                                    presentationMode = presentationMode,
                                    onNavigateToTarget = onNavigateToTarget,
                                    onResult = { selection ->
                                        callbacks.onApofinderPharmacySelected(selection.pharmacyId)
                                        onFinish()
                                    },
                                    onFinish = onFinish,
                                )
                            } else {
                                IaSdkScreen(
                                    sdkEntryPoint = entryPoint,
                                    presentationMode = presentationMode,
                                    onNavigateToTarget = onNavigateToTarget,
                                    onFinish = onFinish,
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    override fun getView(): View {
        return nativeView
    }

    override fun dispose() {}
}

internal class IaClientFlutterViewFactory(
    private val callbacks: IaClientCallbacks,
    private val channel: MethodChannel,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // The SDK's screens use what a ComponentActivity gives Compose: lifecycle, saved state and view models.
        // Failing here reaches Dart as an error, where the screen would otherwise crash the app.
        val activity = context.findActivity()
        check(activity is ComponentActivity) {
            "SDK screens shown in the app's UI need the app's activity to be a ComponentActivity, such as " +
                "FlutterFragmentActivity; ${activity?.javaClass?.name} isn't one."
        }
        return IaClientNativeView(activity, viewId, args as? Map<*, *>, callbacks, channel)
    }
}

/**
 * The activity this context belongs to, or `null` when it belongs to none.
 */
internal fun Context.findActivity(): Activity? {
    var context: Context? = this
    while (context is ContextWrapper) {
        if (context is Activity) return context
        context = context.baseContext
    }
    return null
}
