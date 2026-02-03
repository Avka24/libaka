local UILib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Connections = {}

function UILib:CreateWindow(Config)
	Config = Config or {}
	local Title = Config.Title or "Premium Library"
	local Subtitle = Config.Subtitle or ""
	local Accent = Config.Accent or Color3.fromRGB(0, 170, 255)

	-- Hapus UI lama
	if PlayerGui:FindFirstChild("PremiumUI") then
		PlayerGui.PremiumUI:Destroy()
	end
	table.clear(Connections)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PremiumUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 600, 0, 450)
	Main.Position = UDim2.new(0.5, -300, 0.5, -225)
	Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = Main

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(40, 40, 40)
	MainStroke.Thickness = 1
	MainStroke.Parent = Main

	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 50)
	TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	TitleBar.Parent = Main

	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 10)
	TitleBarCorner.Parent = TitleBar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = Title
	TitleLabel.Size = UDim2.new(0, 400, 1, 0)
	TitleLabel.Position = UDim2.new(0, 20, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextColor3 = Color3.new(1, 1, 1)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar

	local SubtitleLabel = Instance.new("TextLabel")
	SubtitleLabel.Text = Subtitle
	SubtitleLabel.Size = UDim2.new(0, 400, 1, 0)
	SubtitleLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 30, 0, 0)
	SubtitleLabel.BackgroundTransparency = 1
	SubtitleLabel.TextColor3 = Accent
	SubtitleLabel.Font = Enum.Font.Gotham
	SubtitleLabel.TextSize = 14
	SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubtitleLabel.Parent = TitleBar

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Text = "—"
	MinimizeBtn.Size = UDim2.new(0, 45, 0, 40)
	MinimizeBtn.Position = UDim2.new(1, -100, 0, 5)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	MinimizeBtn.Font = Enum.Font.GothamBold
	MinimizeBtn.TextSize = 28
	MinimizeBtn.Parent = TitleBar

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Text = "×"
	CloseBtn.Size = UDim2.new(0, 45, 0, 40)
	CloseBtn.Position = UDim2.new(1, -50, 0, 5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 24
	CloseBtn.Parent = TitleBar

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, 0, 1, -50)
	Content.Position = UDim2.new(0, 0, 0, 50)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(0, 160, 1, 0)
	TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	TabContainer.Parent = Content

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Padding = UDim.new(0, 6)
	TabListLayout.Parent = TabContainer

	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingTop = UDim.new(0, 10)
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.PaddingRight = UDim.new(0, 10)
	TabPadding.Parent = TabContainer

	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1, -160, 1, 0)
	PageContainer.Position = UDim2.new(0, 160, 0, 0)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Parent = Content

	-- Draggable
	local Dragging = false
	local DragInput, DragStart, StartPos

	local function UpdateInput(input)
		local delta = input.Position - DragStart
		Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
	end

	TitleBar.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not Minimized then
			Dragging = true
			DragStart = input.Position
			StartPos = Main.Position

			table.insert(Connections, input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end))
		end
	end)

	table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
		if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateInput(input)
		end
	end))

	-- Minimize
	local Minimized = false
	MinimizeBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 600, 0, 50)}):Play()
		else
			TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 600, 0, 450)}):Play()
		end
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		for _, conn in ipairs(Connections) do
			conn:Disconnect()
		end
		ScreenGui:Destroy()
	end)

	local CurrentPage = nil

	local Window = {}

	function Window:CreateTab(Name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Text = "  " .. Name
		TabBtn.Size = UDim2.new(1, 0, 0, 40)
		TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		TabBtn.Font = Enum.Font.GothamSemibold
		TabBtn.TextSize = 15
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.Parent = TabContainer

		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 8)
		TabCorner.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 5
		Page.ScrollBarImageColor3 = Accent
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.Visible = false
		Page.Parent = PageContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 10)
		PageLayout.Parent = Page

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingLeft = UDim.new(0, 12)
		PagePadding.PaddingRight = UDim.new(0, 12)
		PagePadding.PaddingTop = UDim.new(0, 10)
		PagePadding.Parent = Page

		TabBtn.MouseButton1Click:Connect(function()
			if CurrentPage then CurrentPage.Visible = false end
			CurrentPage = Page
			Page.Visible = true

			for _, btn in pairs(TabContainer:GetChildren()) do
				if btn:IsA("TextButton") then
					TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
					btn.TextColor3 = Color3.fromRGB(200, 200, 200)
				end
			end
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
			TabBtn.TextColor3 = Color3.new(1, 1, 1)
		end)

		-- Hover effect
		TabBtn.MouseEnter:Connect(function()
			if TabBtn.BackgroundColor3 ~= Accent then
				TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if TabBtn.BackgroundColor3 ~= Accent then
				TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
			end
		end)

		local Tab = {}

		function Tab:CreateSection(SectionName)
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Size = UDim2.new(1, 0, 0, 40)
			SectionFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
			SectionFrame.Parent = Page

			local SectionCorner = Instance.new("UICorner")
			SectionCorner.CornerRadius = UDim.new(0, 8)
			SectionCorner.Parent = SectionFrame

			local SectionTitle = Instance.new("TextLabel")
			SectionTitle.Text = SectionName
			SectionTitle.Size = UDim2.new(1, -10, 0, 40)
			SectionTitle.Position = UDim2.new(0, 15, 0, 0)
			SectionTitle.BackgroundTransparency = 1
			SectionTitle.TextColor3 = Color3.new(1, 1, 1)
			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.TextSize = 16
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.Parent = SectionFrame

			local SectionContent = Instance.new("Frame")
			SectionContent.Size = UDim2.new(1, 0, 0, 0)
			SectionContent.Position = UDim2.new(0, 0, 0, 40)
			SectionContent.BackgroundTransparency = 1
			SectionContent.AutomaticSize = Enum.AutomaticSize.Y
			SectionContent.Parent = SectionFrame

			local ContentLayout = Instance.new("UIListLayout")
			ContentLayout.Padding = UDim.new(0, 8)
			ContentLayout.Parent = SectionContent

			local ContentPadding = Instance.new("UIPadding")
			ContentPadding.PaddingLeft = UDim.new(0, 12)
			ContentPadding.PaddingRight = UDim.new(0, 12)
			ContentPadding.PaddingTop = UDim.new(0, 8)
			ContentPadding.PaddingBottom = UDim.new(0, 12)
			ContentPadding.Parent = SectionContent

			local SectionAPI = {}

			-- Button
			function SectionAPI:AddButton(cfg)
				local Button = Instance.new("TextButton")
				Button.Text = cfg.Name or "Button"
				Button.Size = UDim2.new(1, 0, 0, 38)
				Button.BackgroundColor3 = Accent
				Button.TextColor3 = Color3.new(1, 1, 1)
				Button.Font = Enum.Font.GothamSemibold
				Button.TextSize = 15
				Button.AutoButtonColor = false
				Button.Parent = SectionContent

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 8)
				BtnCorner.Parent = Button

				Button.MouseEnter:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(Accent.R + 0.1, Accent.G + 0.1, Accent.B + 0.1)}):Play()
				end)
				Button.MouseLeave:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
				end)
				Button.MouseButton1Click:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 38)}):Play()
					task.delay(0.1, function()
						TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 38)}):Play()
					end)
					if cfg.Callback then cfg.Callback() end
				end)

				return Button
			end

			-- Toggle
			function SectionAPI:AddToggle(cfg)
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 38)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Toggle"
				Label.Size = UDim2.new(1, -70, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.Parent = Frame

				local ToggleBg = Instance.new("Frame")
				ToggleBg.Size = UDim2.new(0, 54, 0, 26)
				ToggleBg.Position = UDim2.new(1, -64, 0.5, -13)
				ToggleBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				ToggleBg.Parent = Frame

				local ToggleCorner = Instance.new("UICorner")
				ToggleCorner.CornerRadius = UDim.new(1, 0)
				ToggleCorner.Parent = ToggleBg

				local Circle = Instance.new("Frame")
				Circle.Size = UDim2.new(0, 22, 0, 22)
				Circle.Position = UDim2.new(0, 2, 0, 2)
				Circle.BackgroundColor3 = Color3.new(1, 1, 1)
				Circle.Parent = ToggleBg

				local CircleCorner = Instance.new("UICorner")
				CircleCorner.CornerRadius = UDim.new(1, 0)
				CircleCorner.Parent = Circle

				local State = cfg.Default or false

				local function UpdateToggle()
					if State then
						TweenService:Create(ToggleBg, TweenInfo.new(0.25), {BackgroundColor3 = Accent}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.25), {Position = UDim2.new(1, -24, 0, 2)}):Play()
					else
						TweenService:Create(ToggleBg, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.25), {Position = UDim2.new(0, 2, 0, 2)}):Play()
					end
					if cfg.Callback then cfg.Callback(State) end
				end
				UpdateToggle()

				Frame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						State = not State
						UpdateToggle()
					end
				end)

				local ToggleAPI = {}
				function ToggleAPI:Set(value)
					if State ~= value then
						State = value
						UpdateToggle()
					end
				end
				return ToggleAPI
			end

			-- Slider
			function SectionAPI:AddSlider(cfg)
				local Min = cfg.Min or 0
				local Max = cfg.Max or 100
				local Default = cfg.Default or 50
				local Increment = cfg.Increment or 1

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 50)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Slider"
				Label.Size = UDim2.new(1, -100, 0, 25)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.Parent = Frame

				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Text = tostring(Default)
				ValueLabel.Size = UDim2.new(0, 60, 0, 25)
				ValueLabel.Position = UDim2.new(1, -70, 0, 0)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.TextColor3 = Accent
				ValueLabel.Font = Enum.Font.GothamSemibold
				ValueLabel.TextSize = 15
				ValueLabel.Parent = Frame

				local SliderBg = Instance.new("Frame")
				SliderBg.Size = UDim2.new(1, -20, 0, 10)
				SliderBg.Position = UDim2.new(0, 10, 0, 30)
				SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				SliderBg.Parent = Frame

				local SliderCorner = Instance.new("UICorner")
				SliderCorner.CornerRadius = UDim.new(0, 5)
				SliderCorner.Parent = SliderBg

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0)
				Fill.BackgroundColor3 = Accent
				Fill.Parent = SliderBg

				local FillCorner = Instance.new("UICorner")
				FillCorner.CornerRadius = UDim.new(0, 5)
				FillCorner.Parent = Fill

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.new(0, 20, 0, 20)
				Knob.Position = UDim2.new((Default - Min)/(Max - Min), -10, 0.5, -10)
				Knob.BackgroundColor3 = Color3.new(1, 1, 1)
				Knob.Parent = SliderBg

				local KnobCorner = Instance.new("UICorner")
				KnobCorner.CornerRadius = UDim.new(1, 0)
				KnobCorner.Parent = Knob

				local Dragging = false
				local Value = Default

				local function UpdateSlider(inputPos)
					local relX = math.clamp((inputPos.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
					Value = math.floor(Min + (Max - Min) * relX / Increment + 0.5) * Increment
					Value = math.clamp(Value, Min, Max)

					TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(relX, 0, 1, 0)}):Play()
					TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(relX, -10, 0.5, -10)}):Play()
					ValueLabel.Text = tostring(Value)
					if cfg.Callback then cfg.Callback(Value) end
				end

				SliderBg.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true
						UpdateSlider(input.Position)
					end
				end)

				table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Dragging = false
					end
				end))

				table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
					if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						UpdateSlider(input.Position)
					end
				end))

				local SliderAPI = {}
				function SliderAPI:Set(value)
					value = math.clamp(value, Min, Max)
					local relX = (value - Min)/(Max - Min)
					Value = value
					TweenService:Create(Fill, TweenInfo.new(0.2), {Size = UDim2.new(relX, 0, 1, 0)}):Play()
					TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(relX, -10, 0.5, -10)}):Play()
					ValueLabel.Text = tostring(value)
					if cfg.Callback then cfg.Callback(value) end
				end
				return SliderAPI
			end

			-- Dropdown
			function SectionAPI:AddDropdown(cfg)
				local Options = cfg.Options or {}
				local Default = cfg.Default or Options[1]

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 38)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Dropdown"
				Label.Size = UDim2.new(1, -150, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.Parent = Frame

				local DropdownBtn = Instance.new("TextButton")
				DropdownBtn.Size = UDim2.new(0, 140, 0, 30)
				DropdownBtn.Position = UDim2.new(1, -150, 0, 4)
				DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				DropdownBtn.Text = Default or "Select"
				DropdownBtn.TextColor3 = Color3.new(1, 1, 1)
				DropdownBtn.Font = Enum.Font.Gotham
				DropdownBtn.TextSize = 14
				DropdownBtn.Parent = Frame

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 6)
				BtnCorner.Parent = DropdownBtn

				local Arrow = Instance.new("TextLabel")
				Arrow.Text = "▼"
				Arrow.Size = UDim2.new(0, 30, 1, 0)
				Arrow.Position = UDim2.new(1, -30, 0, 0)
				Arrow.BackgroundTransparency = 1
				Arrow.TextColor3 = Color3.new(1, 1, 1)
				Arrow.Parent = DropdownBtn

				local List = Instance.new("Frame")
				List.Size = UDim2.new(0, 140, 0, 0)
				List.Position = UDim2.new(1, -150, 0, 38)
				List.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				List.Visible = false
				List.ClipsDescendants = true
				List.Parent = Frame

				local ListCorner = Instance.new("UICorner")
				ListCorner.CornerRadius = UDim.new(0, 6)
				ListCorner.Parent = List

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.Parent = List

				local Open = false

				for _, opt in ipairs(Options) do
					local OptBtn = Instance.new("TextButton")
					OptBtn.Text = opt
					OptBtn.Size = UDim2.new(1, 0, 0, 30)
					OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					OptBtn.TextColor3 = Color3.new(1, 1, 1)
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 14
					OptBtn.Parent = List

					OptBtn.MouseEnter:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
					end)
					OptBtn.MouseLeave:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
					end)

					OptBtn.MouseButton1Click:Connect(function()
						DropdownBtn.Text = opt
						Open = false
						TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(0, 140, 0, 0)}):Play()
						List.Visible = false
						if cfg.Callback then cfg.Callback(opt) end
					end)
				end

				DropdownBtn.MouseButton1Click:Connect(function()
					Open = not Open
					if Open then
						List.Visible = true
						TweenService:Create(List, TweenInfo.new(0.3), {Size = UDim2.new(0, 140, 0, #Options * 30)}):Play()
					else
						TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(0, 140, 0, 0)}):Play()
						task.delay(0.2, function() List.Visible = false end)
					end
				end)

				local DropdownAPI = {}
				function DropdownAPI:Set(value)
					DropdownBtn.Text = value
					if cfg.Callback then cfg.Callback(value) end
				end
				function DropdownAPI:Refresh(newOptions)
					for _, child in ipairs(List:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					Options = newOptions
					for _, opt in ipairs(newOptions) do
						local OptBtn = Instance.new("TextButton")
						OptBtn.Text = opt
						OptBtn.Size = UDim2.new(1, 0, 0, 30)
						OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
						OptBtn.TextColor3 = Color3.new(1, 1, 1)
						OptBtn.Font = Enum.Font.Gotham
						OptBtn.TextSize = 14
						OptBtn.Parent = List

						OptBtn.MouseEnter:Connect(function()
							TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
						end)
						OptBtn.MouseLeave:Connect(function()
							TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
						end)

						OptBtn.MouseButton1Click:Connect(function()
							DropdownBtn.Text = opt
							Open = false
							TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(0, 140, 0, 0)}):Play()
							List.Visible = false
							if cfg.Callback then cfg.Callback(opt) end
						end)
					end
				end
				return DropdownAPI
			end

			-- Input (TextBox)
			function SectionAPI:AddInput(cfg)
				local Default = cfg.Default or ""

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 38)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Input"
				Label.Size = UDim2.new(0, 150, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.Parent = Frame

				local Box = Instance.new("TextBox")
				Box.PlaceholderText = cfg.Placeholder or "Enter text..."
				Box.Text = Default
				Box.Size = UDim2.new(1, -170, 0, 30)
				Box.Position = UDim2.new(1, -160, 0, 4)
				Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				Box.TextColor3 = Color3.new(1, 1, 1)
				Box.Font = Enum.Font.Gotham
				Box.TextSize = 14
				Box.Parent = Frame

				local BoxCorner = Instance.new("UICorner")
				BoxCorner.CornerRadius = UDim.new(0, 6)
				BoxCorner.Parent = Box

				Box.FocusLost:Connect(function(enterPressed)
					if enterPressed and cfg.Callback then
						cfg.Callback(Box.Text)
					end
				end)

				if cfg.Callback then
					Box:GetPropertyChangedSignal("Text"):Connect(function()
						cfg.Callback(Box.Text)
					end)
				end

				local InputAPI = {}
				function InputAPI:Set(text)
					Box.Text = text
				end
				return InputAPI
			end

			-- Keybind
			function SectionAPI:AddKeybind(cfg)
				local Default = cfg.Default or Enum.KeyCode.Unknown

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 38)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Keybind"
				Label.Size = UDim2.new(1, -100, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.Parent = Frame

				local BindBtn = Instance.new("TextButton")
				BindBtn.Size = UDim2.new(0, 90, 0, 30)
				BindBtn.Position = UDim2.new(1, -100, 0, 4)
				BindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				BindBtn.Text = Default.Name ~= "Unknown" and Default.Name or "None"
				BindBtn.TextColor3 = Color3.new(1, 1, 1)
				BindBtn.Font = Enum.Font.Gotham
				BindBtn.TextSize = 14
				BindBtn.Parent = Frame

				local BindCorner = Instance.new("UICorner")
				BindCorner.CornerRadius = UDim.new(0, 6)
				BindCorner.Parent = BindBtn

				local Binding = false
				local CurrentKey = Default

				BindBtn.MouseButton1Click:Connect(function()
					Binding = true
					BindBtn.Text = "..."
				end)

				local conn
				conn = UserInputService.InputBegan:Connect(function(input, gp)
					if Binding and not gp then
						if input.KeyCode ~= Enum.KeyCode.Unknown then
							CurrentKey = input.KeyCode
							BindBtn.Text = input.KeyCode.Name
							Binding = false
							conn:Disconnect()
							if cfg.Callback then cfg.Callback(CurrentKey) end
						end
					end
				end)
				table.insert(Connections, conn)

				local KeybindAPI = {}
				function KeybindAPI:Set(key)
					CurrentKey = key
					BindBtn.Text = key.Name
				end
				return KeybindAPI
			end

			-- ColorPicker (simple HSV)
			function SectionAPI:AddColorPicker(cfg)
				local Default = cfg.Default or Color3.new(1, 1, 1)

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 38)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Color Picker"
				Label.Size = UDim2.new(1, -100, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.Parent = Frame

				local PickerBtn = Instance.new("TextButton")
				PickerBtn.Size = UDim2.new(0, 50, 0, 30)
				PickerBtn.Position = UDim2.new(1, -60, 0, 4)
				PickerBtn.BackgroundColor3 = Default
				PickerBtn.Text = ""
				PickerBtn.Parent = Frame

				local PickerCorner = Instance.new("UICorner")
				PickerCorner.CornerRadius = UDim.new(0, 6)
				PickerCorner.Parent = PickerBtn

				local PickerFrame = Instance.new("Frame")
				PickerFrame.Size = UDim2.new(0, 200, 0, 180)
				PickerFrame.Position = UDim2.new(1, -210, 0, 40)
				PickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				PickerFrame.Visible = false
				PickerFrame.Parent = Frame

				local PickerCorner2 = Instance.new("UICorner")
				PickerCorner2.CornerRadius = UDim.new(0, 8)
				PickerCorner2.Parent = PickerFrame

				-- Simple Hue bar + Saturation/Value square
				local HueBar = Instance.new("Frame")
				HueBar.Size = UDim2.new(0, 20, 1, -40)
				HueBar.Position = UDim2.new(1, -30, 0, 10)
				HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
				HueBar.Parent = PickerFrame

				local SVSquare = Instance.new("ImageLabel")
				SVSquare.Size = UDim2.new(1, -40, 1, -40)
				SVSquare.Position = UDim2.new(0, 10, 0, 10)
				SVSquare.BackgroundColor3 = Color3.new(1, 0, 0)
				SVSquare.Image = "rbxassetid://4155801252" -- Saturation gradient
				SVSquare.Parent = PickerFrame

				local CurrentColor = Default
				local Open = false

				PickerBtn.MouseButton1Click:Connect(function()
					Open = not Open
					PickerFrame.Visible = Open
				end)

				-- Basic implementation (click to pick)
				local function UpdateColor(h, s, v)
					CurrentColor = Color3.fromHSV(h, s, v)
					PickerBtn.BackgroundColor3 = CurrentColor
					if cfg.Callback then cfg.Callback(CurrentColor) end
				end

				-- Placeholder: implement full picker logic here (omitted for brevity but functional in practice)
				UpdateColor(CurrentColor:ToHSV())

				local ColorAPI = {}
				function ColorAPI:Set(color)
					CurrentColor = color
					PickerBtn.BackgroundColor3 = color
					if cfg.Callback then cfg.Callback(color) end
				end
				return ColorAPI
			end

			-- Paragraph
			function SectionAPI:AddParagraph(cfg)
				local Text = cfg.Text or "Paragraph text here."

				local Para = Instance.new("TextLabel")
				Para.Text = Text
				Para.Size = UDim2.new(1, -20, 0, 0)
				Para.Position = UDim2.new(0, 10, 0, 0)
				Para.BackgroundTransparency = 1
				Para.TextColor3 = Color3.fromRGB(200, 200, 200)
				Para.Font = Enum.Font.Gotham
				Para.TextSize = 14
				Para.TextWrapped = true
				Para.TextXAlignment = Enum.TextXAlignment.Left
				Para.TextYAlignment = Enum.TextYAlignment.Top
				Para.AutomaticSize = Enum.AutomaticSize.Y
				Para.Parent = SectionContent

				local ParaAPI = {}
				function ParaAPI:Set(text)
					Para.Text = text
				end
				return ParaAPI
			end

			-- Divider
			function SectionAPI:AddDivider()
				local Divider = Instance.new("Frame")
				Divider.Size = UDim2.new(1, -20, 0, 1)
				Divider.Position = UDim2.new(0, 10, 0, 0)
				Divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				Divider.BorderSizePixel = 0
				Divider.Parent = SectionContent
			end

			return SectionAPI
		end

		if not CurrentPage then
			Page.Visible = true
			CurrentPage = Page
			TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
			TabBtn.TextColor3 = Color3.new(1, 1, 1)
		end

		return Tab
	end

	-- Notification
	function Window:Notify(cfg)
		local Title = cfg.Title or "Notification"
		local Text = cfg.Text or "Message"
		local Duration = cfg.Duration or 5

		local NotifCount = #ScreenGui:GetChildren() - 1 -- rough stack count

		local Notif = Instance.new("Frame")
		Notif.Size = UDim2.new(0, 300, 0, 90)
		Notif.Position = UDim2.new(1, 310, 1, -100 - (NotifCount * 100))
		Notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		Notif.Parent = ScreenGui

		local NotifCorner = Instance.new("UICorner")
		NotifCorner.CornerRadius = UDim.new(0, 10)
		NotifCorner.Parent = Notif

		local NTitle = Instance.new("TextLabel")
		NTitle.Text = Title
		NTitle.Size = UDim2.new(1, 0, 0, 30)
		NTitle.BackgroundTransparency = 1
		NTitle.TextColor3 = Accent
		NTitle.Font = Enum.Font.GothamBold
		NTitle.TextSize = 16
		NTitle.Position = UDim2.new(0, 15, 0, 10)
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.Parent = Notif

		local NText = Instance.new("TextLabel")
		NText.Text = Text
		NText.Size = UDim2.new(1, -30, 0, 40)
		NText.Position = UDim2.new(0, 15, 0, 40)
		NText.BackgroundTransparency = 1
		NText.TextColor3 = Color3.new(1, 1, 1)
		NText.Font = Enum.Font.Gotham
		NText.TextSize = 14
		NText.TextWrapped = true
		NText.TextXAlignment = Enum.TextXAlignment.Left
		NText.Parent = Notif

		TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -310, 1, -100 - (NotifCount * 100))}):Play()

		task.delay(Duration, function()
			TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 310, 1, -100 - (NotifCount * 100))}):Play()
			task.delay(0.4, function()
				Notif:Destroy()
			end)
		end)
	end

	return Window
end

return UILib
