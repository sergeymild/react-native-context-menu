public final class MenuImpactGenerator: UIImpactFeedbackGenerator {
    public static let shared = MenuImpactGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
    /// Глобальное включение/отключение вибрации
    public static var isEnabled = true

    public override func impactOccurred() {
        guard Self.isEnabled else { return }

        super.impactOccurred()
    }

    @available(iOS 13.0, *)
    public override func impactOccurred(intensity: CGFloat) {
        guard Self.isEnabled else { return }

        super.impactOccurred(intensity: intensity)
    }
}
