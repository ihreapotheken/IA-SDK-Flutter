package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import IaClientFlutterViewFactory
import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.Window
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.integrations.api.view.IaPrerequisiteActivity
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
     * A process-wide object, so it's usable before `register`.
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
            // Runs within the activity's super.onCreate, before the SDK sets its content. onActivityPreCreated and
            // onActivityPostCreated would only run from API 29. The feature request has to come first, since looking
            // up the content view for the padding installs the window decor.
            if (usesHostTheme(activity)) activity.requestWindowFeature(Window.FEATURE_NO_TITLE)
            if (activity is IaPrerequisiteActivity) padForNavigationBarAndKeyboard(activity)
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
     * Whether [activity] is an SDK activity that declares no theme, so it gets the host app's. Without an app theme
     * that's the platform default one, whose action bar shows the app's name above the debug viewer. Its layout also
     * passes window insets on to the content only when they change, so the prerequisites screens, which start reading
     * insets later, would get none and draw behind the status bar. The SDK screens have their own top bars.
     */
    private fun usesHostTheme(activity: Activity): Boolean {
        if (!activity.javaClass.name.startsWith("de.ihreapotheken.sdk.")) return false
        val packageManager = activity.packageManager
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getActivityInfo(activity.componentName, PackageManager.ComponentInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getActivityInfo(activity.componentName, 0)
        }
        return info.theme == 0
    }

    /**
     * The SDK's prerequisites activity draws edge to edge, but unlike `IaSdkActivity` it doesn't pad its screens for
     * the navigation bar and the keyboard, so they'd draw behind them. This pads them like `IaSdkActivity` does, and
     * consumes those insets so the screens don't pad again.
     */
    private fun padForNavigationBarAndKeyboard(activity: Activity) {
        val content = activity.findViewById<View>(android.R.id.content)
        ViewCompat.setOnApplyWindowInsetsListener(content) { view, insets ->
            val padding = insets.getInsets(WindowInsetsCompat.Type.navigationBars() or WindowInsetsCompat.Type.ime())
            view.setPadding(padding.left, 0, padding.right, padding.bottom)
            WindowInsetsCompat.Builder(insets)
                .setInsets(WindowInsetsCompat.Type.navigationBars(), Insets.NONE)
                .setInsets(WindowInsetsCompat.Type.ime(), Insets.NONE)
                .build()
        }
    }

    fun finishOpenSdkScreens() {
        openSdkScreens.toList().forEach { if (!it.isFinishing) it.finish() }
    }

    fun onPrerequisiteFlowFinished(isCancelled: Boolean) {
        methodHandler?.onPrerequisiteFlowFinished(isCancelled)
    }

    fun onActivityClosed() {
        methodHandler?.failPrerequisiteFlow()
    }

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
