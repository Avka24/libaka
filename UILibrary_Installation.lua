--[[
    📦 INSTALLATION GUIDE
    ═══════════════════════════════════════

    METHOD 1: ONE-LINE LOADER (Recommended)
    ----------------------------------------
    1. Upload UILibrary_Main.lua to a file host (GitHub, Pastebin, etc.)
    2. Use this loader:

    local Library = loadstring(game:HttpGet("YOUR_URL_HERE"))()


    METHOD 2: DIRECT PASTE
    ----------------------------------------
    1. Copy entire UILibrary_Main.lua content
    2. Paste into your executor
    3. Use:

    local Library = loadstring(Source)()


    🎨 CREATING YOUR FIRST WINDOW
    ----------------------------------------
    local Window = Library:CreateWindow({
        Title = "My Hub",
        Subtitle = "Version 1.0",
        AccentColor = Color3.fromRGB(138, 43, 226)
    })


    📑 CREATING TABS
    ----------------------------------------
    local Tab = Window:CreateTab({
        Name = "Main",
        Icon = "🏠"
    })


    🎛️ ADDING ELEMENTS
    ----------------------------------------

    BUTTON:
    Tab:CreateButton({
        Name = "Click Me",
        Callback = function()
            print("Clicked!")
        end
    })

    TOGGLE:
    Tab:CreateToggle({
        Name = "Enable Feature",
        Default = false,
        Callback = function(state)
            print("Toggle:", state)
        end
    })

    SLIDER:
    Tab:CreateSlider({
        Name = "Speed",
        Min = 0,
        Max = 100,
        Default = 50,
        Increment = 1,
        Callback = function(value)
            print("Value:", value)
        end
    })

    DROPDOWN:
    Tab:CreateDropdown({
        Name = "Select Option",
        Options = {"Option 1", "Option 2", "Option 3"},
        Default = "Option 1",
        Callback = function(option)
            print("Selected:", option)
        end
    })

    INPUT:
    Tab:CreateInput({
        Name = "Enter Text",
        Default = "",
        Placeholder = "Type here...",
        NumberOnly = false,
        Callback = function(text)
            print("Input:", text)
        end
    })

    KEYBIND:
    Tab:CreateKeybind({
        Name = "Hotkey",
        Default = Enum.KeyCode.E,
        Callback = function()
            print("Key pressed!")
        end
    })

    LABEL:
    Tab:CreateLabel({
        Text = "This is a label"
    })

    SECTION:
    Tab:CreateSection({
        Name = "Section Title"
    })


    🔔 NOTIFICATIONS
    ----------------------------------------
    Library.Notifications:Send({
        Type = "Success", -- Success, Info, Warning, Error
        Title = "Title",
        Message = "Message text",
        Duration = 5
    })


    💾 CONFIGURATION SYSTEM
    ----------------------------------------

    SAVE:
    Library.Config:Save("myconfig", Window.ConfigData)

    LOAD:
    local data = Library.Config:Load("myconfig")

    DELETE:
    Library.Config:Delete("myconfig")

    GET ALL:
    local configs = Library.Config:GetAll()


    🎨 CUSTOMIZATION
    ----------------------------------------

    CHANGE ACCENT COLOR:
    Library.Theme:SetAccent(Color3.fromRGB(255, 0, 0))

    TOGGLE MINIMIZE:
    Window:ToggleMinimize()

    DESTROY UI:
    Window:Destroy()


    🔧 ELEMENT METHODS
    ----------------------------------------

    BUTTON:
    button:SetEnabled(true/false)
    button:SetText("New Text")

    TOGGLE:
    toggle:SetState(true/false)

    SLIDER:
    slider:SetValue(75)

    DROPDOWN:
    dropdown:SetValue("Option 2")

    INPUT:
    input:SetValue("Text")

    KEYBIND:
    keybind:SetKey(Enum.KeyCode.F)

    LABEL:
    label:SetText("New text")
    label:SetColor(Color3.fromRGB(255, 0, 0))


    ⚡ PERFORMANCE TIPS
    ----------------------------------------
    1. Use pcall() for callbacks
    2. Don't create too many elements at once
    3. Use sections to organize
    4. Destroy UI when not needed
    5. Use Config system to save states


    🛡️ ANTI-DETECTION
    ----------------------------------------
    - Uses CoreGui (hidden from players)
    - No excessive loops
    - Memory optimized
    - Destroy-safe architecture
    - Duplicate prevention


    📱 MOBILE SUPPORT
    ----------------------------------------
    - Touch input supported
    - Responsive design
    - Drag & drop works on mobile
    - Optimized button sizes


    🎯 BEST PRACTICES
    ----------------------------------------
    1. Group related elements in sections
    2. Use meaningful names
    3. Add tooltips via labels
    4. Save configs for user convenience
    5. Use notifications for feedback
    6. Organize tabs logically


    🐛 TROUBLESHOOTING
    ----------------------------------------

    UI NOT SHOWING:
    - Check if CoreGui is accessible
    - Verify script execution
    - Check for errors in console

    ELEMENTS NOT WORKING:
    - Check callback functions
    - Verify element syntax
    - Test with simple callbacks

    LAG/PERFORMANCE:
    - Reduce number of elements
    - Use sections instead of tabs
    - Optimize callback code


    📚 ADDITIONAL RESOURCES
    ----------------------------------------
    - Check example usage script
    - Read inline code comments
    - Experiment with settings
    - Join community for support


    ✨ ENJOY YOUR PREMIUM UI LIBRARY!
    ═══════════════════════════════════════
]]--
