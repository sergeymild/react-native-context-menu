package com.contextmenu.contextMenuPresentationModal

import android.view.View
import android.widget.LinearLayout

fun wrapChildrenInLinearLayout(
  parent: LinearLayout,
  children: List<View>,
  maxWidth: Int
) {
  parent.orientation = LinearLayout.VERTICAL
  parent.removeAllViews()

  var currentRow = LinearLayout(parent.context).apply {
    orientation = LinearLayout.HORIZONTAL
  }
  var usedWidth = 0

  for (child in children) {
    child.measure(
      View.MeasureSpec.UNSPECIFIED,
      View.MeasureSpec.UNSPECIFIED
    )
    val childWidth = child.measuredWidth

    if (usedWidth + childWidth > maxWidth) {
      // Добавляем строку в parent
      parent.addView(currentRow)
      // Начинаем новую строку
      currentRow = LinearLayout(parent.context).apply {
        orientation = LinearLayout.HORIZONTAL
      }
      usedWidth = 0
    }

    currentRow.addView(child)
    usedWidth += childWidth
  }

  // Добавляем последнюю строку
  if (currentRow.childCount > 0) {
    parent.addView(currentRow)
  }
}
