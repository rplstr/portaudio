const std = @import("std");
const pa = @import("portaudio");

const sample_rate = 44100;
const frames_per_buffer = 512;
const num_seconds = 10;
const sample_type = f32;

const AudioStream = pa.TypedStream(sample_type);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    std.debug.print("read_write_wire.zig\n", .{});

    const input_device = lib.getDefaultInputDevice();
    if (input_device == pa.no_device) {
        std.debug.print("Error: No default input device found.\n", .{});
        return;
    }
    const output_device = lib.getDefaultOutputDevice();
    if (output_device == pa.no_device) {
        std.debug.print("Error: No default output device found.\n", .{});
        return;
    }

    const input_info = lib.getDeviceInfo(input_device).?;
    const output_info = lib.getDeviceInfo(output_device).?;

    const num_channels = @min(input_info.max_input_channels, output_info.max_output_channels);
    std.debug.print("Num channels = {d}.\n", .{num_channels});

    const input_params = .{
        .device = input_device,
        .channel_count = num_channels,
        .suggested_latency = input_info.default_high_input_latency,
    };
    const output_params = .{
        .device = output_device,
        .channel_count = num_channels,
        .suggested_latency = output_info.default_high_output_latency,
    };

    var stream = try AudioStream.open(&lib, input_params, output_params, sample_rate, frames_per_buffer, .{}, null, null);
    defer stream.close() catch |err| std.debug.print("Error closing stream: {any}\n", .{err});

    const buffer_size = frames_per_buffer * @as(usize, @intCast(num_channels));
    const sample_buffer = try allocator.alloc(sample_type, buffer_size);
    defer allocator.free(sample_buffer);

    try stream.start();
    std.debug.print("Wire on. Will run for {d} seconds.\n", .{num_seconds});

    const num_iterations = (num_seconds * sample_rate) / frames_per_buffer;
    for (0..num_iterations) |_| {
        try stream.read(sample_buffer);
        try stream.write(sample_buffer);
    }

    std.debug.print("Wire off.\n", .{});
    try stream.stop();
}
