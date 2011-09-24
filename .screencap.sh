#!/bin/sh

# Integrates Mac OS X's screenshot utility with DropBox for easy sharing.

# Starts the interactive screenshot tool, saves it to your public
# Dropbox (if you don't cancel it) where it will be uploaded automatically.
# Copies the public URL to your clipboard and opens your browser to the URL.

## Config
dropbox_id="10809"
dropbox_public_folder="$HOME/Dropbox/Public/screenshots"
upload_delay_in_second=2

## Derivative Variables
filename=$(date '+%F__%H-%M-%S.png')
save_to="$dropbox_public_folder/$filename"
url="http://dl.dropbox.com/u/$dropbox_id/screenshots/$filename"

## start interactive screen capture
screencapture -i "$save_to"

## if the screenshot actually saved to a file (user didn't cancel by pressing escape)
if [[ -e "$save_to" ]]; then
    ## echo some output in case you run this in a shell
    echo "Saved screenshot to:" "$save_to"

    ## copy url to the clipboard
    echo "$url" | pbcopy

    ## wait for Dropbox to upload your screenshot, then open in your browser
    sleep $upload_delay_in_second
    ## The `-g` flag means it won't bring your browser to the foreground, which 
    ## feels less like getting interrupted.
    open -g "$url"
fi
