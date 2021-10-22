import Foundation

struct RectangleWithCoordinates {
    var upperLeft: Coordinates
    var lowerRight: Coordinates
    var width: Int {
        lowerRight.colIndex - upperLeft.colIndex + 1
    }
    var height: Int {
        lowerRight.rowIndex - upperLeft.rowIndex + 1
    }
    var area: Int {
        if lowerRight.rowIndex == -1 && lowerRight.colIndex == -1 {
            return 0
        }
        return width * height
    }
}

struct Coordinates {
    var rowIndex: Int
    var colIndex: Int
}


