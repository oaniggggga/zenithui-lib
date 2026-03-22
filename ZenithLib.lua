--[[
	ZenithLib - Modular UI Library for Roblox
	Version 2.1.0
	Created for Roblox Luau
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- ═══════════════════════════════════════════════════════════
-- Lucide Icons Integration
-- Thanks to Latte Softworks / SiriusSoftwareLtd
-- ═══════════════════════════════════════════════════════════
local Icons = nil
local _iconsLoaded = false

local function _loadIcons()
	if _iconsLoaded then return end
	_iconsLoaded = true
	local ok, result = pcall(function()
		return loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"
		))()
	end)
	if ok and result then
		Icons = result
		print("[ZenithLib] Lucide icons loaded ✓")
	else
		warn("[ZenithLib] Lucide icons failed to load:", result)
	end
end

-- Загружаем иконки асинхронно
task.spawn(_loadIcons)

-- Получить данные иконки по имени (Lucide name)
local function getIcon(name)
	if not Icons then return nil end
	name = string.match(string.lower(tostring(name)), "^%s*(.-)%s*$")
	local sizedIcons = Icons["48px"]
	if not sizedIcons then return nil end
	local r = sizedIcons[name]
	if not r then return nil end
	if type(r[1]) ~= "number" then return nil end
	return {
		id              = r[1],
		imageRectSize   = Vector2.new(r[2][1], r[2][2]),
		imageRectOffset = Vector2.new(r[3][1], r[3][2]),
	}
end

-- Применить иконку к ImageLabel/ImageButton
local function applyIcon(imageObj, name)
	if type(name) == "number" then
		-- Числовой asset id
		imageObj.Image           = "rbxassetid://" .. name
		imageObj.ImageRectSize   = Vector2.new(0, 0)
		imageObj.ImageRectOffset = Vector2.new(0, 0)
		return true
	elseif type(name) == "string" and name ~= "" then
		local icon = getIcon(name)
		if icon then
			imageObj.Image           = "rbxassetid://" .. icon.id
			imageObj.ImageRectSize   = icon.imageRectSize
			imageObj.ImageRectOffset = icon.imageRectOffset
			return true
		else
			-- Иконки ещё грузятся — пробуем позже
			task.delay(2, function()
				local retried = getIcon(name)
				if retried and imageObj.Parent then
					imageObj.Image           = "rbxassetid://" .. retried.id
					imageObj.ImageRectSize   = retried.imageRectSize
					imageObj.ImageRectOffset = retried.imageRectOffset
				end
			end)
			return false
		end
	end
	return false
end



-- HEX утилиты (совместимость с executor'ами без Color3:ToHex)
local function color3ToHex(col)
	return string.format("%02X%02X%02X",
		math.floor(col.R * 255),
		math.floor(col.G * 255),
		math.floor(col.B * 255)
	)
end

local function hexToColor3(hex)
	hex = hex:gsub("#", "")
	if #hex ~= 6 then return nil end
	local r = tonumber(hex:sub(1,2), 16)
	local g = tonumber(hex:sub(3,4), 16)
	local b = tonumber(hex:sub(5,6), 16)
	if not r or not g or not b then return nil end
	return Color3.fromRGB(r, g, b)
end

-- Utility Functions
print("[ZenithLib] v2.1.0 loaded OK")
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

local function TweenBack(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		props
	):Play()
end

local function TweenElastic(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		props
	):Play()
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
-- ┌─────────────────────────────────────────────────────────┐
-- │  ZenithLib — Obsidian Ember Theme                       │
-- │  Тёмный как обсидиан фон + раскалённый янтарный акцент  │
-- └─────────────────────────────────────────────────────────┘
local COLORS = {
	-- ── Base: Obsidian ───────────────────────────────────────
	--  Почти чёрный с едва заметным тёплым угольным тоном.
	--  Даёт ощущение глубины без резкого холодного чёрного.
	MainBackground   = Color3.fromRGB(10,   9,   8),   -- обсидиан
	DarkerBackground = Color3.fromRGB(6,    5,   4),   -- глубже — для TabNav / TitleBar
	InputBackground  = Color3.fromRGB(18,  16,  14),   -- фон элементов — чуть теплее
	DropdownHolder   = Color3.fromRGB(13,  11,   9),   -- фон списков дропдауна

	-- ── Accent: Ember (раскалённый янтарь) ──────────────────
	--  Не просто оранжевый — это цвет раскалённого металла,
	--  горячий и насыщенный, но не кричащий.
	Accent           = Color3.fromRGB(255, 150,  40),  -- ember / раскалённый янтарь
	AccentText       = Color3.fromRGB(255, 205, 130),  -- мягкий золотисто-кремовый
	AccentDim        = Color3.fromRGB(55,  32,   8),   -- тёмный ember для hover/pressed

	-- ── Text ──────────────────────────────────────────────────
	--  Тёплый белый — не чистый #FFFFFF (слишком резкий),
	--  а слоновая кость с лёгким золотым подтоном.
	Text             = Color3.fromRGB(242, 236, 226),  -- ivory white
	SubText          = Color3.fromRGB(118, 110,  96),  -- тёплый серо-золотой

	-- ── Borders & Rails ──────────────────────────────────────
	--  Тонкие, чуть теплее фона — не контрастные, но заметные.
	ElementBorder    = Color3.fromRGB(48,  38,  22),   -- тёмно-янтарный бордер
	InElementBorder  = Color3.fromRGB(48,  38,  22),
	SliderRail       = Color3.fromRGB(30,  24,  14),   -- трек слайдера
	TitleBarLine     = Color3.fromRGB(70,  50,  18),   -- линия под тайтлбаром

	-- ── Tab States ────────────────────────────────────────────
	ActiveTab        = Color3.fromRGB(28,  20,   8),   -- фон активного таба
	EL_HOVER         = Color3.fromRGB(24,  20,  14),   -- hover на элементах

	-- ── Window Controls (macOS style) ────────────────────────
	CloseRed         = Color3.fromRGB(255,  95,  87),
	MaximizeYellow   = Color3.fromRGB(254, 188,  46),
	MinimizeGreen    = Color3.fromRGB(40,  200,  64),
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
	
	local Title      = config.Title      or "ZenithLib"
	local Author     = config.Author     or nil
	local ConfigName = config.ConfigName or "Default"
	self._configName = ConfigName
	self._cfgPath    = nil
	self._cfgRegistry = {}
	-- Устанавливаем путь для конфигов
	_configPath = "ZenithLib/" .. ConfigName .. "/"
	pcall(makefolder, "ZenithLib")
	pcall(makefolder, _configPath)
	
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

	-- Появление окна снизу вверх
	self.MainFrame.BackgroundTransparency = 1
	self.MainFrame.Position = UDim2.new(windowPos.X.Scale, windowPos.X.Offset, windowPos.Y.Scale, windowPos.Y.Offset + 24)
	task.defer(function()
		Tween(self.MainFrame, { BackgroundTransparency = 0, Position = windowPos }, 0.38, Enum.EasingStyle.Back)
	end)
	
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
		Position = UDim2.new(1, -96, 0, 0),
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
	
	self.TabFrames  = {}
	self.CurrentTab = nil
	self._tabIndex  = 0   -- счётчик для LayoutOrder
	
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
	
	-- Индекс таба для LayoutOrder
	win._tabIndex = (win._tabIndex or 0) + 1
	local _tabOrder = config.LayoutOrder or win._tabIndex

	-- Create Tab Button
	local tabButton = CreateInstance("TextButton", {
		Name = "Tab_" .. Title,
		Size = UDim2.new(1, -10, 0, 34),
		BackgroundColor3 = COLORS.InputBackground,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = _tabOrder,
	})
	
	local tabCorner = CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) })
	tabCorner.Parent = tabButton
	
	CreateInstance("UIPadding", { PaddingLeft = UDim.new(0, 10) }).Parent = tabButton
	
	local tabImage = nil
	if Image and Image ~= "" then
		tabImage = CreateInstance("ImageLabel", {
			Name = "TabIcon",
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 0, 0.5, -8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://0",
			ImageColor3 = Color3.fromRGB(150, 140, 125),
		})
		applyIcon(tabImage, Image)
		tabImage.Parent = tabButton
	end

	local textOffset = (Image and Image ~= "") and 22 or 0
	local tabText = CreateInstance("TextLabel", {
		Size = UDim2.new(1, -textOffset, 1, 0),
		Position = UDim2.new(0, textOffset, 0, 0),
		BackgroundTransparency = 1,
		Text = Title,
		TextColor3 = Color3.fromRGB(220, 215, 218),
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
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageTransparency = 1,
	})

	local contentList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	contentList.Parent = tabContent

	contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 14)
	end)

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
		-- Fade out текущего таба
		for _, frame in pairs(win.TabFrames) do
			if frame.Visible then
				task.delay(0.08, function()
					frame.Visible = false
				end)
			end
		end
		task.delay(0.08, function()
			tabContent.Visible = true
			tabContent.Position = UDim2.new(0, 8, 0, 0)
			Tween(tabContent, { Position = UDim2.new(0, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quint)
		end)
		win.CurrentTab = Title
		
		-- Update button appearance — только Frame с именем Tab_*
		local tabContainer = win._tabScroll or win.TabNav
		for _, button in ipairs(tabContainer:GetChildren()) do
			if (button:IsA("Frame") or button:IsA("TextButton")) and button.Name:sub(1,4) == "Tab_" then
				button.BackgroundColor3 = COLORS.InputBackground
				button.BackgroundTransparency = 1
				local txt = button:FindFirstChildWhichIsA("TextLabel")
				if txt then txt.TextColor3 = Color3.fromRGB(150, 140, 145); txt.TextSize = 12 end
				local ico = button:FindFirstChild("TabIcon")
				if ico then ico.ImageColor3 = Color3.fromRGB(130, 120, 125) end
			end
		end
		print("[ZenithLib] Tween tabButton")
		Tween(tabButton, { BackgroundColor3 = COLORS.ActiveTab, BackgroundTransparency = 0 }, 0.15)
		Tween(tabText, { TextColor3 = COLORS.AccentText, TextSize = 13 }, 0.15)
		if tabImage then
			Tween(tabImage, { ImageColor3 = COLORS.AccentText }, 0.15)
		end
	end
	
	print("[ZenithLib] Connecting MouseButton1Click for tab:", Title)
	local tabScale = CreateInstance("UIScale", { Scale = 1 })
	tabScale.Parent = tabButton

	tabButton.MouseButton1Click:Connect(function()
		TweenService:Create(tabScale, TweenInfo.new(0.08, Enum.EasingStyle.Quint), { Scale = 0.95 }):Play()
		task.delay(0.08, function()
			TweenBack(tabScale, { Scale = 1 }, 0.25)
		end)
		SelectTab()
	end)

	tabButton.MouseEnter:Connect(function()
		if win.CurrentTab ~= Title then
			Tween(tabButton, { BackgroundColor3 = COLORS.InputBackground, BackgroundTransparency = 0.4 }, 0.12)
		end
	end)

	tabButton.MouseLeave:Connect(function()
		if win.CurrentTab ~= Title then
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
		local Name     = config.Name     or "Button"
		local Icon     = config.Icon     or nil
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
		
		-- Иконка кнопки (опционально)
		if Icon then
			local btnIcon = CreateInstance("ImageLabel", {
				Name = "BtnIcon",
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 12, 0.5, -8),
				BackgroundTransparency = 1,
				Image = "rbxassetid://0",
				ImageColor3 = COLORS.AccentText,
				ZIndex = 2,
			})
			applyIcon(btnIcon, Icon)
			btnIcon.Parent = buttonFrame
		end

		local iconOffset = Icon and 34 or 0
		local buttonText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -iconOffset - 12, 1, 0),
			Position = UDim2.new(0, iconOffset + 12, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.AccentText,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		buttonText.Parent = buttonFrame
		
		local buttonHitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
		})
		buttonHitbox.Parent = buttonFrame
		
		local btnScale = CreateInstance("UIScale", { Scale = 1 })
		btnScale.Parent = buttonFrame

		buttonHitbox.MouseButton1Down:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.Accent }, 0.08)
			TweenService:Create(btnScale, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 0.96 }):Play()
		end)

		buttonHitbox.MouseButton1Up:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.InputBackground }, 0.2)
			TweenBack(btnScale, { Scale = 1 }, 0.3)
			Callback()
		end)

		buttonHitbox.MouseEnter:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.AccentDim }, 0.15)
			TweenService:Create(btnScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.02 }):Play()
		end)

		buttonHitbox.MouseLeave:Connect(function()
			Tween(buttonFrame, { BackgroundColor3 = COLORS.InputBackground }, 0.15)
			TweenService:Create(btnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end)
		
		buttonFrame.Parent = tabContent
		return buttonFrame
	end
	
	function Tab:MakeToggle(config)
	print("[ZenithLib] >> Tab:MakeToggle() name=", config and (config.Name or config.Title) or "?")
		local Name     = config.Name     or "Toggle"
		local Icon     = config.Icon     or nil
		local Default  = config.Default  or false
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
		
		if Icon then
			local togIcon = CreateInstance("ImageLabel", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 10, 0.5, -8),
				BackgroundTransparency = 1,
				Image = "rbxassetid://0",
				ImageColor3 = COLORS.SubText,
			})
			applyIcon(togIcon, Icon)
			togIcon.Parent = toggleFrame
		end
		local iconOff = Icon and 30 or 0
		local toggleText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -60 - iconOff, 1, 0),
			Position = UDim2.new(0, 10 + iconOff, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 13,
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
				Tween(toggleSwitch, { BackgroundColor3 = COLORS.Accent }, 0.2)
				-- Knob squeeze then spring to right
				TweenService:Create(toggleKnob, TweenInfo.new(0.08, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 10, 0, 10) }):Play()
				task.delay(0.08, function()
					TweenService:Create(toggleKnob, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Position = UDim2.new(1, -18, 0.5, -7),
						Size = UDim2.new(0, 14, 0, 14),
					}):Play()
				end)
				Tween(toggleText, { TextColor3 = COLORS.AccentText }, 0.18)
			else
				Tween(toggleSwitch, { BackgroundColor3 = Color3.fromRGB(50, 50, 50) }, 0.2)
				TweenService:Create(toggleKnob, TweenInfo.new(0.08, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 10, 0, 10) }):Play()
				task.delay(0.08, function()
					TweenService:Create(toggleKnob, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, 4, 0.5, -7),
						Size = UDim2.new(0, 14, 0, 14),
					}):Play()
				end)
				Tween(toggleText, { TextColor3 = COLORS.Text }, 0.18)
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

		-- Config registration
		if config.ConfigKey then
			win:_RegisterCfgItem(config.ConfigKey,
				function() return isOn end,
				function(v) isOn = v == true; UpdateToggle() end,
				"bool"
			)
		end
		
		-- Регистрируем в конфиге
		_registerConfigItem("toggle_" .. Name,
			function() return isOn end,
			function(v)
				if type(v) == "boolean" then
					isOn = not isOn  -- сбрасываем в противоположное чтобы UpdateToggle правильно сработал
					if v ~= isOn then isOn = v end
					isOn = v
					UpdateToggle()
				end
			end,
			"boolean"
		)
		toggleFrame.Parent = tabContent
		return toggleFrame
	end
	
	function Tab:MakeSlider(config)
	print("[ZenithLib] >> Tab:MakeSlider() name=", config and (config.Name or config.Title) or "?")
		local Icon = config.Icon or nil
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
		
		if Icon then
			local sldIcon = CreateInstance("ImageLabel", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(0, 10, 0, 9),
				BackgroundTransparency = 1,
				Image = "rbxassetid://0",
				ImageColor3 = COLORS.SubText,
			})
			applyIcon(sldIcon, Icon)
			sldIcon.Parent = sliderFrame
		end
		local sldOff = Icon and 26 or 0
		local sliderText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -60 - sldOff, 0, 20),
			Position = UDim2.new(0, 10 + sldOff, 0, 6),
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
			Tween(sliderFill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.05)
			Tween(sliderKnob, { Position = UDim2.new(percent, -7, 0.5, -7) }, 0.05)
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
			TweenService:Create(sliderKnob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 16, 0, 16) }):Play()
		end)

		sliderHitbox.MouseButton1Up:Connect(function()
			isDragging = false
			TweenService:Create(sliderKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 12, 0, 12) }):Play()
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
		
		-- Config registration
		local _sliderVal = Default
		local _origUpdate = UpdateSlider
		UpdateSlider = function(value)
			_sliderVal = value
			_origUpdate(value)
		end
		if config.ConfigKey then
			win:_RegisterCfgItem(config.ConfigKey,
				function() return _sliderVal end,
				function(v)
					local n = tonumber(v)
					if n then UpdateSlider(math.clamp(n, Min, Max)) end
				end,
				"number"
			)
		end

		sliderFrame.Parent = tabContent
		return sliderFrame
	end
	

	function Tab:MakeDropdown(config)
	print("[ZenithLib] >> Tab:MakeDropdown() name=", config and (config.Name or config.Title) or "?")
		local Name     = config.Name    or "Dropdown"
		local DdIcon   = config.Image   or config.Icon or nil
		local Options  = config.Options or {}
		local Default  = config.Default or (Options[1] or "")
		local Callback = config.Callback or function() end

		local selected = Default
		local isOpen   = false

		-- Основной фрейм
		local frame = CreateInstance("Frame", {
			Name = "Dropdown_" .. Name,
			Size = UDim2.new(1, 0, 0, 38),
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

		if DdIcon then
			local ddIco = CreateInstance("ImageLabel", {
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new(0, 10, 0.5, -7),
				BackgroundTransparency = 1,
				Image = "",
				ImageColor3 = COLORS.SubText,
				ZIndex = 2,
			})
			applyIcon(ddIco, DdIcon)
			ddIco.Parent = frame
		end

		local ddTextX = DdIcon and 30 or 12
		local label = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, ddTextX, 0, 0),
			BackgroundTransparency = 1,
			Text = Name .. ":  " .. tostring(selected),
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		label.Parent = frame

		local arrow = CreateInstance("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -26, 0.5, -8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://16898612629",
			ImageRectSize   = Vector2.new(48, 48),
			ImageRectOffset = Vector2.new(967, 49),
			ImageColor3 = COLORS.SubText,
		})
		arrow.Parent = frame

		-- Список опций — прямо в ScreenGui поверх всего
		local listFrame = CreateInstance("Frame", {
			Name = "DropList_" .. Name,
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(10, 6, 8),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 300,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = listFrame
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.4,
			Color = COLORS.Accent,
		}).Parent = listFrame

		local listLayout = CreateInstance("UIListLayout", {
			Padding = UDim.new(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		listLayout.Parent = listFrame
		CreateInstance("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}).Parent = listFrame

		-- Строим опции
		for _, opt in ipairs(Options) do
			local btn = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = opt == selected and COLORS.ActiveTab or Color3.fromRGB(0,0,0),
				BackgroundTransparency = opt == selected and 0 or 1,
				BorderSizePixel = 0,
				Text = opt,
				TextColor3 = opt == selected and COLORS.AccentText or COLORS.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				AutoButtonColor = false,
				ZIndex = 301,
			})
			CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = btn

			btn.MouseEnter:Connect(function()
				if opt ~= selected then
					btn.BackgroundTransparency = 0.5
					btn.BackgroundColor3 = COLORS.InputBackground
				end
			end)
			btn.MouseLeave:Connect(function()
				if opt ~= selected then
					btn.BackgroundTransparency = 1
				end
			end)
			btn.MouseButton1Click:Connect(function()
				selected = opt
				label.Text = Name .. ":  " .. opt
				-- Сбрасываем все кнопки
				for _, child in ipairs(listFrame:GetChildren()) do
					if child:IsA("TextButton") then
						child.BackgroundTransparency = child.Text == opt and 0 or 1
						child.BackgroundColor3 = COLORS.ActiveTab
						child.TextColor3 = child.Text == opt and COLORS.AccentText or COLORS.Text
					end
				end
				isOpen = false
				listFrame.Visible = false
				arrow.Image = "rbxassetid://7733658504"
				Callback(opt)
			end)
			btn.Parent = listFrame
		end

		-- Функция открытия/закрытия
		local function openList()
			local absPos  = frame.AbsolutePosition
			local absSize = frame.AbsoluteSize
			local itemH   = 31
			local listH   = math.min(#Options, 8) * itemH + 8
			local screenH = workspace.CurrentCamera.ViewportSize.Y
			local yPos = absPos.Y + absSize.Y + 4
			if yPos + listH > screenH - 10 then
				yPos = absPos.Y - listH - 4
			end
			listFrame.Size     = UDim2.new(0, absSize.X, 0, 0)
			listFrame.Position = UDim2.new(0, absPos.X, 0, yPos)
			listFrame.BackgroundTransparency = 1
			listFrame.Parent = win.ScreenGui
			listFrame.Visible = true
			Tween(arrow, { ImageRectOffset = Vector2.new(967, 355), ImageColor3 = COLORS.Accent }, 0.18)
			Tween(listFrame, { BackgroundTransparency = 0, Size = UDim2.new(0, absSize.X, 0, listH) }, 0.2)
		end

		local function closeList()
			isOpen = false
			Tween(arrow, { ImageRectOffset = Vector2.new(967, 49), ImageColor3 = COLORS.SubText }, 0.18)
			local w = listFrame.Size.X.Offset
			Tween(listFrame, { BackgroundTransparency = 1, Size = UDim2.new(0, w, 0, 0) }, 0.15)
			task.delay(0.16, function()
				listFrame.Visible = false
			end)
		end

		local hitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 2,
		})
		hitbox.Parent = frame
		hitbox.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			if isOpen then openList() else closeList() end
		end)

		-- Закрыть при клике вне (но не на самой кнопке)
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if not isOpen then return end
			local mp = UserInputService:GetMouseLocation()
			-- Проверяем клик вне listFrame И вне frame
			local lp, ls = listFrame.AbsolutePosition, listFrame.AbsoluteSize
			local fp, fs = frame.AbsolutePosition, frame.AbsoluteSize
			local inList  = mp.X >= lp.X and mp.X <= lp.X+ls.X and mp.Y >= lp.Y and mp.Y <= lp.Y+ls.Y
			local inFrame = mp.X >= fp.X and mp.X <= fp.X+fs.X and mp.Y >= fp.Y and mp.Y <= fp.Y+fs.Y
			if not inList and not inFrame then
				closeList()
			end
		end)

		frame.Parent = tabContent
		local obj = {}
		function obj:SetValue(v)
			selected = v
			label.Text = Name .. ":  " .. v
		end
		function obj:GetValue() return selected end
		return obj
	end

	function Tab:MakeMultiDropdown(config)
	print("[ZenithLib] >> Tab:MakeMultiDropdown() name=", config and (config.Name or config.Title) or "?")
		local Name     = config.Name    or "MultiDropdown"
		local Options  = config.Options or {}
		local Default  = config.Default or {}
		local Callback = config.Callback or function() end

		local selected = {}
		for _, v in ipairs(Default) do selected[v] = true end

		local isOpen = false

		local function countSelected()
			local n = 0
			for _ in pairs(selected) do n = n + 1 end
			return n
		end

		local function getDisplayText()
			local n = countSelected()
			if n == 0 then return Name .. ":  None" end
			local parts = {}
			for k in pairs(selected) do table.insert(parts, k) end
			table.sort(parts)
			if n <= 2 then
				return Name .. ":  " .. table.concat(parts, ", ")
			end
			return Name .. ":  " .. parts[1] .. ", +" .. (n-1)
		end

		local frame = CreateInstance("Frame", {
			Name = "MultiDD_" .. Name,
			Size = UDim2.new(1, 0, 0, 38),
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

		local label = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text = getDisplayText(),
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		label.Parent = frame

		local arrow = CreateInstance("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -26, 0.5, -8),
			BackgroundTransparency = 1,
			Image = "rbxassetid://16898612629",
			ImageRectSize   = Vector2.new(48, 48),
			ImageRectOffset = Vector2.new(967, 49),
			ImageColor3 = COLORS.SubText,
		})
		arrow.Parent = frame

		local listFrame = CreateInstance("Frame", {
			Name = "MultiDDList_" .. Name,
			BackgroundColor3 = Color3.fromRGB(10, 6, 8),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 300,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = listFrame
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.4,
			Color = COLORS.Accent,
		}).Parent = listFrame
		local listLayout = CreateInstance("UIListLayout", {
			Padding = UDim.new(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		listLayout.Parent = listFrame
		CreateInstance("UIPadding", {
			PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
		}).Parent = listFrame

		local btnRefs = {}

		local function refreshBtn(btn, opt)
			local on = selected[opt] == true
			btn.BackgroundTransparency = on and 0 or 1
			btn.BackgroundColor3 = COLORS.ActiveTab
			btn.TextColor3 = on and COLORS.AccentText or COLORS.Text
		end

		for _, opt in ipairs(Options) do
			local btn = CreateInstance("TextButton", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = COLORS.ActiveTab,
				BackgroundTransparency = selected[opt] and 0 or 1,
				BorderSizePixel = 0,
				Text = opt,
				TextColor3 = selected[opt] and COLORS.AccentText or COLORS.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				AutoButtonColor = false,
				ZIndex = 301,
			})
			CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = btn
			btn.MouseEnter:Connect(function()
				if not selected[opt] then
					btn.BackgroundTransparency = 0.5
					btn.BackgroundColor3 = COLORS.InputBackground
				end
			end)
			btn.MouseLeave:Connect(function()
				refreshBtn(btn, opt)
			end)
			btn.MouseButton1Click:Connect(function()
				selected[opt] = not selected[opt] or nil
				refreshBtn(btn, opt)
				label.Text = getDisplayText()
				local res = {}
				for k in pairs(selected) do table.insert(res, k) end
				Callback(res)
			end)
			btn.Parent = listFrame
			btnRefs[opt] = btn
		end

		local function openList()
			local absPos  = frame.AbsolutePosition
			local absSize = frame.AbsoluteSize
			local itemH   = 31
			local listH   = math.min(#Options, 8) * itemH + 8
			local screenH = workspace.CurrentCamera.ViewportSize.Y
			local yPos = absPos.Y + absSize.Y + 4
			if yPos + listH > screenH - 10 then
				yPos = absPos.Y - listH - 4
			end
			listFrame.Size     = UDim2.new(0, absSize.X, 0, 0)
			listFrame.Position = UDim2.new(0, absPos.X, 0, yPos)
			listFrame.BackgroundTransparency = 1
			listFrame.Parent = win.ScreenGui
			listFrame.Visible = true
			Tween(arrow, { ImageRectOffset = Vector2.new(967, 355), ImageColor3 = COLORS.Accent }, 0.18)
			Tween(listFrame, { BackgroundTransparency = 0, Size = UDim2.new(0, absSize.X, 0, listH) }, 0.2)
		end

		local function closeList()
			isOpen = false
			Tween(arrow, { ImageRectOffset = Vector2.new(967, 49), ImageColor3 = COLORS.SubText }, 0.18)
			local w = listFrame.Size.X.Offset
			Tween(listFrame, { BackgroundTransparency = 1, Size = UDim2.new(0, w, 0, 0) }, 0.15)
			task.delay(0.16, function()
				listFrame.Visible = false
			end)
		end

		local hitbox = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, Text = "", ZIndex = 2,
		})
		hitbox.Parent = frame
		hitbox.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			if isOpen then openList() else closeList() end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if not isOpen then return end
			local mp = UserInputService:GetMouseLocation()
			local lp, ls = listFrame.AbsolutePosition, listFrame.AbsoluteSize
			local fp, fs = frame.AbsolutePosition, frame.AbsoluteSize
			local inList  = mp.X >= lp.X and mp.X <= lp.X+ls.X and mp.Y >= lp.Y and mp.Y <= lp.Y+ls.Y
			local inFrame = mp.X >= fp.X and mp.X <= fp.X+fs.X and mp.Y >= fp.Y and mp.Y <= fp.Y+fs.Y
			if not inList and not inFrame then
				closeList()
			end
		end)

		frame.Parent = tabContent
		local obj = {}
		function obj:SetValue(tbl)
			selected = {}
			for _, v in ipairs(tbl) do selected[v] = true end
			for opt, btn in pairs(btnRefs) do refreshBtn(btn, opt) end
			label.Text = getDisplayText()
		end
		function obj:GetValue()
			local res = {}
			for k in pairs(selected) do table.insert(res, k) end
			return res
		end
		return obj
	end


	function Tab:MakeKeybind(config)
	print("[ZenithLib] >> Tab:MakeKeybind() name=", config and (config.Name or config.Title) or "?")
		local Name     = config.Name     or "Keybind"
		local KbIcon   = config.Image    or config.Icon or nil
		local Default  = config.Default  or Enum.KeyCode.Unknown
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
		
		if KbIcon then
			local kbIco = CreateInstance("ImageLabel", {
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new(0, 10, 0.5, -7),
				BackgroundTransparency = 1,
				Image = "",
				ImageColor3 = COLORS.SubText,
				ZIndex = 2,
			})
			applyIcon(kbIco, KbIcon)
			kbIco.Parent = keybindFrame
		end

		local kbTextX = KbIcon and 30 or 10
		local keybindText = CreateInstance("TextLabel", {
			Size = UDim2.new(1, -100, 1, 0),
			Position = UDim2.new(0, kbTextX, 0, 0),
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
		
		local kbScale = CreateInstance("UIScale", { Scale = 1 })
		kbScale.Parent = keybindButton

		keyHitbox.MouseButton1Click:Connect(function()
			isListening = true
			keyText.Text = "..."
			Tween(keybindButton, { BackgroundColor3 = COLORS.Accent }, 0.15)
			TweenElastic(kbScale, { Scale = 1.08 }, 0.4)
			task.delay(0.4, function()
				Tween(kbScale, { Scale = 1 }, 0.2)
			end)
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
		
		if config.ConfigKey then
			win:_RegisterCfgItem(config.ConfigKey,
				function() return tostring(currentKey):gsub("Enum.KeyCode.", "") end,
				function(v)
					local ok, key = pcall(function() return Enum.KeyCode[tostring(v)] end)
					if ok and key then currentKey = key; UpdateKeyText() end
				end,
				"keybind"
			)
		end

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
		local Name     = config.Name    or "Color"
		local Default  = config.Default or Color3.fromRGB(220, 80, 120)
		local Callback = config.Callback or function() end

		-- Внутренние HSV состояние
		local h, s, v = Color3.toHSV(Default)
		local currentColor = Default
		local pickerOpen = false

		-- ── Основная строка (как другие элементы) ──
		local row = CreateInstance("Frame", {
			Name = "ColorPicker_" .. Name,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = COLORS.InputBackground,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.5,
			Color = COLORS.ElementBorder,
		}).Parent = row

		CreateInstance("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text = Name,
			TextColor3 = COLORS.Text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		}).Parent = row

		-- Preview цвет
		local preview = CreateInstance("Frame", {
			Size = UDim2.new(0, 22, 0, 22),
			Position = UDim2.new(1, -36, 0.5, -11),
			BackgroundColor3 = Default,
			BorderSizePixel = 0,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = preview
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1, Transparency = 0.4,
			Color = Color3.fromRGB(255,255,255),
		}).Parent = preview
		preview.Parent = row

		-- ── Палитра (рендерится в ScreenGui поверх всего) ──
		local palette = CreateInstance("Frame", {
			Name = "Palette_" .. Name,
			Size = UDim2.new(0, 260, 0, 260),
			BackgroundColor3 = Color3.fromRGB(10, 6, 8),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 400,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 10) }).Parent = palette
		CreateInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 0.5, Transparency = 0.35,
			Color = COLORS.Accent,
		}).Parent = palette

		-- SV квадрат (Saturation-Value)
		local svFrame = CreateInstance("ImageLabel", {
			Name = "SVSquare",
			Size = UDim2.new(1, -20, 0, 160),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			BorderSizePixel = 0,
			Image = "rbxassetid://4155801252", -- S-V gradient overlay
			ZIndex = 401,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = svFrame
		svFrame.Parent = palette

		-- SV курсор
		local svCursor = CreateInstance("Frame", {
			Size = UDim2.new(0, 12, 0, 12),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(s, 0, 1 - v, 0),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BorderSizePixel = 0,
			ZIndex = 403,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = svCursor
		CreateInstance("UIStroke", {
			Thickness = 2, Transparency = 0.3,
			Color = Color3.fromRGB(0,0,0),
		}).Parent = svCursor
		svCursor.Parent = svFrame

		-- Hue полоска
		local hueBar = CreateInstance("ImageLabel", {
			Name = "HueBar",
			Size = UDim2.new(1, -20, 0, 14),
			Position = UDim2.new(0, 10, 0, 178),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BorderSizePixel = 0,
			Image = "rbxassetid://698052001", -- hue gradient
			ZIndex = 401,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 4) }).Parent = hueBar
		hueBar.Parent = palette

		-- Hue курсор
		local hueCursor = CreateInstance("Frame", {
			Size = UDim2.new(0, 6, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(h, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BorderSizePixel = 0,
			ZIndex = 403,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = hueCursor
		CreateInstance("UIStroke", {
			Thickness = 1.5, Transparency = 0.2,
			Color = Color3.fromRGB(0,0,0),
		}).Parent = hueCursor
		hueCursor.Parent = hueBar

		-- HEX поле
		local hexBox = CreateInstance("TextBox", {
			Size = UDim2.new(0, 110, 0, 26),
			Position = UDim2.new(0, 10, 0, 200),
			BackgroundColor3 = Color3.fromRGB(18, 10, 14),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Text = "#" .. color3ToHex(Default),
			TextColor3 = COLORS.Text,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
			ClearTextOnFocus = false,
			ZIndex = 402,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = hexBox
		CreateInstance("UIStroke", {
			Thickness = 0.5, Transparency = 0.4,
			Color = COLORS.ElementBorder,
		}).Parent = hexBox
		hexBox.Parent = palette

		-- Preview большой
		local bigPreview = CreateInstance("Frame", {
			Size = UDim2.new(0, 52, 0, 26),
			Position = UDim2.new(1, -72, 0, 200),
			BackgroundColor3 = Default,
			BorderSizePixel = 0,
			ZIndex = 402,
		})
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = bigPreview
		CreateInstance("UIStroke", {
			Thickness = 0.5, Transparency = 0.4,
			Color = Color3.fromRGB(255,255,255),
		}).Parent = bigPreview
		bigPreview.Parent = palette

		-- Кнопка закрытия палитры
		local closeBtn = CreateInstance("TextButton", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, -28, 0, 8),
			BackgroundTransparency = 1,
			Text = "✕",
			TextColor3 = COLORS.SubText,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			ZIndex = 403,
		})
		closeBtn.Parent = palette

		-- ── Функция обновления ──
		local function applyColor()
			currentColor = Color3.fromHSV(h, s, v)
			Tween(preview, { BackgroundColor3 = currentColor }, 0.05)
			Tween(bigPreview, { BackgroundColor3 = currentColor }, 0.05)
			Tween(svFrame, { BackgroundColor3 = Color3.fromHSV(h, 1, 1) }, 0.05)
				hexBox.Text = "#" .. color3ToHex(currentColor)
			svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
			Callback(currentColor)
		end

		-- ── Drag на SV квадрате ──
		local svDragging = false
		local svHit = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, Text = "",
			ZIndex = 402,
		})
		svHit.Parent = svFrame

		svHit.MouseButton1Down:Connect(function()
			svDragging = true
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if svDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local ap = svFrame.AbsolutePosition
				local as = svFrame.AbsoluteSize
				local mp = UserInputService:GetMouseLocation()
				s = math.clamp((mp.X - ap.X) / as.X, 0, 1)
				v = math.clamp(1 - (mp.Y - ap.Y) / as.Y, 0, 1)
				applyColor()
			end
		end)

		-- ── Drag на Hue ──
		local hueDragging = false
		local hueHit = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, Text = "",
			ZIndex = 402,
		})
		hueHit.Parent = hueBar

		hueHit.MouseButton1Down:Connect(function()
			hueDragging = true
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if hueDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local ap = hueBar.AbsolutePosition
				local as = hueBar.AbsoluteSize
				local mp = UserInputService:GetMouseLocation()
				h = math.clamp((mp.X - ap.X) / as.X, 0, 1)
				applyColor()
			end
		end)

		-- ── HEX ввод ──
		hexBox.FocusLost:Connect(function()
			local hex = hexBox.Text:gsub("#","")
			local col = hexToColor3(hex)
			if col then
				h, s, v = Color3.toHSV(col)
				applyColor()
			else
				hexBox.Text = "#" .. color3ToHex(currentColor)
			end
		end)

		-- ── Открыть/закрыть палитру ──
		local function openPalette()
			palette.Parent = win.ScreenGui
			palette.BackgroundTransparency = 1
			palette.Visible = true
			task.defer(function()
				local ap = row.AbsolutePosition
				local as = row.AbsoluteSize
				local screenH = workspace.CurrentCamera.ViewportSize.Y
				local yPos = ap.Y + as.Y + 4
				if yPos + 260 > screenH - 10 then yPos = ap.Y - 264 end
				palette.Position = UDim2.new(0, ap.X, 0, yPos)
				Tween(palette, { BackgroundTransparency = 0 }, 0.18)
			end)
		end

		local function closePalette()
			pickerOpen = false
			Tween(palette, { BackgroundTransparency = 1 }, 0.15)
			task.delay(0.16, function() palette.Visible = false end)
		end

		local rowHit = CreateInstance("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, Text = "", ZIndex = 2,
		})
		rowHit.Parent = row
		rowHit.MouseButton1Click:Connect(function()
			pickerOpen = not pickerOpen
			if pickerOpen then openPalette() else closePalette() end
		end)

		closeBtn.MouseButton1Click:Connect(function()
			closePalette()
		end)

		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if not pickerOpen then return end
			local mp = UserInputService:GetMouseLocation()
			local pp, ps = palette.AbsolutePosition, palette.AbsoluteSize
			local rp, rs = row.AbsolutePosition, row.AbsoluteSize
			local inPalette = mp.X >= pp.X and mp.X <= pp.X+ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y+ps.Y
			local inRow    = mp.X >= rp.X and mp.X <= rp.X+rs.X and mp.Y >= rp.Y and mp.Y <= rp.Y+rs.Y
			if not inPalette and not inRow then
				closePalette()
			end
		end)

		row.Parent = tabContent

		local obj = {}
		function obj:SetValue(color)
			h, s, v = Color3.toHSV(color)
			applyColor()
		end
		function obj:GetValue() return currentColor end
		return obj
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
		local Name    = config.Name  or "Section"
		local SecIcon = config.Image or config.Icon or nil

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

		local secTextX = SecIcon and 20 or 4
		if SecIcon then
			local secIco = CreateInstance("ImageLabel", {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0, 2, 0.5, -6),
				BackgroundTransparency = 1,
				Image = "",
				ImageColor3 = COLORS.Accent,
			})
			applyIcon(secIco, SecIcon)
			secIco.Parent = headerRow
		end

		CreateInstance("TextLabel", {
			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.new(0, secTextX, 0, 0),
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
	local credTab = self:MakeTab({ Title = "Credits", Image = "info", LayoutOrder = 9998 })
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

	local setTab = self:MakeTab({ Title = "Settings", Image = "settings", LayoutOrder = 9999 })
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
		Size = UDim2.new(0, 260, 1, -16),
		Position = UDim2.new(1, -272, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 200,
		Parent = gui,
	})
	CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
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

	-- Карточка
	local card = CreateInstance("Frame", {
		Name = "Notif",
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = Color3.fromRGB(12, 7, 9),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(1, 10, 0, 0),
		ZIndex = 200,
		Parent = holder,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = card
	CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Transparency = 0.55,
		Color = COLORS.Accent,
	}).Parent = card

	-- Акцентный левый border
	local accent = CreateInstance("Frame", {
		Size = UDim2.new(0, 3, 0, 36),
		Position = UDim2.new(0, 0, 0.5, -18),
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		ZIndex = 201,
	})
	CreateInstance("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = accent
	accent.Parent = card

	-- Заголовок
	CreateInstance("TextLabel", {
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.new(0, 12, 0, 9),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = COLORS.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 201,
	}).Parent = card

	-- Контент
	CreateInstance("TextLabel", {
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.new(0, 12, 0, 31),
		BackgroundTransparency = 1,
		Text = content,
		TextColor3 = COLORS.SubText,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 201,
	}).Parent = card

	-- Таймер-линия снизу
	local timerBar = CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = COLORS.Accent,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		ZIndex = 201,
	})
	timerBar.Parent = card

	-- Slide in
	Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.25, Enum.EasingStyle.Quint)

	-- Таймер
	TweenService:Create(timerBar,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0, 0, 0, 2) }
	):Play()

	-- Dismiss
	task.delay(duration, function()
		if not card.Parent then return end
		Tween(card, { Position = UDim2.new(1, 10, 0, 0) }, 0.2, Enum.EasingStyle.Quint)
		task.delay(0.22, function()
			pcall(function() card:Destroy() end)
		end)
	end)

	return card
end


-- ═══════════════════════════════════════════════════════════
function ZenithLib:_RegisterCfgItem(key, getter, setter, itemType)
	self._cfgRegistry = self._cfgRegistry or {}
	self._cfgRegistry[key] = { get = getter, set = setter, type = itemType or "value" }
end

function ZenithLib:SaveConfig(name)
	self._cfgRegistry = self._cfgRegistry or {}
	name = name or self._cfgName or "default"
	local path = self._cfgPath or _getCfgPath(self._configName or "default")
	local data = {}
	for k, entry in pairs(self._cfgRegistry) do
		local ok, val = pcall(entry.get)
		if ok then
			if typeof(val) == "Color3" then val = color3ToHex(val) end
			data[k] = val
		end
	end
	_cfgWrite(path, name, data)
end

function ZenithLib:LoadConfig(name)
	self._cfgRegistry = self._cfgRegistry or {}
	name = name or self._cfgName or "default"
	local path = self._cfgPath or _getCfgPath(self._configName or "default")
	local data = _cfgRead(path, name)
	if not data then return false end
	for k, entry in pairs(self._cfgRegistry) do
		if data[k] ~= nil then
			local val = data[k]
			if entry.type == "color" and type(val) == "string" then
				local col = hexToColor3(val)
				if col then val = col end
			end
			pcall(entry.set, val)
		end
	end
	return true
end

function ZenithLib:MakeConfigTab(configName)
	configName = configName or self._configName or "default"
	self._cfgPath  = _getCfgPath(configName)
	self._cfgName  = "default"
	self._cfgRegistry = self._cfgRegistry or {}

	local tab = self:MakeTab({ Title = "Config", Image = "save", LayoutOrder = 9000 })

	tab:MakeSection({ Name = "Profiles" })

	local cfgList = _cfgList(self._cfgPath)
	if #cfgList == 0 then cfgList = { "default" } end

	local cfgDropdown = tab:MakeDropdown({
		Name    = "Profile",
		Options = cfgList,
		Default = cfgList[1],
		Callback = function(name) self._cfgName = name end,
	})

	tab:MakeTextbox({
		Name        = "New Profile Name",
		Placeholder = "my_config",
		Default     = "",
		Callback    = function(name)
			if name == "" then return end
			pcall(writefile, self._cfgPath .. name .. ".json", "{}")
			self:Notify({ Title = "Created", Content = "Profile: " .. name, Duration = 2 })
		end,
	})

	tab:MakeSeparator()
	tab:MakeSection({ Name = "Actions" })

	tab:MakeButton({
		Name = "Save Config",
		Icon = "save",
		Callback = function()
			self:SaveConfig()
			self:Notify({ Title = "Saved", Content = self._cfgName, Duration = 2 })
		end,
	})

	tab:MakeButton({
		Name = "Load Config",
		Icon = "folder-open",
		Callback = function()
			if self:LoadConfig() then
				self:Notify({ Title = "Loaded", Content = self._cfgName, Duration = 2 })
			else
				self:Notify({ Title = "Not Found", Content = self._cfgName, Duration = 2 })
			end
		end,
	})

	tab:MakeButton({
		Name = "Delete Profile",
		Icon = "trash-2",
		Callback = function()
			if self._cfgName == "default" then
				self:Notify({ Title = "Error", Content = "Cannot delete default", Duration = 2 })
				return
			end
			pcall(function() if delfile then delfile(self._cfgPath .. self._cfgName .. ".json") else warn("delfile not supported") end end)
			self:Notify({ Title = "Deleted", Content = self._cfgName, Duration = 2 })
		end,
	})

	tab:MakeSeparator()
	tab:MakeSection({ Name = "Auto Save" })

	local autoConn = nil
	local autoInterval = 30

	tab:MakeToggle({
		Name    = "Auto Save",
		Icon    = "refresh-cw",
		Default = false,
		Callback = function(state)
			if state then
				local last = tick()
				autoConn = game:GetService("RunService").Heartbeat:Connect(function()
					if tick() - last >= autoInterval then
						last = tick()
						self:SaveConfig()
					end
				end)
				self:Notify({ Title = "Auto Save", Content = "Every " .. autoInterval .. "s", Duration = 2 })
			else
				if autoConn then autoConn:Disconnect(); autoConn = nil end
			end
		end,
	})

	tab:MakeSlider({
		Name    = "Save Interval (sec)",
		Min     = 10,
		Max     = 300,
		Default = 30,
		Callback = function(v) autoInterval = v end,
	})

	-- Auto-load at start
	task.defer(function()
		if self:LoadConfig() then
			self:Notify({ Title = "Config", Content = "Auto-loaded: " .. self._cfgName, Duration = 3 })
		end
	end)

	return tab
end


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