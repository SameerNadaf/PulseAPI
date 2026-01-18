//
//  DesignSystem.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

// MARK: - Theme Manager
@MainActor
final class ThemeManager: ObservableObject {
    @AppStorage("appTheme") var appTheme: AppTheme = .system
    
    var colorScheme: ColorScheme? {
        switch appTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - App Theme
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Design Tokens
enum DS {
    // MARK: - Spacing
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 999
    }
    
    // MARK: - Font Sizes
    enum FontSize {
        static let caption2: CGFloat = 11
        static let caption: CGFloat = 12
        static let footnote: CGFloat = 13
        static let subheadline: CGFloat = 15
        static let body: CGFloat = 17
        static let headline: CGFloat = 17
        static let title3: CGFloat = 20
        static let title2: CGFloat = 22
        static let title: CGFloat = 28
        static let largeTitle: CGFloat = 34
    }
    
    // MARK: - Animation
    enum Animation {
        static let fast: Double = 0.15
        static let normal: Double = 0.25
        static let slow: Double = 0.4
    }
}

// MARK: - Semantic Colors
extension Color {
    // MARK: - Brand Colors
    static let brand = Color("BrandPrimary")
    static let brandSecondary = Color("BrandSecondary")
    
    // MARK: - Status Colors (Adaptive)
    static let statusHealthy = Color("StatusHealthy")
    static let statusDegraded = Color("StatusDegraded")
    static let statusDown = Color("StatusDown")
    static let statusUnknown = Color("StatusUnknown")
    
    // MARK: - Severity Colors
    static let severityCritical = Color("SeverityCritical")
    static let severityMajor = Color("SeverityMajor")
    static let severityMinor = Color("SeverityMinor")
    
    // MARK: - Chart Colors
    static let chartPrimary = Color("ChartPrimary")
    static let chartSecondary = Color("ChartSecondary")
    static let chartTertiary = Color("ChartTertiary")
    
    // MARK: - Backgrounds (Fallbacks)
    static var cardBackground: Color {
        Color(.secondarySystemGroupedBackground)
    }
    
    static var screenBackground: Color {
        Color(.systemGroupedBackground)
    }
}

// MARK: - Text Styles
extension Font {
    static func displayLarge(weight: Font.Weight = .bold) -> Font {
        .system(size: DS.FontSize.largeTitle, weight: weight, design: .rounded)
    }
    
    static func displayMedium(weight: Font.Weight = .bold) -> Font {
        .system(size: DS.FontSize.title, weight: weight, design: .rounded)
    }
    
    static func titleLarge(weight: Font.Weight = .semibold) -> Font {
        .system(size: DS.FontSize.title2, weight: weight, design: .default)
    }
    
    static func titleMedium(weight: Font.Weight = .semibold) -> Font {
        .system(size: DS.FontSize.title3, weight: weight, design: .default)
    }
    
    static func labelLarge(weight: Font.Weight = .medium) -> Font {
        .system(size: DS.FontSize.body, weight: weight, design: .default)
    }
    
    static func labelMedium(weight: Font.Weight = .medium) -> Font {
        .system(size: DS.FontSize.subheadline, weight: weight, design: .default)
    }
    
    static func bodyLarge(weight: Font.Weight = .regular) -> Font {
        .system(size: DS.FontSize.body, weight: weight, design: .default)
    }
    
    static func bodyMedium(weight: Font.Weight = .regular) -> Font {
        .system(size: DS.FontSize.subheadline, weight: weight, design: .default)
    }
    
    static func mono(size: CGFloat = DS.FontSize.body) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

// MARK: - Shadow Styles
extension View {
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func subtleShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Card Style Modifier
struct CardStyle: ViewModifier {
    var padding: CGFloat = DS.Spacing.lg
    var radius: CGFloat = DS.Radius.md
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

extension View {
    func cardStyle(padding: CGFloat = DS.Spacing.lg, radius: CGFloat = DS.Radius.md) -> some View {
        self.modifier(CardStyle(padding: padding, radius: radius))
    }
}

// MARK: - Theme Preference Modifier
struct ThemedView: ViewModifier {
    @ObservedObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}

extension View {
    func themed(with manager: ThemeManager) -> some View {
        self.modifier(ThemedView(themeManager: manager))
    }
}
