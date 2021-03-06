//
//  Curve.swift
//  curve
//
//  Created by Dom Hofmann on 1/30/18.
//  Copyright © 2018 Dom Hofmann. All rights reserved.
//

import Foundation
import UIKit

public protocol Tweenable {
    static func tweenedValue(begin: Self, end: Self, progress: Float) -> Self
}

public protocol WrappedTweenable: Tweenable {
    associatedtype WrappedType
    init(_ obj: WrappedType)
    func unwrap() -> WrappedType
}

public protocol Wrappable {
    associatedtype WrappedContainerType
    func wrap() -> WrappedContainerType
}

extension Float: Tweenable {
    public static func tweenedValue(begin: Float, end: Float, progress: Float) -> Float {
        return begin + (end - begin) * progress
    }
}

extension CGFloat: Tweenable {
    public static func tweenedValue(begin: CGFloat, end: CGFloat, progress: Float) -> CGFloat {
        return begin + (end - begin) * CGFloat(progress)
    }
}

extension Double: Tweenable {
    public static func tweenedValue(begin: Double, end: Double, progress: Float) -> Double {
        return begin + (end - begin) * Double(progress)
    }
}

extension CGPoint: Tweenable {
    public static func tweenedValue(begin: CGPoint, end: CGPoint, progress: Float) -> CGPoint {
        let diff = CGPoint(x: end.x - begin.x, y: end.y - begin.y)
        return CGPoint(x: begin.x + diff.x * CGFloat(progress), y: begin.y + diff.y * CGFloat(progress))
    }
}

extension CGSize: Tweenable {
    public static func tweenedValue(begin: CGSize, end: CGSize, progress: Float) -> CGSize {
        let diff = CGSize(width: end.width - begin.width, height: end.height - begin.height)
        return CGSize(width: begin.width + diff.width * CGFloat(progress), height: begin.height + diff.height * CGFloat(progress))
    }
}

extension CGRect: Tweenable {
    public static func tweenedValue(begin: CGRect, end: CGRect, progress: Float) -> CGRect {
        let origin = CGPoint.tweenedValue(begin: begin.origin, end: end.origin, progress: progress)
        let size = CGSize.tweenedValue(begin: begin.size, end: end.size, progress: progress)
        return CGRect(origin: origin, size: size)
    }
}

extension CATransform3D: Tweenable {
    public static func tweenedValue(begin: CATransform3D, end: CATransform3D, progress: Float) -> CATransform3D {
        return CATransform3D(
            m11: CGFloat.tweenedValue(begin: begin.m11, end: end.m11, progress: progress),
            m12: CGFloat.tweenedValue(begin: begin.m12, end: end.m12, progress: progress),
            m13: CGFloat.tweenedValue(begin: begin.m13, end: end.m13, progress: progress),
            m14: CGFloat.tweenedValue(begin: begin.m14, end: end.m14, progress: progress),
            m21: CGFloat.tweenedValue(begin: begin.m21, end: end.m21, progress: progress),
            m22: CGFloat.tweenedValue(begin: begin.m22, end: end.m22, progress: progress),
            m23: CGFloat.tweenedValue(begin: begin.m23, end: end.m23, progress: progress),
            m24: CGFloat.tweenedValue(begin: begin.m24, end: end.m24, progress: progress),
            m31: CGFloat.tweenedValue(begin: begin.m31, end: end.m31, progress: progress),
            m32: CGFloat.tweenedValue(begin: begin.m32, end: end.m32, progress: progress),
            m33: CGFloat.tweenedValue(begin: begin.m33, end: end.m33, progress: progress),
            m34: CGFloat.tweenedValue(begin: begin.m34, end: end.m34, progress: progress),
            m41: CGFloat.tweenedValue(begin: begin.m41, end: end.m41, progress: progress),
            m42: CGFloat.tweenedValue(begin: begin.m42, end: end.m42, progress: progress),
            m43: CGFloat.tweenedValue(begin: begin.m43, end: end.m43, progress: progress),
            m44: CGFloat.tweenedValue(begin: begin.m44, end: end.m44, progress: progress)
        )
    }
}

extension CGAffineTransform: Tweenable {
    public static func tweenedValue(begin: CGAffineTransform, end: CGAffineTransform, progress: Float) -> CGAffineTransform {
        return CGAffineTransform(
            a:  CGFloat.tweenedValue(begin: begin.a,  end: end.a,  progress: progress),
            b:  CGFloat.tweenedValue(begin: begin.b,  end: end.b,  progress: progress),
            c:  CGFloat.tweenedValue(begin: begin.c,  end: end.c,  progress: progress),
            d:  CGFloat.tweenedValue(begin: begin.d,  end: end.d,  progress: progress),
            tx: CGFloat.tweenedValue(begin: begin.tx, end: end.tx, progress: progress),
            ty: CGFloat.tweenedValue(begin: begin.ty, end: end.ty, progress: progress)
        )
    }
}

public final class UIColorWrapper: WrappedTweenable {
    public typealias WrappedType = UIColor
    let color: UIColor
    
    public init(_ color: UIColor) {
        self.color = color
    }
    
    public func unwrap() -> UIColor {
        return color
    }
    
    public static func tweenedValue(begin: UIColorWrapper, end: UIColorWrapper, progress: Float) -> UIColorWrapper {
        var redBegin: CGFloat = 0, greenBegin: CGFloat = 0, blueBegin: CGFloat = 0, alphaBegin: CGFloat = 0
        var redEnd: CGFloat = 0, greenEnd: CGFloat = 0, blueEnd: CGFloat = 0, alphaEnd: CGFloat = 0
        
        if begin.color.getRed(&redBegin, green: &greenBegin, blue: &blueBegin, alpha: &alphaBegin)
            && end.color.getRed(&redEnd, green: &greenEnd, blue: &blueEnd, alpha: &alphaEnd) {
            
            let tweenedColor = UIColor(
                red: CGFloat.tweenedValue(begin: redBegin, end: redEnd, progress: progress),
                green: CGFloat.tweenedValue(begin: greenBegin, end: greenEnd, progress: progress),
                blue: CGFloat.tweenedValue(begin: blueBegin, end: blueEnd, progress: progress),
                alpha: CGFloat.tweenedValue(begin: alphaBegin, end: alphaEnd, progress: progress)
            )
            
            return UIColorWrapper(tweenedColor)
        }
        
        return begin
    }
}

extension UIColor: Wrappable {
    public typealias WrappedContainerType = UIColorWrapper
    
    public func wrap() -> UIColorWrapper {
        return UIColorWrapper(self)
    }
}

extension UIView {
    public func animateFrame(to endValue: CGRect, in duration: Double) -> Curve.Animation<CGRect> {
        return animate(\UIView.frame, to: endValue, in: duration)
    }
    
    public func animateFrame(from startValue: CGRect, to endValue: CGRect, in duration: Double) -> Curve.Animation<CGRect> {
        return animate(\UIView.frame, from: startValue, to: endValue, in: duration)
    }
    
    public func animateCenter(to endValue: CGPoint, in duration: Double) -> Curve.Animation<CGPoint> {
        return animate(\UIView.center, to: endValue, in: duration)
    }
    
    public func animateCenter(from startValue: CGPoint, to endValue: CGPoint, in duration: Double) -> Curve.Animation<CGPoint> {
        return animate(\UIView.center, from: startValue, to: endValue, in: duration)
    }
    
    public func animateAlpha(to endValue: CGFloat, in duration: Double) -> Curve.Animation<CGFloat> {
        return animate(\UIView.alpha, to: endValue, in: duration)
    }
    
    public func animateAlpha(from startValue: CGFloat, to endValue: CGFloat, in duration: Double) -> Curve.Animation<CGFloat> {
        return animate(\UIView.alpha, from: startValue, to: endValue, in: duration)
    }
    
    public func animateBackgroundColor(to endValue: UIColor, in duration: Double) -> Curve.Animation<UIColorWrapper> {
        if backgroundColor == nil {
            backgroundColor = UIColor.clear
        }
        
        return animate(\UIView.backgroundColor!, to: UIColorWrapper(endValue), in: duration)
    }
    
    public func animateBackgroundColor(from startValue: UIColor, to endValue: UIColor, in duration: Double) -> Curve.Animation<UIColorWrapper> {
        return animate(\UIView.backgroundColor!, from: UIColorWrapper(startValue), to: UIColorWrapper(endValue), in: duration)
    }
    
    public func animate<T: Tweenable>(_ keyPath: ReferenceWritableKeyPath<UIView, T>, to endValue: T, in duration: Double) -> Curve.Animation<T> {
        let currentValue = self[keyPath: keyPath]
        return Curve.from(currentValue, to: endValue, in: duration).change({ (value: T) in
            self[keyPath: keyPath] = value
        })
    }
    
    public func animate<T: Tweenable>(_ keyPath: ReferenceWritableKeyPath<UIView, T>, from startValue: T, to endValue: T, in duration: Double) -> Curve.Animation<T> {
        return Curve.from(startValue, to: endValue, in: duration).change({ (value: T) in
            self[keyPath: keyPath] = value
        })
    }
    
    public func animate<T: WrappedTweenable>(_ keyPath: ReferenceWritableKeyPath<UIView, T.WrappedType>, to endValue: T, in duration: Double) -> Curve.Animation<T> {
        let currentValue = T.init(self[keyPath: keyPath])
        return Curve.from(currentValue, to: endValue, in: duration).change({ (value: T) in
            self[keyPath: keyPath] = value.unwrap()
        })
    }
    
    public func animate<T: WrappedTweenable>(_ keyPath: ReferenceWritableKeyPath<UIView, T.WrappedType>, from startValue: T, to endValue: T, in duration: Double) -> Curve.Animation<T> {
        return Curve.from(startValue, to: endValue, in: duration).change({ (value: T) in
            self[keyPath: keyPath] = value.unwrap()
        })
    }
}

extension CAKeyframeAnimation {
    public func to(layer: CALayer, keyPath: String) {
        self.keyPath = keyPath
        layer.add(self, forKey: keyPath)
    }
}

public class Curve {
    public typealias TimingFunction = (TimingProps) -> (Float)
    
    public struct TimingProps {
        var t: Float // time
        var b: Float // begin
        var c: Float // change
        var d: Float // duration
        var extras: [Any]?
        
        init(_ t: Float, _ b: Float, _ c: Float, _ d: Float, extras: [Any]? = nil) {
            self.t = t
            self.b = b
            self.c = c
            self.d = d
            self.extras = extras
        }
    }
    
    class Equations {
        static func bounceOut(_ props: TimingProps) -> Float {
            var t = props.t, b = props.b, c = props.c, d = props.d
            t = t / d
            if (t < Float(1/2.75)) {
                return c*(7.5625*t*t) + b
            } else if (t < (2/2.75)) {
                t = t - (1.5/2.75)
                return c*(Float(7.5625)*t*t + 0.75) + b
            } else if (t < (2.5/2.75)) {
                t = t - (2.25/2.75)
                return c*(Float(7.5625)*t*t + 0.9375) + b
            } else {
                t = t - (2.625/2.75)
                return c*(Float(7.5625)*t*t + 0.984375) + b
            }
        }
        
        static func bounceIn(_ props: TimingProps) -> Float {
            let t = props.t, b = props.b, c = props.c, d = props.d
            return c - bounceOut(TimingProps(d-t, 0, c, d)) + b
        }
        
        static func bounceInOut(_ props: TimingProps) -> Float {
            let t = props.t, b = props.b, c = props.c, d = props.d
            if (t < d/2) {
                return bounceIn(TimingProps(t*2, 0, c, d)) * 0.5 + b
            } else {
                return bounceOut(TimingProps(t*2-d, 0, c, d)) * 0.5 + c * 0.5 + b
            }
        }
    }
    
    public enum EasingEquation {
        case linear
        case bounceOut, bounceIn, bounceInOut
        case circOut, circIn, circInOut
        case cubicOut, cubicIn, cubicInOut
        case backOut(overshoot: Float)
        case backIn(overshoot: Float)
        case backInOut(overshoot: Float)
        case custom(_: TimingFunction)
        func functionForType() -> TimingFunction {
            switch self {
            case .linear:
                return { (props: TimingProps) -> Float in
                    let t = props.t, b = props.b, c = props.c, d = props.d
                    return c * t / d + b
                }
            case let .backOut(overshoot):
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / d - 1
                    let s = overshoot
                    return c*(t*t*((s+1)*t + s) + 1) + b
                }
            case let .backIn(overshoot):
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / d - 1
                    let s = overshoot
                    return c*t*t*((s+1)*t - s) + b
                }
            case let .backInOut(overshoot):
                return { (props: TimingProps) -> Float in
                    let t = props.t, b = props.b, c = props.c, d = props.d
                    let t0 = t / (d / 2)
                    let s = overshoot
                    if t0 < 1 {
                        let s0 = s * 1.525
                        return c/2*(t0*t0*((s0+1)*t0 - s0)) + b
                    }
                    
                    let t1 = t0 - 2
                    let s0 = s * 1.525
                    
                    return c/2*((t1)*t1*((s0+1)*t1 + s0) + 2) + b
                }
            case .bounceOut:
                return Equations.bounceOut
            case .bounceIn:
                return Equations.bounceIn
            case .bounceInOut:
                return Equations.bounceInOut
            case .circOut:
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / d - 1
                    return c * (sqrt(1 - t*t) as Float) + b
                }
            case .circIn:
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / d
                    return -c * ((sqrt(1 - t*t) as Float) - 1) + b
                }
            case .circInOut:
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / (d / 2)
                    if (t < 1) {
                        return -c/2 * ((sqrt(1 - t*t) as Float) - 1) + b
                    }
                    t = t - 2
                    return c/2 * ((sqrt(1 - t*t) as Float) + 1) + b
                }
            case .cubicOut:
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / d - 1
                    return c*(t*t*t + 1) + b
                }
            case .cubicIn:
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / d
                    return c*t*t*t + b
                }
            case .cubicInOut:
                return { (props: TimingProps) -> Float in
                    var t = props.t, b = props.b, c = props.c, d = props.d
                    t = t / (d / 2)
                    if (t < 1) {
                        return c/2*t*t*t + b
                    }
                    t = t - 2
                    return c/2*(t*t*t + 2) + b
                }
            case let .custom(timingFunction):
                return timingFunction
            }
        }
    }
    
    public class AbstractAnimation: Hashable {
        enum CompletionType {
            case natural, forced
        }
        
        var completionType: CompletionType = .natural
        var completed: Bool = false
        var cancelled: Bool = false
        
        // MARK: - Hashable
        
        public static func ==(lhs: AbstractAnimation, rhs: AbstractAnimation) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
        
        public var hashValue: Int {
            return ObjectIdentifier(self).hashValue
        }
        
        func tick(time: Double) {
            
        }
    }
    
    public class Animation<T: Tweenable>: AbstractAnimation {
        var startValues: [T]
        var endValues: [T]
        var duration: Double
        var equation: EasingEquation = .linear
        var changeFunctionSingle: ((T) -> Void)?
        var changeFunctionMany: (([T]) -> Void)?
        var completeFunction: ((Bool) -> Void)?
        var startTime: Double = 0
        var endTime: Double = 0
        
        init(startValues: [T], endValues: [T], duration: Double) {
            self.startValues = startValues
            self.endValues = endValues
            self.duration = duration
        }
        
        @discardableResult func run(_ easingEquation: EasingEquation = .linear, delay: Double = 0) -> Animation<T> {
            equation = easingEquation
            startTime = CACurrentMediaTime() + delay
            endTime = startTime + duration
            Curve.animations.insert(self)
            if !Curve.hasStarted {
                Curve.start()
            }
            return self
        }
        
        @discardableResult func run(delay: Double) -> Animation<T> {
            return run(.linear, delay: delay)
        }
        
        @discardableResult func render(_ equation: EasingEquation = .linear, framerate: Float = Curve.targetFramerate) -> CAKeyframeAnimation {
            let numTicks = Int(ceil(Double(framerate) * duration)) + 1
            let tickAmount = 1.0 / framerate
            var timings = Array<NSNumber>()
            var results = Array<T>()
            for i in 0..<numTicks {
                let timing = tickAmount * Float(i)
                let props = TimingProps(timing, 0, 1, Float(duration))
                let progress = equation.functionForType()(props)
                let result = type(of: startValues[0]).tweenedValue(begin: startValues[0], end: endValues[0], progress: progress)
                print("\(timing): \(result)")
                
                timings.append(NSNumber(value: timing / Float(duration))) // normalize to 0 -> 1
                results.append(result)
            }
            
            let anim = CAKeyframeAnimation()
            anim.keyTimes = timings
            anim.values = results
            anim.duration = duration
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            return anim
        }
        
        @discardableResult func render<T1, T2>(conversion: ((T1) -> T2), equation: EasingEquation = .linear, framerate: Float = Curve.targetFramerate) -> CAKeyframeAnimation? {
            let numTicks = Int(ceil(Double(framerate) * duration)) + 1
            let tickAmount = 1.0 / framerate
            var timings = Array<NSNumber>()
            var results = Array<T2>()
            for i in 0..<numTicks {
                let timing = tickAmount * Float(i)
                let props = TimingProps(timing, 0, 1, Float(duration))
                let progress = equation.functionForType()(props)
                let result = type(of: startValues[0]).tweenedValue(begin: startValues[0], end: endValues[0], progress: progress)
                if !(result is T1) {
                    return nil
                }
                let convertedResult = conversion(result as! T1)
                print("\(timing): \(convertedResult)")
                
                timings.append(NSNumber(value: timing / Float(duration))) // normalize to 0 -> 1
                results.append(convertedResult)
            }
            
            let anim = CAKeyframeAnimation()
            anim.keyTimes = timings
            anim.values = results
            anim.duration = duration
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            return anim
        }
        
        @discardableResult func cancel(forceComplete: Bool = true) -> Animation<T> {
            if !forceComplete {
                // cancel without completing animation
                cancelled = true
                if let completeFunction = completeFunction {
                    completeFunction(false)
                }
                return self
            }
            
            // cancel and force completion of animation
            // NB: "success" bool in .complete() callback will still be false
            endTime = CACurrentMediaTime()
            duration = endTime - startTime
            completionType = .forced
            tick(time: CACurrentMediaTime())
            return self
        }
        
        @discardableResult func change(_ function: @escaping ((T) -> Void)) -> Animation<T> {
            changeFunctionSingle = function
            return self
        }
        
        @discardableResult func change(_ function: @escaping (([T]) -> Void)) -> Animation<T> {
            changeFunctionMany = function
            return self
        }
        
        @discardableResult func completion(_ function: @escaping ((Bool) -> Void)) -> Animation<T> {
            completeFunction = function
            return self
        }
        
        override func tick(time: Double) {
            if cancelled { return }
            var time = time
            if time > endTime {
                time = endTime
            }
            
            let t = time - startTime
            
            if (startValues.count > 1) {
                var results = Array<T>()
                for i in 0..<startValues.count {
                    let props = TimingProps(Float(t), 0, 1, Float(duration))
                    let progress = equation.functionForType()(props)
                    let result = type(of: startValues[0]).tweenedValue(begin: startValues[i], end: endValues[i], progress: progress)
                    results.append(result)
                }
                if let change = changeFunctionMany {
                    change(results)
                }
            } else {
                let props = TimingProps(Float(t), 0, 1, Float(duration))
                let progress = equation.functionForType()(props)
                let result = type(of: startValues[0]).tweenedValue(begin: startValues[0], end: endValues[0], progress: progress)
                if let change = changeFunctionSingle {
                    change(result)
                }
            }
            
            
            if time >= endTime {
                completed = true
                if let complete = completeFunction {
                    complete(completionType == .natural)
                }
            }
        }
    }
    
    public static var targetFramerate: Float = 60.0
    static var animations: Set<AbstractAnimation> = Set<AbstractAnimation>()
    static var hasStarted: Bool = false
    static var displayLink: CADisplayLink? = nil
    
    @discardableResult public static func from<T: Tweenable>(_ startValue: T, to endValue: T, in duration: Double) -> Animation<T> {
        return Animation<T>(startValues: [startValue], endValues: [endValue], duration: duration)
    }
    
    @discardableResult public static func from<T: Tweenable>(_ startValues: [T], to endValues: [T], in duration: Double) -> Animation<T> {
        return Animation<T>(startValues: startValues, endValues: endValues, duration: duration)
    }
    
    private static func start() {
        if hasStarted {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
        
        hasStarted = true
    }
    
    @objc private static func tick(displayLink: CADisplayLink) {
        let time = CACurrentMediaTime()
        var completedAnimations = Set<AbstractAnimation>()
        for animation in animations {
            animation.tick(time: time)
            if animation.completed == true {
                completedAnimations.insert(animation)
            }
        }
        
        for animation in completedAnimations {
            animations.remove(animation)
        }
    }
}
