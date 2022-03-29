package com.qk4req.turbo_go;

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.yandex.mapkit.MapKitFactory
import java.util.*

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        //MapKitFactory.setLocale("ru_RU") // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("d3c1770f-fc4e-4bc5-a785-9f41b2202d38") // Your generated API key
        super.configureFlutterEngine(flutterEngine)
    }
}