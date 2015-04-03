tell application "Finder"
    mount volume "smb://192.168.1.1/nas"
end tell

tell application "Finder"
    try
        mount volume "afp://ryan@192.168.1.30/iTunes Media"
    end try
end tell
