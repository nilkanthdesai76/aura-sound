import SwiftUI
import Combine

/// Main macOS ambient soundscape dashboard for AuraSound.
public struct MainView: View {
    @State private var engine = AuraSoundEngine.shared
    
    // UI reactive bindings
    @State private var isPlaying: Bool = false
    @State private var rain: Float = 0.65
    @State private var rainResonance: Float = 2400.0
    @State private var thunder: Float = 0.25
    @State private var fire: Float = 0.40
    @State private var wind: Float = 0.30
    @State private var binaural: Float = 0.20
    @State private var waveType: BinauralWaveType = .alpha
    @State private var masterVolume: Float = 0.80
    
    // Telemetry timer for waveform display
    @State private var rmsLeft: Float = 0.0
    @State private var rmsRight: Float = 0.0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            headerView
            
            presetsView
            
            Divider()
                .opacity(0.3)
            
            ScrollView {
                VStack(spacing: 12) {
                    SoundSliderView(
                        title: "Rainfall",
                        sfSymbol: "cloud.rain.fill",
                        tintColor: .cyan,
                        value: $rain
                    )
                    .onChange(of: rain) { engine.parameters.rainIntensity = rain }
                    
                    SoundSliderView(
                        title: "Rolling Thunder",
                        sfSymbol: "cloud.bolt.fill",
                        tintColor: .purple,
                        value: $thunder
                    )
                    .onChange(of: thunder) { engine.parameters.thunderIntensity = thunder }
                    
                    if thunder > 0.05 {
                        HStack {
                            Spacer()
                            Button {
                                engine.triggerThunder()
                            } label: {
                                Label("Trigger Thunder Strike", systemImage: "bolt.fill")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .buttonStyle(.bordered)
                            .tint(.purple)
                            .controlSize(.small)
                        }
                        .transition(.opacity)
                    }
                    
                    SoundSliderView(
                        title: "Campfire Crackle",
                        sfSymbol: "flame.fill",
                        tintColor: .orange,
                        value: $fire
                    )
                    .onChange(of: fire) { engine.parameters.fireIntensity = fire }
                    
                    SoundSliderView(
                        title: "Mountain Wind",
                        sfSymbol: "wind",
                        tintColor: .mint,
                        value: $wind
                    )
                    .onChange(of: wind) { engine.parameters.windIntensity = wind }
                    
                    binauralCard
                    
                    SoundSliderView(
                        title: "Master Output",
                        sfSymbol: "speaker.wave.3.fill",
                        tintColor: .primary,
                        value: $masterVolume
                    )
                    .onChange(of: masterVolume) { engine.parameters.masterVolume = masterVolume }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .frame(width: 360, height: 580)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            syncFromEngine()
        }
        .onReceive(timer) { _ in
            rmsLeft = engine.currentRmsLeft
            rmsRight = engine.currentRmsRight
            isPlaying = engine.parameters.isPlaying
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("AuraSound")
                    .font(.system(size: 18, weight: .bold))
                Text("100% Procedural Audio DSP")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            WaveformVisualizer(rmsLeft: rmsLeft, rmsRight: rmsRight, isPlaying: isPlaying)
            
            Button {
                do {
                    try engine.togglePlayPause()
                    isPlaying = engine.parameters.isPlaying
                } catch {
                    print("Engine error: \(error)")
                }
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isPlaying ? .cyan : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
    
    private var presetsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SoundPreset.all) { preset in
                    Button {
                        engine.apply(preset: preset)
                        syncFromEngine()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: preset.sfSymbol)
                                .font(.system(size: 11))
                            Text(preset.title)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var binauralCard: some View {
        VStack(spacing: 8) {
            SoundSliderView(
                title: "Binaural Beats",
                sfSymbol: "brain.head.profile",
                tintColor: .pink,
                value: $binaural
            )
            .onChange(of: binaural) { engine.parameters.binauralVolume = binaural }
            
            Picker("Brainwave Target", selection: $waveType) {
                ForEach(BinauralWaveType.allCases) { wave in
                    Text(wave.rawValue).tag(wave)
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: 11))
            .padding(.horizontal, 8)
            .onChange(of: waveType) {
                engine.parameters.binauralWaveType = waveType
            }
        }
    }
    
    private func syncFromEngine() {
        let snap = engine.parameters.snapshot()
        rain = snap.rainIntensity
        rainResonance = snap.rainSurfaceResonance
        thunder = snap.thunderIntensity
        fire = snap.fireIntensity
        wind = snap.windIntensity
        binaural = snap.binauralVolume
        waveType = snap.binauralWaveType
        masterVolume = snap.masterVolume
        isPlaying = snap.isPlaying
    }
}
