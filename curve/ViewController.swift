//
//  ViewController.swift
//  curve
//
//  Created by Dom Hofmann on 1/25/18.
//  Copyright © 2018 Dom Hofmann. All rights reserved.
//

import UIKit

protocol Tweenable {
    static func tweenedValue(begin: Self, end: Self, progress: Float) -> Self
}

extension Float: Tweenable {
    typealias ValueType = Float
    static func tweenedValue(begin: Float, end: Float, progress: Float) -> Float {
        return begin + (end - begin) * progress
    }
}

extension CGFloat: Tweenable {
    static func tweenedValue(begin: CGFloat, end: CGFloat, progress: Float) -> CGFloat {
        return begin + (end - begin) * CGFloat(progress)
    }
}

extension Double: Tweenable {
    static func tweenedValue(begin: Double, end: Double, progress: Float) -> Double {
        return begin + (end - begin) * Double(progress)
    }
}

extension CGPoint: Tweenable {
    static func tweenedValue(begin: CGPoint, end: CGPoint, progress: Float) -> CGPoint {
        let diff = CGPoint(x: end.x - begin.x, y: end.y - begin.y)
        return CGPoint(x: begin.x + diff.x * CGFloat(progress), y: begin.y + diff.y * CGFloat(progress))
    }
}

extension CGSize: Tweenable {
    static func tweenedValue(begin: CGSize, end: CGSize, progress: Float) -> CGSize {
        let diff = CGSize(width: end.width - begin.width, height: end.height - begin.height)
        return CGSize(width: begin.width + diff.width * CGFloat(progress), height: begin.height + diff.height * CGFloat(progress))
    }
}

extension CGRect: Tweenable {
    static func tweenedValue(begin: CGRect, end: CGRect, progress: Float) -> CGRect {
        let origin = CGPoint.tweenedValue(begin: begin.origin, end: end.origin, progress: progress)
        let size = CGSize.tweenedValue(begin: begin.size, end: end.size, progress: progress)
        return CGRect(origin: origin, size: size)
    }
}

extension UIView {
    func animateFrame(to endValue: CGRect, in duration: Double) -> Curve.Animation<CGRect> {
        return Curve.from(self.frame, to: endValue, in: duration).change({ (value: CGRect) in
            self.frame = value
        })
    }
}

class Curve {
    typealias TimingFunction = (TimingProps) -> (Float)
    
    struct TimingProps {
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
    
    enum EasingEquation {
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
    
    class AbstractAnimation: Hashable {
        var completed: Bool = false
        
        // MARK: - Hashable
        
        static func ==(lhs: AbstractAnimation, rhs: AbstractAnimation) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
        
        var hashValue: Int {
            return ObjectIdentifier(self).hashValue
        }
        
        func tick(time: Double) {
            
        }
    }
    
    class Animation<T: Tweenable>: AbstractAnimation {
        var startValues: [T]
        var endValues: [T]
        var duration: Double
        var equation: EasingEquation = .linear
        var changeFunctionSingle: ((T) -> Void)?
        var changeFunctionMany: (([T]) -> Void)?
        var completeFunction: ((Bool) -> Void)?
        var startTime: Double = 0
        var endTime: Double = 0
        
        init(startValue: T, endValue: T, duration: Double) {
            self.startValues = [startValue]
            self.endValues = [endValue]
            self.duration = duration
        }
        
        init(startValues: [T], endValues: [T], duration: Double) {
            self.startValues = startValues
            self.endValues = endValues
            self.duration = duration
        }
        
        @discardableResult func animate(_ equation: EasingEquation = .linear) -> Animation<T> {
            self.equation = equation
            self.startTime = CACurrentMediaTime()
            self.endTime = self.startTime + duration
            Curve.animations.insert(self)
            if !Curve.hasStarted {
                Curve.start()
            }
            return self
        }
        
        @discardableResult func change(_ changeFunction: @escaping ((T) -> Void)) -> Animation<T> {
            self.changeFunctionSingle = changeFunction
            return self
        }
        
        @discardableResult func change(_ changeFunction: @escaping (([T]) -> Void)) -> Animation<T> {
            self.changeFunctionMany = changeFunction
            return self
        }
        
        @discardableResult func completion(_ completeFunction: @escaping ((Bool) -> Void)) -> Animation<T> {
            self.completeFunction = completeFunction
            return self
        }
        
        override func tick(time: Double) {
            var time = time
            if time > self.endTime {
                time = self.endTime
            }
            
            let t = time - self.startTime
            
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

            
            if time >= self.endTime {
                completed = true
                if let complete = completeFunction {
                    complete(completed)
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
        
        print("Starting")
        
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

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let square = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        square.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        square.backgroundColor = UIColor.red
        view.addSubview(square)
        
        Curve.from(square.center.y, to: square.center.y + 100, in: 2).animate(.linear)
            .change { (value: CGFloat) in
                square.center.y = value
            }
            .completion { (completed: Bool) in
                print(completed)
            }
        
//        Curve.from(square.center, to: CGPoint(x: square.center.x + 100, y: square.center.y + 100), in: 2).animate(.backOut(overshoot: 5))
//        .change { (value: CGPoint) in
//            square.center = value
//        }
//        .completion { (completed: Bool) in
//            print(completed)
//        }
        
        square.animateFrame(to: square.frame.offsetBy(dx: 100, dy: 100), in: 2).animate(.backOut(overshoot: 5))
    }
}

