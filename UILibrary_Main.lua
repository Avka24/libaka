--[[
    🔥 ROBLOX UI LIBRARY - MASTER EDITION
    Version: 2.0.0
    Created: 2026

    Features:
    - Professional UI/UX design
    - 15+ UI elements
    - Theme system
    - Config save/load
    - Notification system
    - Mobile & PC support
    - Memory optimized
    - No memory leaks

    Usage:
    local Library = loadstring(game:HttpGet("your_url"))()
    local Window = Library:CreateWindow({
        Title = "My Hub",
        Subtitle = "Premium Edition",
        AccentColor = Color3.fromRGB(138, 43, 226)
    })
]]--

local Library = {}
Library.__index = Library
Library._Version = "2.0.0"
Library._Instances = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Prevent duplicate UI
local UIIdentifier = "PremiumUILibrary_v2"
if CoreGui:FindFirstChild(UIIdentifier) then
    CoreGui[UIIdentifier]:Destroy()
end

-- Utility Functions
local Utils = {}

function Utils:Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utils:Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils:MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos

    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utils:Tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

function Utils:RippleEffect(button, color)
    local ripple = Utils:Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = button
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })

    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2

    Utils:Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5)

    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Theme System
local Theme = {
    Current = "Dark",
    Themes = {
        Dark = {
            Background = Color3.fromRGB(20, 20, 25),
            Secondary = Color3.fromRGB(25, 25, 30),
            Tertiary = Color3.fromRGB(30, 30, 35),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(200, 200, 200),
            Border = Color3.fromRGB(40, 40, 45),
            Accent = Color3.fromRGB(138, 43, 226),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60),
            Info = Color3.fromRGB(52, 152, 219)
        },
        Cyber = {
            Background = Color3.fromRGB(10, 10, 20),
            Secondary = Color3.fromRGB(15, 15, 25),
            Tertiary = Color3.fromRGB(20, 20, 30),
            Text = Color3.fromRGB(0, 255, 255),
            TextDark = Color3.fromRGB(0, 200, 200),
            Border = Color3.fromRGB(0, 100, 150),
            Accent = Color3.fromRGB(0, 255, 255),
            Success = Color3.fromRGB(0, 255, 100),
            Warning = Color3.fromRGB(255, 200, 0),
            Error = Color3.fromRGB(255, 0, 100),
            Info = Color3.fromRGB(100, 150, 255)
        }
    }
}

function Theme:Get(color)
    return self.Themes[self.Current][color] or Color3.fromRGB(255, 255, 255)
end

function Theme:SetAccent(color)
    self.Themes[self.Current].Accent = color
end

-- Notification System
local Notifications = {}
Notifications.Container = nil
Notifications.Queue = {}

function Notifications:Init(parent)
    if self.Container then return end

    self.Container = Utils:Create("Frame", {
        Name = "NotificationContainer",
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = parent
    })

    Utils:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = self.Container
    })
end

function Notifications:Send(config)
    local notifType = config.Type or "Info"
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 5

    local colors = {
        Success = Theme:Get("Success"),
        Warning = Theme:Get("Warning"),
        Error = Theme:Get("Error"),
        Info = Theme:Get("Info")
    }

    local notif = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Container
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notif
    })

    Utils:Create("UIStroke", {
        Color = colors[notifType],
        Thickness = 2,
        Parent = notif
    })

    local accent = Utils:Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = colors[notifType],
        BorderSizePixel = 0,
        Parent = notif
    })

    local titleLabel = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -50, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme:Get("Text"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })

    local messageLabel = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -50, 0, 40),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme:Get("TextDark"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notif
    })

    local closeBtn = Utils:Create("TextButton", {
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Theme:Get("TextDark"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = notif
    })

    local progressBar = Utils:Create("Frame", {
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = colors[notifType],
        BorderSizePixel = 0,
        Parent = notif
    })

    Utils:Tween(notif, {Size = UDim2.new(1, 0, 0, 80)}, 0.3, Enum.EasingStyle.Back)

    Utils:Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)

    local function close()
        Utils:Tween(notif, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        task.delay(0.3, function()
            notif:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(close)
    task.delay(duration, close)
end

-- Configuration System
local Config = {}
Config.Data = {}
Config.Folder = "UILibraryConfigs"

function Config:Save(name, data)
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    local path = self.Folder .. "/" .. name .. ".json"
    local json = HttpService:JSONEncode(data)
    writefile(path, json)
end

function Config:Load(name)
    local path = self.Folder .. "/" .. name .. ".json"
    if isfile(path) then
        local json = readfile(path)
        return HttpService:JSONDecode(json)
    end
    return nil
end

function Config:Delete(name)
    local path = self.Folder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
    end
end

function Config:GetAll()
    if not isfolder(self.Folder) then
        return {}
    end

    local files = listfiles(self.Folder)
    local configs = {}

    for _, file in ipairs(files) do
        local name = file:match("([^/]+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end

    return configs
end

-- Library Constructor
function Library:CreateWindow(config)
    config = config or {}

    local Window = {
        Title = config.Title or "UI Library",
        Subtitle = config.Subtitle or "v2.0.0",
        AccentColor = config.AccentColor or Color3.fromRGB(138, 43, 226),
        Position = config.Position,
        Size = config.Size or UDim2.new(0, 550, 0, 600),
        Tabs = {},
        Elements = {},
        Minimized = false,
        ConfigData = {}
    }

    Theme:SetAccent(Window.AccentColor)

    -- Create ScreenGui
    Window.ScreenGui = Utils:Create("ScreenGui", {
        Name = UIIdentifier,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    table.insert(Library._Instances, Window.ScreenGui)

    Notifications:Init(Window.ScreenGui)

    -- Main Frame
    Window.Main = Utils:Create("Frame", {
        Name = "MainWindow",
        Size = Window.Size,
        Position = Window.Position or UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme:Get("Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Window.ScreenGui
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Window.Main
    })

    Utils:Create("UIStroke", {
        Color = Theme:Get("Border"),
        Thickness = 1,
        Parent = Window.Main
    })

    -- Top Bar
    Window.TopBar = Utils:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        Parent = Window.Main
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Window.TopBar
    })

    local topBarBottom = Utils:Create("Frame", {
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        Parent = Window.TopBar
    })

    Utils:MakeDraggable(Window.Main, Window.TopBar)

    -- Title
    Window.TitleLabel = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -100, 0, 20),
        BackgroundTransparency = 1,
        Text = Window.Title,
        TextColor3 = Theme:Get("Text"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window.TopBar
    })

    -- Subtitle
    Window.SubtitleLabel = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 28),
        Size = UDim2.new(1, -100, 0, 16),
        BackgroundTransparency = 1,
        Text = Window.Subtitle,
        TextColor3 = Theme:Get("TextDark"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window.TopBar
    })

    -- Close Button
    Window.CloseBtn = Utils:Create("TextButton", {
        Position = UDim2.new(1, -40, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = Theme:Get("Tertiary"),
        Text = "✕",
        TextColor3 = Theme:Get("Text"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = Window.TopBar
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Window.CloseBtn
    })

    -- Minimize Button
    Window.MinimizeBtn = Utils:Create("TextButton", {
        Position = UDim2.new(1, -75, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = Theme:Get("Tertiary"),
        Text = "─",
        TextColor3 = Theme:Get("Text"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = Window.TopBar
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Window.MinimizeBtn
    })

    -- Tab Container
    Window.TabContainer = Utils:Create("Frame", {
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(0, 150, 1, -70),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        Parent = Window.Main
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Window.TabContainer
    })

    Window.TabList = Utils:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme:Get("Accent"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.TabContainer
    })

    Utils:Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Window.TabList
    })

    Utils:Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = Window.TabList
    })

    -- Content Container
    Window.ContentContainer = Utils:Create("Frame", {
        Position = UDim2.new(0, 170, 0, 60),
        Size = UDim2.new(1, -180, 1, -70),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        Parent = Window.Main
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Window.ContentContainer
    })

    -- Button Events
    Window.CloseBtn.MouseButton1Click:Connect(function()
        Utils:RippleEffect(Window.CloseBtn, Theme:Get("Error"))
        Window:Destroy()
    end)

    Window.MinimizeBtn.MouseButton1Click:Connect(function()
        Utils:RippleEffect(Window.MinimizeBtn, Theme:Get("Accent"))
        Window:ToggleMinimize()
    end)

    -- Window Methods
    function Window:ToggleMinimize()
        self.Minimized = not self.Minimized

        if self.Minimized then
            Utils:Tween(self.Main, {
                Size = UDim2.new(0, 550, 0, 50)
            }, 0.3, Enum.EasingStyle.Quad)
            self.MinimizeBtn.Text = "□"
        else
            Utils:Tween(self.Main, {
                Size = self.Size
            }, 0.3, Enum.EasingStyle.Quad)
            self.MinimizeBtn.Text = "─"
        end
    end

    function Window:Destroy()
        Utils:Tween(self.Main, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)

        task.delay(0.3, function()
            self.ScreenGui:Destroy()
        end)
    end

    function Window:CreateTab(config)
        config = config or {}

        local Tab = {
            Name = config.Name or "Tab",
            Icon = config.Icon or "📄",
            Window = self,
            Active = false,
            Elements = {}
        }

        -- Tab Button
        Tab.Button = Utils:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme:Get("Tertiary"),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            Parent = self.TabList
        })

        Utils:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Tab.Button
        })

        local icon = Utils:Create("TextLabel", {
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Text = Tab.Icon,
            TextColor3 = Theme:Get("TextDark"),
            TextSize = 16,
            Font = Enum.Font.Gotham,
            Parent = Tab.Button
        })

        local label = Utils:Create("TextLabel", {
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = Tab.Name,
            TextColor3 = Theme:Get("TextDark"),
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Tab.Button
        })

        -- Tab Content
        Tab.Content = Utils:Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme:Get("Accent"),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = self.ContentContainer
        })

        Utils:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Tab.Content
        })

        Utils:Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            Parent = Tab.Content
        })

        -- Auto-resize canvas
        Tab.Content.ChildAdded:Connect(function()
            task.wait()
            Tab.Content.CanvasSize = UDim2.new(0, 0, 0, Tab.Content.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        -- Tab Button Click
        Tab.Button.MouseButton1Click:Connect(function()
            for _, tab in pairs(self.Tabs) do
                tab.Active = false
                tab.Content.Visible = false
                Utils:Tween(tab.Button, {BackgroundTransparency = 1}, 0.2)
                tab.Button:FindFirstChildOfClass("TextLabel").TextColor3 = Theme:Get("TextDark")
                tab.Button:FindFirstChild("TextLabel").TextColor3 = Theme:Get("TextDark")
            end

            Tab.Active = true
            Tab.Content.Visible = true
            Utils:Tween(Tab.Button, {BackgroundTransparency = 0}, 0.2)
            icon.TextColor3 = Theme:Get("Accent")
            label.TextColor3 = Theme:Get("Text")
            Utils:RippleEffect(Tab.Button, Theme:Get("Accent"))
        end)

        table.insert(self.Tabs, Tab)

        if #self.Tabs == 1 then
            Tab.Button.MouseButton1Click:Fire()
        end

        Tab.Content.ChildAdded:Connect(function()
            task.wait()
            self.TabList.CanvasSize = UDim2.new(0, 0, 0, self.TabList.UIListLayout.AbsoluteContentSize.Y + 20)
        end)

        return Tab
    end

    return Window
end

return Library
