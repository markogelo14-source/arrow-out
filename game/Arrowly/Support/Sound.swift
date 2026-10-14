import AVFoundation

/// Short sound effects, synthesized in code so there are no audio files to ship or license.
/// Uses the ambient audio session: it respects the silent switch and mixes with the player's music.
/// Switched off by the Settings toggle.
@MainActor
enum Sound {
    static let enabledKey = "soundEnabled"

    private static var enabled: Bool {
        UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    }

    /// An arrow slides off the board.
    static func tap() { play(\.tick) }

    /// An arrow bumps into another one.
    static func blocked() { play(\.thud) }

    /// The board is cleared.
    static func win() { play(\.chime) }

    private static func play(_ sound: KeyPath<Synth, AVAudioPCMBuffer>) {
        guard enabled, let synth = Synth.shared else { return }
        synth.play(synth[keyPath: sound])
    }
}

/// A tiny audio engine with a few player voices, so quick taps can overlap.
@MainActor
private final class Synth {
    static let shared = Synth()

    private let engine = AVAudioEngine()
    private let format: AVAudioFormat
    private var voices: [AVAudioPlayerNode] = []
    private var nextVoice = 0

    let tick: AVAudioPCMBuffer
    let thud: AVAudioPCMBuffer
    let chime: AVAudioPCMBuffer

    private init?() {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { return nil }
        self.format = format
        tick = Self.tone(format, notes: [(1_320, 0, 0.045)], volume: 0.18, decay: 70)
        thud = Self.tone(format, notes: [(150, 0, 0.14), (95, 0, 0.14)], volume: 0.35, decay: 22)
        // C6, E6, G6 as a quick rising arpeggio.
        chime = Self.tone(format, notes: [(1_047, 0, 0.5), (1_319, 0.08, 0.5), (1_568, 0.16, 0.6)], volume: 0.14, decay: 6)

        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        for _ in 0..<4 {
            let voice = AVAudioPlayerNode()
            engine.attach(voice)
            engine.connect(voice, to: engine.mainMixerNode, format: format)
            voices.append(voice)
        }
    }

    func play(_ buffer: AVAudioPCMBuffer) {
        // The engine stops after interruptions such as a phone call, so restart it on demand.
        if !engine.isRunning {
            try? AVAudioSession.sharedInstance().setActive(true)
            do { try engine.start() } catch { return }
        }
        let voice = voices[nextVoice]
        nextVoice = (nextVoice + 1) % voices.count
        voice.stop()
        voice.scheduleBuffer(buffer)
        voice.play()
    }

    /// Mixes sine notes, each `(frequency, start, length)` in seconds, with an exponential fade.
    private static func tone(
        _ format: AVAudioFormat, notes: [(Double, Double, Double)], volume: Float, decay: Double
    ) -> AVAudioPCMBuffer {
        let rate = format.sampleRate
        let total = notes.map { $0.1 + $0.2 }.max() ?? 0
        let frames = AVAudioFrameCount(total * rate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let samples = buffer.floatChannelData![0]
        for i in 0..<Int(frames) { samples[i] = 0 }

        for (frequency, start, length) in notes {
            let first = Int(start * rate)
            let count = Int(length * rate)
            for i in 0..<count where first + i < Int(frames) {
                let t = Double(i) / rate
                // A 3 ms fade-in avoids a click at the start of each note.
                let attack = min(t / 0.003, 1)
                let envelope = attack * exp(-decay * t)
                samples[first + i] += Float(sin(2 * .pi * frequency * t) * envelope) * volume
            }
        }
        return buffer
    }
}
