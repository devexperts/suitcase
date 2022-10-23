#!/bin/bash

#
# See Docs/run_this_from_post_action.md for configuration script
#

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

# sync images

echo "Syncing images between $TEST_IMAGES_SOURCE_PATH and $TEST_IMAGES_DESTINATION_PATH" >> "$LOG_FILE_PATH"
echo "-- source -> target" >> "$LOG_FILE_PATH"
rsync -rtuv "$TEST_IMAGES_SOURCE_PATH/" "$TEST_IMAGES_DESTINATION_PATH" >> "$LOG_FILE_PATH" 2>&1
echo "-- target -> source" >> "$LOG_FILE_PATH"
rsync -rtuv "$TEST_IMAGES_DESTINATION_PATH/" "$TEST_IMAGES_SOURCE_PATH" >> "$LOG_FILE_PATH" 2>&1



