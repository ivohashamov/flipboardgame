import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var gameFieldColors = Array(
        repeating: Array(
            repeating: Color.white,
            count: 15),
        count: 15
    )
    
    @Published
    var biggestRectangle: RectangleWithCoordinates = RectangleWithCoordinates(
        upperLeft: Coordinates(rowIndex: 0, colIndex: 0),
        lowerRight: Coordinates(rowIndex: -1, colIndex: -1)
    )
    
    /**
     Changes color of tapped field and calculates the new biggest rectangle
     */
    func changeColor(_ rowIndex: Int, _ colIndex: Int) {
        if gameFieldColors[rowIndex][colIndex] == .white {
            gameFieldColors[rowIndex][colIndex] = .gray
        } else {
            gameFieldColors[rowIndex][colIndex] = .white
        }
        let intMatrix = toIntMatrix(gameFieldColors) // map color matrix to a binary matrix
        calculateBiggestRectangle(intMatrix)
        setRedColors()
    }
    
    /**
     Updates values of non-white fields such that only the ones included in the biggest rectangle are red
     */
    private func setRedColors() {
        for i in 0...14 {
            for j in 0...14 {
                if gameFieldColors[i][j] != .white {
                    if isInBiggestRectangle(i, j) {
                        gameFieldColors[i][j] = .red
                    } else {
                        gameFieldColors[i][j] = .gray
                    }
                }
            }
        }
    }
    
    private func isInBiggestRectangle(_ rowIndex: Int, _ colIndex: Int) -> Bool {
        if biggestRectangle.upperLeft.rowIndex...biggestRectangle.lowerRight.rowIndex ~= rowIndex && biggestRectangle.upperLeft.colIndex...biggestRectangle.lowerRight.colIndex ~= colIndex {
            return true
        }
        return false
    }
    
    /**
    Algorithm to calculate the biggest rectangle in a binary matrix
     For **m** (row length) and **n** (column length) it applies that
     - Time complexity is *O(m(n^2))*
        - one loop through each field in the matrix for the *calculateRectangle* - *O(mn)*
        - *calculateLowerRightCoordinates* has time complexity of *O(n)*
     - Runtime space complexity is *O(n)* since we store one column at a time for every outer loop
     - Overall space complexity is *O(mn + n)* - matrix size + cache
     */
    private func calculateBiggestRectangle(_ matrix: [[Int]]) {
        var biggestRectangleUpperLeft = Coordinates(rowIndex: 0, colIndex: 0)
        var biggestRectangleLowerRight = Coordinates(rowIndex: -1, colIndex: -1)
        var cache = Array(repeating: 0, count: 15)
        // since we draw rectangles from left to right, looping from the right allows us to initialize cache with zeroes
        for colIndex in (0...14).reversed() {
            updateCache(colIndex, matrix, &cache) // update cache with current column
            for rowIndex in (0...14).reversed() {
                let upperLeft = Coordinates(rowIndex: rowIndex, colIndex: colIndex)
                // draw rectangle from upper left corner to lower right corner
                let lowerRight = calculateLowerRightCoordinates(upperLeft, cache)
                // update new biggest rectangle
                if area(upperLeft, lowerRight) > area(biggestRectangleUpperLeft, biggestRectangleLowerRight) {
                    biggestRectangleUpperLeft = upperLeft
                    biggestRectangleLowerRight = lowerRight
                }
            }
        }
        biggestRectangle.upperLeft = biggestRectangleUpperLeft
        biggestRectangle.lowerRight = biggestRectangleLowerRight
    }
    
    private func area(_ upperLeft: Coordinates, _ lowerRight: Coordinates) -> Int {
        if upperLeft.rowIndex > lowerRight.rowIndex || upperLeft.colIndex > lowerRight.colIndex {
            return 0
        } else {
            let width = lowerRight.colIndex - upperLeft.colIndex + 1
            let height = lowerRight.rowIndex - upperLeft.rowIndex + 1
            return width * height
        }
    }
    
    /**
        Update cache, such that value for the selected column field gets incremented if the field is not 0, otherwise field in cache gets set to 0 as well
     */
    private func updateCache(_ colIndex: Int, _ matrix: [[Int]], _ cache: inout [Int]) {
        for rowIndex in 0...14 {
            if matrix[rowIndex][colIndex] != 0 {
                cache[rowIndex] += 1
            } else {
                cache[rowIndex] = 0
            }
        }
    }
    
    /**
        Calculates lower right corner coordinates of a rectangle based on upper left corner coordiantes and cache
     */
    private func calculateLowerRightCoordinates(_ upperLeft: Coordinates, _ cache: [Int]) -> Coordinates {
        var lowerRight = Coordinates(rowIndex: upperLeft.rowIndex - 1, colIndex: upperLeft.colIndex - 1)
        var maxColIndex = 15
        var rowIndex = upperLeft.rowIndex - 1
        // if cache contains 0, the rectangle would contain a white field, therefore we break the loop
        while rowIndex + 1 < 15 && cache[rowIndex + 1] != 0 {
            rowIndex += 1
            // represents "cutting off" any outstanding white fields on the right of the rectangle we are drawing
            let colIndex = min(upperLeft.colIndex + cache[rowIndex] - 1, maxColIndex)
            maxColIndex = colIndex
            let newCoordinates = Coordinates(rowIndex: rowIndex, colIndex: colIndex)
            // update lower right coordiantes, only if the newly produced rectangle is larger
            if area(upperLeft, newCoordinates) > area(upperLeft, lowerRight) {
                lowerRight = newCoordinates
            }
        }
        return lowerRight
    }
    
    /**
        Maps a Color matrix to a binary matrix
        - white gets mapped to 0
        - gray and red get mapped to 1
     */
    private func toIntMatrix(_ matrix: [[Color]]) -> [[Int]] {
        var result = Array(
            repeating: Array(
                repeating: 0,
                count: 15),
            count: 15
        )
        
        for i in 0...14 {
            for j in 0...14 {
                if matrix[i][j] != .white {
                    result[i][j] = 1
                }
            }
        }
        
        return result
    }
}
