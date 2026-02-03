--[[
    🔥 UI LIBRARY - EXAMPLE USAGE SCRIPT
    Complete demonstration of all features

    Copy this entire script to test the library!
]]--

-- Load the library (replace with your loadstring URL)
local Library = loadstring(game:HttpGet("YOUR_URL_HERE"))()

-- Create main window
local Window = Library:CreateWindow({
    Title = "Premium Hub",
    Subtitle = "v2.0.0 - Master Edition",
    AccentColor = Color3.fromRGB(138, 43, 226), -- Purple accent
    Size = UDim2.new(0, 580, 0, 650)
})

-- TAB 1: MAIN FEATURES
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "🏠"
})

MainTab:CreateSection({
    Name = "Combat Features"
})

MainTab:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
        if state then
            _G.AutoFarm = true
            -- Your auto farm code here
        else
            _G.AutoFarm = false
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(state)
        print("Auto Collect:", state)
    end
})

MainTab:CreateSlider({
    Name = "Farm Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        print("Farm Speed:", value)
        _G.FarmSpeed = value
    end
})

MainTab:CreateButton({
    Name = "Teleport to Farm Area",
    Callback = function()
        print("Teleporting...")
        Library.Notifications:Send({
            Type = "Success",
            Title = "Teleport",
            Message = "Teleported to farm area!",
            Duration = 3
        })
    end
})

MainTab:CreateSection({
    Name = "Player Settings"
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        print("Walk Speed set to:", value)
    end
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        print("Jump Power set to:", value)
    end
})

-- TAB 2: COMBAT
local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "⚔️"
})

CombatTab:CreateSection({
    Name = "Aimbot Settings"
})

CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        print("Aimbot:", state)
    end
})

CombatTab:CreateToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(state)
        print("Team Check:", state)
    end
})

CombatTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(option)
        print("Target Part:", option)
    end
})

CombatTab:CreateSlider({
    Name = "FOV Size",
    Min = 50,
    Max = 500,
    Default = 200,
    Increment = 10,
    Callback = function(value)
        print("FOV Size:", value)
    end
})

CombatTab:CreateSection({
    Name = "ESP Settings"
})

CombatTab:CreateToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(state)
        print("Player ESP:", state)
    end
})

CombatTab:CreateToggle({
    Name = "Name ESP",
    Default = false,
    Callback = function(state)
        print("Name ESP:", state)
    end
})

CombatTab:CreateToggle({
    Name = "Distance ESP",
    Default = false,
    Callback = function(state)
        print("Distance ESP:", state)
    end
})

-- TAB 3: MISC
local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "⚙️"
})

MiscTab:CreateSection({
    Name = "User Interface"
})

MiscTab:CreateKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        Window:ToggleMinimize()
        Library.Notifications:Send({
            Type = "Info",
            Title = "UI Toggle",
            Message = "UI visibility toggled",
            Duration = 2
        })
    end
})

MiscTab:CreateKeybind({
    Name = "Panic Key",
    Default = Enum.KeyCode.Delete,
    Callback = function()
        Window:Destroy()
        Library.Notifications:Send({
            Type = "Warning",
            Title = "Panic!",
            Message = "UI destroyed!",
            Duration = 2
        })
    end
})

MiscTab:CreateSection({
    Name = "Game Settings"
})

MiscTab:CreateInput({
    Name = "Custom Message",
    Default = "",
    Placeholder = "Type your message...",
    Callback = function(text)
        print("Message:", text)
    end
})

MiscTab:CreateInput({
    Name = "Player ID to Spectate",
    Default = "",
    Placeholder = "Enter player ID...",
    NumberOnly = true,
    Callback = function(id)
        print("Spectating player:", id)
    end
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            game.Players.LocalPlayer
        )
    end
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        Library.Notifications:Send({
            Type = "Info",
            Title = "Server Hop",
            Message = "Finding new server...",
            Duration = 3
        })
        -- Server hop code here
    end
})

-- TAB 4: CONFIGS
local ConfigTab = Window:CreateTab({
    Name = "Settings",
    Icon = "💾"
})

ConfigTab:CreateSection({
    Name = "Configuration"
})

ConfigTab:CreateLabel({
    Text = "Save and load your settings"
})

local configName = ""

ConfigTab:CreateInput({
    Name = "Config Name",
    Default = "default",
    Placeholder = "Enter config name...",
    Callback = function(text)
        configName = text
    end
})

ConfigTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        if configName ~= "" then
            Library.Config:Save(configName, Window.ConfigData)
            Library.Notifications:Send({
                Type = "Success",
                Title = "Config Saved",
                Message = "Config '" .. configName .. "' saved successfully!",
                Duration = 3
            })
        else
            Library.Notifications:Send({
                Type = "Error",
                Title = "Error",
                Message = "Please enter a config name!",
                Duration = 3
            })
        end
    end
})

ConfigTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        if configName ~= "" then
            local data = Library.Config:Load(configName)
            if data then
                Window.ConfigData = data
                Library.Notifications:Send({
                    Type = "Success",
                    Title = "Config Loaded",
                    Message = "Config '" .. configName .. "' loaded!",
                    Duration = 3
                })
            else
                Library.Notifications:Send({
                    Type = "Error",
                    Title = "Error",
                    Message = "Config not found!",
                    Duration = 3
                })
            end
        end
    end
})

ConfigTab:CreateButton({
    Name = "Delete Config",
    Callback = function()
        if configName ~= "" then
            Library.Config:Delete(configName)
            Library.Notifications:Send({
                Type = "Warning",
                Title = "Config Deleted",
                Message = "Config '" .. configName .. "' deleted!",
                Duration = 3
            })
        end
    end
})

ConfigTab:CreateSection({
    Name = "Information"
})

ConfigTab:CreateLabel({
    Text = "Library Version: 2.0.0"
})

ConfigTab:CreateLabel({
    Text = "Created: 2026"
})

ConfigTab:CreateLabel({
    Text = "Made with ❤️ for Roblox"
})

-- WELCOME NOTIFICATION
wait(0.5)
Library.Notifications:Send({
    Type = "Success",
    Title = "Welcome!",
    Message = "Premium Hub loaded successfully!",
    Duration = 5
})

print("✅ UI Library loaded successfully!")
print("📌 Press RightShift to toggle UI")
print("📌 Press Delete for panic destroy")
