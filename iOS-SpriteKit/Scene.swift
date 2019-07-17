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
    var fondo = SKSpriteNode()
    var texturaMosca1 = SKTexture()

    
    override func didMove(to view: SKView) {

        //MARK: Fondo
        let texturaFondo = SKTexture(imageNamed: "fondo.png")
        let movimientoFondo = SKAction.move(by: CGVector(dx: -texturaFondo.size().width, dy: 0), duration: 4.0)
        let movimientoFondoOrigen = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)

        let movimientoInfinitoFondo = SKAction.repeatForever(
            SKAction.sequence([movimientoFondo, movimientoFondoOrigen])
        )
        
        var i:CGFloat = 0 // Tipo Float para poder multiplicar por el width de la textura
        while i < 2 { // bucle creado para que se implemente una segunda imagen junto al final de la primera
            fondo = SKSpriteNode(texture: texturaFondo)
            fondo.position = CGPoint(x: texturaFondo.size().width * i, y: self.frame.midY)
            fondo.size.height = self.frame.height
            fondo.zPosition = -1 // -1 para garantizar que siempre estará por detrás
            fondo.run(movimientoInfinitoFondo)
            self.addChild(fondo)
            i += 1
        }
        
        
        //MARK: Mosca
        texturaMosca1 = SKTexture(imageNamed: "fly1.png")
        let texturaMosca2 = SKTexture(imageNamed: "fly2.png")
        let animacion = SKAction.animate(with: [texturaMosca1, texturaMosca2], timePerFrame: 0.1)
        let animacionInfinita = SKAction.repeatForever(animacion)
        mosca = SKSpriteNode(texture: texturaMosca1)
        mosca.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mosca.run(animacionInfinita)
        self.addChild(mosca)
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Crear el cuerpo físico de la mosca como un círculo con un radio de mitad del height de la textura
        mosca.physicsBody = SKPhysicsBody(circleOfRadius: texturaMosca1.size().height/2)
        
        // Certificarse de que el cuerpo sea dinámico, que se mueva y interactue
        mosca.physicsBody?.isDynamic = true
        
        // Fijar la velocidad de movimento/caída
        mosca.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // aplicar un impulso cada vez que se pulse en la pantalla
        mosca.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
        

    }
}
