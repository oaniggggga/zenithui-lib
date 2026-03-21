--[[
	ZenithLib - Modular UI Library for Roblox
	Version 2.0.0
	Created for Roblox Luau
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Utility Functions
local function CreateInstance(className, properties)
print("[ZenithLib] >> CreateInstance()")
	local instance = Instance.new(className)
	for prop, value in pairs(properties) do
		instance[prop] = value
	end
	return instance
end

local function Tween(instance, properties, duration)
print("[ZenithLib] >> Tween()")
	local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

-- handle = откуда начинается drag (TitleBar), frame = что двигается (MainFrame)
local function MakeDraggable(frame, handle)
print("[ZenithLib] >> MakeDraggable()")
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function Update(input)
	print("[ZenithLib] >> Update()")
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	handle.InputBegan:Connect(function(input)
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

	handle.InputChanged:Connect(function(input)
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

-- Color Constants (Black & Rose)
local COLORS = {
	MainBackground   = Color3.fromRGB(10,  6,  8),   -- почти чёрный
	Accent           = Color3.fromRGB(220, 80, 120),  -- розовый акцент
	AccentText       = Color3.fromRGB(255, 170, 195), -- светло-розовый текст
	AccentDim        = Color3.fromRGB(90,  22,  48),  -- тёмный акцент (hover)
	Text             = Color3.fromRGB(238, 232, 235),
	SubText          = Color3.fromRGB(118, 100, 108),
	CloseRed         = Color3.fromRGB(255, 95,  87),
	MaximizeYellow   = Color3.fromRGB(254, 188, 46),
	MinimizeGreen    = Color3.fromRGB(40,  200, 64),
	DarkerBackground = Color3.fromRGB(6,   3,   5),   -- темнее основного
	InputBackground  = Color3.fromRGB(20,  12,  16),  -- фон элементов
	ElementBorder    = Color3.fromRGB(55,  22,  35),  -- розовый бордер
	InElementBorder  = Color3.fromRGB(55,  22,  35),
	SliderRail       = Color3.fromRGB(32,  12,  20),
	DropdownHolder   = Color3.fromRGB(14,   8,  11),
	ActiveTab        = Color3.fromRGB(28,   6,  15),
	TitleBarLine     = Color3.fromRGB(70,  28,  45),
}


-- Function to update accent color globally
local function SetAccentColor(color)
print("[ZenithLib] >> SetAccentColor()")
	COLORS.Accent = color
end

-- Main Library
local ZenithLib = {}
ZenithLib.__index = ZenithLib

-- Theme customization (after ZenithLib is defined)
function ZenithLib:SetTheme(theme)
print("[ZenithLib] >> ZenithLib:SetTheme()")
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
print("[ZenithLib] >> ZenithLib:GetTheme()")
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
print("[ZenithLib] >> ZenithLib:MakeWindow()")
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
		Size = UDim2.new(1, 20, 1, 20),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5273142107",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(20, 20, 20, 20),
	})
	shadow.Parent = self.ScreenGui
	
	print("[ZenithLib] Creating MainFrame...")
	self.MainFrame = CreateInstance("Frame", {
		Name = "MainFrame",
		Size = windowSize,
		Position = windowPos,
		BackgroundColor3 = COLORS.MainBackground,
		BackgroundTransparency = 0,
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
		Transparency = 0.4,
		Color = COLORS.Accent,
	})
	mainStroke.Parent = self.MainFrame
	
	-- Title Bar
	self.TitleBar = CreateInstance("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = COLORS.DarkerBackground,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	})
	self.TitleBar.Parent = self.MainFrame
	
	local titleBarCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 12) })
	titleBarCorner.Parent = self.TitleBar
	
	-- Название по центру тайтлбара
	self.TitleText = CreateInstance("TextLabel", {
		Name = "TitleText",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 50, 0, 0),
		BackgroundTransparency = 1,
		Text = Title,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	self.TitleText.Parent = self.TitleBar
	
	-- Window Controls Container
	-- Window controls — правый верхний угол, UIListLayout для равного spacing
	self.ControlsContainer = CreateInstance("Frame", {
		Name = "ControlsContainer",
		Size = UDim2.new(0, 76, 1, 0),
		Position = UDim2.new(1, -84, 0, 0),
		BackgroundTransparency = 1,
	})
	self.ControlsContainer.Parent = self.TitleBar

	CreateInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}).Parent = self.ControlsContainer

	-- Minimize (Green) — LayoutOrder 1 = левая
	self.MinimizeButton = CreateInstance("Frame", {
		Name = "MinimizeButton",
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = COLORS.MinimizeGreen,
		BorderSizePixel = 0,
		LayoutOrder = 1,
	})
	self.MinimizeButton.Parent = self.ControlsContainer
	CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = self.MinimizeButton
	local minHitbox = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
	})
	minHitbox.Parent = self.MinimizeButton

	-- Maximize (Yellow) — LayoutOrder 2 = средняя
	self.MaximizeButton = CreateInstance("Frame", {
		Name = "MaximizeButton",
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = COLORS.MaximizeYellow,
		BorderSizePixel = 0,
		LayoutOrder = 2,
	})
	self.MaximizeButton.Parent = self.ControlsContainer
	CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = self.MaximizeButton
	local maxHitbox = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
	})
	maxHitbox.Parent = self.MaximizeButton

	self.isMaximized = false
	self.normalSize = windowSize
	self.expandedSize = UDim2.new(windowSize.X.Scale, windowSize.X.Offset, 0, 600)
	maxHitbox.MouseButton1Click:Connect(function()
		self.isMaximized = not self.isMaximized
		Tween(self.MainFrame, { Size = self.isMaximized and self.expandedSize or self.normalSize })
	end)

	-- Close (Red) — LayoutOrder 3 = правая
	self.CloseButton = CreateInstance("Frame", {
		Name = "CloseButton",
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = COLORS.CloseRed,
		BorderSizePixel = 0,
		LayoutOrder = 3,
	})
	self.CloseButton.Parent = self.ControlsContainer
	CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = self.CloseButton
	local closeHitbox = CreateInstance("TextButton", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
	})
	closeHitbox.Parent = self.CloseButton
	closeHitbox.MouseButton1Click:Connect(function() self:Destroy() end)
	
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
		Size = UDim2.new(1, 0, 1, -44),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundTransparency = 1,
	})
	self.ContentContainer.Parent = self.MainFrame
	
	-- Tab Navigation
	print("[ZenithLib] Creating TabNav...")
	self.TabNav = CreateInstance("Frame", {
		Name = "TabNav",
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundColor3 = COLORS.DarkerBackground,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
	})
	self.TabNav.Parent = self.ContentContainer

	local tabNavCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 12) })
	tabNavCorner.Parent = self.TabNav

	-- ScrollingFrame для табов без скроллбара
	print("[ZenithLib] Creating TabScroll...")
	local tabScroll = CreateInstance("ScrollingFrame", {
		Name = "TabScroll",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
	})
	tabScroll.Parent = self.TabNav

	self.TabList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	self.TabList.Parent = tabScroll

	CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 8),
	}).Parent = tabScroll

	self.TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabScroll.CanvasSize = UDim2.new(0, 0, 0, self.TabList.AbsoluteContentSize.Y + 14)
	end)
	print("[ZenithLib] _tabScroll assigned:", tabScroll ~= nil)
	self._tabScroll = tabScroll
	

	-- Selector bar (Fluent-style) — в tabScroll
	self.SelectorBar = CreateInstance("Frame", {
		Name = "SelectorBar",
		Size = UDim2.new(0, 3, 0, 16),
		Position = UDim2.new(0, 0, 0, 6),
		BackgroundColor3 = COLORS.Accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 5,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = self.SelectorBar
	self.SelectorBar.Parent = self._tabScroll

	-- Spring-анимация для selector
	local selBar = self.SelectorBar
	local selPosS  = {value=22, velocity=0}
	local selSizeS = {value=16, velocity=0}
	local selPosT, selSizeT = 22, 16
	local selConn

	local function selSpring(s, target, freq, damp, dt)
	print("[ZenithLib] >> selSpring()")
		local f = freq*2*math.pi
		local k = s.value - target
		local e = math.exp(-damp*f*dt)
		local nv = (k*(1+f*dt)+s.velocity*dt)*e + target
		local nvel = (s.velocity*(1-f*dt)-k*f*f*dt)*e
		local done = math.abs(nvel)<0.3 and math.abs(nv-target)<0.3
		return {value=done and target or nv, velocity=done and 0 or nvel, done=done}
	end

	local function stepSel(dt)
	print("[ZenithLib] >> stepSel()")
		selPosS  = selSpring(selPosS,  selPosT,  7, 1,   dt)
		selSizeS = selSpring(selSizeS, selSizeT, 5, 0.7, dt)
		selBar.Position = UDim2.new(0,0,0, selPosS.value)
		selBar.Size     = UDim2.new(0,3,0, selSizeS.value)
		if selPosS.done and selSizeS.done and selConn then
			selConn:Disconnect(); selConn = nil
		end
	end

	local lastSelY, lastSelT = 22, tick()
	self._moveSelectorTo = function(tabY, tabH)
		local now = tick()
		local spd = math.abs(tabY - lastSelY) / math.max(now - lastSelT, 0.001)
		lastSelY, lastSelT = tabY, now
		selPosT  = tabY + (tabH or 35)/2 - 8
		selSizeT = math.clamp(16 + spd*0.05, 16, (tabH or 35)*1.6)
		selPosS.done = false; selSizeS.done = false
		if not selConn then
			selConn = game:GetService("RunService").RenderStepped:Connect(stepSel)
		end
		task.delay(0.13, function()
			selSizeT = 16; selSizeS.done = false
			if not selConn then selConn = game:GetService("RunService").RenderStepped:Connect(stepSel) end
		end)
	end

	-- Tab Content Area
	print("[ZenithLib] Creating TabContent...")
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
	MakeDraggable(self.MainFrame, self.TitleBar)
	
	-- ── Toggle visibility on RightShift ──────────────────────────
	self._visible = true
	self._toggleKey = Enum.KeyCode.RightShift
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == self._toggleKey then
			self._visible = not self._visible
			self.MainFrame.Visible = self._visible
		end
	end)

	-- сохраняем stroke для Settings
	self._mainStroke = mainStroke

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
	
	print("[ZenithLib] MakeWindow complete, returning window object")
	return self
end

function ZenithLib:MakeTab(config)
print("[ZenithLib] >> ZenithLib:MakeTab()")
	local win = self  -- window объект, не перезаписываем
	
	local Title = config.Title or "Tab"
	local Image = config.Image
	
	-- Create Tab Button
	local tabButton = CreateInstance("TextButton", {
		Name = "Tab_" .. Title,
		Size = UDim2.new(1, -10, 0, 34),
		BackgroundColor3 = COLORS.InputBackground,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	})
	
	local tabCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
	tabCorner.Parent = tabButton
	
	CreateInstance("UIPadding", { PaddingLeft = UDim.new(0, 10) }).Parent = tabButton
	
	if Image and Image ~= "" then
		local tabImage = CreateInstance("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 10, 0.5, -8),
			BackgroundTransparency = 1,
			Image = Image,
			ImageColor3 = COLORS.SubText,
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
	
	print("[ZenithLib] Adding tab button to _tabScroll, _tabScroll=", win._tabScroll ~= nil)
	tabButton.Parent = win._tabScroll
	
	-- Create Tab Content Frame
	local tabContent = CreateInstance("ScrollingFrame", {
		Name = "Content_" .. Title,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = COLORS.Accent,
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
	})
	
	local contentList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	contentList.Parent = tabContent

	-- Авто-обновление CanvasSize
	contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
	end)
	
	local contentPadding = CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 10),
	})
	contentPadding.Parent = tabContent
	
	print("[ZenithLib] Adding tabContent to TabContent frame, TabContent=", win.TabContent ~= nil)
	tabContent.Parent = win.TabContent
	tabContent.Visible = false
	
	print("[ZenithLib] Registered tab frame:", Title)
	win.TabFrames[Title] = tabContent
	
	-- Tab Click Handler
	local function SelectTab()
	print("[ZenithLib] >> SelectTab()")
		for _, frame in pairs(win.TabFrames) do
			frame.Visible = false
		end
		tabContent.Visible = true
		win.CurrentTab = Title
		
		-- Update button appearance — только Frame с именем Tab_*
		local tabContainer = win._tabScroll or win.TabNav
		for _, button in ipairs(tabContainer:GetChildren()) do
			if (button:IsA("Frame") or button:IsA("TextButton")) and button.Name:sub(1,4) == "Tab_" then
				button.BackgroundColor3 = COLORS.InputBackground
				button.BackgroundTransparency = 1
				local txt = button:FindFirstChildWhichIsA("TextLabel")
				if txt then txt.TextColor3 = COLORS.SubText; txt.TextSize = 12 end
			end
		end
		print("[ZenithLib] Tween tabButton")
		Tween(tabButton, { BackgroundColor3 = COLORS.ActiveTab, BackgroundTransparency = 0 }, 0.15)
		Tween(tabText, { TextColor3 = COLORS.AccentText }, 0.15)
		-- Selector
		if win._moveSelectorTo then
			local scrollRef = win._tabScroll or win.TabNav
			local relY = tabButton.AbsolutePosition.Y - scrollRef.AbsolutePosition.Y
			print("[ZenithLib] moveSelectorTo relY=", relY, "tabH=", tabButton.AbsoluteSize.Y)
			win._moveSelectorTo(relY, tabButton.AbsoluteSize.Y)
		end
	end
	
	print("[ZenithLib] Connecting MouseButton1Click for tab:", Title)
	tabButton.MouseButton1Click:Connect(function()
		SelectTab()
	end)

	tabButton.MouseEnter:Connect(function()
		if win.CurrentTab ~= Title then
			print("[ZenithLib] Tween tabButton")
			Tween(tabButton, { BackgroundColor3 = COLORS.InputBackground, BackgroundTransparency = 0.4 }, 0.12)
		end
	end)

	tabButton.MouseLeave:Connect(function()
		if win.CurrentTab ~= Title then
			print("[ZenithLib] Tween tabButton")
			Tween(tabButton, { BackgroundTransparency = 1 }, 0.15)
		end
	end)
	
	-- Auto-select first tab
	print("[ZenithLib] Auto-selecting first tab:", Title)
	if not win.CurrentTab then
		SelectTab()
	end
	
	-- Tab Methods
	local Tab = {}
	
	function Tab:MakeButton(config)
	print("[ZenithLib] >> Tab:MakeButton() name=", config and (config.Name or config.Title) or "?")
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
		local _bStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.35,
			Color = COLORS.Accent,
		})
		_bStroke.Parent = buttonFrame
		
		local buttonText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.AccentText,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
		})
		buttonText.Parent = buttonFrame
		
		local buttonHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		buttonHitbox.Parent = buttonFrame
		
		buttonHitbox.MouseButton1Down:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.Accent })
		end)
		
		buttonHitbox.MouseButton1Up:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.InputBackground })
			Callback()
		end)
		
		buttonHitbox.MouseEnter:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.AccentDim })
		end)
		
		buttonHitbox.MouseLeave:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.InputBackground })
		end)
		
		buttonFrame.Parent = tabContent
		return buttonFrame
	end
	
	function Tab:MakeToggle(config)
	print("[ZenithLib] >> Tab:MakeToggle() name=", config and (config.Name or config.Title) or "?")
		local Name = config.Name or "Toggle"
		local Default = config.Default or false
		local Callback = config.Callback or function() end
		
		local toggleFrame = CreateInstance("Frame", {
			Name = "Toggle_" .. Name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local toggleCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		toggleCorner.Parent = toggleFrame
		
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
		
		local function UpdateToggle()
		print("[ZenithLib] >> UpdateToggle()")
			if isOn then
				Tween(toggleSwitch, { BackgroundColor3 = COLORS.Accent })
				Tween(toggleKnob, { Position = UDim2.new(1, -18, 0.5, -7) })
			else
				Tween(toggleSwitch, { BackgroundColor3 = COLORS.SliderRail })
				Tween(toggleKnob, { Position = UDim2.new(0, 4, 0.5, -7) })
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
	print("[ZenithLib] >> Tab:MakeSlider() name=", config and (config.Name or config.Title) or "?")
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
		
		local sliderCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		sliderCorner.Parent = sliderFrame
		
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
		local sliderValLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(0, 45, 0, 20),
			Position = UDim2.new(1, -55, 0, 6),
			BackgroundTransparency = 1,
			Text = tostring(Default),
			TextColor3 = COLORS.SubText,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		sliderValLabel.Parent = sliderFrame
		sliderText.Parent = sliderFrame
		
		local sliderTrack = CreateInstance("Frame", {
			Name = "Track",
			Size = UDim2.new(1, -20, 0, 6),
			Position = UDim2.new(0, 10, 0, 35),
			BackgroundColor3 = COLORS.DarkerBackground,
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
			Position = UDim2.new((Default - Min) / (Max - Min), -6, 0.5, -6),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
		})
		sliderKnob.Parent = sliderTrack
		
		local knobCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) })
		knobCorner.Parent = sliderKnob
		
		local isDragging = false
		
		local function UpdateSlider(value)
		print("[ZenithLib] >> UpdateSlider()")
			local percent = math.clamp((value - Min) / (Max - Min), 0, 1)
			Tween(sliderFill, { Size = UDim2.new(percent, 0, 1, 0) })
			Tween(sliderKnob, { Position = UDim2.new(percent, -7, 0.5, -7) })
			sliderValLabel.Text = tostring(value)
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
	print("[ZenithLib] >> Tab:MakeDropdown() name=", config and (config.Name or config.Title) or "?")
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
		
		local dropdownCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		dropdownCorner.Parent = dropdownFrame
		
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
			ImageColor3 = COLORS.Text,
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
		
		local listCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		listCorner.Parent = dropdownList
		
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
	print("[ZenithLib] >> Tab:MakeMultiDropdown() name=", config and (config.Name or config.Title) or "?")
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
	print("[ZenithLib] >> Tab:MakeKeybind() name=", config and (config.Name or config.Title) or "?")
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
		print("[ZenithLib] >> UpdateKeyText()")
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
	print("[ZenithLib] >> Tab:MakeTextbox() name=", config and (config.Name or config.Title) or "?")
		local Name = config.Name or "Textbox"
		local Default = config.Default or ""
		local TextDisappear = config.TextDisappear or false
		local Callback = config.Callback or function() end

		-- Высота: 8 отступ + 16 лейбл + 4 gap + 28 инпут + 8 отступ = 64
		local textboxFrame = CreateInstance("Frame", {
			Name = "Textbox_" .. Name,
			Size = UDim2.new(1, 0, 0, 64),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})

		local textboxCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		textboxCorner.Parent = textboxFrame

		local textboxStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 0.4,
			Color = COLORS.ElementBorder,
		})
		textboxStroke.Parent = textboxFrame

		-- Лейбл сверху
		local textboxLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -20, 0, 16),
			Position = UDim2.new(0, 10, 0, 8),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.SubText,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		textboxLabel.Parent = textboxFrame

		-- TextBox под лейблом
		local textboxInput = CreateInstance("TextBox", {
			Size = UDim2.new(1, -20, 0, 28),
			Position = UDim2.new(0, 10, 0, 28),
			BackgroundColor3 = COLORS.DarkerBackground,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Text = Default,
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			PlaceholderText = config.Placeholder or "Enter text...",
			PlaceholderColor3 = COLORS.SubText,
			ClearTextOnFocus = TextDisappear,
		})
		textboxInput.Parent = textboxFrame

		local inputCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 5) })
		inputCorner.Parent = textboxInput

		local inputPadding = CreateInstance("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
		})
		inputPadding.Parent = textboxInput

		-- Подсветка при фокусе
		local inputStroke = CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5,
			Transparency = 1,
			Color = COLORS.Accent,
		})
		inputStroke.Parent = textboxInput

		textboxInput.Focused:Connect(function()
			Tween(inputStroke, { Transparency = 0.2 }, 0.18)
			Tween(textboxLabel, { TextColor3 = COLORS.AccentText }, 0.18)
		end)
		textboxInput.FocusLost:Connect(function()
			Tween(inputStroke, { Transparency = 1 }, 0.18)
			Tween(textboxLabel, { TextColor3 = COLORS.SubText }, 0.18)
			Callback(textboxInput.Text)
		end)

		textboxFrame.Parent = tabContent
		return textboxFrame
	end
	
	function Tab:MakeLabel(config)
	print("[ZenithLib] >> Tab:MakeLabel() name=", config and (config.Name or config.Title) or "?")
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
	print("[ZenithLib] >> Tab:MakeSeparator()")
		local sep = CreateInstance("Frame", {
			Name = "Separator",
			Size = UDim2.new(1, 0, 0, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		local line = CreateInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = line
		line.Parent = sep
		sep.Parent = tabContent
		return sep
	end
	
	function Tab:MakeColorPicker(config)
	print("[ZenithLib] >> Tab:MakeColorPicker() name=", config and (config.Name or config.Title) or "?")
		local Name = config.Name or "ColorPicker"
		local Default = config.Default or Color3.new(1, 1, 1)
		local Callback = config.Callback or function() end
		
		local pickerFrame = CreateInstance("Frame", {
			Name = "ColorPicker_" .. Name,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local pickerCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		pickerCorner.Parent = pickerFrame
		
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
	print("[ZenithLib] >> Tab:MakeParagraph() name=", config and (config.Name or config.Title) or "?")
		local Title = config.Title or "Title"
		local Text = config.Text or "Description text here..."
		
		local paragraphFrame = CreateInstance("Frame", {
			Name = "Paragraph_" .. Title,
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = COLORS.InputBackground,
			BorderSizePixel = 0,
		})
		
		local paragraphCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
		paragraphCorner.Parent = paragraphFrame
		
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
	
	print("[ZenithLib] MakeTab complete, returning Tab object for:", Title)
	return Tab
end

function ZenithLib:Destroy()
print("[ZenithLib] >> ZenithLib:Destroy()")
	if self.ScreenGui then self.ScreenGui:Destroy() end
end

end

-- Additional Window Methods
function ZenithLib:SetTitle(newTitle)
print("[ZenithLib] >> ZenithLib:SetTitle()")
	if self.TitleText then
		self.TitleText.Text = newTitle
	end
end

function ZenithLib:SetSize(size)
print("[ZenithLib] >> ZenithLib:SetSize()")
	if self.MainFrame then
		self.normalSize = size
		if not self.isMaximized then
			Tween(self.MainFrame, { Size = size })
		end
	end
end

function ZenithLib:SetPosition(position)
print("[ZenithLib] >> ZenithLib:SetPosition()")
	if self.MainFrame then
		Tween(self.MainFrame, { Position = position })
	end
end

function ZenithLib:Minimize()
print("[ZenithLib] >> ZenithLib:Minimize()")
	if not self.isMinimized then
		self.isMinimized = true
		local targetHeight = self.isMaximized and 600 or self.normalHeight
		Tween(self.MainFrame, { Size = UDim2.new(0, 700, 0, targetHeight) })
	end
end

function ZenithLib:Maximize()
print("[ZenithLib] >> ZenithLib:Maximize()")
	if not self.isMaximized then
		self.isMaximized = true
		Tween(self.MainFrame, { Size = self.expandedSize })
	end
end

function ZenithLib:Restore()
print("[ZenithLib] >> ZenithLib:Restore()")
	self.isMinimized = false
	self.isMaximized = false
	Tween(self.MainFrame, { Size = self.normalSize })
end


function ZenithLib:_InitBuiltinTabs()
print("[ZenithLib] >> ZenithLib:_InitBuiltinTabs()")
	local credTab = self:MakeTab({ Title = "Credits" })
	credTab:MakeParagraph({
		Title = "ZenithLib  v2.0",
		Text  = "Black & Rose Theme\nFluent-style acrylic, spring animations,\nselector bar. Toggle: RightShift.",
	})
	credTab:MakeSeparator()
	credTab:MakeLabel({ Name = "• Toggle UI — RightShift" })
	credTab:MakeLabel({ Name = "• Drag — Title bar" })
	credTab:MakeLabel({ Name = "• Close — Red dot (top right)" })

	local setTab = self:MakeTab({ Title = "Settings" })
	setTab:MakeParagraph({
		Title = "UI Settings",
		Text  = "Customize the library appearance.",
	})
	setTab:MakeSeparator()
	setTab:MakeKeybind({
		Name     = "Toggle Key",
		Default  = Enum.KeyCode.RightShift,
		Callback = function(key)
			self._toggleKey = key
		end,
	})
	setTab:MakeColorPicker({
		Name    = "Accent Color",
		Default = COLORS.Accent,
		Callback = function(color)
			COLORS.Accent = color
			if self._mainStroke then self._mainStroke.Color = color end
		end,
	})
end

-- Make library global
getgenv().ZenithLib = ZenithLib

return ZenithLib