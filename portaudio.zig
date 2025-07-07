//! Documentation mirrored from `portaudio/include/portaudio.h`.
const std = @import("std");

pub const c = @cImport({
    @cInclude("portaudio.h");
});

pub const Error = error{
    NotInitialized,
    UnanticipatedHostError,
    InvalidChannelCount,
    InvalidSampleRate,
    InvalidDevice,
    InvalidFlag,
    SampleFormatNotSupported,
    BadIODeviceCombination,
    InsufficientMemory,
    BufferTooBig,
    BufferTooSmall,
    NullCallback,
    BadStreamPtr,
    TimedOut,
    InternalError,
    DeviceUnavailable,
    IncompatibleHostApiSpecificStreamInfo,
    StreamIsStopped,
    StreamIsNotStopped,
    InputOverflowed,
    OutputUnderflowed,
    HostApiNotFound,
    InvalidHostApi,
    CanNotReadFromACallbackStream,
    CanNotWriteToACallbackStream,
    CanNotReadFromAnOutputOnlyStream,
    CanNotWriteToAnInputOnlyStream,
    IncompatibleStreamHostApi,
    BadBufferPtr,
    CanNotInitializeRecursively,
    OutOfMemory,
};

fn paErrorToError(err: c.PaError) Error {
    return switch (err) {
        c.paNoError => unreachable, // This function should only be called with an error code.
        c.paNotInitialized => error.NotInitialized,
        c.paUnanticipatedHostError => error.UnanticipatedHostError,
        c.paInvalidChannelCount => error.InvalidChannelCount,
        c.paInvalidSampleRate => error.InvalidSampleRate,
        c.paInvalidDevice => error.InvalidDevice,
        c.paInvalidFlag => error.InvalidFlag,
        c.paSampleFormatNotSupported => error.SampleFormatNotSupported,
        c.paBadIODeviceCombination => error.BadIODeviceCombination,
        c.paInsufficientMemory => error.InsufficientMemory,
        c.paBufferTooBig => error.BufferTooBig,
        c.paBufferTooSmall => error.BufferTooSmall,
        c.paNullCallback => error.NullCallback,
        c.paBadStreamPtr => error.BadStreamPtr,
        c.paTimedOut => error.TimedOut,
        c.paInternalError => error.InternalError,
        c.paDeviceUnavailable => error.DeviceUnavailable,
        c.paIncompatibleHostApiSpecificStreamInfo => error.IncompatibleHostApiSpecificStreamInfo,
        c.paStreamIsStopped => error.StreamIsStopped,
        c.paStreamIsNotStopped => error.StreamIsNotStopped,
        c.paInputOverflowed => error.InputOverflowed,
        c.paOutputUnderflowed => error.OutputUnderflowed,
        c.paHostApiNotFound => error.HostApiNotFound,
        c.paInvalidHostApi => error.InvalidHostApi,
        c.paCanNotReadFromACallbackStream => error.CanNotReadFromACallbackStream,
        c.paCanNotWriteToACallbackStream => error.CanNotWriteToACallbackStream,
        c.paCanNotReadFromAnOutputOnlyStream => error.CanNotReadFromAnOutputOnlyStream,
        c.paCanNotWriteToAnInputOnlyStream => error.CanNotWriteToAnInputOnlyStream,
        c.paIncompatibleStreamHostApi => error.IncompatibleStreamHostApi,
        c.paBadBufferPtr => error.BadBufferPtr,
        c.paCanNotInitializeRecursively => error.CanNotInitializeRecursively,
        else => unreachable,
    };
}

/// Retrieve the release number of the currently running PortAudio build.
/// For example, for version "19.5.1" this will return 0x00130501.
pub fn getVersion() c_int {
    return c.Pa_GetVersion();
}

/// Retrieve a textual description of the current PortAudio build,
/// e.g. "PortAudio V19.5.0-devel, revision 1952M".
/// The format of the text may change in the future. Do not try to parse the
/// returned string. Deprecated as of 19.5.0, use `getVersionInfo().text` instead.
pub fn getVersionText() []const u8 {
    return std.mem.sliceTo(c.Pa_GetVersionText(), 0);
}

/// A structure containing PortAudio API version information.
pub const VersionInfo = struct {
    major: c_int,
    minor: c_int,
    sub_minor: c_int,
    /// This is currently the Git revision hash but may change in the future.
    /// The versionControlRevision is updated by running a script before compiling the library.
    /// If the update does not occur, this value may refer to an earlier revision.
    /// Encoded as UTF-8.
    revision: []const u8,
    /// Version as a string, for example "PortAudio V19.5.0-devel, revision 1952M".
    /// Encoded as UTF-8.
    text: []const u8,

    pub fn fromC(c_info: *const c.PaVersionInfo) VersionInfo {
        return .{
            .major = c_info.versionMajor,
            .minor = c_info.versionMinor,
            .sub_minor = c_info.versionSubMinor,
            .revision = std.mem.sliceTo(c_info.versionControlRevision, 0),
            .text = std.mem.sliceTo(c_info.versionText, 0),
        };
    }
};

/// Retrieve version information for the currently running PortAudio build.
/// This function can be called at any time. It does not require PortAudio
/// to be initialized. The structure pointed to is statically allocated. Do not
/// attempt to free it or modify it.
pub fn getVersionInfo() VersionInfo {
    return VersionInfo.fromC(c.Pa_GetVersionInfo());
}

/// Translate the supplied PortAudio error code into a human readable message, encoded as UTF-8.
pub fn getErrorText(err: Error) []const u8 {
    const c_err = switch (err) {
        error.NotInitialized => c.paNotInitialized,
        error.UnanticipatedHostError => c.paUnanticipatedHostError,
        error.InvalidChannelCount => c.paInvalidChannelCount,
        error.InvalidSampleRate => c.paInvalidSampleRate,
        error.InvalidDevice => c.paInvalidDevice,
        error.InvalidFlag => c.paInvalidFlag,
        error.SampleFormatNotSupported => c.paSampleFormatNotSupported,
        error.BadIODeviceCombination => c.paBadIODeviceCombination,
        error.InsufficientMemory => c.paInsufficientMemory,
        error.BufferTooBig => c.paBufferTooBig,
        error.BufferTooSmall => c.paBufferTooSmall,
        error.NullCallback => c.paNullCallback,
        error.BadStreamPtr => c.paBadStreamPtr,
        error.TimedOut => c.paTimedOut,
        error.InternalError => c.paInternalError,
        error.DeviceUnavailable => c.paDeviceUnavailable,
        error.IncompatibleHostApiSpecificStreamInfo => c.paIncompatibleHostApiSpecificStreamInfo,
        error.StreamIsStopped => c.paStreamIsStopped,
        error.StreamIsNotStopped => c.paStreamIsNotStopped,
        error.InputOverflowed => c.paInputOverflowed,
        error.OutputUnderflowed => c.paOutputUnderflowed,
        error.HostApiNotFound => c.paHostApiNotFound,
        error.InvalidHostApi => c.paInvalidHostApi,
        error.CanNotReadFromACallbackStream => c.paCanNotReadFromACallbackStream,
        error.CanNotWriteToACallbackStream => c.paCanNotWriteToACallbackStream,
        error.CanNotReadFromAnOutputOnlyStream => c.paCanNotReadFromAnOutputOnlyStream,
        error.CanNotWriteToAnInputOnlyStream => c.paCanNotWriteToAnInputOnlyStream,
        error.IncompatibleStreamHostApi => c.paIncompatibleStreamHostApi,
        error.BadBufferPtr => c.paBadBufferPtr,
        error.CanNotInitializeRecursively => c.paCanNotInitializeRecursively,
    };
    return std.mem.sliceTo(c.Pa_GetErrorText(c_err), 0);
}

/// Put the caller to sleep for at least `msec` milliseconds. This function is
/// provided only as a convenience for authors of portable code.
/// The function may sleep longer than requested so don't rely on this for accurate musical timing.
pub fn sleep(msec: c_long) void {
    c.Pa_Sleep(msec);
}

/// The type used to refer to audio devices. Values of this type usually
/// range from 0 to (getDeviceCount()-1), and may also take on the `no_device`
/// and `use_host_api_specific_device_specification` values.
pub const DeviceIndex = c.PaDeviceIndex;
/// The type used to enumerate to host APIs at runtime. Values of this type
/// range from 0 to (getHostApiCount()-1).
pub const HostApiIndex = c.PaHostApiIndex;
/// The type used to represent monotonic time in seconds. Time is
/// used for the fields of the StreamCallbackTimeInfo argument to the
/// stream callback and as the result of Stream.getTime().
///
/// Time values have unspecified origin.
pub const Time = c.PaTime;

/// A special DeviceIndex value indicating that no device is available, or should be used.
pub const no_device = c.paNoDevice;
/// A special DeviceIndex value indicating that the device(s) to be used
/// are specified in the host api specific stream info structure.
pub const use_host_api_specific_device_specification = c.paUseHostApiSpecificDeviceSpecification;

/// Unchanging unique identifiers for each supported host API. This type
/// is used in the HostApiInfo structure. The values are guaranteed to be
/// unique and to never change, thus allowing code to be written that
/// conditionally uses host API specific extensions.
/// New type ids will be allocated when support for a host API reaches
/// "public alpha" status, prior to that developers should use the `in_development` type id.
pub const HostApiTypeId = enum(c.PaHostApiTypeId) {
    in_development = c.paInDevelopment,
    direct_sound = c.paDirectSound,
    mme = c.paMME,
    asio = c.paASIO,
    sound_manager = c.paSoundManager,
    core_audio = c.paCoreAudio,
    oss = c.paOSS,
    alsa = c.paALSA,
    al = c.paAL,
    be_os = c.paBeOS,
    wdmks = c.paWDMKS,
    jack = c.paJACK,
    wasapi = c.paWASAPI,
    audio_science_hpi = c.paAudioScienceHPI,
};

/// A structure containing information about a particular host API.
pub const HostApiInfo = struct {
    /// this is struct version 1
    struct_version: c_int,
    /// The well known unique identifier of this host API.
    type: HostApiTypeId,
    /// A textual description of the host API for display on user interfaces. Encoded as UTF-8.
    name: []const u8,
    /// The number of devices belonging to this host API. This field may be
    /// used in conjunction with `hostApiDeviceIndexToDeviceIndex()` to enumerate
    /// all devices for this host API.
    device_count: c_int,
    /// The default input device for this host API. The value will be a
    /// device index ranging from 0 to (getDeviceCount()-1), or `no_device` if no default input device is available.
    default_input_device: DeviceIndex,
    /// The default output device for this host API. The value will be a
    /// device index ranging from 0 to (getDeviceCount()-1), or `no_device` if no default output device is available.
    default_output_device: DeviceIndex,

    pub fn fromC(c_info: *const c.PaHostApiInfo) HostApiInfo {
        return .{
            .struct_version = c_info.structVersion,
            .type = @as(HostApiTypeId, @enumFromInt(c_info.type)),
            .name = std.mem.sliceTo(c_info.name, 0),
            .device_count = c_info.deviceCount,
            .default_input_device = c_info.defaultInputDevice,
            .default_output_device = c_info.defaultOutputDevice,
        };
    }
};

/// Structure used to return information about a host error condition.
pub const HostErrorInfo = struct {
    /// the host API which returned the error code
    host_api_type: HostApiTypeId,
    /// the error code returned
    error_code: c_long,
    /// a textual description of the error if available (encoded as UTF-8), otherwise a zero-length string
    error_text: []const u8,

    pub fn fromC(c_info: *const c.PaHostErrorInfo) HostErrorInfo {
        return .{
            .host_api_type = @as(HostApiTypeId, @enumFromInt(c_info.hostApiType)),
            .error_code = c_info.errorCode,
            .error_text = std.mem.sliceTo(c_info.errorText, 0),
        };
    }
};

/// A structure providing information and capabilities of PortAudio devices.
/// Devices may support input, output or both input and output.
pub const DeviceInfo = struct {
    /// this is struct version 2
    struct_version: c_int,
    /// Human readable device name. Encoded as UTF-8.
    name: []const u8,
    /// Host API index in the range 0 to (getHostApiCount()-1). Note: this is a host API index, not a type id.
    host_api: HostApiIndex,
    max_input_channels: c_int,
    max_output_channels: c_int,
    /// Default latency values for interactive performance.
    default_low_input_latency: Time,
    /// Default latency values for interactive performance.
    default_low_output_latency: Time,
    /// Default latency values for robust non-interactive applications (eg. playing sound files).
    default_high_input_latency: Time,
    /// Default latency values for robust non-interactive applications (eg. playing sound files).
    default_high_output_latency: Time,
    default_sample_rate: f64,

    pub fn fromC(c_info: *const c.PaDeviceInfo) DeviceInfo {
        return .{
            .struct_version = c_info.structVersion,
            .name = std.mem.sliceTo(c_info.name, 0),
            .host_api = c_info.hostApi,
            .max_input_channels = c_info.maxInputChannels,
            .max_output_channels = c_info.maxOutputChannels,
            .default_low_input_latency = c_info.defaultLowInputLatency,
            .default_low_output_latency = c_info.defaultLowOutputLatency,
            .default_high_input_latency = c_info.defaultHighInputLatency,
            .default_high_output_latency = c_info.defaultHighOutputLatency,
            .default_sample_rate = c_info.defaultSampleRate,
        };
    }
};

/// A type used to specify one or more sample formats. Each value indicates
/// a possible format for sound data passed to and from the stream callback,
/// Stream.read() and Stream.write().
///
/// The standard formats float32, int16, int32, int24, int8
/// and uint8 are usually implemented by all implementations.
///
/// The floating point representation (float32) uses +1.0 and -1.0 as the
/// maximum and minimum respectively.
///
/// uint8 is an unsigned 8 bit format where 128 is considered "ground"
///
/// The non_interleaved flag indicates that audio data is passed as an array
/// of pointers to separate buffers, one buffer for each channel. Usually,
/// when this flag is not used, audio data is passed as a single buffer with
/// all channels interleaved.
pub const SampleFormat = packed struct(u32) {
    float32: bool = false,
    int32: bool = false,
    int24: bool = false,
    int16: bool = false,
    int8: bool = false,
    uint8: bool = false,
    _pad1: u10 = 0,
    custom: bool = false,
    _pad2: u14 = 0,
    non_interleaved: bool = false,

    pub fn toC(self: SampleFormat) c.PaSampleFormat {
        return @as(u32, @bitCast(self));
    }

    /// Retrieve the size of a given sample format in bytes.
    /// Returns the size in bytes of a single sample in the specified format,
    /// or an error if the format is not supported.
    pub fn sizeInBytes(self: SampleFormat) !usize {
        const c_size = c.Pa_GetSampleSize(self.toC());
        if (c_size < 0) return paErrorToError(c_size);
        return @as(usize, @intCast(c_size));
    }
};

/// Parameters for one direction (input or output) of a stream.
pub const StreamParameters = struct {
    /// A valid device index in the range 0 to (getDeviceCount()-1)
    /// specifying the device to be used or the special constant
    /// `use_host_api_specific_device_specification` which indicates that the actual
    /// device(s) to use are specified in host_api_specific_stream_info.
    /// This field must not be set to `no_device`.
    device: DeviceIndex,
    /// The number of channels of sound to be delivered to the
    /// stream callback or accessed by Stream.read() or Stream.write().
    /// It can range from 1 to the value of max_input_channels in the
    /// DeviceInfo record for the device specified by the device parameter.
    channel_count: c_int,
    /// The sample format of the buffer provided to the stream callback,
    /// Stream.read() or Stream.write().
    sample_format: SampleFormat,
    /// The desired latency in seconds. Where practical, implementations should
    /// configure their latency based on these parameters, otherwise they may
    /// choose the closest viable latency instead. Unless the suggested latency
    /// is greater than the absolute upper limit for the device implementations
    /// should round the suggestedLatency up to the next practical value - ie to
    /// provide an equal or higher latency than suggestedLatency wherever possible.
    /// Actual latency values for an open stream may be retrieved using the
    /// input_latency and output_latency fields of the StreamInfo structure returned by Stream.getInfo().
    suggested_latency: Time,
    /// An optional pointer to a host api specific data structure
    /// containing additional information for device setup and/or stream processing.
    /// This is never required for correct operation, if not used it should be set to null.
    host_api_specific_stream_info: ?*anyopaque = null,

    pub fn toC(self: StreamParameters) c.PaStreamParameters {
        return .{
            .device = self.device,
            .channelCount = self.channel_count,
            .sampleFormat = self.sample_format.toC(),
            .suggestedLatency = self.suggested_latency,
            .hostApiSpecificStreamInfo = self.host_api_specific_stream_info,
        };
    }
};

/// Flags used to control the behavior of a stream. They are passed as
/// parameters to `openStream()` or `openDefaultStream()`. Multiple flags may be
/// ORed together.
pub const StreamFlags = packed struct(u32) {
    /// Disable default clipping of out of range samples.
    clip_off: bool = false,
    /// Disable default dithering.
    dither_off: bool = false,
    /// Flag requests that where possible a full duplex stream will not discard
    /// overflowed input samples without calling the stream callback. This flag is
    /// only valid for full duplex callback streams and only when used in combination
    /// with the `paFramesPerBufferUnspecified` (0) frames_per_buffer parameter. Using
    /// this flag incorrectly results in an `InvalidFlag` error.
    never_drop_input: bool = false,
    /// Call the stream callback to fill initial output buffers, rather than the
    /// default behavior of priming the buffers with zeros (silence). This flag has
    /// no effect for input-only and blocking read/write streams.
    prime_output_buffers_using_stream_callback: bool = false,
    _: u12 = 0,
    platform_specific: u16 = 0,

    pub fn toC(self: StreamFlags) c.PaStreamFlags {
        return @as(u32, @bitCast(self));
    }
};

/// Timing information for the buffers passed to the stream callback.
/// Time values are expressed in seconds and are synchronised with the time base used by Stream.getTime() for the associated stream.
pub const StreamCallbackTimeInfo = struct {
    /// The time when the first sample of the input buffer was captured at the ADC input
    input_buffer_adc_time: Time,
    /// The time when the stream callback was invoked
    current_time: Time,
    /// The time when the first sample of the output buffer will output the DAC
    output_buffer_dac_time: Time,

    pub fn fromC(c_info: *const c.PaStreamCallbackTimeInfo) StreamCallbackTimeInfo {
        return .{
            .input_buffer_adc_time = c_info.inputBufferAdcTime,
            .current_time = c_info.currentTime,
            .output_buffer_dac_time = c_info.outputBufferDacTime,
        };
    }
};

/// Flag bit constants for the status_flags to the stream callback.
pub const StreamCallbackFlags = packed struct(u32) {
    /// In a stream opened with `paFramesPerBufferUnspecified`, indicates that
    /// input data is all silence (zeros) because no real data is available. In a
    /// stream opened without `paFramesPerBufferUnspecified`, it indicates that one or
    /// more zero samples have been inserted into the input buffer to compensate
    /// for an input underflow.
    input_underflow: bool = false,
    /// In a stream opened with `paFramesPerBufferUnspecified`, indicates that data
    /// prior to the first sample of the input buffer was discarded due to an
    /// overflow, possibly because the stream callback is using too much CPU time.
    /// Otherwise indicates that data prior to one or more samples in the
    /// input buffer was discarded.
    input_overflow: bool = false,
    /// Indicates that output data (or a gap) was inserted, possibly because the
    /// stream callback is using too much CPU time.
    output_underflow: bool = false,
    /// Indicates that output data will be discarded because no room is available.
    output_overflow: bool = false,
    /// Some of all of the output data will be used to prime the stream, input
    /// data may be zero.
    priming_output: bool = false,
    _: u27 = 0,
};

/// Allowable return values for the stream callback.
pub const CallbackResult = enum(c_int) {
    /// Signal that the stream should continue invoking the callback and processing audio.
    @"continue" = c.paContinue,
    /// Signal that the stream should stop invoking the callback and finish once all output samples have played.
    complete = c.paComplete,
    /// Signal that the stream should stop invoking the callback and finish as soon as possible.
    abort = c.paAbort,
};

/// A structure containing unchanging information about an open stream.
pub const StreamInfo = struct {
    /// this is struct version 1
    struct_version: c_int,
    /// The input latency of the stream in seconds. This value provides the most
    /// accurate estimate of input latency available to the implementation. It may
    /// differ significantly from the suggested_latency value passed to `openStream()`.
    /// The value of this field will be zero (0.) for output-only streams.
    input_latency: Time,
    /// The output latency of the stream in seconds. This value provides the most
    /// accurate estimate of output latency available to the implementation. It may
    /// differ significantly from the suggested_latency value passed to `openStream()`.
    /// The value of this field will be zero (0.) for input-only streams.
    output_latency: Time,
    /// The sample rate of the stream in Hertz (samples per second). In cases
    /// where the hardware sample rate is inaccurate and PortAudio is aware of it,
    /// the value of this field may be different from the sample_rate parameter
    /// passed to `openStream()`. If information about the actual hardware sample
    /// rate is not available, this field will have the same value as the sample_rate
    /// parameter passed to `openStream()`.
    sample_rate: f64,

    pub fn fromC(c_info: *const c.PaStreamInfo) StreamInfo {
        return .{
            .struct_version = c_info.structVersion,
            .input_latency = c_info.inputLatency,
            .output_latency = c_info.outputLatency,
            .sample_rate = c_info.sampleRate,
        };
    }
};

/// A single Stream can provide multiple channels of real-time
/// streaming audio input and output to a client application. A stream
/// provides access to audio hardware represented by one or more
/// devices. Depending on the underlying Host API, it may be possible
/// to open multiple streams using the same device, however this behavior
/// is implementation defined. Portable applications should assume that
/// a device may be simultaneously used by at most one Stream.
pub const Stream = struct {
    c_stream: *c.PaStream,
    allocator: std.mem.Allocator,
    callback_context: ?*CallbackContext,
    finished_callback_context: ?*FinishedCallbackContext,

    /// Functions of this type are implemented by PortAudio clients.
    /// They consume, process or generate audio in response to requests from an
    /// active PortAudio stream.
    ///
    /// When a stream is running, PortAudio calls the stream callback periodically.
    /// The callback function is responsible for processing buffers of audio samples
    /// passed via the input and output parameters.
    ///
    /// The PortAudio stream callback runs at very high or real-time priority.
    /// It is required to consistently meet its time deadlines. Do not allocate
    /// memory, access the file system, call library functions or call other functions
    /// from the stream callback that may block or take an unpredictable amount of
    /// time to complete.
    ///
    /// In order for a stream to maintain glitch-free operation the callback
    /// must consume and return audio data faster than it is recorded and/or
    /// played. PortAudio anticipates that each callback invocation may execute for
    /// a duration approaching the duration of frame_count audio frames at the stream
    /// sample rate. It is reasonable to expect to be able to utilise 70% or more of
    /// the available CPU time in the PortAudio callback. However, due to buffer size
    /// adaption and other factors, not all host APIs are able to guarantee audio
    /// stability under heavy CPU load with arbitrary fixed callback buffer sizes.
    /// When high callback CPU utilisation is required the most robust behavior
    /// can be achieved by using `paFramesPerBufferUnspecified` as the
    /// `openStream()` frames_per_buffer parameter.
    const CallbackContext = struct {
        callback: *const fn (
            input: ?*const anyopaque,
            output: ?*anyopaque,
            frame_count: u64,
            time_info: *const StreamCallbackTimeInfo,
            status_flags: StreamCallbackFlags,
            user_data: ?*anyopaque,
        ) CallbackResult,
        user_data: ?*anyopaque,
    };

    /// Functions of this type are implemented by PortAudio clients. They can be
    /// registered with a stream using the `setFinishedCallback()` function.
    /// Once registered they are called when the stream becomes inactive
    /// (ie once a call to `stop()` will not block).
    /// A stream will become inactive after the stream callback returns non-zero,
    /// or when `stop()` or `abort()` is called. For a stream providing audio
    /// output, if the stream callback returns `CallbackResult.complete`, or `stop()` is called,
    /// the stream finished callback will not be called until all generated sample data
    /// has been played.
    const FinishedCallbackContext = struct {
        /// `user_data` is the `user_data` parameter supplied to `openStream()`.
        callback: *const fn (user_data: ?*anyopaque) void,
        user_data: ?*anyopaque,
    };

    fn cCallback(
        c_input: ?*const anyopaque,
        c_output: ?*anyopaque,
        frame_count: c_ulong,
        c_time_info: ?*const c.PaStreamCallbackTimeInfo,
        c_status_flags: c.PaStreamCallbackFlags,
        c_user_data: ?*anyopaque,
    ) callconv(.c) c_int {
        if (c_user_data == null) {
            // This should not happen.
            return @intFromEnum(CallbackResult.abort);
        }
        const stream = @as(*const Stream, @ptrCast(@alignCast(c_user_data.?)));
        const context = stream.callback_context.?;
        const time_info = StreamCallbackTimeInfo.fromC(c_time_info.?);
        const status_flags = @as(StreamCallbackFlags, @bitCast(@as(u32, @truncate(c_status_flags))));

        const result: CallbackResult = context.callback(c_input, c_output, frame_count, &time_info, status_flags, context.user_data);
        return @intFromEnum(result);
    }

    fn cFinishedCallback(c_user_data: ?*anyopaque) callconv(.c) void {
        const stream = @as(*const Stream, @ptrCast(@alignCast(c_user_data.?)));
        if (stream.finished_callback_context) |context| {
            context.callback(context.user_data);
        }
    }

    /// Closes an audio stream. If the audio stream is active it
    /// discards any pending buffers as if abort() had been called.
    pub fn close(self: *Stream) !void {
        const allocator = self.allocator;
        const err = c.Pa_CloseStream(self.c_stream);
        if (self.callback_context) |ctx| allocator.destroy(ctx);
        if (self.finished_callback_context) |ctx| allocator.destroy(ctx);
        allocator.destroy(self);
        if (err != c.paNoError) return paErrorToError(err);
    }

    /// Register a stream finished callback function which will be called when the
    /// stream becomes inactive. See the documentation for `FinishedCallbackContext` for
    /// further details about when the callback will be called.
    /// The stream must be in the stopped state.
    pub fn setFinishedCallback(
        self: *Stream,
        callback: fn (user_data: ?*anyopaque) void,
        user_data: ?*anyopaque,
    ) Error!void {
        if (self.finished_callback_context) |ctx| {
            self.allocator.destroy(ctx);
            self.finished_callback_context = null;
        }

        const context = try self.allocator.create(FinishedCallbackContext);
        context.* = .{
            .callback = callback,
            .user_data = user_data,
        };
        self.finished_callback_context = context;

        const err = c.Pa_SetStreamFinishedCallback(self.c_stream, cFinishedCallback);
        if (err != c.paNoError) return paErrorToError(err);
    }

    /// Commences audio processing.
    pub fn start(self: *Stream) !void {
        const err = c.Pa_StartStream(self.c_stream);
        if (err != c.paNoError) return paErrorToError(err);
    }

    /// Terminates audio processing. It waits until all pending
    /// audio buffers have been played before it returns.
    pub fn stop(self: *Stream) !void {
        const err = c.Pa_StopStream(self.c_stream);
        if (err != c.paNoError) return paErrorToError(err);
    }

    /// Terminates audio processing promptly without necessarily waiting for
    /// pending buffers to complete.
    pub fn abort(self: *Stream) !void {
        const err = c.Pa_AbortStream(self.c_stream);
        if (err != c.paNoError) return paErrorToError(err);
    }

    /// Determine whether the stream is stopped.
    /// A stream is considered to be stopped prior to a successful call to
    /// `start()` and after a successful call to `stop()` or `abort()`.
    /// If a stream callback returns a value other than `CallbackResult.continue` the stream is NOT
    /// considered to be stopped.
    /// Returns true when the stream is stopped, false when the stream is running,
    /// or an error if PortAudio is not initialized or an error is encountered.
    pub fn isStopped(self: *const Stream) !bool {
        const result = c.Pa_IsStreamStopped(self.c_stream);
        if (result < 0) return paErrorToError(result);
        return result == 1;
    }

    /// Determine whether the stream is active.
    /// A stream is active after a successful call to `start()`, until it
    /// becomes inactive either as a result of a call to `stop()` or
    /// `abort()`, or as a result of a return value other than `CallbackResult.continue` from
    /// the stream callback. In the latter case, the stream is considered inactive
    /// after the last buffer has finished playing.
    /// Returns true when the stream is active (ie playing or recording audio),
    /// false when not playing, or an error if PortAudio is not initialized or an error is encountered.
    pub fn isActive(self: *const Stream) !bool {
        const result = c.Pa_IsStreamActive(self.c_stream);
        if (result < 0) return paErrorToError(result);
        return result == 1;
    }

    /// Retrieve a StreamInfo structure containing information about the stream.
    /// The returned structure is only guaranteed to be valid until the stream is closed.
    pub fn getInfo(self: *const Stream) ?StreamInfo {
        const c_info = c.Pa_GetStreamInfo(self.c_stream);
        if (c_info == null) return null;
        return StreamInfo.fromC(c_info);
    }

    /// Returns the current time in seconds for a stream according to the same clock used
    /// to generate callback `StreamCallbackTimeInfo` timestamps. The time values are
    /// monotonically increasing and have unspecified origin.
    ///
    /// `getTime` returns valid time values for the entire life of the stream,
    /// from when the stream is opened until it is closed. Starting and stopping the stream
    /// does not affect the passage of time returned by `getTime`.
    ///
    /// This time may be used for synchronizing other events to the audio stream, for
    /// example synchronizing audio to MIDI.
    pub fn getTime(self: *const Stream) Time {
        return c.Pa_GetStreamTime(self.c_stream);
    }

    /// Retrieve CPU usage information for the specified stream.
    /// The "CPU Load" is a fraction of total CPU time consumed by a callback stream's
    /// audio processing routines including, but not limited to the client supplied
    /// stream callback. This function does not work with blocking read/write streams.
    ///
    /// This function may be called from the stream callback function or the application.
    ///
    /// Returns a floating point value, typically between 0.0 and 1.0, where 1.0 indicates
    /// that the stream callback is consuming the maximum number of CPU cycles possible
    /// to maintain real-time operation. A value of 0.5 would imply that PortAudio and
    /// the stream callback was consuming roughly 50% of the available CPU time. The
    /// return value may exceed 1.0. A value of 0.0 will always be returned for a
    /// blocking read/write stream, or if an error occurs.
    pub fn getCpuLoad(self: *const Stream) f64 {
        return c.Pa_GetStreamCpuLoad(self.c_stream);
    }

    /// Read samples from an input stream. The function doesn't return until
    /// the entire buffer has been filled - this may involve waiting for the operating
    /// system to supply the data. `buffer` is a pointer to a buffer of sample frames.
    /// `frames` is the number of frames to be read into buffer.
    ///
    /// Reading from a stream that is stopped is not currently supported. In particular,
    /// it is not possible to drain the read buffer by calling `read()` after calling `stop()`.
    pub fn read(self: *Stream, buffer: *anyopaque, frames: u64) !void {
        const err = c.Pa_ReadStream(self.c_stream, buffer, frames);
        if (err != c.paNoError and err != c.paInputOverflowed) return paErrorToError(err);
    }

    /// Write samples to an output stream. This function doesn't return until the
    /// entire buffer has been written - this may involve waiting for the operating
    /// system to consume the data. `buffer` is a pointer to a buffer of sample frames.
    /// `frames` is the number of frames to be written from buffer.
    ///
    /// Writing to a stream that is stopped is not currently supported. In particular,
    /// it is not possible to prefill the write buffer by calling `write()` prior to calling `start()`.
    pub fn write(self: *Stream, buffer: *const anyopaque, frames: u64) !void {
        const err = c.Pa_WriteStream(self.c_stream, buffer, frames);
        if (err != c.paNoError and err != c.paOutputUnderflowed) return paErrorToError(err);
    }

    /// Retrieve the number of frames that can be read from the stream without
    /// waiting.
    /// When the stream is stopped the return value is not defined.
    /// Returns a non-negative value representing the maximum number of frames
    /// that can be read from the stream without blocking or busy waiting, or an error.
    pub fn getReadAvailable(self: *const Stream) !u64 {
        const result = c.Pa_GetStreamReadAvailable(self.c_stream);
        if (result < 0) return paErrorToError(@as(c_int, @intCast(result)));
        return @as(u64, @intCast(result));
    }

    /// Retrieve the number of frames that can be written to the stream without
    /// waiting.
    /// When the stream is stopped the return value is not defined.
    /// Returns a non-negative value representing the maximum number of frames
    /// that can be written to the stream without blocking or busy waiting, or an error.
    pub fn getWriteAvailable(self: *const Stream) !u64 {
        const result = c.Pa_GetStreamWriteAvailable(self.c_stream);
        if (result < 0) return paErrorToError(@as(c_int, @intCast(result)));
        return @as(u64, @intCast(result));
    }
};

/// The top-level library structure. You must initialize this before using PortAudio.
pub const Lib = struct {
    allocator: std.mem.Allocator,

    /// Library initialization function - call this before using PortAudio.
    /// This function initializes internal data structures and prepares underlying
    /// host APIs for use. With the exception of `getVersion()`, `getVersionText()`,
    /// and `getErrorText()`, this function MUST be called before using any other
    /// PortAudio API functions.
    ///
    /// If `init()` is called multiple times, each successful call must be matched
    /// with a corresponding call to `deinit()`. Pairs of calls may overlap, and are not
    /// required to be fully nested.
    ///
    /// Note that if `init()` returns an error, `deinit()` should NOT be called.
    ///
    /// Example:
    /// ```
    /// var pa = try portaudio.init(std.heap.page_allocator);
    /// defer pa.deinit();
    /// // use portaudio functions
    /// ```
    pub fn init(allocator: std.mem.Allocator) !Lib {
        const err = c.Pa_Initialize();
        if (err != c.paNoError) return paErrorToError(err);
        return Lib{ .allocator = allocator };
    }

    /// Library termination function - call this when finished using PortAudio.
    /// This function deallocates all resources allocated by PortAudio since it was
    /// initialized by a call to `init()`. In cases where `init()` has been called
    /// multiple times, each call must be matched with a corresponding call to `deinit()`.
    /// The final matching call to `deinit()` will automatically close any PortAudio
    /// streams that are still open.
    ///
    /// This MUST be called before exiting a program which uses PortAudio.
    /// Failure to do so may result in serious resource leaks, such as audio devices
    /// not being available until the next reboot.
    pub fn deinit(self: *const Lib) void {
        _ = self;
        const err = c.Pa_Terminate();

        if (err != c.paNoError) {
            std.debug.panic("Pa_Terminate failed with code: {d}", .{err});
        }
    }

    /// Retrieve the number of available host APIs. Even if a host API is
    /// available it may have no devices available.
    pub fn getHostApiCount(self: *const Lib) !HostApiIndex {
        _ = self;
        const count = c.Pa_GetHostApiCount();
        if (count < 0) return paErrorToError(count);
        return count;
    }

    /// Retrieve the index of the default host API. The default host API will be
    /// the lowest common denominator host API on the current platform and is
    /// unlikely to provide the best performance.
    pub fn getDefaultHostApi(self: *const Lib) !HostApiIndex {
        _ = self;
        const index = c.Pa_GetDefaultHostApi();
        if (index < 0) return paErrorToError(index);
        return index;
    }

    /// Retrieve a pointer to a structure containing information about a specific
    /// host API.
    /// Returns a `HostApiInfo` structure describing a specific host API.
    /// If the `index` parameter is out of range, the function returns null.
    /// The returned structure is owned by the PortAudio implementation and must not
    /// be manipulated. The data is only guaranteed to be valid between calls to `init()` and `deinit()`.
    pub fn getHostApiInfo(self: *const Lib, index: HostApiIndex) ?HostApiInfo {
        _ = self;
        const c_info = c.Pa_GetHostApiInfo(index);
        if (c_info == null) return null;
        return HostApiInfo.fromC(c_info);
    }

    /// Convert a static host API unique identifier, into a runtime host API index.
    /// The `HostApiNotFound` error code indicates that the host API specified by the
    /// type_id parameter is not available.
    pub fn hostApiTypeIdToIndex(self: *const Lib, type_id: HostApiTypeId) !HostApiIndex {
        _ = self;
        const index = c.Pa_HostApiTypeIdToHostApiIndex(@enumFromInt(type_id));
        if (index < 0) return paErrorToError(index);
        return index;
    }

    /// Convert a host-API-specific device index to standard PortAudio device index.
    /// This function may be used in conjunction with the device_count field of
    /// HostApiInfo to enumerate all devices for the specified host API.
    /// An `InvalidHostApi` error code indicates that the `host_api_index` parameter is out of range.
    /// An `InvalidDevice` error code indicates that the `host_api_device_index` parameter is out of range.
    pub fn hostApiDeviceIndexToDeviceIndex(self: *const Lib, host_api_index: HostApiIndex, host_api_device_index: c_int) !DeviceIndex {
        _ = self;
        const index = c.Pa_HostApiDeviceIndexToDeviceIndex(host_api_index, host_api_device_index);
        if (index < 0) return paErrorToError(index);
        return index;
    }

    /// Return information about the last host error encountered. The error
    /// information returned will never be modified asynchronously by errors
    /// occurring in other PortAudio owned threads (such as the thread that
    /// manages the stream callback.)
    /// This function is provided as a last resort, primarily to enhance debugging
    /// by providing clients with access to all available error information.
    /// The values in this structure will only be valid if a PortAudio function has previously returned the `UnanticipatedHostError` error code.
    pub fn getLastHostErrorInfo(self: *const Lib) HostErrorInfo {
        _ = self;
        return HostErrorInfo.fromC(c.Pa_GetLastHostErrorInfo());
    }

    /// Retrieve the number of available devices. The number of available devices may be zero.
    pub fn getDeviceCount(self: *const Lib) !DeviceIndex {
        _ = self;
        const count = c.Pa_GetDeviceCount();
        if (count < 0) return paErrorToError(count);
        return count;
    }

    /// Retrieve the index of the default input device. The result can be
    /// used in the `device` parameter of `StreamParameters` for `openStream()`.
    /// Returns the default input device index for the default host API, or `no_device`
    /// if no default input device is available or an error was encountered.
    pub fn getDefaultInputDevice(self: *const Lib) DeviceIndex {
        _ = self;
        return c.Pa_GetDefaultInputDevice();
    }

    /// Retrieve the index of the default output device. The result can be
    /// used in the `device` parameter of `StreamParameters` for `openStream()`.
    /// Returns the default output device index for the default host API, or `no_device`
    /// if no default output device is available or an error was encountered.
    ///
    /// On the PC, the user can specify a default device by
    /// setting an environment variable. For example, to use device #1.
    /// ```
    /// set PA_RECOMMENDED_OUTPUT_DEVICE=1
    /// ```
    /// The user should first determine the available device ids by using
    /// the supplied application "pa_devs".
    pub fn getDefaultOutputDevice(self: *const Lib) DeviceIndex {
        _ = self;
        return c.Pa_GetDefaultOutputDevice();
    }

    /// Retrieve a `DeviceInfo` structure containing information about the specified device.
    /// If the `index` parameter is out of range the function returns null.
    /// PortAudio manages the memory for the returned structure, the client must not manipulate it.
    /// The data is only guaranteed to be valid between calls to `init()` and `deinit()`.
    pub fn getDeviceInfo(self: *const Lib, index: DeviceIndex) ?DeviceInfo {
        _ = self;
        const c_info = c.Pa_GetDeviceInfo(index);
        if (c_info == null) return null;
        return DeviceInfo.fromC(c_info);
    }

    pub const DeviceIterator = struct {
        lib: *const Lib,
        index: DeviceIndex,
        count: DeviceIndex,

        pub fn next(self: *DeviceIterator) ?DeviceInfo {
            if (self.index >= self.count) {
                return null;
            }
            defer self.index += 1;
            return self.lib.getDeviceInfo(self.index);
        }
    };

    /// Returns an iterator over the available audio devices.
    pub fn devices(self: *const Lib) !DeviceIterator {
        return .{
            .lib = self,
            .index = 0,
            .count = try self.getDeviceCount(),
        };
    }

    pub const HostApiIterator = struct {
        lib: *const Lib,
        index: HostApiIndex,
        count: HostApiIndex,

        pub fn next(self: *HostApiIterator) ?HostApiInfo {
            if (self.index >= self.count) {
                return null;
            }
            defer self.index += 1;
            return self.lib.getHostApiInfo(self.index);
        }
    };

    /// Returns an iterator over the available host APIs.
    pub fn hostApis(self: *const Lib) !HostApiIterator {
        return .{
            .lib = self,
            .index = 0,
            .count = try self.getHostApiCount(),
        };
    }

    /// Determine whether it would be possible to open a stream with the specified parameters.
    /// The `suggested_latency` field of the parameters is ignored.
    /// `input_params` must be null for output-only streams.
    /// `output_params` must be null for input-only streams.
    /// `sample_rate` is the required sampleRate. For full-duplex streams it is the
    /// sample rate for both input and output.
    /// Returns true if the format is supported, and false otherwise.
    pub fn isFormatSupported(
        self: *const Lib,
        input_params: ?StreamParameters,
        output_params: ?StreamParameters,
        sample_rate: f64,
    ) bool {
        _ = self;
        var c_input: ?*const c.PaStreamParameters = null;
        var c_output: ?*const c.PaStreamParameters = null;
        var c_input_storage: c.PaStreamParameters = undefined;
        var c_output_storage: c.PaStreamParameters = undefined;

        if (input_params) |p| {
            c_input_storage = p.toC();
            c_input = &c_input_storage;
        }
        if (output_params) |p| {
            c_output_storage = p.toC();
            c_output = &c_output_storage;
        }

        return c.Pa_IsFormatSupported(c_input, c_output, sample_rate) == c.paFormatIsSupported;
    }

    /// Opens a stream for either input, output or both.
    /// `input_params`: A structure that describes the input parameters. Must be null for output-only streams.
    /// `output_params`: A structure that describes the output parameters. Must be null for input-only streams.
    /// `sample_rate`: The desired sampleRate. For full-duplex streams it is the sample rate for both input and output.
    /// `frames_per_buffer`: The number of frames passed to the stream callback function, or the preferred block granularity for a blocking read/write stream.
    /// The special value `paFramesPerBufferUnspecified` (0) may be used to request that the stream callback will receive an optimal (and possibly varying) number of
    /// frames based on host requirements and the requested latency settings.
    /// Note: With some host APIs, the use of non-zero frames_per_buffer for a callback stream may introduce an additional layer of buffering which could introduce
    /// additional latency. It is strongly recommended that a non-zero value only be used when your algorithm requires a fixed number of frames per stream callback.
    /// `stream_flags`: Flags which modify the behavior of the streaming process.
    /// `callback`: A client-supplied function that is responsible for processing and filling input and output buffers. If this parameter is null
    /// the stream will be opened in 'blocking read/write' mode. In blocking mode, the client can receive sample data using `Stream.read()` and write sample data
    /// using `Stream.write()`.
    /// `user_data`: A client-supplied pointer which is passed to the stream callback function. It is ignored if `callback` is null.
    ///
    /// Upon success `openStream()` returns a valid `Stream`. The stream is inactive (stopped).
    /// If a call fails, an error is returned.
    pub fn openStream(self: *Lib, input_params: ?StreamParameters, output_params: ?StreamParameters, sample_rate: f64, frames_per_buffer: u64, stream_flags: StreamFlags, callback: ?*const fn (
        input: ?*const anyopaque,
        output: ?*anyopaque,
        frame_count: u64,
        time_info: *const StreamCallbackTimeInfo,
        status_flags: StreamCallbackFlags,
        user_data: ?*anyopaque,
    ) CallbackResult, user_data: ?*anyopaque) !*Stream {
        var c_stream: ?*c.PaStream = null;

        var c_input: ?*const c.PaStreamParameters = null;
        var c_output: ?*const c.PaStreamParameters = null;
        var c_input_storage: c.PaStreamParameters = undefined;
        var c_output_storage: c.PaStreamParameters = undefined;

        if (input_params) |p| {
            c_input_storage = p.toC();
            c_input = &c_input_storage;
        }
        if (output_params) |p| {
            c_output_storage = p.toC();
            c_output = &c_output_storage;
        }

        var stream = try self.allocator.create(Stream);
        stream.* = .{
            .c_stream = undefined,
            .allocator = self.allocator,
            .callback_context = null,
            .finished_callback_context = null,
        };

        var c_callback: ?*const fn (
            ?*const anyopaque,
            ?*anyopaque,
            c_ulong,
            ?*const c.PaStreamCallbackTimeInfo,
            c.PaStreamCallbackFlags,
            ?*anyopaque,
        ) callconv(.c) c_int = null;

        var c_user_data: ?*anyopaque = null;

        if (callback) |cb| {
            const context = try self.allocator.create(Stream.CallbackContext);
            context.* = .{
                .callback = cb,
                .user_data = user_data,
            };
            stream.callback_context = context;
            c_callback = Stream.cCallback;
            c_user_data = stream;
        }

        const err = c.Pa_OpenStream(
            &c_stream,
            c_input,
            c_output,
            sample_rate,
            frames_per_buffer,
            stream_flags.toC(),
            c_callback,
            c_user_data,
        );

        if (err != c.paNoError) {
            if (stream.callback_context) |ctx| self.allocator.destroy(ctx);
            self.allocator.destroy(stream);
            return paErrorToError(err);
        }

        stream.c_stream = c_stream.?;
        return stream;
    }

    /// A simplified version of openStream() that opens the default input
    /// and/or output devices.
    /// `num_input_channels`: The number of channels of sound that will be supplied to the stream callback or returned by `Stream.read()`. If 0 the stream is opened as an output-only stream.
    /// `num_output_channels`: The number of channels of sound to be delivered to the stream callback or passed to `Stream.write()`. If 0 the stream is opened as an input-only stream.
    /// `sample_format`: The sample format of both the input and output buffers.
    /// `sample_rate`: Same as `openStream` parameter of the same name.
    /// `frames_per_buffer`: Same as `openStream` parameter of the same name.
    /// `callback`: Same as `openStream` parameter of the same name.
    /// `user_data`: Same as `openStream` parameter of the same name.
    pub fn openDefaultStream(self: *Lib, num_input_channels: c_int, num_output_channels: c_int, sample_format: SampleFormat, sample_rate: f64, frames_per_buffer: u64, callback: ?fn (
        input: ?*const anyopaque,
        output: ?*anyopaque,
        frame_count: u64,
        time_info: *const StreamCallbackTimeInfo,
        status_flags: StreamCallbackFlags,
        user_data: ?*anyopaque,
    ) CallbackResult, user_data: ?*anyopaque) !*Stream {
        var c_stream: ?*c.PaStream = null;

        var stream = try self.allocator.create(Stream);
        stream.* = .{
            .c_stream = undefined,
            .allocator = self.allocator,
            .callback_context = null,
            .finished_callback_context = null,
        };

        var c_callback: ?*const fn (
            ?*const anyopaque,
            ?*anyopaque,
            c_ulong,
            ?*const c.PaStreamCallbackTimeInfo,
            c.PaStreamCallbackFlags,
            ?*anyopaque,
        ) callconv(.c) c_int = null;

        var c_user_data: ?*anyopaque = null;

        if (callback) |cb| {
            const context = try self.allocator.create(Stream.CallbackContext);
            context.* = .{
                .callback = cb,
                .user_data = user_data,
            };
            stream.callback_context = context;
            c_callback = Stream.cCallback;
            c_user_data = stream;
        }

        const err = c.Pa_OpenDefaultStream(
            &c_stream,
            num_input_channels,
            num_output_channels,
            sample_format.toC(),
            sample_rate,
            frames_per_buffer,
            c_callback,
            c_user_data,
        );

        if (err != c.paNoError) {
            if (stream.callback_context) |ctx| self.allocator.destroy(ctx);
            self.allocator.destroy(stream);
            return paErrorToError(err);
        }

        stream.c_stream = c_stream.?;
        return stream;
    }
};

/// A higher-level, typed stream wrapper.
/// This provides a more convenient and type-safe API for reading, writing,
/// and processing audio samples of a specific type `T`.
pub fn TypedStream(comptime T: type) type {
    return struct {
        stream: *Stream,
        input_channel_count: c_int,
        output_channel_count: c_int,
        // This is the context we allocate for the typed callback and must free ourselves.
        typed_callback_context: ?*TypedCallbackContext,

        const Self = @This();

        pub const Callback = *const fn (
            input: ?[]const T,
            output: ?[]T,
            time_info: *const StreamCallbackTimeInfo,
            status_flags: StreamCallbackFlags,
            user_data: ?*anyopaque,
        ) CallbackResult;

        const TypedCallbackContext = struct {
            callback: Callback,
            user_data: ?*anyopaque,
            input_channel_count: c_int,
            output_channel_count: c_int,
        };

        /// This is the wrapper callback that will be passed to the underlying `lib.openStream`.
        /// It receives Zig-style anyopaque buffers and converts them to typed slices.
        fn typedCallbackWrapper(
            input: ?*const anyopaque,
            output: ?*anyopaque,
            frame_count: u64,
            time_info: *const StreamCallbackTimeInfo,
            status_flags: StreamCallbackFlags,
            user_data: ?*anyopaque,
        ) CallbackResult {
            const context = @as(*const TypedCallbackContext, @alignCast(@ptrCast(user_data.?)));

            const input_slice: ?[]const T = if (input) |ptr|
                @as([*]const T, @ptrCast(@alignCast(ptr)))[0 .. frame_count * @as(u64, @intCast(context.input_channel_count))]
            else
                null;

            const output_slice: ?[]T = if (output) |ptr|
                @as([*]T, @ptrCast(@alignCast(ptr)))[0 .. frame_count * @as(u64, @intCast(context.output_channel_count))]
            else
                null;

            return context.callback(input_slice, output_slice, time_info, status_flags, context.user_data);
        }

        fn sampleFormatFromType() SampleFormat {
            return comptime switch (T) {
                f32 => .{ .float32 = true },
                i32 => .{ .int32 = true },
                i16 => .{ .int16 = true },
                i8 => .{ .int8 = true },
                u8 => .{ .uint8 = true },
                else => @compileError("unsupported sample type " ++ @typeName(T)),
            };
        }

        pub fn open(
            lib: *Lib,
            input_params: anytype,
            output_params: anytype,
            sample_rate: f64,
            frames_per_buffer: u64,
            stream_flags: StreamFlags,
            callback: ?Callback,
            user_data: ?*anyopaque,
        ) !Self {
            var pa_input: ?StreamParameters = null;
            var pa_output: ?StreamParameters = null;

            if (@TypeOf(input_params) != @TypeOf(null)) {
                comptime std.debug.assert(@hasField(@TypeOf(input_params), "device") and @hasField(@TypeOf(input_params), "channel_count") and @hasField(@TypeOf(input_params), "suggested_latency"));
                pa_input = StreamParameters{
                    .device = input_params.device,
                    .channel_count = input_params.channel_count,
                    .sample_format = sampleFormatFromType(),
                    .suggested_latency = input_params.suggested_latency,
                    .host_api_specific_stream_info = if (@hasField(@TypeOf(input_params), "host_api_specific_stream_info")) input_params.host_api_specific_stream_info else null,
                };
            }

            if (@TypeOf(output_params) != @TypeOf(null)) {
                comptime std.debug.assert(@hasField(@TypeOf(output_params), "device") and @hasField(@TypeOf(output_params), "channel_count") and @hasField(@TypeOf(output_params), "suggested_latency"));
                pa_output = StreamParameters{
                    .device = output_params.device,
                    .channel_count = output_params.channel_count,
                    .sample_format = sampleFormatFromType(),
                    .suggested_latency = output_params.suggested_latency,
                    .host_api_specific_stream_info = if (@hasField(@TypeOf(output_params), "host_api_specific_stream_info")) output_params.host_api_specific_stream_info else null,
                };
            }

            var untyped_callback: ?*const fn (
                input: ?*const anyopaque,
                output: ?*anyopaque,
                frame_count: u64,
                time_info: *const StreamCallbackTimeInfo,
                status_flags: StreamCallbackFlags,
                user_data: ?*anyopaque,
            ) CallbackResult = null;
            var untyped_user_data: ?*anyopaque = null;
            var typed_ctx: ?*TypedCallbackContext = null;

            if (callback) |cb| {
                const context = try lib.allocator.create(TypedCallbackContext);
                context.* = .{
                    .callback = cb,
                    .user_data = user_data,
                    .input_channel_count = if (@TypeOf(input_params) != @TypeOf(null)) input_params.channel_count else 0,
                    .output_channel_count = if (@TypeOf(output_params) != @TypeOf(null)) output_params.channel_count else 0,
                };
                typed_ctx = context;
                untyped_callback = typedCallbackWrapper;
                untyped_user_data = context;
            }

            const stream = try lib.openStream(
                pa_input,
                pa_output,
                sample_rate,
                frames_per_buffer,
                stream_flags,
                untyped_callback,
                untyped_user_data,
            );

            return Self{
                .stream = stream,
                .input_channel_count = if (@TypeOf(input_params) != @TypeOf(null)) input_params.channel_count else 0,
                .output_channel_count = if (@TypeOf(output_params) != @TypeOf(null)) output_params.channel_count else 0,
                .typed_callback_context = typed_ctx,
            };
        }

        pub fn close(self: *Self) Error!void {
            if (self.typed_callback_context) |ctx| {
                self.stream.allocator.destroy(ctx);
            }

            try self.stream.close();
        }

        /// Write interleaved samples to an output stream.
        /// The number of frames is inferred from `buffer.len / self.output_channel_count`.
        pub fn write(self: *Self, buffer: []const T) Error!void {
            std.debug.assert(self.output_channel_count > 0);
            const frames = @as(u64, @intCast(buffer.len / @as(usize, @intCast(self.output_channel_count))));
            try self.stream.write(buffer.ptr, frames);
        }

        /// Read interleaved samples from an input stream.
        /// The number of frames is inferred from `buffer.len / self.input_channel_count`.
        pub fn read(self: *Self, buffer: []T) Error!void {
            std.debug.assert(self.input_channel_count > 0);
            const frames = @as(u64, @intCast(buffer.len / @as(usize, @intCast(self.input_channel_count))));
            try self.stream.read(buffer.ptr, frames);
        }

        /// See `Stream.setFinishedCallback` for documentation.
        pub fn setFinishedCallback(
            self: *Self,
            callback: fn (user_data: ?*anyopaque) void, // TODO: This should be a typed callback
            user_data: ?*anyopaque,
        ) !void {
            return self.stream.setFinishedCallback(callback, user_data);
        }

        pub fn start(self: *Self) Error!void {
            return self.stream.start();
        }

        pub fn stop(self: *Self) Error!void {
            return self.stream.stop();
        }

        pub fn abort(self: *Self) Error!void {
            return self.stream.abort();
        }

        pub fn isStopped(self: *const Self) Error!bool {
            return self.stream.isStopped();
        }

        pub fn isActive(self: *const Self) Error!bool {
            return self.stream.isActive();
        }

        /// See `Stream.getInfo` for documentation.
        pub fn getInfo(self: *const Self) ?StreamInfo {
            return self.stream.getInfo();
        }

        /// See `Stream.getTime` for documentation.
        pub fn getTime(self: *const Self) Time {
            return self.stream.getTime();
        }

        /// See `Stream.getCpuLoad` for documentation.
        pub fn getCpuLoad(self: *const Self) f64 {
            return self.stream.getCpuLoad();
        }

        /// See `Stream.getReadAvailable` for documentation.
        pub fn getReadAvailable(self: *const Self) Error!u64 {
            return self.stream.getReadAvailable();
        }

        /// See `Stream.getWriteAvailable` for documentation.
        pub fn getWriteAvailable(self: *const Self) Error!u64 {
            return self.stream.getWriteAvailable();
        }
    };
}

/// Library initialization function - call this before using PortAudio.
/// This function initializes internal data structures and prepares underlying
/// host APIs for use. With the exception of `getVersion()`, `getVersionText()`,
/// and `getErrorText()`, this function MUST be called before using any other
/// PortAudio API functions.
///
/// If `init()` is called multiple times, each successful call must be matched
/// with a corresponding call to `deinit()`. Pairs of calls may overlap, and are not
/// required to be fully nested.
///
/// Note that if `init()` returns an error, `deinit()` should NOT be called.
///
/// Example:
/// ```
/// var pa = try portaudio.init(std.heap.page_allocator);
/// defer pa.deinit();
///
/// const device_count = try pa.getDeviceCount();
/// std.debug.print("Number of devices: {d}\n", .{device_count});
/// ```
pub fn init(allocator: std.mem.Allocator) !Lib {
    return Lib.init(allocator);
}
