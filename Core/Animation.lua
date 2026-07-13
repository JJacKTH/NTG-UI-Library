--[[
    NTG UI Library - Animation Utilities
    Glass 2.0 motion helpers for soft premium UI feedback
]]

local Animation = {}

local TweenService = game:GetService("TweenService")

-- Default easing styles
Animation.EasingStyles = {
    Smooth = Enum.EasingStyle.Quint,
    Soft = Enum.EasingStyle.Quad,
    Snappy = Enum.EasingStyle.Cubic,
    Linear = Enum.EasingStyle.Linear
}

Animation.DefaultDuration = 0.22
Animation.DefaultStyle = Enum.EasingStyle.Quint
Animation.DefaultDirection = Enum.EasingDirection.Out

Animation.Motion = {
    Hover = 0.14,
    Leave = 0.18,
    Press = 0.09,
    Release = 0.14
}

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
    duration = duration or 0.18
    object.BackgroundTransparency = 1
    return self:Play(object, {BackgroundTransparency = 0}, duration, Enum.EasingStyle.Quad)
end

-- Fade out
function Animation:FadeOut(object, duration)
    duration = duration or 0.18
    return self:Play(object, {BackgroundTransparency = 1}, duration, Enum.EasingStyle.Quad)
end

-- Gentle pop animation for modal/window entry
function Animation:ScaleIn(object, duration)
    duration = duration or 0.24
    local originalSize = object.Size
    object.Size = UDim2.new(
        originalSize.X.Scale * 0.96, math.floor(originalSize.X.Offset * 0.96),
        originalSize.Y.Scale * 0.96, math.floor(originalSize.Y.Offset * 0.96)
    )
    return self:Play(object, {Size = originalSize}, duration, Enum.EasingStyle.Quint)
end

-- Soft slide animation
function Animation:SlideIn(object, fromDirection, duration)
    duration = duration or 0.24
    local originalPosition = object.Position
    local startPos
    
    if fromDirection == "Left" then
        startPos = UDim2.new(originalPosition.X.Scale - 0.06, originalPosition.X.Offset - 28, 
                             originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif fromDirection == "Right" then
        startPos = UDim2.new(originalPosition.X.Scale + 0.06, originalPosition.X.Offset + 28,
                             originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif fromDirection == "Top" then
        startPos = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset,
                             originalPosition.Y.Scale - 0.06, originalPosition.Y.Offset - 28)
    else -- Bottom
        startPos = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset,
                             originalPosition.Y.Scale + 0.06, originalPosition.Y.Offset + 28)
    end
    
    object.Position = startPos
    return self:Play(object, {Position = originalPosition}, duration, Enum.EasingStyle.Quint)
end

-- Hover effect with subtle lift
function Animation:CreateHoverEffect(button, hoverColor, normalColor, options)
    options = options or {}
    local hoverDuration = options.HoverDuration or self.Motion.Hover
    local leaveDuration = options.LeaveDuration or self.Motion.Leave
    local hoverOffset = options.HoverOffset or -1
    local pressScale = options.PressScale or 0.985
    local originalPosition = button.Position
    local originalSize = button.Size

    local connection1 = button.MouseEnter:Connect(function()
        self:Play(button, {BackgroundColor3 = hoverColor}, hoverDuration, Enum.EasingStyle.Quad)
        if options.Lift and button.Position then
            self:Play(button, {
                Position = UDim2.new(
                    originalPosition.X.Scale, originalPosition.X.Offset,
                    originalPosition.Y.Scale, originalPosition.Y.Offset + hoverOffset
                )
            }, hoverDuration, Enum.EasingStyle.Quad)
        end
        if options.Grow and button.Size then
            self:Play(button, {
                Size = UDim2.new(
                    originalSize.X.Scale, math.floor(originalSize.X.Offset / pressScale),
                    originalSize.Y.Scale, math.floor(originalSize.Y.Offset / pressScale)
                )
            }, hoverDuration, Enum.EasingStyle.Quad)
        end
    end)
    
    local connection2 = button.MouseLeave:Connect(function()
        self:Play(button, {BackgroundColor3 = normalColor}, leaveDuration, Enum.EasingStyle.Quad)
        if options.Lift and button.Position then
            self:Play(button, {Position = originalPosition}, leaveDuration, Enum.EasingStyle.Quad)
        end
        if options.Grow and button.Size then
            self:Play(button, {Size = originalSize}, leaveDuration, Enum.EasingStyle.Quad)
        end
    end)
    
    return {connection1, connection2}
end

function Animation:CreatePressEffect(button, pressedScale, releasedScale)
    pressedScale = pressedScale or 0.98
    releasedScale = releasedScale or 1
    local originalSize = button.Size
    local function scaledSize(scale)
        return UDim2.new(
            originalSize.X.Scale * scale, math.floor(originalSize.X.Offset * scale),
            originalSize.Y.Scale * scale, math.floor(originalSize.Y.Offset * scale)
        )
    end

    local down = button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:Play(button, {Size = scaledSize(pressedScale)}, self.Motion.Press, Enum.EasingStyle.Quad)
        end
    end)

    local up = button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:Play(button, {Size = scaledSize(releasedScale)}, self.Motion.Release, Enum.EasingStyle.Quad)
        end
    end)

    return {down, up}
end

-- Ripple effect for buttons
function Animation:CreateRipple(button)
    button.ClipsDescendants = true
    
    local function doRipple(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.82
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
        }, 0.35, Enum.EasingStyle.Quad)
        
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

function Animation:SoftFade(object, duration, targetTransparency)
    duration = duration or 0.18
    targetTransparency = targetTransparency or 0
    return self:Play(object, {BackgroundTransparency = targetTransparency}, duration, Enum.EasingStyle.Quad)
end

function Animation:MicroLift(object, duration, pixels)
    duration = duration or 0.14
    pixels = pixels or -1
    local originalPosition = object.Position
    return self:Play(object, {
        Position = UDim2.new(
            originalPosition.X.Scale, originalPosition.X.Offset,
            originalPosition.Y.Scale, originalPosition.Y.Offset + pixels
        )
    }, duration, Enum.EasingStyle.Quad)
end

function Animation:GentlePop(object, duration)
    duration = duration or 0.2
    local originalSize = object.Size
    object.Size = UDim2.new(
        originalSize.X.Scale * 0.985, math.floor(originalSize.X.Offset * 0.985),
        originalSize.Y.Scale * 0.985, math.floor(originalSize.Y.Offset * 0.985)
    )
    return self:Play(object, {Size = originalSize}, duration, Enum.EasingStyle.Quad)
end

return Animation
