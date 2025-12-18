package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import IaClientFlutterViewFactory
import android.content.Context
import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.integrations.api.view.SdkEntryPoint
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

// @TODO send callbacks (sdkWillNavigateToTarget, orderingDidFinishOrder, orderingDidUpdateCart) to dart. See IaClientDelegate.swift.

class IaClientBindings(
    val applicationContext: Context,
    val activityContext: () -> Context?,
    binaryMessenger: BinaryMessenger,
    platformViewRegistry: PlatformViewRegistry,
) {
    val channel: MethodChannel = MethodChannel(binaryMessenger, "de.ihreapotheken/sdk")

    lateinit var sdkModule: IaSdk

    init {
        val methodHandler = IaClientMethods(this)
        channel.setMethodCallHandler(methodHandler::callHandler)
        for (view in SdkEntryPoint.entries) {
            platformViewRegistry.registerViewFactory(
                view.name,
                IaClientFlutterViewFactory(),
            )
        }
    }

    /**
     * Data class to hold a user's address in [PersonalData].
     */
    data class SignatureCodes(
        val iaOrderCode: String,
        val hostOrderCode: String,
    )

    /**
     * Property holding the value of the [orderSignatureListener].
     */
    var orderSignatures: MutableLiveData<SignatureCodes?> = MutableLiveData<SignatureCodes?>(null)

    /**
     * Notifier implemented for receiving value updates on order IDs with prescription transfer completion.
     */
    val orderSignaturesListener: MutableLiveData<SignatureCodes?> by lazy {
        orderSignatures
    }
}