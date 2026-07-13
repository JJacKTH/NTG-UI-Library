--[[
    NTG UI Library - Slider Component
]]

local Slider = {}
Slider.__index = Slider

local UserInputService = game:GetService("UserInputService")

function Slider.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, Slider)
    self.Name = options.Name or "Slider"
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Default = options.Default or self.Min
    self.Increment = options.Increment or 1
    self.Suffix = options.Suffix or ""
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    self.Tab = tab
    self.Value = self.Default
    self.Dragging = false
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Slider_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 50)
    self.Container.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    self.Container.BackgroundTransparency = 0.12
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = elementCount
    self.Container.Active = true
    self.Container.Parent = tab.Page
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 16)
    containerCorner.Parent = self.Container

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Theme.Current.Stroke or Theme.Current.Divider
    containerStroke.Transparency = 0.84
    containerStroke.Thickness = 1
    containerStroke.Parent = self.Container
    
    -- Label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(0.6, 0, 0, 20)
    self.Label.Position = UDim2.new(0, 10, 0, 5)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Name
    self.Label.TextColor3 = Theme.Current.Text
    self.Label.TextSize = 13
    self.Label.Font = Enum.Font.GothamMedium
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Container
    
    -- Value display
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "Value"
    self.ValueLabel.Size = UDim2.new(0.4, -10, 0, 20)
    self.ValueLabel.Position = UDim2.new(0.6, 0, 0, 5)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.Text = tostring(self.Value) .. self.Suffix
    self.ValueLabel.TextColor3 = Theme.Current.Accent
    self.ValueLabel.TextSize = 13
    self.ValueLabel.Font = Enum.Font.GothamBold
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Parent = self.Container
    
    -- Slider track
    self.Track = Instance.new("Frame")
    self.Track.Name = "Track"
    self.Track.Size = UDim2.new(1, -20, 0, 8)
    self.Track.Position = UDim2.new(0, 10, 0, 32)
    self.Track.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    self.Track.BackgroundTransparency = 0.06
    self.Track.BorderSizePixel = 0
    self.Track.Parent = self.Container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = self.Track
    
    -- Slider fill
    local fillPercent = (self.Value - self.Min) / (self.Max - self.Min)
    
    self.Fill = Instance.new("Frame")
    self.Fill.Name = "Fill"
    self.Fill.Size = UDim2.new(fillPercent, 0, 1, 0)
    self.Fill.BackgroundColor3 = Theme.Current.Accent
    self.Fill.BorderSizePixel = 0
    self.Fill.Parent = self.Track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = self.Fill
    
    -- Slider knob
    self.Knob = Instance.new("Frame")
    self.Knob.Name = "Knob"
    self.Knob.Size = UDim2.new(0, 18, 0, 18)
    self.Knob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
    self.Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Knob.BorderSizePixel = 0
    self.Knob.ZIndex = 2
    self.Knob.Parent = self.Track

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Theme.Current.Accent
    knobStroke.Thickness = 1
    knobStroke.Transparency = 0.72
    knobStroke.Parent = self.Knob
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = self.Knob
    
    -- Knob shadow
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Theme.Current.Accent
    knobStroke.Thickness = 1
    knobStroke.Parent = self.Knob
    
    -- Helper to update value
    local function updateValue(percent)
        percent = math.clamp(percent, 0, 1)
        
        local range = self.Max - self.Min
        local rawValue = self.Min + (range * percent)
        
        -- Apply increment
        if self.Increment and self.Increment > 0 then
            rawValue = math.floor(rawValue / self.Increment + 0.5) * self.Increment
        end
        
        rawValue = math.clamp(rawValue, self.Min, self.Max)
        
        -- Round for display
        if self.Increment >= 1 then
            rawValue = math.floor(rawValue + 0.5)
        else
            local decimals = -math.floor(math.log10(self.Increment))
            rawValue = math.floor(rawValue * 10^decimals + 0.5) / 10^decimals
        end
        
        if rawValue ~= self.Value then
            self.Value = rawValue
            
            local newPercent = (self.Value - self.Min) / (self.Max - self.Min)
            
            self.Fill.Size = UDim2.new(newPercent, 0, 1, 0)
            self.Knob.Position = UDim2.new(newPercent, 0, 0.5, 0)
            self.ValueLabel.Text = tostring(self.Value) .. self.Suffix
            
            self.Callback(self.Value)
            
            -- Auto save
            if ConfigHandler and ConfigHandler.TriggerAutoSave then
                ConfigHandler:TriggerAutoSave()
            end
        end
    end
    
    -- Mouse/touch input
    local function onInput(input)
        if self.Dragging then
            local trackPos = self.Track.AbsolutePosition.X
            local trackSize = self.Track.AbsoluteSize.X
            local mouseX = input.Position.X
            
            local percent = (mouseX - trackPos) / trackSize
            updateValue(percent)
        end
    end
    
    -- Input connections
    self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            onInput(input)
        end
    end)
    
    self.Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
        end
    end)

    if Animation then
        Animation:CreateHoverEffect(self.Track, Theme.Current.SurfaceAlt or Theme.Current.Surface, Theme.Current.Surface or Theme.Current.Background)
        Animation:CreatePressEffect(self.Track, 0.992, 1)
    end
    
    self.InputChanged = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            onInput(input)
        end
    end)
    
    self.InputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = false
        end
    end)
    
    -- Register to config
    if ConfigHandler and self.Flag then
        ConfigHandler:Register(self.Flag, "Slider",
            function() return self.Value end,
            function(value)
                self:Set(value)
            end
        )
    end
    
    -- Methods
    function self:Set(value)
        value = math.clamp(value or self.Min, self.Min, self.Max)
        local percent = (value - self.Min) / (self.Max - self.Min)
        updateValue(percent)
    end
    
    function self:Get()
        return self.Value
    end
    
    function self:SetRange(min, max)
        self.Min = min
        self.Max = max
        self:Set(math.clamp(self.Value, min, max))
    end
    
    function self:Destroy()
        if self.InputChanged then
            self.InputChanged:Disconnect()
        end
        if self.InputEnded then
            self.InputEnded:Disconnect()
        end
        if ConfigHandler and self.Flag then
            ConfigHandler:Unregister(self.Flag)
        end
        self.Container:Destroy()
    end
    
    return self
end

return Slider
