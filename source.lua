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
local CombatTab = Window:InitTab('Combat')
local ScriptsTab = Window:InitTab('Scripts')
local TrollTab = Window:InitTab('Troll')
local MiscTab = Window:InitTab('Misc')

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

-- Movement Variables
local isFlyActive = false
local isNoclipActive = false

-- Fly Function Variables
local flyLoop = nil
local flyInputBeganConnection = nil
local flyInputEndedConnection = nil

-- Noclip Function Variables
local noclipLoopConnection = nil
local noclipCharacterAddedConnection = nil
local noclipChildAddedConnection = nil
local noclipOriginalPartStates = {}

-- Common Movement Variables
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

-- Deactivation Functions
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

-- Activation Functions
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
    -- Freecam already deactivates Fly internally, so we don't need to call deactivateFreecam() here.

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
        flyInputEndedConnection = UserInputService.InputEnded:Connect(function(input, processed)
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
    -- Freecam already deactivates Noclip internally, so no need to call deactivateFreecam() here.

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

    syde:Notify({Title = 'Noclip', Content = 'Noclip is: ON. You will phase through ALL objects (walls and floors). Gravity remains active.', Duration = 5})
end

------------------------------------------------------------------------
-- Freecam (cinematic camera)
------------------------------------------------------------------------

local pi    = math.pi
local abs   = math.abs
local clamp = math.clamp
local exp   = math.exp
local rad   = math.rad
local sign  = math.sign
local sqrt  = math.sqrt
local tan   = math.tan

local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = Workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

------------------------------------------------------------------------

local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}

local NAV_GAIN = Vector3.new(1, 1, 1)*64
local PAN_GAIN = Vector2.new(0.75, 1)*8
local FOV_GAIN = 300

local PITCH_LIMIT = rad(90)

local VEL_STIFFNESS = 1.5
local PAN_STIFFNESS = 1.0
local FOV_STIFFNESS = 4.0

------------------------------------------------------------------------

local Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

------------------------------------------------------------------------

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0

local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)

------------------------------------------------------------------------

local Input = {} do
	local thumbstickCurve do
		local K_CURVATURE = 2.0
		local K_DEADZONE = 0.15

		local function fCurve(x)
			return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
		end

		local function fDeadzone(x)
			return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
		end

		function thumbstickCurve(x)
			return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
		end
	end

	local gamepad = {
		ButtonX = 0,
		ButtonY = 0,
		DPadDown = 0,
		DPadUp = 0,
		ButtonL2 = 0,
		ButtonR2 = 0,
		Thumbstick1 = Vector2.new(),
		Thumbstick2 = Vector2.new(),
	}

	local keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		U = 0,
		H = 0,
		J = 0,
		K = 0,
		I = 0,
		Y = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
		RightShift = 0,
	}

	local mouse = {
		Delta = Vector2.new(),
		MouseWheel = 0,
	}

	local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)
	local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)
	local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)
	local FOV_WHEEL_SPEED    = 1.0
	local FOV_GAMEPAD_SPEED  = 0.25
	local NAV_ADJ_SPEED      = 0.75
	local NAV_SHIFT_MUL      = 0.25

	local navSpeed = 1

	function Input.Vel(dt)
		navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kGamepad = Vector3.new(
			thumbstickCurve(gamepad.Thumbstick1.x),
			thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
			thumbstickCurve(-gamepad.Thumbstick1.y)
		)*NAV_GAMEPAD_SPEED

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A + keyboard.K - keyboard.H,
			keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
			keyboard.S - keyboard.W + keyboard.J - keyboard.U
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kGamepad = Vector2.new(
			thumbstickCurve(gamepad.Thumbstick2.y),
			thumbstickCurve(-gamepad.Thumbstick2.x)
		)*PAN_GAMEPAD_SPEED
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kGamepad + kMouse
	end

	function Input.Fov(dt)
		local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
		local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
		mouse.MouseWheel = 0
		return kGamepad + kMouse
	end

	do
		local function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function GpButton(action, state, input)
			gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		local function Thumb(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position
			return Enum.ContextActionResult.Sink
		end

		local function Trigger(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function MouseWheel(action, state, input)
			mouse[input.UserInputType.Name] = -input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
				Enum.KeyCode.W, Enum.KeyCode.U,
				Enum.KeyCode.A, Enum.KeyCode.H,
				Enum.KeyCode.S, Enum.KeyCode.J,
				Enum.KeyCode.D, Enum.KeyCode.K,
				Enum.KeyCode.E, Enum.KeyCode.I,
				Enum.KeyCode.Q, Enum.KeyCode.Y,
				Enum.KeyCode.Up, Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
			ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
			ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
			ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
			ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(gamepad)
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
			ContextActionService:UnbindAction("FreecamMouseWheel")
			ContextActionService:UnbindAction("FreecamGamepadButton")
			ContextActionService:UnbindAction("FreecamGamepadTrigger")
			ContextActionService:UnbindAction("FreecamGamepadThumbstick")
		end
	end
end

local function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

------------------------------------------------------------------------

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))
	local fov = fovSpring:Update(dt, Input.Fov(dt))

	local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))

	cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
	cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
	cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

------------------------------------------------------------------------

local PlayerState = {} do
	local mouseBehavior
	local mouseIconEnabled
	local cameraType
	local cameraFocus
	local cameraCFrame
	local cameraFieldOfView
	local screenGuis = {}
	local coreGuis = {
		Backpack = true,
		Chat = true,
		Health = true,
		PlayerList = true,
	}
	local setCores = {
		BadgesNotificationsActive = true,
		PointsNotificationsActive = true,
	}

	-- Save state and set up for freecam
	function PlayerState.Push()
		for name in pairs(coreGuis) do
			coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
		end
		for name in pairs(setCores) do
			setCores[name] = StarterGui:GetCore(name)
			StarterGui:SetCore(name, false)
		end
		local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playergui then
			for _, gui in pairs(playergui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui.Enabled then
					screenGuis[#screenGuis + 1] = gui
					gui.Enabled = false
				end
			end
		end

		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = false

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	-- Restore state
	function PlayerState.Pop()
		for name, isEnabled in pairs(coreGuis) do
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
		end
		for name, isEnabled in pairs(setCores) do
			StarterGui:SetCore(name, isEnabled)
		end
		for _, gui in pairs(screenGuis) do
			if gui.Parent then
				gui.Enabled = true
			end
		end

		Camera.FieldOfView = cameraFieldOfView
		cameraFieldOfView = nil

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

local isFreecamEnabled = false
local function StartFreecam()
    deactivateFly()
    deactivateNoclip()
    isFreecamEnabled = true
    syde:Notify({
        Title = 'Freecam',
        Content = 'Freecam is: ON. Your character is frozen in place.',
        Duration = 3
    })
	local cameraCFrame = Camera.CFrame
	cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())
	fovSpring:Reset(0)

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
end

local function StopFreecam()
    isFreecamEnabled = false
    syde:Notify({
        Title = 'Freecam',
        Content = 'Freecam is: OFF. You have returned to your character.',
        Duration = 3
    })
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
end


local function ToggleFreecam()
    if isFreecamEnabled then
        StopFreecam()
    else
        StartFreecam()
    end
end

------------------------------------------------------------------------

do
	local function HandleActivationInput(action, state, input)
		if state == Enum.UserInputState.Begin then
			if input.KeyCode == FREECAM_MACRO_KB[#FREECAM_MACRO_KB] then
				ToggleFreecam()
			end
		end
		return Enum.ContextActionResult.Pass
	end
	
	-- The original script has a bug where it binds the action every time.
	-- It's better to just bind it once.
	ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, TOGGLE_INPUT_PRIORITY, FREECAM_MACRO_KB[#FREECAM_MACRO_KB])
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
    Description = 'Toggles client-side fly functionality.',
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
    Description = 'Phase through all objects (walls and floors). Gravity remains active.',
    Value = false,
    CallBack = function(value)
        if value then
            activateNoclip()
        else
            deactivateNoclip()
        end
    end,
})

-- Scripts Tab
ScriptsTab:Button({
    Title = 'Soluna\'s 99 Nights In The Forest',
    Description = 'A very advanced 99 Nights In The Forest script that works really well!',
    CallBack = function()
        loadstring(game:HttpGet("https://soluna-script.vercel.app/99-Nights-in-the-Forest.lua",true))()
        syde:Notify({
            Title = 'Soluna\'s 99 Nights In The Forest',
            Content = 'Soluna\'s 99 Nights In The Forest has been loaded.',
            Duration = 2
        })
    end,
})

ScriptsTab:Button({
    Title = 'Infinite Yield',
    Description = 'A popular admin script with many features.',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        syde:Notify({
            Title = 'Infinite Yield',
            Content = 'Infinite Yield has been loaded.',
            Duration = 2
        })
    end,
})

-- Troll Tab
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
        
        local animId = not r15(player) and "rbxassetid://72042024" or "rbxassetid://698251653"
        
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        anim.Parent = tool
        
        local track = nil
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

        local function stopTomfoolery()
            if track then
                pcall(function() track:Stop() end)
                track = nil
            end
        end

        tool.Equipped:Connect(function()
            if humanoid and animator then
                if not track or not track.IsPlaying then
                    track = animator:LoadAnimation(anim)
                    track.Looped = true
                    track:Play()
                    track:AdjustSpeed(r15(player) and 0.7 or 0.65)
                end
            else
                print("Error: Humanoid or Animator not found.")
                stopTomfoolery()
            end
        end)

        tool.Unequipped:Connect(stopTomfoolery)
        humanoid.Died:Connect(stopTomfoolery)

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

-- The following code was commented out because it relies on variables and functions that
-- only exist in the full Infinite Yield script and would cause an error.
--[[
local KeepInfYield = false
local nosaves = false
local cooldown = false

local queueteleport = missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))

function writefileExploit()
	if writefile then
		return true
	end
end

function writefileCooldown(name,data)
	task.spawn(function()
		if not cooldown then
			cooldown = true
			writefile(name, data, true)
		else
			repeat task.wait() until cooldown == false
			writefileCooldown(name,data)
		end
		task.wait(3)
		cooldown = false
	end)
end

function updatesaves()
    if nosaves == false and writefileExploit() then
        local prefix = nil
        local StayOpen = nil
        local guiScale = nil
        local espTransparency = nil
        local logsEnabled = nil
        local jLogsEnabled = nil
        local logsWebhook = nil
        local aliases = nil
        local binds = {}
        local AllWaypoints = nil
        local PluginsTable = nil
        local currentShade1 = {R = 0, G = 0, B = 0}
        local currentShade2 = {R = 0, G = 0, B = 0}
        local currentShade3 = {R = 0, G = 0, B = 0}
        local currentText1 = {R = 0, G = 0, B = 0}
        local currentText2 = {R = 0, G = 0, B = 0}
        local currentScroll = {R = 0, G = 0, B = 0}
        local eventEditor = { SaveData = function() return {} end }

		local update = {
			prefix = prefix;
			StayOpen = StayOpen;
			guiScale = guiScale;
			keepIY = KeepInfYield;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("IY_FE.iy", HttpService:JSONEncode(update))
	end
end

MiscTab:Button({
    Title = 'Rejoin & Execute',
    Description = 'Will rejoin the game and execute Pixie Hub instantly',
    CallBack = function()
        if queueteleport then
            KeepInfYield = true
            updatesaves()
        else
            syde:Notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
        end
    end,
})
--]]

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

MiscTab:Toggle({
    Title = 'Freecam',
    Description = 'Move your camera freely around the map while your character stays still. Use WASD to move horizontally, Q/E for vertical movement.',
    Value = false,
    CallBack = function(value)
        if value then
            ToggleFreecam()
        else
            ToggleFreecam()
        end
        syde:Notify({
            Title = 'Freecam',
            Content = 'Use LeftShift and P to toggle freecam!',
            Duration = 5
        })
    end,
})
