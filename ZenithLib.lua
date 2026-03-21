--[[
	ZenithLib - Modular UI Library for Roblox
	Version 1.2.0
	Created for Roblox Luau
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Utility Functions
local function CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties) do
		instance[prop] = value
	end
	return instance
end

local function Tween(instance, properties, duration, style, direction)
	local tweenInfo = TweenInfo.new(
		duration or 0.18,
		style or Enum.EasingStyle.Quint,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

local function TweenSpring(instance, properties, duration)
	local tweenInfo = TweenInfo.new(duration or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

local function MakeDraggable(frame, parent)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function Update(input)
		local delta = input.Position - dragStart
		local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		frame.Position = newPos
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			Update(input)
		end
	end)
end


-- SpringStep — физика пружины (используется для selector полоски)
local function SpringStep(state, dt, target, frequency, damping)
	frequency = frequency or 8
	damping = damping or 1
	local f = frequency * 2 * math.pi
	local k = state.value - target
	local v = state.velocity or 0
	local e = math.exp(-damping * f * dt)
	local newValue, newVelocity
	if damping >= 1 then
		newValue = (k * (1 + f * dt) + v * dt) * e + target
		newVelocity = (v * (1 - f * dt) - k * (f * f * dt)) * e
	else
		local o = math.sqrt(1 - damping * damping)
		local c_ = math.cos(f * o * dt)
		local s_ = math.sin(f * o * dt)
		local t2 = o > 0.0001 and s_ / o or dt
		newValue = (k * (c_ + damping * t2) + v * (t2 / f)) * e + target
		newVelocity = (v * (c_ - t2 * damping) - k * (t2 * f)) * e
	end
	local done = math.abs(newVelocity) < 0.001 and math.abs(newValue - target) < 0.001
	return {
		value = done and target or newValue,
		velocity = done and 0 or newVelocity,
		complete = done,
	}
end


-- ══════════════════════════════════════════════
-- SpringStep — физика пружины для selector полоски
-- ══════════════════════════════════════════════
-- (уже определена выше)

-- ══════════════════════════════════════════════
-- Acrylic / Frosted Glass (как в Fluent UI)
-- Стеклянный Part в 3D мире перед камерой
-- ══════════════════════════════════════════════
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function MapRange(v, a, b, c_, d)
	return (v - a) * (d - c_) / (b - a) + c_
end

local function ScreenToWorld(pos2d, depth)
	local ray = Camera:ScreenPointToRay(pos2d.X, pos2d.Y)
	return ray.Origin + ray.Direction * depth
end

local function MakeAcrylic(frame)
	local depth = MapRange(Camera.ViewportSize.Y, 0, 2560, 8, 56)

	local part = Instance.new("Part")
	part.Name = "ZenithAcrylic"
	part.Color = Color3.new(0, 0, 0)
	part.Material = Enum.Material.Glass
	part.Size = Vector3.new(1, 1, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Locked = true
	part.CastShadow = false
	part.Transparency = 0.98
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Brick
	mesh.Offset = Vector3.new(0, 0, -0.000001)
	mesh.Parent = part
	part.Parent = workspace

	local conns = {}

	local function update()
		if not frame or not frame.Parent then return end
		local pos = frame.AbsolutePosition
		local size = frame.AbsoluteSize
		local tl = ScreenToWorld(pos, depth)
		local tr = ScreenToWorld(pos + Vector2.new(size.X, 0), depth)
		local br = ScreenToWorld(pos + size, depth)
		local w = (tr - tl).Magnitude
		local h = (tr - br).Magnitude
		local cf = Camera.CFrame
		part.CFrame = CFrame.fromMatrix((tl + br) / 2, cf.XVector, cf.YVector, cf.ZVector)
		part.Mesh.Scale = Vector3.new(w, h, 0)
	end

	table.insert(conns, Camera:GetPropertyChangedSignal("CFrame"):Connect(update))
	table.insert(conns, Camera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
	table.insert(conns, frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(update))
	table.insert(conns, frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))

	frame.AncestryChanged:Connect(function()
		if not frame.Parent then
			for _, conn in ipairs(conns) do pcall(function() conn:Disconnect() end) end
			pcall(function() part:Destroy() end)
		end
	end)

	task.defer(update)
	return part
end

-- Color Constants (Black & Rose Theme)
local COLORS = {
	MainBackground = Color3.fromRGB(0, 0, 0),         -- чистый чёрный
	Accent = Color3.fromRGB(220, 80, 120),            -- тёмно-розовый акцент
	AccentDim = Color3.fromRGB(100, 30, 55),          -- приглушённый акцент для фона кнопок
	AccentText = Color3.fromRGB(255, 170, 195),       -- светло-розовый для текста
	Text = Color3.fromRGB(240, 235, 238),             -- основной текст (чуть тёплый белый)
	SubText = Color3.fromRGB(130, 110, 118),          -- вторичный текст
	CloseRed = Color3.fromRGB(255, 95, 87),
	MaximizeYellow = Color3.fromRGB(254, 188, 46),
	MinimizeGreen = Color3.fromRGB(40, 200, 64),
	DarkerBackground = Color3.fromRGB(0, 0, 0),      -- тоже чёрный
	InputBackground = Color3.fromRGB(12, 8, 10),     -- почти чёрный с розовым оттенком
	ElementBorder = Color3.fromRGB(60, 25, 38),      -- тёмно-розовый бордер
	SliderRail = Color3.fromRGB(35, 15, 22),         -- трек слайдера
	DropdownHolder = Color3.fromRGB(8, 4, 6),
	ActiveTab = Color3.fromRGB(30, 8, 16),           -- фон активного таба
}

-- Function to update accent color globally
local function SetAccentColor(color)
	COLORS.Accent = color
end

-- Main Library
local ZenithLib = {}
ZenithLib.__index = ZenithLib

-- Theme customization (after ZenithLib is defined)
function ZenithLib:SetTheme(theme)
	if theme.Accent then
		COLORS.Accent = theme.Accent
	end
	if theme.MainBackground then
		COLORS.MainBackground = theme.MainBackground
	end
	if theme.Text then
		COLORS.Text = theme.Text
	end
	if theme.SubText then
		COLORS.SubText = theme.SubText
	end
	if theme.InputBackground then
		COLORS.InputBackground = theme.InputBackground
	end
	if theme.DarkerBackground then
		COLORS.DarkerBackground = theme.DarkerBackground
	end
end

-- Get current theme
function ZenithLib:GetTheme()
	return {
		Accent = COLORS.Accent,
		MainBackground = COLORS.MainBackground,
		Text = COLORS.Text,
		SubText = COLORS.SubText,
		InputBackground = COLORS.InputBackground,
		DarkerBackground = COLORS.DarkerBackground,
	}
end

function ZenithLib:MakeWindow(config)
	local self = setmetatable({}, ZenithLib)
	
	local Title = config.Title or "ZenithLib"
	local ConfigName = config.ConfigName or "Default"
	
	-- Create ScreenGui
	self.ScreenGui = CreateInstance("ScreenGui", {
		Name = "ZenithLib_" .. ConfigName,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 100,
	})
	self.ScreenGui.Parent = game:GetService("CoreGui")
	
	-- Main Frame
	local windowPos = config.Position or UDim2.new(0.5, -350, 0, 50)
	local windowSize = config.Size or UDim2.new(0, 700, 0, 450)
	
	-- Shadow Effect
	local shadow = CreateInstance("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 47, 1, 47),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5273142107",
		ImageColor3 = Color3.fromRGB(180, 30, 70),
		ImageTransparency = 0.82,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(20, 20, 20, 20),
	})
	shadow.Parent = self.ScreenGui
	
	self.MainFrame = CreateInstance("Frame", {
		Name = "MainFrame",
		Size = windowSize,
		Position = windowPos,
		BackgroundColor3 = COLORS.MainBackground,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	self.MainFrame.Parent = self.ScreenGui
	
	-- Corner Radius
	local mainCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 12) })
	mainCorner.Parent = self.MainFrame
	
	-- Border Stroke
	local mainStroke = CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Transparency = 0.55,
		Color = Color3.fromRGB(90, 90, 90),
	})
	mainStroke.Parent = self.MainFrame
	
	-- Title Bar
	self.TitleBar = CreateInstance("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = COLORS.DarkerBackground,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
	})
	self.TitleBar.Parent = self.MainFrame
	
	local titleBarCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
	titleBarCorner.Parent = self.TitleBar
	
	-- Title Text
	self.TitleText = CreateInstance("TextLabel", {
		Name = "TitleText",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Title,
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextTransparency = 0,
	})
	self.TitleText.Parent = self.TitleBar
	
	-- Window Controls Container
	self.ControlsContainer = CreateInstance("Frame", {
		Name = "ControlsContainer",
		Size = UDim2.new(0, 80, 0, 20),
		Position = UDim2.new(0, 15, 0.5, -10),
		BackgroundTransparency = 1,
	})
	self.ControlsContainer.Parent = self.TitleBar
	
	-- Close Button (Red)
	self.CloseButton = CreateInstance("Frame", {
		Name = "CloseButton",
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0, 0, 0.5, -6),
		BackgroundColor3 = COLORS.CloseRed,
		BorderSizePixel = 0,
	})
	self.CloseButton.Parent = self.ControlsContainer
	
	local closeCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
	closeCorner.Parent = self.CloseButton
	
	local closeHitbox = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	})
	closeHitbox.Parent = self.CloseButton
	closeHitbox.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
	
	-- Maximize Button (Yellow)
	self.MaximizeButton = CreateInstance("Frame", {
		Name = "MaximizeButton",
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0, 28, 0.5, -6),
		BackgroundColor3 = COLORS.MaximizeYellow,
		BorderSizePixel = 0,
	})
	self.MaximizeButton.Parent = self.ControlsContainer
	
	local maxCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
	maxCorner.Parent = self.MaximizeButton
	
	local maxHitbox = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	})
	maxHitbox.Parent = self.MaximizeButton
	
	self.isMaximized = false
	self.normalSize = windowSize
	self.expandedSize = UDim2.new(windowSize.X.Scale, windowSize.X.Offset, 0, 600)
	
	maxHitbox.MouseButton1Click:Connect(function()
		self.isMaximized = not self.isMaximized
		Tween(self.MainFrame, { Size = self.isMaximized and self.expandedSize or self.normalSize })
	end)
	
	-- Minimize Button (Green)
	self.MinimizeButton = CreateInstance("Frame", {
		Name = "MinimizeButton",
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0, 56, 0.5, -6),
		BackgroundColor3 = COLORS.MinimizeGreen,
		BorderSizePixel = 0,
	})
	self.MinimizeButton.Parent = self.ControlsContainer
	
	local minCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
	minCorner.Parent = self.MinimizeButton
	
	local minHitbox = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	})
	minHitbox.Parent = self.MinimizeButton
	
	self.isMinimized = false
	self.normalHeight = windowSize.Y.Offset
	self.minimizedHeight = 40
	
	minHitbox.MouseButton1Click:Connect(function()
		self.isMinimized = not self.isMinimized
		local targetHeight = self.isMinimized and self.minimizedHeight or (self.isMaximized and 600 or self.normalHeight)
		Tween(self.MainFrame, { Size = UDim2.new(0, 700, 0, targetHeight) })
	end)
	
	-- Content Container
	self.ContentContainer = CreateInstance("Frame", {
		Name = "ContentContainer",
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		BackgroundTransparency = 1,
	})
	self.ContentContainer.Parent = self.MainFrame
	
	-- Tab Navigation
	self.TabNav = CreateInstance("Frame", {
		Name = "TabNav",
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundColor3 = COLORS.DarkerBackground,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
	})
	self.TabNav.Parent = self.ContentContainer
	
	local tabNavCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 0) })
	tabNavCorner.Parent = self.TabNav
	
	self.TabList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	self.TabList.Parent = self.TabNav
	
	local tabPadding = CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
	})
	tabPadding.Parent = self.TabNav
	

	-- Selector полоска (как в Fluent)
	self.SelectorBar = CreateInstance("Frame", {
		Name = "SelectorBar",
		Size = UDim2.new(0, 3, 0, 0),
		Position = UDim2.new(0, 0, 0, 17),
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		ZIndex = 5,
	})
	local selectorCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2) })
	selectorCorner.Parent = self.SelectorBar
	self.SelectorBar.Parent = self.TabNav

	local selectorBar = self.SelectorBar
	local selectorPosState = { value = 17, velocity = 0, complete = true }
	local selectorSizeState = { value = 16, velocity = 0, complete = true }
	local selectorConn = nil

	local function updateSelector()
		selectorBar.Position = UDim2.new(0, 0, 0, selectorPosState.value)
		selectorBar.Size = UDim2.new(0, 3, 0, selectorSizeState.value)
	end

	local selectorTargetPos = 17
	local selectorTargetSize = 16
	local lastPos = 17
	local lastTime = tick()

	local function stepSelector(dt)
		local posComplete, sizeComplete = selectorPosState.complete, selectorSizeState.complete
		if not posComplete then
			selectorPosState = SpringStep(selectorPosState, dt, selectorTargetPos, 6, 1)
		end
		if not sizeComplete then
			selectorSizeState = SpringStep(selectorSizeState, dt, selectorTargetSize, 5, 0.7)
		end
		updateSelector()
		if selectorPosState.complete and selectorSizeState.complete then
			if selectorConn then selectorConn:Disconnect(); selectorConn = nil end
		end
	end

	local function startSelectorStep()
		if not selectorConn then
			selectorConn = game:GetService("RunService").RenderStepped:Connect(stepSelector)
		end
	end

	self._moveSelectorTo = function(tabPosY)
		local now = tick()
		local speed = math.abs(tabPosY - lastPos) / math.max(now - lastTime, 0.001)
		lastPos = tabPosY
		lastTime = now

		selectorTargetPos = tabPosY + 17
		selectorTargetSize = math.clamp(16 + speed * 0.08, 16, 40)
		selectorPosState.complete = false
		selectorSizeState.complete = false
		startSelectorStep()

		-- Возвращаем размер к 16 через 120мс
		task.delay(0.12, function()
			selectorTargetSize = 16
			selectorSizeState.complete = false
			startSelectorStep()
		end)
	end

	-- Tab Content Area
	self.TabContent = CreateInstance("Frame", {
		Name = "TabContent",
		Size = UDim2.new(1, -150, 1, 0),
		Position = UDim2.new(0, 150, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	self.TabContent.Parent = self.ContentContainer
	
	self.TabFrames = {}
	self.CurrentTab = nil
	
	-- Make Draggable
	MakeDraggable(self.MainFrame, self.ScreenGui)

	self._acrylicPart = nil
	task.defer(function()
		if self.MainFrame and self.MainFrame.Parent then
			self._acrylicPart = MakeAcrylic(self.MainFrame)
		end
	end)



	
	-- SetTheme function for Window
	function self:SetTheme(theme)
		if theme.Accent then
			COLORS.Accent = theme.Accent
		end
		if theme.MainBackground then
			COLORS.MainBackground = theme.MainBackground
		end
		if theme.Text then
			COLORS.Text = theme.Text
		end
		if theme.SubText then
			COLORS.SubText = theme.SubText
		end
		if theme.InputBackground then
			COLORS.InputBackground = theme.InputBackground
		end
		if theme.DarkerBackground then
			COLORS.DarkerBackground = theme.DarkerBackground
		end
	end
	
	return self
end

function ZenithLib:MakeTab(config)
	local self = setmetatable({}, { __index = self })
	
	local Title = config.Title or "Tab"
	local Image = config.Image
	
	-- Create Tab Button
	local tabButton = CreateInstance("Frame", {
		Name = "Tab_" .. Title,
		Size = UDim2.new(1, -10, 0, 35),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	
	local tabCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
	tabCorner.Parent = tabButton
	
	local tabLayout = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	tabLayout.Parent = tabButton
	
	local tabPadding = CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
	})
	tabPadding.Parent = tabButton
	
	if Image then
		local tabImage = CreateInstance("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			BackgroundTransparency = 1,
			Image = Image,
		})
		tabImage.Parent = tabButton
	end
	
	local tabText = CreateInstance("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Title,
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	tabText.Parent = tabButton
	
	tabButton.Parent = self.TabNav
	
	-- Create Tab Content Frame
	local tabContent = CreateInstance("ScrollingFrame", {
		Name = "Content_" .. Title,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = COLORS.Accent,
	})
	
	local contentList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	contentList.Parent = tabContent
	
	local contentPadding = CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
	})
	contentPadding.Parent = tabContent
	
	tabContent.Parent = self.TabContent
	tabContent.Visible = false
	
	self.TabFrames[Title] = tabContent
	
	-- Tab Click Handler
	local function SelectTab()
		-- Page transition: скрываем текущий
		for _, frame in pairs(self.TabFrames) do
			if frame.Visible and frame ~= tabContent then
				Tween(frame, { BackgroundTransparency = 1 }, 0.08)
				task.delay(0.1, function()
					frame.Visible = false
					frame.BackgroundTransparency = 0
				end)
			end
		end

		-- Показываем новый с небольшой задержкой
		task.delay(0.08, function()
			tabContent.Visible = true
			tabContent.Position = UDim2.new(0, 0, 0, 6)
			TweenSpring(tabContent, { Position = UDim2.new(0, 0, 0, 0) }, 0.28)
		end)

		self.CurrentTab = Title

		-- Обновляем кнопки табов
		for _, button in ipairs(self.TabNav:GetChildren()) do
			if button:IsA("Frame") and button.Name ~= "SelectorBar" then
				Tween(button, { BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1 }, 0.15)
				local txt = button:FindFirstChildWhichIsA("TextLabel")
				if txt then Tween(txt, { TextColor3 = COLORS.SubText }, 0.15) end
			end
		end
		Tween(tabButton, { BackgroundColor3 = COLORS.ActiveTab, BackgroundTransparency = 0 }, 0.15)
		Tween(tabText, { TextColor3 = COLORS.AccentText }, 0.15)

		-- Selector полоска
		if self._moveSelectorTo then
			local relY = tabButton.AbsolutePosition.Y - self.TabNav.AbsolutePosition.Y
			self._moveSelectorTo(relY)
		end
	end
	
	tabButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			SelectTab()
		end
	end)
	
	-- Hover effect for tab button
	tabButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if self.CurrentTab ~= Title then
				TweenSpring(tabButton, { BackgroundColor3 = Color3.fromRGB(42, 42, 42), BackgroundTransparency = 0.5 }, 0.2)
			end
		end
	end)
	
	tabButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if self.CurrentTab ~= Title then
				TweenSpring(tabButton, { BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1 }, 0.25)
			end
		end
	end)
	
	-- Auto-select first tab
	if not self.CurrentTab then
		SelectTab()
	end
	
	-- Tab Methods
	local Tab = {}
	
	function Tab:MakeButton(config)
		local Name = config.Name or "Button"
		local Callback = config.Callback or function() end
		
		local buttonFrame = CreateInstance("Frame", {
			Name = "Button_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local buttonCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		buttonCorner.Parent = buttonFrame
		
		local buttonStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,
			Transparency = 0.5,
			Color = COLORS.InElementBorder,
		})
		buttonStroke.Parent = buttonFrame
		
		local buttonText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextTransparency = 0,
		})
		buttonText.Parent = buttonFrame
		
		local buttonHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		buttonHitbox.Parent = buttonFrame
		
		buttonHitbox.MouseButton1Down:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.Accent }, 0.1)
			Tween(buttonText, { TextColor3 = Color3.fromRGB(0, 0, 0), TextTransparency = 0 }, 0.08)
		end)
		
		buttonHitbox.MouseButton1Up:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.InputBackground }, 0.22)
			Tween(buttonText, { TextColor3 = COLORS.Text, TextTransparency = 0 }, 0.15)
			Callback()
		end)
		
		buttonHitbox.MouseEnter:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = Color3.fromRGB(50, 50, 50) })
		end)
		
		buttonHitbox.MouseLeave:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.InputBackground })
		end)
		
		buttonFrame.Parent = tabContent
		return buttonFrame
	end
	
	function Tab:MakeToggle(config)
		local Name = config.Name or "Toggle"
		local Default = config.Default or false
		local Callback = config.Callback or function() end
		
		local toggleFrame = CreateInstance("Frame", {
			Name = "Toggle_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local toggleCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		toggleCorner.Parent = toggleFrame
		
		local toggleStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.55,
			Color = COLORS.ElementBorder,
		})
		toggleStroke.Parent = toggleFrame
		
		local toggleText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		toggleText.Parent = toggleFrame
		
		local toggleSwitch = CreateInstance("Frame", {
			Name = "Switch",
			Size = UDim2.new(0, 40, 0, 20),
			Position = UDim2.new(1, -50, 0.5, -10),
			BackgroundColor3 = Default and COLORS.Accent or COLORS.DarkerBackground,
			BorderSizePixel = 0,
		})
		toggleSwitch.Parent = toggleFrame
		
		local switchCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		switchCorner.Parent = toggleSwitch
		
		local toggleKnob = CreateInstance("Frame", {
			Name = "Knob",
			Size = UDim2.new(0, 14, 0, 14),
			Position = Default and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
			BackgroundColor3 = COLORS.Text,
			BorderSizePixel = 0,
		})
		toggleKnob.Parent = toggleSwitch
		
		local knobCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		knobCorner.Parent = toggleKnob
		
		local isOn = Default
		if isOn then
			toggleText.TextColor3 = COLORS.AccentText
		end
		
		local function UpdateToggle()
			if isOn then
				Tween(toggleSwitch, { BackgroundColor3 = COLORS.Accent }, 0.22)
				TweenSpring(toggleKnob, { Position = UDim2.new(1, -20, 0.5, -8) }, 0.3)
				Tween(toggleText, { TextColor3 = COLORS.Accent }, 0.18)
			else
				Tween(toggleSwitch, { BackgroundColor3 = Color3.fromRGB(120, 120, 120) }, 0.22)
				TweenSpring(toggleKnob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.3)
				Tween(toggleText, { TextColor3 = COLORS.Text }, 0.18)  -- белый
			end
			Callback(isOn)
		end
		
		local toggleHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		toggleHitbox.Parent = toggleFrame
		
		toggleHitbox.MouseButton1Click:Connect(function()
			isOn = not isOn
			UpdateToggle()
		end)
		
		toggleFrame.Parent = tabContent
		return toggleFrame
	end
	
	function Tab:MakeSlider(config)
		local Name = config.Name or "Slider"
		local Min = config.Min or 0
		local Max = config.Max or 100
		local Default = config.Default or 50
		local Color = config.Color or COLORS.Accent
		local Callback = config.Callback or function() end
		
		local sliderFrame = CreateInstance("Frame", {
			Name = "Slider_" .. Name,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local sliderCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		sliderCorner.Parent = sliderFrame
		
		local sliderStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.55,
			Color = COLORS.ElementBorder,
		})
		sliderStroke.Parent = sliderFrame
		
		local sliderText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -50, 0, 20),
			Position = UDim2.new(0, 10, 0, 6),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		sliderText.Parent = sliderFrame
		
		local sliderValueLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(0, 40, 0, 20),
			Position = UDim2.new(1, -50, 0, 6),
			BackgroundTransparency = 1,
			Text = tostring(Default),
			TextColor3 = COLORS.SubText,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		sliderValueLabel.Parent = sliderFrame
		
		local sliderTrack = CreateInstance("Frame", {
			Name = "Track",
			Size = UDim2.new(1, -20, 0, 4),
			Position = UDim2.new(0, 10, 0, 35),
			BackgroundColor3 = COLORS.SliderRail,
			BorderSizePixel = 0,
		})
		sliderTrack.Parent = sliderFrame
		
		local trackCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		trackCorner.Parent = sliderTrack
		
		local sliderFill = CreateInstance("Frame", {
			Name = "Fill",
			Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0),
			BackgroundColor3 = Color,
			BorderSizePixel = 0,
		})
		sliderFill.Parent = sliderTrack
		
		local fillCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		fillCorner.Parent = sliderFill
		
		local sliderKnob = CreateInstance("Frame", {
			Name = "Knob",
			Size = UDim2.new(0, 12, 0, 12),
			Position = UDim2.new((Default - Min) / (Max - Min), -7, 0.5, -7),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
		})
		sliderKnob.Parent = sliderTrack
		
		local knobCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		knobCorner.Parent = sliderKnob
		
		local isDragging = false
		
		local function UpdateSlider(value)
			local percent = math.clamp((value - Min) / (Max - Min), 0, 1)
			Tween(sliderFill, { Size = UDim2.new(percent, 0, 1, 0) })
			Tween(sliderKnob, { Position = UDim2.new(percent, -7, 0.5, -7) })
			sliderValueLabel.Text = tostring(value)
			Callback(value)
		end
		
		local sliderHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		sliderHitbox.Parent = sliderFrame
		
		sliderHitbox.MouseButton1Down:Connect(function()
			isDragging = true
		end)
		
		sliderHitbox.MouseButton1Up:Connect(function()
			isDragging = false
		end)
		
		sliderHitbox.MouseMoved:Connect(function()
			if isDragging then
				local relativeX = sliderTrack.AbsolutePosition.X
				local width = sliderTrack.AbsoluteSize.X
				local mouseX = UserInputService:GetMouseLocation().X
				local percent = math.clamp((mouseX - relativeX) / width, 0, 1)
				local value = math.floor(Min + percent * (Max - Min))
				UpdateSlider(value)
			end
		end)
		
		-- Click to set value directly
		sliderTrack.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local relativeX = sliderTrack.AbsolutePosition.X
				local width = sliderTrack.AbsoluteSize.X
				local mouseX = UserInputService:GetMouseLocation().X
				local percent = math.clamp((mouseX - relativeX) / width, 0, 1)
				local value = math.floor(Min + percent * (Max - Min))
				UpdateSlider(value)
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDragging = false
			end
		end)
		
		sliderFrame.Parent = tabContent
		return sliderFrame
	end
	
	function Tab:MakeDropdown(config)
		local Name = config.Name or "Dropdown"
		local Options = config.Options or { "Option 1", "Option 2" }
		local Default = config.Default or Options[1]
		local Callback = config.Callback or function() end
		
		local dropdownFrame = CreateInstance("Frame", {
			Name = "Dropdown_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local dropdownCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		dropdownCorner.Parent = dropdownFrame
		
		local dropdownStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.55,
			Color = COLORS.ElementBorder,
		})
		dropdownStroke.Parent = dropdownFrame
		
		local dropdownText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Name .. ": " .. tostring(Default),
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		dropdownText.Parent = dropdownFrame
		
		local dropdownArrow = CreateInstance("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, -30, 0.5, -10),
			BackgroundTransparency = 1,
			Image = "rbxassetid://7733658504",
			ImageColor3 = COLORS.SubText,
		})
		dropdownArrow.Parent = dropdownFrame
		
		local isOpen = false
		local selectedOption = Default
		
		local dropdownList = CreateInstance("Frame", {
			Name = "OptionsList",
			Size = UDim2.new(1, 0, 0, #Options * 30),
			Position = UDim2.new(0, 0, 1, 5),
			BackgroundColor3 = COLORS.DarkerBackground,
			BorderSizePixel = 0,
			Visible = false,
		})
		dropdownList.Parent = dropdownFrame
		
		local listCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		listCorner.Parent = dropdownList
		
		local listStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.4,
			Color = COLORS.ElementBorder,
		})
		listStroke.Parent = dropdownList
		
		local optionsList = CreateInstance("UIListLayout", {
			Padding = UDim.new(0, 0),
		})
		optionsList.Parent = dropdownList
		
		for _, option in ipairs(Options) do
			local optionButton = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = option == selectedOption and COLORS.Accent or COLORS.InputBackground,
				BorderSizePixel = 0,
				Text = option,
				TextColor3 = COLORS.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
			})
			optionButton.Parent = dropdownList
			
			optionButton.MouseButton1Click:Connect(function()
				selectedOption = option
				dropdownText.Text = Name .. ": " .. option
				isOpen = false
				dropdownList.Visible = false
				Tween(dropdownArrow, { Rotation = 0 })
				Callback(option)
			end)
		end
		
		local dropdownHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		dropdownHitbox.Parent = dropdownFrame
		
		dropdownHitbox.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			dropdownList.Visible = isOpen
			Tween(dropdownArrow, { Rotation = isOpen and 180 or 0 })
		end)
		
		-- Close dropdown when clicking outside
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
				local mousePos = UserInputService:GetMouseLocation()
				local dropdownAbsPos = dropdownFrame.AbsolutePosition
				local dropdownAbsSize = dropdownFrame.AbsoluteSize
				
				if mousePos.X < dropdownAbsPos.X or mousePos.X > dropdownAbsPos.X + dropdownAbsSize.X or
				   mousePos.Y < dropdownAbsPos.Y or mousePos.Y > dropdownAbsPos.Y + dropdownAbsSize.Y then
					isOpen = false
					dropdownList.Visible = false
					Tween(dropdownArrow, { Rotation = 0 })
				end
			end
		end)
		
		dropdownFrame.Parent = tabContent
		return dropdownFrame
	end
	
	function Tab:MakeMultiDropdown(config)
		local Name = config.Name or "MultiDropdown"
		local Options = config.Options or { "Option 1", "Option 2" }
		local Default = config.Default or {}
		local Callback = config.Callback or function() end
		
		local dropdownFrame = CreateInstance("Frame", {
			Name = "MultiDropdown_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local dropdownCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		dropdownCorner.Parent = dropdownFrame
		
		local selectedCount = #Default > 0 and #Default or 0
		local displayText = selectedCount > 0 and (tostring(selectedCount) .. " selected") or "None"
		
		local dropdownText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Name .. ": " .. displayText,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		dropdownText.Parent = dropdownFrame
		
		local dropdownArrow = CreateInstance("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, -30, 0.5, -10),
			BackgroundTransparency = 1,
			Image = "rbxassetid://7733658504",
			ImageColor3 = COLORS.Text,
		})
		dropdownArrow.Parent = dropdownFrame
		
		local isOpen = false
		local selectedItems = {}
		for _, v in ipairs(Default) do
			selectedItems[v] = true
		end
		
		local dropdownList = CreateInstance("Frame", {
			Name = "OptionsList",
			Size = UDim2.new(1, 0, 0, #Options * 30),
			Position = UDim2.new(0, 0, 1, 5),
			BackgroundColor3 = COLORS.DarkerBackground,
			BorderSizePixel = 0,
			Visible = false,
		})
		dropdownList.Parent = dropdownFrame
		
		local listCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		listCorner.Parent = dropdownList
		
		local optionsList = CreateInstance("UIListLayout", {
			Padding = UDim.new(0, 0),
		})
		optionsList.Parent = dropdownList
		
		local optionButtons = {}
		
		for _, option in ipairs(Options) do
			local optionFrame = CreateInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = selectedItems[option] and COLORS.Accent or COLORS.InputBackground,
				BorderSizePixel = 0,
			})
			optionFrame.Parent = dropdownList
			
			local checkmark = CreateInstance("ImageLabel", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 10, 0.5, -8),
				BackgroundTransparency = 1,
				Image = "rbxassetid://7733658504",
				ImageColor3 = COLORS.Text,
				Visible = selectedItems[option] or false,
			})
			checkmark.Parent = optionFrame
			
			local optionText = CreateInstance("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				BackgroundTransparency = 1,
				Text = option,
				TextColor3 = COLORS.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			optionText.Parent = optionFrame
			
			local optionHitbox = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
			})
			optionHitbox.Parent = optionFrame
			
			optionHitbox.MouseButton1Click:Connect(function()
				selectedItems[option] = not selectedItems[option]
				checkmark.Visible = selectedItems[option]
				optionFrame.BackgroundColor3 = selectedItems[option] and COLORS.Accent or COLORS.InputBackground
				
				local selected = {}
				for k, v in pairs(selectedItems) do
					if v then table.insert(selected, k) end
				end
				
				local count = #selected
				local display = count > 0 and (tostring(count) .. " selected") or "None"
				dropdownText.Text = Name .. ": " .. display
				Callback(selected)
			end)
			
			optionButtons[option] = { frame = optionFrame, checkmark = checkmark }
		end
		
		local dropdownHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		dropdownHitbox.Parent = dropdownFrame
		
		dropdownHitbox.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			dropdownList.Visible = isOpen
			Tween(dropdownArrow, { Rotation = isOpen and 180 or 0 })
		end)
		
		-- Close dropdown when clicking outside
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
				local mousePos = UserInputService:GetMouseLocation()
				local dropdownAbsPos = dropdownFrame.AbsolutePosition
				local dropdownAbsSize = dropdownFrame.AbsoluteSize
				
				if mousePos.X < dropdownAbsPos.X or mousePos.X > dropdownAbsPos.X + dropdownAbsSize.X or
				   mousePos.Y < dropdownAbsPos.Y or mousePos.Y > dropdownAbsPos.Y + dropdownAbsSize.Y then
					isOpen = false
					dropdownList.Visible = false
					Tween(dropdownArrow, { Rotation = 0 })
				end
			end
		end)
		
		dropdownFrame.Parent = tabContent
		return dropdownFrame
	end
	
	function Tab:MakeKeybind(config)
		local Name = config.Name or "Keybind"
		local Default = config.Default or Enum.KeyCode.Unknown
		local Callback = config.Callback or function() end
		
		local keybindFrame = CreateInstance("Frame", {
			Name = "Keybind_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local keybindCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		keybindCorner.Parent = keybindFrame
		
		local keybindText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -100, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		keybindText.Parent = keybindFrame
		
		local keybindButton = CreateInstance("Frame", {
			Name = "KeyButton",
			Size = UDim2.new(0, 80, 0, 26),
			Position = UDim2.new(1, -90, 0.5, -13),
			BackgroundColor3 = COLORS.DarkerBackground,
			BorderSizePixel = 0,
		})
		keybindButton.Parent = keybindFrame
		
		local keyButtonCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4) })
		keyButtonCorner.Parent = keybindButton
		
		local keyText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = tostring(Default):gsub("Enum.KeyCode.", ""),
			TextColor3 = COLORS.Text,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
		})
		keyText.Parent = keybindButton
		
		local currentKey = Default
		local isListening = false
		
		local function UpdateKeyText()
			keyText.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
		end
		
		local keyHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		keyHitbox.Parent = keybindButton
		
		keyHitbox.MouseButton1Click:Connect(function()
			isListening = true
			keyText.Text = "..."
			Tween(keybindButton, { BackgroundColor3 = COLORS.Accent })
		end)
		
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if isListening then
				currentKey = input.KeyCode
				isListening = false
				Tween(keybindButton, { BackgroundColor3 = COLORS.DarkerBackground })
				UpdateKeyText()
				Callback(currentKey)
			end
		end)
		
		keybindFrame.Parent = tabContent
		return keybindFrame
	end
	
	function Tab:MakeTextbox(config)
		local Name = config.Name or "Textbox"
		local Default = config.Default or ""
		local TextDisappear = config.TextDisappear or false
		local Callback = config.Callback or function() end
		
		local textboxFrame = CreateInstance("Frame", {
			Name = "Textbox_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local textboxCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		textboxCorner.Parent = textboxFrame
		
		local textboxStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.55,
			Color = COLORS.ElementBorder,
		})
		textboxStroke.Parent = textboxFrame
		
		local textboxLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		textboxLabel.Parent = textboxFrame
		
		local textboxInput = CreateInstance("TextBox", {
			Size = UDim2.new(1, -20, 0, 24),
			Position = UDim2.new(0, 10, 0, 30),
			BackgroundColor3 = COLORS.DarkerBackground,
			BorderSizePixel = 0,
			Text = Default,
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			PlaceholderText = "Enter text...",
			PlaceholderColor3 = COLORS.SubText,
			ClearTextOnFocus = TextDisappear,
		})
		textboxInput.Parent = textboxFrame
		
		local inputCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4) })
		inputCorner.Parent = textboxInput
		
		textboxInput.Focused:Connect(function()
			Tween(textboxStroke, { Color = COLORS.Accent, Transparency = 0.2 }, 0.18)
		end)
		
		textboxInput.FocusLost:Connect(function()
			Tween(textboxStroke, { Color = COLORS.ElementBorder, Transparency = 0.55 }, 0.18)
			Callback(textboxInput.Text)
		end)
		
		textboxFrame.Parent = tabContent
		return textboxFrame
	end
	
	function Tab:MakeLabel(config)
		local Name = config.Name or "Label"
		
		local labelFrame = CreateInstance("Frame", {
			Name = "Label_" .. Name,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		
		local labelText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
		})
		labelText.Parent = labelFrame
		
		labelFrame.Parent = tabContent
		return labelFrame
	end
	
	function Tab:MakeSeparator()
		local separatorOuter = CreateInstance("Frame", {
			Name = "Separator",
			Size = UDim2.new(1, 0, 0, 9),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		
		local separatorLine = CreateInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = COLORS.TitleBarLine,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		})
		
		local sepCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		sepCorner.Parent = separatorLine
		separatorLine.Parent = separatorOuter
		separatorOuter.Parent = tabContent
		return separatorOuter
	end
	
	function Tab:MakeColorPicker(config)
		local Name = config.Name or "ColorPicker"
		local Default = config.Default or Color3.new(1, 1, 1)
		local Callback = config.Callback or function() end
		
		local pickerFrame = CreateInstance("Frame", {
			Name = "ColorPicker_" .. Name,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local pickerCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		pickerCorner.Parent = pickerFrame
		
		local pickerStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.55,
			Color = COLORS.ElementBorder,
		})
		pickerStroke.Parent = pickerFrame
		
		local pickerText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -50, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		pickerText.Parent = pickerFrame
		
		local colorPreview = CreateInstance("Frame", {
			Name = "ColorPreview",
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -40, 0.5, -15),
			BackgroundColor3 = Default,
			BorderSizePixel = 0,
		})
		colorPreview.Parent = pickerFrame
		
		local previewCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4) })
		previewCorner.Parent = colorPreview
		
		local colors = {
			Color3.new(1, 0, 0),
			Color3.new(0, 1, 0),
			Color3.new(0, 0, 1),
			Color3.new(1, 1, 0),
			Color3.new(1, 0, 1),
			Color3.new(0, 1, 1),
			Color3.new(1, 0.5, 0),
			Color3.new(0.5, 0, 1),
		}
		
		local colorButtons = {}
		local currentColor = Default
		
		local colorsFrame = CreateInstance("Frame", {
			Name = "ColorsFrame",
			Size = UDim2.new(1, -60, 0, 25),
			Position = UDim2.new(0, 5, 0, 25),
			BackgroundTransparency = 1,
		})
		colorsFrame.Parent = pickerFrame
		
		local colorsList = CreateInstance("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
		})
		colorsList.Parent = colorsFrame
		
		for i, color in ipairs(colors) do
			local colorBtn = CreateInstance("Frame", {
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
			})
			colorBtn.Parent = colorsFrame
			
			local btnCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4) })
			btnCorner.Parent = colorBtn
			
			local btnHitbox = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
			})
			btnHitbox.Parent = colorBtn
			
			btnHitbox.MouseButton1Click:Connect(function()
				currentColor = color
				Tween(colorPreview, { BackgroundColor3 = color })
				Callback(color)
			end)
			
			colorButtons[i] = colorBtn
		end
		
		pickerFrame.Parent = tabContent
		return pickerFrame
	end
	
	function Tab:MakeParagraph(config)
		local Title = config.Title or "Title"
		local Text = config.Text or "Description text here..."
		
		local paragraphFrame = CreateInstance("Frame", {
			Name = "Paragraph_" .. Title,
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local paragraphCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		paragraphCorner.Parent = paragraphFrame
		
		local paragraphStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.55,
			Color = COLORS.ElementBorder,
		})
		paragraphStroke.Parent = paragraphFrame
		
		local titleLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			Text = Title,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		titleLabel.Parent = paragraphFrame
		
		local textLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -20, 0, 35),
			Position = UDim2.new(0, 10, 0, 25),
			BackgroundTransparency = 1,
			Text = Text,
			TextColor3 = COLORS.SubText,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		textLabel.Parent = paragraphFrame
		
		paragraphFrame.Parent = tabContent
		return paragraphFrame
	end
	
	return Tab
end

function ZenithLib:Destroy()
	if self._acrylicPart then
		pcall(function() self._acrylicPart:Destroy() end)
	end
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

-- Additional Window Methods
function ZenithLib:SetAcrylic(enabled)
	if self._acrylicPart then
		self._acrylicPart.Transparency = enabled and 0.98 or 1
	end
end

function ZenithLib:SetTitle(newTitle)
	if self.TitleText then
		self.TitleText.Text = newTitle
	end
end

function ZenithLib:SetSize(size)
	if self.MainFrame then
		self.normalSize = size
		if not self.isMaximized then
			Tween(self.MainFrame, { Size = size })
		end
	end
end

function ZenithLib:SetPosition(position)
	if self.MainFrame then
		Tween(self.MainFrame, { Position = position })
	end
end

function ZenithLib:Minimize()
	if not self.isMinimized then
		self.isMinimized = true
		local targetHeight = self.isMaximized and 600 or self.normalHeight
		Tween(self.MainFrame, { Size = UDim2.new(0, 700, 0, targetHeight) })
	end
end

function ZenithLib:Maximize()
	if not self.isMaximized then
		self.isMaximized = true
		Tween(self.MainFrame, { Size = self.expandedSize })
	end
end

function ZenithLib:Restore()
	self.isMinimized = false
	self.isMaximized = false
	Tween(self.MainFrame, { Size = self.normalSize })
end

-- Make library global
getgenv().ZenithLib = ZenithLib

return ZenithLib