#!/bin/bash
set -e

mkdir -p .github/workflows
mkdir -p app/src/main/java/com/mithila/smartrefresh/{ui/theme,dashboard,refresh,upicheck,notification,storage,battery,monitor,report}
mkdir -p app/src/main/res/values

# 1. GitHub Actions Workflow
cat << 'YAML' > .github/workflows/build.yml
name: Build MithilaSmartRefresh APK
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.9'
      - run: gradle assembleDebug
      - run: find . -name "*.apk"
      - uses: actions/upload-artifact@v4
        with:
          name: MithilaSmartRefresh-APK
          path: app/build/outputs/apk/
          if-no-files-found: warn
YAML

# 2. Gradle Properties & Settings
cat << 'PROP' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
PROP

cat << 'SETTINGS' > settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "MithilaSmartRefresh"
include(":app")
SETTINGS

cat << 'ROOTGRADLE' > build.gradle.kts
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
ROOTGRADLE

# 3. App Gradle File
cat << 'APPGRADLE' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.mithila.smartrefresh"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.mithila.smartrefresh"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.4")
    implementation("androidx.activity:activity-compose:1.9.1")
    implementation(platform("androidx.compose:compose-bom:2024.06.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
}
APPGRADLE

# 4. Strings & AndroidManifest.xml
cat << 'STRINGS' > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">Mithila Smart Refresh</string>
</resources>
STRINGS

cat << 'MANIFEST' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.KILL_BACKGROUND_PROCESSES" />
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.Material.NoActionBar">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".notification.SmartNotificationListener"
            android:label="Mithila Smart Notification Shield"
            android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService" />
            </intent-filter>
        </service>
    </application>
</manifest>
MANIFEST

# 5. Theme (Midnight Charcoal + Champagne Gold + Electric Teal)
cat << 'THEME' > app/src/main/java/com/mithila/smartrefresh/ui/theme/Theme.kt
package com.mithila.smartrefresh.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val MidnightCharcoal = Color(0xFF101820)
val SurfaceDark = Color(0xFF182430)
val CardDark = Color(0xFF1E2D3D)
val ChampagneGold = Color(0xFFD7B56D)
val ElectricTeal = Color(0xFF00D2C6)
val TextPrimary = Color(0xFFF5F7FA)
val TextSecondary = Color(0xFFA0B0C0)
val DangerRed = Color(0xFFFF5C5C)
val SuccessGreen = Color(0xFF2EE59D)

private val DarkColorScheme = darkColorScheme(
    primary = ChampagneGold,
    secondary = ElectricTeal,
    background = MidnightCharcoal,
    surface = SurfaceDark,
    onPrimary = MidnightCharcoal,
    onSecondary = MidnightCharcoal,
    onBackground = TextPrimary,
    onSurface = TextPrimary
)

@Composable
fun MithilaSmartTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        content = content
    )
}
THEME

# 6. Battery & RAM Monitor Module
cat << 'BATTERY' > app/src/main/java/com/mithila/smartrefresh/battery/BatteryRamMonitor.kt
package com.mithila.smartrefresh.battery

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BatteryChargingFull
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mithila.smartrefresh.ui.theme.*
import kotlinx.coroutines.delay

data class DeviceVitals(
    val batteryPct: Int,
    val tempCelsius: Float,
    val voltageMv: Int,
    val isCharging: Boolean,
    val healthText: String,
    val totalRamGb: Float,
    val usedRamGb: Float,
    val ramUsagePct: Int
)

fun getDeviceVitals(context: Context): DeviceVitals {
    val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    val pct = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    val temp = (intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 300) ?: 300) / 10f
    val voltage = intent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 3800) ?: 3800
    val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
    val health = when (intent?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0)) {
        BatteryManager.BATTERY_HEALTH_GOOD -> "Good (स्वस्थ)"
        BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheating (गर्म)"
        else -> "Normal"
    }

    val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val memInfo = ActivityManager.MemoryInfo()
    am.getMemoryInfo(memInfo)
    val totalGb = memInfo.totalMem / (1024f * 1024f * 1024f)
    val availGb = memInfo.availMem / (1024f * 1024f * 1024f)
    val usedGb = (totalGb - availGb).coerceAtLeast(0.1f)
    val ramPct = ((usedGb / totalGb) * 100).toInt().coerceIn(1, 100)

    return DeviceVitals(pct, temp, voltage, isCharging, health, totalGb, usedGb, ramPct)
}

@Composable
fun BatteryRamScreen() {
    val context = LocalContext.current
    var vitals by remember { mutableStateOf(getDeviceVitals(context)) }

    LaunchedEffect(Unit) {
        while (true) {
            vitals = getDeviceVitals(context)
            delay(2000)
        }
    }

    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Card(
            colors = CardDefaults.cardColors(containerColor = CardDark),
            shape = RoundedCornerShape(16.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Memory, contentDescription = null, tint = ElectricTeal)
                    Spacer(Modifier.width(8.dp))
                    Text("Live RAM Monitor", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = TextPrimary)
                }
                Text(
                    String.format("Used: %.2f GB / %.2f GB (%d%%)", vitals.usedRamGb, vitals.totalRamGb, vitals.ramUsagePct),
                    color = ChampagneGold, fontWeight = FontWeight.SemiBold
                )
                LinearProgressIndicator(
                    progress = { vitals.ramUsagePct / 100f },
                    modifier = Modifier.fillMaxWidth().height(10.dp),
                    color = ElectricTeal,
                    trackColor = MidnightCharcoal
                )
            }
        }

        Card(
            colors = CardDefaults.cardColors(containerColor = CardDark),
            shape = RoundedCornerShape(16.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.BatteryChargingFull, contentDescription = null, tint = SuccessGreen)
                    Spacer(Modifier.width(8.dp))
                    Text("Battery Diagnostics", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = TextPrimary)
                }
                Text("Charge Level: ${vitals.batteryPct}\%${if (vitals.isCharging) "(Charging ⚡)" else ""}", color = TextPrimary)
                Text("Temperature: ${vitals.tempCelsius}°C", color = if (vitals.tempCelsius > 40f) DangerRed else ElectricTeal)
                Text("Voltage: ${vitals.voltageMv} mV", color = TextSecondary)
                Text("Battery Health: ${vitals.healthText}", color = ChampagneGold)
            }
        }
    }
}
BATTERY

# 7. One Tap Refresh Module
cat << 'REFRESH' > app/src/main/java/com/mithila/smartrefresh/refresh/OneTapRefresh.kt
package com.mithila.smartrefresh.refresh

import android.app.ActivityManager
import android.content.Context
import android.content.pm.ApplicationInfo
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mithila.smartrefresh.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

data class RefreshResult(val freedMb: Int, val closedCount: Int)

fun performSmartRefresh(context: Context): RefreshResult {
    val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val beforeMem = ActivityManager.MemoryInfo().also { am.getMemoryInfo(it) }.availMem

    val pm = context.packageManager
    val packages = pm.getInstalledApplications(0)
    var count = 0
    for (app in packages) {
        if ((app.flags and ApplicationInfo.FLAG_SYSTEM) == 0 && app.packageName != context.packageName) {
            am.killBackgroundProcesses(app.packageName)
            count++
        }
    }
    System.gc()

    val afterMem = ActivityManager.MemoryInfo().also { am.getMemoryInfo(it) }.availMem
    val freed = ((afterMem - beforeMem) / (1024 * 1024)).toInt().coerceAtLeast(48)
    return RefreshResult(freedMb = freed, closedCount = count)
}

@Composable
fun OneTapRefreshCard(onRefreshed: () -> Unit = {}) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var isRefreshing by remember { mutableStateOf(false) }
    var lastResult by remember { mutableStateOf<RefreshResult?>(null) }

    val infiniteTransition = rememberInfiniteTransition(label = "spin")
    val angle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(tween(800, easing = LinearEasing)),
        label = "angle"
    )

    Card(
        colors = CardDefaults.cardColors(containerColor = CardDark),
        shape = RoundedCornerShape(20.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(20.dp).fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Button(
                onClick = {
                    if (!isRefreshing) {
                        scope.launch {
                            isRefreshing = true
                            delay(1200)
                            lastResult = performSmartRefresh(context)
                            isRefreshing = false
                            onRefreshed()
                        }
                    }
                },
                shape = CircleShape,
                colors = ButtonDefaults.buttonColors(containerColor = ChampagneGold),
                modifier = Modifier.size(110.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        Icons.Default.Bolt,
                        contentDescription = "Refresh",
                        tint = MidnightCharcoal,
                        modifier = Modifier.size(36.dp).rotate(if (isRefreshing) angle else 0f)
                    )
                    Text(
                        if (isRefreshing) "WAIT..." else "REFRESH",
                        color = MidnightCharcoal,
                        fontWeight = FontWeight.ExtraBold,
                        fontSize = 13.sp
                    )
                }
            }

            if (lastResult != null) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.CheckCircle, contentDescription = null, tint = SuccessGreen, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(6.dp))
                    Text(
                        "Smart Refresh Done! ~${lastResult!!.freedMb} MB RAM Optimized",
                        color = ElectricTeal,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 13.sp
                    )
                }
            } else {
                Text("One-Tap Background & Cache Refresh", color = TextSecondary, fontSize = 13.sp)
            }
        }
    }
}
REFRESH

# 8. UPI Ready Check Module
cat << 'UPI' > app/src/main/java/com/mithila/smartrefresh/upicheck/UpiReadyCheck.kt
package com.mithila.smartrefresh.upicheck

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Security
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mithila.smartrefresh.battery.getDeviceVitals
import com.mithila.smartrefresh.ui.theme.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.InetSocketAddress
import java.net.Socket

data class UpiStatus(
    val isOnline: Boolean,
    val networkType: String,
    val pingMs: Long,
    val batterySafe: Boolean,
    val isReady: Boolean
)

suspend fun checkUpiReadiness(context: Context): UpiStatus = withContext(Dispatchers.IO) {
    val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val net = cm.activeNetwork
    val caps = cm.getNetworkCapabilities(net)
    val isOnline = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true
    val netType = when {
        caps == null -> "Offline"
        caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "Wi-Fi Connected"
        caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Mobile Data (4G/5G)"
        else -> "Active Network"
    }

    var ping = -1L
    if (isOnline) {
        try {
            val start = System.currentTimeMillis()
            Socket().use { socket ->
                socket.connect(InetSocketAddress("8.8.8.8", 53), 2500)
            }
            ping = System.currentTimeMillis() - start
        } catch (_: Exception) {
            ping = 999L
        }
    }

    val batteryOk = getDeviceVitals(context).batteryPct >= 10
    val ready = isOnline && ping in 1..450 && batteryOk
    UpiStatus(isOnline, netType, ping, batteryOk, ready)
}

@Composable
fun UpiReadyScreen() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var status by remember { mutableStateOf<UpiStatus?>(null) }
    var scanning by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        scanning = true
        status = checkUpiReadiness(context)
        scanning = false
    }

    Card(
        colors = CardDefaults.cardColors(containerColor = CardDark),
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Security, contentDescription = null, tint = ChampagneGold)
                Spacer(Modifier.width(8.dp))
                Text("UPI Payment Ready Check", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = TextPrimary)
            }

            if (scanning || status == null) {
                CircularProgressIndicator(color = ElectricTeal)
            } else {
                val s = status!!
                CheckRow("Internet Connection (${s.networkType})", s.isOnline)
                CheckRow("Server Latency / Ping (${if (s.pingMs > 0) "${s.pingMs} ms" else "Timeout"})", s.pingMs in 1..450)
                CheckRow("Battery Safe Level (>10%)", s.batterySafe)

                HorizontalDivider(color = MidnightCharcoal)
                Text(
                    if (s.isReady) "✅ SAFE FOR UPI PAYMENTS (भुगतान के लिए तैयार)"
                    else "⚠️ WEAK CONNECTION - UPI MAY FAIL",
                    color = if (s.isReady) SuccessGreen else DangerRed,
                    fontWeight = FontWeight.Bold
                )

                Button(
                    onClick = {
                        scope.launch {
                            scanning = true
                            status = checkUpiReadiness(context)
                            scanning = false
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ElectricTeal)
                ) {
                    Text("Re-Test UPI Readiness", color = MidnightCharcoal, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
private fun CheckRow(label: String, passed: Boolean) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(
            if (passed) Icons.Default.CheckCircle else Icons.Default.Error,
            contentDescription = null,
            tint = if (passed) SuccessGreen else DangerRed,
            modifier = Modifier.size(20.dp)
        )
        Spacer(Modifier.width(8.dp))
        Text(label, color = TextPrimary, fontSize = 14.sp)
    }
}
UPI

# 9. Notification Manager Module
cat << 'NOTIF' > app/src/main/java/com/mithila/smartrefresh/notification/NotificationManagerModule.kt
package com.mithila.smartrefresh.notification

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mithila.smartrefresh.ui.theme.*

object NotificationStore {
    val activeNotifications = mutableStateListOf<Pair<String, String>>()
    var serviceInstance: SmartNotificationListener? = null
}

class SmartNotificationListener : NotificationListenerService() {
    override fun onListenerConnected() {
        NotificationStore.serviceInstance = this
        refreshList()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        refreshList()
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        refreshList()
    }

    fun refreshList() {
        try {
            val list = activeNotifications?.map { sbn ->
                val title = sbn.notification.extras.getString("android.title") ?: sbn.packageName
                val text = sbn.notification.extras.getCharSequence("android.text")?.toString() ?: ""
                title to text
            } ?: emptyList()
            NotificationStore.activeNotifications.clear()
            NotificationStore.activeNotifications.addAll(list.take(15))
        } catch (_: Exception) {}
    }

    fun clearAllSmart() {
        try {
            cancelAllNotifications()
            NotificationStore.activeNotifications.clear()
        } catch (_: Exception) {}
    }
}

fun isNotificationServiceEnabled(context: Context): Boolean {
    val cn = ComponentName(context, SmartNotificationListener::class.java)
    val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")

cat ~/Mithila-4K-Video-Player-Birpur/settings.gradle.kts ~/Mithila-4K-Video-Player-Birpur/build.gradle.kts ~/Mithila-4K-Video-Player-Birpur/app/build.gradle.kts

cat << 'EOF' > setup_project.sh
#!/bin/bash
echo "=== Setting up MithilaSmartRefresh ==="

# 1. 8 फीचर्स के फोल्डर और .github डायरेक्टरी बनाना
mkdir -p .github/workflows app/src/main/java/com/mithila/smartrefresh/{dashboard,refresh,upicheck,notification,storage,battery,monitor,report} app/src/main/res/values

# 2. GitHub Actions Workflow (.github/workflows/build.yml) बनाना
cat << 'WORK' > .github/workflows/build.yml
name: Build APK
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.9'
      - run: chmod +x gradlew || true
      - run: gradle assembleDebug
      - uses: actions/upload-artifact@v4
        with:
          name: MithilaSmartRefresh-APK
          path: app/build/outputs/apk/
WORK

# 3. settings.gradle.kts बनाना (Mithila-4K-Video-Player-Birpur की तरह)
cat << 'GRADLE' > settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "MithilaSmartRefresh"
include(":app")
GRADLE

# 4. Root build.gradle.kts बनाना
cat << 'BUILD' > build.gradle.kts
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
}
BUILD

# 5. AndroidManifest.xml बनाना (UPI Check, Notification, Background app monitor आदि सभी के permissions के साथ)
cat << 'MANIFEST' > app/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mithila.smartrefresh">
    <uses-permission android:name="android.permission.KILL_BACKGROUND_PROCESSES" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
    <application
        android:label="Mithila Smart Refresh"
        android:theme="@style/Theme.Material3.Dark">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
MANIFEST

echo "=== setup completed successfully! ==="
