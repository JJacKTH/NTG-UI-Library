--[[
    NTG UI Library - Loader
    โหลด library จาก GitHub ผ่าน loadstring
    
    วิธีใช้:
    local NTGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/JJacKTH/NTG-UI/main/Loader.lua"))()
]]

local BASE_URL = "https://raw.githubusercontent.com/JJacKTH/NTG-UI/main/"

local cb = "?cb=" .. tostring(os.time())

-- Load all modules with safe wrapper
local function safeLoad(url, name)
    local content
    local success, err = pcall(function()
        content = game:HttpGet(url)
    end)
    if not success or not content or content == "" then
        error("[NTGUI] Failed to download " .. name .. " from: " .. url .. " | Error: " .. tostring(err or "empty response"))
    end
    
    local func, compileErr = loadstring(content)
    if not func then
        error("[NTGUI] Failed to compile " .. name .. " | Error: " .. tostring(compileErr))
    end
    
    local ok, result = pcall(func)
    if not ok then
        error("[NTGUI] Failed to execute " .. name .. " | Error: " .. tostring(result))
    end
    
    return result
end

local Theme = safeLoad(BASE_URL .. "Core/Theme.lua" .. cb, "Theme")
local Animation = safeLoad(BASE_URL .. "Core/Animation.lua" .. cb, "Animation")
local Utility = safeLoad(BASE_URL .. "Core/Utility.lua" .. cb, "Utility")
local ConfigManager = safeLoad(BASE_URL .. "Config/ConfigManager.lua" .. cb, "ConfigManager")

-- Load components
local Components = {
    Button = safeLoad(BASE_URL .. "Components/Button.lua" .. cb, "Button"),
    Toggle = safeLoad(BASE_URL .. "Components/Toggle.lua" .. cb, "Toggle"),
    Textbox = safeLoad(BASE_URL .. "Components/Textbox.lua" .. cb, "Textbox"),
    Dropdown = safeLoad(BASE_URL .. "Components/Dropdown.lua" .. cb, "Dropdown"),
    Slider = safeLoad(BASE_URL .. "Components/Slider.lua" .. cb, "Slider"),
    ColorPicker = safeLoad(BASE_URL .. "Components/ColorPicker.lua" .. cb, "ColorPicker"),
    Keybind = safeLoad(BASE_URL .. "Components/Keybind.lua" .. cb, "Keybind"),
    Label = safeLoad(BASE_URL .. "Components/Label.lua" .. cb, "Label"),
    Section = safeLoad(BASE_URL .. "Components/Section.lua" .. cb, "Section"),
    Divider = safeLoad(BASE_URL .. "Components/Divider.lua" .. cb, "Divider")
}

-- ================================================================
-- MAIN LIBRARY
-- ================================================================

local NTGUI = {}
NTGUI.__index = NTGUI
NTGUI.Version = "1.0.0"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

NTGUI.Windows = {}

function NTGUI:GetParent()
    local success, gui = pcall(function()
        local existing = CoreGui:FindFirstChild("NTGUI")
        if existing then return existing end
        local newGui = Instance.new("ScreenGui")
        newGui.Name = "NTGUI"
        newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        newGui.ResetOnSpawn = false
        newGui.Parent = CoreGui
        return newGui
    end)
    
    if success and gui then
        return gui
    else
        local player = Players.LocalPlayer
        if player then
            local playerGui = player:WaitForChild("PlayerGui")
            local existing = playerGui:FindFirstChild("NTGUI")
            if existing then return existing end
            
            local newGui = Instance.new("ScreenGui")
            newGui.Name = "NTGUI"
            newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            newGui.ResetOnSpawn = false
            newGui.Parent = playerGui
            return newGui
        end
    end
    return nil
end

function NTGUI:CreateWindow(options)
    options = options or {}
    
    local Window = {}
    Window.Title = options.Title or "NTG UI"
    Window.Size = options.Size or UDim2.new(0, 500, 0, 400)
    Window.Theme = options.Theme or "Dark"
    Window.GameName = options.GameName or options.Title or "Default"
    Window.ConfigName = options.ConfigName or "Config"
    Window.AutoSave = options.AutoSave or false
    Window.AutoLoad = options.AutoLoad or false
    Window.FolderName = options.FolderName
    Window.Resizable = options.Resizable ~= false  -- Default true
    Window.MinSize = options.MinSize or UDim2.new(0, 400, 0, 300)
    Window.MaxSize = options.MaxSize or UDim2.new(0, 900, 0, 700)
    Window.SaveSize = options.SaveSize ~= false  -- Default true
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Minimized = false
    Window.Visible = true
    Window.OnClose = options.OnClose
    
    if Theme.Presets and Theme.Presets[Window.Theme] then
        Theme.Current = Theme.Presets[Window.Theme]
    end
    
    -- CreateHandler(gameName, configName, autoSave, autoLoad, baseFolder)
    Window.ConfigHandler = ConfigManager:CreateHandler(Window.GameName, Window.ConfigName, Window.AutoSave, Window.AutoLoad, Window.FolderName)
    
    -- Register Theme for save/load
    Window.ConfigHandler:Register("__Theme__", "Theme", 
        function() return Window.Theme end,
        function(value)
            if value and Theme.Presets[value] then
                -- Use SetTheme to properly refresh UI after load
                task.defer(function()
                    if Window.SetTheme then
                        Window:SetTheme(value)
                    else
                        Window.Theme = value
                        Theme.Current = Theme.Presets[value]
                    end
                end)
            end
        end
    )
    
    local parent = self:GetParent()
    if not parent then
        warn("[NTGUI] Failed to get parent")
        return nil
    end
    
    -- Main container
    Window.Container = Instance.new("Frame")
    Window.Container.Name = "Window_" .. Window.Title
    Window.Container.Size = Window.Size
    Window.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Window.Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.Container.BackgroundColor3 = Theme.Current.Background
    Window.Container.BorderSizePixel = 0
    Window.Container.ClipsDescendants = true
    Window.Container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = Window.Container
    
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 1
    shadow.Transparency = 0.5
    shadow.Parent = Window.Container
    
    -- Title bar
    Window.TitleBar = Instance.new("Frame")
    Window.TitleBar.Name = "TitleBar"
    Window.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    Window.TitleBar.BackgroundColor3 = Theme.Current.Secondary
    Window.TitleBar.BorderSizePixel = 0
    Window.TitleBar.Parent = Window.Container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = Window.TitleBar
    
    Window.TitleFix = Instance.new("Frame")
    Window.TitleFix.Size = UDim2.new(1, 0, 0, 15)
    Window.TitleFix.Position = UDim2.new(0, 0, 1, -15)
    Window.TitleFix.BackgroundColor3 = Theme.Current.Secondary
    Window.TitleFix.BorderSizePixel = 0
    Window.TitleFix.Parent = Window.TitleBar
    
    Window.TitleLabel = Instance.new("TextLabel")
    Window.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    Window.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    Window.TitleLabel.BackgroundTransparency = 1
    Window.TitleLabel.Text = Window.Title
    Window.TitleLabel.TextColor3 = Theme.Current.Text
    Window.TitleLabel.TextSize = 16
    Window.TitleLabel.Font = Enum.Font.GothamBold
    Window.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    Window.TitleLabel.Parent = Window.TitleBar
    
    -- Controls
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Size = UDim2.new(0, 70, 1, 0)
    controlsContainer.Position = UDim2.new(1, -80, 0, 0)
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Parent = Window.TitleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 5)
    controlsLayout.Parent = controlsContainer
    
    Window.MinimizeBtn = Instance.new("TextButton")
    Window.MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    Window.MinimizeBtn.BackgroundColor3 = Theme.Current.Tertiary
    Window.MinimizeBtn.BorderSizePixel = 0
    Window.MinimizeBtn.Text = "−"
    Window.MinimizeBtn.TextColor3 = Theme.Current.Text
    Window.MinimizeBtn.TextSize = 20
    Window.MinimizeBtn.Font = Enum.Font.GothamBold
    Window.MinimizeBtn.AutoButtonColor = false
    Window.MinimizeBtn.Parent = controlsContainer
    
    Instance.new("UICorner", Window.MinimizeBtn).CornerRadius = UDim.new(0, 6)
    
    Window.CloseBtn = Instance.new("TextButton")
    Window.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    Window.CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    Window.CloseBtn.BorderSizePixel = 0
    Window.CloseBtn.Text = "×"
    Window.CloseBtn.TextColor3 = Theme.Current.Text
    Window.CloseBtn.TextSize = 20
    Window.CloseBtn.Font = Enum.Font.GothamBold
    Window.CloseBtn.AutoButtonColor = false
    Window.CloseBtn.Parent = controlsContainer
    
    Instance.new("UICorner", Window.CloseBtn).CornerRadius = UDim.new(0, 6)
    
    -- Dynamic hover effects for minimize button
    Window.MinimizeBtn.MouseEnter:Connect(function()
        Animation:Play(Window.MinimizeBtn, {BackgroundColor3 = Theme.Current.Accent}, 0.15)
    end)
    Window.MinimizeBtn.MouseLeave:Connect(function()
        Animation:Play(Window.MinimizeBtn, {BackgroundColor3 = Theme.Current.Tertiary}, 0.15)
    end)
    -- Close button hover (always red tones)
    Animation:CreateHoverEffect(Window.CloseBtn, Color3.fromRGB(220, 100, 100), Color3.fromRGB(200, 80, 80))
    
    -- Search Bar Area
    Window.SearchContainer = Instance.new("Frame")
    Window.SearchContainer.Name = "SearchContainer"
    Window.SearchContainer.Size = UDim2.new(1, -10, 0, 30)
    Window.SearchContainer.Position = UDim2.new(0, 5, 0, 45)
    Window.SearchContainer.BackgroundColor3 = Theme.Current.Secondary
    Window.SearchContainer.BorderSizePixel = 0
    Window.SearchContainer.Parent = Window.Container
    
    Instance.new("UICorner", Window.SearchContainer).CornerRadius = UDim.new(0, 6)
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "Icon"
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 10, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://6031154871" -- Search icon
    searchIcon.ImageColor3 = Theme.Current.SubText
    searchIcon.Parent = Window.SearchContainer
    
    Window.SearchBar = Instance.new("TextBox")
    Window.SearchBar.Name = "Input"
    Window.SearchBar.Size = UDim2.new(1, -35, 1, 0)
    Window.SearchBar.Position = UDim2.new(0, 35, 0, 0)
    Window.SearchBar.BackgroundTransparency = 1
    Window.SearchBar.Text = ""
    Window.SearchBar.PlaceholderText = "Search features..."
    Window.SearchBar.TextColor3 = Theme.Current.Text
    Window.SearchBar.PlaceholderColor3 = Theme.Current.SubText
    Window.SearchBar.TextSize = 14
    Window.SearchBar.Font = Enum.Font.Gotham
    Window.SearchBar.TextXAlignment = Enum.TextXAlignment.Left
    Window.SearchBar.ClearTextOnFocus = false
    Window.SearchBar.Parent = Window.SearchContainer
    
    -- Search Results Container (Floating)
    Window.ClickBlocker = Instance.new("TextButton") -- Blocks clicks outside results
    Window.ClickBlocker.Name = "ClickBlocker"
    Window.ClickBlocker.Size = UDim2.new(1, 0, 1, 0)
    Window.ClickBlocker.BackgroundTransparency = 1
    Window.ClickBlocker.Text = ""
    Window.ClickBlocker.Visible = false
    Window.ClickBlocker.ZIndex = 50
    Window.ClickBlocker.Parent = Window.Container
    
    Window.SearchResults = Instance.new("ScrollingFrame")
    Window.SearchResults.Name = "SearchResults"
    Window.SearchResults.Size = UDim2.new(1, -10, 0, 200)
    Window.SearchResults.Position = UDim2.new(0, 5, 0, 80)
    Window.SearchResults.BackgroundColor3 = Theme.Current.Secondary
    Window.SearchResults.BorderSizePixel = 0
    Window.SearchResults.Visible = false
    Window.SearchResults.ZIndex = 51
    Window.SearchResults.ScrollBarThickness = 2
    Window.SearchResults.ScrollBarImageColor3 = Theme.Current.Accent
    Window.SearchResults.Parent = Window.Container
    
    Instance.new("UICorner", Window.SearchResults).CornerRadius = UDim.new(0, 6)
    
    local resultsLayout = Instance.new("UIListLayout")
    resultsLayout.FillDirection = Enum.FillDirection.Vertical
    resultsLayout.Padding = UDim.new(0, 2)
    resultsLayout.Parent = Window.SearchResults

    -- Tab sidebar (Shifted down)
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Size = UDim2.new(0, 140, 1, -90) -- Adjusted height
    Window.TabContainer.Position = UDim2.new(0, 5, 0, 85) -- Shifted Y
    Window.TabContainer.BackgroundColor3 = Theme.Current.Secondary
    Window.TabContainer.BackgroundTransparency = 0.5
    Window.TabContainer.BorderSizePixel = 0
    Window.TabContainer.Parent = Window.Container
    
    Instance.new("UICorner", Window.TabContainer).CornerRadius = UDim.new(0, 8)
    
    Window.TabScroll = Instance.new("ScrollingFrame")
    Window.TabScroll.Size = UDim2.new(1, -10, 1, -10)
    Window.TabScroll.Position = UDim2.new(0, 5, 0, 5)
    Window.TabScroll.BackgroundTransparency = 1
    Window.TabScroll.BorderSizePixel = 0
    Window.TabScroll.ScrollBarThickness = 2
    Window.TabScroll.ScrollBarImageColor3 = Theme.Current.Accent
    Window.TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Window.TabScroll.Parent = Window.TabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = Window.TabScroll
    
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Window.TabScroll.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content area (Shifted down)
    Window.ContentContainer = Instance.new("Frame")
    Window.ContentContainer.Size = UDim2.new(1, -160, 1, -95) -- Adjusted height
    Window.ContentContainer.Position = UDim2.new(0, 150, 0, 85) -- Shifted Y
    Window.ContentContainer.BackgroundTransparency = 1
    Window.ContentContainer.ClipsDescendants = true
    Window.ContentContainer.Parent = Window.Container
    
    -- ================================================================
    -- GLOBAL SEARCH LOGIC
    -- ================================================================
    
    local function UpdateSearchResults()
        local query = Window.SearchBar.Text:lower()
        
        -- Clear existing results
        for _, child in ipairs(Window.SearchResults:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        if query == "" then
            Window.SearchResults.Visible = false
            Window.ClickBlocker.Visible = false
            return
        end
        
        local matches = {}
        
        -- Recursive search function
        local function searchInList(list, parentTab, parentSection)
            for _, element in ipairs(list) do
                -- Check string match
                local name = nil
                if element.Configs and element.Configs.Name then
                    name = element.Configs.Name
                elseif element.Label and element.Label:IsA("TextLabel") then
                    name = element.Label.Text
                end
                
                if name and string.find(name:lower(), query, 1, true) then
                    table.insert(matches, {
                        Name = name,
                        Type = "Element",
                        Tab = parentTab,
                        Section = parentSection, -- Can be nil
                        Element = element
                    })
                end
                
                -- Recursive check for container elements (like Sections)
                if element.Elements then
                    searchInList(element.Elements, parentTab, element)
                end
            end
        end
        
        -- Index and search all tabs
        for _, tab in ipairs(Window.Tabs) do
            if tab.Elements then
                searchInList(tab.Elements, tab, nil)
            end
        end
        
        -- Display results
        if #matches > 0 then
            Window.SearchResults.Visible = true
            Window.ClickBlocker.Visible = true
            Window.SearchResults.Size = UDim2.new(1, -10, 0, math.min(#matches * 35, 200))
            
            for _, match in ipairs(matches) do
                local btn = Instance.new("TextButton")
                btn.Name = "ResultBtn"
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = Theme.Current.Tertiary
                btn.BackgroundTransparency = 1
                local locInfo = match.Section and (match.Tab.Name .. " > " .. match.Section.Name) or match.Tab.Name
                btn.Text = "  " .. match.Name .. "  (" .. locInfo .. ")"
                btn.TextColor3 = Theme.Current.Text
                btn.TextSize = 13
                btn.Font = Enum.Font.Gotham
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.AutoButtonColor = false
                btn.Parent = Window.SearchResults
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                
                btn.MouseEnter:Connect(function()
                    Animation:Play(btn, {BackgroundTransparency = 0}, 0.1)
                end)
                btn.MouseLeave:Connect(function()
                    Animation:Play(btn, {BackgroundTransparency = 1}, 0.1)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    match.Tab:Select()
                    
                    -- Expand section if needed
                    if match.Section and match.Section.SetCollapsed then
                        match.Section:SetCollapsed(false)
                    end
                    
                    Window.SearchBar.Text = ""
                    Window.SearchResults.Visible = false
                    Window.ClickBlocker.Visible = false
                    
                    if match.Element.Container then
                        local originalColor = match.Element.Container.BackgroundColor3
                        task.spawn(function()
                            -- Wait briefly for layout update if section was just expanded
                            task.wait(0.1)
                             if match.Element.Container.Parent and match.Element.Container.Parent:IsA("ScrollingFrame") then
                                -- Ideally, we would set CanvasPosition here to scroll to it
                                -- But that requires calculation. For now, the visual flash is good enough.
                            end
                            
                            for i = 1, 3 do
                                Animation:Play(match.Element.Container, {BackgroundColor3 = Theme.Current.Accent}, 0.2)
                                task.wait(0.2)
                                Animation:Play(match.Element.Container, {BackgroundColor3 = originalColor}, 0.2)
                                task.wait(0.2)
                            end
                        end)
                    end
                end)
            end
        else
            Window.SearchResults.Visible = false
            Window.ClickBlocker.Visible = false
        end
    end
    
    Window.SearchBar:GetPropertyChangedSignal("Text"):Connect(UpdateSearchResults)
    
    -- Hide results when clicking outside
    Window.ClickBlocker.MouseButton1Click:Connect(function()
        Window.SearchResults.Visible = false
        Window.ClickBlocker.Visible = false
    end)

    Utility:MakeDraggable(Window.Container, Window.TitleBar)
    
    -- ================================================================
    -- RESIZE HANDLES
    -- ================================================================
    if Window.Resizable then
        local resizing = false
        local resizeType = nil
        local startSize = nil
        local startPos = nil
        
        -- Corner resize handle (bottom-right)
        Window.ResizeCorner = Instance.new("TextButton")
        Window.ResizeCorner.Name = "ResizeCorner"
        Window.ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
        Window.ResizeCorner.Position = UDim2.new(1, -20, 1, -20)
        Window.ResizeCorner.BackgroundTransparency = 1
        Window.ResizeCorner.Text = ""
        Window.ResizeCorner.ZIndex = 11
        Window.ResizeCorner.AutoButtonColor = false
        Window.ResizeCorner.Parent = Window.Container

        -- Create resize graphic lines
        Window.ResizeLine1 = Instance.new("Frame")
        Window.ResizeLine1.Name = "Line1"
        Window.ResizeLine1.Size = UDim2.new(0, 6, 0, 2)
        Window.ResizeLine1.Position = UDim2.new(1, -6, 1, -6)
        Window.ResizeLine1.BackgroundColor3 = Theme.Current.SubText
        Window.ResizeLine1.BorderSizePixel = 0
        Window.ResizeLine1.Rotation = 45
        Window.ResizeLine1.Parent = Window.ResizeCorner

        Window.ResizeLine2 = Instance.new("Frame")
        Window.ResizeLine2.Name = "Line2"
        Window.ResizeLine2.Size = UDim2.new(0, 12, 0, 2)
        Window.ResizeLine2.Position = UDim2.new(1, -9, 1, -9)
        Window.ResizeLine2.BackgroundColor3 = Theme.Current.SubText
        Window.ResizeLine2.BorderSizePixel = 0
        Window.ResizeLine2.Rotation = 45
        Window.ResizeLine2.Parent = Window.ResizeCorner
        
        -- Right edge resize handle
        Window.ResizeRight = Instance.new("TextButton")
        Window.ResizeRight.Name = "ResizeRight"
        Window.ResizeRight.Size = UDim2.new(0, 6, 1, -60)
        Window.ResizeRight.Position = UDim2.new(1, -3, 0, 45)
        Window.ResizeRight.BackgroundTransparency = 1
        Window.ResizeRight.Text = ""
        Window.ResizeRight.ZIndex = 10
        Window.ResizeRight.AutoButtonColor = false
        Window.ResizeRight.Parent = Window.Container
        
        -- Bottom edge resize handle
        Window.ResizeBottom = Instance.new("TextButton")
        Window.ResizeBottom.Name = "ResizeBottom"
        Window.ResizeBottom.Size = UDim2.new(1, -30, 0, 6)
        Window.ResizeBottom.Position = UDim2.new(0, 0, 1, -3)
        Window.ResizeBottom.BackgroundTransparency = 1
        Window.ResizeBottom.Text = ""
        Window.ResizeBottom.ZIndex = 10
        Window.ResizeBottom.AutoButtonColor = false
        Window.ResizeBottom.Parent = Window.Container
        
        -- Resize function
        local function clampSize(width, height)
            local minW = Window.MinSize.X.Offset
            local minH = Window.MinSize.Y.Offset
            local maxW = Window.MaxSize.X.Offset
            local maxH = Window.MaxSize.Y.Offset
            return math.clamp(width, minW, maxW), math.clamp(height, minH, maxH)
        end
        
        local function updateResize(input)
            if not resizing or not startSize or not startPos then return end
            
            local delta = input.Position - startPos
            local newWidth = startSize.X.Offset
            local newHeight = startSize.Y.Offset
            
            if resizeType == "corner" or resizeType == "right" then
                newWidth = startSize.X.Offset + delta.X
            end
            if resizeType == "corner" or resizeType == "bottom" then
                newHeight = startSize.Y.Offset + delta.Y
            end
            
            newWidth, newHeight = clampSize(newWidth, newHeight)
            
            if Animation then
                Animation:Play(Window.Container, {Size = UDim2.new(0, newWidth, 0, newHeight)}, 0.05)
            else
                Window.Container.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end
        
        local function startResize(rType)
            return function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    resizing = true
                    resizeType = rType
                    startSize = Window.Container.Size
                    startPos = input.Position
                end
            end
        end
        
        local function endResize(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                if resizing and Window.SaveSize then
                    -- Save size to config
                    Window.Size = Window.Container.Size
                    if Window.ConfigHandler and Window.ConfigHandler.AutoSave then
                        Window.ConfigHandler:TriggerAutoSave()
                    end
                end
                resizing = false
                resizeType = nil
                startSize = nil
                startPos = nil
            end
        end
        
        -- Connect events
        Window.ResizeCorner.InputBegan:Connect(startResize("corner"))
        Window.ResizeRight.InputBegan:Connect(startResize("right"))
        Window.ResizeBottom.InputBegan:Connect(startResize("bottom"))
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or 
               input.UserInputType == Enum.UserInputType.Touch then
                updateResize(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(endResize)
        
        -- Hover effects
        Window.ResizeCorner.MouseEnter:Connect(function()
            Window.ResizeCorner.TextColor3 = Theme.Current.Accent
        end)
        Window.ResizeCorner.MouseLeave:Connect(function()
            Window.ResizeCorner.TextColor3 = Theme.Current.SubText
        end)
        
        -- Preset sizes method
        function Window:SetSize(preset)
            local sizes = {
                Small = UDim2.new(0, 400, 0, 300),
                Medium = UDim2.new(0, 550, 0, 420),
                Large = UDim2.new(0, 700, 0, 550)
            }
            
            local targetSize = sizes[preset]
            if targetSize then
                local w, h = clampSize(targetSize.X.Offset, targetSize.Y.Offset)
                if Animation then
                    Animation:Play(Window.Container, {Size = UDim2.new(0, w, 0, h)}, 0.3)
                else
                    Window.Container.Size = UDim2.new(0, w, 0, h)
                end
                Window.Size = UDim2.new(0, w, 0, h)
            end
        end
    end
    
    -- Floating Icon
    if options.FloatingIcon and options.FloatingIcon.Enabled ~= false then
        local iconPosition = options.FloatingIcon.Position or UDim2.new(0, 20, 0.5, 0)
        
        Window.FloatingIcon = Instance.new("ImageButton")
        Window.FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
        Window.FloatingIcon.Position = iconPosition
        Window.FloatingIcon.AnchorPoint = Vector2.new(0, 0.5)
        Window.FloatingIcon.BackgroundColor3 = Theme.Current.Background
        Window.FloatingIcon.BorderSizePixel = 0
        Window.FloatingIcon.Image = options.FloatingIcon.Image or "rbxassetid://94618813054930"
        Window.FloatingIcon.ImageColor3 = options.FloatingIcon.ImageColor3 or Theme.Current.Accent
        Window.FloatingIcon.Visible = true
        Window.FloatingIcon.Parent = parent
        
        Instance.new("UICorner", Window.FloatingIcon).CornerRadius = UDim.new(0, 10)
        local iconStroke = Instance.new("UIStroke", Window.FloatingIcon)
        iconStroke.Color = Theme.Current.Accent
        iconStroke.Thickness = 2
        
        Utility:MakeDraggable(Window.FloatingIcon)
        
        Window.FloatingIcon.MouseButton1Click:Connect(function()
            Window:Toggle()
        end)
    end
    
    -- Window methods
    function Window:Minimize()
        Window.Minimized = true
        Window.Container.Visible = false
        if Window.FloatingIcon then Window.FloatingIcon.Visible = true end
    end
    
    function Window:Maximize()
        Window.Minimized = false
        Window.Container.Visible = true
        if Window.FloatingIcon then Window.FloatingIcon.Visible = true end
    end
    
    function Window:Toggle()
        if Window.Minimized then Window:Maximize() else Window:Minimize() end
    end
    
    function Window:Hide()
        Window.Visible = false
        Window.Container.Visible = false
        if Window.FloatingIcon then Window.FloatingIcon.Visible = false end
    end
    
    function Window:Show()
        Window.Visible = true
        Window.Container.Visible = true
        if Window.FloatingIcon then Window.FloatingIcon.Visible = true end
    end
    
    function Window:Destroy()
        if Window.OnClose then
            pcall(Window.OnClose)
        end
        Window.Container:Destroy()
        if Window.FloatingIcon then Window.FloatingIcon:Destroy() end
    end
    
    function Window:SetTheme(themeName)
        if Theme.Presets and Theme.Presets[themeName] then
            Theme.Current = Theme.Presets[themeName]
            Window.Theme = themeName
            
            -- Refresh main container colors
            if Window.Container then
                Window.Container.BackgroundColor3 = Theme.Current.Background
            end
            if Window.TitleBar then
                Window.TitleBar.BackgroundColor3 = Theme.Current.Secondary
            end
            if Window.TitleLabel then
                Window.TitleLabel.TextColor3 = Theme.Current.Text
            end
            if Window.TabContainer then
                Window.TabContainer.BackgroundColor3 = Theme.Current.Secondary
            end
            -- TitleBar corner fix element
            if Window.TitleFix then
                Window.TitleFix.BackgroundColor3 = Theme.Current.Secondary
            end
            -- Minimize button
            if Window.MinimizeBtn then
                Window.MinimizeBtn.BackgroundColor3 = Theme.Current.Tertiary
                Window.MinimizeBtn.TextColor3 = Theme.Current.Text
            end
            
            -- Search Bar Refresh
            if Window.SearchContainer then
                Window.SearchContainer.BackgroundColor3 = Theme.Current.Secondary
                local icon = Window.SearchContainer:FindFirstChild("Icon")
                if icon then icon.ImageColor3 = Theme.Current.SubText end
            end
            if Window.SearchBar then
                Window.SearchBar.TextColor3 = Theme.Current.Text
                Window.SearchBar.PlaceholderColor3 = Theme.Current.SubText
            end
            if Window.SearchResults then
                Window.SearchResults.BackgroundColor3 = Theme.Current.Secondary
                Window.SearchResults.ScrollBarImageColor3 = Theme.Current.Accent
            end
            
            -- Resize Lines Refresh
            if Window.ResizeLine1 then Window.ResizeLine1.BackgroundColor3 = Theme.Current.SubText end
            if Window.ResizeLine2 then Window.ResizeLine2.BackgroundColor3 = Theme.Current.SubText end

            -- Close button text
            if Window.CloseBtn then
                Window.CloseBtn.TextColor3 = Theme.Current.Text
            end
            
            -- Resize handle
            if Window.ResizeLine1 then
                Window.ResizeLine1.BackgroundColor3 = Theme.Current.SubText
            end
            if Window.ResizeLine2 then
                Window.ResizeLine2.BackgroundColor3 = Theme.Current.SubText
            end
            
            -- Refresh tab buttons
            for _, tab in ipairs(Window.Tabs) do
                if tab.Button then
                    if Window.ActiveTab == tab then
                        tab.Button.BackgroundColor3 = Theme.Current.Accent
                        tab.Button.TextColor3 = Theme.Current.Text
                    else
                        tab.Button.TextColor3 = Theme.Current.SubText
                    end
                end
                
                -- Refresh all elements in tab
                if tab.Elements then
                    for _, element in ipairs(tab.Elements) do
                        -- Refresh based on element type
                        if element.Container then
                            -- Most elements have Container with Secondary color
                            if element.Container:FindFirstChild("ButtonElement") then
                                -- Button
                                local btn = element.Container:FindFirstChild("ButtonElement")
                                if btn then
                                    btn.BackgroundColor3 = Theme.Current.Tertiary
                                    btn.TextColor3 = Theme.Current.Text
                                end
                            else
                                element.Container.BackgroundColor3 = Theme.Current.Secondary
                            end
                        end
                        
                        -- Refresh labels
                        if element.Label then
                            element.Label.TextColor3 = Theme.Current.Text
                        end
                        
                        -- Toggle specific (SwitchBg is the toggle background)
                        if element.SwitchBg then
                            element.SwitchBg.BackgroundColor3 = element.Value and Theme.Current.Accent or Theme.Current.Tertiary
                        end
                        
                        -- Slider specific (Track, Fill, ValueLabel)
                        if element.Track then
                            element.Track.BackgroundColor3 = Theme.Current.Tertiary
                        end
                        if element.Fill then
                            element.Fill.BackgroundColor3 = Theme.Current.Accent
                        end
                        if element.ValueLabel then
                            element.ValueLabel.TextColor3 = Theme.Current.Accent
                        end
                        
                        -- Dropdown specific (Button is the dropdown button, SelectedLabel is the text)
                        if element.Button and element.Button.Name == "DropdownButton" then
                            element.Button.BackgroundColor3 = Theme.Current.Tertiary
                        end
                        if element.SelectedLabel then
                            element.SelectedLabel.TextColor3 = Theme.Current.Text
                        end
                        -- Dropdown list container
                        if element.ListContainer then
                            element.ListContainer.BackgroundColor3 = Theme.Current.Tertiary
                        end
                        -- Dropdown search box
                        if element.SearchBox then
                            element.SearchBox.BackgroundColor3 = Theme.Current.Secondary
                            element.SearchBox.TextColor3 = Theme.Current.Text
                            element.SearchBox.PlaceholderColor3 = Theme.Current.SubText
                        end
                        -- Dropdown option labels
                        if element.OptionsList then
                            for _, optBtn in ipairs(element.OptionsList:GetChildren()) do
                                if optBtn:IsA("TextButton") then
                                    optBtn.BackgroundColor3 = Theme.Current.Accent
                                    local label = optBtn:FindFirstChild("Label")
                                    if label then
                                        label.TextColor3 = Theme.Current.Text
                                    end
                                    local checkmark = optBtn:FindFirstChild("Checkmark")
                                    if checkmark then
                                        checkmark.TextColor3 = Theme.Current.Text
                                    end
                                end
                            end
                        end
                        
                        -- Keybind specific
                        if element.Button and element.Button.Name == "KeyButton" then
                            element.Button.BackgroundColor3 = Theme.Current.Tertiary
                            element.Button.TextColor3 = Theme.Current.Text
                        end
                        
                        -- ColorPicker specific
                        if element.ColorPreview then
                            -- ColorPreview uses actual color, not theme
                        end
                        
                        -- Divider/Section specific
                        if element.Title then
                            element.Title.TextColor3 = Theme.Current.Text
                        end
                        if element.Arrow then
                            element.Arrow.TextColor3 = Theme.Current.SubText
                        end
                        if element.LeftLine then
                            element.LeftLine.BackgroundColor3 = Theme.Current.Divider
                        end
                        if element.RightLine then
                            element.RightLine.BackgroundColor3 = Theme.Current.Divider
                        end
                        if element.Text and typeof(element.Text) == "Instance" then
                            element.Text.TextColor3 = Theme.Current.SubText
                        end
                        
                        -- Section has nested elements - refresh them recursively
                        if element.Elements then
                            for _, nestedElement in ipairs(element.Elements) do
                                -- Container
                                if nestedElement.Container then
                                    if nestedElement.Container:FindFirstChild("ButtonElement") then
                                        local btn = nestedElement.Container:FindFirstChild("ButtonElement")
                                        if btn then
                                            btn.BackgroundColor3 = Theme.Current.Tertiary
                                            btn.TextColor3 = Theme.Current.Text
                                        end
                                    else
                                        nestedElement.Container.BackgroundColor3 = Theme.Current.Secondary
                                    end
                                end
                                -- Labels
                                if nestedElement.Label then
                                    nestedElement.Label.TextColor3 = Theme.Current.Text
                                end
                                -- Toggle
                                if nestedElement.SwitchBg then
                                    nestedElement.SwitchBg.BackgroundColor3 = nestedElement.Value and Theme.Current.Accent or Theme.Current.Tertiary
                                end
                                -- Slider
                                if nestedElement.Track then
                                    nestedElement.Track.BackgroundColor3 = Theme.Current.Tertiary
                                end
                                if nestedElement.Fill then
                                    nestedElement.Fill.BackgroundColor3 = Theme.Current.Accent
                                end
                                if nestedElement.ValueLabel then
                                    nestedElement.ValueLabel.TextColor3 = Theme.Current.Accent
                                end
                                -- Dropdown
                                if nestedElement.Button and nestedElement.Button.Name == "DropdownButton" then
                                    nestedElement.Button.BackgroundColor3 = Theme.Current.Tertiary
                                end
                                if nestedElement.SelectedLabel then
                                    nestedElement.SelectedLabel.TextColor3 = Theme.Current.Text
                                end
                                if nestedElement.ListContainer then
                                    nestedElement.ListContainer.BackgroundColor3 = Theme.Current.Tertiary
                                end
                                if nestedElement.SearchBox then
                                    nestedElement.SearchBox.BackgroundColor3 = Theme.Current.Secondary
                                    nestedElement.SearchBox.TextColor3 = Theme.Current.Text
                                end
                                if nestedElement.OptionsList then
                                    for _, optBtn in ipairs(nestedElement.OptionsList:GetChildren()) do
                                        if optBtn:IsA("TextButton") then
                                            optBtn.BackgroundColor3 = Theme.Current.Accent
                                            local label = optBtn:FindFirstChild("Label")
                                            if label then label.TextColor3 = Theme.Current.Text end
                                        end
                                    end
                                end
                                -- Keybind
                                if nestedElement.Button and nestedElement.Button.Name == "KeyButton" then
                                    nestedElement.Button.BackgroundColor3 = Theme.Current.Tertiary
                                    nestedElement.Button.TextColor3 = Theme.Current.Text
                                end
                            end
                        end
                    end
                end
            end
            
            -- Trigger auto save
            if Window.ConfigHandler and Window.ConfigHandler.AutoSave then
                Window.ConfigHandler:TriggerAutoSave()
            end
            
            return true
        end
        return false
    end
    
    function Window:SaveConfig() return Window.ConfigHandler:Save() end
    function Window:LoadConfig() return Window.ConfigHandler:Load() end
    function Window:DeleteConfig() return Window.ConfigHandler:Delete() end
    
    -- Create tab
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        
        local Tab = {}
        Tab.Name = tabOptions.Name or "Tab"
        Tab.Elements = {}
        Tab.LayoutOrder = #Window.Tabs + 1
        
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Size = UDim2.new(1, 0, 0, 35)
        Tab.Button.BackgroundColor3 = Theme.Current.Tertiary
        Tab.Button.BackgroundTransparency = 1
        Tab.Button.BorderSizePixel = 0
        Tab.Button.Text = Tab.Name
        Tab.Button.TextColor3 = Theme.Current.SubText
        Tab.Button.TextSize = 13
        Tab.Button.Font = Enum.Font.GothamMedium
        Tab.Button.AutoButtonColor = false
        Tab.Button.TextXAlignment = Enum.TextXAlignment.Left
        Tab.Button.LayoutOrder = Tab.LayoutOrder
        Tab.Button.Parent = Window.TabScroll
        
        Instance.new("UICorner", Tab.Button).CornerRadius = UDim.new(0, 6)
        
        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingLeft = UDim.new(0, 10)
        tabPadding.Parent = Tab.Button
        
        Tab.Page = Instance.new("ScrollingFrame")
        Tab.Page.Name = "Page_" .. Tab.Name
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.BorderSizePixel = 0
        Tab.Page.ScrollBarThickness = 3
        Tab.Page.ScrollBarImageColor3 = Theme.Current.Accent
        Tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.Page.Visible = false
        Tab.Page.Parent = Window.ContentContainer
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.FillDirection = Enum.FillDirection.Vertical
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = Tab.Page
        
        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingTop = UDim.new(0, 5)
        pagePadding.PaddingBottom = UDim.new(0, 5)
        pagePadding.PaddingLeft = UDim.new(0, 5)
        pagePadding.PaddingRight = UDim.new(0, 5)
        pagePadding.Parent = Tab.Page
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        function Tab:Select()
            for _, tab in ipairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Button.TextColor3 = Theme.Current.SubText
                tab.Page.Visible = false
            end
            Tab.Button.BackgroundTransparency = 0
            Tab.Button.BackgroundColor3 = Theme.Current.Accent
            Tab.Button.TextColor3 = Theme.Current.Text
            Tab.Page.Visible = true
            Window.ActiveTab = Tab
        end
        
        Tab.Button.MouseButton1Click:Connect(function() Tab:Select() end)
        
        Tab.Button.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Animation:Play(Tab.Button, {BackgroundTransparency = 0.5}, 0.15)
            end
        end)
        
        Tab.Button.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Animation:Play(Tab.Button, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then Tab:Select() end
        
        -- Add component methods (store in Tab.Elements for theme refresh)
        function Tab:AddButton(opts)
            local component = Components.Button.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddToggle(opts)
            local component = Components.Toggle.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddTextbox(opts)
            local component = Components.Textbox.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddDropdown(opts)
            local component = Components.Dropdown.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddSlider(opts)
            local component = Components.Slider.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddColorPicker(opts)
            local component = Components.ColorPicker.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddKeybind(opts)
            local component = Components.Keybind.new(Tab, opts, Theme, Animation, Window.ConfigHandler)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddLabel(opts)
            local component = Components.Label.new(Tab, opts, Theme, Animation)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddSection(opts)
            local component = Components.Section.new(Tab, opts, Theme, Animation, Window.ConfigHandler, Components)
            table.insert(Tab.Elements, component)
            return component
        end
        function Tab:AddDivider(opts)
            local component = Components.Divider.new(Tab, opts, Theme, Animation)
            table.insert(Tab.Elements, component)
            return component
        end
        
        return Tab
    end
    
    
    Window.AddTab = Window.CreateTab

    Window.MinimizeBtn.MouseButton1Click:Connect(function() Window:Minimize() end)
    Window.CloseBtn.MouseButton1Click:Connect(function() Window:Destroy() end)
    
    table.insert(NTGUI.Windows, Window)
    
    Animation:ScaleIn(Window.Container, 0.4)
    Animation:Play(Window.Container, {BackgroundTransparency = 0}, 0.3)
    
    return Window
end

-- Notification system
-- Notification system
function NTGUI:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Info" -- Success, Warning, Error, Info
    
    local parent = self:GetParent()
    if not parent then return end
    
    local notifContainer = parent:FindFirstChild("NotificationContainer")
    if not notifContainer then
        notifContainer = Instance.new("Frame")
        notifContainer.Name = "NotificationContainer"
        notifContainer.Size = UDim2.new(0, 320, 1, 0) -- Slightly wider
        notifContainer.Position = UDim2.new(1, -330, 0, 20)
        notifContainer.BackgroundTransparency = 1
        notifContainer.Parent = parent
        
        local notifLayout = Instance.new("UIListLayout")
        notifLayout.FillDirection = Enum.FillDirection.Vertical
        notifLayout.Padding = UDim.new(0, 10)
        notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        notifLayout.Parent = notifContainer
    end
    
    local typeColors = {
        Info = Theme.Current.Accent,
        Success = Color3.fromRGB(80, 220, 100),
        Warning = Color3.fromRGB(255, 190, 60),
        Error = Color3.fromRGB(240, 70, 70)
    }
    
    local typeIcons = {
        Info = "rbxassetid://3944686258",
        Success = "rbxassetid://3944680095",
        Warning = "rbxassetid://3944669909",
        Error = "rbxassetid://3944672958"
    }
    
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 70)
    notif.BackgroundColor3 = Theme.Current.Background
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = notifContainer
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    -- Status Indicator (Left Bar)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, 0)
    indicator.BackgroundColor3 = typeColors[notifType] or Theme.Current.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = notif
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = typeIcons[notifType] or typeIcons.Info
    icon.ImageColor3 = typeColors[notifType] or Theme.Current.Accent
    icon.Parent = notif
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Current.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -50, 0, 30)
    messageLabel.Position = UDim2.new(0, 50, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Theme.Current.SubText
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = notif
    
    -- Animation
    notif.Position = UDim2.new(1, 50, 0, 0)
    Animation:Play(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    
    task.delay(duration, function()
        Animation:Play(notif, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.3)
        -- Fade out contents
        for _, child in ipairs(notif:GetChildren()) do
            if child:IsA("ImageLabel") then
                Animation:Play(child, {ImageTransparency = 1}, 0.3)
            elseif child:IsA("TextLabel") then
                Animation:Play(child, {TextTransparency = 1}, 0.3)
            elseif child:IsA("Frame") then
                Animation:Play(child, {BackgroundTransparency = 1}, 0.3)
            end
        end
        
        task.wait(0.3)
        notif:Destroy()
    end)
end    


function NTGUI:SetTheme(themeName)
    if Theme.Set then Theme:Set(themeName) end
end

function NTGUI:DestroyAll()
    for _, window in ipairs(self.Windows) do
        if window.Destroy then window:Destroy() end
    end
    self.Windows = {}
end

NTGUI.Load = NTGUI.CreateWindow

return NTGUI
