const std = @import("std");
const gtk = @import("utils/gtk.zig");
const Keys = @import("utils/keys.zig").Keys;
const sound = @import("utils/sound.zig");
const config = @import("config.zig");
const synth = @import("synth.zig");
const game = @import("game.zig");

var is_fullscreen: bool = false;

fn onRender(glArea: *gtk.GtkGLArea) bool {
    const screen_width = gtk.gtk_widget_get_allocated_width(@ptrCast(*gtk.GtkWidget, glArea));
    const screen_height = gtk.gtk_widget_get_allocated_height(@ptrCast(*gtk.GtkWidget, glArea));
    game.render(screen_width, screen_height, @floatCast(f32, gtk.getTime()));
    return true;
}

fn onRealize(glArea: *gtk.GtkGLArea) void {
    gtk.gtk_gl_area_make_current(glArea);

    game.init();

    const context = gtk.gtk_gl_area_get_context(glArea);
    const glwindow = gtk.gdk_gl_context_get_window(context);
    const frame_clock = gtk.gdk_window_get_frame_clock(glwindow);
    _ = gtk.g_signal_connect_swapped_(frame_clock, "update", @ptrCast(gtk.GCallback, &gtk.gtk_gl_area_queue_render), glArea);
    gtk.gdk_frame_clock_begin_updating(frame_clock);
}

fn keyPress(gtk_widget: *gtk.GtkWidget, event: *gtk.GdkEventKeyZig) bool {
    switch (event.keyval) {
        gtk.GDK_KEY_Escape => gtk.gtk_widget_destroy(gtk_widget),
        gtk.GDK_KEY_f => {
            is_fullscreen = !is_fullscreen;
            if (is_fullscreen) {
                gtk.gtk_window_fullscreen(@ptrCast(*gtk.GtkWindow, gtk_widget));
            } else {
                gtk.gtk_window_unfullscreen(@ptrCast(*gtk.GtkWindow, gtk_widget));
            }
        },
        else => {
            game.keyPress(translateKey(event.keyval));
        },
    }

    return true;
}

fn keyRelease(gtk_widget: *gtk.GtkWidget, event: *gtk.GdkEventKeyZig) bool {
    _ = gtk_widget;
    game.keyRelease(translateKey(event.keyval), @floatCast(f32, gtk.getTime()));
    return true;
}

fn translateKey(gtk_key: u32) Keys {
    return switch (gtk_key) {
        gtk.GDK_KEY_Left, gtk.GDK_KEY_a => Keys.left,
        gtk.GDK_KEY_Up, gtk.GDK_KEY_w => Keys.up,
        gtk.GDK_KEY_Down, gtk.GDK_KEY_s => Keys.down,
        gtk.GDK_KEY_Right, gtk.GDK_KEY_d => Keys.right,
        gtk.GDK_KEY_space, gtk.GDK_KEY_Control_L, gtk.GDK_KEY_Control_R => Keys.jump,
        else => {
            if (config.DEBUG) {
                std.debug.print("Unknown key pressed: {}\n", .{gtk_key});
            }
            return Keys.unkown;
        },
    };
}

fn activate(app: *gtk.GtkApplication, _: gtk.gpointer) void {
    const window: *gtk.GtkWidget = gtk.gtk_application_window_new(app);

    const gl_area: *gtk.GtkWidget = gtk.gtk_gl_area_new();
    gtk.gtk_container_add(@ptrCast(*gtk.GtkContainer, window), gl_area);

    _ = gtk.g_signal_connect_(gl_area, "realize", @ptrCast(gtk.GCallback, &onRealize), null);
    _ = gtk.g_signal_connect_(gl_area, "render", @ptrCast(gtk.GCallback, &onRender), null);

    const w = @ptrCast(*gtk.GtkWindow, window);
    gtk.gtk_window_set_title(w, "Zig Micro Game");

    gtk.gtk_window_set_default_size(w, 800, 600);
    if (is_fullscreen) {
        gtk.gtk_window_fullscreen(w);
    }

    _ = gtk.g_signal_connect_(window, "key_press_event", @ptrCast(gtk.GCallback, &keyPress), null);
    _ = gtk.g_signal_connect_(window, "key_release_event", @ptrCast(gtk.GCallback, &keyRelease), null);

    gtk.gtk_widget_show_all(window);
}

pub fn main() !u8 {
    if (config.ENABLE_SOUND) try sound.init(synth.generate);
    defer {
        if (config.ENABLE_SOUND) sound.deinit();
    }

    var app = gtk.gtk_application_new("zig.micro.game", gtk.G_APPLICATION_FLAGS_NONE);
    defer gtk.g_object_unref(app);
    _ = gtk.g_signal_connect_(app, "activate", @ptrCast(gtk.GCallback, &activate), null);
    const status: i32 = gtk.g_application_run(@ptrCast(*gtk.GApplication, app), 0, null);
    return @intCast(u8, status);
}
