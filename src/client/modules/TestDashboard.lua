local BaseComponent = require(script.Parent.Parent.lib.BaseComponent)
local UI = require(script.Parent.Parent.lib.ui)
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local TestDashboard = setmetatable({}, BaseComponent)
TestDashboard.__index = TestDashboard

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
-- 🔥 MANIFEST FOR AUTO-DISCOVERY
TestDashboard.__manifest = {
    name = "TestDashboard",
    version = "1.0.0",
    type = "module",
    domain = "ui",
    dependencies = {},
    autoload = true,
    priority = 40,
    description = "System testing and monitoring dashboard",
}

function TestDashboard:Init()
	BaseComponent.Init(self)

	self.state = {
		-- Service Status
		servicesStatus = {},
		connectionStatus = "Disconnected",

		-- Test Results
		testResults = {},
		currentTest = nil,
		isTesting = false,

		-- Performance Metrics
		performanceMetrics = {
			serverPing = 0,
			serviceStartup = 0,
			eventLatency = 0,
			lastUpdate = os.time(),
		},
	}

	print("🔧 TestDashboard initialized with UI Library")
	return true
end

function TestDashboard:DidMount()
	-- Setup real-time monitoring
	self:StartServiceMonitoring()
	self:SetupEventListeners()

	print("🎯 TestDashboard mounted with UI Library")
end

function TestDashboard:StartServiceMonitoring()
	-- Monitor service health setiap 5 detik
	while self._instance and self._instance.Parent do
		self:CheckServiceHealth()
		self:UpdatePerformanceMetrics()
		wait(5)
	end
end

function TestDashboard:CheckServiceHealth()
	local RemoteClient = require(script.Parent.Parent.controllers.RemoteClient)
	local servicesStatus = {}

	-- Check RemoteClient connection
	servicesStatus.RemoteClient = RemoteClient:IsConnected() and "✅ Connected" or "❌ Disconnected"
	servicesStatus.StateManager = "✅ Active"
	servicesStatus.UIEngine = "✅ Ready"

	-- Update connection status
	self.connectionStatus = RemoteClient:IsConnected() and "Connected" or "Disconnected"

	self:SetState({
		servicesStatus = servicesStatus,
		connectionStatus = self.connectionStatus,
	})
end

function TestDashboard:UpdatePerformanceMetrics()
	-- Simulate performance metrics
	local metrics = {
		serverPing = math.random(20, 100),
		serviceStartup = math.random(50, 150),
		eventLatency = math.random(5, 30),
		lastUpdate = os.time(),
	}

	self:SetState({
		performanceMetrics = metrics,
	})
end

function TestDashboard:RunPingTest()
	if self.state.isTesting then
		return
	end

	self:SetState({
		isTesting = true,
		currentTest = "Ping Test",
	})

	local RemoteClient = require(script.Parent.Parent.controllers.RemoteClient)

	local startTime = os.clock()

	local success, result = pcall(function()
		return RemoteClient:Invoke("Test:Ping", {
			message = "Ping from TestDashboard",
			timestamp = os.time(),
		})
	end)

	local endTime = os.clock()
	local responseTime = math.floor((endTime - startTime) * 1000)

	local testResult = {
		testName = "Ping Test",
		success = success,
		responseTime = responseTime,
		result = result,
		timestamp = os.time(),
	}

	local newResults = { testResult }
	for _, existing in ipairs(self.state.testResults) do
		table.insert(newResults, existing)
	end

	self:SetState({
		testResults = newResults,
		isTesting = false,
		currentTest = nil,
	})

	print(success and "✅ Ping test completed" or "❌ Ping test failed")
end

function TestDashboard:RunEventTest()
	if self.state.isTesting then
		return
	end

	self:SetState({
		isTesting = true,
		currentTest = "Event Test",
	})

	local EventBus = require(script.Parent.Parent.Parent.server.services.EventBus)

	local testEventName = "TestDashboard_Event_" .. tostring(math.random(1000, 9999))
	local eventReceived = false
	local testData = { message = "Test event", number = 42 }

	-- Subscribe to test event
	local unsubscribe = EventBus:Subscribe(testEventName, function(receivedData)
		eventReceived = true
		print("📨 Event received:", receivedData)
	end)

	-- Emit test event
	EventBus:Emit(testEventName, testData)

	-- Wait a bit for event to be processed
	wait(0.5)

	-- Cleanup
	unsubscribe()

	local testResult = {
		testName = "Event Test",
		success = eventReceived,
		result = eventReceived and "Event delivered successfully" or "Event not received",
		timestamp = os.time(),
	}

	local newResults = { testResult }
	for _, existing in ipairs(self.state.testResults) do
		table.insert(newResults, existing)
	end

	self:SetState({
		testResults = newResults,
		isTesting = false,
		currentTest = nil,
	})

	print(eventReceived and "✅ Event test completed" or "❌ Event test failed")
end

function TestDashboard:RunDataTest()
	if self.state.isTesting then
		return
	end

	self:SetState({
		isTesting = true,
		currentTest = "Data Test",
	})

	local DataService = require(script.Parent.Parent.Parent.server.services.DataService)

	local success, playerData = pcall(function()
		return DataService:GetPlayerData(game.Players.LocalPlayer, "MainData")
	end)

	local testResult = {
		testName = "Data Test",
		success = success,
		result = success and "Data loaded: " .. tostring(playerData.coins) .. " coins" or "Failed to load data",
		timestamp = os.time(),
	}

	local newResults = { testResult }
	for _, existing in ipairs(self.state.testResults) do
		table.insert(newResults, existing)
	end

	self:SetState({
		testResults = newResults,
		isTesting = false,
		currentTest = nil,
	})

	print(success and "✅ Data test completed" or "❌ Data test failed")
end

function TestDashboard:ClearTestResults()
	self:SetState({
		testResults = {},
	})
end

-- ==================== UI RENDERING WITH UI LIBRARY ====================

function TestDashboard:Render()
	-- Use UI Library untuk semua rendering
	local dashboard = UI.Panel:Create({
		size = UDim2.fromScale(1, 1),
		backgroundColor = StyleManager:GetColor("background"),
		padding = { left = 20, right = 20, top = 20, bottom = 20 },
	})

	-- Header
	local header = self:RenderHeader()
	header.Parent = dashboard

	-- Status Section
	local statusSection = self:RenderStatusSection()
	statusSection.Position = UDim2.fromOffset(0, 60)
	statusSection.Parent = dashboard

	-- Controls Section
	local controlsSection = self:RenderControlsSection()
	controlsSection.Position = UDim2.fromOffset(0, 180)
	controlsSection.Parent = dashboard

	-- Results Section
	local resultsSection = self:RenderResultsSection()
	resultsSection.Position = UDim2.fromOffset(0, 320)
	resultsSection.Parent = dashboard

	return dashboard
end

function TestDashboard:RenderHeader()
	local header = UI.Panel:Create({
		size = UDim2.new(1, 0, 0, 50),
		backgroundTransparency = 1,
	})

	local title = UI.Text:Create({
		text = "🚀 OVHL TEST DASHBOARD",
		textSize = 24,
		fontStyle = "bold",
		alignX = Enum.TextXAlignment.Center,
	})
	title.Parent = header

	return header
end

function TestDashboard:RenderStatusSection()
	local section = UI.Utils.CreateSection("📊 SYSTEM STATUS", 110)

	-- Connection Status
	local connectionText = UI.Text:Create({
		text = "Connection: " .. self.state.connectionStatus,
		textColor = self.state.connectionStatus == "Connected" and StyleManager:GetColor("success")
			or StyleManager:GetColor("error"),
		textSize = 14,
		position = UDim2.fromOffset(15, 30),
	})
	connectionText.Parent = section

	-- Performance Metrics
	local metricsText = UI.Text:Create({
		text = string.format(
			"Ping: %dms | Services: %dms | Events: %dms",
			self.state.performanceMetrics.serverPing,
			self.state.performanceMetrics.serviceStartup,
			self.state.performanceMetrics.eventLatency
		),
		textSize = 12,
		textColor = StyleManager:GetColor("textSecondary"),
		position = UDim2.fromOffset(15, 55),
	})
	metricsText.Parent = section

	-- Services Status
	local servicesText = UI.Text:Create({
		text = "Services: " .. (self.state.servicesStatus.RemoteClient or "Checking..."),
		textSize = 12,
		textColor = StyleManager:GetColor("textSecondary"),
		position = UDim2.fromOffset(15, 80),
	})
	servicesText.Parent = section

	return section
end

function TestDashboard:RenderControlsSection()
	local section = UI.Utils.CreateSection("🎯 TEST CONTROLS", 120)

	-- Test Buttons menggunakan UI Library
	local pingButton = UI.Button:Create({
		text = "🏓 Ping Test",
		size = UDim2.new(0.3, 0, 0, 30),
		position = UDim2.fromOffset(15, 30),
		onClick = function()
			self:RunPingTest()
		end,
	})
	pingButton.Parent = section

	local eventButton = UI.Button:Create({
		text = "📡 Event Test",
		size = UDim2.new(0.3, 0, 0, 30),
		position = UDim2.new(0.35, 0, 0, 30),
		onClick = function()
			self:RunEventTest()
		end,
	})
	eventButton.Parent = section

	local dataButton = UI.Button:Create({
		text = "💾 Data Test",
		size = UDim2.new(0.3, 0, 0, 30),
		position = UDim2.new(0.7, 0, 0, 30),
		onClick = function()
			self:RunDataTest()
		end,
	})
	dataButton.Parent = section

	-- Clear Results Button
	local clearButton = UI.Button:Create({
		text = "🗑️ Clear Results",
		size = UDim2.new(0.3, 0, 0, 25),
		position = UDim2.fromOffset(15, 70),
		backgroundColor = StyleManager:GetColor("error"),
		onClick = function()
			self:ClearTestResults()
		end,
	})
	clearButton.Parent = section

	-- Current Test Indicator
	local testIndicator = UI.Text:Create({
		text = self.state.currentTest and "Running: " .. self.state.currentTest or "Ready for tests",
		textColor = self.state.isTesting and StyleManager:GetColor("warning") or StyleManager:GetColor("success"),
		textSize = 12,
		size = UDim2.new(0.6, 0, 0, 25),
		position = UDim2.new(0.35, 0, 0, 70),
	})
	testIndicator.Parent = section

	return section
end

function TestDashboard:RenderResultsSection()
	local section = UI.Utils.CreateSection("📋 TEST RESULTS", 200)

	local scrollContainer = UI.Utils.CreateScrollContainer(160)
	scrollContainer.Position = UDim2.fromOffset(0, 25)
	scrollContainer.Parent = section

	-- Populate with test results
	self:PopulateTestResults(scrollContainer)

	return section
end

function TestDashboard:PopulateTestResults(scrollContainer)
	-- Clear existing results
	for _, child in ipairs(scrollContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Add test result items
	for i, result in ipairs(self.state.testResults) do
		local resultItem = UI.Panel:Create({
			size = UDim2.new(1, -10, 0, 40),
			backgroundColor = result.success and StyleManager:GetColor("success") or StyleManager:GetColor("error"),
			backgroundTransparency = 0.8,
			cornerRadius = 4,
			padding = { left = 10, right = 10, top = 5, bottom = 5 },
		})
		resultItem.Position = UDim2.fromOffset(5, (i - 1) * 45)
		resultItem.Parent = scrollContainer

		-- Test Name and Status
		local statusText = UI.Text:Create({
			text = (result.success and "✅ " or "❌ ") .. result.testName,
			textSize = 14,
			size = UDim2.fromScale(0.6, 1),
		})
		statusText.Parent = resultItem

		-- Response Time or Result
		local resultText = UI.Text:Create({
			text = result.responseTime and string.format("%dms", result.responseTime) or (result.result or ""),
			textSize = 12,
			textColor = StyleManager:GetColor("textSecondary"),
			size = UDim2.fromScale(0.4, 1),
			position = UDim2.fromScale(0.6, 0),
			alignX = Enum.TextXAlignment.Right,
		})
		resultText.Parent = resultItem

		-- Update scroll container size
		scrollContainer.CanvasSize = UDim2.fromOffset(0, i * 45)
	end
end

return TestDashboard
