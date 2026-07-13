--[[
    ████████╗██╗ ██████╗ ██████╗  █████╗ ██╗   ██╗██╗████████╗██╗   ██╗
    ██╔═══██║██║██╔════╝ ██╔══██╗██╔══██╗██║   ██║██║╚══██╔══╝╚██╗ ██╔╝
    ████████║██║██║  ███╗██████╔╝███████║██║   ██║██║   ██║    ╚████╔╝ 
    ██╔═══██║██║██║   ██║██╔══██╗██╔══██║╚██╗ ██╔╝██║   ██║     ╚██╔╝  
    ██║   ██║██║╚██████╔╝██║  ██║██║  ██║ ╚████╔╝ ██║   ██║      ██║   
    ╚═╝   ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝   ╚═╝      ╚═╝   
    
    NTG UI Library v1.0
    A modern, feature-rich UI library for Roblox
]]

local NTGUI = {}
NTGUI.__index = NTGUI
NTGUI.Version = "1.0.0"

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local BASE_URL = "https://raw.githubusercontent.com/JJacKTH/NTG-UI-Library/main/"
local function safeLoad(url, name)
    local content
    local ok, err = pcall(function()
        content = game:HttpGet(url)
    end)
    if not ok or not content or content == "" then
        error("[NTGUI] Failed to download " .. name .. " from: " .. url .. " | Error: " .. tostring(err or "empty response"))
    end
    local func, compileErr = loadstring(content)
    if not func then
        error("[NTGUI] Failed to compile " .. name .. " | Error: " .. tostring(compileErr))
    end
    local runOk, result = pcall(func)
    if not runOk then
        error("[NTGUI] Failed to execute " .. name .. " | Error: " .. tostring(result))
    end
    return result
end

local function loadModule(path)
    local success, module = pcall(function()
        return require(path)
    end)
    return success and module or nil
end

local Theme = safeLoad(BASE_URL .. "Core/Theme.lua", "Theme")
local Animation = safeLoad(BASE_URL .. "Core/Animation.lua", "Animation")
local Utility = safeLoad(BASE_URL .. "Core/Utility.lua", "Utility")
local ConfigManager = safeLoad(BASE_URL .. "Config/ConfigManager.lua", "ConfigManager")
local Components = {
    Button = safeLoad(BASE_URL .. "Components/Button.lua", "Button"),
    Toggle = safeLoad(BASE_URL .. "Components/Toggle.lua", "Toggle"),
    Textbox = safeLoad(BASE_URL .. "Components/Textbox.lua", "Textbox"),
    Dropdown = safeLoad(BASE_URL .. "Components/Dropdown.lua", "Dropdown"),
    Slider = safeLoad(BASE_URL .. "Components/Slider.lua", "Slider"),
    ColorPicker = safeLoad(BASE_URL .. "Components/ColorPicker.lua", "ColorPicker"),
    Keybind = safeLoad(BASE_URL .. "Components/Keybind.lua", "Keybind"),
    Label = safeLoad(BASE_URL .. "Components/Label.lua", "Label"),
    Section = safeLoad(BASE_URL .. "Components/Section.lua", "Section"),
    Divider = safeLoad(BASE_URL .. "Components/Divider.lua", "Divider")
}

-- Local require support is intentionally omitted here because some executors
-- expose `script` as a table stub that does not implement Instance methods.

-- If still nil, create inline versions
if not Theme then
    Theme = {
        Current = {
            Background = Color3.fromRGB(14, 16, 22),
            Surface = Color3.fromRGB(22, 25, 34),
            SurfaceAlt = Color3.fromRGB(28, 32, 43),
            Accent = Color3.fromRGB(110, 160, 255),
            AccentHover = Color3.fromRGB(135, 185, 255),
            Text = Color3.fromRGB(245, 247, 255),
            SubText = Color3.fromRGB(168, 175, 195),
            Divider = Color3.fromRGB(255, 255, 255),
            Stroke = Color3.fromRGB(255, 255, 255),
            Transparency = {
                Background = 0.18,
                Surface = 0.28,
                SurfaceAlt = 0.38,
                Stroke = 0.82,
                SoftStroke = 0.9
            }
        },
        Presets = {
            GlassDark = {},
            GlassLight = {}
        }
    }
end

-- Store active windows
NTGUI.Windows = {}

-- Get safe parent for UI
function NTGUI:GetParent()
    local success, gui = pcall(function()
        return CoreGui:FindFirstChild("NTGUI") or 
               Instance.new("ScreenGui", CoreGui)
    end)
    
    if success then
        gui.Name = "NTGUI"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.ResetOnSpawn = false
        return gui
    else
        -- Fallback to PlayerGui
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

-- Create a new window
function NTGUI:CreateWindow(options)
    options = options or {}
    
    local Window = {}
    Window.Title = options.Title or "NTG UI"
    Window.Size = options.Size or UDim2.new(0, 500, 0, 400)
    Window.Theme = options.Theme or "GlassDark"
    Window.GameName = options.GameName or "Default"
    Window.ConfigName = options.ConfigName or "Default"
    Window.AutoSave = options.AutoSave or false
    Window.AutoLoad = options.AutoLoad or false
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Minimized = false
    Window.Visible = true
    Window.OnClose = options.OnClose -- Custom callback
    Window._connections = {}
    
    -- Set theme
    if Theme.Presets and Theme.Presets[Window.Theme] then
        Theme.Current = Theme.Presets[Window.Theme]
    end
    
    -- Create config handler
    Window.ConfigHandler = ConfigManager:CreateHandler(Window.GameName, Window.ConfigName, Window.AutoSave, Window.AutoLoad)
    
    -- Get parent
    local parent = self:GetParent()
    if not parent then
        warn("[NTGUI] Failed to get parent for UI")
        return nil
    end
    
    -- Main container
    Window.Container = Instance.new("Frame")
    Window.Container.Name = "Window_" .. Window.Title
    Window.Container.Size = Window.Size
    Window.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Window.Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.Container.BackgroundColor3 = Theme.Current.Background
    Window.Container.BackgroundTransparency = 0.18
    Window.Container.BorderSizePixel = 0
    Window.Container.ClipsDescendants = true
    Window.Container.Active = true
    Window.Container.Parent = parent
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = Window.Container
    
    -- Shadow (using UIStroke for subtle effect)
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 1
    shadow.Transparency = 0.9
    shadow.Parent = Window.Container
    
    -- Title bar
    Window.TitleBar = Instance.new("Frame")
    Window.TitleBar.Name = "TitleBar"
    Window.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    Window.TitleBar.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    Window.TitleBar.BackgroundTransparency = 0.28
    Window.TitleBar.BorderSizePixel = 0
    Window.TitleBar.Active = true
    Window.TitleBar.Parent = Window.Container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = Window.TitleBar
    
    -- Fix corner overlap
    local titleFix = Instance.new("Frame")
    titleFix.Name = "CornerFix"
    titleFix.Size = UDim2.new(1, 0, 0, 15)
    titleFix.Position = UDim2.new(0, 0, 1, -15)
    titleFix.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    titleFix.BorderSizePixel = 0
    titleFix.Parent = Window.TitleBar
    
    -- Title text
    Window.TitleLabel = Instance.new("TextLabel")
    Window.TitleLabel.Name = "Title"
    Window.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    Window.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    Window.TitleLabel.BackgroundTransparency = 1
    Window.TitleLabel.Text = Window.Title
    Window.TitleLabel.TextColor3 = Theme.Current.Text
    Window.TitleLabel.TextSize = 16
    Window.TitleLabel.Font = Enum.Font.GothamBold
    Window.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    Window.TitleLabel.Parent = Window.TitleBar
    
    -- Control buttons container
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "Controls"
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
    
    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
    minimizeBtn.BackgroundTransparency = 0.38
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Theme.Current.Text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = controlsContainer
    
    local minimizeBtnCorner = Instance.new("UICorner")
    minimizeBtnCorner.CornerRadius = UDim.new(0, 6)
    minimizeBtnCorner.Parent = minimizeBtn
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    closeBtn.BackgroundTransparency = 0.38
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.Current.Text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = controlsContainer
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    -- Hover effects
    if Animation then
        Animation:CreateHoverEffect(minimizeBtn, Theme.Current.AccentHover or Theme.Current.Accent, Theme.Current.SurfaceAlt or Theme.Current.Surface)
        Animation:CreateHoverEffect(closeBtn, Color3.fromRGB(220, 100, 100), Color3.fromRGB(200, 80, 80))
    end
    
    -- Tab sidebar
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Name = "TabContainer"
    Window.TabContainer.Size = UDim2.new(0, 140, 1, -50)
    Window.TabContainer.Position = UDim2.new(0, 5, 0, 45)
    Window.TabContainer.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    Window.TabContainer.BackgroundTransparency = 0.38
    Window.TabContainer.BorderSizePixel = 0
    Window.TabContainer.Active = true
    Window.TabContainer.Parent = Window.Container
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = Window.TabContainer
    
    -- Tab buttons scroll
    Window.TabScroll = Instance.new("ScrollingFrame")
    Window.TabScroll.Name = "TabScroll"
    Window.TabScroll.Size = UDim2.new(1, -10, 1, -10)
    Window.TabScroll.Position = UDim2.new(0, 5, 0, 5)
    Window.TabScroll.BackgroundTransparency = 1
    Window.TabScroll.BorderSizePixel = 0
    Window.TabScroll.ScrollBarThickness = 2
    Window.TabScroll.ScrollBarImageColor3 = Theme.Current.Accent
    Window.TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Window.TabScroll.Active = true
    Window.TabScroll.Parent = Window.TabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = Window.TabScroll
    
    -- Auto resize tab scroll
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Window.TabScroll.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content area
    Window.ContentContainer = Instance.new("Frame")
    Window.ContentContainer.Name = "ContentContainer"
    Window.ContentContainer.Size = UDim2.new(1, -160, 1, -55)
    Window.ContentContainer.Position = UDim2.new(0, 150, 0, 45)
    Window.ContentContainer.BackgroundTransparency = 1
    Window.ContentContainer.BorderSizePixel = 0
    Window.ContentContainer.ClipsDescendants = true
    Window.ContentContainer.Active = true
    Window.ContentContainer.Parent = Window.Container
    
    -- Make window draggable
    if Utility then
        Window._dragConnections = Utility:MakeDraggable(Window.Container, Window.TitleBar)
    end
    
    -- Floating Icon
    Window.FloatingIcon = nil
    if options.FloatingIcon and options.FloatingIcon.Enabled ~= false then
        local iconImage = options.FloatingIcon.Image or "rbxassetid://94618813054930"
        local iconPosition = options.FloatingIcon.Position or UDim2.new(0, 20, 0.5, 0)
        
        Window.FloatingIcon = Instance.new("ImageButton")
        Window.FloatingIcon.Name = "FloatingIcon"
        Window.FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
        Window.FloatingIcon.Position = iconPosition
        Window.FloatingIcon.AnchorPoint = Vector2.new(0, 0.5)
        Window.FloatingIcon.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
        Window.FloatingIcon.BackgroundTransparency = 0.28
        Window.FloatingIcon.BorderSizePixel = 0
        Window.FloatingIcon.Image = iconImage
        Window.FloatingIcon.ImageColor3 = options.FloatingIcon.ImageColor3 or Theme.Current.Accent
        Window.FloatingIcon.Visible = true
        Window.FloatingIcon.Parent = parent
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 10)
        iconCorner.Parent = Window.FloatingIcon
        
        local iconStroke = Instance.new("UIStroke")
        iconStroke.Color = Theme.Current.Accent
        iconStroke.Thickness = 2
        iconStroke.Parent = Window.FloatingIcon
        
        -- Make icon draggable
        if Utility then
            Utility:MakeDraggable(Window.FloatingIcon)
        end
        
        -- Icon click to toggle window
        Window.FloatingIcon.MouseButton1Click:Connect(function()
            Window:Toggle()
        end)
        
        function Window:SetFloatingIconPosition(pos)
            if Window.FloatingIcon then
                Window.FloatingIcon.Position = pos
            end
        end

        function Window:SetFloatingIconImage(img)
            if Window.FloatingIcon then
                Window.FloatingIcon.Image = img
            end
        end
    end
    
    -- Global Toggle Key support
    Window.ToggleKey = options.ToggleKey
    if Window.ToggleKey == nil then Window.ToggleKey = Enum.KeyCode.K end -- Default to K if not specified
    
    local UserInputService = game:GetService("UserInputService")
    local toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if Window.ToggleKey and input.KeyCode == Window.ToggleKey then
            -- Avoid toggling UI when typing in text fields
            if not UserInputService:GetFocusedTextBox() then
                Window:Toggle(true) -- Pass true to indicate keybind toggle (center it)
            end
        end
    end)
    table.insert(Window._connections, toggleConnection)

    function Window:Minimize()
        Window.Minimized = true
        Window.Container.Visible = false
        if Window.FloatingIcon then
            Window.FloatingIcon.Visible = true
        end
    end
    
    function Window:Maximize(forceCenter)
        Window.Minimized = false
        Window.Container.Visible = true
        
        -- Center the UI to prevent it from being lost off-screen
        if forceCenter or options.CenterOnToggle ~= false then
            Window.Container.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
        
        if Window.FloatingIcon then
            Window.FloatingIcon.Visible = true -- Keep visible
        end
    end
    
    function Window:Toggle(forceCenter)
        if Window.Minimized then
            Window:Maximize(forceCenter)
        else
            Window:Minimize()
        end
    end
    
    function Window:Hide()
        Window.Visible = false
        Window.Container.Visible = false
        if Window.FloatingIcon then
            Window.FloatingIcon.Visible = false
        end
    end
    
    function Window:Show()
        Window.Visible = true
        Window.Container.Visible = true
        if Window.FloatingIcon then
            Window.FloatingIcon.Visible = true
        end
    end
    
    function Window:Destroy()
        if Window.OnClose then
            local success, err = pcall(Window.OnClose)
            if not success then warn("[NTGUI] Error in OnClose callback:", err) end
        end
        for _, connection in ipairs(Window._connections) do
            if connection and connection.Disconnect then
                connection:Disconnect()
            end
        end
        if Window._dragConnections then
            for _, connection in ipairs(Window._dragConnections) do
                if connection and connection.Disconnect then
                    connection:Disconnect()
                end
            end
        end
        Window.Container:Destroy()
        if Window.FloatingIcon then
            Window.FloatingIcon:Destroy()
        end
        for index, window in ipairs(NTGUI.Windows) do
            if window == Window then
                table.remove(NTGUI.Windows, index)
                break
            end
        end
    end
    
    function Window:SetTheme(themeName)
        if Theme.Presets and Theme.Presets[themeName] then
            Theme.Current = Theme.Presets[themeName]
            -- Refresh UI colors would go here
        end
    end
    
    function Window:SaveConfig()
        return Window.ConfigHandler:Save()
    end
    
    function Window:LoadConfig()
        return Window.ConfigHandler:Load()
    end
    
    function Window:DeleteConfig()
        return Window.ConfigHandler:Delete()
    end
    
    -- Create tab method
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        
        local Tab = {}
        Tab.Name = tabOptions.Name or "Tab"
        Tab.Icon = tabOptions.Icon
        Tab.Elements = {}
        Tab.LayoutOrder = #Window.Tabs + 1
        
        -- Tab button
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Name = "Tab_" .. Tab.Name
        Tab.Button.Size = UDim2.new(1, 0, 0, 35)
        Tab.Button.BackgroundColor3 = Theme.Current.SurfaceAlt or Theme.Current.Surface
        Tab.Button.BackgroundTransparency = 1
        Tab.Button.BorderSizePixel = 0
        Tab.Button.Text = Tab.Name
        Tab.Button.TextColor3 = Theme.Current.SubText
        Tab.Button.TextSize = 13
        Tab.Button.Font = Enum.Font.GothamMedium
        Tab.Button.AutoButtonColor = false
        Tab.Button.LayoutOrder = Tab.LayoutOrder
        Tab.Button.Parent = Window.TabScroll
        
        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = Tab.Button
        
        -- Tab content page
        Tab.Page = Instance.new("ScrollingFrame")
        Tab.Page.Name = "Page_" .. Tab.Name
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.Position = UDim2.new(0, 0, 0, 0)
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.BorderSizePixel = 0
        Tab.Page.ScrollBarThickness = 3
        Tab.Page.ScrollBarImageColor3 = Theme.Current.Accent
        Tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.Page.Visible = false
        Tab.Page.Active = true
        Tab.Page.Parent = Window.ContentContainer
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.FillDirection = Enum.FillDirection.Vertical
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.Parent = Tab.Page
        
        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingTop = UDim.new(0, 5)
        pagePadding.PaddingBottom = UDim.new(0, 5)
        pagePadding.PaddingLeft = UDim.new(0, 5)
        pagePadding.PaddingRight = UDim.new(0, 5)
        pagePadding.Parent = Tab.Page
        
        -- Auto resize canvas
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Select tab function
        function Tab:Select()
            -- Deselect all tabs
            for _, tab in ipairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Button.TextColor3 = Theme.Current.SubText
                tab.Page.Visible = false
            end
            
            -- Select this tab
            Tab.Button.BackgroundTransparency = 0
            Tab.Button.BackgroundColor3 = Theme.Current.Accent
            Tab.Button.TextColor3 = Theme.Current.Text
            Tab.Page.Visible = true
            Window.ActiveTab = Tab
        end
        
        -- Tab button click
        Tab.Button.MouseButton1Click:Connect(function()
            Tab:Select()
        end)
        
        -- Hover effect
        Tab.Button.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                if Animation then
                    Animation:Play(Tab.Button, {BackgroundTransparency = 0.5}, 0.15)
                else
                    Tab.Button.BackgroundTransparency = 0.5
                end
            end
        end)
        
        Tab.Button.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                if Animation then
                    Animation:Play(Tab.Button, {BackgroundTransparency = 1}, 0.15)
                else
                    Tab.Button.BackgroundTransparency = 1
                end
            end
        end)
        
        -- Add tab to window
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab by default
        if #Window.Tabs == 1 then
            Tab:Select()
        end
        
        -- Import component methods
        -- These will be populated by component modules
        Tab.AddButton = function(self, opts) return Components.Button.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddToggle = function(self, opts) return Components.Toggle.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddTextbox = function(self, opts) return Components.Textbox.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddDropdown = function(self, opts) return Components.Dropdown.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddSlider = function(self, opts) return Components.Slider.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddColorPicker = function(self, opts) return Components.ColorPicker.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddKeybind = function(self, opts) return Components.Keybind.new(Tab, opts, Theme, Animation, Window.ConfigHandler) end
        Tab.AddLabel = function(self, opts) return Components.Label.new(Tab, opts, Theme, Animation) end
        Tab.AddSection = function(self, opts) return Components.Section.new(Tab, opts, Theme, Animation, Window.ConfigHandler, Components) end
        Tab.AddDivider = function(self, opts) return Components.Divider.new(Tab, opts, Theme, Animation) end
        
        return Tab
    end
    
    -- Button events
    minimizeBtn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    -- Add to windows list
    table.insert(NTGUI.Windows, Window)
    
    -- Entry animation
    if Animation then
        Window.Container.BackgroundTransparency = 1
        Animation:ScaleIn(Window.Container, 0.4)
        Animation:Play(Window.Container, {BackgroundTransparency = 0}, 0.3)
    end
    
    return Window
end

-- Notification system
function NTGUI:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Info" -- Info, Success, Warning, Error
    
    local parent = self:GetParent()
    if not parent then return end
    
    -- Create notification container if not exists
    local notifContainer = parent:FindFirstChild("NotificationContainer")
    if not notifContainer then
        notifContainer = Instance.new("Frame")
        notifContainer.Name = "NotificationContainer"
        notifContainer.Size = UDim2.new(0, 300, 1, 0)
        notifContainer.Position = UDim2.new(1, -310, 0, 10)
        notifContainer.BackgroundTransparency = 1
        notifContainer.Parent = parent
        
        local notifLayout = Instance.new("UIListLayout")
        notifLayout.FillDirection = Enum.FillDirection.Vertical
        notifLayout.Padding = UDim.new(0, 10)
        notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        notifLayout.Parent = notifContainer
    end
    
    -- Notification frame
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 70)
    notif.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    notif.BackgroundTransparency = 0.22
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = notifContainer
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif
    
    -- Type indicator
    local typeColors = {
        Info = Theme.Current.Accent,
        Success = Theme.Current.Success or Color3.fromRGB(100, 200, 100),
        Warning = Theme.Current.Warning or Color3.fromRGB(255, 200, 100),
        Error = Theme.Current.Error or Color3.fromRGB(255, 100, 100)
    }
    
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 4, 1, 0)
    indicator.BackgroundColor3 = typeColors[notifType] or Theme.Current.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = notif
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Current.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 30)
    messageLabel.Position = UDim2.new(0, 15, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Theme.Current.SubText
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = notif
    
    -- Entry animation
    if Animation then
        notif.Position = UDim2.new(1, 50, 0, 0)
        Animation:Play(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    end
    
    -- Auto dismiss
    task.delay(duration, function()
        if Animation then
            Animation:Play(notif, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.3)
        end
        notif:Destroy()
    end)
    
    return notif
end

-- Set global theme
function NTGUI:SetTheme(themeName)
    if Theme.Set then
        Theme:Set(themeName)
    end
    
    -- Update all windows (would need refresh logic)
end

-- Destroy all windows
function NTGUI:DestroyAll()
    for i = #self.Windows, 1, -1 do
        local window = self.Windows[i]
        if window.Destroy then
            window:Destroy()
        end
    end
    self.Windows = {}
end

return NTGUI
