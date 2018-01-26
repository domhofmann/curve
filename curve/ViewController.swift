//
//  ViewController.swift
//  curve
//
//  Created by Dom Hofmann on 1/25/18.
//  Copyright © 2018 Dom Hofmann. All rights reserved.
//

import UIKit

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
    
    class Animation: Hashable {
        var startValues: [Float]
        var endValues: [Float]
        var duration: Double
        var equation: EasingEquation = .linear
        var changeFunctionSingle: ((Float) -> Void)?
        var changeFunctionMany: (([Float]) -> Void)?
        var completeFunction: ((Bool) -> Void)?
        var startTime: Double = 0
        var endTime: Double = 0
        var completed: Bool = false
        
        init(startValue: Float, endValue: Float, duration: Double) {
            self.startValues = [startValue]
            self.endValues = [endValue]
            self.duration = duration
        }
        
        init(startValues: [Float], endValues: [Float], duration: Double) {
            self.startValues = startValues
            self.endValues = endValues
            self.duration = duration
        }
        
        @discardableResult func animate(_ equation: EasingEquation = .linear) -> Animation {
            self.equation = equation
            self.startTime = CACurrentMediaTime()
            self.endTime = self.startTime + duration
            Curve.animations.insert(self)
            if !Curve.hasStarted {
                Curve.start()
            }
            return self
        }
        
        @discardableResult func change(_ changeFunction: @escaping ((Float) -> Void)) -> Animation {
            self.changeFunctionSingle = changeFunction
            return self
        }
        
        @discardableResult func change(_ changeFunction: @escaping (([Float]) -> Void)) -> Animation {
            self.changeFunctionMany = changeFunction
            return self
        }
        
        @discardableResult func completion(_ completeFunction: @escaping ((Bool) -> Void)) -> Animation {
            self.completeFunction = completeFunction
            return self
        }
        
        func tick(time: Double) {
            var time = time
            if time > self.endTime {
                time = self.endTime
            }
            
            let t = time - self.startTime
            
            if (startValues.count > 1) {
                var results = Array<Float>()
                for i in 0..<startValues.count {
                    let c = endValues[i] - startValues[i]
                    print(t, startValues, c, duration)
                    let props = TimingProps(Float(t), startValues[i], c, Float(duration))
                    let result = equation.functionForType()(props)
                    results.append(result)
                }
                if let change = changeFunctionMany {
                    change(results)
                }
            } else {
                let c = endValues[0] - startValues[0]
                print(t, startValues, c, duration)
                let props = TimingProps(Float(t), startValues[0], c, Float(duration))
                let result = equation.functionForType()(props)
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
        
        // MARK: - Hashable
        
        static func ==(lhs: Animation, rhs: Animation) -> Bool {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
        
        var hashValue: Int {
            return ObjectIdentifier(self).hashValue
        }
    }
    
    public static var targetFramerate: Float = 60.0
    static var animations: Set<Animation> = Set<Animation>()
    static var hasStarted: Bool = false
    static var displayLink: CADisplayLink? = nil
    
    @discardableResult public static func from(_ startValue: Float, to endValue: Float, in duration: Double = 0.35) -> Animation {
        return Animation(startValues: [startValue], endValues: [endValue], duration: duration)
    }
    
    @discardableResult public static func from(_ startValue: Double, to endValue: Double, in duration: Double = 0.35) -> Animation {
        return from(Float(startValue), to: Float(endValue), in: duration)
    }
    
    @discardableResult public static func from(_ startValue: CGFloat, to endValue: CGFloat, in duration: Double = 0.35) -> Animation {
        return from(Float(startValue), to: Float(endValue), in: duration)
    }
    
    @discardableResult public static func fromMany(_ startValues: [Float], to endValues: [Float], in duration: Double = 0.35) -> Animation {
        return Animation(startValues: startValues, endValues: endValues, duration: duration)
    }
    
    @discardableResult public static func fromMany(_ startValues: [Double], to endValues: [Double], in duration: Double = 0.35) -> Animation {
        return fromMany(startValues.map { Float($0) }, to: endValues.map { Float($0) }, in: duration)
    }
    
    @discardableResult public static func fromMany(_ startValues: [CGFloat], to endValues: [CGFloat], in duration: Double = 0.35) -> Animation {
        return fromMany(startValues.map { Float($0) }, to: endValues.map { Float($0) }, in: duration)
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
        var completedAnimations = Set<Animation>()
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
        
        Curve.from(square.center.y, to: square.center.y + 100, in: 2).animate(.backOut(overshoot: 5))
            .change { (value: Float) in
                square.center.y = CGFloat(value)
            }
            .completion { (completed: Bool) in
                print(completed)
            }
        
    }
}

