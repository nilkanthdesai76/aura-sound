import SwiftUI

/// Animated audio energy visualizer reflecting live DSP output levels.
public struct WaveformVisualizer: View {
    let rmsLeft: Float
    let rmsRight: Float
    let isPlaying: Bool
    
    public init(rmsLeft: Float, rmsRight: Float, isPlaying: Bool) {
        self.rmsLeft = rmsLeft
        self.rmsRight = rmsRight
        self.isPlaying = isPlaying
    }
    
    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<16, id: \.self) { index in
                barView(index: index)
            }
        }
        .frame(height: 28)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    private func barView(index: Int) -> some View {
        let isLeft = index < 8
        let rms = isLeft ? rmsLeft : rmsRight
        let scale = isPlaying ? max(0.12, min(1.0, CGFloat(rms * Float(index % 4 + 2) * 2.2))) : 0.08
        
        return RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: isPlaying ? [Color.cyan, Color.purple] : [Color.gray.opacity(0.3)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 4, height: 24 * scale)
            .animation(.easeOut(duration: 0.08), value: scale)
    }
}
