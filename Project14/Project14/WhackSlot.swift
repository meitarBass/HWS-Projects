import SpriteKit
import UIKit

class WhackSlot: SKNode {
    
    var isVisible = false
    var isHit = false
    
    var charNode: SKSpriteNode!
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        if charNode.name == "charEnemy" {
            if let mud = SKEmitterNode(fileNamed: "MudEmitter") {
                mud.position = CGPoint(x: 0, y: 0)
                mud.zPosition = 1
                mud.numParticlesToEmit = 50
                mud.particleLifetime = 0.2
                mud.particleColor = SKColor.brown

                effectSequence(effect: mud)
            }
        }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
        
        if let smoke = SKEmitterNode(fileNamed: "SmokeEmitter") {
            smoke.position = CGPoint(x: 0, y: -20)
            smoke.zPosition = 1
            smoke.numParticlesToEmit = 30
            smoke.particleLifetime = 0.3
            smoke.particleColor = SKColor.white
            
            effectSequence(effect: smoke)
            
        }
        
        charNode.run(SKAction.sequence([delay, hide, notVisible]))
    }
    
    func effectSequence(effect: SKEmitterNode) {
        let action = SKAction.run { [weak self] in
            self?.addChild(effect)
        }
        
        let duration = SKAction.wait(forDuration: 1.5)
        let removal = SKAction.run { [weak self] in
            self?.removeChildren(in: [effect])
        }
        
        run(SKAction.sequence([action, duration, removal]))
    }
}
