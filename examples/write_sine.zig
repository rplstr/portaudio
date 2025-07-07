const std = @import("std");
const pa = @import("portaudio");

const num_seconds = 5;
const sample_rate = 44100;
const frames_per_buffer = 1024;
const table_size = 200;
const channels = 2;

const AudioStream = pa.TypedStream(f32);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    std.debug.print("PortAudio Test: output sine wave using blocking write. SR = {d}, BufSize = {d}\n", .{ sample_rate, frames_per_buffer });

    var sine: [table_size]f32 = undefined;
    for (&sine, 0..) |*s, i| {
        s.* = @sin(@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(table_size)) * std.math.pi * 2.0);
    }

    const output_device = lib.getDefaultOutputDevice();
    if (output_device == pa.no_device) {
        std.debug.print("Error: No default output device.\n", .{});
        return;
    }

    const output_params = .{
        .device = output_device,
        .channel_count = channels,
        .suggested_latency = lib.getDeviceInfo(output_device).?.default_low_output_latency,
    };

    var stream = try AudioStream.open(&lib, null, output_params, sample_rate, frames_per_buffer, .{}, null, null);
    defer stream.close() catch |err| std.debug.print("Error closing stream: {any}\n", .{err});

    var left_phase: usize = 0;
    var right_phase: usize = 0;
    var left_inc: usize = 1;
    var right_inc: usize = 3;

    const buffer_len = frames_per_buffer * channels;
    var buffer = try allocator.alloc(f32, buffer_len);
    defer allocator.free(buffer);

    std.debug.print("Play 3 times, higher each time.\n", .{});

    var k: u32 = 0;
    while (k < 3) : (k += 1) {
        try stream.start();
        std.debug.print("Play for {d} seconds.\n", .{num_seconds});

        const buffer_count = (num_seconds * sample_rate) / frames_per_buffer;
        var i: u32 = 0;
        while (i < buffer_count) : (i += 1) {
            var j: usize = 0;
            while (j < buffer.len) : (j += channels) {
                buffer[j] = sine[left_phase];
                left_phase += left_inc;
                if (left_phase >= table_size) left_phase -= table_size;

                if (channels == 2) {
                    buffer[j + 1] = sine[right_phase];
                    right_phase += right_inc;
                    if (right_phase >= table_size) right_phase -= table_size;
                }
            }
            try stream.write(buffer);
        }

        try stream.stop();

        left_inc += 1;
        right_inc += 1;
        std.time.sleep(1 * std.time.ns_per_s);
    }

    std.debug.print("Test finished.\n", .{});
}
