# myth_rename
Renames files created by MythTV using their original names

Tested up to mythtv 0.28.1 (June 2017)

Eg:

FROM: 8710_20170604184900.mpg
TO: Engineering_Giants_20170601212900_Gas_Rig_Strip-Down.mpg

Why: I use mythtv to record TV programs. However, I do not use Mythtv to watch it. Instead, I share the saved program directory on my local network and simply play the programs using VLC or Media Player Classic on my windows clients.

Myth saves the files in a non-human friendly and the developers were not interested in changing that when I suggested it as a feature - so I wrote a simple script.

NOTE: This will prevent Mythtv-frontend or any third party program that takes a feed from Myth to play these files as Mythtv developers intended. You could probably update the code to point to the new name if you wished - I never had a need to.

Setup:
1. Change the path to the saved files dir.
2. If you are not using the default mysql password, set that too.

This script should be run via cron by a user with read/write privs to the data. I run it every five minutes since it is lightweight. 

When run it:

1. Checks the directory to see if there is any file there that matches the digit-only format that MythTV records in, and ends with .mpg or .ts
2. Checks that the file was last written to at least 100 seconds ago. (So it doesn't try to rename files that are still being recorded)
3. Connects to the mythtv database and looks up the relevant information for the recorded program.
4. Renames the file with the human readable filename: Series_Name_DateTime_Episode_Name.mpg



