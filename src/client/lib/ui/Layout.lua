local Layout = {}
Layout.__index = Layout

function Layout:CreateVertical(parent, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing or 5)
    layout.Parent = parent
    return layout
end

function Layout:CreateHorizontal(parent, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing or 5)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = parent
    return layout
end

function Layout:CreateGrid(parent, cellPadding)
    local layout = Instance.new("UIGridLayout")
    layout.CellPadding = UDim2.new(0, cellPadding or 5, 0, cellPadding or 5)
    layout.CellSize = UDim2.new(0, 100, 0, 100)
    layout.Parent = parent
    return layout
end

return Layout
