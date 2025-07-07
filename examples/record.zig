const std = @import("std");
const pa = @import("portaudio");

const sample_rate = 44100;
const frames_per_buffer = 512;
const num_seconds = 5;
const num_channels = 1;

const pa_sample_type = f32;
const AudioStream = pa.TypedStream(pa_sample_type);

const TestData = struct {
    frame_index: usize,
    max_frame_index: usize,
    recorded_samples: []pa_sample_type,
};

fn recordCallback(
    input: ?[]const pa_sample_type,
    output: ?[]pa_sample_type,
    time_info: *const pa.StreamCallbackTimeInfo,
    status_flags: pa.StreamCallbackFlags,
    user_data: ?*anyopaque,
) pa.CallbackResult {
    _ = output;
    _ = time_info;
    _ = status_flags;

    const data = @as(*TestData, @ptrCast(@alignCast(user_data.?)));
    const rptr = input orelse return .@"continue";

    const frames_left = data.max_frame_index - data.frame_index;
    const frames_to_calc = @min(frames_left, frames_per_buffer);

    const wptr = data.recorded_samples[data.frame_index * num_channels ..];
    @memcpy(wptr[0 .. frames_to_calc * num_channels], rptr[0 .. frames_to_calc * num_channels]);

    data.frame_index += frames_to_calc;

    if (frames_left < frames_per_buffer) {
        return .complete;
    } else {
        return .@"continue";
    }
}

fn playCallback(
    input: ?[]const pa_sample_type,
    output: ?[]pa_sample_type,
    time_info: *const pa.StreamCallbackTimeInfo,
    status_flags: pa.StreamCallbackFlags,
    user_data: ?*anyopaque,
) pa.CallbackResult {
    _ = input;
    _ = time_info;
    _ = status_flags;

    const data = @as(*TestData, @ptrCast(@alignCast(user_data.?)));
    const wptr = output.?;
    const rptr = data.recorded_samples[data.frame_index * num_channels ..];

    const frames_left = data.max_frame_index - data.frame_index;
    const frames_to_calc = @min(frames_left, frames_per_buffer);

    @memcpy(wptr[0 .. frames_to_calc * num_channels], rptr[0 .. frames_to_calc * num_channels]);
    @memset(wptr[frames_to_calc * num_channels ..], 0);

    data.frame_index += frames_to_calc;

    if (frames_left < frames_per_buffer) {
        return .complete;
    } else {
        return .@"continue";
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    std.debug.print("patest_record.zig\n", .{});

    const total_frames = num_seconds * sample_rate;
    const num_samples = total_frames * num_channels;
    const recorded_samples = try allocator.alloc(pa_sample_type, num_samples);
    defer allocator.free(recorded_samples);
    @memset(recorded_samples, 0);

    var data = TestData{
        .frame_index = 0,
        .max_frame_index = total_frames,
        .recorded_samples = recorded_samples,
    };

    {
        const input_device = lib.getDefaultInputDevice();
        if (input_device == pa.no_device) {
            std.debug.print("Error: No default input device.\n", .{});
            return;
        }
        const input_params = .{ .device = input_device, .channel_count = num_channels, .suggested_latency = lib.getDeviceInfo(input_device).?.default_low_input_latency };

        std.debug.print("\n=== Now recording!! Please speak into the microphone. ===\n", .{});
        var stream = try AudioStream.open(&lib, input_params, null, sample_rate, frames_per_buffer, .{}, recordCallback, &data);
        defer stream.close() catch |err| std.debug.print("Error closing record stream: {any}\n", .{err});

        try stream.start();
        while (try stream.isActive()) {
            std.time.sleep(1 * std.time.ns_per_s);
            std.debug.print("index = {d}\n", .{data.frame_index});
        }
    }

    var max: pa_sample_type = 0;
    var average: f64 = 0.0;
    for (recorded_samples) |val_raw| {
        const val = @abs(val_raw);
        if (val > max) max = val;
        average += val;
    }
    average /= @as(f64, @floatFromInt(num_samples));
    std.debug.print("sample max amplitude = {d}\n", .{max});
    std.debug.print("sample average = {d}\n", .{average});

    data.frame_index = 0;
    {
        const output_device = lib.getDefaultOutputDevice();
        if (output_device == pa.no_device) {
            std.debug.print("Error: No default output device.\n", .{});
            return;
        }
        const output_params = .{ .device = output_device, .channel_count = num_channels, .suggested_latency = lib.getDeviceInfo(output_device).?.default_low_output_latency };

        std.debug.print("\n=== Now playing back. ===\n", .{});
        var stream = try AudioStream.open(&lib, null, output_params, sample_rate, frames_per_buffer, .{}, playCallback, &data);
        defer stream.close() catch |err| std.debug.print("Error closing playback stream: {any}\n", .{err});

        try stream.start();
        std.debug.print("Waiting for playback to finish.\n", .{});
        while (try stream.isActive()) {
            std.time.sleep(100 * std.time.ns_per_ms);
        }
    }

    std.debug.print("Done.\n", .{});
}
