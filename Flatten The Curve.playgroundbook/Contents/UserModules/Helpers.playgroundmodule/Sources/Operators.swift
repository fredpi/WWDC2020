
import Foundation

// This is a dummy operator allowing a slick notation of percentages (e. g. 25%)
postfix operator %

public postfix func %(lhs: Double) -> Double {
    lhs
}

public postfix func %(lhs: Int) -> Double {
    Double(lhs)
}
