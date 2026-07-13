--[[
    NTG UI Library - Button Component
]]

local Button = {}
Button.__index = Button

function Button.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, Button)
    self.Name = options.Name or "Button"
    self.Callback = options.Callback or function() end
    self.Tab = tab
    self.Theme = Theme  -- Store Theme reference for dynamic color
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Button_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 35)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = elementCount
    self.Container.Active = true
    self.Container.Parent = tab.Page
    
    -- Button element
    self.Element = Instance.new("TextButton")
    self.Element.Name = "ButtonElement"
    self.Element.Size = UDim2.new(1, 0, 1, 0)
    self.Element.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    self.Element.BackgroundTransparency = 0.32
    self.Element.BorderSizePixel = 0
    self.Element.Text = self.Name
    self.Element.TextColor3 = Theme.Current.Text
    self.Element.TextSize = 14
    self.Element.Font = Enum.Font.GothamMedium
    self.Element.AutoButtonColor = false
    self.Element.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.Element
    
    -- Hover effect with dynamic Theme colors
    self.Element.MouseEnter:Connect(function()
        if Animation then
            Animation:Play(self.Element, {BackgroundColor3 = Theme.Current.AccentHover or Theme.Current.Accent}, 0.15)
        else
            self.Element.BackgroundColor3 = Theme.Current.AccentHover or Theme.Current.Accent
        end
    end)
    
    self.Element.MouseLeave:Connect(function()
        if Animation then
            Animation:Play(self.Element, {BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface}, 0.15)
        else
            self.Element.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
        end
    end)
    
    -- Click event
    self.Element.MouseButton1Click:Connect(function()
        self.Callback()
    end)
    
    -- Methods
    function self:SetText(text)
        self.Element.Text = text
    end
    
    function self:SetCallback(callback)
        self.Callback = callback
    end
    
    function self:Destroy()
        self.Container:Destroy()
    end
    
    return self
end

return Button
