//
//  NextPiecePreview.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

final class NextPiecePreview {
    // MARK: - Properties

    private var blocks: [SKSpriteNode] = []
    private let parent: SKNode
    private let blockSize: CGFloat
    private let origin: CGPoint

    // MARK: - Init

    init(parent: SKNode, blockSize: CGFloat, origin: CGPoint) {
        self.parent = parent
        self.blockSize = blockSize
        self.origin = origin
    }

    // MARK: - Public functions

    func update(with tetromino: Tetromino) {
        blocks.forEach { $0.removeFromParent() }
        blocks.removeAll()

        let shape = tetromino.currentShape
        let previewSize = blockSize * 0.6

        for row in 0..<4 {
            for col in 0..<4 where shape[row][col] {
                let block = SKSpriteNode(color: tetromino.color, size: CGSize(width: previewSize, height: previewSize))
                let x = origin.x + CGFloat(col) * previewSize + previewSize / 2
                let y = origin.y - CGFloat(row) * previewSize - previewSize / 2

                block.position = CGPoint(x: x, y: y)

                parent.addChild(block)

                blocks.append(block)
            }
        }
    }
}
