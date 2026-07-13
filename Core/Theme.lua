--[[
    NTG UI Library - Theme System
    Glass 2.0 base theme set for modern translucent UI
]]

local Theme = {}

Theme.Presets = {
    GlassDark = {
        Name = "GlassDark",
        Background = Color3.fromRGB(9, 12, 22),
        Surface = Color3.fromRGB(24, 28, 44),
        SurfaceAlt = Color3.fromRGB(31, 37, 58),
        Accent = Color3.fromRGB(124, 92, 255),
        AccentHover = Color3.fromRGB(145, 116, 255),
        Text = Color3.fromRGB(245, 247, 255),
        SubText = Color3.fromRGB(175, 182, 205),
        Divider = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(124, 92, 255),
        Success = Color3.fromRGB(96, 214, 140),
        Error = Color3.fromRGB(255, 104, 104),
        Warning = Color3.fromRGB(255, 194, 92),
        Transparency = {
            Background = 0.06,
            Surface = 0.22,
            SurfaceAlt = 0.3,
            Stroke = 0.78,
            SoftStroke = 0.9,
            Glow = 0.72
        },
        BlurStrength = 24
    },

    GlassLight = {
        Name = "GlassLight",
        Background = Color3.fromRGB(233, 238, 248),
        Surface = Color3.fromRGB(246, 248, 252),
        SurfaceAlt = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(92, 116, 255),
        AccentHover = Color3.fromRGB(112, 136, 255),
        Text = Color3.fromRGB(24, 28, 38),
        SubText = Color3.fromRGB(96, 105, 122),
        Divider = Color3.fromRGB(28, 32, 44),
        Stroke = Color3.fromRGB(28, 32, 44),
        Glow = Color3.fromRGB(92, 116, 255),
        Success = Color3.fromRGB(52, 170, 102),
        Error = Color3.fromRGB(220, 70, 70),
        Warning = Color3.fromRGB(214, 156, 48),
        Transparency = {
            Background = 0.08,
            Surface = 0.18,
            SurfaceAlt = 0.26,
            Stroke = 0.88,
            SoftStroke = 0.94,
            Glow = 0.78
        },
        BlurStrength = 14
    }
}

Theme.Current = Theme.Presets.GlassDark

function Theme:Set(themeName)
    if Theme.Presets[themeName] then
        Theme.Current = Theme.Presets[themeName]
        return true
    end
    return false
end

function Theme:Get(colorName)
    return Theme.Current[colorName]
end

function Theme:CreateCustom(name, colors)
    local newTheme = {}

    for key, value in pairs(Theme.Presets.GlassDark) do
        newTheme[key] = value
    end

    for key, value in pairs(colors) do
        newTheme[key] = value
    end

    newTheme.Name = name
    Theme.Presets[name] = newTheme
    return newTheme
end

function Theme:ApplyToElement(element, properties)
    for property, themeKey in pairs(properties) do
        if element[property] and Theme.Current[themeKey] then
            element[property] = Theme.Current[themeKey]
        end
    end
end

return Theme
