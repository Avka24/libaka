--!strict
-- NeonUI.lua
-- Futuristic Dark Red Neon UI Library (Core)
-- Ready to be split into multiple modules later (Window, Theme, Elements, Config, etc.)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- UTILS
---------------------------------------------------------------------
local NeonUI = {}
NeonUI.__index = NeonUI

local ACTIVE_ROOT_NAME = "_NeonUI_Root"
local VERSION = "1.0.0"

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
		for _, child in ipairs(children) do
			child.Parent = inst
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
-- THEME SYSTEM
---------------------------------------------------------------------
export type Theme = {
	Name: string,
	Background: Color3,
	Foreground: Color3,
	Accent: Color3,
	AccentSecondary: Color3,
	Outline: Color3,
	Font: Enum.Font
}

local DefaultTheme: Theme = {
	Name = "NeonDarkRed",
	Background = Color3.fromRGB(10, 10, 16),
	Foreground = Color3.fromRGB(230, 230, 240),
	Accent = Color3.fromRGB(255, 60, 80),
	AccentSecondary = Color3.fromRGB(180, 30, 50),
	Outline = Color3.fromRGB(60, 20, 30),
	Font = Enum.Font.Gotham
}

local Themes: {[string]: Theme} = {
	["NeonDarkRed"] = DefaultTheme,
	["Compact"] = {
		Name = "Compact",
		Background = Color3.fromRGB(12, 12, 18),
		Foreground = Color3.fromRGB(220, 220, 230),
		Accent = Color3.fromRGB(255, 70, 90),
		AccentSecondary = Color3.fromRGB(160, 40, 55),
		Outline = Color3.fromRGB(70, 30, 45),
		Font = Enum.Font.Gotham
	},
	["Comfortable"] = {
		Name = "Comfortable",
		Background = Color3.fromRGB(8, 8, 14),
		Foreground = Color3.fromRGB(240, 240, 245),
		Accent = Color3.fromRGB(255, 80, 100),
		AccentSecondary = Color3.fromRGB(190, 40, 60),
		Outline = Color3.fromRGB(55, 25, 35),
		Font = Enum.Font.Gotham
	}
}

---------------------------------------------------------------------
-- ANIMATION PRESETS
---------------------------------------------------------------------
local TweenPresets = {
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Elastic = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

---------------------------------------------------------------------
-- ELEMENT BASE
---------------------------------------------------------------------
export type ElementBase = {
	Type: string,
	Instance: Instance,
	Enabled: boolean,
	Destroy: (self: any) -> (),
	SetEnabled: (self: any, enabled: boolean) -> (),
	OnChange: (self: any, callback: (any) -> ()) -> ()
}

local ElementRegistry = {} :: {[string]: (parent: Instance, theme: Theme, options: any) -> any}

local function registerElement(name: string, ctor: (Instance, Theme, any) -> any)
	ElementRegistry[name] = ctor
end

---------------------------------------------------------------------
-- WINDOW / TAB TYPES
---------------------------------------------------------------------
export type TabObject = {
	Name: string,
	Icon: string?,
	Frame: Frame,
	Sections: {[string]: Frame},
	AddSection: (self: TabObject, title: string) -> Frame
}

export type WindowObject = {
	Title: string,
	Subtitle: string?,
	AccentColor: Color3?,
	Icon: string?,
	ScreenGui: ScreenGui,
	Root: Frame,
	TabBar: Frame,
	TabPages: Frame,
	Close: (self: WindowObject) -> (),
	Minimize: (self: WindowObject) -> (),
	Restore: (self: WindowObject) -> (),
	AddTab: (self: WindowObject, name: string, icon: string?) -> TabObject
}

---------------------------------------------------------------------
-- NOTIFICATION MANAGER
---------------------------------------------------------------------
export type NotificationType = "Success" | "Info" | "Warning" | "Error"

local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(rootGui: ScreenGui, theme: Theme)
	local self = setmetatable({}, NotificationManager)

	self.Theme = theme
	self.RootGui = rootGui
	self.Container = create("Frame", {
		Name = "NeonNotifications",
		Parent = rootGui,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 320, 1, 0),
		ZIndex = 1000
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

local NotificationColors: {[NotificationType]: Color3} = {
	Success = Color3.fromRGB(80, 255, 160),
	Info = Color3.fromRGB(80, 180, 255),
	Warning = Color3.fromRGB(255, 210, 90),
	Error = Color3.fromRGB(255, 80, 120)
}

function NotificationManager:Push(text: string, nType: NotificationType?, duration: number?)
	nType = nType or "Info"
	duration = duration or 4

	local theme = self.Theme

	local frame = create("Frame", {
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),
		ClipsDescendants = true
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		create("UIStroke", {
			Color = theme.Outline,
			Thickness = 1
		}),
		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Background),
				ColorSequenceKeypoint.new(1, theme.AccentSecondary)
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(1, 0.6)
			})
		})
	})

	frame.Parent = self.Container
	frame.LayoutOrder = #self.Active + 1
	table.insert(self.Active, frame)

	local accentBar = create("Frame", {
		Parent = frame,
		BackgroundColor3 = NotificationColors[nType],
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0)
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 2) })
	})

	local label = create("TextLabel", {
		Parent = frame,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		RichText = true,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		TextSize = 14
	})

	local progress = create("Frame", {
		Parent = frame,
		BackgroundColor3 = NotificationColors[nType],
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2)
	})

	tween(frame, TweenPresets.Smooth, {
		BackgroundTransparency = 0
	})

	progress.Size = UDim2.new(1, 0, 0, 2)
	tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 0, 2)
	})

	task.delay(duration, function()
		if frame.Parent == nil then
			return
		end
		tween(frame, TweenPresets.Smooth, {
			BackgroundTransparency = 1
		}).Completed:Wait()
		safeDestroy(frame)
	end)

	return frame
end

---------------------------------------------------------------------
-- ELEMENT IMPLEMENTATIONS (BASIC SET)
---------------------------------------------------------------------

-- BUTTON
registerElement("Button", function(parent: Instance, theme: Theme, options)
	local text = options.Text or "Button"
	local callback = options.Callback

	local btn = create("TextButton", {
		Parent = parent,
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 28),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ClipsDescendants = true
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		create("UIStroke", {
			Color = theme.Outline,
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
		tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.AccentSecondary})
	end)

	btn.MouseLeave:Connect(function()
		tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.Background})
	end)

	btn.MouseButton1Click:Connect(function()
		tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.Accent})
		task.delay(0.06, function()
			if btn and btn.Parent then
				tween(btn, TweenPresets.Fast, {BackgroundColor3 = theme.AccentSecondary})
			end
		end)
		if callback then
			task.spawn(callback)
		end
	end)

	local obj = {
		Type = "Button",
		Instance = btn,
		Enabled = true,
		SetEnabled = function(self, enabled: boolean)
			self.Enabled = enabled
			btn.Active = enabled
			btn.AutoButtonColor = false
			btn.BackgroundTransparency = enabled and 0 or 0.4
		end,
		OnChange = function(self, cb)
			-- Buttons generally don't have value change
		end,
		Destroy = function(self)
			safeDestroy(btn)
		end
	}

	return obj
end)

-- TOGGLE
registerElement("Toggle", function(parent: Instance, theme: Theme, options)
	local text = options.Text or "Toggle"
	local default = options.Default or false
	local callback = options.Callback

	local root = create("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28)
	})

	local label = create("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -48, 1, 0)
	})

	local btn = create("TextButton", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 32, 0, 18),
		Position = UDim2.new(1, -32, 0.5, -9),
		Text = "",
		AutoButtonColor = false
	})

	local track = create("Frame", {
		Parent = btn,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) }),
		create("UIStroke", {
			Color = theme.Outline,
			Thickness = 1
		})
	})

	local thumb = create("Frame", {
		Parent = track,
		Size = UDim2.new(0.45, 0, 1, 0),
		BackgroundColor3 = theme.AccentSecondary,
		BorderSizePixel = 0
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})

	local state = default

	local function refresh(animated: boolean?)
		animated = animated ~= false
		local goalPos = state and UDim2.new(1, -thumb.AbsoluteSize.X, 0, 0) or UDim2.new(0, 0, 0, 0)
		local colorGoal = state and theme.Accent or theme.AccentSecondary
		if animated then
			tween(thumb, TweenPresets.Smooth, {Position = goalPos, BackgroundColor3 = colorGoal})
		else
			thumb.Position = goalPos
			thumb.BackgroundColor3 = colorGoal
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
		Enabled = true,
		Value = state,
		SetEnabled = function(self, enabled: boolean)
			self.Enabled = enabled
			btn.Active = enabled
			track.BackgroundTransparency = enabled and 0 or 0.4
		end,
		SetValue = function(self, v: boolean)
			state = v
			self.Value = v
			refresh(true)
			if callback then
				task.spawn(callback, state)
			end
		end,
		OnChange = function(self, cb)
			callback = cb
		end,
		Destroy = function(self)
			safeDestroy(root)
		end
	}

	return obj
end)

-- SLIDER (basic)
registerElement("Slider", function(parent: Instance, theme: Theme, options)
	local text = options.Text or "Slider"
	local min = options.Min or 0
	local max = options.Max or 100
	local default = options.Default or min
	local callback = options.Callback

	local value = math.clamp(default, min, max)

	local root = create("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36)
	})

	local label = create("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16)
	})

	local valueLabel = create("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = tostring(value),
		TextColor3 = theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, 0, 0, 16)
	})

	local bar = create("Frame", {
		Parent = root,
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 0, 22)
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) }),
		create("UIStroke", {
			Color = theme.Outline,
			Thickness = 1
		})
	})

	local fill = create("Frame", {
		Parent = bar,
		BackgroundColor3 = theme.AccentSecondary,
		BorderSizePixel = 0,
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) })
	})

	local dragging = false

	local function setValueFromX(x: number)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local newVal = min + (max - min) * rel
		newVal = math.floor(newVal + 0.5)
		if newVal ~= value then
			value = newVal
			valueLabel.Text = tostring(value)
			tween(fill, TweenPresets.Fast, {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			})
			if callback then
				task.spawn(callback, value)
			end
		end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setValueFromX(input.Position.X)
		end
	end)

	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setValueFromX(input.Position.X)
		end
	end)

	local obj = {
		Type = "Slider",
		Instance = root,
		Enabled = true,
		Value = value,
		SetEnabled = function(self, enabled: boolean)
			self.Enabled = enabled
			bar.Active = enabled
			bar.BackgroundTransparency = enabled and 0 or 0.4
		end,
		SetValue = function(self, v: number)
			value = math.clamp(v, min, max)
			valueLabel.Text = tostring(value)
			fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			if callback then
				task.spawn(callback, value)
			end
		end,
		OnChange = function(self, cb)
			callback = cb
		end,
		Destroy = function(self)
			safeDestroy(root)
		end
	}

	return obj
end)

-- LABEL / PARAGRAPH
registerElement("Label", function(parent: Instance, theme: Theme, options)
	local text = options.Text or "Label"

	local label = create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = text,
		TextColor3 = theme.Foreground,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18)
	})

	local obj = {
		Type = "Label",
		Instance = label,
		Enabled = true,
		SetEnabled = function(self, enabled: boolean)
			self.Enabled = enabled
			label.Visible = enabled
		end,
		SetText = function(self, t: string)
			label.Text = t
		end,
		OnChange = function(self, cb)
			-- N/A
		end,
		Destroy = function(self)
			safeDestroy(label)
		end
	}

	return obj
end)

---------------------------------------------------------------------
-- TAB & WINDOW IMPLEMENTATION
---------------------------------------------------------------------
local function makeScrollingContainer(parent: Instance): ScrollingFrame
	local scroll = create("ScrollingFrame", {
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		}),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		})
	})

	local layout = scroll:FindFirstChildOfClass("UIListLayout")
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
	end)

	return scroll
end

local function createWindow(title: string, options: any?): WindowObject
	options = options or {}

	local accent = options.AccentColor or DefaultTheme.Accent
	local themeName = options.Theme or "NeonDarkRed"
	local theme = Themes[themeName] or DefaultTheme

	local existing = PlayerGui:FindFirstChild(ACTIVE_ROOT_NAME)
	if existing then
		existing:Destroy()
	end

	local screenGui = create("ScreenGui", {
		Name = ACTIVE_ROOT_NAME,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		IgnoreGuiInset = true
	})

	screenGui.Parent = PlayerGui

	local root = create("Frame", {
		Parent = screenGui,
		Name = "MainWindow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 580, 0, 420),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		create("UIStroke", {
			Color = theme.Outline,
			Thickness = 1
		}),
		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Background),
				ColorSequenceKeypoint.new(1, theme.AccentSecondary)
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(1, 0.4)
			})
		})
	})

	-- Top bar
	local topBar = create("Frame", {
		Parent = root,
		BackgroundColor3 = Color3.fromRGB(16, 16, 26),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36)
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		create("UIStroke", {
			Color = theme.AccentSecondary,
			Thickness = 1
		})
	})

	local titleLabel = create("TextLabel", {
		Parent = topBar,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = title,
		TextColor3 = theme.Foreground,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.4, 0, 1, 0)
	})

	local subtitle = options.Subtitle or ""
	local subtitleLabel = create("TextLabel", {
		Parent = topBar,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = subtitle,
		TextColor3 = Color3.fromRGB(140, 140, 160),
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 12, 0, 18),
		Size = UDim2.new(0.4, 0, 0, 16)
	})

	local closeButton = create("TextButton", {
		Parent = topBar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 22),
		BackgroundColor3 = Color3.fromRGB(34, 8, 8),
		Text = "✕",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 110, 120),
		AutoButtonColor = false
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	local minimizeButton = create("TextButton", {
		Parent = topBar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -40, 0.5, 0),
		Size = UDim2.new(0, 26, 0, 22),
		BackgroundColor3 = Color3.fromRGB(20, 12, 12),
		Text = "–",
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 200, 120),
		AutoButtonColor = false
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) })
	})

	-- Tab bar
	local tabBar = create("Frame", {
		Parent = root,
		BackgroundColor3 = Color3.fromRGB(14, 14, 24),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 36),
		Size = UDim2.new(0, 150, 1, -36)
	})

	local tabList = create("UIListLayout", {
		Parent = tabBar,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	})

	local tabPages = create("Frame", {
		Parent = root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 150, 0, 36),
		Size = UDim2.new(1, -150, 1, -36)
	})

	local tabs: {[string]: TabObject} = {}
	local currentTab: TabObject? = nil

	-- Dragging
	do
		local dragging = false
		local dragStart
		local startPos

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
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					update(input)
				end
			end
		end)
	end

	-- Minimize / close behavior
	local minimized = false
	local storedSize = root.Size

	local function minimize()
		if minimized then return end
		minimized = true
		tween(root, TweenPresets.Smooth, {
			Size = UDim2.new(storedSize.X.Scale, storedSize.X.Offset, 0, 36)
		})
	end

	local function restore()
		if not minimized then return end
		minimized = false
		tween(root, TweenPresets.Smooth, {
			Size = storedSize
		})
	end

	minimizeButton.MouseButton1Click:Connect(function()
		if minimized then
			restore()
		else
			minimize()
		end
	end)

	closeButton.MouseEnter:Connect(function()
		tween(closeButton, TweenPresets.Fast, {BackgroundColor3 = Color3.fromRGB(60, 10, 18)})
	end)

	closeButton.MouseLeave:Connect(function()
		tween(closeButton, TweenPresets.Fast, {BackgroundColor3 = Color3.fromRGB(34, 8, 8)})
	end)

	local function closeWindow()
		tween(root, TweenPresets.Smooth, {
			Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset, 0, 0),
			BackgroundTransparency = 1
		}).Completed:Wait()
		safeDestroy(screenGui)
	end

	closeButton.MouseButton1Click:Connect(closeWindow)

	-- Tabs
	local function setActiveTab(tab: TabObject)
		if currentTab == tab then
			return
		end

		for _, t in pairs(tabs) do
			t.Frame.Visible = false
		end
		tab.Frame.Visible = true
		currentTab = tab
	end

	local windowObj: WindowObject = {
		Title = title,
		Subtitle = subtitle,
		AccentColor = accent,
		Icon = options.Icon,
		ScreenGui = screenGui,
		Root = root,
		TabBar = tabBar,
		TabPages = tabPages,
		Close = closeWindow,
		Minimize = minimize,
		Restore = restore,
		AddTab = function(self, name: string, icon: string?): TabObject
			local tabButton = create("TextButton", {
				Parent = tabBar,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				Size = UDim2.new(1, 0, 0, 30)
			})

			local bg = create("Frame", {
				Parent = tabButton,
				BackgroundColor3 = Color3.fromRGB(18, 18, 28),
				BorderSizePixel = 0,
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 5, 0, 0)
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 6) })
			})

			local textLabel = create("TextLabel", {
				Parent = bg,
				BackgroundTransparency = 1,
				Font = theme.Font,
				Text = name,
				TextColor3 = theme.Foreground,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0, 8, 0, 0),
				Size = UDim2.new(1, -16, 1, 0)
			})

			local indicator = create("Frame", {
				Parent = bg,
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0)
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 4) })
			})

			local page = create("Frame", {
				Parent = tabPages,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = false
			})

			local content = makeScrollingContainer(page)

			local tab: TabObject = {
				Name = name,
				Icon = icon,
				Frame = page,
				Sections = {},
				AddSection = function(self, titleText: string): Frame
					local section = create("Frame", {
						Parent = content,
						BackgroundColor3 = Color3.fromRGB(14, 14, 22),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 40)
					}, {
						create("UICorner", { CornerRadius = UDim.new(0, 6) }),
						create("UIStroke", {
							Color = theme.Outline,
							Thickness = 1
						}),
						create("UIListLayout", {
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							Padding = UDim.new(0, 4),
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
						create("UIPadding", {
							PaddingTop = UDim.new(0, 6),
							PaddingBottom = UDim.new(0, 6),
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8)
						})
					})

					local header = create("TextLabel", {
						Parent = section,
						BackgroundTransparency = 1,
						Font = theme.Font,
						Text = titleText,
						TextColor3 = theme.Accent,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = UDim2.new(1, 0, 0, 18)
					})

					local layout = section:FindFirstChildOfClass("UIListLayout")
					layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						section.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 12)
					end)

					self.Sections[titleText] = section
					return section
				end
			}

			tabButton.MouseEnter:Connect(function()
				if currentTab ~= tab then
					tween(bg, TweenPresets.Fast, {BackgroundColor3 = Color3.fromRGB(20, 20, 32)})
				end
			end)

			tabButton.MouseLeave:Connect(function()
				if currentTab ~= tab then
					tween(bg, TweenPresets.Fast, {BackgroundColor3 = Color3.fromRGB(18, 18, 28)})
				end
			end)

			tabButton.MouseButton1Click:Connect(function()
				setActiveTab(tab)
				tween(bg, TweenPresets.Fast, {BackgroundColor3 = Color3.fromRGB(24, 24, 38)})
				tween(indicator, TweenPresets.Smooth, {Size = UDim2.new(0, 3, 1, 0)})
				for _, other in pairs(tabs) do
					if other ~= tab then
						local otherBg = other.Frame.Parent.Parent:FindFirstChild(other.Name, true)
					end
				end
			end)

			if not currentTab then
				setActiveTab(tab)
				bg.BackgroundColor3 = Color3.fromRGB(24, 24, 38)
				indicator.Size = UDim2.new(0, 3, 1, 0)
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

function NeonUI.CreateNotificationManager(window: WindowObject)
	local themeName = "NeonDarkRed"
	local theme = Themes[themeName] or DefaultTheme
	return NotificationManager.new(window.ScreenGui, theme)
end

function NeonUI.RegisterElement(name: string, ctor: (Instance, Theme, any) -> any)
	registerElement(name, ctor)
end

function NeonUI.CreateElement(kind: string, parent: Instance, options: any?): any
	options = options or {}
	local theme = Themes["NeonDarkRed"] or DefaultTheme
	local ctor = ElementRegistry[kind]
	if not ctor then
		error("NeonUI: Unknown element kind '" .. kind .. "'")
	end
	return ctor(parent, theme, options)
end

function NeonUI.GetVersion()
	return VERSION
end

return NeonUI
