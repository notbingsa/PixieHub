print([[

   8 888888888o    8 8888 `8.`8888.      ,8'  8 8888 8 8888888888   8 8888        8 8 8888      88 8 888888888o   
   8 8888    `88.  8 8888  `8.`8888.    ,8'   8 8888 8 8888         8 8888        8 8 8888      88 8 8888    `88. 
   8 8888     `88  8 8888   `8.`8888.  ,8'    8 8888 8 8888         8 8888        8 8 8888      88 8 8888     `88 
   8 8888     ,88  8 8888    `8.`8888.,8'     8 8888 8 8888         8 8888        8 8 8888      88 8 8888     ,88 
   8 8888.   ,88'  8 8888     `8.`88888'      8 8888 8 888888888888 8 8888        8 8 8888      88 8 8888.   ,88' 
   8 888888888P'   8 8888     .88.`8888.      8 8888 8 8888         8 8888        8 8 8888      88 8 8888888888   
   8 8888          8 8888    .8'`8.`8888.     8 8888 8 8888         8 8888888888888 8 8888      88 8 8888    `88. 
   8 8888          8 8888   .8'  `8.`8888.    8 8888 8 8888         8 8888        8 ` 8888     ,8P 8 8888      88 
   8 8888          8 8888  .8'    `8.`8888.   8 8888 8 8888         8 8888        8   8888   ,d8P  8 8888    ,88' 
   8 8888          8 8888 .8'      `8.`8888.  8 8888 8 888888888888 8 8888        8    `Y88888P'   8 888888888P   

                                                      Made by Bingsa
                                                     #1 Hub In Roblox
]])

local syde = loadstring(game:HttpGet("https://raw.githubusercontent.com/essencejs/syde/refs/heads/main/source", true))()

syde:Load({
    Logo = '7488932274',
    Name = 'Pixie Hub',
    Status = 'Stable',
    Accent = Color3.fromRGB(251, 144, 255),
    HitBox = Color3.fromRGB(251, 144, 255),
    AutoLoad = false,
    Socials = {},
    ConfigurationSaving = {
        Enabled = true,
        FolderName = 'SydeDemo',
        FileName = "config"
    },
    AutoJoinDiscord = {
        Enabled = false,
        Invite = "CZRZBwPz",
        RememberJoins = false
    }
})

local Window = syde:Init({
    Title = 'Pixie Hub';
    SubText = '#1 Hub on Roblox'
})

local PlayerTab = Window:InitTab('Player')
local TrollTab = Window:InitTab('Troll')
local CombatTab = Window:InitTab('Combat')
local MiscTab = Window:InitTab('Misc')

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local isFlyActive = false
local isNoclipActive = false
local isWalkOnAirActive = false

local flyLoop = nil
local flyInputBeganConnection = nil
local flyInputEndedConnection = nil

local noclipLoopConnection = nil
local noclipCharacterAddedConnection = nil
local noclipChildAddedConnection = nil

local walkOnAirCharacterAddedConnection = nil

local noclipOriginalPartStates = {}

local originalGravity = Workspace.Gravity
local currentTrail = nil

local currentFlyBodyGyro = nil
local currentFlyBodyVelocity = nil

local function deactivateFly()
    if not isFlyActive then return end
    FLYING = false
    if flyLoop then task.cancel(flyLoop) flyLoop = nil end
    if flyInputBeganConnection then flyInputBeganConnection:Disconnect() flyInputBeganConnection = nil end
    if flyInputEndedConnection then flyInputEndedConnection:Disconnect() flyInputEndedConnection = nil end

    if currentFlyBodyGyro and currentFlyBodyGyro.Parent then currentFlyBodyGyro:Destroy() end
    if currentFlyBodyVelocity and currentFlyBodyVelocity.Parent then currentFlyBodyVelocity:Destroy() end
    currentFlyBodyGyro = nil
    currentFlyBodyVelocity = nil

    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChildOfClass('Humanoid') then
        char:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() camera.CameraType = Enum.CameraType.Custom end)
    isFlyActive = false
    syde:Notify({Title = 'Fly', Content = 'Fly is: OFF', Duration = 1})
    local toggle = PlayerTab:FindToggle("Fly")
    if toggle then toggle:Set(false) end
end

local function deactivateNoclip()
    if not isNoclipActive then return end
    if noclipLoopConnection then noclipLoopConnection:Disconnect() noclipLoopConnection = nil end
    if noclipChildAddedConnection then noclipChildAddedConnection:Disconnect() noclipChildAddedConnection = nil end
    if noclipCharacterAddedConnection then noclipCharacterAddedConnection:Disconnect() noclipCharacterAddedConnection = nil end

    for part, originalState in pairs(noclipOriginalPartStates) do
        if part and part.Parent then
            part.CanCollide = originalState.CanCollide
            part.Massless = originalState.Massless
        end
    end
    table.clear(noclipOriginalPartStates)

    isNoclipActive = false
    syde:Notify({Title = 'Noclip', Content = 'Noclip is: OFF', Duration = 1})
    local toggle = PlayerTab:FindToggle("Noclip")
    if toggle then toggle:Set(false) end
end

local function deactivateWalkOnAir()
    if not isWalkOnAirActive then return end
    if walkOnAirCharacterAddedConnection then walkOnAirCharacterAddedConnection:Disconnect() walkOnAirCharacterAddedConnection = nil end
    if currentTrail then
        currentTrail:Destroy()
        currentTrail = nil
    end
    isWalkOnAirActive = false
    syde:Notify({Title = 'Walk on Air', Content = 'Walk on Air is: OFF', Duration = 1})
    local toggle = PlayerTab:FindToggle("Walk on Air")
    if toggle then toggle:Set(false) end
end

local FLYING = false
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local currentFlySpeed = 100
local iyflyspeed = currentFlySpeed
local vehicleflyspeed = currentFlySpeed * 1.5
local vfly = false
local QEfly = true

local function getRoot(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function setupFlyPhysics(char)
    if currentFlyBodyGyro and currentFlyBodyGyro.Parent then currentFlyBodyGyro:Destroy() end
    if currentFlyBodyVelocity and currentFlyBodyVelocity.Parent then currentFlyBodyVelocity:Destroy() end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local T = getRoot(char)

    if not humanoid or not T then
        return false
    end

    humanoid.PlatformStand = true

    currentFlyBodyGyro = Instance.new('BodyGyro')
    currentFlyBodyVelocity = Instance.new('BodyVelocity')
    currentFlyBodyGyro.P = 9e4
    currentFlyBodyGyro.Parent = T
    currentFlyBodyVelocity.Parent = T
    currentFlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    currentFlyBodyGyro.CFrame = T.CFrame
    currentFlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    currentFlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    return true
end

local function activateFly()
    deactivateWalkOnAir()

    FLYING = true
    isFlyActive = true

    local char = Players.LocalPlayer.Character
    if not char then
        syde:Notify({
            Title = 'Fly',
            Content = 'Character not found. Waiting for character to load.',
            Duration = 3
        })
        Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
            if isFlyActive then
                if setupFlyPhysics(newChar) then
                    syde:Notify({Title = 'Fly', Content = 'Fly is: ON (Reapplied after respawn). Use WASD for movement, Q/E for vertical.', Duration = 2})
                else
                    syde:Notify({Title = 'Fly', Content = 'Failed to reapply Fly after respawn.', Duration = 3})
                    deactivateFly()
                end
            end
        end)
    else
        if not setupFlyPhysics(char) then
            syde:Notify({Title = 'Fly', Content = 'Character or Humanoid not found. Cannot activate fly.', Duration = 3})
            deactivateFly()
            return
        end
    end

    flyLoop = task.spawn(function()
        repeat task.wait()
            local currentCamera = Workspace.CurrentCamera
            local char_in_loop = Players.LocalPlayer.Character
            local humanoid_in_loop = char_in_loop and char_in_loop:FindFirstChildOfClass("Humanoid")
            local T_in_loop = char_in_loop and getRoot(char_in_loop)

            if not humanoid_in_loop or not T_in_loop or not currentFlyBodyGyro or not currentFlyBodyVelocity or not currentFlyBodyGyro.Parent or not currentFlyBodyVelocity.Parent then
                if isFlyActive and char_in_loop then
                    if setupFlyPhysics(char_in_loop) then
                        syde:Notify({Title = 'Fly', Content = 'Fly re-establishing connection.', Duration = 1})
                    else
                        syde:Notify({Title = 'Fly', Content = 'Fly functionality lost.', Duration = 1})
                        FLYING = false
                        break
                    end
                else
                    FLYING = false
                    break
                end
            end

            if humanoid_in_loop then
                humanoid_in_loop.PlatformStand = true
            end

            local moveX = CONTROL.R + CONTROL.L
            local moveY = CONTROL.Q + CONTROL.E
            local moveZ = CONTROL.F + CONTROL.B

            local desiredDirection = Vector3.new(0, 0, 0)
            if math.abs(moveX) > 0 or math.abs(moveY) > 0 or math.abs(moveZ) > 0 then
                local cameraRightVector = currentCamera.CFrame.RightVector
                local cameraLookVector = currentCamera.CFrame.LookVector
                local cameraUpVector = currentCamera.CFrame.UpVector

                desiredDirection = (cameraRightVector * moveX) +
                                   (cameraLookVector * moveZ) +
                                   (cameraUpVector * moveY)

                desiredDirection = desiredDirection.Unit * currentFlySpeed
            end
            
            currentFlyBodyVelocity.Velocity = desiredDirection
            currentFlyBodyGyro.CFrame = currentCamera.CFrame
        until not FLYING
    end)
    syde:Notify({Title = 'Fly', Content = 'Fly is: ON. Use WASD for movement, Q/E for vertical.', Duration = 2})

    if not flyInputBeganConnection then
        flyInputBeganConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if not isFlyActive then return end
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = - currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = - currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.E and QEfly then
                CONTROL.Q = currentFlySpeed
            elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
                CONTROL.E = -currentFlySpeed
            end
            pcall(function() camera.CameraType = Enum.CameraType.Track end)
        end)
    end

    if not flyInputEndedConnection then
        flyInputEndedEnded = UserInputService.InputEnded:Connect(function(input, processed)
            if processed then return end
            if not isFlyActive then return end
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then
                CONTROL.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then
                CONTROL.E = 0
            end
        end)
    end
end

local function activateNoclip()
    deactivateWalkOnAir()

    isNoclipActive = true
    local char = Players.LocalPlayer.Character
    if not char then
        syde:Notify({Title = 'Noclip', Content = 'Character not found. Cannot activate Noclip.', Duration = 3})
        deactivateNoclip()
        return
    end

    local function NoclipLoopFunction()
        if isNoclipActive and Players.LocalPlayer.Character then
            for _, child in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") then
                    if not noclipOriginalPartStates[child] then
                        noclipOriginalPartStates[child] = {
                            CanCollide = child.CanCollide,
                            Massless = child.Massless
                        }
                    end
                    child.CanCollide = false
                    child.Massless = true
                end
            end
        end
    end

    noclipLoopConnection = RunService.Stepped:Connect(NoclipLoopFunction)

    noclipCharacterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        if isNoclipActive then
            deactivateNoclip()
            activateNoclip()
            syde:Notify({Title = 'Noclip', Content = 'Noclip is: ON (Reapplied after respawn).', Duration = 2})
        end
    end)

    syde:Notify({Title = 'Noclip', Content = 'Noclip is: ON. You will phase through ALL objects (walls and floors). Gravity remains active. Use Walk on Air if you wish to float.', Duration = 5})
end


local function activateWalkOnAir()
    deactivateFly()
    deactivateNoclip()

    isWalkOnAirActive = true
    local char = Players.LocalPlayer.Character
    if not char then
        syde:Notify({Title = 'Walk on Air', Content = 'Character not found. Cannot activate Walk on Air.', Duration = 3})
        deactivateWalkOnAir()
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        syde:Notify({Title = 'Walk on Air', Content = 'HumanoidRootPart not found. Cannot create trail.', Duration = 3})
        deactivateWalkOnAir()
        return
    end

    currentTrail = Instance.new("Trail")
    currentTrail.Attachment0 = Instance.new("Attachment", root)
    currentTrail.Attachment1 = Instance.new("Attachment", root)
    currentTrail.Lifetime = 2
    currentTrail.MinLength = 1
    currentTrail.TextureMode = Enum.TextureMode.Wrap
    currentTrail.Texture = "rbxassetid://1319779383"
    currentTrail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    })
    currentTrail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    currentTrail.Parent = root

    walkOnAirCharacterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        if isWalkOnAirActive then
            deactivateWalkOnAir()
            activateWalkOnAir()
        end
    end)
    syde:Notify({Title = 'Walk on Air', Content = 'Walk on Air is: ON. A rainbow trail will follow you!', Duration = 2})
end


PlayerTab:CreateSlider({
    Title = 'Player Settings',
    Description = 'Adjust various player attributes.',
    Sliders = {
        {
            Title = 'Walk Speed',
            Range = {16, 100},
            Increment = 1,
            StarterValue = 16,
            CallBack = function(value)
                if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
                end
            end,
        },
        {
            Title = 'Jump Power',
            Range = {50, 200},
            Increment = 5,
            StarterValue = 50,
            CallBack = function(value)
                if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Players.LocalPlayer.Character.Humanoid.JumpPower = value
                end
            end,
        },
        {
            Title = 'Field of View',
            Range = {70, 120},
            Increment = 1,
            StarterValue = 70,
            CallBack = function(value)
                camera.FieldOfView = value
            end,
        },
        {
            Title = 'Fly Speed',
            Range = {100, 300},
            Increment = 1,
            StarterValue = 100,
            CallBack = function(value)
                currentFlySpeed = value
                iyflyspeed = value
                vehicleflyspeed = value * 1.5
            end,
        },
        {
            Title = 'Gravity',
            Range = {0, 500},
            Increment = 1,
            StarterValue = 196,
            CallBack = function(value)
                Workspace.Gravity = value
            end,
        }
    }
})

PlayerTab:Toggle({
    Title = 'Fly',
    Description = 'Toggles client-side fly functionality. Will deactivate Walk on Air.',
    Value = false,
    CallBack = function(value)
        if value then
            activateFly()
        else
            deactivateFly()
        end
    end,
})

PlayerTab:Toggle({
    Title = 'Noclip',
    Description = 'Phase through all objects (walls and floors). Gravity remains active. Will deactivate Walk on Air.',
    Value = false,
    CallBack = function(value)
        if value then
            activateNoclip()
        else
            deactivateNoclip()
        end
    end,
})

PlayerTab:Toggle({
    Title = 'Walk on Air',
    Description = 'A rainbow trail will follow you.',
    Value = false,
    CallBack = function(value)
        if value then
            activateWalkOnAir()
        else
            deactivateWalkOnAir()
        end
    end,
})


local player = Players.LocalPlayer
local egorEnabled = false
local runAnimId = "rbxassetid://913376220"
local runTrack
local runConn
local lastHumanoid
local originalWalkSpeed = 16

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local function playRunAnimation(h)
    if runConn then runConn:Disconnect() runConn = nil end
    if runTrack then pcall(function() runTrack:Stop() end) runTrack = nil end
    local animator = h:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", h)
    local runAnim = Instance.new("Animation")
    runAnim.AnimationId = runAnimId
    runTrack = animator:LoadAnimation(runAnim)
    runTrack.Priority = Enum.AnimationPriority.Movement
    runTrack:Play()
    runTrack:AdjustSpeed(6)
    runConn = game:GetService("RunService").RenderStepped:Connect(function()
        if h.Health <= 0 then return end
        if h.MoveDirection.Magnitude == 0 then
            if runTrack.IsPlaying then runTrack:Stop() end
        else
            if not runTrack.IsPlaying then runTrack:Play(); runTrack:AdjustSpeed(6) end
        end
    end)
end

local function stopRunAnimation()
    if runConn then runConn:Disconnect() runConn = nil end
    if runTrack then pcall(function() runTrack:Stop() end) runTrack = nil end
end

local function enableEgor()
    local hum = getHumanoid()
    if not hum then return end
    lastHumanoid = hum
    originalWalkSpeed = hum.WalkSpeed
    hum.WalkSpeed = 3
    playRunAnimation(hum)
end

local function disableEgor()
    stopRunAnimation()
    local hum = lastHumanoid or getHumanoid()
    if hum and hum.Parent then
        hum.WalkSpeed = originalWalkSpeed or 16
    end
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    lastHumanoid = hum
    if egorEnabled then
        task.defer(enableEgor)
    else
        originalWalkSpeed = hum.WalkSpeed
        stopRunAnimation()
    end
end)

TrollTab:Toggle({
    Title = 'Toggle Egor',
    Description = 'Toggles the popular Roblox Egor animation.',
    Value = false,
    CallBack = function(value)
        egorEnabled = value
        if value then
            enableEgor()
        else
            disableEgor()
        end
        syde:Notify({
            Title = 'Toggle Egor',
            Content = 'Toggle Egor is: ' .. (value and 'ON' or 'OFF'),
            Duration = 1
        })
    end,
})

function r15(plr)
    if plr.Character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 then
        return true
    end
    return false
end

TrollTab:Button({
    Title = 'Give Jerk',
    Description = 'Get an item that allows you to Jerk Off.',
    CallBack = function()
        local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
        local backpack = player:FindFirstChildWhichIsA("Backpack")
        if not humanoid or not backpack then return end

        local tool = Instance.new("Tool")
        tool.Name = "Jerk Off"
        tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha. let's justr say. My peanits."
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

        while task.wait() do
            if not jorkin then continue end
            local isR15 = r15(player)
            if not track then
                local anim = Instance.new("Animation")
                anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                track = humanoid:LoadAnimation(anim)
            end

            track:Play()
            track:AdjustSpeed(isR15 and 0.7 or 0.65)
            track.TimePosition = 0.6
            task.wait(0.1)
            while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
            if track then
                track:Stop()
                track = nil
            end
        end

        syde:Notify({
            Title = 'Give Jerk',
            Content = 'Jerk item has been given.',
            Duration = 2
        })
    end,
})
TrollTab:Button({
    Title = 'FE Hamsterball',
    Description = 'A GUI that toggles the usual movement into a hamster in a ball!',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KaterHub-Inc/scripts/refs/heads/main/unofficial-Projects/FEHamsterBall.lua"))()
        syde:Notify({
            Title = 'FE Hamsterball',
            Content = 'FE Hamsterball has been loaded.',
            Duration = 2
        })
    end,
})

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local TracersScreenGui = Instance.new("ScreenGui")
TracersScreenGui.Name = "TracersScreenGui"
TracersScreenGui.DisplayOrder = 10
TracersScreenGui.Parent = PlayerGui

local isTracing = false
local tracersLoop
local activeTracerFrames = {}

CombatTab:Toggle({
    Title = 'Toggle Tracers',
    Value = false,
    CallBack = function(value)
        isTracing = value
        if value then
            tracersLoop = task.spawn(function()
                local currentCamera = Workspace.CurrentCamera
                local localPlayer = Players.LocalPlayer

                while isTracing do
                    for _, frame in ipairs(activeTracerFrames) do
                        frame:Destroy()
                    end
                    table.clear(activeTracerFrames)

                    local myTorso = localPlayer.Character and (localPlayer.Character:FindFirstChild("Torso") or localPlayer.Character:FindFirstChild("HumanoidRootPart"))
                    if myTorso then
                        local myPosition = currentCamera:WorldToScreenPoint(myTorso.Position)
                        local my2DPos = Vector2.new(myPosition.X, myPosition.Y)

                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= localPlayer and p.Character then
                                local targetTorso = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
                                if targetTorso then
                                    local targetPosition = currentCamera:WorldToScreenPoint(targetTorso.Position)
                                    
                                    if targetPosition.Z > 0 then
                                        local target2DPos = Vector2.new(targetPosition.X, targetPosition.Y)
                                        
                                        local directionVector = target2DPos - my2DPos
                                        local distance = directionVector.Magnitude
                                        local angle = math.atan2(directionVector.Y, directionVector.X)

                                        local midPoint2D = my2DPos + directionVector / 2

                                        local tracerFrame = Instance.new("Frame")
                                        tracerFrame.Name = "TracerLine"
                                        tracerFrame.Size = UDim2.new(0, distance, 0, 2)
                                        tracerFrame.Position = UDim2.new(0, midPoint2D.X, 0, midPoint2D.Y)
                                        tracerFrame.Rotation = math.deg(angle)
                                        tracerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                                        tracerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
                                        tracerFrame.BackgroundTransparency = 0.3
                                        tracerFrame.ZIndex = 2
                                        tracerFrame.Parent = TracersScreenGui
                                        table.insert(activeTracerFrames, tracerFrame)
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        else
            if tracersLoop then
                task.cancel(tracersLoop)
                tracersLoop = nil
            end
            for _, frame in ipairs(activeTracerFrames) do
                frame:Destroy()
            end
            table.clear(activeTracerFrames)
        end
        syde:Notify({
            Title = 'Toggle Tracers',
            Content = 'Toggle Tracers is: ' .. (value and 'ON' or 'OFF'),
            Duration = 1
        })
    end,
})

--- Misc Tab
MiscTab:Button({
    Title = 'Rejoin',
    CallBack = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
        syde:Notify({
            Title = 'Rejoin',
            Content = 'Attempting to rejoin the server...',
            Duration = 1
        })
    end,
})

MiscTab:Button({
    Title = 'Rejoin & Execute',
    Description = 'This will only teleport you. To execute the script, copy the code printed to the console and paste it when you load into the new server.',
    CallBack = function()
        -- The "Rejoin & Execute" functionality requires an exploit-specific feature that can queue a script
        -- to run after a teleport. Since we cannot rely on a universal function, this button
        -- will simply teleport the user and provide the script's source code to the console
        -- for easy copying and manual execution.

        local teleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        
        -- Print the source code to the console for the user to copy.
        local sourceCode = game:HttpGet("https://raw.githubusercontent.com/essencejs/syde/refs/heads/main/source", true)
        print("-------------------- COPY SCRIPT SOURCE BELOW THIS LINE --------------------")
        print(sourceCode)
        print("-------------------- COPY SCRIPT SOURCE ABOVE THIS LINE --------------------")
        
        -- Notify the user that they will be teleported.
        syde:Notify({
            Title = 'Rejoin & Execute',
            Content = 'Teleporting now... Copy the source from your console to re-execute.',
            Duration = 3
        })
        
        -- Teleport the player.
        teleportService:Teleport(placeId)
    end,
})

local isAntiAfkActive = false
local antiAfkLoop

MiscTab:Toggle({
    Title = 'Anti-AFK (Camera Adjust)',
    Description = 'Prevents being kicked for inactivity by making tiny camera adjustments.',
    Value = false,
    CallBack = function(value)
        isAntiAfkActive = value
        if value then
            antiAfkLoop = task.spawn(function()
                while isAntiAfkActive do
                    camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
                    task.wait(0.5)
                    camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(-0.01), 0)
                    task.wait(10)
                end
            end)
            syde:Notify({
                Title = 'Anti-AFK',
                Content = 'Anti-AFK (Camera Adjust) is: ON',
                Duration = 1
            })
        else
            if antiAfkLoop then
                task.cancel(antiAfkLoop)
                antiAfkLoop = nil
            end
            syde:Notify({
                Title = 'Anti-AFK',
                Content = 'Anti-AFK (Camera Adjust) is: OFF',
                Duration = 1
            })
        end
    end,
})

local isFullbrightActive = false
local originalBrightness = game.Lighting.Brightness
local originalAmbient = game.Lighting.Ambient
local originalOutdoorAmbient = game.Lighting.OutdoorAmbient
local originalFogEnd = game.Lighting.FogEnd

MiscTab:Toggle({
    Title = 'Fullbright',
    Description = 'Eliminates darkness, making everything fully bright.',
    Value = false,
    CallBack = function(value)
        isFullbrightActive = value
        if value then
            originalBrightness = game.Lighting.Brightness
            originalAmbient = game.Lighting.Ambient
            originalOutdoorAmbient = game.Lighting.OutdoorAmbient
            originalFogEnd = game.Lighting.FogEnd

            game.Lighting.Brightness = 2
            game.Lighting.Ambient = Color3.new(1, 1, 1)
            game.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            game.Lighting.FogEnd = 1000000
            syde:Notify({
                Title = 'Fullbright',
                Content = 'Fullbright is: ON',
                Duration = 1
            })
        else
            game.Lighting.Brightness = originalBrightness
            game.Lighting.Ambient = originalAmbient
            game.Lighting.OutdoorAmbient = originalOutdoorAmbient
            game.Lighting.FogEnd = originalFogEnd
            syde:Notify({
                Title = 'Fullbright',
                Content = 'Fullbright is: OFF',
                Duration = 1
            })
        end
    end,
})
