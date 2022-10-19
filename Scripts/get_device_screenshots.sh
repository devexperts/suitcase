#!/bin/bash

#
# Add the following script as Post-action to your Target's scheme in Test section, set needed values:
#
# SCRIPT_PATH="$PROJECT_DIR/get_device_screenshots.sh"
# # set path where to save test images retrieved from device
# TEST_IMAGES_DESTINATION_PATH="$PROJECT_DIR/TestImages" 
# # set test images relative path inside application container without leading slash
# # for instance FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TestImages").path
# TEST_IMAGES_SOURCE_PATH="Documents/TestImages"
# # set tests target bundle id. This will be a runner app where images will be saved
# TESTS_TARGET_BUNDLE_ID="com.suitcase.SUITCaseExampleAppUITests" 
# "$SCRIPT_PATH" "$TESTS_TARGET_BUNDLE_ID" "$TEST_IMAGES_SOURCE_PATH" "$TEST_IMAGES_DESTINATION_PATH"


LOG_FILE_PATH="$4"

MOUNT_DIR="$HOME/fuse_mount_point"
echo "Mount point $MOUNT_DIR" >> "$LOG_FILE_PATH"

mkdir "$MOUNT_DIR"

# get input

TESTS_TARGET_BUNDLE_ID="$1.xctrunner"
TEST_IMAGES_SOURCE_PATH="$MOUNT_DIR/$2"
TEST_IMAGES_DESTINATION_PATH="$3"

echo "Got following data:" >> "$LOG_FILE_PATH"
echo "-- Bundle identifier '$TESTS_TARGET_BUNDLE_ID'" >> "$LOG_FILE_PATH"
echo "-- Images source path '$TEST_IMAGES_SOURCE_PATH'" >> "$LOG_FILE_PATH"
echo "-- Images destination path '$TEST_IMAGES_DESTINATION_PATH'" >> "$LOG_FILE_PATH"

# mount app container

echo "(Re)mounting '$TESTS_TARGET_BUNDLE_ID'" >> "$LOG_FILE_PATH"
# unmount container (if already mounted) to avoid copying error,
# make it forcibly (with -f flag) to get updated mounted container
umount -f -v "$MOUNT_DIR" >> "$LOG_FILE_PATH" 2>&1
# mount container
ifuse --debug --container $TESTS_TARGET_BUNDLE_ID "$MOUNT_DIR" >> "$LOG_FILE_PATH" 2>&1

# copy images

echo "Copying images from $TEST_IMAGES_SOURCE_PATH to $TEST_IMAGES_DESTINATION_PATH"
cp -r "$TEST_IMAGES_SOURCE_PATH" "$TEST_IMAGES_DESTINATION_PATH" >> "$LOG_FILE_PATH" 2>&1



