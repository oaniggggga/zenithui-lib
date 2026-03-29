# 🌟 ZenithLib

<div align="center">

**Modern Roblox UI Library with Obsidian Ember Theme**

[![Version](https://img.shields.io/badge/version-2.1.0-orange.svg)](https://github.com/oaniggggga/zenithui-lib)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/platform-Roblox-red.svg)](https://www.roblox.com)
[![Discord](https://img.shields.io/discord/1485607035595657300?color=7289da&label=Discord&logo=discord&logoColor=white)](https://discord.gg/PFJgrzyZ)

*Elegant, feature-rich UI library for Roblox scripts with smooth animations, Lucide icons, and comprehensive element support*

[Features](#-features) • [Installation](#-installation) • [Documentation](#-documentation) • [Examples](#-examples)

</div>

---

## ✨ Features

- 🎨 **Obsidian Ember Theme** - Dark obsidian background with ember accent colors
- 🎭 **Lucide Icons** - 1000+ beautiful icons integrated
- 🎬 **Smooth Animations** - Elastic, back, and quint easing animations
- 🎯 **Centered UI** - Always appears in screen center
- 🖱️ **Cursor Control** - Automatic cursor visibility management
- 📦 **Rich Elements** - 15+ UI components ready to use
- 💾 **Config System** - Built-in save/load with profiles
- 🔔 **Notifications** - Beautiful toast notifications
- 🎨 **HSV Color Picker** - Advanced color selection
- ⌨️ **Keybind Support** - Customizable hotkeys
- 📱 **Responsive** - Adapts to screen size

---

## 🚀 Installation

### Method 1: LoadString (Recommended)

```lua
local ZenithLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/oaniggggga/zenithui-lib/refs/heads/main/ZenithLib.lua"
))()
```

### Method 2: Local File

Download `ZenithLib.lua` and load it in your script.

---

## 📖 Quick Start

```lua
-- Load library
local ZenithLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/oaniggggga/zenithui-lib/refs/heads/main/ZenithLib.lua"
))()

-- Create window
local Window = ZenithLib:MakeWindow({
    Title      = "My Script",
    Author     = "YourName",
    SubTitle   = "v1.0",
    ConfigName = "MyScript",
    Intro      = true,
})

-- Initialize built-in tabs (Credits, Settings)
Window:_InitBuiltinTabs()

-- Create config tab with auto-save
Window:MakeConfigTab("MyScript")

-- Create custom tab
local MainTab = Window:MakeTab({
    Title = "Main",
    Image = "home"  -- Lucide icon name
})

-- Add button
MainTab:MakeButton({
    Name = "Click Me",
    Icon = "play",
    Callback = function()
        print("Button clicked!")
    end
})

-- Add toggle
MainTab:MakeToggle({
    Name      = "Enable Feature",
    Icon      = "zap",
    Default   = false,
    ConfigKey = "feature_enabled",  -- Auto-save
    Callback  = function(state)
        print("Toggle:", state)
    end
})

-- Add slider
MainTab:MakeSlider({
    Name      = "Speed",
    Icon      = "gauge",
    Min       = 1,
    Max       = 100,
    Default   = 16,
    ConfigKey = "player_speed",
    Callback  = function(value)
        print("Speed:", value)
    end
})
```

---

## 📚 Documentation

### Window Creation

```lua
local Window = ZenithLib:MakeWindow({
    Title      = "Script Name",      -- Window title
    Author     = "Author Name",      -- Optional author name
    SubTitle   = "v1.0",            -- Optional subtitle
    ConfigName = "MyConfig",        -- Config folder name
    Intro      = true,              -- Show intro animation
    Position   = UDim2.new(...),    -- Optional custom position
    Size       = UDim2.new(...),    -- Optional custom size
})
```

### Tab Creation

```lua
local Tab = Window:MakeTab({
    Title       = "Tab Name",
    Image       = "home",           -- Lucide icon name or asset ID
    LayoutOrder = 1,                -- Optional tab order
})
```

### Elements

#### Button
```lua
Tab:MakeButton({
    Name     = "Button Name",
    Icon     = "play",              -- Optional icon
    Callback = function()
        -- Your code here
    end
})
```

#### Toggle
```lua
Tab:MakeToggle({
    Name      = "Toggle Name",
    Icon      = "zap",
    Default   = false,
    ConfigKey = "my_toggle",        -- Auto-save key
    Callback  = function(state)
        print("State:", state)
    end
})
```

#### Slider
```lua
Tab:MakeSlider({
    Name      = "Slider Name",
    Icon      = "gauge",
    Min       = 0,
    Max       = 100,
    Default   = 50,
    ConfigKey = "my_slider",
    Callback  = function(value)
        print("Value:", value)
    end
})
```

#### Dropdown
```lua
Tab:MakeDropdown({
    Name      = "Dropdown Name",
    Options   = {"Option 1", "Option 2", "Option 3"},
    Default   = "Option 1",
    ConfigKey = "my_dropdown",
    Callback  = function(option)
        print("Selected:", option)
    end
})
```

#### Multi Dropdown
```lua
Tab:MakeMultiDropdown({
    Name      = "Multi Select",
    Options   = {"A", "B", "C", "D"},
    Default   = {"A", "B"},
    ConfigKey = "my_multi",
    Callback  = function(selected)
        print("Selected:", table.concat(selected, ", "))
    end
})
```

#### Keybind
```lua
Tab:MakeKeybind({
    Name      = "Keybind Name",
    Default   = Enum.KeyCode.E,
    ConfigKey = "my_keybind",
    Callback  = function(key)
        print("Key:", key)
    end
})
```

#### Textbox
```lua
Tab:MakeTextbox({
    Name        = "Textbox Name",
    Placeholder = "Enter text...",
    Default     = "",
    ConfigKey   = "my_textbox",
    Callback    = function(text)
        print("Text:", text)
    end
})
```

#### Color Picker
```lua
Tab:MakeColorPicker({
    Name      = "Color Name",
    Default   = Color3.fromRGB(255, 150, 40),
    ConfigKey = "my_color",
    Callback  = function(color)
        print("Color:", color)
    end
})
```

#### Progress Bar
```lua
local Bar = Tab:MakeProgressBar({
    Name    = "Progress",
    Default = 50,
})

-- Update value
Bar:SetValue(75)
```

#### Label
```lua
Tab:MakeLabel({
    Name = "This is a label"
})
```

#### Paragraph
```lua
Tab:MakeParagraph({
    Title = "Title",
    Text  = "Description text here..."
})
```

#### Section
```lua
Tab:MakeSection({
    Name = "Section Name"
})
```

#### Separator
```lua
Tab:MakeSeparator()
```

---

## 🎨 Customization

### Change Accent Color
```lua
Window:SetAccent(Color3.fromRGB(255, 100, 50))
```

### Change Theme
```lua
Window:SetTheme({
    Accent           = Color3.fromRGB(255, 150, 40),
    MainBackground   = Color3.fromRGB(10, 9, 8),
    Text             = Color3.fromRGB(242, 236, 226),
    SubText          = Color3.fromRGB(118, 110, 96),
    InputBackground  = Color3.fromRGB(18, 16, 14),
    DarkerBackground = Color3.fromRGB(6, 5, 4),
})
```

### Change Toggle Key
```lua
Window:SetToggleKey(Enum.KeyCode.RightControl)
```

---

## 🔔 Notifications

```lua
Window:Notify({
    Title    = "Notification Title",
    Content  = "Notification message",
    Duration = 3,  -- seconds
})
```

---

## 💾 Config System

### Auto Config Tab
```lua
-- Creates a full config tab with save/load/delete
Window:MakeConfigTab("MyScript")
```

### Manual Config
```lua
-- Save
Window:SaveConfig("ProfileName")

-- Load
Window:LoadConfig("ProfileName")

-- Delete
Window:DeleteConfig("ProfileName")

-- List profiles
local profiles = Window:ListConfigs()
```

---

## 🎯 Window Methods

```lua
-- Show/Hide
Window:Show()
Window:Hide()
Window:Toggle()

-- Minimize/Maximize
Window:Minimize()
Window:Maximize()
Window:Restore()

-- Destroy
Window:Destroy()

-- Set properties
Window:SetTitle("New Title")
Window:SetSize(UDim2.new(0, 800, 0, 500))
Window:SetPosition(UDim2.new(0.5, -400, 0.5, -250))
```

---

## 🎭 Lucide Icons

ZenithLib supports 1000+ Lucide icons. Use icon names like:

- `"home"`, `"settings"`, `"user"`, `"search"`
- `"play"`, `"pause"`, `"stop"`, `"refresh-cw"`
- `"eye"`, `"eye-off"`, `"lock"`, `"unlock"`
- `"zap"`, `"star"`, `"heart"`, `"shield"`
- `"crosshair"`, `"target"`, `"activity"`

Or use Roblox asset IDs: `"rbxassetid://123456789"`

Full icon list: [Lucide Icons](https://lucide.dev/icons/)

---

## 📋 Examples

Check out `example.lua` for a complete demonstration with:
- Aimbot settings
- ESP/Visuals
- Player modifications
- Config system
- All UI elements

---

## 🎨 Theme Colors

**Obsidian Ember Theme:**
- Background: `#0A0908` (Obsidian)
- Accent: `#FF9628` (Ember)
- Text: `#F2ECE2` (Ivory)
- SubText: `#766E60` (Warm Gray)

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

---

## 📄 License

MIT License - feel free to use in your projects!

---

## 🙏 Credits

- **ZenithLib** - Created by oaniggggga
- **Lucide Icons** - Icon system by Latte Softworks / SiriusSoftwareLtd
- **Inspiration** - Modern UI/UX design principles

---

## 📞 Support

- **Discord**: [Join our server](https://discord.gg/PFJgrzyZ) - Get help, share scripts, and connect with the community
- **Issues**: [GitHub Issues](https://github.com/oaniggggga/zenithui-lib/issues)
- **Discussions**: [GitHub Discussions](https://github.com/oaniggggga/zenithui-lib/discussions)

---

<div align="center">

**Made with ❤️ for the Roblox scripting community**

⭐ Star this repo if you find it useful!

</div>
