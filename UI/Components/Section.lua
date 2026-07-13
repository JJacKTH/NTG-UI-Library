--[[
    NTG UI Library - Section Component
    Collapsible section for grouping elements
    รองรับการเพิ่ม components ภายใน Section
]]

local Section = {}
Section.__index = Section

-- Components จะถูก inject จาก Loader
Section.Components = nil

function Section.new(tab, options, Theme, Animation, ConfigHandler, Components)
    options = options or {}
    
    local self = setmetatable({}, Section)
    self.Name = options.Name or "Section"
    self.Collapsed = options.Collapsed or false
    self.Tab = tab
    self.Elements = {}
    self.Theme = Theme
    self.Animation = Animation
    self.ConfigHandler = ConfigHandler
    self.Components = Components
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Section_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 30)
    self.Container.BackgroundColor3 = Theme.Current.Secondary
    self.Container.BackgroundTransparency = 0.5
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.LayoutOrder = elementCount
    self.Container.Parent = tab.Page
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = self.Container
    
    -- Header
    self.Header = Instance.new("TextButton")
    self.Header.Name = "Header"
    self.Header.Size = UDim2.new(1, 0, 0, 30)
    self.Header.BackgroundTransparency = 1
    self.Header.BorderSizePixel = 0
    self.Header.Text = ""
    self.Header.AutoButtonColor = false
    self.Header.Parent = self.Container
    
    -- Title
    self.Title = Instance.new("TextLabel")
    self.Title.Name = "Title"
    self.Title.Size = UDim2.new(1, -40, 1, 0)
    self.Title.Position = UDim2.new(0, 10, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = self.Name
    self.Title.TextColor3 = Theme.Current.Text
    self.Title.TextSize = 13
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.Header
    
    -- Arrow
    self.Arrow = Instance.new("TextLabel")
    self.Arrow.Name = "Arrow"
    self.Arrow.Size = UDim2.new(0, 20, 1, 0)
    self.Arrow.Position = UDim2.new(1, -25, 0, 0)
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.Text = self.Collapsed and "▶" or "▼"
    self.Arrow.TextColor3 = Theme.Current.SubText
    self.Arrow.TextSize = 10
    self.Arrow.Font = Enum.Font.GothamBold
    self.Arrow.Parent = self.Header
    
    -- Content container (สำหรับ components ที่เพิ่มเข้ามา)
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -10, 0, 0)
    self.Content.Position = UDim2.new(0.5, 0, 0, 32)
    self.Content.AnchorPoint = Vector2.new(0.5, 0)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Container
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = self.Content
    
    -- Create a fake "page" object for components to use
    self.Page = self.Content
    
    -- Auto resize
    self.ContentLayout = contentLayout
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self:UpdateSize()
    end)
    
    -- Toggle collapse
    local function toggleCollapse()
        self.Collapsed = not self.Collapsed
        self:UpdateSize()
        
        self.Arrow.Text = self.Collapsed and "▶" or "▼"
    end
    
    self.Header.MouseButton1Click:Connect(toggleCollapse)
    
    -- Methods
    function self:UpdateSize()
        local contentHeight = self.ContentLayout.AbsoluteContentSize.Y
        local targetHeight = self.Collapsed and 30 or (35 + contentHeight)
        
        if Animation then
            Animation:Play(self.Container, {Size = UDim2.new(1, -10, 0, targetHeight)}, 0.2)
            Animation:Play(self.Content, {Size = UDim2.new(1, -10, 0, contentHeight)}, 0.2)
        else
            self.Container.Size = UDim2.new(1, -10, 0, targetHeight)
            self.Content.Size = UDim2.new(1, -10, 0, contentHeight)
        end
    end
    
    function self:SetCollapsed(collapsed)
        if self.Collapsed ~= collapsed then
            self.Collapsed = collapsed
            self:UpdateSize()
            self.Arrow.Text = self.Collapsed and "▶" or "▼"
        end
    end
    
    function self:Destroy()
        self.Container:Destroy()
    end
    
    -- ================================================================
    -- ADD COMPONENT METHODS (ให้ใช้ Section:AddToggle() ได้)
    -- ================================================================
    function self:AddButton(opts)
        if not self.Components or not self.Components.Button then return nil end
        local component = self.Components.Button.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddToggle(opts)
        if not self.Components or not self.Components.Toggle then return nil end
        local component = self.Components.Toggle.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddTextbox(opts)
        if not self.Components or not self.Components.Textbox then return nil end
        local component = self.Components.Textbox.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddDropdown(opts)
        if not self.Components or not self.Components.Dropdown then return nil end
        local component = self.Components.Dropdown.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddSlider(opts)
        if not self.Components or not self.Components.Slider then return nil end
        local component = self.Components.Slider.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddColorPicker(opts)
        if not self.Components or not self.Components.ColorPicker then return nil end
        local component = self.Components.ColorPicker.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddKeybind(opts)
        if not self.Components or not self.Components.Keybind then return nil end
        local component = self.Components.Keybind.new(self, opts, Theme, Animation, ConfigHandler)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    function self:AddLabel(opts)
        if not self.Components or not self.Components.Label then return nil end
        local component = self.Components.Label.new(self, opts, Theme, Animation)
        table.insert(self.Elements, component)
        self:UpdateSize()
        return component
    end
    
    -- Initial update
    self:UpdateSize()
    
    return self
end

return Section
