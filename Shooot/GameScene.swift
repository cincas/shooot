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
  var scoreBoard: ScoreBoard?
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    scaleMode = .aspectFit
    backgroundColor = .gray
    if let gunNode = childNode(withName: "Gun") as? GunNode {
      self.gunNode = gunNode
      gunNode.color = .clear
      gunNode.prepare()
    }
    
    if let fireButton = childNode(withName: "FireButton") as? FireButton {
      self.fireButton = fireButton
      fireButton.onClick = { [weak self] (sender: FireButton) in self?.fire() }
    }
    
    if let scoreBoard = childNode(withName: "ScoreBoard") as? ScoreBoard {
      self.scoreBoard = scoreBoard
      scoreBoard.prepare()
    }
    
    prepareTargets()
  }

  func gained(score: Double) {
    totalScore += score
    scoreBoard?.updateScore(to: totalScore)
  }
  
  func prepareTargets() {
    let originPoint = CGPoint(x: 0, y: frame.height)
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
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    gunNode?.stopMoving()
  }
  
  func moveGun(toPosition position: CGPoint, previousPosition: CGPoint) {
    guard let gunNode = gunNode else { return }
    guard abs(position.x - previousPosition.x) > 5 else { return }

    let newX = gunNode.position.x + (position.x - previousPosition.x) * 1.1
    gunNode.position.x = xBoundrayOf(newX)
    switch position.x > previousPosition.x {
    case true:
      gunNode.movingRight()
    case false:
      gunNode.movingLeft()
    }
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
