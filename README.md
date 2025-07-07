<div align="center">

# portaudio

PortAudio is a portable audio I/O library designed for cross-platform
support of audio.

</div>

[Zig](http://ziglang.org) wrapper for the [PortAudio](http://www.portaudio.com) library.
The library will be updated only for STABLE Zig releases. The current latest stable Zig version is 0.14.1 with the `minimum_zig_version` set to the same value.

## Usage

If you have Nix with flakes enabled, you can enter a development shell with all dependencies by running:

```sh
nix develop
```

This provides the correct Zig compiler and system libraries such as ALSA and JACK.

### Adding to your project

1.  Add this repository as a dependency in your `build.zig.zon`. 
```sh
zig fetch --save git+https://github.com/rplstr/portaudio.git
```

2.  In your `build.zig`, add the dependency and link against it:

    ```zig
    // build.zig
    const exe = b.addExecutable(...);

    const portaudio = b.dependency("portaudio", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_library.addImport("portaudio", portaudio.module("portaudio"));
    exe.linkLibrary(portaudio.artifact("portaudio"));
    ```

## Examples

The `examples/` directory contains several examples demonstrating how to use the library.

You can build and run any of them using `zig build run-<example_name>`. For example:

```sh
zig build run-devs

zig build run-sine

zig build run-record
```