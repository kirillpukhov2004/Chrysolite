import UIKit

extension UIFont {
    static func systemFont(
        ofSize size: CGFloat,
        weight: UIFont.Weight = .regular,
        design: UIFontDescriptor.SystemDesign = .default
    ) -> UIFont {
        let fontDescriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(design)
        guard let fontDescriptor = fontDescriptor else { fatalError() }

        let font = UIFont(descriptor: fontDescriptor, size: size)

        return font
    }
}
