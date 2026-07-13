--[[
    NTG UI Library - Theme System
    Glass 2.0 base theme set for modern translucent UI
]]

local Theme = {}

Theme.Presets = {
    GlassDark = {
        Name = "GlassDark",
        Background = Color3.fromRGB(6, 10, 20),
        Surface = Color3.fromRGB(18, 24, 38),
        SurfaceAlt = Color3.fromRGB(25, 33, 51),
        SurfaceGlow = Color3.fromRGB(34, 42, 68),
        Accent = Color3.fromRGB(112, 141, 255),
        AccentHover = Color3.fromRGB(140, 165, 255),
        AccentSoft = Color3.fromRGB(112, 141, 255),
        Text = Color3.fromRGB(248, 250, 255),
        SubText = Color3.fromRGB(170, 179, 204),
        Divider = Color3.fromRGB(255, 255, 255),
        Stroke = Color3.fromRGB(255, 255, 255),
        Glow = Color3.fromRGB(112, 141, 255),
        Success = Color3.fromRGB(96, 214, 140),
        Error = Color3.fromRGB(255, 104, 104),
        Warning = Color3.fromRGB(255, 194, 92),
        Transparency = {
            Background = 0.1,
            Surface = 0.2,
            SurfaceAlt = 0.28,
            Stroke = 0.82,
            SoftStroke = 0.9,
            Glow = 0.76
        },
        BlurStrength = 28
    },

    GlassLight = {
        Name = "GlassLight",
        Background = Color3.fromRGB(232, 238, 248),
        Surface = Color3.fromRGB(248, 250, 255),
        SurfaceAlt = Color3.fromRGB(255, 255, 255),
        SurfaceGlow = Color3.fromRGB(226, 233, 246),
        Accent = Color3.fromRGB(84, 108, 255),
        AccentHover = Color3.fromRGB(106, 129, 255),
        AccentSoft = Color3.fromRGB(84, 108, 255),
        Text = Color3.fromRGB(23, 28, 40),
        SubText = Color3.fromRGB(94, 104, 124),
        Divider = Color3.fromRGB(28, 32, 44),
        Stroke = Color3.fromRGB(28, 32, 44),
        Glow = Color3.fromRGB(84, 108, 255),
        Success = Color3.fromRGB(52, 170, 102),
        Error = Color3.fromRGB(220, 70, 70),
        Warning = Color3.fromRGB(214, 156, 48),
        Transparency = {
            Background = 0.08,
            Surface = 0.16,
            SurfaceAlt = 0.24,
            Stroke = 0.9,
            SoftStroke = 0.95,
            Glow = 0.8
        },
        BlurStrength = 18
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

function Theme:StyleCard(frame, opts)
    opts = opts or {}
    frame.BackgroundColor3 = opts.BackgroundColor3 or Theme.Current.Surface or Theme.Current.Background
    frame.BackgroundTransparency = opts.BackgroundTransparency or (Theme.Current.Transparency and Theme.Current.Transparency.Surface or 0.2)
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = opts.CornerRadius or UDim.new(0, 16)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = opts.StrokeColor or Theme.Current.Stroke or Theme.Current.Divider
    stroke.Transparency = opts.StrokeTransparency or (Theme.Current.Transparency and Theme.Current.Transparency.Stroke or 0.85)
    stroke.Thickness = opts.StrokeThickness or 1
    stroke.Parent = frame

    if opts.EnableGradient ~= false then
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = opts.GradientRotation or 90
        gradient.Color = opts.GradientColor or ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Current.SurfaceGlow or Theme.Current.Accent),
            ColorSequenceKeypoint.new(0.25, Theme.Current.SurfaceAlt or Theme.Current.Surface),
            ColorSequenceKeypoint.new(1, Theme.Current.Background)
        })
        gradient.Transparency = opts.GradientTransparency or NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.4, 0.45),
            NumberSequenceKeypoint.new(1, 0.15)
        })
        gradient.Parent = frame
    end

    return frame, corner, stroke
end

function Theme:StyleInput(input)
    input.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    input.BackgroundTransparency = Theme.Current.Transparency and Theme.Current.Transparency.SurfaceAlt or 0.24
    input.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = input
    return corner
end

return Theme
