//
//  GameStats.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import Foundation

struct GameStats {
    // MARK: - Properties

    private(set) var score: Int = 0
    private(set) var level: Int = 1
    private(set) var linesCleared: Int = 0

    // MARK: - Public functions

    mutating func addClearedLines(_ count: Int) -> (points: Int, didLevelUp: Bool) {
        linesCleared += count

        let points: Int
        switch count {
        case 1: points = 100 * level
        case 2: points = 300 * level
        case 3: points = 500 * level
        case 4: points = 800 * level
        default: points = 0
        }

        score += points

        let newLevel = (linesCleared / 10) + 1
        let didLevelUp = newLevel > level

        level = newLevel

        return (points, didLevelUp)
    }
}
