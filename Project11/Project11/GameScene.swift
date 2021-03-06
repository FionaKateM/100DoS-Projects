//
//  GameScene.swift
//  Project11
//
//  Created by Fiona Kate Morgan on 27/03/2019.
//  Copyright © 2019 Fiona Kate Morgan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var inEditingMode = false {
        didSet {
            if inEditingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var ballCountLabel: SKLabelNode!
    var ballCount = 5 {
        didSet {
            if ballCount == -1 {
                ballCountLabel.text = "Restart"
            } else {
                ballCountLabel.text = "Balls: \(ballCount)"
            }
        }
    }
    
    let balls = ["Green", "Red", "Blue", "Cyan", "Grey", "Purple", "Yellow"]

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 908, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text = "Balls: \(ballCount)"
        ballCountLabel.position = CGPoint(x: 414, y: 700)
        addChild(ballCountLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y:0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y:0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y:0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y:0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            inEditingMode.toggle()
        } else if objects.contains(ballCountLabel) && ballCountLabel.text == "Restart"{
            ballCount = 5
            score = 0
        } else {
            if inEditingMode {
                let size =  CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor.init(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
            } else if location.y > 500 && ballCount > 0 {
                ballCount -= 1
                let ball = SKSpriteNode(imageNamed: "ball\(balls[Int.random(in: 0..<balls.count)])")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = location
                ball.name = "ball"
                addChild(ball)
            } else if ballCount == 0 {
                ballCount -= 1
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotGlow)
        addChild(slotBase)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(node: ball)
            ballCount += 1
            score += 1
        } else if object.name == "bad" {
            score -= 1
            destroy(node: ball)
        } else if object.name == "box" {
            destroy(node: object)
        }
    }
    
    func destroy(node: SKNode) {
        if node.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = node.position
                addChild(fireParticles)
            }
        }
        node.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
    
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
}
