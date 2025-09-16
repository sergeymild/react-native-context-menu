package com.contextmenu.contextMenuPresentationModal

import android.content.DialogInterface
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.annotation.ColorInt
import androidx.fragment.app.DialogFragment
import com.contextmenu.R
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import kotlin.math.max


data class BottomMenuItem(
  val id: String,
  val title: String,
  val titleSize: Float,
  val iconSize: Int,
  val icon: ReadableMap?,
  @ColorInt
  val color: Int,
  @ColorInt
  val iconTint: Int,
  val itemHeight: Int
)

internal class FullScreenDialog(
  private val params: ReadableMap,
  private var onDismiss: ((String?, String) -> Unit)?
) : DialogFragment() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setStyle(STYLE_NORMAL, R.style.Theme_FullScreenDialog)
  }

  override fun onStart() {
    super.onStart()
    dialog?.window?.let {
      val width = ViewGroup.LayoutParams.MATCH_PARENT
      val height = ViewGroup.LayoutParams.MATCH_PARENT
      it.setLayout(width, height)
      it.setFormat(PixelFormat.TRANSLUCENT)
      it.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
      it.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
    }
  }

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View {
    super.onCreateView(inflater, container, savedInstanceState)
    val parent = inflater.inflate(R.layout.dialog, container, false)
    return parent
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    view.findViewById<FrameLayout>(R.id.container).setOnClickListener {
      println("⚽️ FullScreenDialog.click")
      dismissAllowingStateLoss()
    }
    showMenu(params.getArray("bottomMenuItems")!!)
  }

  private fun invalidateMenuContainer(menuContainer: LinearLayout) {
    menuContainer.requestLayout()
    menuContainer.invalidate()
    menuContainer.post {
      val menuWidth = max(params.width("minWidth", 0), menuContainer.width)
      if (menuContainer.width < menuWidth) {
        menuContainer.layoutParams.width = menuWidth
        menuContainer.requestLayout()
        menuContainer.invalidate()
      }

      val menuItemHeight = params.getDouble("menuItemHeight").dp()
      val menuHeight = menuContainer.childCount * menuItemHeight
      val screenHeight = requireView().height - params.getDouble("safeAreaBottom").dp()
      val screenWidth = requireView().width
      val rect = params.getMap("rect")!!

      // start of parent
      var right = (rect.getDouble("x")).toInt().dpf()

      // end of parent
      if (params.hasKey("gravity") && params.getString("gravity") == "end") {
        right += (rect.getDouble("width")).toInt().dpf()
      }

      // center of parent
      if (!params.hasKey("gravity")) {
        right = (rect.getDouble("x")).toInt().dpf() + ( (rect.getDouble("width")).toInt().dpf() / 2)
        right -= menuWidth / 2
      }
      if (right == 0f) right = 8.dpf()

      if (right.toInt() + menuWidth >= screenWidth) {
        right = screenWidth - menuWidth - 8.dpf()
      }

      var top = (rect.getDouble("height") + rect.getDouble("y")).toInt().dpf() + 8.dpf()
      if (top.toInt() + menuHeight > screenHeight) {
        top = (screenHeight - menuHeight - 8.dp()).toFloat()
      }
      menuContainer.x = max(16.dp().toFloat(), right)
      menuContainer.y = top
    }
  }

  private fun showMenu(items: ReadableArray) {
    val size = items.size()
    val menuItemHeight = params.getDouble("menuItemHeight").dp()
    val menuCornerRadius = params.getDouble("menuCornerRadius").dp()
    val leadingIcons = params.getBoolean("leadingIcons")
    val menuContainer = requireView().findViewById<LinearLayout>(R.id.menu_container)
    menuContainer.setBackgroundColor(
      params.color(
        requireContext(),
        "menuBackgroundColor",
        Color.WHITE
      )
    )
    menuContainer.setCornerRadius(menuCornerRadius)

    for (i in 0 until size) {
      val item = items.getMap(i)
      menuContainer.insertMenuItem(
        requireContext(),
        leadingIcons = leadingIcons,
        data = BottomMenuItem(
          id = item.getString("id")!!,
          title = item.getString("title")!!,
          titleSize = item.getDouble("titleSize").toFloat(),
          iconSize = item.getDouble("iconSize").toFloat().dp(),
          icon = item,
          color = item.color(requireContext(), "color", Color.BLACK),
          iconTint = item.color(requireContext(), "color", Color.BLACK),
          itemHeight = menuItemHeight
        )
      ) {
        if (item.hasKey("submenu")) {
          menuContainer.removeAllViews()
          showMenu(item.getArray("submenu")!!)
          invalidateMenuContainer(menuContainer)
          return@insertMenuItem
        }

        onDismiss?.invoke(it.id, "bottom")
        onDismiss = null
        dismissAllowingStateLoss()
      }
    }

    invalidateMenuContainer(menuContainer)
  }

  override fun onDismiss(dialog: DialogInterface) {
    super.onDismiss(dialog)
    println("⚽️ FullScreenDialog.onDismiss")
    onDismiss?.invoke(null, "")
  }
}
