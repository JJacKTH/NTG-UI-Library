--[[
    NTG UI Library - Notification Component
    Toast-style notifications
]]

local Notification = {}
Notification.__index = Notification

function Notification.new(parent, options, Theme, Animation)
    options = options or {}
    
    local self = setmetatable({}, Notification)
    self.Title = options.Title or "Notification"
    self.Message = options.Message or ""
    self.Duration = options.Duration or 3
    self.Type = options.Type or "Info"
    self.Parent = parent
    
    -- Type colors
    local typeColors = {
        Info = Theme.Current.Accent,
        Success = Theme.Current.Success or Color3.fromRGB(100, 200, 100),
        Warning = Theme.Current.Warning or Color3.fromRGB(255, 200, 100),
        Error = Theme.Current.Error or Color3.fromRGB(255, 100, 100)
    }
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Notification"
    self.Container.Size = UDim2.new(1, 0, 0, 70)
    self.Container.BackgroundColor3 = Theme.Current.Surface or Theme.Current.Background
    self.Container.BackgroundTransparency = 0.22
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Container
    
    -- Type indicator
    self.Indicator = Instance.new("Frame")
    self.Indicator.Name = "Indicator"
    self.Indicator.Size = UDim2.new(0, 4, 1, 0)
    self.Indicator.BackgroundColor3 = typeColors[self.Type] or Theme.Current.Accent
    self.Indicator.BorderSizePixel = 0
    self.Indicator.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 8)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme.Current.Text
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Container
    
    -- Message
    self.MessageLabel = Instance.new("TextLabel")
    self.MessageLabel.Name = "Message"
    self.MessageLabel.Size = UDim2.new(1, -20, 0, 30)
    self.MessageLabel.Position = UDim2.new(0, 15, 0, 32)
    self.MessageLabel.BackgroundTransparency = 1
    self.MessageLabel.Text = self.Message
    self.MessageLabel.TextColor3 = Theme.Current.SubText
    self.MessageLabel.TextSize = 12
    self.MessageLabel.Font = Enum.Font.Gotham
    self.MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.MessageLabel.TextWrapped = true
    self.MessageLabel.Parent = self.Container
    
    -- Entry animation
    if Animation then
        self.Container.Position = UDim2.new(1, 50, 0, 0)
        Animation:Play(self.Container, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    end
    
    -- Auto dismiss
    task.delay(self.Duration, function()
        self:Dismiss()
    end)
    
    -- Methods
    function self:Dismiss()
        if Animation then
            Animation:Play(self.Container, {
                Position = UDim2.new(1, 50, 0, 0),
                BackgroundTransparency = 1
            }, 0.3)
            task.wait(0.3)
        end
        
        if self.Container and self.Container.Parent then
            self.Container:Destroy()
        end
    end
    
    return self
end

return Notification
