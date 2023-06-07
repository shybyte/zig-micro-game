//! Play sounds on ALSA
//! Inspired by https://github.com/mjrosenkranz/beatbox and https://github.com/hazeycode/zig-alsa

const math = @import("std").math;
const std = @import("std");
const config = @import("../config.zig");

const c = @cImport({
    @cInclude("alsa/asoundlib.h");
    @cDefine("ALSA_PCM_NEW_HW_PARAMS_API", "1");
});

const AlsaError = error{
    FailedToOpen,
    FailedToSetHardware,
};

const alloc = std.heap.page_allocator;

const PLAYBACK = 0;
const RW_INTERLEAVED = 3;
const S16_LE = 2;
const CHANNELS = 2;
pub const RATE = 44100;
const FRAMES = 256;
const BLOCKS = 4;

const Output = struct {
    handle: ?*c.snd_pcm_t = null,
    buffer: []i16 = undefined,
    user_fn: *const fn () Frame,
    thread: std.Thread = undefined,
    running: bool = true,

    const Self = @This();

    fn validate(err: c_int) void {
        if (config.DEBUG and err < 0) {
            std.debug.print("Alsa error: {s}\n", .{c.snd_strerror(err)});
        }
    }

    pub fn setup(self: *Self) !void {
        if (c.snd_pcm_open(&self.handle, "default", PLAYBACK, 0) != 0) {
            if (config.DEBUG) {
                std.log.err("Error to open ALSA", .{});
            }
            return AlsaError.FailedToOpen;
        }

        var params: ?*c.snd_pcm_hw_params_t = null;
        validate(c.snd_pcm_hw_params_malloc(&params));
        validate(c.snd_pcm_hw_params_any(self.handle, params));
        validate(c.snd_pcm_hw_params_set_access(self.handle, params, RW_INTERLEAVED));
        validate(c.snd_pcm_hw_params_set_format(self.handle, params, S16_LE));
        validate(c.snd_pcm_hw_params_set_channels(self.handle, params, CHANNELS));
        validate(c.snd_pcm_hw_params_set_rate(self.handle, params, RATE, 0));
        validate(c.snd_pcm_hw_params_set_periods(self.handle, params, BLOCKS, 0));
        validate(c.snd_pcm_hw_params_set_period_size(self.handle, params, FRAMES, 0));

        const rc = c.snd_pcm_hw_params(self.handle, params);
        if (rc < 0) {
            if (config.DEBUG) {
                std.log.err("unable to set hw parameters: {s}", .{c.snd_strerror(rc)});
            }
            return AlsaError.FailedToSetHardware;
        }

        self.buffer = try alloc.alloc(i16, FRAMES * CHANNELS);
        self.thread = try std.Thread.spawn(.{}, loop, .{self});
    }

    fn loop(self: *Self) void {
        while (self.running) {
            var i: usize = 0;
            while (i < FRAMES * CHANNELS) : (i += 1) {
                var f = self.user_fn().clip();
                self.buffer[i] = @floatToInt(i16, f.l * 32767);
                i += 1;
                self.buffer[i] = @floatToInt(i16, f.r * 32767);
            }

            const written = c.snd_pcm_writei(self.handle, &self.buffer[0], FRAMES);

            if (written < 0) {
                _ = c.snd_pcm_prepare(self.handle);
                if (config.DEBUG) {
                    std.log.err("underrun", .{});
                }
            }
        }
    }

    pub fn deinit(self: *Self) void {
        self.running = false;
        self.thread.join();
        alloc.free(self.buffer);
        _ = c.snd_pcm_drain(self.handle);
        _ = c.snd_pcm_close(self.handle);
    }
};

pub const Frame = struct {
    l: f32 = 0.0,
    r: f32 = 0.0,

    const Self = @This();

    pub fn mul(self: Self, val: f32) Self {
        return .{
            .l = self.l * val,
            .r = self.r * val,
        };
    }

    pub fn clip(self: Self) Self {
        return .{
            .l = math.clamp(self.l, -1, 1),
            .r = math.clamp(self.r, -1, 1),
        };
    }
};

var sound_output: Output = undefined;

pub fn init(generate: *const fn () Frame) anyerror!void {
    sound_output = Output{
        .user_fn = generate,
    };

    try sound_output.setup();
}

pub fn deinit() void {
    sound_output.deinit();
}
