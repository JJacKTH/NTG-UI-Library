--[[
    NTG UI Library - Label Component
]]

local Label = {}
Label.__index = Label

function Label.new(tab, options, Theme, Animation)
    options = options or {}
    
    local self = setmetatable({}, Label)
    self.Name = options.Name or "Label"
    self.Text = options.Text or self.Name
    self.Tab = tab
    
    -- Get current element count for ordering
    local elementCount = #tab.Page:GetChildren()
    
    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Label_" .. self.Name
    self.Container.Size = UDim2.new(1, -10, 0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = elementCount
    self.Container.AutomaticSize = Enum.AutomaticSize.Y
    self.Container.Parent = tab.Page
    
    -- Label text
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Text"
    self.Label.Size = UDim2.new(1, -10, 0, 0)
    self.Label.Position = UDim2.new(0, 5, 0, 0)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = self.Text
    self.Label.TextColor3 = Theme.Current.SubText
    self.Label.TextSize = 13
    self.Label.Font = Enum.Font.Gotham
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.TextYAlignment = Enum.TextYAlignment.Top
    self.Label.TextWrapped = true
    self.Label.RichText = true
    self.Label.AutomaticSize = Enum.AutomaticSize.Y
    self.Label.Parent = self.Container
    
    -- Methods
    function self:Set(text)
        self.Text = text
        self.Label.Text = text
    end
    
    function self:Get()
        return self.Text
    end
    
    function self:Destroy()
        self.Container:Destroy()
    end
    
    return self
end

return Label
