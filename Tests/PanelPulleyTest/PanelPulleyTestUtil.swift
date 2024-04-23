import CoreGraphics
import Foundation

extension PanelPulleyTestUtil {
  func cfDictionary(
    width wd: Int,
    height hi: Int,
    x xax: Int,
    y yax: Int
  ) -> CFDictionary {
    let rect = CGRect(
      x: CGFloat(integerLiteral: xax), y: CGFloat(integerLiteral: yax),
      width: CGFloat(integerLiteral: wd), height: CGFloat(integerLiteral: hi))
    return rect.dictionaryRepresentation
  }
}
