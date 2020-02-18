# this example is translated and tweaked from the following link:
# https://github.com/IntelRealSense/librealsense/blob/master/examples/C/depth/rs-depth.c
using RealSense
using Images

include("rs-utils.jl")

STREAM        = RS2_STREAM_DEPTH  # rs2_stream is a types of data provided by RealSense device
FORMAT        = RS2_FORMAT_Z16    # rs2_format is identifies how binary data is encoded within a frame
WIDTH         = 640               # defines the number of columns for each frame
HEIGHT        = 480               # defines the number of lines for each frame
FPS           = 30                # defines the rate of frames per second
STREAM_INDEX  = 0                 # defines the stream index, used for multiple streams of the same type

# the number of meters represented by a single depth unit
function get_depth_unit_value(dev)
    err = Ref{Ptr{rs2_error}}(0)
    sensor_list = rs2_query_sensors(dev, err)
    check_error(err)

    num_of_sensors = rs2_get_sensors_count(sensor_list, err)
    check_error(err)

    depth_scale = Float32(0)
    is_depth_sensor_found = 0
    for i = 0:num_of_sensors-1
        sensor = rs2_create_sensor(sensor_list, i, err)
        check_error(err)

        # check if the given sensor can be extended to depth sensor interface
        is_depth_sensor_found = rs2_is_sensor_extendable_to(sensor, RS2_EXTENSION_DEPTH_SENSOR, err)
        check_error(err)

        if 1 == is_depth_sensor_found
            depth_scale = rs2_get_option(sensor, RS2_OPTION_DEPTH_UNITS, err)
            check_error(err)
            rs2_delete_sensor(sensor)
            break
        end
        rs2_delete_sensor(sensor)
    end

    rs2_delete_sensor_list(sensor_list)

    @assert 1 == is_depth_sensor_found "Depth sensor not found!"

    return depth_scale
end


err = Ref{Ptr{rs2_error}}(0)

# create context
ctx = rs2_create_context(RS2_API_VERSION, err)
check_error(err)

# get a list of all the connected devices
device_list = rs2_query_devices(ctx, err)
check_error(err)

dev_count = rs2_get_device_count(device_list, err)
check_error(err)
println("There are $dev_count connected RealSense devices.")

# get the first connected device
dev = rs2_create_device(device_list, 0, err)
print_device_info(dev)

# determine depth value corresponding to one meter
one_meter = round(UInt16, 1.0 / get_depth_unit_value(dev))

# create pipeline
_pipeline = rs2_create_pipeline(ctx, err)
check_error(err)

# create a config instance
config = rs2_create_config(err)
check_error(err)

# request a specific configuration
rs2_config_enable_stream(config, STREAM, STREAM_INDEX, WIDTH, HEIGHT, FORMAT, FPS, err)
check_error(err)

# start the pipeline streaming
@static if is_apple()
    # we sleep 1s on MacOS, otherwise it will hit issue #1586:
    # https://github.com/IntelRealSense/librealsense/issues/1586
    sleep(1)
end
pipeline_profile = rs2_pipeline_start_with_config(_pipeline, config, err)
@assert err[] == C_NULL "The connected device doesn't support depth streaming!"


pixels = collect(" .,'`^:;lI!i<>~+-?[]{}1|()*oawmzcvunxrhkbdpqjftLCJUO0QYX%B8&WM#Z@")
while true
    frames = rs2_pipeline_wait_for_frames(_pipeline, 5000, err)
    check_error(err)

    # returns the number of frames embedded within the composite frame
    num_of_frames = rs2_embedded_frames_count(frames, err)
    check_error(err)

    for i = 0:num_of_frames-1
        # the retunred object should be released with rs2_release_frame(...)
        frame = rs2_extract_frame(frames, i, err)
        check_error(err)

        # check if the given frame can be extended to depth frame interface
        # accept only depth frames and skip other frames
        0 == rs2_is_frame_extendable_to(frame, RS2_EXTENSION_DEPTH_FRAME, err) && continue

        # retrieve depth data, configured as 16-bit depth values
        depth_frame_data = Ptr{UInt16}(rs2_get_frame_data(frame, err))
        check_error(err)

        # manipulate data
        depth_image_raw = unsafe_wrap(Array, depth_frame_data, (WIDTH,HEIGHT))
        img = imresize(depth_image_raw, (80,60))
        buffer = fill('\n', (81,60))
        for y = 1:60, x = 1:80
            pixel_index = Int(img[x,y] ÷ ceil(maximum(img) / 64) + 1)
            buffer[x,y] = pixels[pixel_index]
        end
        print(string(buffer...))

        rs2_release_frame(frame)
    end
    rs2_release_frame(frames)
end

# stop the pipeline streaming
rs2_pipeline_stop(_pipeline, err)
check_error(err)

# release resources
rs2_delete_pipeline_profile(pipeline_profile)
rs2_delete_config(config)
rs2_delete_pipeline(_pipeline)
rs2_delete_device(dev)
rs2_delete_device_list(device_list)
rs2_delete_context(ctx)
