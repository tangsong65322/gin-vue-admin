package uts.sdk.modules.utsXdxdAnimation


import android.view.View
import android.animation.ObjectAnimator
import android.animation.Animator
import android.animation.AnimatorInflater
import android.graphics.Path
import android.animation.AnimatorSet
import android.animation.AnimatorListenerAdapter
import android.animation.TimeInterpolator
import android.view.animation.LinearInterpolator
import android.animation.ValueAnimator

class xdAnimation private constructor() {
	val runningAnimators = mutableListOf<Animator>()
    companion object {

        // 平移动画
        fun translate(
            view: View,
            duration: Long = 1000,
            delay: Long = 0,
			translation : Int = 0, //0平行移x,1平移y,2平移x,y
			fromLen:Float = 0f,
			len:Float = 0f,
			loop: Int = 0,
            start: (() -> Unit)? = null,
            end: (() -> Unit)? = null
        ) {
         
			val animator = when (translation) {
				1 -> { // Y轴平移
					ObjectAnimator.ofFloat(view, "translationY", fromLen, len)
				}
				2 -> { // XY轴同时平移
					val path = Path().apply {
						moveTo(fromLen, fromLen)
						lineTo(len, len)
					}
					ObjectAnimator.ofFloat(view, View.X, View.Y, path)
				}
				else -> { // X轴平移
					ObjectAnimator.ofFloat(view, "translationX", fromLen, len)
				}
			}
			// animator.repeatMode = ObjectAnimator.RESTART
			if (loop == -1) {
			    animator.repeatCount = ObjectAnimator.INFINITE
			} else {
			    animator.repeatCount = loop
			}
			
            animator.duration = duration
            animator.startDelay = delay
            animator.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationStart(animation: Animator) {
                    start?.invoke()
                }

                override fun onAnimationEnd(animation: Animator) {
                    end?.invoke()
                }
            })
            animator.start()
        }

        // 旋转动画
        fun rotate(
            view: View,
            duration: Long = 1000,
            delay: Long = 0,
			fromDeg: Float = 0f,
			deg: Float = 360f,
			loop: Int = 0,
            start: (() -> Unit)? = null,
            end: (() -> Unit)? = null
        ) {
            val animator = ObjectAnimator.ofFloat(view, "rotation", fromDeg, deg)
			animator.repeatMode = ObjectAnimator.RESTART
			if (loop == -1) {
			    animator.repeatCount = ObjectAnimator.INFINITE
			} else {
			    animator.repeatCount = loop
			}
			
			animator.interpolator = LinearInterpolator()
            animator.duration = duration
            animator.startDelay = delay
            animator.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationStart(animation: Animator) {
                    start?.invoke()
                }
                override fun onAnimationEnd(animation: Animator) {
                    end?.invoke()
                }
            })
            animator.start()
			// runningAnimators.add(animator)
        }

        // 3D翻转动画
        fun flip3D(
            view: View,
            duration: Long = 1000,
            delay: Long = 0,
            axis: Int = 1, // 0: X轴, 1: Y轴
            fromDeg: Float = 0f, // 旋转角度
            deg: Float = 180f, // 旋转角度
            loop: Int = 0,
            cameraDistance: Float = 8f, // 控制视角距离，默认值更合理
            scaleZ: Float = 0.8f, // 控制Z轴缩放，默认值更自然
            start: (() -> Unit)? = null,
            end: (() -> Unit)? = null
        ) {
            view.pivotX = if (axis == 0) view.width / 2f else view.pivotX
            view.pivotY = if (axis == 1) view.height / 2f else view.pivotY
        
            val rotateProperty = if (axis == 0) "rotationX" else "rotationY"
            val rotateFrom = fromDeg
            val rotateTo = deg
        
            val rotateAnimator = ObjectAnimator.ofFloat(view, rotateProperty, rotateFrom, rotateTo)
            val scaleZAnimator = ObjectAnimator.ofFloat(view, "scale", scaleZ, scaleZ)
            
            rotateAnimator.repeatMode = ObjectAnimator.RESTART
            if (loop == -1) {
                rotateAnimator.repeatCount = ObjectAnimator.INFINITE
            } else {
                rotateAnimator.repeatCount = loop
            }
        
            val animatorSet = AnimatorSet()
            animatorSet.playTogether(rotateAnimator, scaleZAnimator)
            animatorSet.duration = duration
            animatorSet.startDelay = delay
            
            animatorSet.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationStart(animation: Animator) {
                    start?.invoke()
                    // 使用传入的参数控制摄像机距离
                    view.cameraDistance = view.width * cameraDistance
                }
        
                override fun onAnimationEnd(animation: Animator) {
                    end?.invoke()
                }
            })
            
            animatorSet.start()
        }
		
		/**
		 * 清除视图上的所有动画
		 * @param view 需要清除动画的视图
		 * @param reset 是否重置视图属性到初始状态
		 */
		fun clearAnimations(
		    view: View,
		    reset: Boolean = true
		) {
		    view.animate().cancel()
		    view.clearAnimation()
			
		    // 如果需要重置视图属性
		    if (reset) {
		        // 重置所有变换
		        view.translationX = 0f
		        view.translationY = 0f
		        view.scaleX = 1f
		        view.scaleY = 1f
		        view.rotation = 0f
		        view.rotationX = 0f
		        view.rotationY = 0f
		        view.alpha = 1f
		        // 重置视角距离
		        view.cameraDistance = 0f
		    }
		}
        
        fun scale(
            view: View,
            duration: Long = 1000,
            delay: Long = 0,
            direction: Int = 0, // 0: 水平缩放, 1: 竖直翻转,2:x,y缩放,
			fromScale: Float = 0f,
			scale: Float = 1f,
			loop: Int = 0,
            start: (() -> Unit)? = null,
            end: (() -> Unit)? = null
        ) {
            when (direction) {
				1 -> { // Y轴缩放
					val scaleY = ObjectAnimator.ofFloat(view, "scaleY", fromScale, scale)
					scaleY.duration = duration
					scaleY.startDelay = delay
					// scaleY.interpolator = LinearInterpolator()
					if (loop == -1) {
						scaleY.repeatCount = ObjectAnimator.INFINITE
					} else {
						scaleY.repeatCount = loop
					}
					scaleY.addListener(object : AnimatorListenerAdapter() {
						override fun onAnimationStart(animation: Animator) {
							start?.invoke()
						}
						override fun onAnimationEnd(animation: Animator) {
							end?.invoke()
						}
					})
					scaleY.start()
				}
				2 -> { // XY轴同时缩放
					val scaleX = ObjectAnimator.ofFloat(view, "scaleX", fromScale, scale)
					val scaleY = ObjectAnimator.ofFloat(view, "scaleY", fromScale, scale)
					
					// 为每个动画单独设置循环
					if (loop == -1) {
						scaleX.repeatCount = ObjectAnimator.INFINITE
						scaleY.repeatCount = ObjectAnimator.INFINITE
					} else {
						scaleX.repeatCount = loop
						scaleY.repeatCount = loop
					}
		
					val animatorSet = AnimatorSet()
					animatorSet.playTogether(scaleX, scaleY)
					animatorSet.duration = duration
					animatorSet.startDelay = delay
					// animatorSet.interpolator = LinearInterpolator()
					animatorSet.addListener(object : AnimatorListenerAdapter() {
						override fun onAnimationStart(animation: Animator) {
							start?.invoke()
						}
						override fun onAnimationEnd(animation: Animator) {
							end?.invoke()
						}
					})
					animatorSet.start()
				}
				else -> { // X轴缩放
					val scaleX = ObjectAnimator.ofFloat(view, "scaleX", fromScale, scale)
					// scaleX.interpolator = LinearInterpolator()
					scaleX.duration = duration
					scaleX.startDelay = delay
					if (loop == -1) {
						scaleX.repeatCount = ObjectAnimator.INFINITE
					} else {
						scaleX.repeatCount = loop
					}
					scaleX.addListener(object : AnimatorListenerAdapter() {
						override fun onAnimationStart(animation: Animator) {
							start?.invoke()
						}
						override fun onAnimationEnd(animation: Animator) {
							end?.invoke()
						}
					})
					scaleX.start()
				}
			}
        }
    }
}