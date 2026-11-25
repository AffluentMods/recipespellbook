-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Home screen widgets. The manifest already keeps the providers; these rules
# also keep the widget classes whole, so release builds behave like debug.
-keep class com.affluentlabs.recipespellbook.widgets.** { *; }

# ML Kit and Firebase create their component registrars by class name from the
# manifest. Since AGP 9, a member-less -keep (as in the libraries' own rules)
# no longer keeps the no-arg constructor, so ML Kit's registrars could not be
# created: every barcode and QR scanner failed with "Attempt to invoke virtual
# method ... on a null object reference" (2.1.0 to 2.2.0).
-keep class * implements com.google.firebase.components.ComponentRegistrar { <init>(); }
