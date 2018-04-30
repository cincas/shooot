//
//  GameScene.swift
//  Shooot
//
//  Created by Tyler Yang on 29/4/18.
//  Copyright © 2018 cincas. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  var gunNode: GunNode?
  var fireButton: FireButton?
  var totalScore: Double = 0.0
  var scoreLabel: SKLabelNode?
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    scaleMode = .aspectFill
    
    if let gunNode = childNode(withName: "Gun") as? GunNode {
      self.gunNode = gunNode
      gunNode.color = UIColor.green
    }
    
    if let fireButton = childNode(withName: "FireButton") as? FireButton {
      self.fireButton = fireButton
      fireButton.onClick = { [weak self] (sender: FireButton) in self?.fire() }
    }
    
    prepareTargets()
    prepareBoard()
  }
  
  func prepareBoard() {
    let board = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 100))
    addChild(board)
    var position = fireButton?.position ?? CGPoint.zero
    
    position.y += 150.0
    position.x -= 50
    board.position = position
    
    let scoreLabel = SKLabelNode(text: "Score: \(totalScore)")
    board.addChild(scoreLabel)
    self.scoreLabel = scoreLabel
  }
  
  func gained(score: Double) {
    totalScore += score
    scoreLabel?.text = "Score: \(totalScore)"
  }
  
  func prepareTargets() {
    let originPoint = CGPoint(x: -frame.width/2, y: frame.height/2)
    var lastPoint = originPoint
    let numberOfTargets = 10
    let targets: [TargetNode] = (0..<numberOfTargets).map { index in
      let point = CGPoint(x: lastPoint.x, y: lastPoint.y - 40)
      let target = TargetNode.makeTarget(position: point)
      addChild(target)
      target.zPosition = 1
      target.score = Double(numberOfTargets - index).rounded()
      lastPoint = point
      return target
    }
    
    targets.forEach { $0.startMoving() }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let previousPosition = touch.previousLocation(in: self)
    let position = touch.location(in: self)
    moveGun(toPosition: position, previousPosition: previousPosition)
  }
  
  func moveGun(toPosition position: CGPoint, previousPosition: CGPoint) {
    guard let gunNode = gunNode else { return }
    guard abs(position.x - previousPosition.x) > 5 else { return }

    let newX = gunNode.position.x + (position.x - previousPosition.x)
    gunNode.position.x = xBoundrayOf(newX)
  }
}

extension GameScene {
  func xBoundrayOf(_ x: CGFloat) -> CGFloat {
    let minX = frame.minX
    let maxX = frame.maxX
    
    guard let gunNode = self.gunNode else { return 0 }
    let halfWidth = gunNode.size.width / 2
    let allowedMinX = minX + halfWidth
    let allowedMaxX = maxX - halfWidth
    
    switch x {
    case ..<allowedMinX:
      return allowedMinX
    case allowedMaxX...CGFloat.infinity:
      return allowedMaxX
    default:
      return x
    }
  }
}

extension GameScene {
  func fire() {
    gunNode?.fire(inScene: self)
  }
}

extension GameScene {
  func didBegin(_ contact: SKPhysicsContact) {
    let targetNode = [contact.bodyA.node, contact.bodyB.node].first { $0 is TargetNode } as? TargetNode
    targetNode?.hitted()
    if let score = targetNode?.score {
      gained(score: score)
    }
    let bulletNode = [contact.bodyA.node, contact.bodyB.node].first { $0 is Bullet } as? Bullet
    bulletNode?.hitted()
  }
}
