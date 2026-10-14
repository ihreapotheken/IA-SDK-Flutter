package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import IaClientFlutterViewFactory
import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
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
     * Open SDK screens, including those `IaSdkActivity.finishAllActivities` doesn't close, such as the overlay a
     * prescription transfer with a confirmation sheet runs in. CardLink screens aren't included, like on iOS.
     */
    private val openSdkScreens = mutableSetOf<Activity>()

    private val sdkScreenTracker = object : Application.ActivityLifecycleCallbacks {
        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
            val name = activity.javaClass.name
            if (name.startsWith("de.ihreapotheken.sdk.") && !name.startsWith("de.ihreapotheken.sdk.cardlink.")) {
                openSdkScreens.add(activity)
            }
        }

        override fun onActivityDestroyed(activity: Activity) {
            openSdkScreens.remove(activity)
        }

        override fun onActivityStarted(activity: Activity) = Unit
        override fun onActivityResumed(activity: Activity) = Unit
        override fun onActivityPaused(activity: Activity) = Unit
        override fun onActivityStopped(activity: Activity) = Unit
        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit
    }

    /**
     * Finishes the open SDK screens, see [openSdkScreens].
     */
    fun finishOpenSdkScreens() {
        openSdkScreens.toList().forEach { if (!it.isFinishing) it.finish() }
    }

    /**
     * Stops the work that would otherwise outlive the detached Flutter engine.
     */
    fun dispose() {
        initStateJob?.cancel()
        methodHandler?.dispose()
        channel.setMethodCallHandler(null)
        (applicationContext as? Application)?.unregisterActivityLifecycleCallbacks(sdkScreenTracker)
        openSdkScreens.clear()
    }

    init {
        (applicationContext as? Application)?.registerActivityLifecycleCallbacks(sdkScreenTracker)
        val methodHandler = IaClientMethods(this)
        channel.setMethodCallHandler(methodHandler::callHandler)

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
