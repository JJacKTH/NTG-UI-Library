--[[
    NTG UI Library - Toggle Component
]]

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, Toggle)
    self.Name = options.Name or "Toggle"
    self.Default = options.Default or false
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    self.Tab = tab
    self.Value = self.Default
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Toggle_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 35)
    self.Container.BackgroundColor3 = Theme.Current.Secondary
    self.Container.BackgroundTransparency = 0
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = elementCount
    self.Container.Active = true
    self.Container.Parent = tab.Page
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = self.Container
    
    -- Label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, -60, 1, 0)
    self.Label.Position = UDim2.new(0, 12, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Name
    self.Label.TextColor3 = Theme.Current.Text
    self.Label.TextSize = 14
    self.Label.Font = Enum.Font.GothamMedium
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Container
    
    -- Toggle switch background
    self.SwitchBg = Instance.new("Frame")
    self.SwitchBg.Name = "SwitchBg"
    self.SwitchBg.Size = UDim2.new(0, 44, 0, 22)
    self.SwitchBg.Position = UDim2.new(1, -52, 0.5, 0)
    self.SwitchBg.AnchorPoint = Vector2.new(0, 0.5)
    self.SwitchBg.BackgroundColor3 = self.Value and Theme.Current.Accent or Theme.Current.Tertiary
    self.SwitchBg.BorderSizePixel = 0
    self.SwitchBg.Parent = self.Container
    
    local switchBgCorner = Instance.new("UICorner")
    switchBgCorner.CornerRadius = UDim.new(1, 0)
    switchBgCorner.Parent = self.SwitchBg
    
    -- Toggle knob
    self.Knob = Instance.new("Frame")
    self.Knob.Name = "Knob"
    self.Knob.Size = UDim2.new(0, 18, 0, 18)
    self.Knob.Position = self.Value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    self.Knob.AnchorPoint = Vector2.new(0, 0.5)
    self.Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Knob.BorderSizePixel = 0
    self.Knob.Parent = self.SwitchBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = self.Knob
    
    -- Toggle function
    local function toggle()
        self.Value = not self.Value
        
        local targetPos = self.Value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetColor = self.Value and Theme.Current.Accent or Theme.Current.Tertiary
        
        if Animation then
            Animation:Play(self.Knob, {Position = targetPos}, 0.2)
            Animation:Play(self.SwitchBg, {BackgroundColor3 = targetColor}, 0.2)
        else
            self.Knob.Position = targetPos
            self.SwitchBg.BackgroundColor3 = targetColor
        end
        
        self.Callback(self.Value)
        
        -- Auto save
        if ConfigHandler and ConfigHandler.TriggerAutoSave then
            ConfigHandler:TriggerAutoSave()
        end
    end
    
    -- Clickable areas
    self.Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
    
    -- Register to config
    if ConfigHandler and self.Flag then
        ConfigHandler:Register(self.Flag, "Toggle", 
            function() return self.Value end,
            function(value)
                if value ~= self.Value then
                    toggle()
                end
            end
        )
    end
    
    -- Methods
    function self:Set(value)
        if value ~= self.Value then
            toggle()
        end
    end
    
    function self:Get()
        return self.Value
    end
    
    function self:Destroy()
        if ConfigHandler and self.Flag then
            ConfigHandler:Unregister(self.Flag)
        end
        self.Container:Destroy()
    end
    
    return self
end

return Toggle
