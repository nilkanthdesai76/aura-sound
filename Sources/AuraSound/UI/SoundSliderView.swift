import SwiftUI

/// Elegant horizontal slider card with live percentage badge and SF Symbol icon.
public struct SoundSliderView: View {
    let title: String
    let sfSymbol: String
    let tintColor: Color
    @Binding var value: Float
    
    public init(
        title: String,
        sfSymbol: String,
        tintColor: Color,
        value: Binding<Float>
    ) {
        self.title = title
        self.sfSymbol = sfSymbol
        self.tintColor = tintColor
        self._value = value
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: sfSymbol)
                        .font(.system(size: 14))
                        .foregroundColor(tintColor)
                        .frame(width: 20)
                }
                
                Spacer()
                
                Text("\(Int(value * 100))%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Float($0) }
            ), in: 0.0...1.0)
            .tint(tintColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                #if os(iOS)
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.6))
                #else
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                #endif
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tintColor.opacity(value > 0.05 ? 0.35 : 0.1), lineWidth: 1)
        )
    }
}
