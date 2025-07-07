const std = @import("std");
const log = std.log;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const win_host = b.option(
        WinHost,
        "win-host",
        "Windows PortAudio Host API (wasapi, dsound, mme, wdmks)",
    ) orelse .wasapi;

    const linux_host = b.option(
        LinuxHost,
        "linux-host",
        "Linux PortAudio Host API (alsa, jack, oss)",
    ) orelse .alsa;

    const pa_config = PaConfig{
        .win_host = win_host,
        .linux_host = linux_host,
    };

    const pa_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    pa_module.addIncludePath(b.path("portaudio/include"));
    pa_module.addIncludePath(b.path("portaudio/src/common"));
    configurePaSources(b, pa_module, target, pa_config);
    pa_module.addCSourceFiles(.{
        .files = &.{
            "portaudio/src/common/pa_allocation.c",
            "portaudio/src/common/pa_converters.c",
            "portaudio/src/common/pa_cpuload.c",
            "portaudio/src/common/pa_debugprint.c",
            "portaudio/src/common/pa_dither.c",
            "portaudio/src/common/pa_front.c",
            "portaudio/src/common/pa_process.c",
            "portaudio/src/common/pa_ringbuffer.c",
            "portaudio/src/common/pa_stream.c",
            "portaudio/src/common/pa_trace.c",
        },
    });

    const pa_lib = b.addLibrary(.{
        .name = "portaudio",
        .root_module = pa_module,
        .linkage = .static,
    });

    const pa_zig_module = b.createModule(.{
        .root_source_file = b.path("portaudio.zig"),
        .target = target,
        .optimize = optimize,
    });

    pa_zig_module.linkLibrary(pa_lib);
    pa_zig_module.addIncludePath(b.path("portaudio/include"));

    const pa_zig_lib = b.addLibrary(.{
        .name = "zig-portaudio",
        .root_module = pa_zig_module,
        .linkage = .static,
    });

    const devs_run = addExample(b, "devs", pa_zig_lib, target, optimize, pa_config);
    const devs_run_step = b.step("run-devs", "Run the device lister example");
    devs_run_step.dependOn(&devs_run.step);

    const sine_run = addExample(b, "sine", pa_zig_lib, target, optimize, pa_config);
    const sine_run_step = b.step("run-sine", "Run the sine wave example");
    sine_run_step.dependOn(&sine_run.step);

    const record_run = addExample(b, "record", pa_zig_lib, target, optimize, pa_config);
    const record_run_step = b.step("run-record", "Run the recording example");
    record_run_step.dependOn(&record_run.step);

    const fuzz_run = addExample(b, "fuzz", pa_zig_lib, target, optimize, pa_config);
    const fuzz_run_step = b.step("run-fuzz", "Run the fuzz example");
    fuzz_run_step.dependOn(&fuzz_run.step);

    const pink_run = addExample(b, "pink", pa_zig_lib, target, optimize, pa_config);
    const pink_run_step = b.step("run-pink", "Run the pink noise example");
    pink_run_step.dependOn(&pink_run.step);

    const read_write_wire_run = addExample(b, "read_write_wire", pa_zig_lib, target, optimize, pa_config);
    const read_write_wire_run_step = b.step("run-read-write-wire", "Run the blocking wire example");
    read_write_wire_run_step.dependOn(&read_write_wire_run.step);

    const saw_run = addExample(b, "saw", pa_zig_lib, target, optimize, pa_config);
    const saw_run_step = b.step("run-saw", "Run the saw wave example");
    saw_run_step.dependOn(&saw_run.step);

    const write_sine_run = addExample(b, "write_sine", pa_zig_lib, target, optimize, pa_config);
    const write_sine_run_step = b.step("run-write-sine", "Run the blocking write sine example");
    write_sine_run_step.dependOn(&write_sine_run.step);

    const examples_step = b.step("examples", "Build all examples");
    examples_step.dependOn(b.getInstallStep());

    const run_examples_step = b.step("run-examples", "Run all examples");
    run_examples_step.dependOn(devs_run_step);
    run_examples_step.dependOn(sine_run_step);
    run_examples_step.dependOn(record_run_step);
    run_examples_step.dependOn(fuzz_run_step);
    run_examples_step.dependOn(pink_run_step);
    run_examples_step.dependOn(read_write_wire_run_step);
    run_examples_step.dependOn(saw_run_step);
    run_examples_step.dependOn(write_sine_run_step);
}

const WinHost = enum {
    wasapi,
    dsound,
    mme,
    wdmks,
};

const LinuxHost = enum {
    alsa,
    jack,
    oss,
};

const PaConfig = struct {
    win_host: WinHost,
    linux_host: LinuxHost,
};

fn configurePaSources(b: *std.Build, module: *std.Build.Module, target: std.Build.ResolvedTarget, pa_config: PaConfig) void {
    switch (target.result.os.tag) {
        .windows => configureWindowsSources(b, module, pa_config.win_host),
        .linux => configureLinuxSources(b, module, pa_config.linux_host),
        .macos => configureMacosSources(b, module),
        else => log.warn("unsupported OS: {s}", .{@tagName(target.result.os.tag)}),
    }
}

fn configureWindowsSources(b: *std.Build, module: *std.Build.Module, win_host: WinHost) void {
    module.link_libc = true;
    module.addIncludePath(b.path("portaudio/src/os/win"));
    module.addCSourceFiles(.{
        .files = &.{
            "portaudio/src/os/win/pa_win_coinitialize.c",
            "portaudio/src/os/win/pa_win_hostapis.c",
            "portaudio/src/os/win/pa_win_util.c",
            "portaudio/src/os/win/pa_win_waveformat.c",
            "portaudio/src/os/win/pa_x86_plain_converters.c",
        },
    });
    switch (win_host) {
        .wasapi => {
            module.addCMacro("PA_USE_WASAPI", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/wasapi"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/wasapi/pa_win_wasapi.c") });
        },
        .dsound => {
            module.addCMacro("PA_USE_DS", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/dsound"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/dsound/pa_win_ds.c") });
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/dsound/pa_win_ds_dynlink.c") });
        },
        .mme => {
            module.addCMacro("PA_USE_MME", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/mme"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/mme/pa_win_mme.c") });
        },
        .wdmks => {
            module.addCMacro("PA_USE_WDMKS", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/wdmks"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/wdmks/pa_win_wdmks.c") });
        },
    }
}

fn configureLinuxSources(b: *std.Build, module: *std.Build.Module, linux_host: LinuxHost) void {
    module.link_libc = true;
    module.linkSystemLibrary("m", .{});
    module.addIncludePath(b.path("portaudio/src/os/unix"));
    module.addCSourceFiles(.{
        .files = &.{
            "portaudio/src/os/unix/pa_unix_hostapis.c",
            "portaudio/src/os/unix/pa_unix_util.c",
            "portaudio/src/os/unix/pa_pthread_util.c",
        },
    });
    switch (linux_host) {
        .alsa => {
            module.addCMacro("PA_USE_ALSA", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/alsa"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/alsa/pa_linux_alsa.c") });
        },
        .jack => {
            module.addCMacro("PA_USE_JACK", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/jack"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/jack/pa_jack.c") });
        },
        .oss => {
            module.addCMacro("PA_USE_OSS", "1");
            module.addIncludePath(b.path("portaudio/src/hostapi/oss"));
            module.addCSourceFile(.{ .file = b.path("portaudio/src/hostapi/oss/pa_unix_oss.c") });
        },
    }
}

fn configureMacosSources(b: *std.Build, module: *std.Build.Module) void {
    module.addIncludePath(b.path("portaudio/src/os/unix"));
    module.addCMacro("PA_USE_COREAUDIO", "1");
    module.addCMacro("PA_USE_SYSTEM_CONVERTERS", "1");
    module.addIncludePath(b.path("portaudio/src/hostapi/coreaudio"));
    module.addCSourceFiles(.{
        .files = &.{
            "portaudio/src/os/unix/pa_unix_hostapis.c",
            "portaudio/src/os/unix/pa_unix_util.c",
            "portaudio/src/hostapi/coreaudio/pa_mac_core.c",
            "portaudio/src/hostapi/coreaudio/pa_mac_core_blocking.c",
            "portaudio/src/hostapi/coreaudio/pa_mac_core_utilities.c",
        },
    });
}

fn linkPaSystemLibs(exe: *std.Build.Step.Compile, target: std.Build.ResolvedTarget, pa_config: PaConfig) void {
    if (target.result.os.tag == .windows) {
        exe.root_module.link_libc = true;
        switch (pa_config.win_host) {
            .wasapi => {
                exe.root_module.linkSystemLibrary("ole32", .{});
                exe.root_module.linkSystemLibrary("uuid", .{});
                exe.root_module.linkSystemLibrary("audioclient", .{});
                exe.root_module.linkSystemLibrary("avrt", .{});
            },
            .dsound => exe.root_module.linkSystemLibrary("ole32", .{}),
            .mme => exe.root_module.linkSystemLibrary("winmm", .{}),
            .wdmks => exe.root_module.linkSystemLibrary("setupapi", .{}),
        }
    } else if (target.result.os.tag == .linux) {
        exe.root_module.link_libc = true;
        switch (pa_config.linux_host) {
            .alsa => {
                exe.root_module.linkSystemLibrary("asound", .{});
                exe.root_module.linkSystemLibrary("pthread", .{});
            },
            .jack => {
                exe.root_module.linkSystemLibrary("jack", .{});
                exe.root_module.linkSystemLibrary("pthread", .{});
            },
            .oss => {
                exe.root_module.linkSystemLibrary("pthread", .{});
            },
        }
    } else if (target.result.os.tag == .macos) {
        exe.root_module.linkFramework("CoreAudio", .{});
        exe.root_module.linkFramework("AudioToolbox", .{});
        exe.root_module.linkFramework("AudioUnit", .{});
        exe.root_module.linkFramework("CoreFoundation", .{});
    }
}

fn addExample(
    b: *std.Build,
    comptime name: []const u8,
    lib: *std.Build.Step.Compile,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    pa_config: PaConfig,
) *std.Build.Step.Run {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path("examples/" ++ name ++ ".zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("portaudio", lib.root_module);

    exe.linkLibrary(lib);
    linkPaSystemLibs(exe, target, pa_config);

    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}
