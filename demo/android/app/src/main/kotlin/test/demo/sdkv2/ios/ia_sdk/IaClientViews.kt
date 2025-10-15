package test.demo.sdkv2.ios.ia_sdk

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.view.View
import androidx.compose.foundation.layout.Box
import androidx.compose.material3.Text
import androidx.compose.ui.platform.ComposeView
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.rememberNavController
import de.ihreapotheken.sdk.core.navigation.SdkEntryScreen
import de.ihreapotheken.sdk.core.navigation.SdkGraph.sdkGraphProvider
import de.ihreapotheken.sdk.core.navigation.route.Route
import de.ihreapotheken.sdk.core.ui.theme.SdkTheme
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Collection of views available for client display.
 */
@Suppress("EnumEntryName")
internal enum class IaClientViews {
    /**
     * Product search screen.
     */
    productSearchScreen,

    /**
     * Cart summary screen.
     */
    cartScreen;

    /**
     * Visual interface representation.
     */
    fun view(
        context: Context,
    ): View {
        fun findActivity(context: Context?): Activity? {
            var ctx = context
            while (ctx is ContextWrapper) {
                if (ctx is Activity) return ctx
                ctx = ctx.baseContext
            }
            return null
        }

        val activity = findActivity(context)
            ?: throw IllegalStateException("Could not find Activity from context: $context")

        return ComposeView(activity).apply {
            setContent {
                when (name) {
                    productSearchScreen.name -> {
                        Text("AAAA")
                    }

                    cartScreen.name -> {
                        SdkTheme {
                            val navController = rememberNavController()

                            Box {
                                NavHost(
                                    navController = navController,
                                    startDestination = Route.Integration.Root
                                ) {
                                    sdkGraphProvider()
                                }

                                SdkEntryScreen(
                                    onDestinationChanged = { },
                                    navController = navController,
                                    startRoute = Route.Integration,
                                )
                            }
                        }
                    }

                    else -> {
                        throw IllegalArgumentException("No view mapped for ID: $name")
                    }
                }
            }
        }
    }
}

internal class IaClientNativeView(
    context: Context,
    id: Int,
    creationParams: Map<*, *>?,
) : PlatformView {
    private var nativeView: View

    init {
        val viewId = creationParams?.get("viewId")
        if (viewId !is String) {
            throw Exception("Provided creation parameter \"viewId\" is not a String: $viewId")
        }
        nativeView = IaClientViews.entries.first(predicate = { it.name == viewId }).view(context)
    }

    override fun getView(): View {
        return nativeView
    }

    override fun dispose() {}
}

internal class IaClientFlutterViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<*, *>?
        return IaClientNativeView(context, viewId, creationParams)
    }
}