-- UI ELEMENTS MODULE
-- This module contains all UI element constructors

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Elements = {}

-- Assume Utils and Theme are passed in or available globally
local Utils, Theme

function Elements:Init(utilsTable, themeTable)
    Utils = utilsTable
    Theme = themeTable
end

-- BUTTON ELEMENT
function Elements:CreateButton(tab, config)
    config = config or {}

    local Button = {
        Name = config.Name or "Button",
        Callback = config.Callback or function() end,
        Enabled = true
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme:Get("Tertiary"),
        BorderSizePixel = 0,
        Parent = tab.Content
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container
    })

    local button = Utils:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = Button.Name,
        TextColor3 = Theme:Get("Text"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = container
    })

    button.MouseButton1Click:Connect(function()
        if Button.Enabled then
            Utils:RippleEffect(container, Theme:Get("Accent"))
            pcall(Button.Callback)
        end
    end)

    button.MouseEnter:Connect(function()
        if Button.Enabled then
            Utils:Tween(container, {BackgroundColor3 = Theme:Get("Border")}, 0.2)
        end
    end)

    button.MouseLeave:Connect(function()
        Utils:Tween(container, {BackgroundColor3 = Theme:Get("Tertiary")}, 0.2)
    end)

    function Button:SetEnabled(state)
        self.Enabled = state
        button.TextColor3 = state and Theme:Get("Text") or Theme:Get("TextDark")
    end

    function Button:SetText(text)
        self.Name = text
        button.Text = text
    end

    return Button
end

-- TOGGLE ELEMENT
function Elements:CreateToggle(tab, config)
    config = config or {}

    local Toggle = {
        Name = config.Name or "Toggle",
        Default = config.Default or false,
        Callback = config.Callback or function() end,
        State = config.Default or false
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme:Get("Tertiary"),
        BorderSizePixel = 0,
        Parent = tab.Content
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container
    })

    local label = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        Text = Toggle.Name,
        TextColor3 = Theme:Get("Text"),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local toggleFrame = Utils:Create("Frame", {
        Position = UDim2.new(1, -55, 0.5, 0),
        Size = UDim2.new(0, 45, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Toggle.State and Theme:Get("Accent") or Theme:Get("Border"),
        BorderSizePixel = 0,
        Parent = container
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleFrame
    })

    local toggleCircle = Utils:Create("Frame", {
        Position = Toggle.State and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = toggleFrame
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleCircle
    })

    local button = Utils:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })

    button.MouseButton1Click:Connect(function()
        Toggle.State = not Toggle.State

        Utils:Tween(toggleFrame, {
            BackgroundColor3 = Toggle.State and Theme:Get("Accent") or Theme:Get("Border")
        }, 0.3)

        Utils:Tween(toggleCircle, {
            Position = Toggle.State and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Quad)

        pcall(Toggle.Callback, Toggle.State)
    end)

    function Toggle:SetState(state)
        self.State = state

        Utils:Tween(toggleFrame, {
            BackgroundColor3 = state and Theme:Get("Accent") or Theme:Get("Border")
        }, 0.3)

        Utils:Tween(toggleCircle, {
            Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Quad)
    end

    return Toggle
end

-- SLIDER ELEMENT
function Elements:CreateSlider(tab, config)
    config = config or {}

    local Slider = {
        Name = config.Name or "Slider",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 50,
        Increment = config.Increment or 1,
        Callback = config.Callback or function() end,
        Value = config.Default or 50
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Theme:Get("Tertiary"),
        BorderSizePixel = 0,
        Parent = tab.Content
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container
    })

    local label = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -80, 0, 20),
        BackgroundTransparency = 1,
        Text = Slider.Name,
        TextColor3 = Theme:Get("Text"),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local valueLabel = Utils:Create("TextLabel", {
        Position = UDim2.new(1, -65, 0, 8),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(Slider.Value),
        TextColor3 = Theme:Get("Accent"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })

    local sliderBack = Utils:Create("Frame", {
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 6),
        BackgroundColor3 = Theme:Get("Border"),
        BorderSizePixel = 0,
        Parent = container
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBack
    })

    local sliderFill = Utils:Create("Frame", {
        Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0),
        BackgroundColor3 = Theme:Get("Accent"),
        BorderSizePixel = 0,
        Parent = sliderBack
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    })

    local sliderButton = Utils:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = sliderBack
    })

    local dragging = false

    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    sliderButton.MouseMoved:Connect(function(x, y)
        if dragging then
            local pos = math.clamp((x - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            local value = math.floor((Slider.Min + (Slider.Max - Slider.Min) * pos) / Slider.Increment + 0.5) * Slider.Increment
            value = math.clamp(value, Slider.Min, Slider.Max)

            Slider.Value = value
            valueLabel.Text = tostring(value)

            Utils:Tween(sliderFill, {
                Size = UDim2.new(pos, 0, 1, 0)
            }, 0.1)

            pcall(Slider.Callback, value)
        end
    end)

    function Slider:SetValue(value)
        value = math.clamp(value, self.Min, self.Max)
        self.Value = value
        valueLabel.Text = tostring(value)

        local pos = (value - self.Min) / (self.Max - self.Min)
        Utils:Tween(sliderFill, {
            Size = UDim2.new(pos, 0, 1, 0)
        }, 0.3)
    end

    return Slider
end

-- DROPDOWN ELEMENT
function Elements:CreateDropdown(tab, config)
    config = config or {}

    local Dropdown = {
        Name = config.Name or "Dropdown",
        Options = config.Options or {"Option 1", "Option 2"},
        Default = config.Default or config.Options[1],
        Callback = config.Callback or function() end,
        Selected = config.Default or config.Options[1],
        Open = false
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme:Get("Tertiary"),
        BorderSizePixel = 0,
        Parent = tab.Content
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container
    })

    local label = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -80, 0, 40),
        BackgroundTransparency = 1,
        Text = Dropdown.Name,
        TextColor3 = Theme:Get("Text"),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local selectedLabel = Utils:Create("TextLabel", {
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 55, 0, 40),
        BackgroundTransparency = 1,
        Text = Dropdown.Selected,
        TextColor3 = Theme:Get("Accent"),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = container
    })

    local arrow = Utils:Create("TextLabel", {
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme:Get("TextDark"),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = container
    })

    local optionContainer = Utils:Create("Frame", {
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = container
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = optionContainer
    })

    Utils:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        Parent = optionContainer
    })

    Utils:Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = optionContainer
    })

    for _, option in ipairs(Dropdown.Options) do
        local optionBtn = Utils:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme:Get("Tertiary"),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Theme:Get("Text"),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Parent = optionContainer
        })

        optionBtn.MouseEnter:Connect(function()
            Utils:Tween(optionBtn, {BackgroundTransparency = 0}, 0.2)
        end)

        optionBtn.MouseLeave:Connect(function()
            Utils:Tween(optionBtn, {BackgroundTransparency = 1}, 0.2)
        end)

        optionBtn.MouseButton1Click:Connect(function()
            Dropdown.Selected = option
            selectedLabel.Text = option
            Dropdown:Toggle()
            pcall(Dropdown.Callback, option)
        end)
    end

    local button = Utils:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })

    button.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)

    function Dropdown:Toggle()
        self.Open = not self.Open

        if self.Open then
            optionContainer.Visible = true
            local height = #self.Options * 32 + 10
            Utils:Tween(optionContainer, {
                Size = UDim2.new(1, 0, 0, height)
            }, 0.3, Enum.EasingStyle.Quad)
            Utils:Tween(arrow, {Rotation = 180}, 0.3)
            Utils:Tween(container, {
                Size = UDim2.new(1, 0, 0, 40 + height + 5)
            }, 0.3, Enum.EasingStyle.Quad)
        else
            Utils:Tween(optionContainer, {
                Size = UDim2.new(1, 0, 0, 0)
            }, 0.3, Enum.EasingStyle.Quad)
            Utils:Tween(arrow, {Rotation = 0}, 0.3)
            Utils:Tween(container, {
                Size = UDim2.new(1, 0, 0, 40)
            }, 0.3, Enum.EasingStyle.Quad)
            task.delay(0.3, function()
                optionContainer.Visible = false
            end)
        end
    end

    function Dropdown:SetValue(value)
        if table.find(self.Options, value) then
            self.Selected = value
            selectedLabel.Text = value
        end
    end

    return Dropdown
end

-- INPUT ELEMENT
function Elements:CreateInput(tab, config)
    config = config or {}

    local Input = {
        Name = config.Name or "Input",
        Default = config.Default or "",
        Placeholder = config.Placeholder or "Enter text...",
        NumberOnly = config.NumberOnly or false,
        Callback = config.Callback or function() end,
        Value = config.Default or ""
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme:Get("Tertiary"),
        BorderSizePixel = 0,
        Parent = tab.Content
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container
    })

    local label = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Text = Input.Name,
        TextColor3 = Theme:Get("Text"),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local inputFrame = Utils:Create("Frame", {
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 28),
        BackgroundColor3 = Theme:Get("Secondary"),
        BorderSizePixel = 0,
        Parent = container
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = inputFrame
    })

    local inputBox = Utils:Create("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Input.Value,
        PlaceholderText = Input.Placeholder,
        TextColor3 = Theme:Get("Text"),
        PlaceholderColor3 = Theme:Get("TextDark"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame
    })

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local value = inputBox.Text

            if Input.NumberOnly then
                value = tonumber(value) or Input.Value
                inputBox.Text = tostring(value)
            end

            Input.Value = value
            pcall(Input.Callback, value)
        end
    end)

    if Input.NumberOnly then
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = inputBox.Text
            if text ~= "" and not tonumber(text) then
                inputBox.Text = text:sub(1, #text - 1)
            end
        end)
    end

    function Input:SetValue(value)
        self.Value = value
        inputBox.Text = tostring(value)
    end

    return Input
end

-- LABEL ELEMENT
function Elements:CreateLabel(tab, config)
    config = config or {}

    local Label = {
        Text = config.Text or "Label",
        Color = config.Color or Theme:Get("Text")
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })

    local label = Utils:Create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = Label.Text,
        TextColor3 = Label.Color,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = container
    })

    function Label:SetText(text)
        self.Text = text
        label.Text = text
    end

    function Label:SetColor(color)
        self.Color = color
        label.TextColor3 = color
    end

    return Label
end

-- SECTION/DIVIDER
function Elements:CreateSection(tab, config)
    config = config or {}

    local Section = {
        Name = config.Name or "Section"
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })

    local label = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(0, 100, 0, 20),
        BackgroundTransparency = 1,
        Text = Section.Name,
        TextColor3 = Theme:Get("Accent"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local line = Utils:Create("Frame", {
        Position = UDim2.new(0, 120, 0, 18),
        Size = UDim2.new(1, -135, 0, 1),
        BackgroundColor3 = Theme:Get("Border"),
        BorderSizePixel = 0,
        Parent = container
    })

    return Section
end

-- KEYBIND ELEMENT
function Elements:CreateKeybind(tab, config)
    config = config or {}

    local Keybind = {
        Name = config.Name or "Keybind",
        Default = config.Default or Enum.KeyCode.E,
        Callback = config.Callback or function() end,
        Key = config.Default or Enum.KeyCode.E,
        Listening = false
    }

    local container = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme:Get("Tertiary"),
        BorderSizePixel = 0,
        Parent = tab.Content
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container
    })

    local label = Utils:Create("TextLabel", {
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -100, 0, 40),
        BackgroundTransparency = 1,
        Text = Keybind.Name,
        TextColor3 = Theme:Get("Text"),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local keyButton = Utils:Create("TextButton", {
        Position = UDim2.new(1, -75, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 25),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:Get("Secondary"),
        Text = Keybind.Key.Name,
        TextColor3 = Theme:Get("Accent"),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        Parent = container
    })

    Utils:Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = keyButton
    })

    keyButton.MouseButton1Click:Connect(function()
        Keybind.Listening = true
        keyButton.Text = "..."
        Utils:Tween(keyButton, {BackgroundColor3 = Theme:Get("Accent")}, 0.2)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if Keybind.Listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind.Key = input.KeyCode
                    keyButton.Text = input.KeyCode.Name
                    Keybind.Listening = false
                    Utils:Tween(keyButton, {BackgroundColor3 = Theme:Get("Secondary")}, 0.2)
                end
            elseif input.KeyCode == Keybind.Key then
                pcall(Keybind.Callback)
            end
        end
    end)

    function Keybind:SetKey(key)
        self.Key = key
        keyButton.Text = key.Name
    end

    return Keybind
end

return Elements
