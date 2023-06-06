const std = @import("std");
const sound = @import("./utils/sound.zig");

const env_attack = 0.01;
const env_sustain = 0.1;
const env_release = 0.5;
const sound_length = env_attack + env_sustain + env_release;

var freq: f32 = 0;
var time_index: usize = sound.RATE * sound_length;

pub fn generate() sound.Frame {
    time_index += 1;
    const time: f32 = @intToFloat(f32, time_index) / sound.RATE;

    if (time >= sound_length) {
        return sound.Frame{ .l = 0, .r = 0 };
    }

    var env: f32 = 1;
    if (time < env_attack) {
        env = time / env_attack;
    } else if (time >= env_attack + env_sustain) {
        env -= (time - env_attack - env_sustain) / env_release;
    }

    return sound.Frame{ .l = generateSin(time * freq) * env, .r = generateSin(time * freq * 1.02) * env };
}

fn generateSin(x: f32) f32 {
    return @sin(x * std.math.pi * 2);
}

pub fn playNote(note: u8) void {
    time_index = 0;
    freq = midiNoteFrequency(note);
}

fn midiNoteFrequency(note: u8) f32 {
    const half_steps = @intToFloat(f32, note) - 69.0;
    return 440 * std.math.pow(f32, 2.0, half_steps / 12.0);
}
