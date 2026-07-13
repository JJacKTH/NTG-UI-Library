--[[
    NTG UI Library - ColorPicker Component
]]

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local UserInputService = game:GetService("UserInputService")

function ColorPicker.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, ColorPicker)
    self.Name = options.Name or "ColorPicker"
    self.Default = options.Default or Color3.fromRGB(255, 255, 255)
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    self.Tab = tab
    self.Value = self.Default
    self.Open = false
    self.Dragging = nil
    
    -- Helper methods (defined early for use during UI creation)
    function self:GetRGBText()
        local r = math.floor(self.Value.R * 255 + 0.5)
        local g = math.floor(self.Value.G * 255 + 0.5)
        local b = math.floor(self.Value.B * 255 + 0.5)
        return string.format("RGB: %d, %d, %d", r, g, b)
    end
    
    function self:GetHexText()
        local r = math.floor(self.Value.R * 255 + 0.5)
        local g = math.floor(self.Value.G * 255 + 0.5)
        local b = math.floor(self.Value.B * 255 + 0.5)
        return string.format("#%02X%02X%02X", r, g, b)
    end
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "ColorPicker_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 35)
    self.Container.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    self.Container.BackgroundTransparency = 0.24
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = false
    self.Container.ZIndex = 2
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
    self.Label.ZIndex = 2
    self.Label.Parent = self.Container
    
    -- Color preview button
    self.Preview = Instance.new("TextButton")
    self.Preview.Name = "Preview"
    self.Preview.Size = UDim2.new(0, 40, 0, 22)
    self.Preview.Position = UDim2.new(1, -50, 0.5, 0)
    self.Preview.AnchorPoint = Vector2.new(0, 0.5)
    self.Preview.BackgroundColor3 = self.Value
    self.Preview.BorderSizePixel = 0
    self.Preview.Text = ""
    self.Preview.AutoButtonColor = false
    self.Preview.ZIndex = 2
    self.Preview.Parent = self.Container
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = self.Preview
    
    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Theme.Current.Divider
    previewStroke.Thickness = 1
    previewStroke.Parent = self.Preview
    
    -- Picker panel
    self.PickerPanel = Instance.new("Frame")
    self.PickerPanel.Name = "PickerPanel"
    self.PickerPanel.Size = UDim2.new(0, 200, 0, 180)
    self.PickerPanel.Position = UDim2.new(1, -210, 0, 38)
    self.PickerPanel.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    self.PickerPanel.BorderSizePixel = 0
    self.PickerPanel.Visible = false
    self.PickerPanel.ZIndex = 100
    self.PickerPanel.Active = true
    self.PickerPanel.Parent = self.Container
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = self.PickerPanel
    
    -- Saturation/Value picker
    self.SVPicker = Instance.new("ImageLabel")
    self.SVPicker.Name = "SVPicker"
    self.SVPicker.Size = UDim2.new(0, 150, 0, 120)
    self.SVPicker.Position = UDim2.new(0, 10, 0, 10)
    self.SVPicker.BackgroundColor3 = Color3.fromHSV(Color3.toHSV(self.Value))
    self.SVPicker.BorderSizePixel = 0
    self.SVPicker.Image = "rbxassetid://4155801252" -- saturation/value gradient
    self.SVPicker.ZIndex = 101
    self.SVPicker.Parent = self.PickerPanel
    
    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = self.SVPicker
    
    -- SV cursor
    self.SVCursor = Instance.new("Frame")
    self.SVCursor.Name = "Cursor"
    self.SVCursor.Size = UDim2.new(0, 12, 0, 12)
    self.SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    self.SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.SVCursor.BackgroundTransparency = 1
    self.SVCursor.BorderSizePixel = 0
    self.SVCursor.ZIndex = 102
    self.SVCursor.Parent = self.SVPicker
    
    local svCursorStroke = Instance.new("UIStroke")
    svCursorStroke.Color = Color3.fromRGB(255, 255, 255)
    svCursorStroke.Thickness = 2
    svCursorStroke.Parent = self.SVCursor
    
    local svCursorCorner = Instance.new("UICorner")
    svCursorCorner.CornerRadius = UDim.new(1, 0)
    svCursorCorner.Parent = self.SVCursor
    
    -- Hue slider
    self.HueSlider = Instance.new("ImageLabel")
    self.HueSlider.Name = "HueSlider"
    self.HueSlider.Size = UDim2.new(0, 20, 0, 120)
    self.HueSlider.Position = UDim2.new(0, 170, 0, 10)
    self.HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueSlider.BorderSizePixel = 0
    self.HueSlider.Image = "rbxassetid://4155801252" -- use gradient
    self.HueSlider.ZIndex = 101
    self.HueSlider.Parent = self.PickerPanel
    
    -- Create hue gradient
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = self.HueSlider
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = self.HueSlider
    
    -- Hue cursor
    self.HueCursor = Instance.new("Frame")
    self.HueCursor.Name = "Cursor"
    self.HueCursor.Size = UDim2.new(1, 4, 0, 6)
    self.HueCursor.Position = UDim2.new(0.5, 0, 0, 0)
    self.HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    self.HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueCursor.BorderSizePixel = 0
    self.HueCursor.ZIndex = 102
    self.HueCursor.Parent = self.HueSlider
    
    local hueCursorCorner = Instance.new("UICorner")
    hueCursorCorner.CornerRadius = UDim.new(0, 2)
    hueCursorCorner.Parent = self.HueCursor
    
    -- RGB input
    self.RGBLabel = Instance.new("TextLabel")
    self.RGBLabel.Name = "RGBLabel"
    self.RGBLabel.Size = UDim2.new(1, -20, 0, 20)
    self.RGBLabel.Position = UDim2.new(0, 10, 0, 140)
    self.RGBLabel.BackgroundTransparency = 1
    self.RGBLabel.Text = self:GetRGBText()
    self.RGBLabel.TextColor3 = Theme.Current.Text
    self.RGBLabel.TextSize = 11
    self.RGBLabel.Font = Enum.Font.Gotham
    self.RGBLabel.ZIndex = 101
    self.RGBLabel.Parent = self.PickerPanel
    
    -- Hex input
    self.HexInput = Instance.new("TextBox")
    self.HexInput.Name = "HexInput"
    self.HexInput.Size = UDim2.new(0, 80, 0, 20)
    self.HexInput.Position = UDim2.new(0, 110, 0, 140)
    self.HexInput.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    self.HexInput.BorderSizePixel = 0
    self.HexInput.Text = self:GetHexText()
    self.HexInput.TextColor3 = Theme.Current.Text
    self.HexInput.TextSize = 11
    self.HexInput.Font = Enum.Font.Gotham
    self.HexInput.ZIndex = 101
    self.HexInput.Parent = self.PickerPanel
    
    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 3)
    hexCorner.Parent = self.HexInput
    
    -- HSV values
    local h, s, v = Color3.toHSV(self.Value)
    self.Hue = h
    self.Sat = s
    self.Val = v
    
    -- Update cursor positions
    local function updateCursors()
        self.SVCursor.Position = UDim2.new(self.Sat, 0, 1 - self.Val, 0)
        self.HueCursor.Position = UDim2.new(0.5, 0, self.Hue, 0)
        self.SVPicker.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
    end
    
    updateCursors()
    
    -- Update color
    local function updateColor()
        self.Value = Color3.fromHSV(self.Hue, self.Sat, self.Val)
        self.Preview.BackgroundColor3 = self.Value
        self.RGBLabel.Text = self:GetRGBText()
        self.HexInput.Text = self:GetHexText()
        self.Callback(self.Value)
        
        -- Auto save
        if ConfigHandler and ConfigHandler.TriggerAutoSave then
            ConfigHandler:TriggerAutoSave()
        end
    end
    
    -- SV picker input
    self.SVPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = "SV"
            
            local relX = math.clamp((input.Position.X - self.SVPicker.AbsolutePosition.X) / self.SVPicker.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - self.SVPicker.AbsolutePosition.Y) / self.SVPicker.AbsoluteSize.Y, 0, 1)
            
            self.Sat = relX
            self.Val = 1 - relY
            updateCursors()
            updateColor()
        end
    end)
    
    -- Hue slider input
    self.HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = "Hue"
            
            local relY = math.clamp((input.Position.Y - self.HueSlider.AbsolutePosition.Y) / self.HueSlider.AbsoluteSize.Y, 0, 1)
            
            self.Hue = relY
            updateCursors()
            updateColor()
        end
    end)
    
    -- Global input
    self.InputChanged = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            if self.Dragging == "SV" then
                local relX = math.clamp((input.Position.X - self.SVPicker.AbsolutePosition.X) / self.SVPicker.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - self.SVPicker.AbsolutePosition.Y) / self.SVPicker.AbsoluteSize.Y, 0, 1)
                
                self.Sat = relX
                self.Val = 1 - relY
                updateCursors()
                updateColor()
            elseif self.Dragging == "Hue" then
                local relY = math.clamp((input.Position.Y - self.HueSlider.AbsolutePosition.Y) / self.HueSlider.AbsoluteSize.Y, 0, 1)
                
                self.Hue = relY
                updateCursors()
                updateColor()
            end
        end
    end)
    
    self.InputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = nil
        end
    end)
    
    -- Hex input
    self.HexInput.FocusLost:Connect(function()
        local hex = self.HexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            
            if r and g and b then
                self.Value = Color3.fromRGB(r, g, b)
                self.Hue, self.Sat, self.Val = Color3.toHSV(self.Value)
                updateCursors()
                self.Preview.BackgroundColor3 = self.Value
                self.RGBLabel.Text = self:GetRGBText()
                self.Callback(self.Value)
            end
        end
        self.HexInput.Text = self:GetHexText()
    end)
    
    -- Toggle picker
    self.Preview.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        self.PickerPanel.Visible = self.Open
    end)
    
    -- Close on outside click
    self.ClickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.Open and not self.Dragging then
                local mousePos = input.Position
                local panelPos = self.PickerPanel.AbsolutePosition
                local panelSize = self.PickerPanel.AbsoluteSize
                local previewPos = self.Preview.AbsolutePosition
                local previewSize = self.Preview.AbsoluteSize
                
                local inPanel = mousePos.X >= panelPos.X and mousePos.X <= panelPos.X + panelSize.X and
                               mousePos.Y >= panelPos.Y and mousePos.Y <= panelPos.Y + panelSize.Y
                local inPreview = mousePos.X >= previewPos.X and mousePos.X <= previewPos.X + previewSize.X and
                                 mousePos.Y >= previewPos.Y and mousePos.Y <= previewPos.Y + previewSize.Y
                
                if not inPanel and not inPreview then
                    self.Open = false
                    self.PickerPanel.Visible = false
                end
            end
        end
    end)
    
    -- Additional Methods
    function self:Set(color)
        self.Value = color
        self.Hue, self.Sat, self.Val = Color3.toHSV(color)
        updateCursors()
        self.Preview.BackgroundColor3 = color
        self.RGBLabel.Text = self:GetRGBText()
        self.HexInput.Text = self:GetHexText()
    end
    
    function self:Get()
        return self.Value
    end
    
    function self:Destroy()
        if self.InputChanged then
            self.InputChanged:Disconnect()
        end
        if self.InputEnded then
            self.InputEnded:Disconnect()
        end
        if self.ClickConnection then
            self.ClickConnection:Disconnect()
        end
        if ConfigHandler and self.Flag then
            ConfigHandler:Unregister(self.Flag)
        end
        self.Container:Destroy()
    end
    
    -- Register to config
    if ConfigHandler and self.Flag then
        ConfigHandler:Register(self.Flag, "ColorPicker",
            function()
                return {R = self.Value.R, G = self.Value.G, B = self.Value.B}
            end,
            function(value)
                if value and value.R then
                    self:Set(Color3.new(value.R, value.G, value.B))
                end
            end
        )
    end
    
    return self
end

return ColorPicker
