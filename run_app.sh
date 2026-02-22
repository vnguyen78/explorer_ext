#!/bin/bash

# Path to the build product in DerivedData
APP_PATH="/Users/admin/Library/Developer/Xcode/DerivedData/explore_txt_view-gmkbiaubrldmzxgpljtcsjmzepwg/Build/Products/Debug/explore_txt_view.app"

if [ -d "$APP_PATH" ]; then
    echo "Launching explore_txt_view from: $APP_PATH"
    open "$APP_PATH"
else
    echo "Error: Application not found at $APP_PATH"
    echo "Please build the project in Xcode (Cmd+R) first."
fi
