package com.patelcook.service

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import kotlinx.coroutines.delay

data class CookAppTheme(
    val name: String,
    val bgMain: Color,
    val cardBg: Color,
    val accent: Color,
    val border: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val isLight: Boolean = false
)

val AppThemes = listOf(
    CookAppTheme("Pure Veg Emerald", Color(0xFF0A1F18), Color(0xFF133127), Color(0xFF4ADE80), Color(0xFF234E3F), Color.White, Color(0xFFB7E4C7)),
    CookAppTheme("Midnight Gold", Color(0xFF101820), Color(0xFF1A2530), Color(0xFFD7B56D), Color(0xFF2F3E4E), Color.White, Color(0xFFCBD5E1)),
    CookAppTheme("Saffron Light", Color(0xFFFFFBF5), Color(0xFFFFFFFF), Color(0xFFE65100), Color(0xFFFFCC80), Color(0xFF1F2937), Color(0xFF4B5563), true),
    CookAppTheme("Royal Navy", Color(0xFF0B132B), Color(0xFF1C2541), Color(0xFF38BDF8), Color(0xFF3A506B), Color.White, Color(0xFF93C5FD)),
    CookAppTheme("Royal Burgundy", Color(0xFF230912), Color(0xFF38101E), Color(0xFFFBBF24), Color(0xFF5C1D33), Color.White, Color(0xFFFDE68A))
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var showSplash by remember { mutableStateOf(true) }
            LaunchedEffect(Unit) { delay(2500); showSplash = false }
            if (showSplash) MithilaSplashScreen() else PatelCookMainScreen()
        }
    }
}

@Composable
fun MithilaSplashScreen() {
    Box(modifier = Modifier.fillMaxSize().background(Color(0xFF101820))) {
        Image(painter = painterResource(id = R.drawable.mithila_full_banner), contentDescription = "Mithila Banner", modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
    }
}

@Composable
fun PatelCookMainScreen() {
    val context = LocalContext.current
    val prefs = remember { context.getSharedPreferences("patel_cook_prefs", Context.MODE_PRIVATE) }
    var themeIndex by remember { mutableIntStateOf(prefs.getInt("theme_index", 0)) }
    val currentTheme = AppThemes[themeIndex % AppThemes.size]

    val phoneNumber = "8999042677"
    val emailAddress = "professionalpatelcook@gmail.com"
    var customBannerUri by remember { mutableStateOf<Uri?>(null) }
    val bannerPicker = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { if (it != null) customBannerUri = it }

    val dishes = remember {
        mutableStateListOf(
            DishItem("Paneer Butter Masala", false), DishItem("Paneer Kofta", false),
            DishItem("Veg Dum Biryani", false), DishItem("Gujarati Special Thali", false),
            DishItem("Punjabi Shahi Thali", false), DishItem("Dal Tadka & Jeera Rice", false),
            DishItem("Mix Veg & Puri/Chapati", false), DishItem("Gajar Halwa / Gulab Jamun", false)
        )
    }
    val selectedDishNames = dishes.filter { it.isSelected }.map { it.name }

    Scaffold(
        containerColor = currentTheme.bgMain,
        bottomBar = {
            if (selectedDishNames.isNotEmpty()) {
                Button(
                    onClick = {
                        val msg = "नमस्ते राजू जी (Patel Cook), मुझे पार्टी/इवेंट के लिए कुक बुक करना है।\nचुनी हुई डिशेज:\n- ${selectedDishNames.joinToString("\n- ")}"
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/91$phoneNumber?text=${Uri.encode(msg)}")))
                    },
                    modifier = Modifier.fillMaxWidth().padding(16.dp).height(54.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF25D366)),
                    shape = RoundedCornerShape(14.dp)
                ) {
                    Text("WhatsApp पर बुक करें (${selectedDishNames.size} Dishes)", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
            }
        }
    ) { paddingValues ->
        LazyColumn(modifier = Modifier.fillMaxSize().padding(paddingValues).padding(horizontal = 16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
            item {
                Spacer(modifier = Modifier.height(8.dp))
                Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.weight(1f)) {
                        Image(painter = painterResource(id = R.drawable.chef_avatar), contentDescription = "Chef", modifier = Modifier.size(48.dp).clip(CircleShape).border(2.dp, currentTheme.accent, CircleShape), contentScale = ContentScale.Crop)
                        Spacer(modifier = Modifier.width(10.dp))
                        Column {
                            Text("PATEL COOK", color = currentTheme.accent, fontWeight = FontWeight.ExtraBold, fontSize = 16.sp)
                            Text("Pure Veg Chef • Pune", color = currentTheme.textSecondary, fontSize = 12.sp)
                        }
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        OutlinedButton(
                            onClick = {
                                val nextIndex = (themeIndex + 1) % AppThemes.size
                                themeIndex = nextIndex
                                prefs.edit().putInt("theme_index", nextIndex).apply()
                            },
                            border = BorderStroke(1.dp, currentTheme.accent),
                            colors = ButtonDefaults.outlinedButtonColors(containerColor = currentTheme.cardBg),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Icon(Icons.Default.Palette, contentDescription = null, tint = currentTheme.accent, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Color", color = currentTheme.textPrimary, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        }
                        OutlinedButton(
                            onClick = { bannerPicker.launch("image/*") },
                            border = BorderStroke(1.dp, currentTheme.border),
                            colors = ButtonDefaults.outlinedButtonColors(containerColor = currentTheme.cardBg),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Icon(Icons.Default.PhotoCamera, contentDescription = null, tint = currentTheme.accent, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Banner", color = currentTheme.textPrimary, fontSize = 11.sp)
                        }
                    }
                }
            }
            item {
                Box(modifier = Modifier.fillMaxWidth().height(215.dp).clip(RoundedCornerShape(20.dp)).border(1.dp, currentTheme.border, RoundedCornerShape(20.dp))) {
                    if (customBannerUri != null) AsyncImage(model = customBannerUri, contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
                    else Image(painter = painterResource(id = R.drawable.default_food_banner), contentDescription = null, modifier = Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
                    Box(modifier = Modifier.fillMaxSize().background(Brush.verticalGradient(listOf(Color.Black.copy(alpha = 0.4f), Color.Black.copy(alpha = 0.85f)))).padding(18.dp)) {
                        Column(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.SpaceBetween) {
                            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                Surface(color = currentTheme.accent, shape = RoundedCornerShape(50.dp)) {
                                    Text("⭐ 4.9 Rated (90+ Reviews)", color = if (currentTheme.isLight) Color.White else Color.Black, fontWeight = FontWeight.Bold, fontSize = 12.sp, modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp))
                                }
                                Surface(color = Color.Black.copy(alpha = 0.6f), shape = RoundedCornerShape(50.dp)) {
                                    Text(currentTheme.name, color = Color.White, fontSize = 10.sp, modifier = Modifier.padding(horizontal = 10.dp, vertical = 3.dp))
                                }
                            }
                            Column {
                                Text("Best Pure Veg Cook Service for every party & function!", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 20.sp, lineHeight = 25.sp)
                                Spacer(modifier = Modifier.height(6.dp))
                                Text("Paneer Special • Veg Biryani • Gujarati & Punjabi Thali • 10 to 200 Guests (Your Groceries, Our Labor)", color = Color(0xFFE0E0E0), fontSize = 12.sp)
                            }
                        }
                    }
                }
            }
            item {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    ActionTile("Call", Icons.Default.Call, currentTheme.accent, currentTheme, Modifier.weight(1f)) {
                        context.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$phoneNumber")))
                    }
                    ActionTile("WhatsApp", Icons.Default.Chat, Color(0xFF25D366), currentTheme, Modifier.weight(1f), Color(0xFF25D366)) {
                        val msg = "नमस्ते राजू जी, मुझे Pune में कुक सर्विस की जानकारी चाहिए।"
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/91$phoneNumber?text=${Uri.encode(msg)}")))
                    }
                    ActionTile("Share", Icons.Default.Share, Color(0xFF38BDF8), currentTheme, Modifier.weight(1f)) {
                        val shareText = "Pune में पार्टी और घर के फंक्शन के लिए Best Pure Veg Cook Service - Patel Professional Cook.\nसंपर्क करें: $phoneNumber / 9028037576"
                        context.startActivity(Intent.createChooser(Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, shareText) }, "Share Cook Service"))
                    }
                    ActionTile("Email", Icons.Default.Email, Color(0xFFF87171), currentTheme, Modifier.weight(1f)) {
                        context.startActivity(Intent(Intent.ACTION_SENDTO).apply { data = Uri.parse("mailto:$emailAddress"); putExtra(Intent.EXTRA_SUBJECT, "Cook Service Booking Inquiry - Pune") })
                    }
                }
            }
            item {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                    Text("🍲 Select Pure Veg Dishes", color = currentTheme.accent, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Text("put a tick", color = currentTheme.textSecondary, fontSize = 13.sp)
                }
            }
            items(dishes.chunked(2).size) { rowIndex ->
                val rowItems = dishes.chunked(2)[rowIndex]
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    rowItems.forEach { dish ->
                        val actualIndex = dishes.indexOf(dish)
                        DishCard(dish, currentTheme, Modifier.weight(1f)) { dishes[actualIndex] = dish.copy(isSelected = !dish.isSelected) }
                    }
                    if (rowItems.size == 1) Spacer(modifier = Modifier.weight(1f))
                }
            }
            item { Spacer(modifier = Modifier.height(70.dp)) }
        }
    }
}

data class DishItem(val name: String, val isSelected: Boolean)

@Composable
fun ActionTile(title: String, icon: ImageVector, iconTint: Color, theme: CookAppTheme, modifier: Modifier = Modifier, borderHighlight: Color = theme.border, onClick: () -> Unit) {
    Surface(modifier = modifier.height(82.dp).clickable { onClick() }, color = theme.cardBg, shape = RoundedCornerShape(16.dp), border = BorderStroke(1.dp, borderHighlight)) {
        Column(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(icon, contentDescription = title, tint = iconTint, modifier = Modifier.size(28.dp))
            Spacer(modifier = Modifier.height(6.dp))
            Text(title, color = theme.textPrimary, fontSize = 12.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
fun DishCard(item: DishItem, theme: CookAppTheme, modifier: Modifier = Modifier, onToggle: () -> Unit) {
    Surface(modifier = modifier.height(76.dp).clickable { onToggle() }, color = theme.cardBg, shape = RoundedCornerShape(14.dp), border = BorderStroke(if (item.isSelected) 1.5.dp else 1.dp, if (item.isSelected) theme.accent else theme.border)) {
        Row(modifier = Modifier.fillMaxSize().padding(horizontal = 12.dp), verticalAlignment = Alignment.CenterVertically) {
            Checkbox(checked = item.isSelected, onCheckedChange = { onToggle() }, colors = CheckboxDefaults.colors(checkedColor = theme.accent, uncheckedColor = theme.textSecondary, checkmarkColor = if (theme.isLight) Color.White else Color.Black))
            Spacer(modifier = Modifier.width(6.dp))
            Text(item.name, color = theme.textPrimary, fontSize = 13.sp, fontWeight = FontWeight.Medium, maxLines = 2)
        }
    }
}
