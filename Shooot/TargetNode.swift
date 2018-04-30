//
//  TargetNode.swift
//  Shooot
//
//  Created by Tyler Yang on 29/4/18.
//  Copyright © 2018 cincas. All rights reserved.
//

import SpriteKit

class TargetNode: SKSpriteNode {
  var score: Double = 1.0
  static func makeTarget(position: CGPoint,
                         score: Double = 1.0,
                         name: String? = nil,
                         color: UIColor = .random(),
                         size: CGSize = CGSize(width: 100, height: 20)) -> TargetNode {
    let node = TargetNode(color: color, size: size)
    node.name = name
    node.position = position
    node.score = score
    
    let body = SKPhysicsBody(rectangleOf: node.size)
    body.isDynamic = true
    body.categoryBitMask = BitMaskType.target.rawValue;
    body.contactTestBitMask = BitMaskType.bullet.rawValue
    body.collisionBitMask = 0
    node.physicsBody = body
    return node
  }
  
  func startMoving() {
    guard let scene = scene else { return }
    let duration = TimeInterval(CGFloat.random().truncatingRemainder(dividingBy: 3.0)) + 0.5
    let moving = SKAction.moveTo(x: scene.frame.minX, duration: duration)
    let reverse = SKAction.moveTo(x: scene.frame.maxX, duration: duration)
    let all = SKAction.sequence([moving, reverse])
    run(SKAction.repeatForever(all))
  }
  
  func hitted() {

    color = .random()
  }
}

extension CGFloat {
  static func random() -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UInt32.max)
  }
}

extension UIColor {
  static func random() -> UIColor {
    return UIColor(red:   .random(),
                   green: .random(),
                   blue:  .random(),
                   alpha: 1.0)
  }
}
