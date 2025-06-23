package uts.sdk.modules.utsXKeyboardheightchangeS
import android.app.Activity
import android.graphics.Rect
import android.os.Build
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowInsets

typealias cacelCallBack = () -> Unit

fun keyboardHeightChangeByKt(activity: Activity, callback: (height: Int) -> Unit): cacelCallBack {
    val rootView = activity.window.decorView.rootView
    val rect = Rect()
    var lastHeight = 0
    
    val listener = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        // Android 11及以上使用WindowInsets API
        View.OnApplyWindowInsetsListener { _, insets ->
            val imeHeight = insets.getInsets(WindowInsets.Type.ime()).bottom
            val navigationBarHeight = insets.getInsets(WindowInsets.Type.navigationBars()).bottom
            val keyboardHeight = if (imeHeight > 0) imeHeight - navigationBarHeight else 0
            
            if (keyboardHeight != lastHeight) {
                lastHeight = keyboardHeight
                callback(keyboardHeight)
            }
            insets
        }
    } else {
        // Android 5.0 - Android 10使用传统方法
        ViewTreeObserver.OnGlobalLayoutListener {
            rootView.getWindowVisibleDisplayFrame(rect)
            val screenHeight = rootView.height
            val keyboardHeight = screenHeight - rect.bottom
            
            // 考虑导航栏高度
            val navigationBarHeight = getNavigationBarHeight(activity)
            
            val actualKeyboardHeight = if (keyboardHeight > navigationBarHeight) {
                keyboardHeight - navigationBarHeight
            } else 0
            
            if (actualKeyboardHeight != lastHeight) {
                lastHeight = actualKeyboardHeight
                callback(actualKeyboardHeight)
            }
        }
    }
    
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        rootView.setOnApplyWindowInsetsListener(listener as View.OnApplyWindowInsetsListener)
    } else {
        rootView.viewTreeObserver.addOnGlobalLayoutListener(listener as ViewTreeObserver.OnGlobalLayoutListener)
    }
    
    return {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            rootView.setOnApplyWindowInsetsListener(null)
        } else {
            rootView.viewTreeObserver.removeOnGlobalLayoutListener(listener as ViewTreeObserver.OnGlobalLayoutListener)
        }
    }
}

// 添加原生方法检测导航栏高度
private fun getNavigationBarHeight(activity: Activity): Int {
    val resources = activity.resources
    val resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android")
    return if (resourceId > 0 && hasNavigationBar(activity)) {
        resources.getDimensionPixelSize(resourceId)
    } else 0
}

// 检测设备是否有导航栏
private fun hasNavigationBar(activity: Activity): Boolean {
    val windowManager = activity.windowManager
    val d = windowManager.defaultDisplay
    
    val realDisplayMetrics = android.util.DisplayMetrics()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        d.getRealMetrics(realDisplayMetrics)
    }
    
    val displayMetrics = android.util.DisplayMetrics()
    d.getMetrics(displayMetrics)
    
    return realDisplayMetrics.heightPixels > displayMetrics.heightPixels
}