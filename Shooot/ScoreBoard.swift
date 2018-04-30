//
//  ScoreBoard.swift
//  Shooot
//
//  Created by Tyler Yang on 30/4/18.
//  Copyright © 2018 cincas. All rights reserved.
//

import SpriteKit

class ScoreBoard: SKSpriteNode {
  private var currentScore: Double = 0.0
  private var scoreLabel: SKLabelNode?
  
  func prepare() {
    let scoreLabel = SKLabelNode(text: "Score: \(currentScore)")
    addChild(scoreLabel)
    self.scoreLabel = scoreLabel
    
    color = UIColor.blue
  }
  
  func updateScore(to score: Double) {
    scoreLabel?.text = "Score: \(score)"
    currentScore = score
  }
}
