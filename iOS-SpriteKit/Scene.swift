//
//  Scene.swift
//  iOS-SpriteKit
//
//  Created by Flavio Leite on 17/07/2019.
//  Copyright © 2019 Flavio Leite. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    var mosca = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        let texturaMosca1 = SKTexture(imageNamed: "fly1.png")
        let texturaMosca2 = SKTexture(imageNamed: "fly2.png")
        
        let animacion = SKAction.animate(with: [texturaMosca1, texturaMosca2], timePerFrame: 0.1)
        let animacionInfinita = SKAction.repeatForever(animacion)
        
        mosca = SKSpriteNode(texture: texturaMosca1)
        mosca.position = CGPoint(x: 0.0, y: 0.0)
        mosca.run(animacionInfinita)
        self.addChild(mosca)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
