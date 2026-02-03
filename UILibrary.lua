local UILib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Connections = {}

function UILib:CreateWindow(Config)
	Config = Config or {}
	local Title = Config.Title or "Premium Library"
	local Subtitle = Config.Subtitle or ""
	local Accent = Config.Accent or Color3.fromRGB(255, 85, 85) -- Tema hitam-merah default

	-- Cleanup UI lama & connections
	if PlayerGui:FindFirstChild("PremiumUI") then
		PlayerGui.PremiumUI:Destroy()
	end
	for _, conn in ipairs(Connections) do
		conn:Disconnect()
	end
	table.clear(Connections)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PremiumUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 620, 0, 480)
	Main.Position = UDim2.new(0.5, -310, 0.5, -240)
	Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = Main

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(40, 40, 40)
	MainStroke.Thickness = 1
	MainStroke.Parent = Main

	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 55)
	TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	TitleBar.Parent = Main

	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 12)
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
	SubtitleLabel.Position = UDim2.new(0, 30 + TitleLabel.TextBounds.X, 0, 0)
	SubtitleLabel.BackgroundTransparency = 1
	SubtitleLabel.TextColor3 = Accent
	SubtitleLabel.Font = Enum.Font.Gotham
	SubtitleLabel.TextSize = 15
	SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubtitleLabel.Parent = TitleBar

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Text = "—"
	MinimizeBtn.Size = UDim2.new(0, 50, 0, 45)
	MinimizeBtn.Position = UDim2.new(1, -110, 0, 5)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	MinimizeBtn.Font = Enum.Font.GothamBold
	MinimizeBtn.TextSize = 30
	MinimizeBtn.Parent = TitleBar

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Text = "×"
	CloseBtn.Size = UDim2.new(0, 50, 0, 45)
	CloseBtn.Position = UDim2.new(1, -55, 0, 5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 26
	CloseBtn.Parent = TitleBar

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, 0, 1, -55)
	Content.Position = UDim2.new(0, 0, 0, 55)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(0, 170, 1, 0)
	TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	TabContainer.Parent = Content

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Padding = UDim.new(0, 8)
	TabListLayout.Parent = TabContainer

	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingTop = UDim.new(0, 12)
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.PaddingRight = UDim.new(0, 10)
	TabPadding.Parent = TabContainer

	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1, -170, 1, 0)
	PageContainer.Position = UDim2.new(0, 170, 0, 0)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Parent = Content

	-- Draggable (hanya saat tidak minimize)
	local Dragging = false
	local DragInput, DragStart, StartPos

	local function UpdateDrag(input)
		local delta = input.Position - DragStart
		Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
	end

	TitleBar.InputBegan:Connect(function(input)
		if Minimized then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPos = Main.Position

			local conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
			table.insert(Connections, conn)
		end
	end)

	table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
		if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateDrag(input)
		end
	end))

	-- Minimize/Restore dengan animasi halus
	local Minimized = false
	MinimizeBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 620, 0, 55)}):Play()
		else
			TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 620, 0, 480)}):Play()
		end
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		for _, conn in ipairs(Connections) do
			if conn.Connected then conn:Disconnect() end
		end
		ScreenGui:Destroy()
	end)

	local CurrentPage = nil

	local Window = {}

	function Window:CreateTab(Name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Text = "  " .. Name
		TabBtn.Size = UDim2.new(1, 0, 0, 42)
		TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		TabBtn.Font = Enum.Font.GothamSemibold
		TabBtn.TextSize = 15
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = TabContainer

		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 8)
		TabCorner.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 6
		Page.ScrollBarImageColor3 = Accent
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.Visible = false
		Page.Parent = PageContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 12)
		PageLayout.Parent = Page

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingLeft = UDim.new(0, 14)
		PagePadding.PaddingRight = UDim.new(0, 14)
		PagePadding.PaddingTop = UDim.new(0, 12)
		PagePadding.Parent = Page

		-- Tab selection
		TabBtn.MouseButton1Click:Connect(function()
			if CurrentPage then CurrentPage.Visible = false end
			CurrentPage = Page
			Page.Visible = true

			for _, btn in pairs(TabContainer:GetChildren()) do
				if btn:IsA("TextButton") then
					TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
					btn.TextColor3 = Color3.fromRGB(200, 200, 200)
				end
			end
			TweenService:Create(TabBtn, TweenInfo.new(0.25), {BackgroundColor3 = Accent}):Play()
			TabBtn.TextColor3 = Color3.new(1, 1, 1)
		end)

		-- Hover effect
		TabBtn.MouseEnter:Connect(function()
			if TabBtn.BackgroundColor3 ~= Accent then
				TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if TabBtn.BackgroundColor3 ~= Accent then
				TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
			end
		end)

		if not CurrentPage then
			Page.Visible = true
			CurrentPage = Page
			TweenService:Create(TabBtn, TweenInfo.new(0.25), {BackgroundColor3 = Accent}):Play()
			TabBtn.TextColor3 = Color3.new(1, 1, 1)
		end

		local Tab = {}

		function Tab:CreateSection(SectionName)
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Size = UDim2.new(1, 0, 0, 42)
			SectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			SectionFrame.Parent = Page

			local SectionCorner = Instance.new("UICorner")
			SectionCorner.CornerRadius = UDim.new(0, 10)
			SectionCorner.Parent = SectionFrame

			local SectionTitle = Instance.new("TextLabel")
			SectionTitle.Text = SectionName
			SectionTitle.Size = UDim2.new(1, -20, 0, 42)
			SectionTitle.Position = UDim2.new(0, 20, 0, 0)
			SectionTitle.BackgroundTransparency = 1
			SectionTitle.TextColor3 = Color3.new(1, 1, 1)
			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.TextSize = 17
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.Parent = SectionFrame

			local SectionContent = Instance.new("Frame")
			SectionContent.Size = UDim2.new(1, 0, 0, 0)
			SectionContent.Position = UDim2.new(0, 0, 0, 42)
			SectionContent.BackgroundTransparency = 1
			SectionContent.AutomaticSize = Enum.AutomaticSize.Y
			SectionContent.Parent = SectionFrame

			local ContentLayout = Instance.new("UIListLayout")
			ContentLayout.Padding = UDim.new(0, 10)
			ContentLayout.Parent = SectionContent

			local ContentPadding = Instance.new("UIPadding")
			ContentPadding.PaddingLeft = UDim.new(0, 14)
			ContentPadding.PaddingRight = UDim.new(0, 14)
			ContentPadding.PaddingTop = UDim.new(0, 10)
			ContentPadding.PaddingBottom = UDim.new(0, 14)
			ContentPadding.Parent = SectionContent

			local SectionAPI = {}

			-- Button
			function SectionAPI:AddButton(cfg)
				local Button = Instance.new("TextButton")
				Button.Text = cfg.Name or "Button"
				Button.Size = UDim2.new(1, 0, 0, 40)
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
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(Accent.R * 255 + 30, Accent.G * 255 + 30, Accent.B * 255 + 30)}):Play()
				end)
				Button.MouseLeave:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
				end)
				Button.MouseButton1Down:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
				end)
				Button.MouseButton1Up:Connect(function()
					TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)}):Play()
				end)
				Button.MouseButton1Click:Connect(cfg.Callback or function() end)

				return Button
			end

			-- Toggle
			function SectionAPI:AddToggle(cfg)
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 40)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Toggle"
				Label.Size = UDim2.new(1, -80, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 12, 0, 0)
				Label.Parent = Frame

				local ToggleBg = Instance.new("Frame")
				ToggleBg.Size = UDim2.new(0, 56, 0, 28)
				ToggleBg.Position = UDim2.new(1, -70, 0.5, -14)
				ToggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				ToggleBg.Parent = Frame

				local ToggleCorner = Instance.new("UICorner")
				ToggleCorner.CornerRadius = UDim.new(1, 0)
				ToggleCorner.Parent = ToggleBg

				local Circle = Instance.new("Frame")
				Circle.Size = UDim2.new(0, 24, 0, 24)
				Circle.Position = UDim2.new(0, 2, 0, 2)
				Circle.BackgroundColor3 = Color3.new(1, 1, 1)
				Circle.Parent = ToggleBg

				local CircleCorner = Instance.new("UICorner")
				CircleCorner.CornerRadius = UDim.new(1, 0)
				CircleCorner.Parent = Circle

				local State = cfg.Default or false

				local function Update()
					if State then
						TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = Accent}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3), {Position = UDim2.new(1, -26, 0, 2)}):Play()
					else
						TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0, 2)}):Play()
					end
					if cfg.Callback then cfg.Callback(State) end
				end
				Update()

				Frame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						State = not State
						Update()
					end
				end)

				local API = {}
				function API:Set(val)
					if State ~= val then
						State = val
						Update()
					end
				end
				return API
			end

			-- Slider
			function SectionAPI:AddSlider(cfg)
				local Min = cfg.Min or 0
				local Max = cfg.Max or 100
				local Default = math.clamp(cfg.Default or 50, Min, Max)
				local Increment = cfg.Increment or 1

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 60)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Slider"
				Label.Size = UDim2.new(1, -100, 0, 28)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 12, 0, 0)
				Label.Parent = Frame

				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Text = tostring(Default)
				ValueLabel.Size = UDim2.new(0, 80, 0, 28)
				ValueLabel.Position = UDim2.new(1, -92, 0, 0)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.TextColor3 = Accent
				ValueLabel.Font = Enum.Font.GothamBold
				ValueLabel.TextSize = 15
				ValueLabel.Parent = Frame

				local SliderTrack = Instance.new("Frame")
				SliderTrack.Size = UDim2.new(1, -24, 0, 10)
				SliderTrack.Position = UDim2.new(0, 12, 0, 36)
				SliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				SliderTrack.Parent = Frame

				local TrackCorner = Instance.new("UICorner")
				TrackCorner.CornerRadius = UDim.new(0, 5)
				TrackCorner.Parent = SliderTrack

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
				Fill.BackgroundColor3 = Accent
				Fill.Parent = SliderTrack

				local FillCorner = Instance.new("UICorner")
				FillCorner.CornerRadius = UDim.new(0, 5)
				FillCorner.Parent = Fill

				local Knob = Instance.new("Frame")
				Knob.Size = UDim2.new(0, 20, 0, 20)
				Knob.Position = UDim2.new((Default - Min) / (Max - Min), -10, 0.5, -10)
				Knob.BackgroundColor3 = Color3.new(1, 1, 1)
				Knob.Parent = SliderTrack

				local KnobCorner = Instance.new("UICorner")
				KnobCorner.CornerRadius = UDim.new(1, 0)
				KnobCorner.Parent = Knob

				local Value = Default
				local Dragging = false

				local function Update(pos)
					local rel = math.clamp((pos.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
					Value = Min + (Max - Min) * rel
					Value = math.floor(Value / Increment + 0.5) * Increment
					Value = math.clamp(Value, Min, Max)

					TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
					TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(rel, -10, 0.5, -10)}):Play()
					ValueLabel.Text = tostring(Value)
					if cfg.Callback then cfg.Callback(Value) end
				end

				SliderTrack.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Dragging = true
						Update(input.Position)
					end
				end)

				table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Dragging = false
					end
				end))

				table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
					if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						Update(input.Position)
					end
				end))

				local API = {}
				function API:Set(val)
					val = math.clamp(val, Min, Max)
					local rel = (val - Min) / (Max - Min)
					Value = val
					TweenService:Create(Fill, TweenInfo.new(0.2), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
					TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(rel, -10, 0.5, -10)}):Play()
					ValueLabel.Text = tostring(val)
					if cfg.Callback then cfg.Callback(val) end
				end
				return API
			end

			-- Dropdown
			function SectionAPI:AddDropdown(cfg)
				local Options = cfg.Options or {"Option 1"}
				local Default = cfg.Default or Options[1]

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 40)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Dropdown"
				Label.Size = UDim2.new(1, -160, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 12, 0, 0)
				Label.Parent = Frame

				local DropdownBtn = Instance.new("TextButton")
				DropdownBtn.Size = UDim2.new(0, 150, 0, 34)
				DropdownBtn.Position = UDim2.new(1, -162, 0, 3)
				DropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				DropdownBtn.Text = Default
				DropdownBtn.TextColor3 = Color3.new(1, 1, 1)
				DropdownBtn.Font = Enum.Font.Gotham
				DropdownBtn.TextSize = 14
				DropdownBtn.AutoButtonColor = false
				DropdownBtn.Parent = Frame

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 8)
				BtnCorner.Parent = DropdownBtn

				local Arrow = Instance.new("TextLabel")
				Arrow.Text = "▼"
				Arrow.Size = UDim2.new(0, 30, 1, 0)
				Arrow.Position = UDim2.new(1, -30, 0, 0)
				Arrow.BackgroundTransparency = 1
				Arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
				Arrow.Font = Enum.Font.GothamBold
				Arrow.Parent = DropdownBtn

				local ListFrame = Instance.new("Frame")
				ListFrame.Size = UDim2.new(0, 150, 0, 0)
				ListFrame.Position = UDim2.new(1, -162, 0, 40)
				ListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				ListFrame.Visible = false
				ListFrame.ClipsDescendants = true
				ListFrame.Parent = Frame

				local ListCorner = Instance.new("UICorner")
				ListCorner.CornerRadius = UDim.new(0, 8)
				ListCorner.Parent = ListFrame

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.Parent = ListFrame

				local Open = false

				local function BuildList()
					for _, child in ipairs(ListFrame:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					for _, opt in ipairs(Options) do
						local OptBtn = Instance.new("TextButton")
						OptBtn.Text = opt
						OptBtn.Size = UDim2.new(1, 0, 0, 34)
						OptBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
						OptBtn.TextColor3 = Color3.new(1, 1, 1)
						OptBtn.Font = Enum.Font.Gotham
						OptBtn.TextSize = 14
						OptBtn.AutoButtonColor = false
						OptBtn.Parent = ListFrame

						OptBtn.MouseEnter:Connect(function()
							TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Accent}):Play()
						end)
						OptBtn.MouseLeave:Connect(function()
							TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
						end)
						OptBtn.MouseButton1Click:Connect(function()
							DropdownBtn.Text = opt
							Open = false
							TweenService:Create(ListFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 150, 0, 0)}):Play()
							task.delay(0.25, function() ListFrame.Visible = false end)
							if cfg.Callback then cfg.Callback(opt) end
						end)
					end
				end
				BuildList()

				DropdownBtn.MouseButton1Click:Connect(function()
					Open = not Open
					if Open then
						ListFrame.Visible = true
						TweenService:Create(ListFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 150, 0, #Options * 34)}):Play()
					else
						TweenService:Create(ListFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 150, 0, 0)}):Play()
						task.delay(0.25, function() ListFrame.Visible = false end)
					end
				end)

				local API = {}
				function API:Set(val)
					DropdownBtn.Text = val
					if cfg.Callback then cfg.Callback(val) end
				end
				function API:Refresh(newOpts)
					Options = newOpts
					BuildList()
				end
				return API
			end

			-- Input
			function SectionAPI:AddInput(cfg)
				local Default = cfg.Default or ""

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 40)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Input"
				Label.Size = UDim2.new(0, 160, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 12, 0, 0)
				Label.Parent = Frame

				local TextBox = Instance.new("TextBox")
				TextBox.PlaceholderText = cfg.Placeholder or "Enter text..."
				TextBox.Text = Default
				TextBox.Size = UDim2.new(1, -180, 0, 34)
				TextBox.Position = UDim2.new(1, -168, 0, 3)
				TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				TextBox.TextColor3 = Color3.new(1, 1, 1)
				TextBox.Font = Enum.Font.Gotham
				TextBox.TextSize = 14
				TextBox.Parent = Frame

				local BoxCorner = Instance.new("UICorner")
				BoxCorner.CornerRadius = UDim.new(0, 8)
				BoxCorner.Parent = TextBox

				TextBox.FocusLost:Connect(function(enter)
					if enter and cfg.Callback then
						cfg.Callback(TextBox.Text)
					end
				end)

				TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					if cfg.Callback then cfg.Callback(TextBox.Text) end
				end)

				local API = {}
				function API:Set(text)
					TextBox.Text = text
				end
				return API
			end

			-- Keybind
			function SectionAPI:AddKeybind(cfg)
				local Default = cfg.Default or Enum.KeyCode.Unknown

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 40)
				Frame.BackgroundTransparency = 1
				Frame.Parent = SectionContent

				local Label = Instance.new("TextLabel")
				Label.Text = cfg.Name or "Keybind"
				Label.Size = UDim2.new(1, -110, 1, 0)
				Label.BackgroundTransparency = 1
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 15
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Position = UDim2.new(0, 12, 0, 0)
				Label.Parent = Frame

				local BindBtn = Instance.new("TextButton")
				BindBtn.Size = UDim2.new(0, 100, 0, 34)
				BindBtn.Position = UDim2.new(1, -112, 0, 3)
				BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				BindBtn.Text = Default == Enum.KeyCode.Unknown and "None" or Default.Name
				BindBtn.TextColor3 = Color3.new(1, 1, 1)
				BindBtn.Font = Enum.Font.Gotham
				BindBtn.TextSize = 14
				BindBtn.AutoButtonColor = false
				BindBtn.Parent = Frame

				local BindCorner = Instance.new("UICorner")
				BindCorner.CornerRadius = UDim.new(0, 8)
				BindCorner.Parent = BindBtn

				local Binding = false
				local Current = Default

				BindBtn.MouseButton1Click:Connect(function()
					Binding = true
					BindBtn.Text = "..."
				end)

				local inputConn
				inputConn = UserInputService.InputBegan:Connect(function(input, gp)
					if Binding and not gp then
						if input.KeyCode ~= Enum.KeyCode.Unknown then
							Current = input.KeyCode
							BindBtn.Text = input.KeyCode.Name
							Binding = false
							inputConn:Disconnect()
							if cfg.Callback then cfg.Callback(Current) end
						end
					end
				end)
				table.insert(Connections, inputConn)

				local API = {}
				function API:Set(key)
					Current = key
					BindBtn.Text = key.Name
				end
				return API
			end

			-- ColorPicker (RGB sliders - full functional, reliable, no asset dependency)
			function SectionAPI:AddColorPicker(cfg)
				local Default = cfg.Default or Color3.new(1, 1, 1)
				local R = math.floor(Default.R * 255)
				local G = math.floor(Default.G * 255)
				local B = math.floor(Default.B * 255)

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 40)
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
				Label.Position = UDim2.new(0, 12, 0, 0)
				Label.Parent = Frame

				local Preview = Instance.new("Frame")
				Preview.Size = UDim2.new(0, 40, 0, 34)
				Preview.Position = UDim2.new(1, -52, 0, 3)
				Preview.BackgroundColor3 = Default
				Preview.Parent = Frame

				local PreviewCorner = Instance.new("UICorner")
				PreviewCorner.CornerRadius = UDim.new(0, 8)
				PreviewCorner.Parent = Preview

				local PickerFrame = Instance.new("Frame")
				PickerFrame.Size = UDim2.new(1, 0, 0, 0)
				PickerFrame.Position = UDim2.new(0, 0, 0, 46)
				PickerFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				PickerFrame.Visible = false
				PickerFrame.Parent = Frame

				local PickerCorner = Instance.new("UICorner")
				PickerCorner.CornerRadius = UDim.new(0, 8)
				PickerCorner.Parent = PickerFrame

				local PickerPadding = Instance.new("UIPadding")
				PickerPadding.PaddingAll = UDim.new(0, 12)
				PickerPadding.Parent = PickerFrame

				local PickerLayout = Instance.new("UIListLayout")
				PickerLayout.Padding = UDim.new(0, 12)
				PickerLayout.Parent = PickerFrame

				local Open = false

				local function CreateColorSlider(name, default)
					local SliderFrame = Instance.new("Frame")
					SliderFrame.Size = UDim2.new(1, 0, 0, 30)
					SliderFrame.BackgroundTransparency = 1

					local NameLabel = Instance.new("TextLabel")
					NameLabel.Text = name
					NameLabel.Size = UDim2.new(0, 40, 1, 0)
					NameLabel.BackgroundTransparency = 1
					NameLabel.TextColor3 = Color3.new(1, 1, 1)
					NameLabel.Parent = SliderFrame

					local SliderValue = Instance.new("TextLabel")
					SliderValue.Text = tostring(default)
					SliderValue.Size = UDim2.new(0, 50, 1, 0)
					SliderValue.Position = UDim2.new(1, -50, 0, 0)
					SliderValue.BackgroundTransparency = 1
					SliderValue.TextColor3 = Accent
					SliderValue.Parent = SliderFrame

					local Track = Instance.new("Frame")
					Track.Size = UDim2.new(1, -100, 0, 8)
					Track.Position = UDim2.new(0, 50, 0.5, -4)
					Track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					Track.Parent = SliderFrame

					local TCorner = Instance.new("UICorner")
					TCorner.CornerRadius = UDim.new(0, 4)
					TCorner.Parent = Track

					local TFill = Instance.new("Frame")
					TFill.Size = UDim2.new(default / 255, 0, 1, 0)
					TFill.BackgroundColor3 = Accent
					TFill.Parent = Track

					local FCorner = Instance.new("UICorner")
					FCorner.CornerRadius = UDim.new(0, 4)
					FCorner.Parent = TFill

					local Knob = Instance.new("Frame")
					Knob.Size = UDim2.new(0, 16, 0, 16)
					Knob.Position = UDim2.new(default / 255, -8, 0.5, -8)
					Knob.BackgroundColor3 = Color3.new(1, 1, 1)
					Knob.Parent = Track

					local KCorner = Instance.new("UICorner")
					KCorner.CornerRadius = UDim.new(1, 0)
					KCorner.Parent = Knob

					return SliderFrame, SliderValue, TFill, Knob
				end

				local RFrame, RLabel, RFill, RKnob = CreateColorSlider("R", R)
				local GFrame, GLabel, GFill, GKnob = CreateColorSlider("G", G)
				local BFrame, BLabel, BFill, BKnob = CreateColorSlider("B", B)

				RFrame.Parent = PickerFrame
				GFrame.Parent = PickerFrame
				BFrame.Parent = PickerFrame

				local function UpdateColor()
					local color = Color3.fromRGB(R, G, B)
					Preview.BackgroundColor3 = color
					if cfg.Callback then cfg.Callback(color) end
				end

				local function MakeSlider(valueLabel, fill, knob, component)
					local dragging = false
					local track = fill.Parent

					track.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
							if component == "R" then R = math.floor(rel * 255) end
							if component == "G" then G = math.floor(rel * 255) end
							if component == "B" then B = math.floor(rel * 255) end
							valueLabel.Text = tostring(component == "R" and R or component == "G" and G or B)
							TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
							TweenService:Create(knob, TweenInfo.new(0.1), {Position = UDim2.new(rel, -8, 0.5, -8)}):Play()
							UpdateColor()
						end
					end)

					table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
						if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
							if component == "R" then R = math.floor(rel * 255) end
							if component == "G" then G = math.floor(rel * 255) end
							if component == "B" then B = math.floor(rel * 255) end
							valueLabel.Text = tostring(component == "R" and R or component == "G" and G or B)
							TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
							TweenService:Create(knob, TweenInfo.new(0.1), {Position = UDim2.new(rel, -8, 0.5, -8)}):Play()
							UpdateColor()
						end
					end))

					table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
						end
					end))
				end

				MakeSlider(RLabel, RFill, RKnob, "R")
				MakeSlider(GLabel, GFill, GKnob, "G")
				MakeSlider(BLabel, BFill, BKnob, "B")

				Preview.MouseButton1Click:Connect(function()
					Open = not Open
					PickerFrame.Visible = Open
					if Open then
						TweenService:Create(PickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 140)}):Play()
					else
						TweenService:Create(PickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
					end
				end)

				local API = {}
				function API:Set(color)
					R, G, B = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
					Preview.BackgroundColor3 = color
					RLabel.Text = tostring(R)
					GLabel.Text = tostring(G)
					BLabel.Text = tostring(B)
					TweenService:Create(RFill, TweenInfo.new(0.2), {Size = UDim2.new(R/255, 0, 1, 0)}):Play()
					TweenService:Create(GFill, TweenInfo.new(0.2), {Size = UDim2.new(G/255, 0, 1, 0)}):Play()
					TweenService:Create(BFill, TweenInfo.new(0.2), {Size = UDim2.new(B/255, 0, 1, 0)}):Play()
					TweenService:Create(RKnob, TweenInfo.new(0.2), {Position = UDim2.new(R/255, -8, 0.5, -8)}):Play()
					TweenService:Create(GKnob, TweenInfo.new(0.2), {Position = UDim2.new(G/255, -8, 0.5, -8)}):Play()
					TweenService:Create(BKnob, TweenInfo.new(0.2), {Position = UDim2.new(B/255, -8, 0.5, -8)}):Play()
					if cfg.Callback then cfg.Callback(color) end
				end
				return API
			end

			-- Paragraph
			function SectionAPI:AddParagraph(cfg)
				local Text = cfg.Text or "Paragraph text."

				local Para = Instance.new("TextLabel")
				Para.Text = Text
				Para.Size = UDim2.new(1, -24, 0, 0)
				Para.Position = UDim2.new(0, 12, 0, 0)
				Para.BackgroundTransparency = 1
				Para.TextColor3 = Color3.fromRGB(200, 200, 200)
				Para.Font = Enum.Font.Gotham
				Para.TextSize = 14
				Para.TextWrapped = true
				Para.TextXAlignment = Enum.TextXAlignment.Left
				Para.TextYAlignment = Enum.TextYAlignment.Top
				Para.AutomaticSize = Enum.AutomaticSize.Y
				Para.Parent = SectionContent

				local API = {}
				function API:Set(text)
					Para.Text = text
				end
				return API
			end

			-- Divider
			function SectionAPI:AddDivider(cfg)
				local Text = cfg and cfg.Text or nil

				local Divider = Instance.new("Frame")
				Divider.Size = UDim2.new(1, -24, 0, 1)
				Divider.Position = UDim2.new(0, 12, 0, 0)
				Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				Divider.BorderSizePixel = 0
				Divider.Parent = SectionContent

				if Text then
					local DLabel = Instance.new("TextLabel")
					DLabel.Text = Text
					DLabel.BackgroundTransparency = 1
					DLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
					DLabel.Font = Enum.Font.GothamSemibold
					DLabel.TextSize = 14
					DLabel.Position = UDim2.new(0.5, 0, 0, -20)
					DLabel.AnchorPoint = Vector2.new(0.5, 0)
					DLabel.Parent = Divider
				end
			end

			return SectionAPI
		end

		return Tab
	end

	-- Notification (stacked)
	function Window:Notify(cfg)
		local Title = cfg.Title or "Notification"
		local Text = cfg.Text or "Message"
		local Duration = cfg.Duration or 5

		local notifCount = 0
		for _, child in ipairs(ScreenGui:GetChildren()) do
			if child:IsA("Frame") and child.Name == "Notification" then
				notifCount = notifCount + 1
			end
		end

		local Notif = Instance.new("Frame")
		Notif.Name = "Notification"
		Notif.Size = UDim2.new(0, 320, 0, 100)
		Notif.Position = UDim2.new(1, 330, 1, -120 - (notifCount * 110))
		Notif.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		Notif.Parent = ScreenGui

		local NCorner = Instance.new("UICorner")
		NCorner.CornerRadius = UDim.new(0, 12)
		NCorner.Parent = Notif

		local NTitle = Instance.new("TextLabel")
		NTitle.Text = Title
		NTitle.Size = UDim2.new(1, -20, 0, 34)
		NTitle.Position = UDim2.new(0, 20, 0, 12)
		NTitle.BackgroundTransparency = 1
		NTitle.TextColor3 = Accent
		NTitle.Font = Enum.Font.GothamBold
		NTitle.TextSize = 17
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.Parent = Notif

		local NText = Instance.new("TextLabel")
		NText.Text = Text
		NText.Size = UDim2.new(1, -40, 0, 40)
		NText.Position = UDim2.new(0, 20, 0, 50)
		NText.BackgroundTransparency = 1
		NText.TextColor3 = Color3.new(1, 1, 1)
		NText.Font = Enum.Font.Gotham
		NText.TextSize = 14
		NText.TextWrapped = true
		NText.TextXAlignment = Enum.TextXAlignment.Left
		NText.Parent = Notif

		TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -10, 1, -120 - (notifCount * 110))}):Play()

		task.delay(Duration, function()
			TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 330, 1, -120 - (notifCount * 110))}):Play()
			task.delay(0.4, function()
				Notif:Destroy()
			end)
		end)
	end

	return Window
end

return UILib
