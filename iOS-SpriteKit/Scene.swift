//
//  Scene.swift
//  iOS-SpriteKit
//
//  Created by Flavio Leite on 17/07/2019.
//  Copyright © 2019 Flavio Leite. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene, SKPhysicsContactDelegate {
    
    var mosca = SKSpriteNode()
    var fondo = SKSpriteNode()
    var tubo1 = SKSpriteNode()
    var tubo2 = SKSpriteNode()
    var texturaMosca1 = SKTexture()
    var labelPuntuacion = SKLabelNode()
    var puntuacion = 0
    var timer = Timer()
    var gameOver = false
    
    enum tipoNodo: UInt32 {
        case mosca = 1
        case tuboSuelo = 2
        case espacioTubo = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        reiniciarJuego()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(gameOver==false) {
            mosca.physicsBody?.isDynamic = true
            mosca.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            mosca.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 35))
        } else {
            let touch = touches.first
            let positionInScene = touch!.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
            if let name = touchedNode.name {
                if name == "btnRestart" {
                    gameOver = false
                    puntuacion = 0
                    self.speed = 1
                    self.removeAllChildren()
                    reiniciarJuego()
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // identificar cuando se genera un contacto
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        if (cuerpoA.categoryBitMask == tipoNodo.mosca.rawValue && cuerpoB.categoryBitMask == tipoNodo.espacioTubo.rawValue)
        || (cuerpoA.categoryBitMask == tipoNodo.espacioTubo.rawValue && cuerpoB.categoryBitMask == tipoNodo.mosca.rawValue){
            puntuacion += 1
            labelPuntuacion.text = String(puntuacion)
        } else {
            let botonRestart = SKSpriteNode(imageNamed: "restart.png")
            botonRestart.name = "btnRestart"
            botonRestart.size.height = 100
            botonRestart.size.width = 100
            botonRestart.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
            botonRestart.zPosition = 3
            self.addChild(botonRestart)
            gameOver = true
            self.speed = 0
            timer.invalidate()
            labelPuntuacion.fontSize = 30
            labelPuntuacion.text = "Game Over - "+String(puntuacion)+" puntos"
        }
    }
    
    //MARK: Nodos
    func anadirSuelo() {
        let suelo = SKNode()
        suelo.position = CGPoint(x: -self.frame.midX, y: -self.frame.height/2)
        // con el ancho de la pantalla y solo 1px de alto, solo para hacer un límite
        suelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        suelo.physicsBody?.isDynamic = false
        suelo.physicsBody?.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        suelo.physicsBody?.collisionBitMask = tipoNodo.mosca.rawValue
        suelo.physicsBody?.contactTestBitMask = tipoNodo.mosca.rawValue
        self.addChild(suelo)
    }
    
    func anadirMosca() {
        texturaMosca1 = SKTexture(imageNamed: "fly1.png")
        let texturaMosca2 = SKTexture(imageNamed: "fly2.png")
        let animacion = SKAction.animate(with: [texturaMosca1, texturaMosca2], timePerFrame: 0.1)
        let animacionInfinita = SKAction.repeatForever(animacion)
        mosca = SKSpriteNode(texture: texturaMosca1)
        mosca.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        // Crear el cuerpo físico de la mosca como un círculo con un radio de mitad del height de la textura
        mosca.physicsBody = SKPhysicsBody(circleOfRadius: texturaMosca1.size().height/2)
        mosca.physicsBody?.isDynamic = false
        mosca.physicsBody?.categoryBitMask = tipoNodo.mosca.rawValue
        mosca.physicsBody?.collisionBitMask = tipoNodo.tuboSuelo.rawValue
        mosca.physicsBody?.contactTestBitMask = tipoNodo.tuboSuelo.rawValue | tipoNodo.espacioTubo.rawValue
        mosca.run(animacionInfinita)
        self.addChild(mosca)
    }
    
    func anadirFondo() {
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
    }
    
    @objc func anadirTubos(){
        let moverTubos = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy:0), duration: TimeInterval(self.frame.width/80))
        let removerTubos = SKAction.removeFromParent()
        let moverRemoverTubos = SKAction.sequence([moverTubos, removerTubos])
        let dificultad = mosca.size.height * 3
        // numero entre cero y la mitad del alto de la pantalla
        let cantidadMovimientoAleatorio = CGFloat(arc4random() % UInt32(self.frame.height/2))
        let compensacionTubos = cantidadMovimientoAleatorio - self.frame.height / 4
        let texturaTubo1 = SKTexture(imageNamed:"Tubo1.png")
        tubo1 = SKSpriteNode(texture:texturaTubo1)
        tubo1.position = CGPoint(x:self.frame.midX + self.frame.width, y:self.frame.midY + texturaTubo1.size().height / 2 + dificultad + compensacionTubos)
        tubo1.zPosition = 0
        tubo1.physicsBody = SKPhysicsBody(rectangleOf: texturaTubo1.size())
        tubo1.physicsBody?.isDynamic = false
        tubo1.physicsBody?.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        tubo1.physicsBody?.collisionBitMask = tipoNodo.mosca.rawValue
        tubo1.physicsBody?.contactTestBitMask = tipoNodo.mosca.rawValue
        tubo1.run(moverRemoverTubos)
        self.addChild(tubo1)
        let texturaTubo2 = SKTexture(imageNamed:"Tubo2.png")
        tubo2 = SKSpriteNode(texture:texturaTubo2)
        tubo2.position = CGPoint(x:self.frame.midX + self.frame.width, y:self.frame.midY - texturaTubo2.size().height / 2 - dificultad + compensacionTubos)
        tubo2.zPosition = 0
        tubo2.physicsBody = SKPhysicsBody(rectangleOf: texturaTubo2.size())
        tubo2.physicsBody?.isDynamic = false
        tubo2.physicsBody?.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        tubo2.physicsBody?.collisionBitMask = tipoNodo.mosca.rawValue
        tubo2.physicsBody?.contactTestBitMask = tipoNodo.mosca.rawValue
        tubo2.run(moverRemoverTubos)
        self.addChild(tubo2)
        //MARK: Espacios entre los tubos para poder puntuar
        let espacio = SKSpriteNode()
        let moverEspacio = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy:0), duration: TimeInterval(self.frame.width/80))
        let removerEspacio = SKAction.removeFromParent()
        let moverRemoverEspacio = SKAction.sequence([moverEspacio, removerEspacio])
        let texturaTubo = SKTexture(imageNamed:"Tubo1.png")
        espacio.position = CGPoint(x: self.frame.midX + self.frame.width,y: self.frame.midY + compensacionTubos)
        espacio.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: texturaTubo.size().width, height: dificultad))
        espacio.physicsBody?.isDynamic = false
        espacio.zPosition = 1
        espacio.physicsBody?.categoryBitMask = tipoNodo.espacioTubo.rawValue
        espacio.physicsBody?.collisionBitMask = 0
        espacio.physicsBody?.contactTestBitMask = tipoNodo.mosca.rawValue
        espacio.run(moverRemoverEspacio)
        self.addChild(espacio)
    }
    
    func anadirLabelPuntuacion() {
        labelPuntuacion.fontName = "Arial"
        labelPuntuacion.fontSize = 60
        labelPuntuacion.text = String(puntuacion)
        labelPuntuacion.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 250)
        labelPuntuacion.zPosition = 5
        self.addChild(labelPuntuacion)
    }
    
    func reiniciarJuego() {
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.anadirTubos), userInfo: nil, repeats: true)
        anadirLabelPuntuacion()
        anadirMosca()
        anadirFondo()
        anadirSuelo()
        anadirTubos()
    }
}
