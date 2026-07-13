--[[
    NTG UI Library - Textbox Component
]]

local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, Textbox)
    self.Name = options.Name or "Textbox"
    self.Default = options.Default or ""
    self.Placeholder = options.Placeholder or "Enter text..."
    self.Callback = options.Callback or function() end
    self.ClearOnFocus = options.ClearOnFocus or false
    self.Flag = options.Flag
    self.Tab = tab
    self.Value = self.Default
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Textbox_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 55)
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
    self.Label.Size = UDim2.new(1, -20, 0, 20)
    self.Label.Position = UDim2.new(0, 10, 0, 5)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Name
    self.Label.TextColor3 = Theme.Current.Text
    self.Label.TextSize = 13
    self.Label.Font = Enum.Font.GothamMedium
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Container
    
    -- Input box
    self.Input = Instance.new("TextBox")
    self.Input.Name = "Input"
    self.Input.Size = UDim2.new(1, -20, 0, 25)
    self.Input.Position = UDim2.new(0, 10, 0, 25)
    self.Input.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    self.Input.BackgroundTransparency = 0.08
    self.Input.BorderSizePixel = 0
    self.Input.Text = self.Value
    self.Input.PlaceholderText = self.Placeholder
    self.Input.PlaceholderColor3 = Theme.Current.SubText
    self.Input.TextColor3 = Theme.Current.Text
    self.Input.TextSize = 13
    self.Input.Font = Enum.Font.Gotham
    self.Input.TextXAlignment = Enum.TextXAlignment.Left
    self.Input.ClearTextOnFocus = self.ClearOnFocus
    self.Input.Parent = self.Container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 12)
    inputCorner.Parent = self.Input
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 8)
    inputPadding.PaddingRight = UDim.new(0, 8)
    inputPadding.Parent = self.Input
    
    -- Focus effects
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Theme.Current.Accent
    inputStroke.Thickness = 0
    inputStroke.Transparency = 0.1
    inputStroke.Parent = self.Input
    
    self.Input.Focused:Connect(function()
        if Animation then
            Animation:Play(inputStroke, {Thickness = 1.5}, 0.16)
            Animation:Play(self.Input, {BackgroundTransparency = 0.04}, 0.16)
        else
            inputStroke.Thickness = 1.5
        end
    end)
    
    self.Input.FocusLost:Connect(function(enterPressed)
        if Animation then
            Animation:Play(inputStroke, {Thickness = 0}, 0.16)
            Animation:Play(self.Input, {BackgroundTransparency = 0.08}, 0.16)
        else
            inputStroke.Thickness = 0
        end
        
        self.Value = self.Input.Text
        self.Callback(self.Value, enterPressed)
        
        -- Auto save
        if ConfigHandler and ConfigHandler.TriggerAutoSave then
            ConfigHandler:TriggerAutoSave()
        end
    end)
    
    -- Register to config
    if ConfigHandler and self.Flag then
        ConfigHandler:Register(self.Flag, "Textbox",
            function() return self.Value end,
            function(value)
                self.Value = value or ""
                self.Input.Text = self.Value
                self.Callback(self.Value)
            end
        )
    end
    
    -- Methods
    function self:Set(text)
        self.Value = text or ""
        self.Input.Text = self.Value
        self.Callback(self.Value)
    end
    
    function self:Get()
        return self.Value
    end
    
    function self:SetPlaceholder(text)
        self.Input.PlaceholderText = text
    end

    if Animation then
        Animation:CreateHoverEffect(self.Container, Theme.Current.SurfaceAlt or Theme.Current.Surface, Theme.Current.Surface or Theme.Current.Background, {Lift = true})
    end
    
    function self:Destroy()
        if ConfigHandler and self.Flag then
            ConfigHandler:Unregister(self.Flag)
        end
        self.Container:Destroy()
    end
    
    return self
end

return Textbox
