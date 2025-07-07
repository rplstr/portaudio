const std = @import("std");
const pa = @import("portaudio");

fn printSupportedStandardSampleRates(
    lib: *const pa.Lib,
    input_params: ?pa.StreamParameters,
    output_params: ?pa.StreamParameters,
) void {
    const standard_sample_rates = [_]f64{
        8000.0,  9600.0,  11025.0, 12000.0, 16000.0,  22050.0, 24000.0, 32000.0,
        44100.0, 48000.0, 88200.0, 96000.0, 192000.0,
    };

    var print_count: u32 = 0;
    for (standard_sample_rates) |rate| {
        if (lib.isFormatSupported(input_params, output_params, rate)) {
            if (print_count == 0) {
                std.debug.print("\t{d:.2}", .{rate});
                print_count = 1;
            } else if (print_count == 4) {
                std.debug.print(",\n\t{d:.2}", .{rate});
                print_count = 1;
            } else {
                std.debug.print(", {d:.2}", .{rate});
                print_count += 1;
            }
        }
    }

    if (print_count == 0) {
        std.debug.print("None\n", .{});
    } else {
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    const version_info = pa.getVersionInfo();
    std.debug.print("PortAudio version: 0x{X:0>8}\n", .{pa.getVersion()});
    std.debug.print("Version text: '{s}'\n", .{version_info.text});

    var device_iterator = try lib.devices();
    std.debug.print("Number of devices = {d}\n", .{device_iterator.count});

    while (device_iterator.next()) |device_info| {
        const i = device_iterator.index - 1;
        std.debug.print("--------------------------------------- device #{d}\n", .{i});

        var default_displayed = false;
        if (i == lib.getDefaultInputDevice()) {
            std.debug.print("[ Default Input", .{});
            default_displayed = true;
        } else if (i == lib.getHostApiInfo(device_info.host_api).?.default_input_device) {
            const host_info = lib.getHostApiInfo(device_info.host_api).?;
            std.debug.print("[ Default {s} Input", .{host_info.name});
            default_displayed = true;
        }

        if (i == lib.getDefaultOutputDevice()) {
            if (default_displayed) {
                std.debug.print(", ", .{});
            } else {
                std.debug.print("[", .{});
            }
            std.debug.print("Default Output", .{});
            default_displayed = true;
        } else if (i == lib.getHostApiInfo(device_info.host_api).?.default_output_device) {
            const host_info = lib.getHostApiInfo(device_info.host_api).?;
            if (default_displayed) {
                std.debug.print(", ", .{});
            } else {
                std.debug.print("[", .{});
            }
            std.debug.print("Default {s} Output", .{host_info.name});
            default_displayed = true;
        }

        if (default_displayed) {
            std.debug.print(" ]\n", .{});
        }

        std.debug.print("Name                        = {s}\n", .{device_info.name});
        std.debug.print("Host API                    = {s}\n", .{lib.getHostApiInfo(device_info.host_api).?.name});
        std.debug.print("Max inputs = {d}, Max outputs = {d}\n", .{ device_info.max_input_channels, device_info.max_output_channels });
        std.debug.print("Default low input latency   = {d:.4}\n", .{device_info.default_low_input_latency});
        std.debug.print("Default low output latency  = {d:.4}\n", .{device_info.default_low_output_latency});
        std.debug.print("Default high input latency  = {d:.4}\n", .{device_info.default_high_input_latency});
        std.debug.print("Default high output latency = {d:.4}\n", .{device_info.default_high_output_latency});
        std.debug.print("Default sample rate         = {d:.2}\n", .{device_info.default_sample_rate});

        const input_params: pa.StreamParameters = .{
            .device = i,
            .channel_count = device_info.max_input_channels,
            .sample_format = .{ .int16 = true },
            .suggested_latency = 0, // ignored by isFormatSupported
        };

        const output_params: pa.StreamParameters = .{
            .device = i,
            .channel_count = device_info.max_output_channels,
            .sample_format = .{ .int16 = true },
            .suggested_latency = 0, // ignored by isFormatSupported
        };

        if (input_params.channel_count > 0) {
            std.debug.print("Supported standard sample rates\n for half-duplex 16 bit {d} channel input = \n", .{input_params.channel_count});
            printSupportedStandardSampleRates(&lib, input_params, null);
        }

        if (output_params.channel_count > 0) {
            std.debug.print("Supported standard sample rates\n for half-duplex 16 bit {d} channel output = \n", .{output_params.channel_count});
            printSupportedStandardSampleRates(&lib, null, output_params);
        }

        if (input_params.channel_count > 0 and output_params.channel_count > 0) {
            std.debug.print("Supported standard sample rates\n for full-duplex 16 bit {d} channel input, {d} channel output = \n", .{ input_params.channel_count, output_params.channel_count });
            printSupportedStandardSampleRates(&lib, input_params, output_params);
        }
    }

    std.debug.print("----------------------------------------------\n", .{});
}
