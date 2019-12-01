//
//  ViewController.swift
//  Demo
//
//  Created by 乐哥 on 2019/11/27.
//  Copyright © 2019 乐Coding. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var confettiTypes: [ConfettiType] = {
        let confettiColors = [
            (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
            (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
            (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
            ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }

        // For each position x shape x color, construct an image
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    lazy var confettiLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()

        emitterLayer.emitterCells = confettiCells
//        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 500)
//        emitterLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 500)
//        emitterLayer.emitterShape = .rectangle
        //5.0
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitterLayer.emitterSize = CGSize(width: 100, height: 100)
        emitterLayer.emitterShape = .sphere
        emitterLayer.frame = view.bounds
        //6.p
        emitterLayer.birthRate = 0
       

        emitterLayer.beginTime = CACurrentMediaTime()
        return emitterLayer
    }()

    lazy var confettiCells: [CAEmitterCell] = {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()

            cell.beginTime = 0.1
            cell.birthRate = 10
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
//            cell.velocityRange = 100
//            cell.yAcceleration = 150
            //5.
            cell.velocityRange = 0
            cell.yAcceleration = 0
            //6.
            cell.birthRate = 100
            
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")

            return cell
        }
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layer.addSublayer(confettiLayer)
        addBehaviors()
        addAnimations() // new!
    }
    // 4.
    func addBehaviors() {
//        confettiLayer.setValue([
//            horizontalWaveBehavior(),
//            verticalWaveBehavior()
//        ], forKey: "emitterBehaviors")
        //5.0
        confettiLayer.setValue([
            horizontalWaveBehavior(),
            verticalWaveBehavior(),
            attractorBehavior(for: confettiLayer) // new!
        ], forKey: "emitterBehaviors")
    }
    
    func horizontalWaveBehavior() -> CAEmitterBehavior {
        let behavior = CAEmitterBehavior(type: kCAEmitterBehaviorWave)
        behavior?.setValue([100, 0, 0], forKeyPath: "force")
        behavior?.setValue(0.5, forKeyPath: "frequency")
        return behavior!
    }

    func verticalWaveBehavior() -> CAEmitterBehavior {
        let behavior = CAEmitterBehavior(type: kCAEmitterBehaviorWave)
        behavior?.setValue([0, 500, 0], forKeyPath: "force")
        behavior?.setValue(3, forKeyPath: "frequency")
        return behavior!
    }
    //5.
    func attractorBehavior(for emitterLayer: CAEmitterLayer) -> CAEmitterBehavior {
        let behavior = CAEmitterBehavior(type: kCAEmitterBehaviorAttractor)
        
        behavior?.setValue("attractor", forKeyPath: "name")
        // Attractiveness
        behavior?.setValue(-290, forKeyPath: "falloff")
        behavior?.setValue(300, forKeyPath: "radius")
        behavior?.setValue(10, forKeyPath: "stiffness")

        // Position
        behavior?.setValue(CGPoint(x: emitterLayer.emitterPosition.x,
                                  y: emitterLayer.emitterPosition.y + 20),
                          forKeyPath: "position")
        behavior?.setValue(-70, forKeyPath: "zPosition")
        
        

        return behavior!
    }
    //6.0
    func addAttractorAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 3
        animation.keyTimes = [0, 0.4]
        animation.values = [80, 5]

        layer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
    }
    
    func addBirthrateAnimation(to layer: CALayer) {
        let animation = CABasicAnimation()
        animation.duration = 1
        animation.fromValue = 1
        animation.toValue = 0

        layer.add(animation, forKey: "birthRate")
    }
    func addAnimations() {
        addAttractorAnimation(to: confettiLayer)
        addBirthrateAnimation(to: confettiLayer)
    }
}
