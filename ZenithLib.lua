--[[
	ZenithLib - Modular UI Library for Roblox
	Version 2.0.0
	Created for Roblox Luau
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Utility Functions
print("[ZenithLib] FILE LOADED - line 1 reached")
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
	EL_HOVER         = Color3.fromRGB(30,  16,  22),   -- hover на элементах
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
	local Author = config.Author or nil
	local ConfigName = config.ConfigName or "Default"
	
	-- Create ScreenGui
	self.ScreenGui = CreateInstance("ScreenGui", {
		Name = "ZenithLib_" .. ConfigName,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 100,
	})
	self.ScreenGui.Parent = game:GetService("CoreGui")

	-- ── INTRO SCREEN ─────────────────────────────────────────────
	if config.Intro ~= false then
		local introGui = CreateInstance("ScreenGui", {
			Name = "ZenithIntro",
			IgnoreGuiInset = true,
			DisplayOrder = 999,
			ResetOnSpawn = false,
			Parent = game:GetService("CoreGui"),
		})

		local bg = CreateInstance("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = introGui,
		})

		-- Центральный контейнер
		local center = CreateInstance("Frame", {
			Size = UDim2.new(0, 320, 0, 100),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = bg,
		})

		-- Акцентная линия сверху
		local topLine = CreateInstance("Frame", {
			Size = UDim2.new(0, 0, 0, 2),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Parent = center,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = topLine

		-- Название скрипта
		local titleLbl = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 0, 52),
			Position = UDim2.new(0, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = Title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextTransparency = 1,
			TextSize = 36,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = center,
		})

		-- "by AuthorName"
		local byLbl = CreateInstance("TextLabel", {
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.new(0, 0, 0, 66),
			BackgroundTransparency = 1,
			Text = Author and ("by " .. Author) or "ZenithLib",
			TextColor3 = COLORS.Accent,
			TextTransparency = 1,
			TextSize = 14,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = center,
		})

		-- Анимация появления
		task.spawn(function()
			task.wait(0.1)

			-- Линия раскрывается
			Tween(topLine, { Size = UDim2.new(0, 280, 0, 2) }, 0.5, Enum.EasingStyle.Quint)
			task.wait(0.3)

			-- Текст появляется
			Tween(titleLbl, { TextTransparency = 0 }, 0.4, Enum.EasingStyle.Quint)
			task.wait(0.15)
			Tween(byLbl, { TextTransparency = 0 }, 0.35, Enum.EasingStyle.Quint)
			task.wait(0.9)

			-- Fade out всего
			Tween(titleLbl, { TextTransparency = 1 }, 0.3)
			Tween(byLbl,    { TextTransparency = 1 }, 0.3)
			task.wait(0.15)
			Tween(topLine, { Size = UDim2.new(0, 0, 0, 2) }, 0.3, Enum.EasingStyle.Quint)
			task.wait(0.15)
			Tween(bg, { BackgroundTransparency = 1 }, 0.35)
			task.wait(0.4)

			introGui:Destroy()
		end)
	end
	-- ─────────────────────────────────────────────────────────────

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
	

	if config.SubTitle then
		CreateInstance("TextLabel", {
			Name = "SubTitle",
			Size = UDim2.new(1, -100, 0, 12),
			Position = UDim2.new(0, 50, 1, -13),
			BackgroundTransparency = 1,
			Text = config.SubTitle,
			TextColor3 = COLORS.SubText,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = self.TitleBar,
		})
	end
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
		self:Minimize()
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

	-- Обычный Frame для табов — никакого скроллбара
	local tabScroll = CreateInstance("Frame", {
		Name = "TabScroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	tabScroll.Parent = self.TabNav

	self.TabList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	self.TabList.Parent = tabScroll

	CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 8),
	}).Parent = tabScroll



	print("[ZenithLib] _tabScroll assigned:", tabScroll ~= nil)
	self._tabScroll = tabScroll
	



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

	win._tabCount = (win._tabCount or 0) + 1
	local tabIdx = win._tabCount

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
	local tabContent = CreateInstance("Frame", {
		Name = "Content_" .. Title,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	
	local contentList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	contentList.Parent = tabContent

	
	local contentPadding = CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 4),
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
		Tween(tabText, { TextColor3 = COLORS.AccentText, TextSize = 13 }, 0.15)
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
		local toggleCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		toggleCorner.Parent = toggleFrame
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.5,
			Color = COLORS.ElementBorder,
		}).Parent = toggleFrame
		
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
		
		local sliderCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		sliderCorner.Parent = sliderFrame
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.5,
			Color = COLORS.ElementBorder,
		}).Parent = sliderFrame
		
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
		
		local keybindCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) })
		keybindCorner.Parent = keybindFrame
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.5,
			Color = COLORS.ElementBorder,
		}).Parent = keybindFrame
		
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
		local Name   = config.Name  or config.Title or "Label"
		local Color  = config.Color or COLORS.SubText
		local Size   = config.TextSize or 12

		local labelFrame = CreateInstance("Frame", {
			Name = "Label_" .. Name,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})

		CreateInstance("TextLabel", {
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = Color,
			TextSize = Size,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
		}).Parent = labelFrame

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
	

	function Tab:MakeSection(config)
	print("[ZenithLib] >> Tab:MakeSection() name=", config and (config.Name or config.Title) or "?")
		local Name = config.Name or "Section"

		local sectionFrame = CreateInstance("Frame", {
			Name = "Section_" .. Name,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
		})

		-- Header строка
		local headerRow = CreateInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		headerRow.Parent = sectionFrame

		CreateInstance("TextLabel", {
			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = string.upper(Name),
			TextColor3 = COLORS.Accent,
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		}).Parent = headerRow

		-- Линия
		local line = CreateInstance("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = line
		line.Parent = headerRow

		sectionFrame.Parent = tabContent
		return sectionFrame
	end


	function Tab:MakeInput(config)
		return self:MakeTextbox(config)
	end


	function Tab:MakeProgressBar(config)
	print("[ZenithLib] >> Tab:MakeProgressBar() name=", config and (config.Name or config.Title) or "?")
		local Name     = config.Name    or "Progress"
		local Default  = config.Default or 0   -- 0..100
		local Callback = config.Callback or function() end

		local frame = CreateInstance("Frame", {
			Name = "Progress_" .. Name,
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = COLORS.InputBackground,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = frame
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.5,
			Color = COLORS.ElementBorder,
		}).Parent = frame

		-- Label + процент
		CreateInstance("TextLabel", {
			Size = UDim2.new(1, -50, 0, 18),
			Position = UDim2.new(0, 10, 0, 4),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = frame

		local pctLabel = CreateInstance("TextLabel", {
			Size = UDim2.new(0, 44, 0, 18),
			Position = UDim2.new(1, -54, 0, 4),
			BackgroundTransparency = 1,
			Text = tostring(Default) .. "%",
			TextColor3 = COLORS.AccentText,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		pctLabel.Parent = frame

		-- Track
		local track = CreateInstance("Frame", {
			Size = UDim2.new(1, -20, 0, 4),
			Position = UDim2.new(0, 10, 0, 30),
			BackgroundColor3 = COLORS.SliderRail,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = track
		track.Parent = frame

		local fill = CreateInstance("Frame", {
			Size = UDim2.new(Default / 100, 0, 1, 0),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(1,0) }).Parent = fill
		fill.Parent = track

		local obj = {}
		function obj:SetValue(v)
			v = math.clamp(v, 0, 100)
			Tween(fill, { Size = UDim2.new(v/100, 0, 1, 0) }, 0.2)
			pctLabel.Text = tostring(math.floor(v)) .. "%"
			Callback(v)
		end
		function obj:GetValue()
			return math.floor(fill.Size.X.Scale * 100)
		end

		frame.Parent = tabContent
		return obj
	end

	print("[ZenithLib] MakeTab complete, returning Tab object for:", Title)
	return Tab
end

function ZenithLib:Destroy()
print("[ZenithLib] >> ZenithLib:Destroy()")
	if self.ScreenGui then self.ScreenGui:Destroy() end
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

function ZenithLib:Toggle()
	self._visible = not self._visible
	self.MainFrame.Visible = self._visible
end

function ZenithLib:Show()
	self._visible = true
	self.MainFrame.Visible = true
end

function ZenithLib:Hide()
	self._visible = false
	self.MainFrame.Visible = false
end

function ZenithLib:SetToggleKey(key)
	self._toggleKey = key
end

function ZenithLib:GetVersion()
	return "2.0.0"
end

function ZenithLib:SetWindowSize(w, h)
	local s = UDim2.new(0, w, 0, h)
	self.normalSize = s
	Tween(self.MainFrame, { Size = s }, 0.25, Enum.EasingStyle.Quint)
end

function ZenithLib:SetWindowPosition(x, y)
	Tween(self.MainFrame, { Position = UDim2.new(0, x, 0, y) }, 0.2)
end

function ZenithLib:SetAccent(color)
	COLORS.Accent     = color
	COLORS.AccentText = Color3.new(math.min(color.R+0.35,1), math.min(color.G+0.35,1), math.min(color.B+0.35,1))
	COLORS.ActiveTab  = Color3.new(color.R*0.13, color.G*0.07, color.B*0.1)
	COLORS.ElementBorder = Color3.new(color.R*0.25, color.G*0.09, color.B*0.15)
	COLORS.AccentDim  = Color3.new(color.R*0.41, color.G*0.09, color.B*0.21)
	if self._mainStroke then self._mainStroke.Color = color end
end

-- Обновляет ContentContainer.Size если меняется TabNav ширина
function ZenithLib:SetTabWidth(w)
	self.TabNav.Size = UDim2.new(0, w, 1, 0)
	self.TabContent.Size = UDim2.new(1, -w, 1, 0)
	self.TabContent.Position = UDim2.new(0, w, 0, 0)
end

-- Возвращает список названий всех табов
function ZenithLib:GetTabs()
	local names = {}
	for k in pairs(self.TabFrames) do
		table.insert(names, k)
	end
	return names
end



function ZenithLib:_InitBuiltinTabs()
print("[ZenithLib] >> ZenithLib:_InitBuiltinTabs()")
	local credTab = self:MakeTab({ Title = "Credits" })
	credTab:MakeParagraph({
		Title = "ZenithLib  v2.0",
		Text  = "Black & Rose Theme — модульная UI библиотека для Roblox. Чистый дизайн, гибкие элементы, простое API.",
	})
	credTab:MakeSeparator()
	credTab:MakeSection({ Name = "Управление" })
	credTab:MakeLabel({ Name = "• RightShift — показать/скрыть" })
	credTab:MakeLabel({ Name = "• Тайтлбар — перетащить окно" })
	credTab:MakeLabel({ Name = "• Красная точка — закрыть" })
	credTab:MakeLabel({ Name = "• Зелёная точка — свернуть" })
	credTab:MakeSeparator()
	credTab:MakeSection({ Name = "Элементы" })
	credTab:MakeLabel({ Name = "MakeButton, MakeToggle, MakeSlider" })
	credTab:MakeLabel({ Name = "MakeDropdown, MakeMultiDropdown" })
	credTab:MakeLabel({ Name = "MakeKeybind, MakeTextbox, MakeLabel" })
	credTab:MakeLabel({ Name = "MakeParagraph, MakeSeparator, MakeSection" })

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


-- ═══════════════════════════════════════════
-- Notification System
-- ═══════════════════════════════════════════
local NotifHolder = nil

local function GetNotifHolder(gui)
	if NotifHolder and NotifHolder.Parent then return NotifHolder end
	NotifHolder = CreateInstance("Frame", {
		Name = "ZenithNotifHolder",
		Size = UDim2.new(0, 280, 1, -20),
		Position = UDim2.new(1, -296, 0, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 200,
		Parent = gui,
	})
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = NotifHolder,
	})
	return NotifHolder
end

function ZenithLib:Notify(cfg)
	local title    = cfg.Title    or "Notification"
	local content  = cfg.Content  or ""
	local duration = cfg.Duration or 4
	local holder   = GetNotifHolder(self.ScreenGui)

	local card = CreateInstance("Frame", {
		Name = "Notif",
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = COLORS.DarkerBackground,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = holder,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = card
	CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 0.5, Transparency = 0.4,
		Color = COLORS.Accent,
	}).Parent = card

	-- Акцентная полоска слева
	local stripe = CreateInstance("Frame", {
		Size = UDim2.new(0, 3, 1, -16),
		Position = UDim2.new(0, 0, 0, 8),
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = stripe
	stripe.Parent = card

	-- Title
	CreateInstance("TextLabel", {
		Size = UDim2.new(1, -20, 0, 18),
		Position = UDim2.new(0, 14, 0, 10),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = COLORS.AccentText,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	}).Parent = card

	-- Content
	CreateInstance("TextLabel", {
		Size = UDim2.new(1, -20, 0, 28),
		Position = UDim2.new(0, 14, 0, 30),
		BackgroundTransparency = 1,
		Text = content,
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}).Parent = card

	-- Progress bar
	local bar = CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = COLORS.Accent,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
	})
	bar.Parent = card

	-- Animate in: slide from right
	card.Position = UDim2.new(1, 10, 0, 0)
	Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back)

	-- Progress shrink
	task.spawn(function()
		local steps = duration * 20
		for i = 1, steps do
			if not card.Parent then return end
			bar.Size = UDim2.new(1 - (i / steps), 0, 0, 2)
			task.wait(1 / 20)
		end
	end)

	-- Dismiss
	task.delay(duration, function()
		if not card.Parent then return end
		Tween(card, { Position = UDim2.new(1, 10, 0, 0), BackgroundTransparency = 1 }, 0.25)
		task.wait(0.3)
		pcall(function() card:Destroy() end)
	end)

	return card
end

-- Make library global
-- Сохраняем глобально если возможно
pcall(function()
	getgenv().ZenithLib = ZenithLib
end)
_G.ZenithLib = ZenithLib

return ZenithLib



-- ═══════════════════════════════════════════════════════════
-- ZenithLib API Reference (inline docs)
-- ═══════════════════════════════════════════════════════════
--[[

WINDOW CREATION:
  local win = ZenithLib:MakeWindow({
    Title      = "MyScript",    -- название окна
    SubTitle   = "v1.0",        -- подназвание под title (опционально)
    ConfigName = "main",        -- уникальный ключ
    Size       = UDim2.new(0, 680, 0, 440),
    Position   = UDim2.new(0.5, -340, 0.5, -220),
  })

TAB CREATION:
  local tab = win:MakeTab({
    Title = "Main",
    Image = "rbxassetid://...",  -- опционально
  })

ELEMENTS:
  tab:MakeButton({ Name="", Callback=fn })
  tab:MakeToggle({ Name="", Default=false, Callback=fn })
  tab:MakeSlider({ Name="", Min=0, Max=100, Default=50, Callback=fn })
  tab:MakeDropdown({ Name="", Options={}, Default="", Callback=fn })
  tab:MakeMultiDropdown({ Name="", Options={}, Default={}, Callback=fn })
  tab:MakeKeybind({ Name="", Default=Enum.KeyCode.E, Callback=fn })
  tab:MakeTextbox({ Name="", Default="", Placeholder="", Callback=fn })
  tab:MakeColorPicker({ Name="", Default=Color3.new(1,0,0), Callback=fn })
  tab:MakeLabel({ Name="", Color=COLORS.SubText, TextSize=12 })
  tab:MakeParagraph({ Title="", Text="" })
  tab:MakeSeparator()
  tab:MakeSection({ Name="" })
  tab:MakeInput(config)  -- алиас MakeTextbox

WINDOW METHODS:
  win:Notify({ Title="", Content="", Duration=4 })
  win:Minimize()            -- свернуть/развернуть
  win:Toggle()              -- показать/скрыть
  win:Show() / win:Hide()
  win:SetAccent(Color3)     -- поменять акцентный цвет
  win:SetToggleKey(KeyCode) -- поменять кнопку показа/скрытия
  win:SetWindowSize(w, h)   -- изменить размер окна
  win:SetWindowPosition(x, y)
  win:SetTabWidth(w)        -- ширина панели табов
  win:GetTabs()             -- список всех табов
  win:GetVersion()          -- "2.0.0"
  win:_InitBuiltinTabs()    -- добавить Credits + Settings вкладки
  win:Destroy()             -- удалить UI

BUILT-IN TABS:
  win:_InitBuiltinTabs()
  -- Добавляет Credits и Settings вкладки автоматически.
  -- Settings содержит: Toggle Key, Accent Color.
  -- Credits содержит: описание, список элементов, управление.

THEMING:
  win:SetAccent(Color3.fromRGB(220, 80, 120))  -- розовый (default)
  win:SetAccent(Color3.fromRGB(96, 205, 255))  -- голубой (Fluent)
  win:SetAccent(Color3.fromRGB(97, 62, 167))   -- фиолетовый

TOGGLE KEY:
  По умолчанию RightShift. Можно сменить:
  win:SetToggleKey(Enum.KeyCode.Insert)
  -- или через Settings вкладку

]]
-- ═══════════════════════════════════════════════════════════
-- MakeProgressBar usage:
--   local bar = tab:MakeProgressBar({ Name="Loading", Default=0 })
--   bar:SetValue(75)   -- устанавливает 75%
--   bar:GetValue()     -- возвращает текущее значение
-- ═══════════════════════════════════════════════════════════