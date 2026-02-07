# RaidSwitcherFix

RaidSwitcherFix tries to fix the problem where the "Auto-Activate on" option in Blizzard's raid profiles doesn't work properly (doesn't automatically activate when you would expect it to).
The addon checks if we should activate a new raid profile when:
    1. Joining a group/raid
    2. The number of group members change.
It uses the Blizzard's default raid profile interface to detect which profile we should activate.
OPTIONS:
    - Debug mode lets you see detailed information on how the addon activates a raid profile
COMMANDS:
     - /rsf, checks if we should activate a new raid profile
     - /RaidSwitcherFix, opens settings panel

Backported for 3.3.5, tested on Bronzebeard - Project Ascension
