//
//  StartScene.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

class StartScene: SKScene {
    // MARK: - Override

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let label = SKLabelNode(text: String(localized: "TETRIS"))
        label.fontName = "Helvetica-Bold"
        label.fontSize = 64
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)

        addChild(label)

        let startLabel = SKLabelNode(text: String(localized: "Tap to start"))
        startLabel.fontName = "Helvetica"
        startLabel.fontSize = 28
        startLabel.fontColor = .lightGray
        startLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 40)

        addChild(startLabel)

        addDecorativePieces()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: size)

        view?.presentScene(gameScene, transition: transition)
    }
}

// MARK: - Private

private extension StartScene {
    func addDecorativePieces() {
        let decorativeTypes: [Tetromino] = [
            TetrominoFactory.createI(),
            TetrominoFactory.createT(),
            TetrominoFactory.createL(),
            TetrominoFactory.createO()
        ]
        let positions: [CGPoint] = [
            CGPoint(x: size.width * 0.2, y: size.height * 0.7),
            CGPoint(x: size.width * 0.8, y: size.height * 0.75),
            CGPoint(x: size.width * 0.25, y: size.height * 0.3),
            CGPoint(x: size.width * 0.75, y: size.height * 0.2)
        ]

        for (index, tetromino) in decorativeTypes.enumerated() {
            drawDecorativeTetromino(tetromino, at: positions[index])
        }
    }

    func drawDecorativeTetromino(_ tetromino: Tetromino, at position: CGPoint) {
        let shape = tetromino.currentShape
        let blockSize: CGFloat = 20.0

        for row in 0..<4 {
            for col in 0..<4 {
                if shape[row][col] {
                    let block = SKSpriteNode(color: tetromino.color.withAlphaComponent(0.3),
                                             size: CGSize(width: blockSize, height: blockSize))
                    let offsetX = CGFloat(col) * blockSize
                    let offsetY = CGFloat(3 - row) * blockSize
                    block.position = CGPoint(x: position.x + offsetX, y: position.y + offsetY)
                    block.zPosition = -1

                    addChild(block)
                }
            }
        }
    }
}
