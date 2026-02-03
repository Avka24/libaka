--!strict
-- NeonUI v2 - Futuristic Dark Red Neon
-- Single-file core, siap dipisah ke banyak module (Window, Elements, Theme, Config, dsb.)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local NeonUI = {}
NeonUI.__index = NeonUI

local ACTIVE_ROOT_NAME = "_NeonUI_Root"
local VERSION = "2.0.0"

---------------------------------------------------------------------
-- UTILS
---------------------------------------------------------------------
local function safeDestroy(obj: Instance?)
	if obj and obj.Parent then
		obj.Parent = nil
	end
end

local function create(className: string, props: {[string]: any}?, children: {Instance}?)
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			(inst :: any)[k] = v
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = inst
		end
	end
	return inst
end

local function tween(obj: Instance, info: TweenInfo, props: {[string]: any})
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

---------------------------------------------------------------------
-- THEME
---------------------------------------------------------------------
export type Theme = {
	Name: string,
	Background: Color3,
	BackgroundElevated: Color3,
	Panel: Color3,
	PanelAlt: Color3,
	Foreground: Color3,
	Muted: Color3,
	Accent: Color3,
	AccentSoft: Color3,
	OutlineSoft: Color3,
	OutlineStrong: Color3,
	Font: Enum.Font
}

local DefaultTheme: Theme = {
	Name = "NeonDarkRed",
	Background = Color3.fromRGB(10, 10, 16),
	BackgroundElevated = Color3.fromRGB(14, 14, 22),
	Panel = Color3.fromRGB(16, 12, 22),
	PanelAlt = Color3.fromRGB(20, 14, 26),
	Foreground = Color3.fromRGB(235, 235, 245),
	Muted = Color3.fromRGB(150, 150, 170),
	Accent = Color3.fromRGB(255, 70, 100),
	AccentSoft = Color3.fromRGB(150, 30, 50),
	OutlineSoft = Color3.fromRGB(60, 40, 60),
	OutlineStrong = Color3.fromRGB(255, 80, 120),
	Font = Enum.Font.Gotham
}

local Themes: {[string]: Theme} = {
	["NeonDarkRed"] = DefaultTheme
}

---------------------------------------------------------------------
-- TWEENS
---------------------------------------------------------------------
local TweenPresets = {
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Elastic = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

---------------------------------------------------------------------
-- ELEMENT REGISTRY
---------------------------------------------------------------------
local ElementRegistry: {[string]: (Instance, Theme, any) -> any} = {}

local function registerElement(name: string, ctor: (Instance, Theme, any) -> any)
	ElementRegistry[name] = ctor
end

---------------------------------------------------------------------
-- BASE CONTAINERS
---------------------------------------------------------------------
local function makeScrollingY(parent: Instance): ScrollingFrame
	local scroll = create("ScrollingFrame", {
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageTransparency = 0.4,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(90, 90, 120),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0,0,0,0),
		Size = UDim2.new(1,0,1,0),
		ClipsDescendants = true
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		}),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12)
		})
	})

	local layout = scroll:FindFirstChildOfClass("UIListLayout")
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
	end)

	return scroll
end

local function makeSection(parent: Instance, theme: Theme, titleText: string)
	local section = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 60),
		ClipsDescendants = true
	}, {
		create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		create("UIStroke", {
			Color = theme.OutlineSoft,
			Thickness = 1
		}),
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4)
		}),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10)
		})
	})

	local headerRow = create("Frame", {
		Parent = section,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18)
	}, {
		create("UICorner"),
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6)
		})
	})

	local titleLabel = create("TextLabel", {
		Parent = headerRow,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = titleText,
		TextColor3 = theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0, 200, 1, 0)
	})

	local collapseBtn = create("TextButton", {
		Parent = headerRow,
		BackgroundTransparency = 1,
		Text = "▼",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = theme.Muted,
		Size = UDim2.new(0, 20, 1, 0),
		AutoButtonColor = false
	})

	local innerContainer = create("Frame", {
		Parent = section,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20)
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		})
	})

	local layout = section:FindFirstChildOfClass("UIListLayout")
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		section.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 18)
	end)

	local collapsed = false
	local savedHeight = innerContainer.Size

	local function setCollapsed(state: boolean)
		collapsed = state
		if collapsed then
			tween(innerContainer, TweenPresets.Smooth, {Size = UDim2.new(1,0,0,0)})
			tween(collapseBtn, TweenPresets.Smooth, {Rotation = -90})
		else
			tween(innerContainer, TweenPresets.Smooth, {Size = savedHeight})
			tween(collapseBtn, TweenPresets.Smooth, {Rotation = 0})
		end
	end

	collapseBtn.MouseButton1Click:Connect(function()
		setCollapsed(not collapsed)
	end)

	return section, innerContainer
end

---------------------------------------------------------------------
-- NOTIFICATION MANAGER (rapih)
---------------------------------------------------------------------
export type NotificationType = "Success"|"Info"|"Warning"|"Error"

local NotificationColors: {[NotificationType]: Color3} = {
	Success = Color3.fromRGB(110, 255, 170),
	Info = Color3.fromRGB(110, 190, 255),
	Warning = Color3.fromRGB(255, 210, 120),
	Error = Color3.fromRGB(255, 100, 140)
}

local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(rootGui: ScreenGui, theme: Theme)
	local self = setmetatable({}, NotificationManager)

	self.Theme = theme
	self.RootGui = rootGui
	self.Container = create("Frame", {
		Parent = rootGui,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 320, 1, 0),
		ClipsDescendants = false
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})

	self.Active = {}
	return self
end

function NotificationManager:Push(message: string, nType: NotificationType?, duration: number?)
	nType = nType or "Info"
	duration = duration or 4

	local theme = self.Theme

	local frame = create("Frame", {
		Parent = self.Container,
		BackgroundColor3 = theme.PanelAlt,
		Size = UDim2.new(1, 0, 0, 56),
		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		ClipsDescendants = true
	}, {
		create("UICorner", {CornerRadius = UDim.new(0, 6)}),
		create("UIStroke", {
			Color = theme.OutlineSoft,
			Thickness = 1
		})
	})

	local colorStrip = create("Frame", {
		Parent = frame,
		BackgroundColor3 = NotificationColors[nType],
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0)
	}, {
		create("UICorner", {CornerRadius = UDim.new(0, 2)})
	})

	local label = create("TextLabel", {
		Parent = frame,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = message,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -24, 1, 0)
	})

	local progress = create("Frame", {
		Parent = frame,
		BackgroundColor3 = NotificationColors[nType],
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0,1),
		Position = UDim2.new(0,0,1,0),
		Size = UDim2.new(1,0,0,2)
	})

	tween(frame, TweenPresets.Smooth, {BackgroundTransparency = 0})
	tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(0,0,0,2)
	})

	task.delay(duration, function()
		if not frame or not frame.Parent then return end
		tween(frame, TweenPresets.Smooth, {BackgroundTransparency = 1}):Play()
		task.wait(0.22)
		safeDestroy(frame)
	end)

	return frame
end

---------------------------------------------------------------------
-- ELEMENTS – RAPIH & LEBIH LENGKAP
---------------------------------------------------------------------

-- LABEL / PARAGRAPH
registerElement("Label", function(parent, theme, options)
	local text = options.Text or "Label"
	local sizeY = options.MultiLine and 32 or 18

	local label = create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = options.Color or theme.Muted,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, sizeY)
	})

	local obj = {
		Type = "Label",
		Instance = label,
		SetText = function(self, t: string)
			label.Text = t
		end,
		SetEnabled = function(self, e: boolean)
			label.Visible = e
		end,
		OnChange = function() end,
		Destroy = function()
			safeDestroy(label)
		end
	}
	return obj
end)

-- BUTTON
registerElement("Button", function(parent, theme, options)
	local text = options.Text or "Button"
	local callback = options.Callback

	local btn = create("TextButton", {
		Parent = parent,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Size = UDim2.new(1, 0, 0, 28),
		ClipsDescendants = true
	}, {
		create("UICorner", {CornerRadius = UDim.new(0, 6)}),
		create("UIStroke", {
			Color = theme.OutlineSoft,
			Thickness = 1
		})
	})

	local label = create("TextLabel", {
		Parent = btn,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0)
	})

	btn.MouseEnter:Connect(function()
		tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.Panel})
	end)

	btn.MouseLeave:Connect(function()
		tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.PanelAlt})
	end)

	btn.MouseButton1Click:Connect(function()
		tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.AccentSoft})
		task.delay(0.06, function()
			if btn.Parent then
				tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.Panel})
			end
		end)
		if callback then
			task.spawn(callback)
		end
	end)

	local obj = {
		Type = "Button",
		Instance = btn,
		SetEnabled = function(self, e: boolean)
			btn.Active = e
			btn.AutoButtonColor = false
			btn.BackgroundTransparency = e and 0 or 0.4
		end,
		OnChange = function() end,
		Destroy = function()
			safeDestroy(btn)
		end
	}
	return obj
end)

-- TOGGLE
registerElement("Toggle", function(parent, theme, options)
	local text = options.Text or "Toggle"
	local default = options.Default or false
	local callback = options.Callback

	local root = create("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26)
	})

	local label = create("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -50, 1, 0)
	})

	local btn = create("TextButton", {
		Parent = root,
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 34, 0, 18),
		Position = UDim2.new(1, -34, 0.5, -9),
		AutoButtonColor = false
	})

	local track = create("Frame", {
		Parent = btn,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		create("UICorner", {CornerRadius = UDim.new(1, 0)}),
		create("UIStroke", {
			Color = theme.OutlineSoft,
			Thickness = 1
		})
	})

	local thumb = create("Frame", {
		Parent = track,
		BackgroundColor3 = theme.AccentSoft,
		BorderSizePixel = 0,
		Size = UDim2.new(0.45, 0, 1, -2),
		Position = UDim2.new(0, 1, 0, 1)
	}, {
		create("UICorner", {CornerRadius = UDim.new(1, 0)})
	})

	local state = default

	local function refresh(animated: boolean?)
		local targetPos = state and UDim2.new(1, -thumb.AbsoluteSize.X - 1, 0, 1) or UDim2.new(0, 1, 0, 1)
		local targetColor = state and theme.Accent or theme.AccentSoft
		if animated ~= false then
			tween(thumb, TweenPresets.Smooth, {Position = targetPos, BackgroundColor3 = targetColor})
			tween(track, TweenPresets.Smooth, {BackgroundColor3 = state and theme.PanelAlt or theme.PanelAlt})
		else
			thumb.Position = targetPos
			thumb.BackgroundColor3 = targetColor
		end
	end

	btn.MouseButton1Click:Connect(function()
		state = not state
		refresh(true)
		if callback then
			task.spawn(callback, state)
		end
	end)

	refresh(false)

	local obj = {
		Type = "Toggle",
		Instance = root,
		Value = state,
		SetEnabled = function(self, e: boolean)
			btn.Active = e
			root.Visible = e
		end,
		SetValue = function(self, v: boolean)
			state = v
			self.Value = v
			refresh(true)
			if callback then
				task.spawn(callback, v)
			end
		end,
		OnChange = function(self, cb)
			callback = cb
		end,
		Destroy = function()
			safeDestroy(root)
		end
	}
	return obj
end)

-- SLIDER
registerElement("Slider", function(parent, theme, options)
	local text = options.Text or "Slider"
	local min = options.Min or 0
	local max = options.Max or 100
	local default = options.Default or min
	local callback = options.Callback

	local value = math.clamp(default, min, max)

	local root = create("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,40)
	})

	local topRow = create("Frame", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,18)
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0,6)
		})
	})

	local label = create("TextLabel", {
		Parent = topRow,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -60, 1, 0)
	})

	local valueLabel = create("TextLabel", {
		Parent = topRow,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = tostring(value),
		TextColor3 = theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0,60,1,0)
	})

	local bar = create("Frame", {
		Parent = root,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,10),
		Position = UDim2.new(0,0,0,24)
	}, {
		create("UICorner",{CornerRadius = UDim.new(1,0)}),
		create("UIStroke",{
			Color = theme.OutlineSoft,
			Thickness = 1
		})
	})

	local fill = create("Frame", {
		Parent = bar,
		BackgroundColor3 = theme.AccentSoft,
		BorderSizePixel = 0,
		Size = UDim2.new((value-min)/(max-min),0,1,0)
	}, {
		create("UICorner",{CornerRadius = UDim.new(1,0)})
	})

	local dragging = false

	local function applyValueFromX(x: number)
		local rel = math.clamp((x - bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
		local newVal = min + (max-min)*rel
		newVal = math.floor(newVal + 0.5)
		if newVal ~= value then
			value = newVal
			valueLabel.Text = tostring(value)
			tween(fill, TweenPresets.Fast, {
				Size = UDim2.new((value-min)/(max-min),0,1,0)
			})
			if callback then
				task.spawn(callback, value)
			end
		end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			applyValueFromX(input.Position.X)
		end
	end)

	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			applyValueFromX(input.Position.X)
		end
	end)

	local obj = {
		Type = "Slider",
		Instance = root,
		Value = value,
		SetEnabled = function(self, e: boolean)
			root.Visible = e
		end,
		SetValue = function(self, v: number)
			value = math.clamp(v,min,max)
			valueLabel.Text = tostring(value)
			fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
			if callback then
				task.spawn(callback, value)
			end
		end,
		OnChange = function(self, cb)
			callback = cb
		end,
		Destroy = function()
			safeDestroy(root)
		end
	}
	return obj
end)

-- INPUT (text/number/password)
registerElement("Input", function(parent, theme, options)
	local text = options.Text or "Input"
	local placeholder = options.Placeholder or ""
	local mode = options.Mode or "Text" -- "Text"|"Number"|"Password"
	local callback = options.Callback

	local root = create("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,34)
	})

	local label = create("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,0,0,16)
	})

	local box = create("TextBox", {
		Parent = root,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Font = theme.Font,
		Text = "",
		PlaceholderText = placeholder,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = theme.Foreground,
		PlaceholderColor3 = theme.Muted,
		Size = UDim2.new(1,0,0,18),
		Position = UDim2.new(0,0,0,18),
		ClearTextOnFocus = false
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,6)}),
		create("UIStroke",{
			Color = theme.OutlineSoft,
			Thickness = 1
		}),
		create("UIPadding",{PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6)})
	})

	if mode == "Password" then
		box.TextTransparency = 0
		box.Text = ""
		box.ClearTextOnFocus = false
		box.TextEditable = true
		box.RichText = false
	end

	box.Focused:Connect(function()
		tween(box, TweenPresets.Fast, {BackgroundColor3 = theme.Panel})
	end)

	box.FocusLost:Connect(function()
		tween(box, TweenPresets.Fast, {BackgroundColor3 = theme.PanelAlt})
		local textVal = box.Text
		if mode == "Number" then
			local num = tonumber(textVal)
			if num == nil then
				box.Text = ""
				return
			end
			if callback then
				task.spawn(callback, num)
			end
		else
			if callback then
				task.spawn(callback, textVal)
			end
		end
	end)

	local obj = {
		Type = "Input",
		Instance = root,
		Value = "",
		SetEnabled = function(self,e: boolean)
			root.Visible = e
			box.Active = e
		end,
		SetValue = function(self,v: any)
			self.Value = tostring(v)
			box.Text = tostring(v)
		end,
		OnChange = function(self,cb)
			callback = cb
		end,
		Destroy = function()
			safeDestroy(root)
		end
	}
	return obj
end)

-- DROPDOWN (single select sederhana)
registerElement("Dropdown", function(parent, theme, options)
	local text = options.Text or "Dropdown"
	local values = options.Values or {"Option 1","Option 2"}
	local default = options.Default or values[1]
	local callback = options Callback

	local root = create("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,32),
		ClipsDescendants = true
	})

	local label = create("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,0,0,16)
	})

	local mainBtn = create("TextButton", {
		Parent = root,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,18),
		Position = UDim2.new(0,0,0,18),
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,6)}),
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1})
	})

	local currentLabel = create("TextLabel", {
		Parent = mainBtn,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = tostring(default),
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,-20,1,0),
		Position = UDim2.new(0,6,0,0)
	})

	local arrow = create("TextLabel", {
		Parent = mainBtn,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "▼",
		TextColor3 = theme.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0,16,1,0),
		Position = UDim2.new(1,-18,0,0)
	})

	local optionsFrame = create("Frame", {
		Parent = root,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,0),
		Position = UDim2.new(0,0,0,36),
		ClipsDescendants = true,
		Visible = false
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,6)}),
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1}),
		create("UIListLayout",{
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0,2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		create("UIPadding",{PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6)})
	})

	local listLayout = optionsFrame:FindFirstChildOfClass("UIListLayout")

	for _,v in ipairs(values) do
		local optBtn = create("TextButton", {
			Parent = optionsFrame,
			BackgroundTransparency = 1,
			Text = v,
			Font = theme.Font,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.Muted,
			AutoButtonColor = false,
			Size = UDim2.new(1,0,0,18)
		})
		optBtn.MouseEnter:Connect(function()
			tween(optBtn, TweenPresets.Fast, {TextColor3 = theme.Foreground})
		end)
		optBtn.MouseLeave:Connect(function()
			tween(optBtn, TweenPresets.Fast, {TextColor3 = theme.Muted})
		end)
		optBtn.MouseButton1Click:Connect(function()
			currentLabel.Text = v
			if callback then
				task.spawn(callback, v)
			end
			optionsFrame.Visible = false
			arrow.Rotation = 0
			tween(optionsFrame, TweenPresets.Smooth, {Size = UDim2.new(1,0,0,0)})
		end)
	end

	local expanded = false
	mainBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		if expanded then
			optionsFrame.Visible = true
			local height = listLayout.AbsoluteContentSize.Y + 8
			tween(optionsFrame, TweenPresets.Smooth, {Size = UDim2.new(1,0,0,height)})
			tween(arrow, TweenPresets.Smooth, {Rotation = -90})
		else
			tween(optionsFrame, TweenPresets.Smooth, {Size = UDim2.new(1,0,0,0)})
			tween(arrow, TweenPresets.Smooth, {Rotation = 0}).Completed:Connect(function()
				optionsFrame.Visible = false
			end)
		end
	end)

	local obj = {
		Type = "Dropdown",
		Instance = root,
		Value = default,
		SetEnabled = function(self,e: boolean)
			root.Visible = e
		end,
		SetValue = function(self,v:any)
			self.Value = v
			currentLabel.Text = tostring(v)
			if callback then
				task.spawn(callback, v)
			end
		end,
		OnChange = function(self,cb)
			callback = cb
		end,
		Destroy = function()
			safeDestroy(root)
		end
	}
	return obj
end)

-- PROGRESSBAR
registerElement("ProgressBar", function(parent, theme, options)
	local text = options.Text or "Progress"
	local default = options.Default or 0
	local max = options.Max or 100

	local root = create("Frame",{
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,30)
	})

	local topRow = create("Frame",{
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,16)
	}, {
		create("UIListLayout",{
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0,6)
		})
	})

	local label = create("TextLabel",{
		Parent = topRow,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,-50,1,0)
	})

	local valueLabel = create("TextLabel",{
		Parent = topRow,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = ("%d%%"):format(default),
		TextColor3 = theme.Muted,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0,50,1,0)
	})

	local bar = create("Frame",{
		Parent = root,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,8),
		Position = UDim2.new(0,0,0,20)
	}, {
		create("UICorner",{CornerRadius = UDim.new(1,0)}),
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1})
	})

	local fill = create("Frame",{
		Parent = bar,
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(default/max,0,1,0)
	}, {
		create("UICorner",{CornerRadius = UDim.new(1,0)})
	})

	local obj = {
		Type = "ProgressBar",
		Instance = root,
		Value = default,
		SetEnabled = function(self,e:boolean)
			root.Visible = e
		end,
		SetValue = function(self,v:number)
			self.Value = math.clamp(v,0,max)
			valueLabel.Text = ("%d%%"):format(math.floor(self.Value/max*100+0.5))
			tween(fill, TweenPresets.Fast, {
				Size = UDim2.new(self.Value/max,0,1,0)
			})
		end,
		OnChange = function() end,
		Destroy = function()
			safeDestroy(root)
		end
	}
	return obj
end)

-- CODEBOX (singkat + tombol copy)
registerElement("CodeBox", function(parent, theme, options)
	local text = options.Text or "-- code here"
	local callback = options.Callback -- opsional

	local root = create("Frame",{
		Parent = parent,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,52),
		ClipsDescendants = true
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,6)}),
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1}),
		create("UIPadding",{PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})
	})

	local codeLabel = create("TextLabel",{
		Parent = root,
		BackgroundTransparency = 1,
		Font = Enum.Font.Code,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1,-26,1,0)
	})

	local copyBtn = create("TextButton",{
		Parent = root,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Text = "⧉",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = theme.Muted,
		Size = UDim2.new(0,22,0,22),
		AnchorPoint = Vector2.new(1,0),
		Position = UDim2.new(1,0,0,0),
		AutoButtonColor = false
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,4)})
	})

	copyBtn.MouseEnter:Connect(function()
		tween(copyBtn, TweenPresets.Fast, {BackgroundColor3 = theme.PanelAlt, TextColor3 = theme.Foreground})
	end)
	copyBtn.MouseLeave:Connect(function()
		tween(copyBtn, TweenPresets.Fast, {BackgroundColor3 = theme.Panel, TextColor3 = theme.Muted})
	end)

	copyBtn.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(text)
		end
		if callback then
			task.spawn(callback)
		end
	end)

	local obj = {
		Type = "CodeBox",
		Instance = root,
		SetEnabled = function(self,e:boolean)
			root.Visible = e
		end,
		SetText = function(self,t:string)
			codeLabel.Text = t
		end,
		OnChange = function() end,
		Destroy = function()
			safeDestroy(root)
		end
	}
	return obj
end)

---------------------------------------------------------------------
-- WINDOW + TAB SYSTEM (layout lebih rapih)
---------------------------------------------------------------------
export type TabObject = {
	Name: string,
	Frame: Frame,
	Sections: {[string]: Frame},
	AddSection: (self: any, title: string) -> Frame
}

export type WindowObject = {
	Title: string,
	ScreenGui: ScreenGui,
	Root: Frame,
	AddTab: (self: any, name: string) -> TabObject,
	Close: (self: any) -> (),
	Minimize: (self: any) -> (),
	Restore: (self: any) -> ()
}

local function createWindow(title: string, options: any?): WindowObject
	options = options or {}
	local themeName = options.Theme or "NeonDarkRed"
	local theme = Themes[themeName] or DefaultTheme

	local existing = PlayerGui:FindFirstChild(ACTIVE_ROOT_NAME)
	if existing then existing:Destroy() end

	local screenGui = create("ScreenGui", {
		Name = ACTIVE_ROOT_NAME,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = false
	})

	screenGui.Parent = PlayerGui

	local root = create("Frame", {
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5,0,0.5,0),
		Size = UDim2.new(0,640,0,420),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,12)}),
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1}),
		create("UIGradient",{
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Background),
				ColorSequenceKeypoint.new(1, theme.Panel)
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0,0.05),
				NumberSequenceKeypoint.new(1,0.3)
			})
		})
	})

	-- TOP BAR
	local topBar = create("Frame",{
		Parent = root,
		BackgroundColor3 = theme.PanelAlt,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,0,34)
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,12)}),
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1})
	})

	local titleLabel = create("TextLabel",{
		Parent = topBar,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = title,
		TextColor3 = theme.Foreground,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0,12,0,0),
		Size = UDim2.new(0.4,0,1,0)
	})

	local subtitleLabel = create("TextLabel",{
		Parent = topBar,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = options.Subtitle or "",
		TextColor3 = theme.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0,12,0,18),
		Size = UDim2.new(0.4,0,0,14)
	})

	local controlsContainer = create("Frame",{
		Parent = topBar,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1,0),
		Position = UDim2.new(1,-10,0,0),
		Size = UDim2.new(0,80,1,0)
	}, {
		create("UIListLayout",{
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0,6)
		})
	})

	local minimizeButton = create("TextButton",{
		Parent = controlsContainer,
		Text = "–",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = theme.Muted,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(0,24,0,20),
		AutoButtonColor = false
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,6)})
	})

	local closeButton = create("TextButton",{
		Parent = controlsContainer,
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255,110,120),
		BackgroundColor3 = Color3.fromRGB(40,10,16),
		BorderSizePixel = 0,
		Size = UDim2.new(0,24,0,20),
		AutoButtonColor = false
	}, {
		create("UICorner",{CornerRadius = UDim.new(0,6)})
	})

	-- SIDEBAR
	local sidebar = create("Frame",{
		Parent = root,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(0,0,0,34),
		Size = UDim2.new(0,160,1,-34)
	}, {
		create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1}),
		create("UIPadding",{PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})
	})

	local tabList = create("UIListLayout",{
		Parent = sidebar,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0,6)
	})

	-- CONTENT AREA
	local contentArea = create("Frame",{
		Parent = root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0,160,0,34),
		Size = UDim2.new(1,-160,1,-34)
	})

	local tabs: {[string]: TabObject} = {}
	local currentTab: TabObject? = nil

	-- DRAGGING
	do
		local dragging = false
		local dragStart, startPos

		local function update(input)
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		topBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = root.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		topBar.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
	end

	-- MINIMIZE / CLOSE
	local minimized = false
	local storedSize = root.Size

	local function minimize()
		if minimized then return end
		minimized = true
		tween(root, TweenPresets.Smooth, {Size = UDim2.new(storedSize.X.Scale, storedSize.X.Offset, 0, 34)})
	end

	local function restore()
		if not minimized then return end
		minimized = false
		tween(root, TweenPresets.Smooth, {Size = storedSize})
	end

	minimizeButton.MouseButton1Enter:Connect(function()
		tween(minimizeButton, TweenPresets.Fast, {BackgroundColor3 = theme.PanelAlt})
	end)
	minimizeButton.MouseLeave:Connect(function()
		tween(minimizeButton, TweenPresets.Fast, {BackgroundColor3 = theme.Panel})
	end)
	minimizeButton.MouseButton1Click:Connect(function()
		if minimized then
			restore()
		else
			minimize()
		end
	end)

	closeButton.MouseEnter:Connect(function()
		tween(closeButton, TweenPresets.Fast,{BackgroundColor3 = Color3.fromRGB(70,20,26)})
	end)
	closeButton.MouseLeave:Connect(function()
		tween(closeButton, TweenPresets.Fast,{BackgroundColor3 = Color3.fromRGB(40,10,16)})
	end)

	local function closeWindow()
		tween(root, TweenPresets.Smooth, {
			BackgroundTransparency = 1,
			Size = UDim2.new(storedSize.X.Scale, storedSize.X.Offset, 0, 0)
		}).Completed:Wait()
		safeDestroy(screenGui)
	end

	closeButton.MouseButton1Click:Connect(closeWindow)

	-- TAB SWITCHING
	local function setActiveTab(tab: TabObject)
		if currentTab == tab then return end
		for _, t in pairs(tabs) do
			t.Frame.Visible = false
		end
		tab.Frame.Visible = true
		currentTab = tab
	end

	local windowObj: WindowObject = {
		Title = title,
		ScreenGui = screenGui,
		Root = root,
		Close = closeWindow,
		Minimize = minimize,
		Restore = restore,
		AddTab = function(self, name: string): TabObject
			local tabButton = create("TextButton",{
				Parent = sidebar,
				BackgroundColor3 = theme.PanelAlt,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(1,0,0,26)
			}, {
				create("UICorner",{CornerRadius = UDim.new(0,6)}),
				create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1})
			})

			local label = create("TextLabel",{
				Parent = tabButton,
				BackgroundTransparency = 1,
				Font = theme.Font,
				Text = name,
				TextColor3 = theme.Muted,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0,10,0,0),
				Size = UDim2.new(1,-20,1,0)
			})

			local indicator = create("Frame",{
				Parent = tabButton,
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(0,0,1,0),
				Position = UDim2.new(0,0,0,0)
			}, {
				create("UICorner",{CornerRadius = UDim.new(0,4)})
			})

			local page = create("Frame",{
				Parent = contentArea,
				BackgroundColor3 = theme.BackgroundElevated,
				BorderSizePixel = 0,
				Size = UDim2.new(1,-16,1,-16),
				Position = UDim2.new(0,8,0,8),
				Visible = false
			}, {
				create("UICorner",{CornerRadius = UDim.new(0,8)}),
				create("UIStroke",{Color = theme.OutlineSoft, Thickness = 1})
			})

			local scroll = makeScrollingY(page)

			local tab: TabObject = {
				Name = name,
				Frame = page,
				Sections = {},
				AddSection = function(self, sectionTitle: string): Frame
					local sec, inner = makeSection(scroll, theme, sectionTitle)
					self.Sections[sectionTitle] = inner
					return inner
				end
			}

			tabButton.MouseEnter:Connect(function()
				if currentTab ~= tab then
					tween(tabButton, TweenPresets.Fast, {BackgroundColor3 = theme.Panel})
				end
			end)
			tabButton.MouseLeave:Connect(function()
				if currentTab ~= tab then
					tween(tabButton, TweenPresets.Fast, {BackgroundColor3 = theme.PanelAlt})
				end
			end)

			local function applySelected(selected: boolean)
				if selected then
					tween(tabButton, TweenPresets.Smooth, {BackgroundColor3 = theme.Panel})
					tween(label, TweenPresets.Smooth, {TextColor3 = theme.Foreground})
					tween(indicator, TweenPresets.Smooth, {Size = UDim2.new(0,3,1,0)})
				else
					tween(tabButton, TweenPresets.Smooth, {BackgroundColor3 = theme.PanelAlt})
					tween(label, TweenPresets.Smooth, {TextColor3 = theme.Muted})
					tween(indicator, TweenPresets.Smooth, {Size = UDim2.new(0,0,1,0)})
				end
			end

			tabButton.MouseButton1Click:Connect(function()
				for _, other in pairs(tabs) do
					if other == tab then
						applySelected(true)
					else
						applySelected(false)
					end
				end
				setActiveTab(tab)
			end)

			if not currentTab then
				setActiveTab(tab)
				page.Visible = true
				applySelected(true)
			else
				applySelected(false)
			end

			tabs[name] = tab
			return tab
		end
	}

	return windowObj
end

---------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------
function NeonUI.CreateWindow(title: string, options: any?): WindowObject
	return createWindow(title, options)
end

function NeonUI.CreateElement(kind: string, parent: Instance, options: any?): any
	options = options or {}
	local theme = Themes["NeonDarkRed"] or DefaultTheme
	local ctor = ElementRegistry[kind]
	if not ctor then
		error("NeonUI: unknown element '"..kind.."'")
	end
	return ctor(parent, theme, options)
end

function NeonUI.CreateNotificationManager(window: WindowObject)
	local theme = Themes["NeonDarkRed"] or DefaultTheme
	return NotificationManager.new(window.ScreenGui, theme)
end

function NeonUI.RegisterElement(name: string, ctor: (Instance,Theme,any)->any)
	registerElement(name, ctor)
end

function NeonUI.GetVersion()
	return VERSION
end

return NeonUI
