//
//  FireButton.swift
//  Shooot
//
//  Created by Tyler Yang on 29/4/18.
//  Copyright © 2018 cincas. All rights reserved.
//

import SpriteKit

typealias FireButtonOnClick = (FireButton) -> Void

class FireButton: SKSpriteNode {
  var onClick: FireButtonOnClick?
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
    prepareChildNodes()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    prepareChildNodes()
  }
  
  private var backgroundNode: SKShapeNode?
  private var titleNode: SKLabelNode?
  
  func prepareChildNodes() {
    let width: CGFloat = 120.0
    let titleNode = SKLabelNode(text: "Fire")
    titleNode.fontSize = 32
    titleNode.fontName = "Helvetica Neue"
    titleNode.zPosition = 2
    
    let backgroundNode = SKShapeNode(circleOfRadius: width / 2)
    backgroundNode.strokeColor = .blue
    backgroundNode.lineWidth = 2.0
    backgroundNode.zPosition = 1
    addChild(titleNode)
    addChild(backgroundNode)
    backgroundNode.position = CGPoint(x: 0, y: 0)
    
    titleNode.verticalAlignmentMode = .center
    titleNode.position = CGPoint(x: 0,
                                 y: 0)
    
    self.size = CGSize(width: width, height: width)
    isUserInteractionEnabled = true
    self.backgroundNode = backgroundNode
    self.titleNode = titleNode
    color = .clear
    isFiring = false
  }
  
  private var isFiring = false {
    didSet {
      backgroundNode?.fillColor = isFiring ? .red : .green
      titleNode?.fontColor = isFiring ? .white : .black
    }
  }
  
  private var firingTimer: Timer?
  private var fireRate: TimeInterval = 0.2
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    isFiring = true
    firingTimer?.invalidate()
    
    let timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true) { [onClick, weak self](_) in
      guard let sself = self else { return; }
      onClick?(sself)
    }
    timer.fire()
    firingTimer = timer
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isFiring = false
    firingTimer?.invalidate()
    (scene as? GameScene)?.touchesEnded(touches, with: event)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let previousPosition = touch.previousLocation(in: self)
    let position = touch.location(in: self)
    
    (scene as? GameScene)?.moveGun(toPosition: position, previousPosition: previousPosition)
  }
}
