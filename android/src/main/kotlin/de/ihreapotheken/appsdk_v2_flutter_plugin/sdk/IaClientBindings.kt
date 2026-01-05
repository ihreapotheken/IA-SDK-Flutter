package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import IaClientFlutterViewFactory
import android.content.Context
import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import de.ihreapotheken.sdk.integrations.api.view.SdkEntryPoint
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

// @TODO send callbacks (sdkWillNavigateToTarget, orderingDidFinishOrder, orderingDidUpdateCart) to dart. See IaClientDelegate.swift.
// @TODO handle configuration in FlutterCall.initIaSdk (See IaClientMethods in Swift)
// @TODO handle register method (See IaClientMethods.swift)

class IaClientBindings(
    val applicationContext: Context,
    val activityContext: () -> Context?,
    binaryMessenger: BinaryMessenger,
    platformViewRegistry: PlatformViewRegistry,
) {
    val channel: MethodChannel = MethodChannel(binaryMessenger, "de.ihreapotheken/sdk")

    lateinit var sdkModule: IaSdk
    
    /**
     * Property holding the value of the [orderSignaturesListener].
     */
    var orderSignatures: MutableLiveData<SignatureCodes?> = MutableLiveData<SignatureCodes?>(null)
    
    /**
     * Callbacks handler for SDK events (cart updates, order completion, etc.)
     * This is the Android equivalent of iOS's IaClientDelegate
     */
    val callbacks: IaClientCallbacks = IaClientCallbacks(channel, orderSignatures)

    init {
        val methodHandler = IaClientMethods(this)
        channel.setMethodCallHandler(methodHandler::callHandler)
        
        // Register all SDK entry point views
        val entryPoints = listOf(
            IaScreen.StartScreen,
            IaScreen.CartScreen,
            IaScreen.SearchScreen,
            IaScreen.PharmacyScreen,
            IaScreen.PrerequisiteFlow,
            IaScreen.TransferPrescriptionsScreen
        )
        
        for (view in entryPoints) {
            platformViewRegistry.registerViewFactory(
                view::class.simpleName!!,
                IaClientFlutterViewFactory(),
            )
        }
    }

    /**
     * Data class to hold order signature codes.
     */
    data class SignatureCodes(
        val iaOrderCode: String,
        val hostOrderCode: String,
    )

    /**
     * Notifier implemented for receiving value updates on order IDs with prescription transfer completion.
     */
    val orderSignaturesListener: MutableLiveData<SignatureCodes?> by lazy {
        orderSignatures
    }
}
