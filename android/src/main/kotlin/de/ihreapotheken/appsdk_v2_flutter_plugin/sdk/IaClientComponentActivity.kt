package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.rememberNavController
import de.ihreapotheken.sdk.core.navigation.SdkEntryScreen
import de.ihreapotheken.sdk.core.navigation.SdkGraph.sdkGraphProvider
import de.ihreapotheken.sdk.core.navigation.route.Route
import de.ihreapotheken.sdk.core.ui.theme.SdkTheme

class IaClientComponentActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        actionBar?.hide()
        val viewId = intent.getStringExtra("viewId")
        setContent {
            if (viewId?.isNotBlank() != true) {
                Text("View ID must be provided as an Intent extra.")
            } else {
                val navController = rememberNavController()

                SdkTheme {
                    Scaffold { innerPadding ->
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(innerPadding)
                        ) {
                            NavHost(
                                navController = navController,
                                startDestination = Route.Integration.Root,
                            ) {
                                sdkGraphProvider()
                            }

                            SdkEntryScreen(
                                onDestinationChanged = {},
                                navController = navController,
                                startRoute = IaClientViews.Companion.getStartDestination(viewId),
                            )
                        }
                    }
                }
            }
        }
    }
}