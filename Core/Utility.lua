--[[
    NTG UI Library - Utility Functions
    Helper functions for UI creation
]]

local Utility = {}

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Get local player
function Utility:GetPlayer()
    return Players.LocalPlayer
end

-- Get player UserId (for config)
function Utility:GetUserId()
    local player = self:GetPlayer()
    return player and player.UserId or 0
end

-- Generate unique ID
function Utility:GenerateId()
    return HttpService:GenerateGUID(false)
end

-- Deep copy table
function Utility:DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = self:DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Merge tables
function Utility:Merge(base, override)
    local result = self:DeepCopy(base)
    for k, v in pairs(override) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = self:Merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- Create basic frame
function Utility:CreateFrame(properties)
    local frame = Instance.new("Frame")
    frame.Name = properties.Name or "Frame"
    frame.Size = properties.Size or UDim2.new(0, 100, 0, 100)
    frame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = properties.BackgroundColor3 or Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = properties.BackgroundTransparency or 0
    frame.BorderSizePixel = properties.BorderSizePixel or 0
    frame.AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0)
    frame.ClipsDescendants = properties.ClipsDescendants or false
    frame.Visible = properties.Visible ~= false
    frame.ZIndex = properties.ZIndex or 1
    
    if properties.Parent then
        frame.Parent = properties.Parent
    end
    
    return frame
end

-- Create text label
function Utility:CreateLabel(properties)
    local label = Instance.new("TextLabel")
    label.Name = properties.Name or "Label"
    label.Size = properties.Size or UDim2.new(1, 0, 0, 20)
    label.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = properties.BackgroundTransparency or 1
    label.BorderSizePixel = 0
    label.Text = properties.Text or ""
    label.TextColor3 = properties.TextColor3 or Color3.fromRGB(255, 255, 255)
    label.TextSize = properties.TextSize or 14
    label.Font = properties.Font or Enum.Font.GothamMedium
    label.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center
    label.TextTruncate = properties.TextTruncate or Enum.TextTruncate.AtEnd
    label.ZIndex = properties.ZIndex or 1
    
    if properties.Parent then
        label.Parent = properties.Parent
    end
    
    return label
end

-- Create text button
function Utility:CreateButton(properties)
    local button = Instance.new("TextButton")
    button.Name = properties.Name or "Button"
    button.Size = properties.Size or UDim2.new(0, 100, 0, 30)
    button.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = properties.BackgroundColor3 or Color3.fromRGB(100, 100, 255)
    button.BackgroundTransparency = properties.BackgroundTransparency or 0
    button.BorderSizePixel = 0
    button.Text = properties.Text or "Button"
    button.TextColor3 = properties.TextColor3 or Color3.fromRGB(255, 255, 255)
    button.TextSize = properties.TextSize or 14
    button.Font = properties.Font or Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.ZIndex = properties.ZIndex or 1
    
    if properties.Parent then
        button.Parent = properties.Parent
    end
    
    return button
end

-- Create text box
function Utility:CreateTextBox(properties)
    local textbox = Instance.new("TextBox")
    textbox.Name = properties.Name or "TextBox"
    textbox.Size = properties.Size or UDim2.new(0, 200, 0, 30)
    textbox.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    textbox.BackgroundColor3 = properties.BackgroundColor3 or Color3.fromRGB(50, 50, 70)
    textbox.BackgroundTransparency = properties.BackgroundTransparency or 0
    textbox.BorderSizePixel = 0
    textbox.Text = properties.Text or ""
    textbox.PlaceholderText = properties.PlaceholderText or ""
    textbox.PlaceholderColor3 = properties.PlaceholderColor3 or Color3.fromRGB(150, 150, 150)
    textbox.TextColor3 = properties.TextColor3 or Color3.fromRGB(255, 255, 255)
    textbox.TextSize = properties.TextSize or 14
    textbox.Font = properties.Font or Enum.Font.GothamMedium
    textbox.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
    textbox.ClearTextOnFocus = properties.ClearTextOnFocus or false
    textbox.ZIndex = properties.ZIndex or 1
    
    if properties.Parent then
        textbox.Parent = properties.Parent
    end
    
    return textbox
end

-- Create image label
function Utility:CreateImage(properties)
    local image = Instance.new("ImageLabel")
    image.Name = properties.Name or "Image"
    image.Size = properties.Size or UDim2.new(0, 20, 0, 20)
    image.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.Image = properties.Image or ""
    image.ImageColor3 = properties.ImageColor3 or Color3.fromRGB(255, 255, 255)
    image.ImageTransparency = properties.ImageTransparency or 0
    image.ScaleType = properties.ScaleType or Enum.ScaleType.Fit
    image.ZIndex = properties.ZIndex or 1
    
    if properties.Parent then
        image.Parent = properties.Parent
    end
    
    return image
end

-- Create UI corner
function Utility:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

-- Create UI padding
function Utility:CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.Parent = parent
    return padding
end

-- Create UI list layout
function Utility:CreateList(parent, direction, padding)
    local list = Instance.new("UIListLayout")
    list.FillDirection = direction or Enum.FillDirection.Vertical
    list.Padding = UDim.new(0, padding or 5)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = parent
    return list
end

-- Create UI stroke
function Utility:CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(100, 100, 100)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Make frame draggable
function Utility:MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos
    local connections = {}
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    
    table.insert(connections, dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))
    
    table.insert(connections, dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end))

    return connections
end

-- Clamp number
function Utility:Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Lerp (linear interpolation)
function Utility:Lerp(a, b, t)
    return a + (b - a) * t
end

-- Round number
function Utility:Round(value, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(value * mult + 0.5) / mult
end

-- Color to hex
function Utility:ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255))
end

-- Hex to color
function Utility:HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

return Utility
