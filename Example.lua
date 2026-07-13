-- NTG UI Library - Glass 2.0 Example

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/JJacKTH/NTG-UI-Library/main/Loader.lua"))()

local Window = UI:CreateWindow({
    Title = "Glass 2.0 Demo",
    GameName = "DemoGame",
    ConfigName = "GlassDemo",
    Theme = "GlassDark",
    Size = UDim2.new(0, 600, 0, 500),
    ToggleKey = Enum.KeyCode.RightShift,
    CenterOnToggle = true,
    AutoSave = true,
    AutoLoad = true,
    FloatingIcon = {
        Enabled = true,
        Position = UDim2.new(0, 24, 0.5, 0)
    }
})

local Dashboard = Window:CreateTab({ Name = "Dashboard" })
Dashboard:AddDivider({ Name = "Main Controls" })

Dashboard:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Enable Feature:", value)
    end
})

Dashboard:AddDropdown({
    Name = "Select Option",
    Options = { "Option 1", "Option 2", "Option 3" },
    Default = "Option 1",
    Searchable = true,
    Flag = "SelectedOption",
    Callback = function(value)
        print("Selected Option:", value)
    end
})

Dashboard:AddSlider({
    Name = "Adjust Value",
    Min = 0,
    Max = 100,
    Default = 75,
    Flag = "AdjustValue",
    Callback = function(value)
        print("Adjust Value:", value)
    end
})

Dashboard:AddColorPicker({
    Name = "Choose Color",
    Default = Color3.fromRGB(138, 92, 255),
    Flag = "ChooseColor",
    Callback = function(color)
        print("Choose Color:", color)
    end
})

Dashboard:AddKeybind({
    Name = "Set Keybind",
    Default = Enum.KeyCode.RightShift,
    Flag = "SetKeybind",
    Callback = function()
        Window:Toggle()
    end
})

local Tools = Window:CreateTab({ Name = "Tools" })
local ToolsSection = Tools:AddSection({
    Name = "Quick Actions",
    Collapsed = false
})

ToolsSection:AddButton({
    Name = "Teleport",
    Callback = function()
        print("Teleport")
    end
})

ToolsSection:AddButton({
    Name = "Rejoin",
    Callback = function()
        print("Rejoin")
    end
})

ToolsSection:AddTextbox({
    Name = "Target Player",
    Placeholder = "Type player name",
    Flag = "TargetPlayer",
    Callback = function(value)
        print("Target Player:", value)
    end
})

local Settings = Window:CreateTab({ Name = "Settings" })
Settings:AddDivider({ Name = "Appearance" })

Settings:AddDropdown({
    Name = "Theme",
    Options = { "GlassDark", "GlassLight" },
    Default = "GlassDark",
    Callback = function(value)
        Window:SetTheme(value)
    end
})

Settings:AddButton({
    Name = "Save Config",
    Callback = function()
        Window:SaveConfig()
    end
})

Settings:AddButton({
    Name = "Load Config",
    Callback = function()
        Window:LoadConfig()
    end
})
