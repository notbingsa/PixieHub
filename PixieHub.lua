--[[
Pixie Hub is a Roblox script that allows you to have higher privileges than the usual player.
You can have maximum functionality whilst having the most easy to use interface.
]]
print(" ")
print("Pixie Hub debugging logs")
print("This is usually a place for logs to appear in case an error occurs.")
print(" ")
print("[PixieHub] Loading script...")
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")

-- Create ScreenGui
ScreenGui.Name = "PixieHubGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Create Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
-- Start in exact center with small size for animation
MainFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
MainFrame.Size = UDim2.new(0, 50, 0, 50)
MainFrame.Active = false
MainFrame.Draggable = false

-- Create corner radius for main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Create resize handle
local ResizeHandle = Instance.new("Frame")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Parent = MainFrame
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
ResizeHandle.BorderSizePixel = 0

-- Create resize icon
local ResizeIcon = Instance.new("TextLabel")
ResizeIcon.Name = "ResizeIcon"
ResizeIcon.Parent = ResizeHandle
ResizeIcon.BackgroundTransparency = 1
ResizeIcon.Position = UDim2.new(0, 0, 0, 0)
ResizeIcon.Size = UDim2.new(1, 0, 1, 0)
ResizeIcon.Font = Enum.Font.GothamBold
ResizeIcon.Text = "⤡"
ResizeIcon.TextColor3 = Color3.fromRGB(100, 100, 100)
ResizeIcon.TextSize = 12
ResizeIcon.TextXAlignment = Enum.TextXAlignment.Center
ResizeIcon.TextYAlignment = Enum.TextYAlignment.Center
-- Start transparent for animation
ResizeIcon.TextTransparency = 1

-- Create Title Bar
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
-- Start transparent for animation
TitleBar.BackgroundTransparency = 1

-- Create corner radius for title bar (top corners only)
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Create Title
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Pixie Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
-- Start transparent for animation
Title.TextTransparency = 1

-- Create Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0, 7)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
-- Start transparent for animation
CloseButton.BackgroundTransparency = 1
CloseButton.TextTransparency = 1

-- Create corner radius for close button
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton
-- Create Minimize Button
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -65, 0, 7)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
-- Start transparent for animation
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.TextTransparency = 1

-- Create corner radius for minimize button
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

-- Create Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.Size = UDim2.new(1, -20, 1, -60)

-- Button hover effects
local function createHoverEffect(button, originalColor, hoverColor)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverColor})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = originalColor})
        tween:Play()
    end)
end

-- Apply hover effects
createHoverEffect(CloseButton, Color3.fromRGB(80, 80, 80), Color3.fromRGB(100, 100, 100))
createHoverEffect(MinimizeButton, Color3.fromRGB(80, 80, 80), Color3.fromRGB(100, 100, 100))

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize button functionality
local isMinimized = false
local originalSize = UDim2.new(0, 600, 0, 300)
local minimizedSize = UDim2.new(0, 600, 0, 40)

MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        -- Restore
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize})
        tween:Play()
        MinimizeButton.Text = "-"
        isMinimized = false
        -- Show content
        ContentFrame.Visible = true
    else
        -- Minimize
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = minimizedSize})
        tween:Play()
        MinimizeButton.Text = "+"
        isMinimized = true
        -- Hide content
        ContentFrame.Visible = false
    end
end)

-- Create profile picture frame
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Parent = ContentFrame
ProfileFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ProfileFrame.Position = UDim2.new(0.5, -200, 0.5, -60)
ProfileFrame.Size = UDim2.new(0, 80, 0, 80)
-- Start transparent for animation
ProfileFrame.BackgroundTransparency = 1

-- Create corner radius for profile frame
local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 8)
ProfileCorner.Parent = ProfileFrame

-- Create profile picture
local ProfilePicture = Instance.new("ImageLabel")
ProfilePicture.Name = "ProfilePicture"
ProfilePicture.Parent = ProfileFrame
ProfilePicture.BackgroundTransparency = 1
ProfilePicture.Position = UDim2.new(0, 0, 0, 0)
ProfilePicture.Size = UDim2.new(1, 0, 1, 0)
ProfilePicture.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=180&height=180"
ProfilePicture.ImageTransparency = 1

-- Create corner radius for profile picture
local PictureCorner = Instance.new("UICorner")
PictureCorner.CornerRadius = UDim.new(0, 8)
PictureCorner.Parent = ProfilePicture

-- Create greeting label
local GreetingLabel = Instance.new("TextLabel")
GreetingLabel.Name = "GreetingLabel"
GreetingLabel.Parent = ContentFrame
GreetingLabel.BackgroundTransparency = 1
GreetingLabel.Position = UDim2.new(0.534, -100, 0.5, -45)
GreetingLabel.Size = UDim2.new(0, 200, 0, 30)
GreetingLabel.Font = Enum.Font.GothamBold
GreetingLabel.Text = "Hello, " .. Player.Name .. "!"
GreetingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GreetingLabel.TextSize = 22
GreetingLabel.TextXAlignment = Enum.TextXAlignment.Center
-- Start transparent for fade-in animation
GreetingLabel.TextTransparency = 1

-- Create date/time label
local DateTimeLabel = Instance.new("TextLabel")
DateTimeLabel.Name = "DateTimeLabel"
DateTimeLabel.Parent = ContentFrame
DateTimeLabel.BackgroundTransparency = 1
DateTimeLabel.Position = UDim2.new(0.5, -150, 0.5, -15)
DateTimeLabel.Size = UDim2.new(0, 300, 0, 25)
DateTimeLabel.Font = Enum.Font.Gotham
DateTimeLabel.Text = "Loading..."
DateTimeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DateTimeLabel.TextSize = 15
DateTimeLabel.TextXAlignment = Enum.TextXAlignment.Center
-- Start transparent for fade-in animation
DateTimeLabel.TextTransparency = 1

-- Create START button
local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.Parent = ContentFrame
StartButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
StartButton.Position = UDim2.new(0.5, -75, 0.5, 15)
StartButton.Size = UDim2.new(0, 150, 0, 40)
StartButton.Font = Enum.Font.GothamBold
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 18
StartButton.BorderSizePixel = 0
-- Start transparent for fade-in animation
StartButton.BackgroundTransparency = 1
StartButton.TextTransparency = 1

-- Create corner radius for START button
local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartButton

-- START button hover effect
createHoverEffect(StartButton, Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 170, 255))

-- Create Category Frame (Left Side)
local CategoryFrame = Instance.new("Frame")
CategoryFrame.Name = "CategoryFrame"
CategoryFrame.Parent = ContentFrame
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.Position = UDim2.new(0, 0, 0, 0)
CategoryFrame.Size = UDim2.new(0, 150, 1, 0)
CategoryFrame.Visible = false

-- Create Category ScrollableFrame
local CategoryScrollFrame = Instance.new("ScrollingFrame")
CategoryScrollFrame.Name = "CategoryScrollFrame"
CategoryScrollFrame.Parent = CategoryFrame
CategoryScrollFrame.BackgroundTransparency = 1
CategoryScrollFrame.Position = UDim2.new(0, 10, 0, 10)
CategoryScrollFrame.Size = UDim2.new(1, -20, 1, -20)
CategoryScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
CategoryScrollFrame.ScrollBarThickness = 4
CategoryScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

-- Create Content Page Frame (Right Side)
local ContentPageFrame = Instance.new("Frame")
ContentPageFrame.Name = "ContentPageFrame"
ContentPageFrame.Parent = ContentFrame
ContentPageFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentPageFrame.Position = UDim2.new(0, 160, 0, 0)
ContentPageFrame.Size = UDim2.new(1, -170, 1, 0)
ContentPageFrame.Visible = false

-- Create corner radius for content page frame
local ContentPageCorner = Instance.new("UICorner")
ContentPageCorner.CornerRadius = UDim.new(0, 6)
ContentPageCorner.Parent = ContentPageFrame

-- Create Content ScrollableFrame
local ContentScrollFrame = Instance.new("ScrollingFrame")
ContentScrollFrame.Name = "ContentScrollFrame"
ContentScrollFrame.Parent = ContentPageFrame
ContentScrollFrame.BackgroundTransparency = 1
ContentScrollFrame.Position = UDim2.new(0, 15, 0, 15)
ContentScrollFrame.Size = UDim2.new(1, -30, 1, -30)
ContentScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentScrollFrame.ScrollBarThickness = 4
ContentScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

-- START button click functionality
StartButton.MouseButton1Click:Connect(function()
    print("[PixieHub] Starting...")
    -- Hide the starting UI
    ProfileFrame.Visible = false
    GreetingLabel.Visible = false
    DateTimeLabel.Visible = false
    StartButton.Visible = false
    
    -- Show the main UI
    CategoryFrame.Visible = true
    ContentPageFrame.Visible = true
    
    -- Load changelog by default
    loadChangelog()
end)

-- Function to update date and time
local function updateDateTime()
    local currentTime = os.date("*t")
    local timeString = string.format("%02d:%02d:%02d", currentTime.hour, currentTime.min, currentTime.sec)
    local dateString = string.format("%s, %s %d, %d", 
        os.date("%A", os.time()), 
        os.date("%B", os.time()), 
        currentTime.day, 
        currentTime.year
    )
    DateTimeLabel.Text = dateString .. " • " .. timeString
end

-- Update time immediately and then every second
updateDateTime()
RunService.Heartbeat:Connect(function()
    updateDateTime()
end)

-- Function to create category buttons
local function createCategoryButton(name, position)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Parent = CategoryScrollFrame
    button.BackgroundTransparency = 1
    button.Position = UDim2.new(0, 0, 0, position)
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.BorderSizePixel = 0
    
    -- Create corner radius
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    -- Custom hover effect for transparent buttons
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(80, 80, 80)})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        tween:Play()
    end)
    
    return button
end

-- Create category buttons
local changelogButton = createCategoryButton("Changelog", 0)
local scriptsButton = createCategoryButton("Scripts", 45)
local settingsButton = createCategoryButton("Settings", 90)
local aboutButton = createCategoryButton("About", 135)

-- Function to load changelog
function loadChangelog()
    -- Clear existing content
    for _, child in pairs(ContentScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Create changelog content
    local title = Instance.new("TextLabel")
    title.Name = "ChangelogTitle"
    title.Parent = ContentScrollFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "Changelog"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Changelog content (all in one text)
    local changelogContent = Instance.new("TextLabel")
    changelogContent.Name = "ChangelogContent"
    changelogContent.Parent = ContentScrollFrame
    changelogContent.BackgroundTransparency = 1
    changelogContent.Position = UDim2.new(0, 0, 0, 40)
    changelogContent.Size = UDim2.new(1, 0, 0, 400)
    changelogContent.Font = Enum.Font.Gotham
    changelogContent.Text = "# Update 2\n• Fixed profile picture loading\n• Improved UI responsiveness\n• Added category system\n+ New changelog page\n+ Real-time date/time display\n- Removed old description text\n\n# Update 1\n• Initial release\n+ Basic UI framework\n+ Profile picture integration\n+ Personalized greeting\n+ Minimize/close functionality"
    changelogContent.TextColor3 = Color3.fromRGB(200, 200, 200)
    changelogContent.TextSize = 14
    changelogContent.TextXAlignment = Enum.TextXAlignment.Left
    changelogContent.TextYAlignment = Enum.TextYAlignment.Top
    changelogContent.TextWrapped = true
end

-- Category button click handlers
changelogButton.MouseButton1Click:Connect(function()
    loadChangelog()
end)

scriptsButton.MouseButton1Click:Connect(function()
    -- Clear content and show scripts page
    for _, child in pairs(ContentScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    local title = Instance.new("TextLabel")
    title.Name = "ScriptsTitle"
    title.Parent = ContentScrollFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "Scripts"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add Goon item button
    local addGoonButton = Instance.new("TextButton")
    addGoonButton.Name = "AddGoonButton"
    addGoonButton.Parent = ContentScrollFrame
    addGoonButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    addGoonButton.Position = UDim2.new(0, 0, 0, 50)
    addGoonButton.Size = UDim2.new(0, 200, 0, 35)
    addGoonButton.Font = Enum.Font.GothamBold
    addGoonButton.Text = "Add Goon item"
    addGoonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addGoonButton.TextSize = 14
    addGoonButton.BorderSizePixel = 2
    addGoonButton.BorderColor3 = Color3.fromRGB(0, 150, 255)
    
    -- Create corner radius for button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = addGoonButton
    
    -- Button hover effect
    createHoverEffect(addGoonButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(80, 80, 80))
    
    -- Add Goon item functionality
    addGoonButton.MouseButton1Click:Connect(function()
        local humanoid = Player.Character:FindFirstChildWhichIsA("Humanoid")
        local backpack = Player:FindFirstChildWhichIsA("Backpack")
        if not humanoid or not backpack then 
            print("[PixieHub] Error: Could not find humanoid or backpack")
            return 
        end

        local tool = Instance.new("Tool")
        tool.Name = "Jerk Off"
        tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
        tool.RequiresHandle = false
        tool.Parent = backpack

        local jorkin = false
        local track = nil

        local function stopTomfoolery()
            jorkin = false
            if track then
                track:Stop()
                track = nil
            end
        end

        tool.Equipped:Connect(function() jorkin = true end)
        tool.Unequipped:Connect(stopTomfoolery)
        humanoid.Died:Connect(stopTomfoolery)

        -- R15 detection function
        local function isR15(player)
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    return humanoid.RigType == Enum.HumanoidRigType.R15
                end
            end
            return false
        end

        -- Animation loop
        spawn(function()
            while task.wait() do
                if not jorkin then continue end

                local isR15Player = isR15(Player)
                if not track then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = not isR15Player and "rbxassetid://72042024" or "rbxassetid://698251653"
                    track = humanoid:LoadAnimation(anim)
                end

                track:Play()
                track:AdjustSpeed(isR15Player and 0.7 or 0.65)
                track.TimePosition = 0.6
                task.wait(0.1)
                while track and track.TimePosition < (not isR15Player and 0.65 or 0.7) do task.wait(0.1) end
                if track then
                    track:Stop()
                    track = nil
                end
            end
        end)
        
        print("[PixieHub] Goon item added to backpack!")
    end)
end)

settingsButton.MouseButton1Click:Connect(function()
    -- Clear content and show settings page
    for _, child in pairs(ContentScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    local title = Instance.new("TextLabel")
    title.Name = "SettingsTitle"
    title.Parent = ContentScrollFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
end)

aboutButton.MouseButton1Click:Connect(function()
    -- Clear content and show about page
    for _, child in pairs(ContentScrollFrame:GetChildren()) do
        child:Destroy()
    end
    
    local title = Instance.new("TextLabel")
    title.Name = "AboutTitle"
    title.Parent = ContentScrollFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "About"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
end)

-- Make the window draggable from the title bar
local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Resize functionality
local resizing = false
local resizeStart
local startSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStart = input.Position
        startSize = MainFrame.Size
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

ResizeHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and resizing then
        local delta = input.Position - resizeStart
        local newWidth = math.max(400, startSize.X.Offset + delta.X)
        local newHeight = math.max(200, startSize.Y.Offset + delta.Y)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        -- Update original size for minimize functionality
        originalSize = MainFrame.Size
    end
end)

-- Animation sequence when GUI loads
local function playLoadingAnimation()
    -- Final sizes and positions
    local finalSize = UDim2.new(0, 600, 0, 300)
    local finalPosition = UDim2.new(0.5, -300, 0.5, -150)
    local verticalSize = UDim2.new(0, 50, 0, 300)
    local verticalPosition = UDim2.new(0.5, -25, 0.5, -150)
    
    -- Step 1: Stretch vertically from center (0.5 seconds)
    local verticalTween = TweenService:Create(
        MainFrame, 
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Size = verticalSize, Position = verticalPosition}
    )
    
    verticalTween:Play()
    
    -- Step 2: Stretch horizontally from center after vertical animation completes (0.5 seconds)
    verticalTween.Completed:Connect(function()
        local horizontalTween = TweenService:Create(
            MainFrame, 
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
            {Size = finalSize, Position = finalPosition}
        )
        
        horizontalTween:Play()
        
        -- Step 3: Fade in ALL UI elements after horizontal animation completes
        horizontalTween.Completed:Connect(function()
            local fadeInInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            -- Fade in title bar
            local titleBarTween = TweenService:Create(TitleBar, fadeInInfo, {BackgroundTransparency = 0})
            
            -- Fade in title text
            local titleTween = TweenService:Create(Title, fadeInInfo, {TextTransparency = 0})
            
            -- Fade in close button
            local closeBgTween = TweenService:Create(CloseButton, fadeInInfo, {BackgroundTransparency = 0})
            local closeTextTween = TweenService:Create(CloseButton, fadeInInfo, {TextTransparency = 0})
            
            -- Fade in minimize button
            local minBgTween = TweenService:Create(MinimizeButton, fadeInInfo, {BackgroundTransparency = 0})
            local minTextTween = TweenService:Create(MinimizeButton, fadeInInfo, {TextTransparency = 0})
            
            -- Fade in resize icon
            local resizeTween = TweenService:Create(ResizeIcon, fadeInInfo, {TextTransparency = 0})
            
            -- Fade in profile frame
            local profileFrameTween = TweenService:Create(ProfileFrame, fadeInInfo, {BackgroundTransparency = 0})
            
            -- Fade in profile picture
            local profileTween = TweenService:Create(ProfilePicture, fadeInInfo, {ImageTransparency = 0})
            
            -- Fade in greeting label
            local greetingTween = TweenService:Create(GreetingLabel, fadeInInfo, {TextTransparency = 0})
            
            -- Fade in date/time label
            local dateTimeTween = TweenService:Create(DateTimeLabel, fadeInInfo, {TextTransparency = 0})
            
            -- Fade in START button
            local startBgTween = TweenService:Create(StartButton, fadeInInfo, {BackgroundTransparency = 0})
            local startTextTween = TweenService:Create(StartButton, fadeInInfo, {TextTransparency = 0})
            
            -- Play all fade-in animations simultaneously
            titleBarTween:Play()
            titleTween:Play()
            closeBgTween:Play()
            closeTextTween:Play()
            minBgTween:Play()
            minTextTween:Play()
            resizeTween:Play()
            profileFrameTween:Play()
            profileTween:Play()
            greetingTween:Play()
            dateTimeTween:Play()
            startBgTween:Play()
            startTextTween:Play()
        end)
    end)
end

-- Start the loading animation after a brief delay
task.wait(0.1)
playLoadingAnimation()

print("[PixieHub] Loaded successfully!")