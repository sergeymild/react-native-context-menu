package com.contextmenu.contextMenuPresentationModal

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Outline
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.StrictMode
import android.view.View
import android.view.ViewOutlineProvider
import androidx.fragment.app.FragmentManager
import com.contextmenu.BuildConfig
import com.facebook.react.bridge.ColorPropConverter
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.PixelUtil
import java.net.URI

fun Int.dp(): Int {
  return PixelUtil.toPixelFromDIP(this.toFloat()).toInt()
}

fun Float.dp(): Int {
  return PixelUtil.toPixelFromDIP(this).toInt()
}

fun Double.dp(): Int {
  return PixelUtil.toPixelFromDIP(this.toFloat()).toInt()
}

fun Int.dpf(): Float {
  return PixelUtil.toPixelFromDIP(this.toFloat())
}

fun Float.dpf(): Float {
  return PixelUtil.toPixelFromDIP(this)
}

fun ReadableMap.color(context: Context, key: String, default: Int): Int {
  if (!hasKey(key)) return default
  return ColorPropConverter.getColor(getDouble(key), context)!!
}

fun ReadableMap.width(key: String, default: Int): Int {
  if (!hasKey(key)) return default
  return PixelUtil.toPixelFromDIP(getDouble(key)).toInt()
}

fun ReadableMap.icon(context: Context, key: String): Bitmap? {
  try {
    if (BuildConfig.DEBUG) {
      val policy: StrictMode.ThreadPolicy = StrictMode.ThreadPolicy.Builder().permitNetwork().build()
      StrictMode.setThreadPolicy(policy)
    }

    val source = getString(key) ?: return null
    val resourceId: Int =
      context.resources.getIdentifier(source, "drawable", context.packageName)

    return if (resourceId == 0) {
      val uri = URI(source)
      BitmapFactory.decodeStream(uri.toURL().openConnection().getInputStream())
    } else {
      BitmapFactory.decodeResource(context.resources, resourceId)
    }
  } finally {
    if (BuildConfig.DEBUG) {
      val policy: StrictMode.ThreadPolicy = StrictMode.ThreadPolicy.Builder().detectNetwork().build()
      StrictMode.setThreadPolicy(policy)
    }
  }
}

fun Bitmap?.toDrawable(context: Context): Drawable? {
  this ?: return null
  return BitmapDrawable(context.resources, this)
}

fun View.setCornerRadius(radius: Int) {
  clipToOutline = true
  outlineProvider = object : ViewOutlineProvider() {
    override fun getOutline(view: View, outline: Outline?) {
      outline?.setRoundRect(0, 0, view.width, view.height, radius.toFloat())
    }
  }
}

fun androidx.fragment.app.Fragment.safeShow(
  manager: FragmentManager,
  tag: String?
) {
  val ft = manager.beginTransaction()
  ft.add(this, tag)
  ft.commitAllowingStateLoss()
}
