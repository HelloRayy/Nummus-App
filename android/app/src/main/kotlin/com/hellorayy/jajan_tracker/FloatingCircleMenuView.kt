package com.hellorayy.jajan_tracker

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.View
import android.view.animation.DecelerateInterpolator
import android.view.animation.OvershootInterpolator
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.cos
import kotlin.math.sin

/**
 * AssistiveTouch-style radial floating circle menu HUD inspired by TLAndroidFloatingCircleMenu.
 * Displays live daily budget status in the center circle and fans out 4 quick action buttons
 * radially inward from whichever screen edge the bubble is snapped to.
 */
class FloatingCircleMenuView(context: Context) : FrameLayout(context) {

    data class MenuItem(
        val id: String,
        val shortIcon: String,
        val label: String,
        val accentColor: Int
    )

    interface Listener {
        fun onMenuItemClicked(itemId: String)
        fun onExpandStateChanged(expanded: Boolean)
    }

    var listener: Listener? = null
    var isExpanded: Boolean = false
        private set
    var isDockedRight: Boolean = false

    private val density = context.resources.displayMetrics.density
    private val centerSizePx = (62 * density).toInt()
    private val itemSizePx = (52 * density).toInt()
    private val radiusPx = (86 * density).toInt()
    private val expandedSizePx = (radiusPx * 2 + itemSizePx + (24 * density).toInt())

    private val centerButton: LinearLayout
    private val centerAmountText: TextView
    private val centerSubText: TextView
    private val itemViews = mutableListOf<LinearLayout>()
    private var currentAnimator: ValueAnimator? = null

    private val menuItems = listOf(
        MenuItem("check", "Rp", "Cek", Color.parseColor("#22C55E")),
        MenuItem("info", "i", "Info", Color.parseColor("#3B82F6")),
        MenuItem("save", "+", "Tahan", Color.parseColor("#F59E0B")),
        MenuItem("hide", "×", "5m", Color.parseColor("#EF4444"))
    )

    init {
        clipChildren = false
        clipToPadding = false

        // Create 4 radial action buttons (initially hidden at center)
        for (item in menuItems) {
            val itemView = createRadialButton(item)
            itemView.visibility = View.GONE
            itemView.alpha = 0f
            itemView.scaleX = 0.4f
            itemView.scaleY = 0.4f
            addView(itemView, LayoutParams(itemSizePx, itemSizePx, Gravity.CENTER))
            itemViews.add(itemView)
        }

        // Create center AssistiveTouch HUD button
        centerAmountText = TextView(context).apply {
            text = "0k"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            includeFontPadding = false
        }

        centerSubText = TextView(context).apply {
            text = "SISA"
            setTextColor(Color.parseColor("#CBD5E1"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 8f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            includeFontPadding = false
        }

        centerButton = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            elevation = 12 * density
            background = buildCircleDrawable(
                fillColor = Color.parseColor("#E6111827"),
                strokeColor = Color.parseColor("#22C55E"),
                strokeWidthDp = 2.5f
            )
            addView(centerAmountText)
            addView(centerSubText)
        }

        addView(centerButton, LayoutParams(centerSizePx, centerSizePx, Gravity.CENTER))
        updateContainerSize(expanded = false)
    }

    private fun createRadialButton(item: MenuItem): LinearLayout {
        val iconTv = TextView(context).apply {
            text = item.shortIcon
            setTextColor(item.accentColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            includeFontPadding = false
        }

        val labelTv = TextView(context).apply {
            text = item.label
            setTextColor(Color.parseColor("#F8FAFC"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 9f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            includeFontPadding = false
        }

        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            elevation = 10 * density
            background = buildCircleDrawable(
                fillColor = Color.parseColor("#EB1E293B"),
                strokeColor = item.accentColor,
                strokeWidthDp = 1.5f
            )
            addView(iconTv)
            addView(labelTv)
            setOnClickListener {
                performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                collapse()
                listener?.onMenuItemClicked(item.id)
            }
        }
    }

    private fun buildCircleDrawable(fillColor: Int, strokeColor: Int, strokeWidthDp: Float): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(fillColor)
            setStroke((strokeWidthDp * density).toInt(), strokeColor)
        }
    }

    fun getCollapsedSizePx(): Int = centerSizePx + (12 * density).toInt()

    fun getExpandedSizePx(): Int = expandedSizePx

    fun updateBudgetDisplay(dailyRemaining: Long, dailyLimit: Long) {
        val (badgeText, subText, strokeColor) = when {
            dailyRemaining <= 0L -> Triple("STOP", "HABIS", Color.parseColor("#EF4444"))
            dailyLimit > 0L && dailyRemaining * 100 / dailyLimit <= 30L -> {
                Triple(formatCompactRp(dailyRemaining), "MEPET", Color.parseColor("#F59E0B"))
            }
            else -> Triple(formatCompactRp(dailyRemaining), "AMAN", Color.parseColor("#22C55E"))
        }

        centerAmountText.text = badgeText
        centerSubText.text = subText
        centerSubText.setTextColor(strokeColor)
        centerButton.background = buildCircleDrawable(
            fillColor = Color.parseColor("#E6111827"),
            strokeColor = strokeColor,
            strokeWidthDp = 2.5f
        )
    }

    private fun formatCompactRp(amount: Long): String {
        val absVal = kotlin.math.abs(amount)
        return when {
            absVal >= 1_000_000L -> String.format("%.1fj", absVal / 1_000_000.0)
            absVal >= 1_000L -> "${absVal / 1_000L}k"
            else -> "$absVal"
        }
    }

    fun toggle() {
        if (isExpanded) collapse() else expand()
    }

    fun expand() {
        if (isExpanded) return
        isExpanded = true
        updateContainerSize(expanded = true)
        listener?.onExpandStateChanged(true)

        // Fan angles inward depending on which screen edge the bubble is docked on
        val anglesDeg = if (isDockedRight) {
            listOf(112.5, 157.5, 202.5, 247.5)
        } else {
            listOf(-67.5, -22.5, 22.5, 67.5)
        }

        currentAnimator?.cancel()
        itemViews.forEach { it.visibility = View.VISIBLE }

        currentAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 240L
            interpolator = OvershootInterpolator(1.1f)
            addUpdateListener { anim ->
                val progress = anim.animatedValue as Float
                itemViews.forEachIndexed { index, view ->
                    val rad = Math.toRadians(anglesDeg[index])
                    view.translationX = (cos(rad) * radiusPx * progress).toFloat()
                    view.translationY = (sin(rad) * radiusPx * progress).toFloat()
                    view.alpha = progress.coerceIn(0f, 1f)
                    val scale = 0.4f + 0.6f * progress
                    view.scaleX = scale
                    view.scaleY = scale
                }
            }
            start()
        }
    }

    fun collapse() {
        if (!isExpanded) return
        isExpanded = false

        val startPositions = itemViews.map { it.translationX to it.translationY }

        currentAnimator?.cancel()
        currentAnimator = ValueAnimator.ofFloat(1f, 0f).apply {
            duration = 160L
            interpolator = DecelerateInterpolator()
            addUpdateListener { anim ->
                val progress = anim.animatedValue as Float
                itemViews.forEachIndexed { index, view ->
                    val (sx, sy) = startPositions[index]
                    view.translationX = sx * progress
                    view.translationY = sy * progress
                    view.alpha = progress.coerceIn(0f, 1f)
                    val scale = 0.4f + 0.6f * progress
                    view.scaleX = scale
                    view.scaleY = scale
                }
                if (progress <= 0.01f) {
                    itemViews.forEach { it.visibility = View.GONE }
                    updateContainerSize(expanded = false)
                    listener?.onExpandStateChanged(false)
                }
            }
            start()
        }
    }

    private fun updateContainerSize(expanded: Boolean) {
        val targetSize = if (expanded) expandedSizePx else getCollapsedSizePx()
        minimumWidth = targetSize
        minimumHeight = targetSize
    }
}
