import CoreMotion
import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    var levelLabel: SKLabelNode!
    var level = 1 {
        didSet {
            levelLabel.text = "Level \(level)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        background.name = "background"
        addChild(background)
        
        loadLevel(level)
        createPlayer()
        physicsWorld.gravity = .zero
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        scoreLabel.name = "scoreLabel"
        addChild(scoreLabel)
        
        
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.fontSize = 48
        levelLabel.text = "Level 1"
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: 512, y: 405)
        levelLabel.zPosition = 2
        levelLabel.name = "levelLabel"
        addChild(levelLabel)
        animateLevelLabel()
        
        physicsWorld.contactDelegate = self
    }
    
    
    func loadLevel(_ level: Int) {
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle.")
        }
        
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if letter == "x" {
                    // load wall
                    createWall(in: position)
                } else if letter == "v" {
                    // load vortex
                    createVortex(in: position)
                } else if letter == "s" {
                    // load star
                    createStar(in: position)
                } else if letter == "f" {
                    // load finish
                    createFinish(in: position)
                } else if letter == " " {
                    // this is an empty space - do nothing
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    func cleanLevel() {
        for node in self.children {
            if node.name != "background" && node.name != "scoreLabel" && node.name != "levelLabel" {
                node.removeFromParent()
            }
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.8
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level?
            cleanLevel()
            if level == 3 {
                isGameOver = true
                levelLabel.text = "YOU WON!"
                levelLabel.name = "won"
                animateLevelLabel()
                return
            }
            level += 1
            loadLevel(level)
            createPlayer()
            animateLevelLabel()
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    func createWall(in position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func createVortex(in position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    func createStar(in position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createFinish(in position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func animateLevelLabel() {
        isUserInteractionEnabled = false
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
        var sequence: SKAction!
        
        if levelLabel.name == "won" {
            sequence = SKAction.sequence([fadeIn, wait])
        } else {
            sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        }
        
        levelLabel.run(sequence) {
            self.isUserInteractionEnabled = true
        }
    }
}
