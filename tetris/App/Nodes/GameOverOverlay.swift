//
//  GameOverOverlay.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

final class GameOverOverlay {
    static func present(in scene: SKScene, size: CGSize, completion: @escaping () -> Void) {
        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = .black
        overlay.alpha = 0.6
        overlay.zPosition = 9
        overlay.strokeColor = .clear
        scene.addChild(overlay)

        let label = SKLabelNode(text: String(localized: "GAME OVER"))
        label.fontName = "Helvetica-Bold"
        label.fontSize = 48
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 10
        scene.addChild(label)

        scene.run(.sequence([
            .wait(forDuration: 3.0),
            .run(completion)
        ]))
    }
}
