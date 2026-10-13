package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import IaClientFlutterViewFactory
import android.content.Context
import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

class IaClientBindings(
    val applicationContext: Context,
    val activityContext: () -> Context?,
    binaryMessenger: BinaryMessenger,
    platformViewRegistry: PlatformViewRegistry,
) {
    val channel: MethodChannel = MethodChannel(binaryMessenger, "de.ihreapotheken/sdk")

    /**
     * The AppSDK entry point. It's a process-wide object, so it's usable before `register`.
     */
    val sdkModule: IaSdk = IaSdk
    
    /**
     * Property holding the value of the [orderSignaturesListener].
     */
    var orderSignatures: MutableLiveData<SignatureCodes?> = MutableLiveData<SignatureCodes?>(null)
    
    /**
     * Callbacks handler for SDK events (cart updates, order completion, etc.)
     * This is the Android equivalent of iOS's IaClientDelegate
     */
    val callbacks: IaClientCallbacks = IaClientCallbacks(channel, orderSignatures)

    private var initStateJob: Job? = null

    private var methodHandler: IaClientMethods? = null

    /**
     * Stops the work that would otherwise outlive the detached Flutter engine.
     */
    fun dispose() {
        initStateJob?.cancel()
        methodHandler?.dispose()
        channel.setMethodCallHandler(null)
    }

    init {
        val methodHandler = IaClientMethods(this)
        channel.setMethodCallHandler(methodHandler::callHandler)

        // Report initialization state changes, like the iOS initializationStatePublisher.
        initStateJob = MainScope().launch {
            IaSdk.initState.collect { state ->
                callbacks.onInitStateChanged(state)
            }
        }
        this.methodHandler = methodHandler

        // Register all SDK entry point views
        val entryPoints = listOf(
            IaScreen.StartScreen,
            IaScreen.CartScreen,
            IaScreen.SearchScreen,
            IaScreen.PharmacyScreen,
            IaScreen.PrerequisiteFlow,
            IaScreen.TransferPrescriptionsScreen,
            IaScreen.ApofinderScreen,
            IaScreen.RedeemPrescription,
        )

        val viewFactory = IaClientFlutterViewFactory(callbacks)
        for (view in entryPoints) {
            platformViewRegistry.registerViewFactory(
                view::class.simpleName!!,
                viewFactory,
            )
        }

        // Register inline component platform views. Component size updates are
        // sent back over the main SDK channel (routed by Dart via IaBaseCallbacks).
        val componentsFactory = IaClientComponentsViewFactory(
            componentsChannel = channel,
            onCartButtonClick = methodHandler::openCartFromCartButton,
        )
        for (component in IaComponentIdentifier.entries) {
            platformViewRegistry.registerViewFactory(
                component.viewTypeId,
                componentsFactory,
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
