--[[
    NTG UI Library - Theme System
    สี Themes: Dark, Light, Pastel Blue, Pastel Green
]]

local Theme = {}

Theme.Presets = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 50),
        Tertiary = Color3.fromRGB(45, 45, 65),
        Accent = Color3.fromRGB(100, 100, 255),
        AccentHover = Color3.fromRGB(120, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Divider = Color3.fromRGB(60, 60, 80),
        Success = Color3.fromRGB(100, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 200, 100)
    },
    
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(230, 230, 240),
        Tertiary = Color3.fromRGB(215, 215, 225),
        Accent = Color3.fromRGB(80, 80, 220),
        AccentHover = Color3.fromRGB(100, 100, 240),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(100, 100, 100),
        Divider = Color3.fromRGB(200, 200, 210),
        Success = Color3.fromRGB(50, 180, 80),
        Error = Color3.fromRGB(220, 60, 60),
        Warning = Color3.fromRGB(220, 160, 50)
    },
    
    PastelBlue = {
        Name = "PastelBlue",
        Background = Color3.fromRGB(230, 240, 250),
        Secondary = Color3.fromRGB(200, 220, 240),
        Tertiary = Color3.fromRGB(180, 200, 230),
        Accent = Color3.fromRGB(100, 150, 220),
        AccentHover = Color3.fromRGB(120, 170, 240),
        Text = Color3.fromRGB(40, 60, 90),
        SubText = Color3.fromRGB(80, 100, 130),
        Divider = Color3.fromRGB(160, 180, 210),
        Success = Color3.fromRGB(100, 180, 140),
        Error = Color3.fromRGB(220, 120, 120),
        Warning = Color3.fromRGB(220, 180, 100)
    },
    
    PastelGreen = {
        Name = "PastelGreen",
        Background = Color3.fromRGB(235, 250, 240),
        Secondary = Color3.fromRGB(210, 240, 220),
        Tertiary = Color3.fromRGB(190, 230, 200),
        Accent = Color3.fromRGB(100, 190, 140),
        AccentHover = Color3.fromRGB(120, 210, 160),
        Text = Color3.fromRGB(40, 70, 50),
        SubText = Color3.fromRGB(80, 110, 90),
        Divider = Color3.fromRGB(170, 210, 180),
        Success = Color3.fromRGB(80, 180, 120),
        Error = Color3.fromRGB(220, 120, 120),
        Warning = Color3.fromRGB(220, 180, 100)
    }
}

-- Current active theme
Theme.Current = Theme.Presets.Dark

-- Set theme by name
function Theme:Set(themeName)
    if Theme.Presets[themeName] then
        Theme.Current = Theme.Presets[themeName]
        return true
    end
    return false
end

-- Get current theme color
function Theme:Get(colorName)
    return Theme.Current[colorName]
end

-- Create custom theme
function Theme:CreateCustom(name, colors)
    local newTheme = {}
    
    -- Start with Dark as base
    for key, value in pairs(Theme.Presets.Dark) do
        newTheme[key] = value
    end
    
    -- Override with custom colors
    for key, value in pairs(colors) do
        newTheme[key] = value
    end
    
    newTheme.Name = name
    Theme.Presets[name] = newTheme
    return newTheme
end

-- Apply theme to UI element
function Theme:ApplyToElement(element, properties)
    for property, themeKey in pairs(properties) do
        if element[property] and Theme.Current[themeKey] then
            element[property] = Theme.Current[themeKey]
        end
    end
end

return Theme
