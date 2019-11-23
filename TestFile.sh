#!/bin/bash

# -----------------------------------------------------------------------------
# Work in progress test file.
#
# Tests functions which manage the cache files of video real time stamps.
# -----------------------------------------------------------------------------

# Configure debug mode for testing this script. Set this value to blank "" for
# running in the final functional mode on the Synology Task Scheduler.
debugMode=""         # True final runtime mode for Synology.
# debugMode="Synology" # Test on Synology SSH prompt, console or redirect output.
# debugMode="MacHome"  # Test on Mac at home, LAN connection to Synology.
# debugMode="MacAway"  # Test on Mac away from home, no connection to Synology.
debugMode="WinAway"  # In the jungle, the mighty jungle.

# Program name used in log messages.
programname="CrowCam Test File"

# Get the directory of the current script so that we can find files in the
# same folder as this script, regardless of the current working directory. The
# technique was learned here: https://stackoverflow.com/a/246128/3621748
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load the configuration file "crowcam-config", which contains variables that
# are user-specific.
source "$DIR/crowcam-config"

# Load the include file "CrowCamHelperFunctions.sh", which contains shared
# functions that are used in multiple scripts.
source "$DIR/CrowCamHelperFunctions.sh"

# Filenames for data files this program reads or writes.
videoData="crowcam-videodata"
videoRealTimestamps="crowcam-realtimestamps"

# Log the current test mode state, if activated.
if [ ! -z "$debugMode" ]
then
  LogMessage "err" "------------- Script $programname is running in debug mode: $debugMode -------------"
fi
 
# Authenticate with the YouTube API and receive the Access Token which allows
# us to make YouTube API calls. Retrieves the $accessToken variable.
YouTubeApiAuth

# If the access Token is empty, crash out of the program. An error message
# will have already been printed if this is the case, so we can just bail
# out without saying anything to the console here.
if test -z "$accessToken" 
then
    exit 1
fi

# Create a list of video IDs to use for testing the behavior of the new functions.
videoIds=( "xRlO9D3xigU" "-k9E41Xtv5s" "feA8mkTI1-s" "HzcqJp0AqDU" "fN8Xj7PkUHY" "ptOU01miz7s" "_LrYCdxnE7A" )

# Loop through the list of test items.
for ((i = 0; i < ${#videoIds[@]}; i++))
do
    oneVideoId=${videoIds[$i]}

    # Test reading an item from the cache. The GetRealTimes function will read
    # the data from the YouTube API if there is a cache miss.
    timeResponseString=""
    timeResponseString=$( GetRealTimes "$oneVideoId" )
    LogMessage "dbg" "Response: $oneVideoId: $timeResponseString"

    # Place the cache responses into variables, test making sure this works.
    read -r oneVideoId actualStartTime actualEndTime <<< "$timeResponseString"

    # Display the output of the variables (compare with string response above).
    LogMessage "dbg" "Values:   $oneVideoId              $actualStartTime $actualEndTime"
done

# Pause the program before testing the cache cleaning features.
read -n1 -r -p "Press space to clean the cache..." key

# Loop through each item in the test list and clean the cache.
for ((i = 0; i < ${#videoIds[@]}; i++))
do
    # Break out of the loop early to make sure it's partially deleting,
    # as expected. Comment out this section to prune all entries in the test.
    if [ "$i" -gt "3" ]
    then
        break
    fi
    
    # Perform the cache item deletion.
    oneVideoId=${videoIds[$i]}
    DeleteRealTimes "$oneVideoId"
done
