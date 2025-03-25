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
        max(0.05, 0.5 * pow(0.9, Double(level - 1)))
    }

    var originX: CGFloat = 0
    var originY: CGFloat = 0
    var blockSize: CGFloat = 0
    var gameArray: [[SKSpriteNode?]] = []
    var currentTetromino: Tetromino?
    var currentBlocks: [SKSpriteNode] = []
    var score = 0
    var level = 1
    var linesCleared = 0
    var scoreLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var linesLabel: SKLabelNode!
    var nextTetromino: Tetromino?
    var nextPiecePreviewNodes: [SKSpriteNode] = []

    let numRows = 20
    let numCols = 10
    let horizontalMargin: CGFloat = 16.0
    let verticalMargin: CGFloat = 0
    let gridNode = SKNode()

    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        calculateBlockSize()
        setupGrid()
        setupLabels()
        spawnNewTetromino()
        setupSwipeGestures(in: view)
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

// MARK: - Private

private extension GameScene {
    func calculateBlockSize() {
        let usableHeight = size.height - (verticalMargin * 2)
        let usableWidth = size.width - (horizontalMargin * 2)

        let heightBased = usableHeight / CGFloat(numRows)
        let widthBased = usableWidth / CGFloat(numCols)

        blockSize = min(heightBased, widthBased)
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

    func setupLabels() {
        let labelX = horizontalMargin
        let startY = size.height - 75
        let verticalSpacing: CGFloat = 30
        let labelAttributes: (SKLabelNode) -> Void = { label in
            label.fontName = "Helvetica-Bold"
            label.fontSize = 20
            label.fontColor = .white
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
        }

        scoreLabel = SKLabelNode(text: String(localized: "SCORE: 0"))
        scoreLabel.position = CGPoint(x: labelX, y: startY)
        labelAttributes(scoreLabel)
        addChild(scoreLabel)

        linesLabel = SKLabelNode(text: String(localized: "LINES: 0"))
        linesLabel.position = CGPoint(x: labelX, y: startY - verticalSpacing)
        labelAttributes(linesLabel)
        addChild(linesLabel)

        levelLabel = SKLabelNode(text: String(localized: "LEVEL: 1"))
        levelLabel.position = CGPoint(x: labelX, y: startY - verticalSpacing * 2)
        labelAttributes(levelLabel)
        addChild(levelLabel)

        let backgroundRect = CGRect(x: labelX - 10,
                                    y: startY - verticalSpacing * 2.5,
                                    width: 140,
                                    height: verticalSpacing * 3 + 10)
        let background = SKShapeNode(rect: backgroundRect, cornerRadius: 5)
        background.fillColor = UIColor.black.withAlphaComponent(0.5)
        background.strokeColor = .clear
        background.zPosition = -1

        addChild(background)
    }

    func updateLabels() {
        scoreLabel.text = String(localized: "SCORE: \(score)")
        levelLabel.text = String(localized: "LEVEL: \(level)")
        linesLabel.text = String(localized: "LINES: \(linesCleared)")
    }

    func updateScoreAndLevel(linesRemoved: Int) {
        let points: Int
        switch linesRemoved {
        case 1: points = 100 * level
        case 2: points = 300 * level
        case 3: points = 500 * level
        case 4: points = 800 * level
        default: points = 0
        }

        score += points
        linesCleared += linesRemoved

        showScoreEffect(points: points, at: CGPoint(x: size.width/2, y: size.height/2))

        let newLevel = linesCleared / 10 + 1

        if newLevel > level {
            level = newLevel
            showLevelUpEffect()
        }

        updateLabels()
    }

    func spawnNewTetromino() {
        if nextTetromino == nil {
            nextTetromino = TetrominoFactory.createRandom()
        }

        currentTetromino = nextTetromino
        currentTetromino?.position = CGPoint(x: CGFloat((numCols / 2) - 2), y: CGFloat(numRows - 4))

        if let tetromino = currentTetromino, !isValidPosition(tetromino) {
            gameOver()

            return
        }

        nextTetromino = TetrominoFactory.createRandom()

        drawCurrentTetromino()
        drawNextTetrominoPreview()
    }

    func setupSwipeGestures(in view: SKView) {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            moveTetrominoBy(x: 1, y: 0)
        case .left:
            moveTetrominoBy(x: -1, y: 0)
        case .down:
            moveTetrominoBy(x: 0, y: -1)
        default:
            break
        }
    }
}

// MARK: - Drawing & Game Logic

private extension GameScene {
    func drawCurrentTetromino() {
        currentBlocks.forEach { $0.removeFromParent() }
        currentBlocks.removeAll()

        guard let currentTetromino else {
            return
        }

        let shape = currentTetromino.currentShape

        for row in 0..<4 {
            for col in 0..<4 {
                if shape[row][col] {
                    let block = SKSpriteNode(color: currentTetromino.color, size: CGSize(width: blockSize, height: blockSize))
                    let gridX = Int(currentTetromino.position.x) + col
                    let gridY = Int(currentTetromino.position.y) + (3 - row)
                    let posX = originX + CGFloat(gridX) * blockSize + blockSize / 2
                    let posY = originY + CGFloat(gridY) * blockSize + blockSize / 2

                    block.position = CGPoint(x: posX, y: posY)

                    gridNode.addChild(block)

                    currentBlocks.append(block)
                }
            }
        }
    }

    func drawNextTetrominoPreview() {
        nextPiecePreviewNodes.forEach { $0.removeFromParent() }
        nextPiecePreviewNodes.removeAll()

        guard let nextTetromino else {
            return
        }

        let shape = nextTetromino.currentShape
        let previewBlockSize = blockSize * 0.6
        let previewOriginX = size.width - horizontalMargin - (4 * previewBlockSize)
        let previewOriginY = size.height - 100

        for row in 0..<4 {
            for col in 0..<4 {
                if shape[row][col] {
                    let block = SKSpriteNode(color: nextTetromino.color, size: CGSize(width: previewBlockSize, height: previewBlockSize))
                    let x = previewOriginX + CGFloat(col) * previewBlockSize + previewBlockSize / 2
                    let y = previewOriginY - CGFloat(row) * previewBlockSize - previewBlockSize / 2

                    block.position = CGPoint(x: x, y: y)

                    addChild(block)

                    nextPiecePreviewNodes.append(block)
                }
            }
        }
    }

    func showScoreEffect(points: Int, at position: CGPoint) {
        let effect = SKLabelNode(text: String(localized: "+\(points)"))
        effect.fontName = "Helvetica-Bold"
        effect.fontSize = 28
        effect.fontColor = .yellow
        effect.position = position
        effect.zPosition = 100

        addChild(effect)

        let action = SKAction.sequence([
            .move(by: CGVector(dx: 0, dy: 50), duration: 0.5),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ])

        effect.run(action)
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

        let action = SKAction.sequence([
            .scale(to: 1.2, duration: 0.3),
            .wait(forDuration: 0.5),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ])
        effect.run(action)
    }

    func moveTetrominoDown() {
        guard var tetromino = currentTetromino else {
            return
        }

        tetromino.position.y -= 1

        if isValidPosition(tetromino) {
            currentTetromino = tetromino

            drawCurrentTetromino()
        } else {
            fixTetromino()
        }
    }

    func isValidPosition(_ tetromino: Tetromino) -> Bool {
        let shape = tetromino.currentShape

        for row in 0..<4 {
            for col in 0..<4 {
                if shape[row][col] {
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
        }

        return true
    }

    func fixTetromino() {
        guard let tetromino = currentTetromino else {
            return
        }

        let shape = tetromino.currentShape

        for row in 0..<4 {
            for col in 0..<4 {
                if shape[row][col] {
                    let gridX = Int(tetromino.position.x) + col
                    let gridY = Int(tetromino.position.y) + (3 - row)

                    if gridX >= 0, gridX < numCols, gridY >= 0, gridY < numRows {
                        let posX = originX + CGFloat(gridX) * blockSize + blockSize / 2
                        let posY = originY + CGFloat(gridY) * blockSize + blockSize / 2
                        let block = SKSpriteNode(color: tetromino.color, size: CGSize(width: blockSize, height: blockSize))
                        block.position = CGPoint(x: posX, y: posY)

                        gridNode.addChild(block)

                        gameArray[gridY][gridX] = block
                    }
                }
            }
        }

        currentBlocks.forEach { $0.removeFromParent() }
        currentBlocks.removeAll()

        currentTetromino = nil

        clearFullLines()

        spawnNewTetromino()
    }

    func moveTetrominoBy(x: Int, y: Int) {
        guard var tetromino = currentTetromino else {
            return
        }

        tetromino.position.x += CGFloat(x)
        tetromino.position.y += CGFloat(y)

        if isValidPosition(tetromino) {
            currentTetromino = tetromino

            drawCurrentTetromino()
        }
    }

    func rotateTetromino() {
        guard var tetromino = currentTetromino else {
            return
        }

        tetromino.rotate()

        if isValidPosition(tetromino) {
            currentTetromino = tetromino

            drawCurrentTetromino()
        } else {
            tetromino.rotationIndex = (tetromino.rotationIndex + tetromino.rotations.count - 1) % tetromino.rotations.count
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
                    let newY = originY + CGFloat(y - 1) * blockSize + blockSize / 2
                    let moveAction = SKAction.moveTo(y: newY, duration: 0.1)

                    block.run(moveAction)

                    gameArray[y - 1][x] = block
                    gameArray[y][x] = nil
                }
            }
        }
    }

    func clearFullLines() {
        var linesRemoved = 0
        var rowsToRemove = [Int]()

        for row in 0..<numRows {
            if gameArray[row].allSatisfy({ $0 != nil }) {
                rowsToRemove.append(row)
            }
        }

        linesRemoved = rowsToRemove.count

        if linesRemoved > 0 {
            for row in rowsToRemove.sorted(by: >) {
                animateLineRemoval(at: row)
                removeLine(at: row)
            }

            updateScoreAndLevel(linesRemoved: linesRemoved)
        }
    }

    func animateLineRemoval(at row: Int) {
        for col in 0..<numCols {
            if let block = gameArray[row][col] {
                let flashAction = SKAction.sequence([
                    .fadeAlpha(to: 0.3, duration: 0.05),
                    .fadeAlpha(to: 1.0, duration: 0.05),
                    .repeat(.sequence([.scale(to: 1.2, duration: 0.05), .scale(to: 1.0, duration: 0.05)]), count: 3)
                ])

                block.run(flashAction)
            }
        }
    }

    func gameOver() {
        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = .black
        overlay.alpha = 0.6
        overlay.zPosition = 9
        overlay.strokeColor = .clear

        addChild(overlay)

        let label = SKLabelNode(text: String(localized: "GAME OVER"))
        label.fontName = "Helvetica-Bold"
        label.fontSize = 48
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 10

        addChild(label)

        run(.sequence([.wait(forDuration: 3.0), .run { [weak self] in
            guard let self, let view = self.view else {
                return
            }

            let startScene = StartScene(size: self.size)
            startScene.scaleMode = .resizeFill

            view.presentScene(startScene, transition: .fade(withDuration: 0.5))
        }]))
    }
}
