-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Home screen widgets. The manifest already keeps the providers; these rules
# also keep the widget classes whole, so release builds behave like debug.
-keep class com.affluentlabs.recipespellbook.widgets.** { *; }
