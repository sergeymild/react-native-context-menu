package com.contextmenu

import androidx.appcompat.app.AppCompatActivity
import com.contextmenu.contextMenuPresentationModal.FullScreenDialog
import com.contextmenu.contextMenuPresentationModal.safeShow
import com.facebook.react.bridge.*

class ContextMenuModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun showMenu(params: ReadableMap, callback: Callback) {
    var dialog: FullScreenDialog? = null
    dialog = FullScreenDialog(false, params) {
      callback(it)
    }
    dialog.safeShow((currentActivity as AppCompatActivity).supportFragmentManager, "TopModalView")
    dialog.isCancelable = true
  }

  companion object {
    const val NAME = "ContextMenu"
  }
}
