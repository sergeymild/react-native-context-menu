package com.contextmenu.contextMenuPresentationModal

import android.content.Context
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.graphics.drawable.DrawableCompat
import com.contextmenu.R

internal fun LinearLayout.insertMenuItem(
  context: Context,
  leadingIcons: Boolean,
  data: BottomMenuItem,
  onPress: (BottomMenuItem) -> Unit
) {
  val view = LayoutInflater.from(context).inflate(if (leadingIcons) R.layout.list_item_leading else R.layout.list_item, this, false) as LinearLayout
  view.layoutParams.height = data.itemHeight
  val title = view.findViewById<TextView>(R.id.title)
  val icon = view.findViewById<ImageView>(R.id.icon)

  title.text = data.title
  title.setTextColor(data.color)
  title.setTextSize(TypedValue.COMPLEX_UNIT_SP, data.titleSize)

  icon.visibility = View.GONE
  data.icon?.icon(context, "icon")?.toDrawable(context)?.let {
    icon.visibility = View.VISIBLE
    DrawableCompat.setTint(it, data.iconTint)
    icon.setImageDrawable(it)
    icon.layoutParams.width = data.iconSize
    icon.layoutParams.height = data.iconSize
  }

  view.setOnClickListener { onPress(data) }
  addView(view)
}
