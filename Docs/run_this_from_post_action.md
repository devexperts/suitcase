## Add the following script as Post-action to your Target's scheme in Test section

```sh
# Log file path where script actions should be written for debug purposes.
# Add as User-Defined Setting in Build Settings.
if [[ -z "$SUITCASE_LOG_FILE_PATH" ]]; then
    SUITCASE_LOG_FILE_PATH="/dev/null 2>&1"
fi

rm "$SUITCASE_LOG_FILE_PATH"

if [[ $PLATFORM_NAME != "iphoneos" ]]; then
    echo "Not running on iPhone, exiting" >> "$SUITCASE_LOG_FILE_PATH"
    exit
fi

# remote path - this path is valid if you install SUITCase as a remote package
SWIFT_PACKAGES_PATH="${BUILD_DIR%Build/*}SourcePackages/checkouts"
SCRIPT_PATH="$SWIFT_PACKAGES_PATH/suitcase/Scripts/get_device_screenshots.sh"

if test -f "$SCRIPT_PATH"; then
    echo "Script found at '$SCRIPT_PATH'" >> "$SUITCASE_LOG_FILE_PATH"
else 
    echo "Script not found at '$SCRIPT_PATH'" >> "$SUITCASE_LOG_FILE_PATH"
    
    # Try local path if it is set, can be used if you install SUITCase as a local package.
    # Add as User-Defined Setting in Build Settings.
    if [[ -z $SUITCASE_LOCAL_SCRIPT_PATH ]]; then
        echo "Local path not set too, exiting" >> "$SUITCASE_LOG_FILE_PATH"
        exit
    fi
    
    SCRIPT_PATH=$SUITCASE_LOCAL_SCRIPT_PATH
    
    if test -f "$SCRIPT_PATH"; then
        echo "Script found at '$SCRIPT_PATH'" >> "$SUITCASE_LOG_FILE_PATH"
    else 
        echo "Script not found at '$SCRIPT_PATH', exiting" >> "$SUITCASE_LOG_FILE_PATH"
        exit
    fi
fi

# Path where to save test images retrieved from device.
# Add as User-Defined Setting in Build Settings.
if [[ -z "$SUITCASE_IMAGES_DIR" ]]; then
    echo "SUITCASE_IMAGES_DIR environment variable not set, exiting" >> "$SUITCASE_LOG_FILE_PATH"
    exit
fi

# Images relative path inside application container on device without leading slash.
# Add as User-Defined Setting in Build Settings.
if [[ -z "$SUITCASE_DEVICE_IMAGES_DIR" ]]; then
    echo "SUITCASE_DEVICE_IMAGES_DIR environment variable not set, exiting" >> "$SUITCASE_LOG_FILE_PATH"
    exit
fi

# Tests target bundle id. This will be a runner app where images will be saved
TESTS_TARGET_BUNDLE_ID="$PRODUCT_BUNDLE_IDENTIFIER"

# Run configured script
"$SCRIPT_PATH" "$TESTS_TARGET_BUNDLE_ID" "$SUITCASE_DEVICE_IMAGES_DIR" "$SUITCASE_IMAGES_DIR" "$SUITCASE_LOG_FILE_PATH"
```
