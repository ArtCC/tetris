//
//  GameScene.swift
//  tetris
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

final class GameScene: SKScene {
    // MARK: - Properties

    private var lastUpdateTime: TimeInterval = 0
    private var fallAccumulator: TimeInterval = 0
    private var currentFallSpeed: TimeInterval {
        max(0.05, 0.5 * pow(0.9, Double(stats.level - 1)))
    }

    private var originX: CGFloat = 0
    private var originY: CGFloat = 0
    private var blockSize: CGFloat = 0
    private var gameArray: [[SKSpriteNode?]] = []
    private var activeTetromino: ActiveTetromino?
    private var nextTetromino: Tetromino?

    private var hud: GameHUD!
    private var stats = GameStats()
    private var nextPreview: NextPiecePreview!

    private let numRows = 20
    private let numCols = 10
    private let horizontalMargin: CGFloat = 16.0
    private let verticalMargin: CGFloat = 0
    private let gridNode = SKNode()

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        calculateBlockSize()
        setupGrid()
        createInitNextPreview()
        spawnNewTetromino()
        setupSwipeGestures(in: view)

        hud = GameHUD(scene: self, position: CGPoint(x: horizontalMargin, y: size.height - 75), width: 140)
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime

            return
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        fallAccumulator += deltaTime

        if fallAccumulator >= currentFallSpeed {
            fallAccumulator = 0

            moveTetrominoDown()
        }
    }

    // MARK: - UITouch

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        rotateTetromino()
    }
}

// MARK: - Setup

private extension GameScene {
    func calculateBlockSize() {
        let usableHeight = size.height - (verticalMargin * 2)
        let usableWidth = size.width - (horizontalMargin * 2)

        blockSize = min(usableHeight / CGFloat(numRows), usableWidth / CGFloat(numCols))
    }

    func setupGrid() {
        addChild(gridNode)

        let totalGridWidth = CGFloat(numCols) * blockSize
        let totalGridHeight = CGFloat(numRows) * blockSize

        originX = (size.width - totalGridWidth) / 2
        originY = (size.height - totalGridHeight) / 2

        for row in 0..<numRows {
            var rowArray: [SKSpriteNode?] = []

            for col in 0..<numCols {
                let cell = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize))
                cell.strokeColor = .darkGray
                cell.lineWidth = 1
                cell.position = CGPoint(x: originX + CGFloat(col) * blockSize + blockSize / 2,
                                        y: originY + CGFloat(row) * blockSize + blockSize / 2)

                gridNode.addChild(cell)

                rowArray.append(nil)
            }

            gameArray.append(rowArray)
        }
    }

    private func createLabel(text: String, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = position

        addChild(label)

        return label
    }

    private func createLabelBackground(at position: CGPoint, size: CGSize) -> SKShapeNode {
        let background = SKShapeNode(rect: CGRect(origin: position, size: size), cornerRadius: 5)
        background.fillColor = UIColor.black.withAlphaComponent(0.5)
        background.strokeColor = .clear
        background.zPosition = -1

        return background
    }
}

// MARK: - Gesture Handling

private extension GameScene {
    func setupSwipeGestures(in view: SKView) {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .down]

        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            gesture.direction = direction

            view.addGestureRecognizer(gesture)
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right: moveTetrominoBy(x: 1, y: 0)
        case .left: moveTetrominoBy(x: -1, y: 0)
        case .down: moveTetrominoBy(x: 0, y: -1)
        default: break
        }
    }
}

// MARK: - Tetromino Management

private extension GameScene {
    func createInitNextPreview() {
        let previewOrigin = CGPoint(x: size.width - horizontalMargin - (4 * blockSize * 0.6), y: size.height - 100)
        nextPreview = NextPiecePreview(parent: self, blockSize: blockSize, origin: previewOrigin)
        nextTetromino = TetrominoFactory.createRandom()

        if let nextTetromino {
            nextPreview.update(with: nextTetromino)
        }
    }

    func spawnNewTetromino() {
        if nextTetromino == nil {
            nextTetromino = TetrominoFactory.createRandom()
        }

        var tetromino = nextTetromino!
        tetromino.position = CGPoint(x: CGFloat((numCols / 2) - 2), y: CGFloat(numRows - 4))

        activeTetromino = ActiveTetromino(tetromino: tetromino,
                                          parentNode: gridNode,
                                          blockSize: blockSize,
                                          originX: originX,
                                          originY: originY)

        if !isValidPosition(activeTetromino?.tetromino) {
            gameOver()

            return
        }

        activeTetromino?.draw()

        nextTetromino = TetrominoFactory.createRandom()

        if let next = nextTetromino {
            nextPreview?.update(with: next)
        }
    }

    func isValidPosition(_ tetromino: Tetromino?) -> Bool {
        guard let tetromino else {
            return false
        }

        let shape = tetromino.currentShape

        for row in 0..<4 {
            for col in 0..<4 where shape[row][col] {
                let gridX = Int(tetromino.position.x) + col
                let gridY = Int(tetromino.position.y) + (3 - row)

                if gridX < 0 || gridX >= numCols || gridY < 0 {
                    return false
                }

                if gridY < numRows && gameArray[gridY][gridX] != nil {
                    return false
                }
            }
        }

        return true
    }

    func moveTetrominoDown() {
        activeTetromino?.move(byX: 0, byY: -1)

        if !isValidPosition(activeTetromino?.tetromino) {
            activeTetromino?.move(byX: 0, byY: 1) // Revert move

            fixTetromino()
        } else {
            activeTetromino?.draw()
        }
    }

    func moveTetrominoBy(x: Int, y: Int) {
        activeTetromino?.move(byX: x, byY: y)

        if !isValidPosition(activeTetromino?.tetromino) {
            activeTetromino?.move(byX: -x, byY: -y) // Revert move
        } else {
            activeTetromino?.draw()
        }
    }

    func rotateTetromino() {
        activeTetromino?.rotate()

        if !isValidPosition(activeTetromino?.tetromino) {
            activeTetromino?.undoRotate()
        } else {
            activeTetromino?.draw()
        }
    }

    func fixTetromino() {
        guard let tetromino = activeTetromino?.tetromino else {
            return
        }

        let shape = tetromino.currentShape

        for row in 0..<4 {
            for col in 0..<4 where shape[row][col] {
                let gridX = Int(tetromino.position.x) + col
                let gridY = Int(tetromino.position.y) + (3 - row)

                if (0..<numCols).contains(gridX), (0..<numRows).contains(gridY) {
                    let posX = originX + CGFloat(gridX) * blockSize + blockSize / 2
                    let posY = originY + CGFloat(gridY) * blockSize + blockSize / 2

                    let block = SKSpriteNode(color: tetromino.color, size: CGSize(width: blockSize, height: blockSize))
                    block.position = CGPoint(x: posX, y: posY)

                    gridNode.addChild(block)

                    gameArray[gridY][gridX] = block
                }
            }
        }

        activeTetromino?.removeFromScene()
        activeTetromino = nil

        clearFullLines()
        spawnNewTetromino()
    }
}

// MARK: - Game Logic

private extension GameScene {
    func updateScoreAndLevel(linesRemoved: Int) {
        let (points, didLevelUp) = stats.addClearedLines(linesRemoved)

        showScoreEffect(points: points, at: CGPoint(x: size.width / 2, y: size.height / 2))

        if didLevelUp {
            showLevelUpEffect()
        }

        hud.update(score: stats.score, lines: stats.linesCleared, level: stats.level)
    }

    func clearFullLines() {
        var rowsToRemove = [Int]()

        for row in 0..<numRows where gameArray[row].allSatisfy({ $0 != nil }) {
            rowsToRemove.append(row)
        }

        if !rowsToRemove.isEmpty {
            for row in rowsToRemove.sorted(by: >) {
                animateLineRemoval(at: row)

                removeLine(at: row)
            }

            updateScoreAndLevel(linesRemoved: rowsToRemove.count)
        }
    }

    func removeLine(at row: Int) {
        for col in 0..<numCols {
            gameArray[row][col]?.removeFromParent()
            gameArray[row][col] = nil
        }

        for y in (row + 1)..<numRows {
            for x in 0..<numCols {
                if let block = gameArray[y][x] {
                    block.run(.moveTo(y: originY + CGFloat(y - 1) * blockSize + blockSize / 2, duration: 0.1))

                    gameArray[y - 1][x] = block
                    gameArray[y][x] = nil
                }
            }
        }
    }

    func animateLineRemoval(at row: Int) {
        for col in 0..<numCols {
            gameArray[row][col]?.run(createFlashAnimation())
        }
    }

    private func createFlashAnimation() -> SKAction {
        return SKAction.sequence([
            .fadeAlpha(to: 0.3, duration: 0.05),
            .fadeAlpha(to: 1.0, duration: 0.05),
            .repeat(.sequence([
                .scale(to: 1.2, duration: 0.05),
                .scale(to: 1.0, duration: 0.05)
            ]), count: 3)
        ])
    }

    func showScoreEffect(points: Int, at position: CGPoint) {
        let effect = SKLabelNode(text: String(localized: "+\(points)"))
        effect.fontName = "Helvetica-Bold"
        effect.fontSize = 28
        effect.fontColor = .yellow
        effect.position = position
        effect.zPosition = 100

        addChild(effect)

        effect.run(.sequence([
            .move(by: CGVector(dx: 0, dy: 50), duration: 0.5),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
    }

    func showLevelUpEffect() {
        let effect = SKLabelNode(text: String(localized: "LEVEL UP!"))
        effect.fontName = "Helvetica-Bold"
        effect.fontSize = 36
        effect.fontColor = .systemOrange
        effect.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        effect.zPosition = 100
        effect.setScale(0.1)

        addChild(effect)

        effect.run(.sequence([
            .scale(to: 1.2, duration: 0.3),
            .wait(forDuration: 0.5),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
    }

    func gameOver() {
        GameOverOverlay.present(in: self, size: size) { [weak self] in
            guard let self, let view else {
                return
            }

            let startScene = StartScene(size: self.size)
            startScene.scaleMode = .resizeFill

            view.presentScene(startScene, transition: .fade(withDuration: 0.5))
        }
    }
}
