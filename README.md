# NTG UI Library

A glass-style Roblox Luau UI library with frosted panels, rounded cards, configurable themes, autosave, and searchable dropdowns.

## Glass 2.0

- Frosted window shell
- Rounded tab pills and glass cards
- Stronger depth, strokes, and layered panels
- Dark and light glass themes

## Components

- Button
- Toggle
- Textbox
- Dropdown
- Slider
- ColorPicker
- Keybind
- Label
- Section
- Divider
- Notification

## Quick Start

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/JJacKTH/NTG-UI-Library/main/Loader.lua"))()

local Window = UI:CreateWindow({
    Title = "My Hub",
    GameName = "MyGame",
    ConfigName = "Main",
    Theme = "GlassDark",
    ToggleKey = Enum.KeyCode.RightShift,
    CenterOnToggle = true,
    AutoSave = true,
    AutoLoad = true,
    FloatingIcon = { Enabled = true }
})

local Tab = Window:CreateTab({ Name = "Main" })

Tab:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Toggle:", value)
    end
})

Tab:AddDropdown({
    Name = "Select Option",
    Options = { "Option 1", "Option 2", "Option 3" },
    Searchable = true,
    Flag = "SelectedOption",
    Callback = function(value)
        print("Selected:", value)
    end
})

Tab:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Flag = "Speed",
    Callback = function(value)
        print("Value:", value)
    end
})
```

## Example Layout

Use [`Example.lua`](./Example.lua) for a full glass-themed demo that includes:

- Dashboard-style controls
- Section and divider layout
- Keybinds
- Color picker
- Save/load actions

## Notes

- `Flag` enables config persistence for supported components.
- `GameName` and `ConfigName` are separate so configs stay organized.
- `Theme` can be switched between `GlassDark` and `GlassLight`.
