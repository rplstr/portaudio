const std = @import("std");
const pa = @import("portaudio");

const sample_rate = 44100;
const frames_per_buffer = 64;
const num_seconds = 5;
const table_size = 200;

const SineStream = pa.TypedStream(f32);

const TestData = struct {
    sine: [table_size]f32,
    left_phase: u32,
    right_phase: u32,
    message: [20]u8,
};

fn streamFinished(user_data: ?*anyopaque) void {
    const data = @as(*TestData, @ptrCast(@alignCast(user_data.?)));
    std.debug.print("Stream Completed: {s}\n", .{data.message});
}

fn patestCallback(
    input: ?[]const f32,
    output: ?[]f32,
    time_info: *const pa.StreamCallbackTimeInfo,
    status_flags: pa.StreamCallbackFlags,
    user_data: ?*anyopaque,
) pa.CallbackResult {
    _ = input;
    _ = time_info;
    _ = status_flags;

    const data = @as(*TestData, @ptrCast(@alignCast(user_data.?)));
    const out = output.?;

    var i: usize = 0;
    while (i < out.len) : (i += 2) {
        out[i] = data.sine[data.left_phase];
        out[i + 1] = data.sine[data.right_phase];

        data.left_phase += 1;
        if (data.left_phase >= table_size) {
            data.left_phase -= table_size;
        }
        data.right_phase += 3; // higher pitch so we can distinguish
        if (data.right_phase >= table_size) {
            data.right_phase -= table_size;
        }
    }

    return .@"continue";
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    std.debug.print("PortAudio Test: output sine wave. SR = {d}, BufSize = {d}\n", .{ sample_rate, frames_per_buffer });

    var data: TestData = .{
        .sine = undefined,
        .left_phase = 0,
        .right_phase = 0,
        .message = undefined,
    };

    for (&data.sine, 0..) |*s, i| {
        s.* = @sin(@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(table_size)) * std.math.pi * 2.0);
    }

    const output_device = lib.getDefaultOutputDevice();
    if (output_device == pa.no_device) {
        std.debug.print("Error: No default output device.\n", .{});
        return;
    }

    const output_params = .{
        .device = output_device,
        .channel_count = 2,
        .suggested_latency = lib.getDeviceInfo(output_device).?.default_low_output_latency,
    };

    var stream = try SineStream.open(&lib, null, output_params, sample_rate, frames_per_buffer, .{}, patestCallback, &data);
    defer stream.close() catch |err| std.debug.print("failed to close stream: {any}\n", .{err});

    @memcpy(&data.message, "No Message\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00");
    try stream.setFinishedCallback(streamFinished, &data);

    try stream.start();

    std.debug.print("Play for {d} seconds.\n", .{num_seconds});
    std.time.sleep(num_seconds * std.time.ns_per_s);

    try stream.stop();

    std.debug.print("Test finished.\n", .{});
}
