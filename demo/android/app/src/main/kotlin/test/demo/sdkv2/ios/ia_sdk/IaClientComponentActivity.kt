package test.demo.sdkv2.ios.ia_sdk

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
        enableEdgeToEdge()
        setContent {
            if (1 == 2) {
                Text("AAAA")
            } else {
                SdkTheme {
                    val navController = rememberNavController()
                    var isAtRoot by remember { mutableStateOf(true) }

                    Scaffold(
                        modifier = Modifier,
                    ) { innerPadding ->
                        Box(modifier = Modifier.padding(innerPadding)) {
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
            }
        }
    }
}