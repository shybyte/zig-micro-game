// Inspired by https://github.com/Swoogan/ziggtk/blob/master/src/gtk.zig

pub usingnamespace @cImport({
    @cInclude("gtk/gtk.h");
});

const c = @cImport({
    @cInclude("gtk/gtk.h");
});

/// Could not get `g_signal_connect` to work. Zig says "use of undeclared identifier". Reimplemented here
pub fn g_signal_connect_(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) c.gulong {
    var zero: u32 = 0;
    const flags: *c.GConnectFlags = @ptrCast(*c.GConnectFlags, &zero);
    return c.g_signal_connect_data(instance, detailed_signal, c_handler, data, null, flags.*);
}

/// Could not get `g_signal_connect_swapped` to work. Zig says "use of undeclared identifier". Reimplemented here
pub fn g_signal_connect_swapped_(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) c.gulong {
    return c.g_signal_connect_data(instance, detailed_signal, c_handler, data, null, c.G_CONNECT_SWAPPED);
}

// GdkEventKey has a bitfield, so it can't be parsed by Zig.
// we'll define it ourselves, but ignore the bitfield
// See https://github.com/spazzylemons/zofi/blob/bf4a211e2c993289d425e6d17adb243faf2b7f6b/src/Launcher.zig
pub const GdkEventKeyZig = extern struct {
    type: c.GdkEventType,
    window: *c.GdkWindow,
    send_event: c.gint8,
    time: c.guint32,
    state: c.GdkModifierType,
    keyval: c.guint,
    length: c.gint,
    string: [*:0]c.gchar,
    hardware_keycode: c.guint16,
    group: c.guint8,
};

var start_time: ?c_long = null;

/// Returns the time since program start in seconds.
pub fn getTime() f64 {
    const time = c.g_get_monotonic_time();
    if (start_time) |start_time_2| {
        return @intToFloat(f64, time - start_time_2) / 1_000_000;
    } else {
        start_time = time;
        return 0;
    }
}
