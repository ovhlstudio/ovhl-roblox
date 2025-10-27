-- HUD v5 - Simple HUD
local BaseComponent = require(script.Parent.Parent.lib.BaseComponent)

local HUD = setmetatable({}, BaseComponent)
HUD.__index = HUD

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
HUD.__manifest = {
	name = "HUD",
	version = "5.0.0",
	type = "module",
	domain = "ui",
	dependencies = {},
	autoload = true,
	priority = 50,
	description = "Heads-up display component",
}

function HUD:Init()
	BaseComponent.Init(self)
	self.state = {
		coins = 1000,
		gems = 100,
		level = 1,
		health = 100,
	}
end

function HUD:Render()
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1

	-- Top bar with coins and gems
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.Position = UDim2.new(0, 0, 0, 10)
	topBar.BackgroundTransparency = 1
	topBar.Parent = container

	local coinsLabel = Instance.new("TextLabel")
	coinsLabel.Text = "💰 " .. self.state.coins
	coinsLabel.Size = UDim2.new(0, 100, 0, 40)
	coinsLabel.Position = UDim2.new(0, 20, 0, 0)
	coinsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	coinsLabel.TextColor3 = Color3.new(1, 1, 1)
	coinsLabel.TextSize = 16
	coinsLabel.Parent = topBar

	local gemsLabel = Instance.new("TextLabel")
	gemsLabel.Text = "💎 " .. self.state.gems
	gemsLabel.Size = UDim2.new(0, 100, 0, 40)
	gemsLabel.Position = UDim2.new(0, 140, 0, 0)
	gemsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	gemsLabel.TextColor3 = Color3.new(1, 1, 1)
	gemsLabel.TextSize = 16
	gemsLabel.Parent = topBar

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Text = "⭐ Lv. " .. self.state.level
	levelLabel.Size = UDim2.new(0, 100, 0, 40)
	levelLabel.Position = UDim2.new(0, 260, 0, 0)
	levelLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	levelLabel.TextColor3 = Color3.new(1, 1, 1)
	levelLabel.TextSize = 16
	levelLabel.Parent = topBar

	-- Health bar
	local healthContainer = Instance.new("Frame")
	healthContainer.Size = UDim2.new(0, 200, 0, 30)
	healthContainer.Position = UDim2.new(0, 20, 1, -50)
	healthContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	healthContainer.Parent = container

	local healthBar = Instance.new("Frame")
	healthBar.Size = UDim2.new(self.state.health / 100, 0, 1, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthContainer

	local healthLabel = Instance.new("TextLabel")
	healthLabel.Text = "❤️ " .. self.state.health .. "/100"
	healthLabel.Size = UDim2.new(1, 0, 1, 0)
	healthLabel.BackgroundTransparency = 1
	healthLabel.TextColor3 = Color3.new(1, 1, 1)
	healthLabel.TextSize = 14
	healthLabel.Parent = healthContainer

	return container
end

return HUD
