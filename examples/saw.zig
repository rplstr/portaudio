const std = @import("std");
const pa = @import("portaudio");

const sample_rate = 44100;
const frames_per_buffer = 256;
const num_seconds = 4;

const AudioStream = pa.TypedStream(f32);

const TestData = struct {
    left_phase: f32 = 0.0,
    right_phase: f32 = 0.0,
};

fn sawCallback(
    input: ?[]const f32,
    output: ?[]f32,
    time_info: *const pa.StreamCallbackTimeInfo,
    status_flags: pa.StreamCallbackFlags,
    user_data: ?*anyopaque,
) pa.CallbackResult {
    _ = input;
    _ = time_info;
    _ = status_flags;

    const data = @as(*TestData, @alignCast(@ptrCast(user_data.?)));
    const out = output.?;

    var i: usize = 0;
    while (i < out.len) : (i += 2) {
        out[i] = data.left_phase;
        out[i + 1] = data.right_phase;

        data.left_phase += 0.01;
        if (data.left_phase >= 1.0) data.left_phase -= 2.0;

        data.right_phase += 0.03;
        if (data.right_phase >= 1.0) data.right_phase -= 2.0;
    }

    return .@"continue";
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    var data: TestData = .{};

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

    var stream = try AudioStream.open(&lib, null, output_params, sample_rate, frames_per_buffer, .{}, sawCallback, &data);
    defer stream.close() catch |err| std.debug.print("Error closing stream: {any}\n", .{err});

    try stream.start();

    std.debug.print("Playing sawtooth wave for {d} seconds.\n", .{num_seconds});
    std.time.sleep(num_seconds * std.time.ns_per_s);

    try stream.stop();

    std.debug.print("Test finished.\n", .{});
}
