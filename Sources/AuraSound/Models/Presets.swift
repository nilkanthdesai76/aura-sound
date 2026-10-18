import Foundation

/// Curated soundscape presets for deep work, relaxation, and focus.
public struct SoundPreset: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let sfSymbol: String
    public let description: String
    
    public let rainIntensity: Float
    public let rainResonance: Float
    public let thunderIntensity: Float
    public let fireIntensity: Float
    public let windIntensity: Float
    public let binauralVolume: Float
    public let binauralWave: BinauralWaveType
    
    public static let all: [SoundPreset] = [
        SoundPreset(
            id: "deep_focus",
            title: "Deep Flow",
            sfSymbol: "brain.head.profile",
            description: "Gentle rain and soft wind paired with Alpha (10Hz) waves for coding flow.",
            rainIntensity: 0.60,
            rainResonance: 2200.0,
            thunderIntensity: 0.0,
            fireIntensity: 0.0,
            windIntensity: 0.25,
            binauralVolume: 0.30,
            binauralWave: .alpha
        ),
        SoundPreset(
            id: "midnight_storm",
            title: "Midnight Storm",
            sfSymbol: "cloud.bolt.rain.fill",
            description: "Heavy rain on a tin roof with deep, rolling thunder for ambient masking.",
            rainIntensity: 0.85,
            rainResonance: 3600.0,
            thunderIntensity: 0.60,
            fireIntensity: 0.0,
            windIntensity: 0.45,
            binauralVolume: 0.0,
            binauralWave: .beta
        ),
        SoundPreset(
            id: "cozy_campfire",
            title: "Cabin Fireplace",
            sfSymbol: "flame.fill",
            description: "Warm wood crackles and gentle distant rain with calming Theta waves.",
            rainIntensity: 0.30,
            rainResonance: 2000.0,
            thunderIntensity: 0.0,
            fireIntensity: 0.75,
            windIntensity: 0.15,
            binauralVolume: 0.20,
            binauralWave: .theta
        ),
        SoundPreset(
            id: "hyper_focus",
            title: "Hyper-Focus",
            sfSymbol: "bolt.fill",
            description: "Aerodynamic mountain wind and Gamma (40Hz) waves for complex problem solving.",
            rainIntensity: 0.20,
            rainResonance: 2800.0,
            thunderIntensity: 0.0,
            fireIntensity: 0.0,
            windIntensity: 0.65,
            binauralVolume: 0.40,
            binauralWave: .gamma
        )
    ]
}
