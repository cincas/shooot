//
//  GunNode.swift
//  Shooot
//
//  Created by Tyler Yang on 29/4/18.
//  Copyright © 2018 cincas. All rights reserved.
//

import SpriteKit

enum BitMaskType: UInt32 {
  case bullet = 1
  case target = 2
}

enum MovingDirection {
  case left, still, right
}

private extension MovingDirection {
  var textureForPlane: SKTexture {
    switch self {
    case .left:
      return SKTexture(image: #imageLiteral(resourceName: "PLANE 8 L"))
    case .right:
      return SKTexture(image: #imageLiteral(resourceName: "PLANE 8 R"))
    case .still:
      return SKTexture(image: #imageLiteral(resourceName: "PLANE 8 N"))
    }
  }
}

class GunNode: SKSpriteNode {
  var numberOfShootedBullets = 0
  private var plane: SKSpriteNode?
  private var movingDirection: MovingDirection = .still {
    didSet {
      updateTexture()
    }
  }
  
  func prepare() {
    let shadow = SKSpriteNode(imageNamed: "PLANE 8 SHADOW")
    shadow.setScale(0.6)
    shadow.zPosition = 1
    addChild(shadow)
    
    let plane = SKSpriteNode(imageNamed: "PLANE 8 N")
    plane.zPosition = 2
    addChild(plane)
    
    shadow.position = CGPoint(x: plane.position.x + 30, y: plane.position.y - 30)
    self.plane = plane
  }
  
  func movingLeft() {
    movingDirection = .left
  }
  
  func movingRight() {
    movingDirection = .right
  }
  
  func stopMoving() {
    movingDirection = .still
  }
  
  func updateTexture() {
    plane?.texture = movingDirection.textureForPlane
  }
  
  func fire(inScene scene: SKScene) {
    let bullet = Bullet(color: .blue, size: CGSize(width: 20, height: 40))
    bullet.position = position
    bullet.name = "Bullet-\(numberOfShootedBullets)"
    let distance: CGFloat = scene.frame.height
    let moving = SKAction.move(to: CGPoint(x: position.x, y: position.y + distance), duration: 0.5)
    let removing = SKAction.removeFromParent()
    bullet.physicsBody = bullet.makePhysicsBody()
    scene.addChild(bullet)
    bullet.zPosition = 1
    bullet.run(SKAction.sequence([moving, removing])) 
  }
}

class Bullet: SKSpriteNode {
  func makePhysicsBody() -> SKPhysicsBody {
    let body = SKPhysicsBody(rectangleOf: frame.size)
    body.isDynamic = true
    body.categoryBitMask = BitMaskType.bullet.rawValue
    body.contactTestBitMask = BitMaskType.target.rawValue
    body.collisionBitMask = 0
    return body
  }
  
  func hitted() {
    removeAllActions()
    removeFromParent()
  }
}
