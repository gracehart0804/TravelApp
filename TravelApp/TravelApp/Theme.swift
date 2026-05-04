//
//  Theme.swift
//  TravelApp
//
//  Created by Hartman, Grace on 4/29/26.
//
import SwiftUI

// MARK: - Hex Color Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (
                255,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )

        case 8: // ARGB
            (a, r, g, b) = (
                (int >> 24) & 0xFF,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Colors

enum AppColors {

    // Backgrounds
    static let background = Color(hex: "#F7F4EF")
    static let surface = Color(hex: "#FFFFFF")
    static let surfaceAlt = Color(hex: "#EFE9E1")

    // Text
    static let primaryText = Color(hex: "#2B2B2B")
    static let secondaryText = Color(hex: "#6E6A66")
    static let placeholderText = Color(hex: "#A8A39D")

    // Accent
    static let accent = Color(hex: "#3D5A80")
    static let highlight = Color(hex: "#E29578")

    // Status
    static let success = Color(hex: "#6B8F71")
    static let warning = Color(hex: "#D4A373")
    static let error = Color(hex: "#C44536")
}

// MARK: - App Fonts

enum AppFonts {

    // Decorative / postcard titles
    static let largeTitle = Font.custom("PlayfairDisplay-Regular", size: 32)
    static let title = Font.custom("PlayfairDisplay-Regular", size: 24)

    // Standard UI text
    static let body = Font.system(size: 16, weight: .regular)
    static let bodyBold = Font.system(size: 16, weight: .semibold)

    // Small supporting text
    static let caption = Font.system(size: 13, weight: .regular)
    static let micro = Font.system(size: 11, weight: .medium)
}

// MARK: - App Spacing

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum AppRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
}

// MARK: - Shadow Model

struct AppShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Shadows

enum AppShadows {

    static let soft = AppShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 10,
        x: 0,
        y: 4
    )

    static let elevated = AppShadowStyle(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )
}

// MARK: - View Extension

extension View {
    func appShadow(_ style: AppShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.bodyBold)
            .foregroundColor(.white)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.lg)
            .background(AppColors.accent)
            .cornerRadius(AppRadius.medium)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.bodyBold)
            .foregroundColor(AppColors.accent)
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.lg)
            .background(AppColors.surfaceAlt)
            .cornerRadius(AppRadius.medium)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
