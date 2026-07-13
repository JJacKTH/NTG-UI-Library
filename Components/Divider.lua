--[[
    NTG UI Library - Divider Component
    แสดง Header แบบ ═══════ Title ═══════ กึ่งกลาง
]]

local Divider = {}
Divider.__index = Divider

function Divider.new(tab, options, Theme, Animation)
    options = options or {}
    
    local self = setmetatable({}, Divider)
    self.Name = options.Name or "Divider"
    self.Tab = tab
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Divider_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 25)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = elementCount
    self.Container.Parent = tab.Page

    local lineColor = Theme.Current.Stroke or Theme.Current.Divider
    
    -- Left line
    self.LeftLine = Instance.new("Frame")
    self.LeftLine.Name = "LeftLine"
    self.LeftLine.Size = UDim2.new(0.3, -10, 0, 1)
    self.LeftLine.Position = UDim2.new(0, 5, 0.5, 0)
    self.LeftLine.AnchorPoint = Vector2.new(0, 0.5)
    self.LeftLine.BackgroundColor3 = lineColor
    self.LeftLine.BackgroundTransparency = 0.86
    self.LeftLine.BorderSizePixel = 0
    self.LeftLine.Parent = self.Container
    
    -- Title label
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(0.4, 0, 1, 0)
    self.Label.Position = UDim2.new(0.3, 0, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Name
    self.Label.TextColor3 = Theme.Current.Text
    self.Label.TextSize = 12
    self.Label.Font = Enum.Font.GothamMedium
    self.Label.TextXAlignment = Enum.TextXAlignment.Center
    self.Label.Parent = self.Container
    
    -- Right line
    self.RightLine = Instance.new("Frame")
    self.RightLine.Name = "RightLine"
    self.RightLine.Size = UDim2.new(0.3, -10, 0, 1)
    self.RightLine.Position = UDim2.new(0.7, 5, 0.5, 0)
    self.RightLine.AnchorPoint = Vector2.new(0, 0.5)
    self.RightLine.BackgroundColor3 = lineColor
    self.RightLine.BackgroundTransparency = 0.86
    self.RightLine.BorderSizePixel = 0
    self.RightLine.Parent = self.Container
    
    -- Methods
    function self:SetText(text)
        self.Label.Text = text
    end
    
    function self:Destroy()
        self.Container:Destroy()
    end
    
    return self
end

return Divider
