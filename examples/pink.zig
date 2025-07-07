const std = @import("std");
const pa = @import("portaudio");

const max_random_rows = 30;
const random_bits = 24;
// @sizeOf(c_long) * 8 - random_bits
const random_shift = 32 - random_bits;

const AudioStream = pa.TypedStream(f32);

const Lcg = struct {
    seed: u32 = 22222,

    fn next(self: *Lcg) u32 {
        self.seed = self.seed *% 196314165 +% 907633515;
        return self.seed;
    }
};

var lcg: Lcg = .{};

const PinkNoise = struct {
    rows: [max_random_rows]c_long,
    running_sum: c_long,
    index: c_int,
    index_mask: c_int,
    scalar: f32,

    pub fn init(num_rows: c_int) PinkNoise {
        const pmax = (num_rows + 1) * (1 << (random_bits - 1));
        return .{
            .rows = [_]c_long{0} ** max_random_rows,
            .running_sum = 0,
            .index = 0,
            .index_mask = (@as(c_int, 1) << @as(u5, @intCast(num_rows))) - 1,
            .scalar = 1.0 / @as(f32, @floatFromInt(pmax)),
        };
    }

    pub fn nextSample(self: *PinkNoise) f32 {
        self.index = (self.index + 1) & self.index_mask;

        if (self.index != 0) {
            var num_zeros: u32 = 0;
            var n = self.index;
            while ((n & 1) == 0) {
                n >>= 1;
                num_zeros += 1;
            }

            self.running_sum -= self.rows[num_zeros];
            const new_random = @as(c_long, @intCast(lcg.next() >> random_shift));
            self.running_sum += new_random;
            self.rows[num_zeros] = new_random;
        }

        const new_random = @as(c_long, @intCast(lcg.next() >> random_shift));
        const sum = self.running_sum + new_random;
        return self.scalar * @as(f32, @floatFromInt(sum));
    }
};

const TestData = struct {
    left_pink: PinkNoise,
    right_pink: PinkNoise,
};

fn pinkCallback(
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
        out[i] = data.left_pink.nextSample();
        out[i + 1] = data.right_pink.nextSample();
    }

    return .@"continue";
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lib = try pa.init(allocator);
    defer lib.deinit();

    var data = TestData{
        .left_pink = PinkNoise.init(12),
        .right_pink = PinkNoise.init(16),
    };

    const sample_rate = 44100.0;
    const frames_per_buffer = 2048;

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

    var stream = try AudioStream.open(&lib, null, output_params, sample_rate, frames_per_buffer, .{}, pinkCallback, &data);
    defer stream.close() catch |err| std.debug.print("Error closing stream: {any}\n", .{err});

    try stream.start();

    std.debug.print("Stereo pink noise for 10 seconds...\n", .{});
    std.time.sleep(10 * std.time.ns_per_s);

    try stream.stop();

    std.debug.print("Test finished.\n", .{});
}
