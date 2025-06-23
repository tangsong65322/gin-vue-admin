import UIKit
import QuartzCore

// 动画代理类，用于回调
class AnimationDelegate: NSObject, CAAnimationDelegate {
	var start: (() -> Void)?
	var end: (() -> Void)?

	init(start: (() -> Void)?, end: (() -> Void)?) {
		self.start = start
		self.end = end
	}

	func animationDidStart(_ anim: CAAnimation) {
		start?()
	}

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		end?()
	}
}

// 扩展CGFloat以支持角度到弧度的转换
extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}
	
class xdAnimation {
	// 平移动画
	static func translate(
	    view: UIView,
	    duration: TimeInterval = 1.0,
	    delay: TimeInterval = 0,
	    translation: Int = 0, // 0平行移x,1平移y,2平移x,y
	    fromLen: CGFloat = 0,
	    len: CGFloat = 0,
	    loop: Int = 0,
	    start: (() -> Void)? = nil,
	    end: (() -> Void)? = nil
	) {
			let  timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
	      // 创建动画
	        let animation: CAPropertyAnimation
	        
	        switch translation {
	        case 1: // Y轴平移
	            let basicAnimation = CABasicAnimation(keyPath: "transform.translation.y")
	            basicAnimation.fromValue = fromLen
	            basicAnimation.toValue = len
	            animation = basicAnimation
	            
	        case 2: // XY轴同时平移
	            let keyframeAnimation = CAKeyframeAnimation(keyPath: "position")
	            let path = CGMutablePath()
	            let startPoint = CGPoint(x: view.frame.origin.x + fromLen, y: view.frame.origin.y + fromLen)
	            let endPoint = CGPoint(x: view.frame.origin.x + len, y: view.frame.origin.y + len)
	            path.move(to: startPoint)
	            path.addLine(to: endPoint)
	            keyframeAnimation.path = path
	            animation = keyframeAnimation
	            
	        default: // X轴平移
	            let basicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
	            basicAnimation.fromValue = fromLen
	            basicAnimation.toValue = len
	            animation = basicAnimation
	        }
	        
	        // 设置基本属性
	        animation.duration = duration
	        animation.beginTime = CACurrentMediaTime() + delay
	        animation.timingFunction = timingFunction // 设置时间曲线
	        animation.isRemovedOnCompletion = false // 动画结束后不要移除
	        animation.fillMode = .forwards // 保持动画最后一帧
	        
	        // 设置循环
	        if loop == -1 {
	            animation.repeatCount = .infinity
	        } else {
	            animation.repeatCount = Float(loop)
	        }
	        
	        // 添加动画
	        CATransaction.begin()
	        CATransaction.setCompletionBlock {
	            end?()
	        }
	        start?()
	        view.layer.add(animation, forKey: "translation")
	        CATransaction.commit()
	}
	
	static func rotate(view: UIView,
	            duration: TimeInterval = 1.0,
	            delay: TimeInterval = 0.0,
	            fromDeg: CGFloat = 0.0,
	            deg: CGFloat = 360.0,
	            loop: Int = 0,
	            start: (() -> Void)? = nil,
	            end: (() -> Void)? = nil) {
	
	    // 创建旋转动画
		let  timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear)
	    let rotation = CABasicAnimation(keyPath: "transform.rotation")
	    rotation.fromValue = fromDeg * .pi / 180.0  // 将度数转为弧度
	    rotation.toValue = deg * .pi / 180.0  // 将度数转为弧度
	    rotation.duration = duration
	    rotation.beginTime = CACurrentMediaTime() + delay
	    rotation.isCumulative = true
		rotation.timingFunction = timingFunction // 设置时间曲线
		rotation.isRemovedOnCompletion = false // 动画结束后不要移除
		rotation.fillMode = .forwards // 保持动画最后一帧
	    
	    // 设置循环次数
	    if loop == -1 {
	        rotation.repeatCount = .infinity
	    } else {
	        rotation.repeatCount = Float(loop)
	    }
	
	    // 开始时的回调
	    if let startAction = start {
	        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
	            startAction()
	        }
	    }
	
	    // 使用 CATransaction 来处理动画完成后的回调
	    CATransaction.begin()
	    
	    // 设置动画完成时的回调
	    CATransaction.setCompletionBlock {
	        end?()
	    }
	    
	    // 添加动画到视图的层上
	    view.layer.add(rotation, forKey: "rotationAnimation")
	    
	    // 提交事务
	    CATransaction.commit()
	}
	
	// 缩放动画
	static func scale(view: UIView,
	           duration: TimeInterval = 1.0,
	           delay: TimeInterval = 0.0,
	           direction: Int = 0,
	           fromScale: CGFloat = 0.0,
	           scale: CGFloat = 1.0,
	           loop: Int = 0,
	           start: (() -> Void)? = nil,
	           end: (() -> Void)? = nil) {
	    
	    // 创建动画集合
	    var scaleAnimations = [CABasicAnimation]()
	    
	    switch direction {
	    case 1: // 竖直缩放 (Y轴)
	        let scaleY = CABasicAnimation(keyPath: "transform.scale.y")
	        scaleY.fromValue = fromScale
	        scaleY.toValue = scale
	        scaleAnimations = [scaleY]
	        
	    case 2: // XY轴同时缩放
	        let scaleX = CABasicAnimation(keyPath: "transform.scale.x")
	        scaleX.fromValue = fromScale
	        scaleX.toValue = scale
	        
	        let scaleY = CABasicAnimation(keyPath: "transform.scale.y")
	        scaleY.fromValue = fromScale
	        scaleY.toValue = scale
	        
	        scaleAnimations = [scaleX, scaleY]
	        
	    default: // 水平缩放 (X轴)
	        let scaleX = CABasicAnimation(keyPath: "transform.scale.x")
	        scaleX.fromValue = fromScale
	        scaleX.toValue = scale
	        scaleAnimations = [scaleX]
	    }
	    
	    // 设置动画属性
	    for animation in scaleAnimations {
	        animation.duration = duration
	        animation.beginTime = CACurrentMediaTime() + delay
	        animation.isCumulative = true
			animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 设置时间曲线
			animation.isRemovedOnCompletion = false // 动画结束后不要移除
			animation.fillMode = .forwards // 保持动画最后一帧
	        
	        if loop == -1 {
	            animation.repeatCount = .infinity
	        } else {
	            animation.repeatCount = Float(loop)
	        }
	        
	    }
	    
	    // 使用 CATransaction 来管理动画的开始和结束
	    CATransaction.begin()
	    
	    // 动画开始时的回调
	    if let startAction = start {
	        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
	            startAction()
	        }
	    }
	
	    // 设置动画完成时的回调
	    CATransaction.setCompletionBlock {
	        end?()
	    }
	    
	    // 添加动画到视图的层上
		var i=0
	    for animation in scaleAnimations {
	        view.layer.add(animation, forKey: "scaleAnimation"+i.toString())
			i+=1;
	    }
	    
	    // 提交事务
	    CATransaction.commit()
	}
	private func deg2rad(_ degree: CGFloat) -> CGFloat {
	    return degree * .pi / 180
	}
	
	// 3D翻转动画
	static func flip3D(
	view: UIView,
	duration: TimeInterval = 1.0,
	delay: TimeInterval = 0.0,
	axis: Int = 1,
	fromDeg: CGFloat = 0.0, // 旋转角度
	deg: CGFloat = 180.0, // 旋转角度
	loop: Int = 0,
	cameraDistance: CGFloat = 8.0,
	scaleZ: CGFloat = 0.8, 
	start: (() -> Void)? = nil,
	end: (() -> Void)? = nil) {
	    
	   let adjustedDeg: CGFloat = deg
	   // 设置3D透视效果
	   var transform = CATransform3DIdentity
	   transform.m34 = -1.0 / cameraDistance
	   view.layer.transform = transform
	   
	   // 根据旋转轴选择旋转方式
	   var rotationTransform: CATransform3D
	   if axis == 1 { // 绕Y轴旋转
		   rotationTransform = CATransform3DMakeRotation(fromDeg.toRadians(), 0, 1, 0)
	   } else { // 绕X轴旋转
		   rotationTransform = CATransform3DMakeRotation(fromDeg.toRadians(), 1, 0, 0)
	   }
	   
	   // 设置初始角度
	   view.layer.transform = rotationTransform
	   
	   // 执行动画
	   UIView.animate(
		   withDuration: duration,
		   delay: delay,
		   options: [.curveLinear],
		   animations: {
			   start?() // 执行开始时的回调
			   // 计算目标角度
			   let finalTransform: CATransform3D
			   if axis == 1 { // 绕Y轴旋转
				   finalTransform = CATransform3DMakeRotation(adjustedDeg.toRadians(), 0, 1, 0)
			   } else { // 绕X轴旋转
				   finalTransform = CATransform3DMakeRotation(adjustedDeg.toRadians(), 1, 0, 0)
			   }
			   
			   // 添加Z轴缩放效果
			   let scaleTransform = CATransform3DScale(finalTransform, 1, 1, scaleZ)
			   view.layer.transform = scaleTransform
		   },
		   completion: { finished in
			   if loop > 1 {
				   // 如果需要循环，递归调用
				   flip3D(
					   view: view,
					   duration: duration,
					   delay: delay,
					   axis: axis,
					   fromDeg: adjustedDeg,
					   deg: fromDeg,
					   loop: loop - 1,
					   cameraDistance: cameraDistance,
					   scaleZ: scaleZ,
					   start: start,
					   end: end
				   )
			   } else {
				   end?() // 执行结束时的回调
			   }
		   }
	   )
	}
	
	
	
	
	
}