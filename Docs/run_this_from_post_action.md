## Add the following script as Post-action to your Target's scheme in Test section

```sh
# Log file path where script actions will be saved for debug purposes,
# should be added in test targets' Build Settings > User-Defined
if [[ ! -z "$LOG_FILE_PATH" ]]; then
    LOG_FILE_PATH="$PROJECT_DIR/TestPostActions.log"
fi

rm "$LOG_FILE_PATH"

if [[ $PLATFORM_NAME != "iphoneos" ]]; then
    echo "Not running on iPhone, exiting" >> "$LOG_FILE_PATH"
    exit
fi

# remote path - this path is valid if you install SUITCase as a remote package
SWIFT_PACKAGES_PATH="${BUILD_DIR%Build/*}SourcePackages/checkouts"
SCRIPT_PATH="$SWIFT_PACKAGES_PATH/suitcase/Scripts/get_device_screenshots.sh"

if test -f "$SCRIPT_PATH"; then
    echo "Script found at '$SCRIPT_PATH'" >> "$LOG_FILE_PATH"
else 
    echo "Script not found at '$SCRIPT_PATH'" >> "$LOG_FILE_PATH"
    
    # Try local path if it is set, can be used if you install SUITCase as a local package
    # should be added in test targets' Build Settings > User-Defined as absolute path
    if [[ -z $LOCAL_SCRIPT_PATH ]]; then
        echo "Local path not set too, exiting" >> "$LOG_FILE_PATH"
        exit
    fi
    
    SCRIPT_PATH=$LOCAL_SCRIPT_PATH
    
    if test -f "$SCRIPT_PATH"; then
        echo "Script found at '$SCRIPT_PATH'" >> "$LOG_FILE_PATH"
    else 
        echo "Script not found at '$SCRIPT_PATH', exiting" >> "$LOG_FILE_PATH"
        exit
    fi
fi

# Path where to save test images retrieved from device,
# should be added in test targets' Build Settings > User-Defined
if [[ -z "$IMAGES_DIR" ]]; then
    echo "IMAGES_DIR environment variable not set, exiting" >> "$LOG_FILE_PATH"
    exit
fi

# Images relative path inside application container without leading slash,
# should be added in test targets' Build Settings > User-Defined
# for instance FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TestImages").path
if [[ -z "$IMAGES_CONTAINER_PATH" ]]; then
    echo "IMAGES_CONTAINER_PATH environment variable not set, exiting" >> "$LOG_FILE_PATH"
    exit
fi

# Tests target bundle id. This will be a runner app where images will be saved
TESTS_TARGET_BUNDLE_ID="$PRODUCT_BUNDLE_IDENTIFIER"

# run configured script
"$SCRIPT_PATH" "$TESTS_TARGET_BUNDLE_ID" "$IMAGES_CONTAINER_PATH" "$IMAGES_DIR" "$LOG_FILE_PATH"

```
