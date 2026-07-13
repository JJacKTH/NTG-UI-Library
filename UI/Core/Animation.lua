--[[
    NTG UI Library - Animation Utilities
    Smooth tweens & animation helpers
]]

local Animation = {}

local TweenService = game:GetService("TweenService")

-- Default easing styles
Animation.EasingStyles = {
    Smooth = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Back = Enum.EasingStyle.Back,
    Linear = Enum.EasingStyle.Linear,
    Quad = Enum.EasingStyle.Quad
}

Animation.DefaultDuration = 0.25
Animation.DefaultStyle = Enum.EasingStyle.Quint
Animation.DefaultDirection = Enum.EasingDirection.Out

-- Create tween
function Animation:Tween(object, properties, duration, style, direction)
    duration = duration or Animation.DefaultDuration
    style = style or Animation.DefaultStyle
    direction = direction or Animation.DefaultDirection

    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(object, tweenInfo, properties)
    
    return tween
end

-- Play tween immediately
function Animation:Play(object, properties, duration, style, direction)
    local tween = self:Tween(object, properties, duration, style, direction)
    tween:Play()
    return tween
end

-- Play tween and wait for completion
function Animation:PlayWait(object, properties, duration, style, direction)
    local tween = self:Play(object, properties, duration, style, direction)
    tween.Completed:Wait()
    return tween
end

-- Fade in
function Animation:FadeIn(object, duration)
    duration = duration or 0.2
    object.BackgroundTransparency = 1
    return self:Play(object, {BackgroundTransparency = 0}, duration)
end

-- Fade out
function Animation:FadeOut(object, duration)
    duration = duration or 0.2
    return self:Play(object, {BackgroundTransparency = 1}, duration)
end

-- Scale animation (pop in/out effect)
function Animation:ScaleIn(object, duration)
    duration = duration or 0.3
    local originalSize = object.Size
    object.Size = UDim2.new(originalSize.X.Scale * 0.8, originalSize.X.Offset * 0.8, 
                            originalSize.Y.Scale * 0.8, originalSize.Y.Offset * 0.8)
    return self:Play(object, {Size = originalSize}, duration, Enum.EasingStyle.Back)
end

-- Slide animation
function Animation:SlideIn(object, fromDirection, duration)
    duration = duration or 0.3
    local originalPosition = object.Position
    local startPos
    
    if fromDirection == "Left" then
        startPos = UDim2.new(originalPosition.X.Scale - 0.1, originalPosition.X.Offset - 50, 
                             originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif fromDirection == "Right" then
        startPos = UDim2.new(originalPosition.X.Scale + 0.1, originalPosition.X.Offset + 50,
                             originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif fromDirection == "Top" then
        startPos = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset,
                             originalPosition.Y.Scale - 0.1, originalPosition.Y.Offset - 50)
    else -- Bottom
        startPos = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset,
                             originalPosition.Y.Scale + 0.1, originalPosition.Y.Offset + 50)
    end
    
    object.Position = startPos
    return self:Play(object, {Position = originalPosition}, duration)
end

-- Hover effect
function Animation:CreateHoverEffect(button, hoverColor, normalColor)
    local connection1 = button.MouseEnter:Connect(function()
        self:Play(button, {BackgroundColor3 = hoverColor}, 0.15)
    end)
    
    local connection2 = button.MouseLeave:Connect(function()
        self:Play(button, {BackgroundColor3 = normalColor}, 0.15)
    end)
    
    return {connection1, connection2}
end

-- Ripple effect for buttons
function Animation:CreateRipple(button)
    button.ClipsDescendants = true
    
    local function doRipple(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Parent = button
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        local tween = self:Play(ripple, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }, 0.5)
        
        tween.Completed:Connect(function()
            ripple:Destroy()
        end)
    end
    
    return button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            local relativeX = input.Position.X - button.AbsolutePosition.X
            local relativeY = input.Position.Y - button.AbsolutePosition.Y
            doRipple(relativeX, relativeY)
        end
    end)
end

return Animation
