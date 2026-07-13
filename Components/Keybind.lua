--[[
    NTG UI Library - Keybind Component
]]

local Keybind = {}
Keybind.__index = Keybind

local UserInputService = game:GetService("UserInputService")

function Keybind.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, Keybind)
    self.Name = options.Name or "Keybind"
    self.Default = options.Default or Enum.KeyCode.Unknown
    self.Callback = options.Callback or function() end
    self.ChangedCallback = options.ChangedCallback
    self.Flag = options.Flag
    self.Tab = tab
    self.Value = self.Default
    self.Listening = false
    
    -- Helper method (defined early for use during UI creation)
    function self:GetKeyName()
        if self.Value == Enum.KeyCode.Unknown then
            return "None"
        end
        return self.Value.Name
    end
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Keybind_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 35)
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
    self.Label.Size = UDim2.new(1, -100, 1, 0)
    self.Label.Position = UDim2.new(0, 12, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Name
    self.Label.TextColor3 = Theme.Current.Text
    self.Label.TextSize = 14
    self.Label.Font = Enum.Font.GothamMedium
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Container
    
    -- Keybind button
    self.Button = Instance.new("TextButton")
    self.Button.Name = "KeyButton"
    self.Button.Size = UDim2.new(0, 80, 0, 25)
    self.Button.Position = UDim2.new(1, -90, 0.5, 0)
    self.Button.AnchorPoint = Vector2.new(0, 0.5)
    self.Button.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    self.Button.BackgroundTransparency = 0.08
    self.Button.BorderSizePixel = 0
    self.Button.Text = self:GetKeyName()
    self.Button.TextColor3 = Theme.Current.Text
    self.Button.TextSize = 12
    self.Button.Font = Enum.Font.GothamMedium
    self.Button.AutoButtonColor = false
    self.Button.Parent = self.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = self.Button

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Theme.Current.Stroke or Theme.Current.Divider
    buttonStroke.Transparency = 0.86
    buttonStroke.Thickness = 1
    buttonStroke.Parent = self.Button
    
    -- Click to change keybind
    self.Button.MouseButton1Click:Connect(function()
        if self.Listening then return end
        
        self.Listening = true
        self.Button.Text = "..."
        self.Button.BackgroundColor3 = Theme.Current.Accent

        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Value = input.KeyCode
                self.Button.Text = self:GetKeyName()
                self.Button.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
                self.Listening = false
                connection:Disconnect()
                self.ChangeConnection = nil
                
                if self.ChangedCallback then
                    self.ChangedCallback(self.Value)
                end
                
                -- Auto save
                if ConfigHandler and ConfigHandler.TriggerAutoSave then
                    ConfigHandler:TriggerAutoSave()
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 then
                -- Cancel on mouse click outside
                self.Button.Text = self:GetKeyName()
                self.Button.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
                self.Listening = false
                connection:Disconnect()
                self.ChangeConnection = nil
            end
        end)
        self.ChangeConnection = connection
    end)
    
    -- Trigger callback on key press
    self.InputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if self.Listening then return end
        
        if input.KeyCode == self.Value then
            self.Callback()
        end
    end)
    
    -- Hover effect with dynamic Theme colors
    self.Button.MouseEnter:Connect(function()
        if Animation then
            Animation:Play(self.Button, {BackgroundColor3 = Theme.Current.AccentHover or Theme.Current.Accent}, 0.15)
        else
            self.Button.BackgroundColor3 = Theme.Current.AccentHover or Theme.Current.Accent
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if Animation then
            Animation:Play(self.Button, {BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface}, 0.15)
        else
            self.Button.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
        end
    end)
    
    -- Additional Methods
    function self:Set(keyCode)
        self.Value = keyCode
        self.Button.Text = self:GetKeyName()
    end
    
    function self:Get()
        return self.Value
    end
    
    function self:Destroy()
        if self.ChangeConnection then
            self.ChangeConnection:Disconnect()
        end
        if self.InputConnection then
            self.InputConnection:Disconnect()
        end
        if ConfigHandler and self.Flag then
            ConfigHandler:Unregister(self.Flag)
        end
        self.Container:Destroy()
    end
    
    -- Register to config
    if ConfigHandler and self.Flag then
        ConfigHandler:Register(self.Flag, "Keybind",
            function()
                return self.Value.Name
            end,
            function(value)
                if Enum.KeyCode[value] then
                    self:Set(Enum.KeyCode[value])
                end
            end
        )
    end
    
    return self
end

return Keybind
