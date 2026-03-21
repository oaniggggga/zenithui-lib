--[[
	ZenithLib - Modular UI Library for Roblox
	Version 2.0.0
	Black & Rose Theme
]]

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function New(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	if parent then inst.Parent = parent end
	return inst
end

local function Tween(obj, props, t, style)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		props
	):Play()
end

local function MakeDraggable(frame)
	local dragging, start, origin = false
	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			start  = i.Position
			origin = frame.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	local dragInput
	frame.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i == dragInput then
			local d = i.Position - start
			frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
end

-- ── Acrylic (Fluent-style Glass Part) ────────────────────────────────────────

local function MakeAcrylic(frame)
	local cam = workspace.CurrentCamera
	local vy  = cam.ViewportSize.Y
	local depth = math.clamp((vy - 0) * (56 - 8) / (2560 - 0) + 8, 8, 56)

	local part = New("Part", {
		Name        = "ZenithAcrylic",
		Color       = Color3.new(0,0,0),
		Material    = Enum.Material.Glass,
		Size        = Vector3.new(1,1,0),
		Anchored    = true,
		CanCollide  = false,
		Locked      = true,
		CastShadow  = false,
		Transparency = 0.98,
		Parent      = workspace,
	})
	New("SpecialMesh", { MeshType = Enum.MeshType.Brick, Offset = Vector3.new(0,0,-1e-6), Parent = part })

	local conns = {}
	local function update()
		if not frame or not frame.Parent then return end
		local p, s = frame.AbsolutePosition, frame.AbsoluteSize
		local function sw(x, y) local r = cam:ScreenPointToRay(x,y) return r.Origin + r.Direction*depth end
		local tl = sw(p.X,       p.Y)
		local tr = sw(p.X+s.X,   p.Y)
		local br = sw(p.X+s.X,   p.Y+s.Y)
		local cf = cam.CFrame
		part.CFrame = CFrame.fromMatrix((tl+br)/2, cf.XVector, cf.YVector, cf.ZVector)
		part.Mesh.Scale = Vector3.new((tr-tl).Magnitude, (tr-br).Magnitude, 0)
	end
	table.insert(conns, cam:GetPropertyChangedSignal("CFrame"):Connect(update))
	table.insert(conns, cam:GetPropertyChangedSignal("ViewportSize"):Connect(update))
	table.insert(conns, frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(update))
	table.insert(conns, frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
	frame.AncestryChanged:Connect(function()
		if not frame.Parent then
			for _,c in ipairs(conns) do pcall(c.Disconnect,c) end
			pcall(function() part:Destroy() end)
		end
	end)
	task.defer(update)
	return part
end

-- ── Selector spring (for tab indicator bar) ───────────────────────────────────

local function MakeSelectorSpring(bar)
	local posS  = {value=17, vel=0}
	local sizeS = {value=16, vel=0}
	local posT, sizeT = 17, 16
	local conn

	local function step(dt)
		local function sp(s, target, freq, damp)
			local f = freq*2*math.pi
			local k = s.value - target
			local e = math.exp(-damp*f*dt)
			local nv = (k*(1+f*dt)+s.vel*dt)*e + target
			local nvel = (s.vel*(1-f*dt)-k*f*f*dt)*e
			local done = math.abs(nvel)<0.3 and math.abs(nv-target)<0.3
			return {value=done and target or nv, vel=done and 0 or nvel, done=done}
		end
		posS  = sp(posS,  posT,  7, 1)
		sizeS = sp(sizeS, sizeT, 5, 0.7)
		bar.Position = UDim2.new(0, 0, 0, posS.value)
		bar.Size     = UDim2.new(0, 3, 0, sizeS.value)
		if posS.done and sizeS.done and conn then
			conn:Disconnect(); conn = nil
		end
	end

	local lastY, lastT = 17, tick()

	return function(tabRelY, tabH)
		local now = tick()
		local speed = math.abs(tabRelY - lastY) / math.max(now - lastT, 0.001)
		lastY, lastT = tabRelY, now

		posT  = tabRelY + tabH/2 - 8
		sizeT = math.clamp(16 + speed*0.05, 16, tabH*1.8)
		posS.done = false; sizeS.done = false

		if not conn then
			conn = RunService.RenderStepped:Connect(step)
		end
		task.delay(0.12, function()
			sizeT = 16
			sizeS.done = false
			if not conn then conn = RunService.RenderStepped:Connect(step) end
		end)
	end
end

-- ── Colors ───────────────────────────────────────────────────────────────────

local C = {
	BG           = Color3.fromRGB(8,   5,   7),
	BG2          = Color3.fromRGB(14,  8,  11),
	EL           = Color3.fromRGB(18,  10,  14),
	EL_HOVER     = Color3.fromRGB(32,  16,  24),
	BORDER       = Color3.fromRGB(55,  22,  35),
	ACCENT       = Color3.fromRGB(220, 80, 120),
	ACCENT_DIM   = Color3.fromRGB(90,  22,  48),
	ACCENT_TEXT  = Color3.fromRGB(255, 170, 195),
	TEXT         = Color3.fromRGB(238, 232, 235),
	SUBTEXT      = Color3.fromRGB(118, 100, 108),
	RAIL         = Color3.fromRGB(32,  12,  20),
	TAB_ACTIVE   = Color3.fromRGB(28,   6,  15),
	LINE         = Color3.fromRGB(75,  30,  48),
	RED          = Color3.fromRGB(255, 95,  87),
	YELLOW       = Color3.fromRGB(254, 188, 46),
	GREEN        = Color3.fromRGB(40,  200, 64),
}

-- ── Library ───────────────────────────────────────────────────────────────────

local ZenithLib = {}
ZenithLib.__index = ZenithLib

function ZenithLib:MakeWindow(cfg)
	local self   = setmetatable({}, ZenithLib)
	local title  = cfg.Title    or "ZenithLib"
	local name   = cfg.ConfigName or "Default"
	local wSize  = cfg.Size     or UDim2.new(0, 680, 0, 440)
	local wPos   = cfg.Position or UDim2.new(0.5, -340, 0.5, -220)

	-- ScreenGui
	self.Gui = New("ScreenGui", {
		Name           = "ZenithLib_"..name,
		IgnoreGuiInset = true,
		ResetOnSpawn   = false,
		DisplayOrder   = 100,
		Parent         = CoreGui,
	})

	-- Shadow
	New("ImageLabel", {
		Name               = "Shadow",
		Size               = UDim2.new(1, 48, 1, 48),
		Position           = UDim2.new(0.5, 0, 0.5, 8),
		AnchorPoint        = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image              = "rbxassetid://5273142107",
		ImageColor3        = Color3.fromRGB(180, 30, 70),
		ImageTransparency  = 0.82,
		ScaleType          = Enum.ScaleType.Slice,
		SliceCenter        = Rect.new(20, 20, 20, 20),
		Parent             = self.Gui,
	})

	-- Main frame
	self.Frame = New("Frame", {
		Name                  = "Main",
		Size                  = wSize,
		Position              = wPos,
		BackgroundColor3      = C.BG,
		BackgroundTransparency = 0,
		BorderSizePixel       = 0,
		ClipsDescendants      = true,
		Parent                = self.Gui,
	})
	New("UICorner", { CornerRadius = UDim.new(0,12), Parent = self.Frame })
	New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.ACCENT, Transparency = 0.5, Thickness = 1, Parent = self.Frame })

	-- Title bar
	local bar = New("Frame", {
		Size                  = UDim2.new(1,0,0,44),
		BackgroundColor3      = C.BG2,
		BackgroundTransparency = 0,
		BorderSizePixel       = 0,
		Parent                = self.Frame,
	})
	New("UICorner", { CornerRadius = UDim.new(0,12), Parent = bar })
	-- accent line
	New("Frame", {
		Size             = UDim2.new(1,-28,0,1),
		Position         = UDim2.new(0,14,1,-1),
		BackgroundColor3 = C.ACCENT,
		BackgroundTransparency = 0.3,
		BorderSizePixel  = 0,
		Parent           = bar,
	})
	-- traffic lights
	local dots = {C.RED, C.YELLOW, C.GREEN}
	for i, col in ipairs(dots) do
		local dot = New("Frame", {
			Size             = UDim2.new(0,12,0,12),
			Position         = UDim2.new(0, 14+(i-1)*20, 0.5, -6),
			BackgroundColor3 = col,
			BorderSizePixel  = 0,
			Parent           = bar,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = dot })
	end
	-- close button
	local closeBtn = New("TextButton", {
		Size = UDim2.new(0,12,0,12),
		Position = UDim2.new(0,14,0.5,-6),
		BackgroundTransparency = 1, Text = "", Parent = bar,
	})
	closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

	-- title text
	New("TextLabel", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = C.SUBTEXT,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		Parent = bar,
	})

	MakeDraggable(bar)

	-- Body
	local body = New("Frame", {
		Size = UDim2.new(1,0,1,-44),
		Position = UDim2.new(0,0,0,44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = self.Frame,
	})

	-- Tab nav
	local navW = cfg.TabWidth or 140
	local nav = New("Frame", {
		Size = UDim2.new(0, navW, 1, 0),
		BackgroundColor3 = C.BG2,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = body,
	})
	New("Frame", { -- right border
		Size = UDim2.new(0,1,1,0),
		Position = UDim2.new(1,-1,0,0),
		BackgroundColor3 = C.BORDER,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = nav,
	})
	local navList = New("UIListLayout", { Padding = UDim.new(0,3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = nav })
	New("UIPadding", { PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = nav })

	-- Selector bar
	local selBar = New("Frame", {
		Size = UDim2.new(0,3,0,0),
		Position = UDim2.new(0,0,0,17),
		BackgroundColor3 = C.ACCENT,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = nav,
	})
	New("UICorner", { CornerRadius = UDim.new(0,2), Parent = selBar })
	local moveSelector = MakeSelectorSpring(selBar)

	-- Content area
	local content = New("Frame", {
		Size = UDim2.new(1, -navW, 1, 0),
		Position = UDim2.new(0, navW, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = body,
	})

	self._tabs      = {}
	self._tabFrames = {}
	self._curTab    = nil
	self._nav       = nav
	self._content   = content
	self._moveSelector = moveSelector

	-- Acrylic
	task.defer(function()
		if self.Frame and self.Frame.Parent then
			self._acrylic = MakeAcrylic(self.Frame)
		end
	end)

	return self
end

function ZenithLib:MakeTab(cfg)
	local title = cfg.Title or "Tab"
	local idx   = #self._tabs + 1

	-- Tab button
	local btn = New("TextButton", {
		Size = UDim2.new(1,0,0,34),
		BackgroundColor3 = C.BG2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		LayoutOrder = idx,
		Parent = self._nav,
	})
	New("UICorner", { CornerRadius = UDim.new(0,7), Parent = btn })

	-- Icon
	if cfg.Icon then
		New("ImageLabel", {
			Size = UDim2.new(0,16,0,16),
			Position = UDim2.new(0,8,0.5,-8),
			BackgroundTransparency = 1,
			Image = cfg.Icon,
			ImageColor3 = C.SUBTEXT,
			Parent = btn,
		})
	end

	local lbl = New("TextLabel", {
		Size = UDim2.new(1,0,1,0),
		Position = cfg.Icon and UDim2.new(0,30,0,0) or UDim2.new(0,12,0,0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = C.SUBTEXT,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = btn,
	})

	-- Scroll frame for content
	local scroll = New("ScrollingFrame", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.ACCENT,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0,0,0,0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = self._content,
	})
	local list = New("UIListLayout", { Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
	New("UIPadding", { PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,12), PaddingBottom = UDim.new(0,10), Parent = scroll })
	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y + 20)
	end)

	self._tabs[idx]      = { btn = btn, lbl = lbl, scroll = scroll }
	self._tabFrames[idx] = scroll

	-- Click
	btn.MouseButton1Click:Connect(function()
		self:_selectTab(idx)
	end)

	-- Hover
	btn.MouseEnter:Connect(function()
		if self._curTab ~= idx then
			Tween(btn, { BackgroundTransparency = 0.6, BackgroundColor3 = C.EL_HOVER }, 0.15)
		end
	end)
	btn.MouseLeave:Connect(function()
		if self._curTab ~= idx then
			Tween(btn, { BackgroundTransparency = 1 }, 0.15)
		end
	end)

	-- Auto-select first tab
	if idx == 1 then
		task.defer(function() self:_selectTab(1) end)
	end

	-- Return Tab object
	local Tab = { _scroll = scroll, _lib = self }
	setmetatable(Tab, { __index = Tab })

	function Tab:MakeButton(c2)
		assert(c2.Title, "Button: missing Title")
		local cb = c2.Callback or function() end

		local el = New("Frame", {
			Size = UDim2.new(1,0,0,40),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.ACCENT, Transparency = 0.55, Thickness = 0.5, Parent = el })
		New("TextLabel", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Text = c2.Title,
			TextColor3 = C.ACCENT_TEXT,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			Parent = el,
		})
		local hit = New("TextButton", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Text = "", Parent = el,
		})
		hit.MouseEnter:Connect(function() Tween(el, { BackgroundColor3 = C.EL_HOVER }, 0.12) end)
		hit.MouseLeave:Connect(function() Tween(el, { BackgroundColor3 = C.EL }, 0.15) end)
		hit.MouseButton1Down:Connect(function() Tween(el, { BackgroundColor3 = C.ACCENT }, 0.1) end)
		hit.MouseButton1Up:Connect(function()
			Tween(el, { BackgroundColor3 = C.EL }, 0.2)
			cb()
		end)
		return el
	end

	function Tab:MakeToggle(c2)
		assert(c2.Title, "Toggle: missing Title")
		local cb      = c2.Callback or function() end
		local state   = c2.Default  or false

		local el = New("Frame", {
			Size = UDim2.new(1,0,0,40),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.4, Thickness = 0.5, Parent = el })

		local lbl2 = New("TextLabel", {
			Size = UDim2.new(1,-60,1,0),
			Position = UDim2.new(0,12,0,0),
			BackgroundTransparency = 1,
			Text = c2.Title,
			TextColor3 = state and C.ACCENT_TEXT or C.TEXT,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = el,
		})

		local track = New("Frame", {
			Size = UDim2.new(0,36,0,18),
			Position = UDim2.new(1,-48,0.5,-9),
			BackgroundColor3 = state and C.ACCENT or C.RAIL,
			BorderSizePixel = 0,
			Parent = el,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = track })
		local knob = New("Frame", {
			Size = UDim2.new(0,14,0,14),
			Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BorderSizePixel = 0,
			Parent = track,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })

		local hit = New("TextButton", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Text = "", Parent = el,
		})
		hit.MouseButton1Click:Connect(function()
			state = not state
			Tween(track, { BackgroundColor3 = state and C.ACCENT or C.RAIL }, 0.2)
			TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7) }
			):Play()
			Tween(lbl2, { TextColor3 = state and C.ACCENT_TEXT or C.TEXT }, 0.18)
			cb(state)
		end)

		local obj = { SetValue = function(_, v)
			state = v
			track.BackgroundColor3 = v and C.ACCENT or C.RAIL
			knob.Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
			lbl2.TextColor3 = v and C.ACCENT_TEXT or C.TEXT
		end }
		return obj
	end

	function Tab:MakeSlider(c2)
		assert(c2.Title,   "Slider: missing Title")
		assert(c2.Min   ~= nil, "Slider: missing Min")
		assert(c2.Max   ~= nil, "Slider: missing Max")
		assert(c2.Default ~= nil, "Slider: missing Default")
		local cb  = c2.Callback or function() end
		local min, max, val = c2.Min, c2.Max, c2.Default

		local el = New("Frame", {
			Size = UDim2.new(1,0,0,50),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.4, Thickness = 0.5, Parent = el })

		New("TextLabel", {
			Size = UDim2.new(1,-60,0,20),
			Position = UDim2.new(0,12,0,6),
			BackgroundTransparency = 1,
			Text = c2.Title,
			TextColor3 = C.TEXT,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = el,
		})
		local valLbl = New("TextLabel", {
			Size = UDim2.new(0,50,0,20),
			Position = UDim2.new(1,-62,0,6),
			BackgroundTransparency = 1,
			Text = tostring(val),
			TextColor3 = C.ACCENT_TEXT,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = el,
		})

		local rail = New("Frame", {
			Size = UDim2.new(1,-24,0,4),
			Position = UDim2.new(0,12,0,34),
			BackgroundColor3 = C.RAIL,
			BorderSizePixel = 0,
			Parent = el,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = rail })
		local fill = New("Frame", {
			Size = UDim2.new((val-min)/(max-min),0,1,0),
			BackgroundColor3 = C.ACCENT,
			BorderSizePixel = 0,
			Parent = rail,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })
		local knob = New("Frame", {
			Size = UDim2.new(0,12,0,12),
			Position = UDim2.new((val-min)/(max-min),-6,0.5,-6),
			BackgroundColor3 = C.ACCENT,
			BorderSizePixel = 0,
			Parent = rail,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })

		local function setVal(v)
			val = math.floor(math.clamp(v, min, max))
			local pct = (val-min)/(max-min)
			fill.Size = UDim2.new(pct,0,1,0)
			knob.Position = UDim2.new(pct,-6,0.5,-6)
			valLbl.Text = tostring(val)
			cb(val)
		end

		local drag = false
		local hit = New("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = el })
		hit.MouseButton1Down:Connect(function() drag = true end)
		hit.MouseButton1Up:Connect(function() drag = false end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if drag and (i.UserInputType == Enum.UserInputType.MouseMovement) then
				local rx = rail.AbsolutePosition.X
				local rw = rail.AbsoluteSize.X
				local pct = math.clamp((i.Position.X - rx) / rw, 0, 1)
				setVal(min + pct*(max-min))
			end
		end)

		local obj = { SetValue = function(_, v) setVal(v) end }
		return obj
	end

	function Tab:MakeDropdown(c2)
		assert(c2.Title, "Dropdown: missing Title")
		local cb      = c2.Callback or function() end
		local opts    = c2.Options  or {}
		local sel     = c2.Default  or opts[1] or ""
		local isOpen  = false

		local el = New("Frame", {
			Size = UDim2.new(1,0,0,40),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.4, Thickness = 0.5, Parent = el })

		local lbl2 = New("TextLabel", {
			Size = UDim2.new(1,-40,1,0),
			Position = UDim2.new(0,12,0,0),
			BackgroundTransparency = 1,
			Text = c2.Title..": "..tostring(sel),
			TextColor3 = C.TEXT,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = el,
		})
		New("TextLabel", {
			Size = UDim2.new(0,20,1,0),
			Position = UDim2.new(1,-32,0,0),
			BackgroundTransparency = 1,
			Text = "▾",
			TextColor3 = C.SUBTEXT,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			Parent = el,
		})

		local list2 = New("Frame", {
			Size = UDim2.new(1,0,0,#opts*30+8),
			Position = UDim2.new(0,0,1,4),
			BackgroundColor3 = C.BG2,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 10,
			Parent = el,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = list2 })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.3, Thickness = 0.5, Parent = list2 })
		local lLayout = New("UIListLayout", { Padding = UDim.new(0,0), Parent = list2 })
		New("UIPadding", { PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), Parent = list2 })

		for _, opt in ipairs(opts) do
			local row = New("TextButton", {
				Size = UDim2.new(1,0,0,30),
				BackgroundTransparency = 1,
				BackgroundColor3 = C.EL_HOVER,
				BorderSizePixel = 0,
				Text = opt,
				TextColor3 = opt == sel and C.ACCENT_TEXT or C.TEXT,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				ZIndex = 11,
				Parent = list2,
			})
			row.MouseEnter:Connect(function() Tween(row, { BackgroundTransparency = 0.5 }, 0.1) end)
			row.MouseLeave:Connect(function() Tween(row, { BackgroundTransparency = 1 }, 0.12) end)
			row.MouseButton1Click:Connect(function()
				sel = opt
				lbl2.Text = c2.Title..": "..opt
				isOpen = false
				list2.Visible = false
				cb(opt)
			end)
		end

		local hit = New("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = el })
		hit.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			list2.Visible = isOpen
		end)

		local obj = { SetValue = function(_, v)
			sel = v; lbl2.Text = c2.Title..": "..v
		end }
		return obj
	end

	function Tab:MakeKeybind(c2)
		assert(c2.Title, "Keybind: missing Title")
		local cb      = c2.Callback or function() end
		local key     = c2.Default  or "RightShift"
		local binding = false
		local toggled = false

		local el = New("Frame", {
			Size = UDim2.new(1,0,0,40),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.4, Thickness = 0.5, Parent = el })
		New("TextLabel", {
			Size = UDim2.new(1,-80,1,0),
			Position = UDim2.new(0,12,0,0),
			BackgroundTransparency = 1,
			Text = c2.Title,
			TextColor3 = C.TEXT,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = el,
		})
		local keyBtn = New("TextButton", {
			Size = UDim2.new(0,72,0,24),
			Position = UDim2.new(1,-84,0.5,-12),
			BackgroundColor3 = C.TAB_ACTIVE,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Text = key,
			TextColor3 = C.ACCENT_TEXT,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			Parent = el,
		})
		New("UICorner", { CornerRadius = UDim.new(0,5), Parent = keyBtn })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.ACCENT, Transparency = 0.4, Thickness = 0.5, Parent = keyBtn })

		keyBtn.MouseButton1Click:Connect(function()
			binding = true
			keyBtn.Text = "..."
			keyBtn.TextColor3 = C.SUBTEXT
		end)

		UserInputService.InputBegan:Connect(function(i, gp)
			if gp then return end
			if binding then
				binding = false
				key = i.KeyCode.Name
				keyBtn.Text = key
				keyBtn.TextColor3 = C.ACCENT_TEXT
			elseif i.KeyCode.Name == key then
				toggled = not toggled
				cb(toggled)
			end
		end)
		return el
	end

	function Tab:MakeTextbox(c2)
		assert(c2.Title, "Textbox: missing Title")
		local cb = c2.Callback or function() end

		local el = New("Frame", {
			Size = UDim2.new(1,0,0,56),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		local stroke = New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.4, Thickness = 0.5, Parent = el })
		New("TextLabel", {
			Size = UDim2.new(1,-24,0,18),
			Position = UDim2.new(0,12,0,5),
			BackgroundTransparency = 1,
			Text = c2.Title,
			TextColor3 = C.SUBTEXT,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = el,
		})
		local box = New("TextBox", {
			Size = UDim2.new(1,-24,0,24),
			Position = UDim2.new(0,12,0,26),
			BackgroundTransparency = 1,
			Text = c2.Default or "",
			PlaceholderText = c2.Placeholder or "Enter text...",
			PlaceholderColor3 = C.SUBTEXT,
			TextColor3 = C.TEXT,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = el,
		})
		box.Focused:Connect(function()
			Tween(stroke, { Color = C.ACCENT, Transparency = 0.2 }, 0.18)
		end)
		box.FocusLost:Connect(function()
			Tween(stroke, { Color = C.BORDER, Transparency = 0.4 }, 0.18)
			cb(box.Text)
		end)
		return el
	end

	function Tab:MakeLabel(c2)
		local el = New("TextLabel", {
			Size = UDim2.new(1,0,0,28),
			BackgroundTransparency = 1,
			Text = c2.Title or c2.Name or "",
			TextColor3 = C.SUBTEXT,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = scroll,
		})
		New("UIPadding", { PaddingLeft = UDim.new(0,4), Parent = el })
		return el
	end

	function Tab:MakeSeparator()
		local el = New("Frame", { Size = UDim2.new(1,0,0,10), BackgroundTransparency = 1, Parent = scroll })
		local line = New("Frame", {
			Size = UDim2.new(1,0,0,1),
			Position = UDim2.new(0,0,0.5,0),
			BackgroundColor3 = C.ACCENT,
			BackgroundTransparency = 0.72,
			BorderSizePixel = 0,
			Parent = el,
		})
		New("UICorner", { CornerRadius = UDim.new(1,0), Parent = line })
		return el
	end

	function Tab:MakeParagraph(c2)
		local el = New("Frame", {
			Size = UDim2.new(1,0,0,60),
			BackgroundColor3 = C.EL,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = scroll,
		})
		New("UICorner", { CornerRadius = UDim.new(0,8), Parent = el })
		New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.BORDER, Transparency = 0.4, Thickness = 0.5, Parent = el })
		New("TextLabel", {
			Size = UDim2.new(1,-24,0,20),
			Position = UDim2.new(0,12,0,4),
			BackgroundTransparency = 1,
			Text = c2.Title or "",
			TextColor3 = C.TEXT,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = el,
		})
		New("TextLabel", {
			Size = UDim2.new(1,-24,0,30),
			Position = UDim2.new(0,12,0,26),
			BackgroundTransparency = 1,
			Text = c2.Content or c2.Text or "",
			TextColor3 = C.SUBTEXT,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = el,
		})
		return el
	end

	return Tab
end

function ZenithLib:_selectTab(idx)
	-- Hide all
	for i, t in ipairs(self._tabs) do
		local active = (i == idx)
		t.scroll.Visible = active
		if active then
			Tween(t.btn, { BackgroundColor3 = C.TAB_ACTIVE, BackgroundTransparency = 0 }, 0.15)
			Tween(t.lbl, { TextColor3 = C.ACCENT_TEXT }, 0.15)
		else
			Tween(t.btn, { BackgroundColor3 = C.BG2, BackgroundTransparency = 1 }, 0.15)
			Tween(t.lbl, { TextColor3 = C.SUBTEXT }, 0.15)
		end
	end
	self._curTab = idx

	-- Move selector
	local btn = self._tabs[idx].btn
	task.defer(function()
		local relY = btn.AbsolutePosition.Y - self._nav.AbsolutePosition.Y
		self._moveSelector(relY, btn.AbsoluteSize.Y)
	end)
end

function ZenithLib:Notify(cfg)
	local title   = cfg.Title   or "Notification"
	local content = cfg.Content or ""
	local dur     = cfg.Duration or 4

	local gui = self.Gui
	local notifHolder = gui:FindFirstChild("NotifHolder")
	if not notifHolder then
		notifHolder = New("Frame", {
			Name = "NotifHolder",
			Size = UDim2.new(0,280,1,-20),
			Position = UDim2.new(1,-300,0,10),
			BackgroundTransparency = 1,
			Parent = gui,
		})
		New("UIListLayout", {
			Padding = UDim.new(0,8),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = notifHolder,
		})
	end

	local n = New("Frame", {
		Size = UDim2.new(1,0,0,64),
		BackgroundColor3 = C.BG2,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1,10,0,0),
		Parent = notifHolder,
	})
	New("UICorner", { CornerRadius = UDim.new(0,8), Parent = n })
	New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.ACCENT, Transparency = 0.4, Thickness = 0.5, Parent = n })
	New("Frame", { Size = UDim2.new(0,3,0,40), Position = UDim2.new(0,0,0.5,-20), BackgroundColor3 = C.ACCENT, BorderSizePixel = 0, Parent = n })
	New("TextLabel", {
		Size = UDim2.new(1,-40,0,18),
		Position = UDim2.new(0,14,0,8),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = C.ACCENT_TEXT,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = n,
	})
	New("TextLabel", {
		Size = UDim2.new(1,-40,0,28),
		Position = UDim2.new(0,14,0,28),
		BackgroundTransparency = 1,
		Text = content,
		TextColor3 = C.SUBTEXT,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = n,
	})

	-- Animate in
	Tween(n, { Position = UDim2.new(0,0,0,0) }, 0.3, Enum.EasingStyle.Back)

	-- Auto dismiss
	task.delay(dur, function()
		Tween(n, { Position = UDim2.new(1,10,0,0), BackgroundTransparency = 1 }, 0.25)
		task.delay(0.3, function() pcall(function() n:Destroy() end) end)
	end)
end

function ZenithLib:Destroy()
	if self._acrylic then pcall(function() self._acrylic:Destroy() end) end
	if self.Gui      then self.Gui:Destroy() end
end

function ZenithLib:SetAcrylic(on)
	if self._acrylic then self._acrylic.Transparency = on and 0.98 or 1 end
end

function ZenithLib:Toggle()
	if self.Frame then self.Frame.Visible = not self.Frame.Visible end
end

getgenv().ZenithLib = ZenithLib
return ZenithLib