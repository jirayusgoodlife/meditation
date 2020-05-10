package io.github.jirayusgoodlife.meditation


import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import androidx.annotation.NonNull;
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
 
	override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
	}
 	
	/** This is a temporary workaround to avoid a memory leak in the Flutter framework 
	override fun provideFlutterEngine(context: Context): FlutterEngine? {
		// Instantiate a FlutterEngine.
		val flutterEngine = FlutterEngine(context.applicationContext)

		// Start executing Dart code to pre-warm the FlutterEngine.
		flutterEngine.dartExecutor.executeDartEntrypoint(
				DartExecutor.DartEntrypoint.createDefault()
		)
		return flutterEngine
	}
	 */
}

