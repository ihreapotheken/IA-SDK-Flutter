
import android.content.Context
import android.view.View
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
        nativeView = IaSdkView.createView(
            context,
            SdkEntryPoint.entries.first(predicate = { it.name == viewId }),
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