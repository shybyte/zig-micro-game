const std = @import("std");
const sound = @import("./utils/sound.zig");

const OscType = enum { sin, saw };

pub const Instrument = struct {
    env_attack: f32 = 0.01,
    env_sustain: f32 = 0.1,
    env_release: f32 = 1.0,
    osc_type: OscType = OscType.sin,
    stereo_freq_delta: f32 = 0.0,
};

pub const Voice = struct {
    instrument: Instrument = .{},
    time_index: usize = 0,
    freq: f32 = 440,
    on: bool = false,
};

var voices: [2]Voice = .{
    Voice{ .instrument = .{ .osc_type = OscType.sin, .stereo_freq_delta = 0.01 } },
    Voice{ .instrument = .{ .osc_type = OscType.saw } },
};

var global_time_index: usize = 0;
const song_speed = 4;
const base_notes: [4]u8 = [_]u8{ 69, 77, 72, 79 };

pub fn generate() sound.Frame {
    var result: sound.Frame = .{};

    if (@mod(global_time_index, sound.RATE / song_speed) == 0) {
        const note_index = global_time_index / (sound.RATE / song_speed);
        const base_note = base_notes[(note_index / 8) % base_notes.len];
        playNote(1, @intCast(u8, base_note - 12 * 3 + (note_index % 2 * 12)));
    }

    for (voices) |*voice| {
        if (!voice.on) {
            continue;
        }

        const instrument = voice.instrument;

        const time: f32 = @intToFloat(f32, voice.time_index) / sound.RATE;

        if (time > instrument.env_attack + instrument.env_sustain + instrument.env_release) {
            voice.on = false;
            continue;
        }

        var env: f32 = 1;
        if (time < instrument.env_attack) {
            env = time / instrument.env_attack;
        } else if (time >= instrument.env_attack + instrument.env_sustain) {
            env -= (time - instrument.env_attack - instrument.env_sustain) / instrument.env_release;
        }

        result.l += generateOsc(instrument.osc_type, time * voice.freq * (1 - instrument.stereo_freq_delta)) * env;
        result.r += generateOsc(instrument.osc_type, time * voice.freq * (1 + instrument.stereo_freq_delta)) * env;

        voice.time_index += 1;
    }

    global_time_index += 1;

    return result.mul(0.5);
}

fn generateOsc(osc_type: OscType, time: f32) f32 {
    return switch (osc_type) {
        .sin => generateSin(time),
        .saw => generateSaw(time),
    };
}

fn generateSin(x: f32) f32 {
    return @sin(x * std.math.pi * 2);
}

fn generateSaw(x: f32) f32 {
    return @mod(x, 1) - 0.5;
}

pub fn playNote(voice_index: usize, note: u8) void {
    var voice = &voices[voice_index];
    voice.on = true;
    voice.time_index = 0;
    voice.freq = midiNoteFrequency(note);
}

fn midiNoteFrequency(note: u8) f32 {
    const half_steps = @intToFloat(f32, note) - 69.0;
    return 440 * std.math.pow(f32, 2.0, half_steps / 12.0);
}
