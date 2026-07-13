--[[
    NTG UI Library - Full Example
    ตัวอย่างการใช้งานครบทุก Component
    
    Features:
    - Section + Divider
    - Resizable Window
    - All UI Components
    - Config Save/Load
]]

-- โหลด Library
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/JJacKTH/NTG-UI/main/Loader.lua"))()

-- ================================================================
-- สร้าง Window (พร้อม Resize)
-- ================================================================
local Window = UI:CreateWindow({
    Title = "BloxFruit Hub",
    GameName = "BloxFruit",
    ConfigName = "Config",
    Theme = "Dark",
    Size = UDim2.new(0, 550, 0, 450),
    
    -- Resize Options
    Resizable = true,                      -- เปิดใช้ยืดหด
    MinSize = UDim2.new(0, 400, 0, 300),   -- ขนาดต่ำสุด
    MaxSize = UDim2.new(0, 800, 0, 600),   -- ขนาดสูงสุด
    SaveSize = true,                       -- บันทึกขนาด
    
    AutoSave = true,
    AutoLoad = true,
    FloatingIcon = {
        Enabled = true,
        Position = UDim2.new(0, 20, 0.5, 0)
    }
})

-- ================================================================
-- Tab: Main Functions
-- ================================================================
local MainTab = Window:CreateTab({ Name = "🎮 Main" })

-- Divider: แสดงหัวข้อแบบ ═══ Farm ═══
MainTab:AddDivider({ Name = "🌾 Auto Farm" })

-- Toggle: Auto Farm
MainTab:AddToggle({
    Name = "Enable Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

-- Toggle: Auto Quest
MainTab:AddToggle({
    Name = "Auto Quest",
    Default = false,
    Flag = "AutoQuest",
    Callback = function(value)
        print("Auto Quest:", value)
    end
})

-- Divider: Combat Section
MainTab:AddDivider({ Name = "⚔️ Combat" })

-- Dropdown: เลือก Zone
MainTab:AddDropdown({
    Name = "Select Zone",
    Options = {"Zone 1", "Zone 2", "Zone 3", "Boss Area"},
    Default = "Zone 1",
    Flag = "SelectedZone",
    Searchable = true,
    Callback = function(selected)
        print("Selected Zone:", selected)
    end
})

-- Dropdown (Categorized): เลือก Weapon
MainTab:AddDropdown({
    Name = "Select Weapon (Grouped)",
    Options = {
        {
            Group = "Melee Weapons",
            Items = {"Fists", "Combat", "Dark Step", "Superhuman"}
        },
        {
            Group = "Swords",
            Items = {"Cutlass", "Katana", "Dual Katana", "Saber", "Cursed Dual Katana"}
        },
        {
            Group = "Fruits",
            Items = {"Rocket Fruit", "Spin Fruit", "Chop Fruit", "Light Fruit", "Dough Fruit"}
        }
    },
    Default = "Fists",
    Flag = "SelectedWeapon",
    Searchable = true,
    Callback = function(selected)
        print("Selected Weapon:", selected)
    end
})

-- Slider: ความเร็ว
MainTab:AddSlider({
    Name = "Farm Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Increment = 5,
    Suffix = " WPS",
    Flag = "FarmSpeed",
    Callback = function(value)
        print("Farm Speed:", value)
    end
})

-- ================================================================
-- Tab: Player Settings
-- ================================================================
local PlayerTab = Window:CreateTab({ Name = "👤 Player" })

-- Section: Collapsible (พับได้)
local SpeedSection = PlayerTab:AddSection({
    Name = "🚀 Speed Hacks",
    Collapsed = false
})

SpeedSection:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Flag = "SpeedHack",
    Callback = function(value)
        if value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

SpeedSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Flag = "WalkSpeed",
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

-- Divider
PlayerTab:AddDivider({ Name = "🎨 Visuals" })

-- ColorPicker
PlayerTab:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        print("ESP Color:", color)
    end
})

-- ================================================================
-- Tab: Keybinds
-- ================================================================
local KeybindsTab = Window:CreateTab({ Name = "⌨️ Keybinds" })

KeybindsTab:AddKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Flag = "ToggleUIKey",
    Callback = function()
        Window:Toggle()
    end
})

KeybindsTab:AddKeybind({
    Name = "Quick Farm",
    Default = Enum.KeyCode.F,
    Flag = "QuickFarmKey",
    Callback = function()
        print("Quick Farm activated!")
    end
})

-- ================================================================
-- Tab: Settings
-- ================================================================
local SettingsTab = Window:CreateTab({ Name = "⚙️ Settings" })

-- Divider
SettingsTab:AddDivider({ Name = "📐 Window Size" })

-- Preset Size Buttons
SettingsTab:AddButton({
    Name = "📦 Small Size",
    Callback = function()
        Window:SetSize("Small")
        UI:Notify({ Title = "Size", Message = "Set to Small", Type = "Info" })
    end
})

SettingsTab:AddButton({
    Name = "📦 Medium Size",
    Callback = function()
        Window:SetSize("Medium")
        UI:Notify({ Title = "Size", Message = "Set to Medium", Type = "Info" })
    end
})

SettingsTab:AddButton({
    Name = "📦 Large Size",
    Callback = function()
        Window:SetSize("Large")
        UI:Notify({ Title = "Size", Message = "Set to Large", Type = "Info" })
    end
})

-- Divider
SettingsTab:AddDivider({ Name = "💾 Config" })

-- Theme Dropdown
SettingsTab:AddDropdown({
    Name = "UI Theme",
    Options = {"Dark", "Light", "PastelBlue", "PastelGreen"},
    Default = "Dark",
    Callback = function(selected)
        Window:SetTheme(selected)
        UI:Notify({ Title = "Theme", Message = "Set to " .. selected, Type = "Success" })
    end
})

-- Save/Load Buttons
SettingsTab:AddButton({
    Name = "💾 Save Config",
    Callback = function()
        Window:SaveConfig()
        UI:Notify({ Title = "Config", Message = "Saved!", Type = "Success" })
    end
})

SettingsTab:AddButton({
    Name = "📂 Load Config",
    Callback = function()
        Window:LoadConfig()
        UI:Notify({ Title = "Config", Message = "Loaded!", Type = "Success" })
    end
})

-- ================================================================
-- Notification
-- ================================================================
UI:Notify({
    Title = "✅ Loaded!",
    Message = "BloxFruit Hub loaded! Drag corner to resize.",
    Type = "Success",
    Duration = 5
})

print("============================================")
print("NTG UI - Full Example Loaded!")
print("- Resizable: Drag bottom-right corner")
print("- Preset Sizes: Small / Medium / Large")
print("- Config saved to: NTGUI/" .. game.Players.LocalPlayer.Name .. "/BloxFruit/")
print("============================================")
