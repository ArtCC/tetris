//
//  GameHUD.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

final class GameHUD {
    // MARK: - Properties

    private let background: SKShapeNode
    private let scoreLabel: SKLabelNode
    private let levelLabel: SKLabelNode
    private let linesLabel: SKLabelNode

    // MARK: - Init

    init(scene: SKScene, position: CGPoint, width: CGFloat, spacing: CGFloat = 30) {
        scoreLabel = GameHUD.createLabel(text: String(localized: "SCORE: 0"), position: position)
        linesLabel = GameHUD.createLabel(text: String(localized: "LINES: 0"), position: CGPoint(x: position.x, y: position.y - spacing))
        levelLabel = GameHUD.createLabel(text: String(localized: "LEVEL: 1"), position: CGPoint(x: position.x, y: position.y - spacing * 2))

        scene.addChild(scoreLabel)
        scene.addChild(linesLabel)
        scene.addChild(levelLabel)

        let rect = CGRect(x: position.x - 10,
                          y: position.y - spacing * 2.5,
                          width: width,
                          height: spacing * 3 + 10)

        background = SKShapeNode(rect: rect, cornerRadius: 5)
        background.fillColor = UIColor.black.withAlphaComponent(0.5)
        background.strokeColor = .clear
        background.zPosition = -1

        scene.addChild(background)
    }

    // MARK: - Public functions

    func update(score: Int, lines: Int, level: Int) {
        scoreLabel.text = String(localized: "SCORE: \(score)")
        linesLabel.text = String(localized: "LINES: \(lines)")
        levelLabel.text = String(localized: "LEVEL: \(level)")
    }

    // MARK: - Private

    private static func createLabel(text: String, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = position

        return label
    }
}
