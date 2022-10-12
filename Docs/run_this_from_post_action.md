# Add the following script as Post-action to your Target's scheme in Test section, set needed values:

```sh
# set log file path where get_device_screenshots.sh script actions will be saved for debug purposes
LOG_FILE_PATH="$PROJECT_DIR/TestPostActions.log"
rm "$LOG_FILE_PATH"

# remote path - this path is valid if you install SUITCase as a remote package
SWIFT_PACKAGES_PATH="${BUILD_DIR%Build/*}SourcePackages/checkouts"
SCRIPT_PATH="$SWIFT_PACKAGES_PATH/suitcase/Scripts/get_device_screenshots.sh"
# local path - set manually if you add SUITCase as a local package
LOCAL_SCRIPT_PATH="/Users/user/Documents/xcode/OpenHack/suitcase/Scripts/get_device_screenshots.sh"

if test -f "$SCRIPT_PATH"; then
    echo "Script found at '$SCRIPT_PATH'" >> "$LOG_FILE_PATH"
else 
    echo "Script not found at '$SCRIPT_PATH'" >> "$LOG_FILE_PATH"
    
    # try local path if it is set
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

# set path where to save test images retrieved from device
TEST_IMAGES_DESTINATION_PATH="$PROJECT_DIR/TestImages"

# set test images relative path inside application container without leading slash
# for instance FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TestImages").path
TEST_IMAGES_SOURCE_PATH="Documents/TestImages"

# set tests target bundle id. This will be a runner app where images will be saved
TESTS_TARGET_BUNDLE_ID="com.suitcase.SUITCaseExampleAppUITests" 

# run configured script
"$SCRIPT_PATH" "$TESTS_TARGET_BUNDLE_ID" "$TEST_IMAGES_SOURCE_PATH" "$TEST_IMAGES_DESTINATION_PATH" "$LOG_FILE_PATH"
```