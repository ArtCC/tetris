//
//  Tetromino.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

enum TetrominoType: CaseIterable {
    case I, O, T, S, Z, J, L
}

struct Tetromino {
    // MARK: - Properties

    var rotationIndex: Int = 0
    var position: CGPoint = .zero
    var currentShape: [[Bool]] {
        rotations[rotationIndex]
    }

    let type: TetrominoType
    let color: SKColor
    let rotations: [[[Bool]]]

    // MARK: - Public functions

    mutating func rotate() {
        rotationIndex = (rotationIndex + 1) % rotations.count
    }
}
