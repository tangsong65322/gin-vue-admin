import UIKit
class XdBlur {
    /// 为视图添加背景模糊效果
    /// - Parameters:
    ///   - view: 需要添加模糊效果的目标视图
    ///   - style: 模糊样式（Light, Dark, ExtraLight）
    ///   - intensity: 模糊强度，范围 0-1
    ///   - backgroundColor: 可选的背景颜色叠加
    static func applyBlur(
        to view: UIView, 
        style: UIBlurEffect.Style = .light,
        intensity: CGFloat = 0.8,
        backgroundColor: UIColor? = nil
    ) {
        // 移除之前可能存在的模糊效果
        view.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }
        
        // 创建模糊效果
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        // 调整模糊强度
        if #available(iOS 13.0, *) {
            let vibrancyView = UIVisualEffectView(effect: 
                UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
            )
            blurView.contentView.addSubview(vibrancyView)
        }
        
        // 设置frame与目标视图一致
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 设置透明度控制模糊强度
        blurView.alpha = intensity
        
        // 如果需要叠加背景色
        if let backgroundColor = backgroundColor {
            let colorView = UIView(frame: blurView.bounds)
            colorView.backgroundColor = backgroundColor
            colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.contentView.addSubview(colorView)
        }
        
        // 插入到视图底部
        view.insertSubview(blurView, at: 0)
    }
    
    /// 移除背景模糊效果
    /// - Parameter view: 需要移除模糊效果的视图
    static func removeBlur(from view: UIView) {
        view.subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }
    }
    
    /// 为视图添加自定义高斯模糊效果
    /// - Parameters:
    ///   - view: 目标视图
    ///   - radius: 模糊半径
    ///   - tintColor: 颜色叠加
    static func applyCustomBlur(
        to view: UIView, 
        radius: CGFloat = 10,
        tintColor: UIColor? = nil
    ) {
        // 创建模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        // 应用额外的模糊
        let vibrancyView = UIVisualEffectView(effect: 
            UIVibrancyEffect(blurEffect: blurEffect)
        )
        
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 添加自定义颜色叠加
        if let tintColor = tintColor {
            let colorView = UIView(frame: blurView.bounds)
            colorView.backgroundColor = tintColor
            colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.contentView.addSubview(colorView)
        }
        
        view.insertSubview(blurView, at: 0)
    }
	
	static func applyBlurSelf(ele: UIView ,bg:UIView, blur: CGFloat, backgroundColor: UIColor = .clear) {
	     // Create snapshot of element
		UIGraphicsBeginImageContextWithOptions(ele.bounds.size, false, 0)
		ele.layer.render(in: UIGraphicsGetCurrentContext()!)
		let snapshot = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		// Create blur effect
		let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
		effectView.frame = bg.bounds
		
		// Create color overlay
		let colorView = UIView(frame: bg.bounds)
		colorView.backgroundColor = backgroundColor
		colorView.alpha = blur
		
		// Add views to background
		bg.addSubview(effectView)
		bg.addSubview(colorView)
		
		// Set snapshot as background
		let imageView = UIImageView(image: snapshot)
		imageView.frame = bg.bounds
		bg.insertSubview(imageView, at: 0)
	}
}