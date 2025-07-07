const std = @import("std");
const pa = @import("portaudio");

const sample_rate = 44100;
const frames_per_buffer = 64;
const num_seconds = 10;

const AudioStream = pa.TypedStream(f32);

fn cubicAmplifier(input: f32) f32 {
    if (input < 0.0) {
        const temp = input + 1.0;
        return (temp * temp * temp) - 1.0;
    } else {
        const temp = input - 1.0;
        return (temp * temp * temp) + 1.0;
    }
}

fn fuzz(x: f32) f32 {
    return cubicAmplifier(cubicAmplifier(cubicAmplifier(cubicAmplifier(x))));
}

fn fuzzCallback(
    input: ?[]const f32,
    output: ?[]f32,
    time_info: *const pa.StreamCallbackTimeInfo,
    status_flags: pa.StreamCallbackFlags,
    user_data: ?*anyopaque,
) pa.CallbackResult {
    _ = time_info;
    _ = status_flags;
    _ = user_data;

    const out = output.?;
    if (input) |in| {
        var i: usize = 0;
        while (i < in.len) : (i += 1) {
            const sample = in[i]; // MONO input
            out[i * 2] = fuzz(sample); // left - distorted
            out[i * 2 + 1] = sample; // right - clean
        }
    } else {
        @memset(out, 0);
    }

    return .@"continue";
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    const input_device = lib.getDefaultInputDevice();
    if (input_device == pa.no_device) {
        std.debug.print("Error: No default input device.\n", .{});
        return;
    }
    const input_params = .{
        .device = input_device,
        .channel_count = 1, // mono input
        .suggested_latency = lib.getDeviceInfo(input_device).?.default_low_input_latency,
    };

    const output_device = lib.getDefaultOutputDevice();
    if (output_device == pa.no_device) {
        std.debug.print("Error: No default output device.\n", .{});
        return;
    }
    const output_params = .{
        .device = output_device,
        .channel_count = 2, // stereo output
        .suggested_latency = lib.getDeviceInfo(output_device).?.default_low_output_latency,
    };

    var stream = try AudioStream.open(&lib, input_params, output_params, sample_rate, frames_per_buffer, .{}, fuzzCallback, null);
    defer stream.close() catch |err| std.debug.print("Error closing stream: {any}\n", .{err});

    try stream.start();

    std.debug.print("Fuzzing for {d} seconds. Hit ENTER to stop program.\n", .{num_seconds});
    std.time.sleep(num_seconds * std.time.ns_per_s);

    try stream.stop();
    std.debug.print("Finished.\n", .{});
}
