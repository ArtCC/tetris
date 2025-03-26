//
//  ActiveTetromino.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

final class ActiveTetromino {
    // MARK: - Properties

    private(set) var blocks: [SKSpriteNode] = []

    private unowned let parentNode: SKNode

    private let blockSize: CGFloat
    private let originX: CGFloat
    private let originY: CGFloat

    var tetromino: Tetromino

    // MARK: - Init

    init(tetromino: Tetromino,
         parentNode: SKNode,
         blockSize: CGFloat,
         originX: CGFloat,
         originY: CGFloat) {
        self.tetromino = tetromino
        self.parentNode = parentNode
        self.blockSize = blockSize
        self.originX = originX
        self.originY = originY
    }

    // MARK: - Public functions

    func draw() {
        blocks.forEach { $0.removeFromParent() }
        blocks.removeAll()

        let shape = tetromino.currentShape

        for row in 0..<4 {
            for col in 0..<4 {
                if shape[row][col] {
                    let gridX = Int(tetromino.position.x) + col
                    let gridY = Int(tetromino.position.y) + (3 - row)
                    let posX = originX + CGFloat(gridX) * blockSize + blockSize / 2
                    let posY = originY + CGFloat(gridY) * blockSize + blockSize / 2

                    let block = SKSpriteNode(color: tetromino.color, size: CGSize(width: blockSize, height: blockSize))
                    block.position = CGPoint(x: posX, y: posY)

                    parentNode.addChild(block)

                    blocks.append(block)
                }
            }
        }
    }

    func move(byX x: Int, byY y: Int) {
        tetromino.position.x += CGFloat(x)
        tetromino.position.y += CGFloat(y)
    }

    func rotate() {
        tetromino.rotate()
    }

    func undoRotate() {
        tetromino.rotationIndex = (tetromino.rotationIndex + tetromino.rotations.count - 1) % tetromino.rotations.count
    }

    func removeFromScene() {
        blocks.forEach { $0.removeFromParent() }
        blocks.removeAll()
    }
}
