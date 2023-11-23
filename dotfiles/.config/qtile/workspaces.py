# Workspace setup
# Get the icons at https://www.nerdfonts.com/cheat-sheet

from libqtile.config import Match

workspaces = [
    {
        "name": " ₁",
        "key": "1",
        "matches": [
            Match(wm_class='firefox'),
        ],
        "layout": "monadtall",
        "spawn": [],
    },
    {
        "name": " ₂",
        "key": "2",
        "matches": [
            Match(wm_class='foot'),
            Match(wm_class='ranger'),
        ],
        "layout": "monadtall",
        "spawn": [],
    },
    {
        "name": " ₃",
        "key": "3",
        "matches": [
            Match(wm_class='nvim'),
        ],
        "layout": "monadtall",
        "spawn": [],
    },
    {
        "name": " ₅",
        "key": "5",
        "matches": [
            Match(wm_class='gimp-2.99'),
        ],
        "layout": "monadtall",
        "spawn": [],
    }
]
