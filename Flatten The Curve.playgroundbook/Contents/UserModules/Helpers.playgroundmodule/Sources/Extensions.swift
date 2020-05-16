
import Foundation

public extension Double {
    var sign: Double {
        self == 0 ? 0 : self > 0 ? 1 : -1
    }
}
