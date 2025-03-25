//
//  TetrominoFactory.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

final class TetrominoFactory {
    static func createI() -> Tetromino {
        Tetromino(
            type: .I,
            color: .cyan,
            rotations: [
                [
                    [false, false, false, false],
                    [true,  true,  true,  true ],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                [
                    [false, true, false, false],
                    [false, true, false, false],
                    [false, true, false, false],
                    [false, true, false, false]
                ]
            ]
        )
    }

    static func createO() -> Tetromino {
        Tetromino(
            type: .O,
            color: .yellow,
            rotations: [
                [
                    [false, true,  true,  false],
                    [false, true,  true,  false],
                    [false, false, false, false],
                    [false, false, false, false]
                ]
            ]
        )
    }

    static func createT() -> Tetromino {
        Tetromino(
            type: .T,
            color: .magenta,
            rotations: [
                [
                    [false, true,  false, false],
                    [true,  true,  true,  false],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                [
                    [false, true, false, false],
                    [false, true, true,  false],
                    [false, true, false, false],
                    [false, false, false, false]
                ],
                [
                    [false, false, false, false],
                    [true,  true,  true,  false],
                    [false, true,  false, false],
                    [false, false, false, false]
                ],
                [
                    [false, true, false, false],
                    [true,  true, false, false],
                    [false, true, false, false],
                    [false, false, false, false]
                ]
            ]
        )
    }

    static func createS() -> Tetromino {
        Tetromino(
            type: .S,
            color: .green,
            rotations: [
                [
                    [false, true,  true,  false],
                    [true,  true,  false, false],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                [
                    [true,  false, false, false],
                    [true,  true,  false, false],
                    [false, true,  false, false],
                    [false, false, false, false]
                ]
            ]
        )
    }

    static func createZ() -> Tetromino {
        Tetromino(
            type: .Z,
            color: .red,
            rotations: [
                [
                    [true,  true,  false, false],
                    [false, true,  true,  false],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                [
                    [false, true,  false, false],
                    [true,  true,  false, false],
                    [true,  false, false, false],
                    [false, false, false, false]
                ]
            ]
        )
    }

    static func createJ() -> Tetromino {
        Tetromino(
            type: .J,
            color: .blue,
            rotations: [
                [
                    [true,  false, false, false],
                    [true,  true,  true,  false],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                [
                    [false, true,  true,  false],
                    [false, true,  false, false],
                    [false, true,  false, false],
                    [false, false, false, false]
                ],
                [
                    [false, false, false, false],
                    [true,  true,  true,  false],
                    [false, false, true,  false],
                    [false, false, false, false]
                ],
                [
                    [false, true,  false, false],
                    [false, true,  false, false],
                    [true,  true,  false, false],
                    [false, false, false, false]
                ]
            ]
        )
    }

    static func createL() -> Tetromino {
        Tetromino(
            type: .L,
            color: .orange,
            rotations: [
                [
                    [false, false, true,  false],
                    [true,  true,  true,  false],
                    [false, false, false, false],
                    [false, false, false, false]
                ],
                [
                    [false, true,  false, false],
                    [false, true,  false, false],
                    [false, true,  true,  false],
                    [false, false, false, false]
                ],
                [
                    [false, false, false, false],
                    [true,  true,  true,  false],
                    [true,  false, false, false],
                    [false, false, false, false]
                ],
                [
                    [true,  true,  false, false],
                    [false, true,  false, false],
                    [false, true,  false, false],
                    [false, false, false, false]
                ]
            ]
        )
    }

    static func createRandom() -> Tetromino {
        let all: [() -> Tetromino] = [createI, createO, createT, createS, createZ, createJ, createL]

        return all.randomElement()!()
    }
}
