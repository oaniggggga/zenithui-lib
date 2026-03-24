--[[
	ZenithLib — Example Script
	Демонстрирует весь функционал библиотеки
	Вставь в LocalScript в Roblox
]]

local ZenithLib = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/oaniggggga/zenithui-lib/refs/heads/main/ZenithLib.lua"
))()

-- ═══════════════════════════════════════════════════
-- ОКНО
-- ═══════════════════════════════════════════════════

local Window = ZenithLib:MakeWindow({
	Title      = "ZenithScript",
	Author     = "oaniggggga",
	SubTitle   = "v2.0",
	ConfigName = "ZenithScript",
	Intro      = true,
})

Window:_InitBuiltinTabs()
local ConfigTab = Window:MakeConfigTab("ZenithScript")  -- конфиг вкладка + автосейв

-- ═══════════════════════════════════════════════════
-- ВКЛАДКИ
-- ═══════════════════════════════════════════════════

local MainTab    = Window:MakeTab({ Title = "Main",    Image = "home" })
local AimbotTab  = Window:MakeTab({ Title = "Aimbot",  Image = "crosshair" })
local VisualsTab = Window:MakeTab({ Title = "Visuals", Image = "eye" })
local PlayerTab  = Window:MakeTab({ Title = "Player",  Image = "user" })
local MiscTab    = Window:MakeTab({ Title = "Misc",    Image = "wrench" })

-- ═══════════════════════════════════════════════════
-- MAIN TAB
-- ═══════════════════════════════════════════════════

MainTab:MakeSection({ Name = "Quick Actions" })

MainTab:MakeButton({
	Name = "Execute Script",
	Icon = "play",
	Callback = function()
		Window:Notify({
			Title   = "Executed",
			Content = "Script ran successfully!",
			Duration = 3,
		})
	end,
})

MainTab:MakeButton({
	Name = "Rejoin Server",
	Icon = "refresh-cw",
	Callback = function()
		local TS = game:GetService("TeleportService")
		pcall(function()
			TS:Teleport(game.PlaceId, game.Players.LocalPlayer)
		end)
	end,
})

MainTab:MakeSeparator()
MainTab:MakeSection({ Name = "Info" })

MainTab:MakeParagraph({
	Title = "ZenithLib v2.0",
	Text  = "Obsidian Ember Theme — модульная Roblox UI библиотека с Lucide иконками, HSV color picker, анимациями и полным набором элементов.",
})

MainTab:MakeLabel({ Name = "RightShift — скрыть/показать UI" })
MainTab:MakeLabel({ Name = "Зелёная точка — свернуть окно" })
MainTab:MakeLabel({ Name = "Красная точка — закрыть" })

MainTab:MakeSeparator()
MainTab:MakeSection({ Name = "Execute Lua" })

MainTab:MakeTextbox({
	Name        = "Lua Console",
	Placeholder = "print('Hello from ZenithLib!')",
	Default     = "",
	Callback    = function(text)
		if text == "" then return end
		local fn, err = loadstring(text)
		if fn then
			local ok, runErr = pcall(fn)
			if not ok then
				Window:Notify({ Title = "Runtime Error", Content = tostring(runErr), Duration = 5 })
			end
		else
			Window:Notify({ Title = "Syntax Error", Content = tostring(err), Duration = 5 })
		end
	end,
})

-- ═══════════════════════════════════════════════════
-- AIMBOT TAB
-- ═══════════════════════════════════════════════════

AimbotTab:MakeSection({ Name = "Core" })

AimbotTab:MakeToggle({
	Name      = "Enable Aimbot",
	Icon      = "crosshair",
	Default   = false,
	ConfigKey = "aimbot_enabled",
	Callback = function(state)
		print("Aimbot:", state)
	end,
})

AimbotTab:MakeToggle({
	Name      = "Silent Aim",
	Icon      = "ghost",
	Default   = false,
	ConfigKey = "silent_aim",
	Callback = function(state)
		print("Silent Aim:", state)
	end,
})

AimbotTab:MakeToggle({
	Name    = "Auto Fire",
	Icon    = "zap",
	Default = false,
	Callback = function(state)
		print("Auto Fire:", state)
	end,
})

AimbotTab:MakeSeparator()
AimbotTab:MakeSection({ Name = "Settings" })

AimbotTab:MakeSlider({
	Name      = "FOV",
	Icon      = "scan",
	Min       = 10,
	ConfigKey = "aimbot_fov",
	Max     = 360,
	Default = 90,
	Callback = function(value)
		print("FOV:", value)
	end,
})

AimbotTab:MakeSlider({
	Name      = "Smoothness",
	Icon      = "activity",
	ConfigKey = "aimbot_smooth",
	Min     = 0,
	Max     = 100,
	Default = 20,
	Callback = function(value)
		print("Smoothness:", value)
	end,
})

AimbotTab:MakeSlider({
	Name    = "Range",
	Icon    = "ruler",
	Min     = 50,
	Max     = 2000,
	Default = 500,
	Callback = function(value)
		print("Range:", value)
	end,
})

AimbotTab:MakeDropdown({
	Name    = "Prediction",
	Options = { "None", "Linear", "Quadratic", "Cubic" },
	Default = "None",
	Callback = function(option)
		print("Prediction:", option)
	end,
})

AimbotTab:MakeMultiDropdown({
	Name    = "Target Parts",
	Options = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" },
	Default = { "Head" },
	Callback = function(selected)
		print("Target parts:", table.concat(selected, ", "))
	end,
})

AimbotTab:MakeSeparator()
AimbotTab:MakeSection({ Name = "Keybinds" })

AimbotTab:MakeKeybind({
	Name    = "Aim Lock",
	Default = Enum.KeyCode.E,
	Callback = function(key)
		print("Aim lock:", key)
	end,
})

AimbotTab:MakeKeybind({
	Name    = "Toggle Aimbot",
	Default = Enum.KeyCode.G,
	Callback = function(key)
		print("Toggle aimbot:", key)
	end,
})

AimbotTab:MakeButton({
	Name = "Reset Settings",
	Icon = "rotate-ccw",
	Callback = function()
		Window:Notify({ Title = "Reset", Content = "Aimbot settings reset.", Duration = 2 })
	end,
})

-- ═══════════════════════════════════════════════════
-- VISUALS TAB
-- ═══════════════════════════════════════════════════

VisualsTab:MakeSection({ Name = "ESP" })

VisualsTab:MakeToggle({
	Name      = "Enable ESP",
	Icon      = "eye",
	ConfigKey = "esp_enabled",
	Default = false,
	Callback = function(state)
		print("ESP:", state)
	end,
})

VisualsTab:MakeMultiDropdown({
	Name    = "ESP Options",
	Options = { "Box", "Name", "Health", "Distance", "Skeleton", "Tracers", "Head Dot" },
	Default = { "Box", "Name", "Health" },
	Callback = function(selected)
		print("ESP options:", table.concat(selected, ", "))
	end,
})

VisualsTab:MakeColorPicker({
	Name    = "ESP Color",
	Default = Color3.fromRGB(255, 150, 40),
	Callback = function(color)
		print("ESP color:", color)
	end,
})

VisualsTab:MakeSlider({
	Name    = "ESP Thickness",
	Min     = 1,
	Max     = 5,
	Default = 1,
	Callback = function(value)
		print("ESP thickness:", value)
	end,
})

VisualsTab:MakeSeparator()
VisualsTab:MakeSection({ Name = "Chams" })

VisualsTab:MakeToggle({
	Name    = "Enable Chams",
	Icon    = "layers",
	Default = false,
	Callback = function(state)
		print("Chams:", state)
	end,
})

VisualsTab:MakeDropdown({
	Name    = "Chams Style",
	Options = { "Flat", "Neon", "Glass", "Wireframe" },
	Default = "Flat",
	Callback = function(option)
		print("Chams style:", option)
	end,
})

VisualsTab:MakeColorPicker({
	Name    = "Chams Color",
	Default = Color3.fromRGB(255, 80, 40),
	Callback = function(color)
		print("Chams color:", color)
	end,
})

VisualsTab:MakeSeparator()
VisualsTab:MakeSection({ Name = "World" })

VisualsTab:MakeToggle({
	Name    = "Fullbright",
	Icon    = "sun",
	Default = false,
	Callback = function(state)
		local L = game:GetService("Lighting")
		L.Brightness = state and 10 or 1
		L.FogEnd     = state and 1e6 or 2000
	end,
})

VisualsTab:MakeToggle({
	Name    = "No Fog",
	Icon    = "cloud-off",
	Default = false,
	Callback = function(state)
		game:GetService("Lighting").FogEnd = state and 1e6 or 2000
	end,
})

VisualsTab:MakeSlider({
	Name    = "Brightness",
	Min     = 0,
	Max     = 10,
	Default = 1,
	Callback = function(value)
		game:GetService("Lighting").Brightness = value
	end,
})

-- ═══════════════════════════════════════════════════
-- PLAYER TAB
-- ═══════════════════════════════════════════════════

PlayerTab:MakeSection({ Name = "Movement" })

PlayerTab:MakeToggle({
	Name    = "No Clip",
	Icon    = "move",
	Default = false,
	Callback = function(state)
		print("No clip:", state)
	end,
})

PlayerTab:MakeToggle({
	Name    = "Infinite Jump",
	Icon    = "chevrons-up",
	Default = false,
	Callback = function(state)
		print("Infinite jump:", state)
	end,
})

PlayerTab:MakeSlider({
	Name      = "Walk Speed",
	Icon      = "gauge",
	ConfigKey = "player_speed",
	Min     = 1,
	Max     = 500,
	Default = 16,
	Callback = function(value)
		local c = game.Players.LocalPlayer.Character
		if c and c:FindFirstChild("Humanoid") then
			c.Humanoid.WalkSpeed = value
		end
	end,
})

PlayerTab:MakeSlider({
	Name    = "Jump Power",
	Icon    = "arrow-up",
	Min     = 1,
	Max     = 500,
	Default = 50,
	Callback = function(value)
		local c = game.Players.LocalPlayer.Character
		if c and c:FindFirstChild("Humanoid") then
			c.Humanoid.JumpPower = value
		end
	end,
})

local hpBar = PlayerTab:MakeProgressBar({
	Name    = "Health",
	Default = 100,
})

-- Обновляем healthbar
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:FindFirstChild("Humanoid")
if hum then
	hum:GetPropertyChangedSignal("Health"):Connect(function()
		hpBar:SetValue(math.floor(hum.Health / hum.MaxHealth * 100))
	end)
end

PlayerTab:MakeSeparator()
PlayerTab:MakeSection({ Name = "God Mode" })

PlayerTab:MakeToggle({
	Name    = "God Mode",
	Icon    = "shield",
	Default = false,
	Callback = function(state)
		print("God mode:", state)
	end,
})

PlayerTab:MakeSeparator()
PlayerTab:MakeSection({ Name = "Teleport" })

PlayerTab:MakeDropdown({
	Name    = "Teleport To",
	Options = { "Spawn", "Base", "Center", "Enemy Base", "Random" },
	Default = "Spawn",
	Callback = function(option)
		print("Teleport to:", option)
	end,
})

PlayerTab:MakeTextbox({
	Name        = "Teleport to Player",
	Placeholder = "Player name...",
	Default     = "",
	Callback    = function(text)
		if text == "" then return end
		local target = game.Players:FindFirstChild(text)
		if target and target.Character then
			local lp = game.Players.LocalPlayer
			if lp.Character then
				lp.Character:SetPrimaryPartCFrame(
					target.Character:GetPrimaryPartCFrame()
				)
				Window:Notify({ Title = "Teleported", Content = "→ " .. text, Duration = 2 })
			end
		else
			Window:Notify({ Title = "Not Found", Content = text .. " is not in game", Duration = 3 })
		end
	end,
})

-- ═══════════════════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════════════════

MiscTab:MakeSection({ Name = "UI" })

MiscTab:MakeKeybind({
	Name      = "Toggle UI",
	Default   = Enum.KeyCode.RightShift,
	ConfigKey = "ui_toggle_key",
	Callback = function(key)
		Window:SetToggleKey(key)
		Window:Notify({
			Title   = "Hotkey Updated",
			Content = tostring(key):gsub("Enum.KeyCode.", ""),
			Duration = 2,
		})
	end,
})

MiscTab:MakeColorPicker({
	Name    = "Accent Color",
	Default = Color3.fromRGB(255, 150, 40),
	Callback = function(color)
		Window:SetAccent(color)
	end,
})

MiscTab:MakeSeparator()
MiscTab:MakeSection({ Name = "Game" })

MiscTab:MakeButton({
	Name = "Copy Game ID",
	Icon = "copy",
	Callback = function()
		pcall(setclipboard, tostring(game.PlaceId))
		Window:Notify({
			Title   = "Copied!",
			Content = "Place ID: " .. tostring(game.PlaceId),
			Duration = 3,
		})
	end,
})

MiscTab:MakeButton({
	Name = "Copy Join Link",
	Icon = "link",
	Callback = function()
		local link = "https://www.roblox.com/games/" .. game.PlaceId
		pcall(setclipboard, link)
		Window:Notify({ Title = "Copied!", Content = link, Duration = 3 })
	end,
})

MiscTab:MakeButton({
	Name = "Rejoin",
	Icon = "refresh-cw",
	Callback = function()
		local TS = game:GetService("TeleportService")
		pcall(function()
			TS:Teleport(game.PlaceId, game.Players.LocalPlayer)
		end)
	end,
})

MiscTab:MakeSeparator()
MiscTab:MakeSection({ Name = "Info" })

MiscTab:MakeLabel({ Name = "Script:   ZenithScript" })
MiscTab:MakeLabel({ Name = "Version:  v2.0" })
MiscTab:MakeLabel({ Name = "Author:   oaniggggga" })
MiscTab:MakeLabel({ Name = "Library:  ZenithLib v2.0" })

-- ═══════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════

Window:Notify({
	Title   = "ZenithScript",
	Content = "Loaded! RightShift to toggle UI.",
	Duration = 4,
})