//
//  ViewController.swift
//  curve
//
//  Created by Dom Hofmann on 1/25/18.
//  Copyright © 2018 Dom Hofmann. All rights reserved.
//

import UIKit


class ViewController: UIViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let square = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        square.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        square.backgroundColor = UIColor.red
        view.addSubview(square)
        
//        square.animateBackgroundColor(to: UIColor.blue, in: 2).render()
        
        square.animateBackgroundColor(to: UIColor.blue, in: 2).render(conversion: { (value: UIColorWrapper) -> CGColor in
            return value.unwrap().cgColor
        })?.to(layer: square.layer, keyPath: "backgroundColor")
        
        Curve.from(square.center, to: CGPoint(x: square.center.x + 100, y: square.center.y + 100), in: 2)
            .render(.backOut(overshoot: 40))
            .to(layer: square.layer, keyPath: "position")
    
        
//        {
//            square.layer.add(caAnim, forKey: "backgroundColor")
//        }
        

        
//        Curve.from(square.center.y, to: square.center.y + 100, in: 2).run(.linear)
//            .change {
//                square.center.y = $0
//            }
//            .completion {
//                print($0)
//            }
        
//        let anim = square.animateFrame(to: square.frame.offsetBy(dx: 100, dy: 100), in: 10).run(.backOut(overshoot: 5), delay: 0.5)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            anim.cancel()
//        }
    }
}

