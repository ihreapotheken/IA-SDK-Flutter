
import android.content.Context
import android.view.View
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import de.ihreapotheken.sdk.integrations.api.view.IaSdkView
import de.ihreapotheken.sdk.integrations.api.view.SdkEntryPoint
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

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
        
        // Convert viewId string to SdkEntryPoint
        val entryPoint: SdkEntryPoint<*> = when (viewId) {
            IaScreen.StartScreen::class.simpleName -> IaScreen.StartScreen
            IaScreen.CartScreen::class.simpleName -> IaScreen.CartScreen
            IaScreen.SearchScreen::class.simpleName -> IaScreen.SearchScreen
            IaScreen.PharmacyScreen::class.simpleName -> IaScreen.PharmacyScreen
            IaScreen.PrerequisiteFlow::class.simpleName -> IaScreen.PrerequisiteFlow
            IaScreen.TransferPrescriptionsScreen::class.simpleName -> IaScreen.TransferPrescriptionsScreen
            else -> throw Exception("Unknown view ID: $viewId")
        }
        
        nativeView = IaSdkView.createView(
            context,
            entryPoint,
        )
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
