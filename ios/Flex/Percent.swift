
import UIKit

public struct FPercent {
    let value: CGFloat
}

postfix operator %
public postfix func % (v: CGFloat) -> FPercent {
    return FPercent(value: v)
}

public postfix func % (v: Int) -> FPercent {
    return FPercent(value: CGFloat(v))
}

prefix operator -
public prefix func - (p: FPercent) -> FPercent {
    return FPercent(value: -p.value)
}
