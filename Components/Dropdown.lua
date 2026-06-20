--[[
    Antigravity UI Library - Dropdown Component
    Supports Single/Multi select with Searchable feature
]]

local Dropdown = {}
Dropdown.__index = Dropdown

local UserInputService = game:GetService("UserInputService")

function Dropdown.new(tab, options, Theme, Animation, ConfigHandler)
    options = options or {}
    
    local self = setmetatable({}, Dropdown)
    self.Name = options.Name or "Dropdown"
    self.Options = options.Options or {}
    self.Default = options.Default
    self.Multi = options.Multi or false
    self.Searchable = options.Searchable or false
    self.Callback = options.Callback or function() end
    self.Flag = options.Flag
    self.Tab = tab
    self.Open = false
    
    -- Initialize value
    if self.Multi then
        self.Value = {}
        if type(self.Default) == "table" then
            for _, opt in ipairs(self.Default) do
                self.Value[opt] = true
            end
        end
    else
        local firstOption = ""
        if #self.Options > 0 then
            if type(self.Options[1]) == "table" and self.Options[1].Group then
                local firstGroupItems = self.Options[1].Items or {}
                firstOption = firstGroupItems[1] or ""
            else
                firstOption = self.Options[1] or ""
            end
        end
        self.Value = self.Default or firstOption
    end
    
    -- Helper methods (defined early for use during UI creation)
    function self:GetDisplayText()
        if self.Multi then
            local selected = self:GetSelectedList()
            if #selected == 0 then
                return "None selected"
            elseif #selected == 1 then
                return selected[1]
            else
                return #selected .. " selected"
            end
        else
            return self.Value or "None"
        end
    end
    
    function self:GetSelectedList()
        if self.Multi then
            local list = {}
            for opt, selected in pairs(self.Value) do
                if selected then
                    table.insert(list, opt)
                end
            end
            return list
        else
            return {self.Value}
        end
    end
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Dropdown_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 55)
    self.Container.BackgroundColor3 = Theme.Current.Secondary
    self.Container.BackgroundTransparency = 0
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
    self.Label.Size = UDim2.new(1, -20, 0, 20)
    self.Label.Position = UDim2.new(0, 10, 0, 5)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Name
    self.Label.TextColor3 = Theme.Current.Text
    self.Label.TextSize = 13
    self.Label.Font = Enum.Font.GothamMedium
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.ZIndex = 2
    self.Label.Parent = self.Container
    
    -- Dropdown button
    self.Button = Instance.new("TextButton")
    self.Button.Name = "DropdownButton"
    self.Button.Size = UDim2.new(1, -20, 0, 25)
    self.Button.Position = UDim2.new(0, 10, 0, 25)
    self.Button.BackgroundColor3 = Theme.Current.Tertiary
    self.Button.BackgroundTransparency = 0
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.ZIndex = 2
    self.Button.Parent = self.Container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = self.Button
    
    -- Selected text
    self.SelectedLabel = Instance.new("TextLabel")
    self.SelectedLabel.Name = "Selected"
    self.SelectedLabel.Size = UDim2.new(1, -30, 1, 0)
    self.SelectedLabel.Position = UDim2.new(0, 8, 0, 0)
    self.SelectedLabel.BackgroundTransparency = 1
    self.SelectedLabel.Text = self:GetDisplayText()
    self.SelectedLabel.TextColor3 = Theme.Current.Text
    self.SelectedLabel.TextSize = 12
    self.SelectedLabel.Font = Enum.Font.Gotham
    self.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    self.SelectedLabel.ZIndex = 2
    self.SelectedLabel.Parent = self.Button
    
    -- Arrow icon
    self.Arrow = Instance.new("TextLabel")
    self.Arrow.Name = "Arrow"
    self.Arrow.Size = UDim2.new(0, 20, 1, 0)
    self.Arrow.Position = UDim2.new(1, -25, 0, 0)
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.Text = "▼"
    self.Arrow.TextColor3 = Theme.Current.SubText
    self.Arrow.TextSize = 10
    self.Arrow.Font = Enum.Font.GothamBold
    self.Arrow.ZIndex = 2
    self.Arrow.Parent = self.Button
    
    -- Dropdown list container
    self.ListContainer = Instance.new("Frame")
    self.ListContainer.Name = "ListContainer"
    self.ListContainer.Size = UDim2.new(1, -20, 0, 0)
    self.ListContainer.Position = UDim2.new(0, 10, 0, 52)
    self.ListContainer.BackgroundColor3 = Theme.Current.Tertiary
    self.ListContainer.BackgroundTransparency = 0
    self.ListContainer.BorderSizePixel = 0
    self.ListContainer.ClipsDescendants = true
    self.ListContainer.Visible = false
    self.ListContainer.ZIndex = 100
    self.ListContainer.Active = true
    self.ListContainer.Parent = self.Container
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = self.ListContainer
    
    -- Search box (if searchable)
    self.SearchBox = nil
    local searchHeight = 0
    if self.Searchable then
        searchHeight = 30
        
        self.SearchBox = Instance.new("TextBox")
        self.SearchBox.Name = "SearchBox"
        self.SearchBox.Size = UDim2.new(1, -10, 0, 25)
        self.SearchBox.Position = UDim2.new(0, 5, 0, 3)
        self.SearchBox.BackgroundColor3 = Theme.Current.Secondary
        self.SearchBox.BackgroundTransparency = 0
        self.SearchBox.BorderSizePixel = 0
        self.SearchBox.Text = ""
        self.SearchBox.PlaceholderText = "🔍 Search..."
        self.SearchBox.PlaceholderColor3 = Theme.Current.SubText
        self.SearchBox.TextColor3 = Theme.Current.Text
        self.SearchBox.TextSize = 12
        self.SearchBox.Font = Enum.Font.Gotham
        self.SearchBox.ClearTextOnFocus = false
        self.SearchBox.ZIndex = 101
        self.SearchBox.Parent = self.ListContainer
        
        local searchCorner = Instance.new("UICorner")
        searchCorner.CornerRadius = UDim.new(0, 4)
        searchCorner.Parent = self.SearchBox
        
        local searchPadding = Instance.new("UIPadding")
        searchPadding.PaddingLeft = UDim.new(0, 8)
        searchPadding.Parent = self.SearchBox
    end
    
    -- Options scroll
    self.OptionsList = Instance.new("ScrollingFrame")
    self.OptionsList.Name = "OptionsList"
    self.OptionsList.Size = UDim2.new(1, -4, 1, -searchHeight - 6)
    self.OptionsList.Position = UDim2.new(0, 2, 0, searchHeight + 3)
    self.OptionsList.BackgroundTransparency = 1
    self.OptionsList.BorderSizePixel = 0
    self.OptionsList.ScrollBarThickness = 2
    self.OptionsList.ScrollBarImageColor3 = Theme.Current.Accent
    self.OptionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.OptionsList.ZIndex = 101
    self.OptionsList.Parent = self.ListContainer
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.FillDirection = Enum.FillDirection.Vertical
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.Parent = self.OptionsList
    
    -- Option items storage
    self.OptionButtons = {}
    self.GroupHeaders = {}
    
    local layoutOrderCounter = 0
    
    -- Create options
    local function createOption(optionText)
        layoutOrderCounter = layoutOrderCounter + 1
        local optBtn = Instance.new("TextButton")
        optBtn.Name = "Option_" .. optionText
        optBtn.Size = UDim2.new(1, -4, 0, 25)
        optBtn.LayoutOrder = layoutOrderCounter
        optBtn.BackgroundColor3 = Theme.Current.Secondary
        optBtn.BackgroundTransparency = 1
        optBtn.BorderSizePixel = 0
        optBtn.Text = ""
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 102
        optBtn.Parent = self.OptionsList
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optBtn
        
        -- Checkbox for multi
        local checkbox = nil
        local textOffset = 8
        if self.Multi then
            textOffset = 28
            checkbox = Instance.new("Frame")
            checkbox.Name = "Checkbox"
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.Position = UDim2.new(0, 6, 0.5, 0)
            checkbox.AnchorPoint = Vector2.new(0, 0.5)
            checkbox.BackgroundColor3 = self.Value[optionText] and Theme.Current.Accent or Theme.Current.Tertiary
            checkbox.BorderSizePixel = 0
            checkbox.ZIndex = 103
            checkbox.Parent = optBtn
            
            local cbCorner = Instance.new("UICorner")
            cbCorner.CornerRadius = UDim.new(0, 3)
            cbCorner.Parent = checkbox
            
            -- Checkmark
            local checkmark = Instance.new("TextLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(1, 0, 1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Text = self.Value[optionText] and "✓" or ""
            checkmark.TextColor3 = Theme.Current.Text
            checkmark.TextSize = 12
            checkmark.Font = Enum.Font.GothamBold
            checkmark.ZIndex = 104
            checkmark.Parent = checkbox
        end
        
        -- Option text
        local optLabel = Instance.new("TextLabel")
        optLabel.Name = "Label"
        optLabel.Size = UDim2.new(1, -textOffset - 5, 1, 0)
        optLabel.Position = UDim2.new(0, textOffset, 0, 0)
        optLabel.BackgroundTransparency = 1
        optLabel.Text = optionText
        optLabel.TextColor3 = Theme.Current.Text
        optLabel.TextSize = 12
        optLabel.Font = Enum.Font.Gotham
        optLabel.TextXAlignment = Enum.TextXAlignment.Left
        optLabel.TextTruncate = Enum.TextTruncate.AtEnd
        optLabel.ZIndex = 103
        optLabel.Parent = optBtn
        
        -- Hover effect
        optBtn.MouseEnter:Connect(function()
            if Animation then
                Animation:Play(optBtn, {BackgroundTransparency = 0}, 0.1)
            else
                optBtn.BackgroundTransparency = 0
            end
        end)
        
        optBtn.MouseLeave:Connect(function()
            if Animation then
                Animation:Play(optBtn, {BackgroundTransparency = 1}, 0.1)
            else
                optBtn.BackgroundTransparency = 1
            end
        end)
        
        -- Click handler
        optBtn.MouseButton1Click:Connect(function()
            if self.Multi then
                -- Toggle selection
                self.Value[optionText] = not self.Value[optionText]
                
                if checkbox then
                    local checkmark = checkbox:FindFirstChild("Checkmark")
                    checkbox.BackgroundColor3 = self.Value[optionText] and Theme.Current.Accent or Theme.Current.Tertiary
                    if checkmark then
                        checkmark.Text = self.Value[optionText] and "✓" or ""
                    end
                end
                
                self.SelectedLabel.Text = self:GetDisplayText()
                self.Callback(self:GetSelectedList())
            else
                -- Single select
                self.Value = optionText
                self.SelectedLabel.Text = self:GetDisplayText()
                self:Close()
                self.Callback(self.Value)
            end
            
            -- Auto save
            if ConfigHandler and ConfigHandler.TriggerAutoSave then
                ConfigHandler:TriggerAutoSave()
            end
        end)
        
        self.OptionButtons[optionText] = {Button = optBtn, Checkbox = checkbox, Label = optLabel}
        return optBtn
    end
    
    -- Populate options helper
    local function populateOptions(optionsList)
        layoutOrderCounter = 0
        
        -- Clear existing
        for _, optData in pairs(self.OptionButtons) do
            if optData.Button then
                optData.Button:Destroy()
            end
        end
        self.OptionButtons = {}
        
        for _, header in ipairs(self.GroupHeaders) do
            if header.Frame then
                header.Frame:Destroy()
            end
        end
        self.GroupHeaders = {}
        
        -- Check if grouped
        local isGrouped = false
        if #optionsList > 0 and type(optionsList[1]) == "table" and optionsList[1].Group then
            isGrouped = true
        end
        
        if isGrouped then
            for _, groupData in ipairs(optionsList) do
                local groupName = groupData.Group
                local items = groupData.Items or {}
                
                -- Create Group Header
                layoutOrderCounter = layoutOrderCounter + 1
                local groupFrame = Instance.new("Frame")
                groupFrame.Name = "GroupHeader_" .. groupName
                groupFrame.Size = UDim2.new(1, -4, 0, 22)
                groupFrame.BackgroundTransparency = 1
                groupFrame.ZIndex = 102
                groupFrame.LayoutOrder = layoutOrderCounter
                groupFrame.Parent = self.OptionsList
                
                local groupLabel = Instance.new("TextLabel")
                groupLabel.Name = "Label"
                groupLabel.Size = UDim2.new(1, -10, 1, 0)
                groupLabel.Position = UDim2.new(0, 8, 0, 0)
                groupLabel.BackgroundTransparency = 1
                groupLabel.Text = groupName:upper()
                groupLabel.TextColor3 = Theme.Current.Accent
                groupLabel.TextSize = 10
                groupLabel.Font = Enum.Font.GothamBold
                groupLabel.TextXAlignment = Enum.TextXAlignment.Left
                groupLabel.ZIndex = 103
                groupLabel.Parent = groupFrame
                
                table.insert(self.GroupHeaders, {
                    Frame = groupFrame,
                    GroupName = groupName,
                    Items = items
                })
                
                for _, opt in ipairs(items) do
                    createOption(opt)
                    self.OptionButtons[opt].GroupName = groupName
                end
            end
        else
            for _, opt in ipairs(optionsList) do
                createOption(opt)
            end
        end
    end
    
    -- Populate options
    populateOptions(self.Options)
    
    -- Update canvas size
    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.OptionsList.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y)
    end)
    
    -- Search functionality
    if self.SearchBox then
        self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = self.SearchBox.Text:lower()
            
            -- Update option buttons visibility
            for optText, optData in pairs(self.OptionButtons) do
                local visible = searchText == "" or optText:lower():find(searchText, 1, true)
                optData.Button.Visible = visible
            end
            
            -- Update group headers visibility
            for _, groupHeader in ipairs(self.GroupHeaders) do
                local groupVisible = false
                for _, optText in ipairs(groupHeader.Items) do
                    local optData = self.OptionButtons[optText]
                    if optData and optData.Button.Visible then
                        groupVisible = true
                        break
                    end
                end
                groupHeader.Frame.Visible = groupVisible
            end
        end)
    end
    
    -- Toggle dropdown
    local function toggleDropdown()
        if self.Open then
            self:Close()
        else
            self:OpenList()
        end
    end
    
    self.Button.MouseButton1Click:Connect(toggleDropdown)
    
    -- Close when clicking outside
    self.ClickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            if self.Open then
                local mousePos = input.Position
                local containerPos = self.Container.AbsolutePosition
                local containerSize = self.Container.AbsoluteSize
                local listSize = self.ListContainer.AbsoluteSize
                
                local totalHeight = containerSize.Y + listSize.Y
                
                if mousePos.X < containerPos.X or mousePos.X > containerPos.X + containerSize.X or
                   mousePos.Y < containerPos.Y or mousePos.Y > containerPos.Y + totalHeight then
                    self:Close()
                end
            end
        end
    end)
    
    -- Additional Methods
    function self:OpenList()
        self.Open = true
        self.Container.ZIndex = 110
        self.ListContainer.Visible = true
        
        local totalElementsHeight = 0
        for _ in pairs(self.OptionButtons) do
            totalElementsHeight = totalElementsHeight + 27
        end
        for _ in ipairs(self.GroupHeaders) do
            totalElementsHeight = totalElementsHeight + 22
        end
        
        local searchOffset = self.Searchable and 30 or 0
        local targetHeight = math.min(totalElementsHeight + searchOffset + 6, 200)
        
        if Animation then
            Animation:Play(self.ListContainer, {Size = UDim2.new(1, -20, 0, targetHeight)}, 0.2)
            Animation:Play(self.Arrow, {Rotation = 180}, 0.2)
        else
            self.ListContainer.Size = UDim2.new(1, -20, 0, targetHeight)
            self.Arrow.Rotation = 180
        end
        
        if self.SearchBox then
            self.SearchBox.Text = ""
            self.SearchBox:CaptureFocus()
        end
    end
    
    function self:Close()
        self.Open = false
        self.Container.ZIndex = 2
        
        if Animation then
            Animation:Play(self.ListContainer, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
            Animation:Play(self.Arrow, {Rotation = 0}, 0.2)
        else
            self.ListContainer.Size = UDim2.new(1, -20, 0, 0)
            self.Arrow.Rotation = 0
        end
        
        task.delay(0.2, function()
            if not self.Open then
                self.ListContainer.Visible = false
            end
        end)
    end
    
    function self:Set(value)
        if self.Multi then
            if type(value) == "table" then
                self.Value = {}
                for _, opt in ipairs(value) do
                    self.Value[opt] = true
                end
                
                -- Update checkboxes
                for optText, optData in pairs(self.OptionButtons) do
                    if optData.Checkbox then
                        optData.Checkbox.BackgroundColor3 = self.Value[optText] and Theme.Current.Accent or Theme.Current.Tertiary
                        local checkmark = optData.Checkbox:FindFirstChild("Checkmark")
                        if checkmark then
                            checkmark.Text = self.Value[optText] and "✓" or ""
                        end
                    end
                end
            end
        else
            self.Value = value
        end
        self.SelectedLabel.Text = self:GetDisplayText()
    end
    
    function self:Get()
        if self.Multi then
            return self:GetSelectedList()
        else
            return self.Value
        end
    end
    
    function self:Refresh(newOptions)
        self.Options = newOptions or {}
        populateOptions(self.Options)
        self.SelectedLabel.Text = self:GetDisplayText()
    end
    
    function self:Destroy()
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
        ConfigHandler:Register(self.Flag, "Dropdown",
            function()
                if self.Multi then
                    return self:GetSelectedList()
                else
                    return self.Value
                end
            end,
            function(value)
                self:Set(value)
            end
        )
    end
    
    return self
end

return Dropdown
