local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- State Variables
local glitchEnabled = false
local glitchBox = nil
local glitchSpeed = 150 -- Default speed
local toggleKey = Enum.KeyCode.Z -- Default PC toggle keybind
local isBinding = false
local isGlitching = false

-------------------------
-- 1. GUI CLEANUP & CREATION
-------------------------
local guiName = "SpeedGlitchGuiV3"
local guiParent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

if guiParent:FindFirstChild(guiName) then
	guiParent[guiName]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.7, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Speed Glitch Settings"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 35)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "Status: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0, 70)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.5, 0, 0, 30)
speedBox.Position = UDim2.new(0.45, 0, 0, 70)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.Text = tostring(glitchSpeed)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.Parent = mainFrame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(0.9, 0, 0, 30)
keybindBtn.Position = UDim2.new(0.05, 0, 0, 110)
keybindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
keybindBtn.Text = "Bind: " .. toggleKey.Name
keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindBtn.Font = Enum.Font.GothamBold
keybindBtn.TextSize = 14
keybindBtn.Parent = mainFrame

-------------------------
-- 2. MECHANIC LOGIC
-------------------------
local function createBox()
	if glitchBox then glitchBox:Destroy() end
	
	glitchBox = Instance.new("Part")
	glitchBox.Name = "GlitchBox"
	glitchBox.Size = Vector3.new(1.5, 4, 1.5)
	glitchBox.Color = Color3.fromRGB(150, 150, 150)
	glitchBox.Transparency = 0.5
	glitchBox.CanCollide = false
	glitchBox.Massless = true
	
	-- FIXED TELEPORTING: Position the box FIRST, then weld it.
	-- Changed offset from 3 to 1.2 so it's directly next to the avatar.
	glitchBox.CFrame = rootPart.CFrame * CFrame.new(1.2, 0, 0)
	glitchBox.Parent = character
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rootPart
	weld.Part1 = glitchBox
	weld.Parent = glitchBox
end

local function removeBox()
	if glitchBox then
		glitchBox:Destroy()
		glitchBox = nil
	end
end

local function toggleGlitch()
	glitchEnabled = not glitchEnabled
	
	if glitchEnabled then
		toggleBtn.Text = "Status: ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		createBox()
	else
		toggleBtn.Text = "Status: OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		removeBox()
	end
end

local function applySpeedGlitch()
	if isGlitching then return end
	isGlitching = true
	
	local rightVector = rootPart.CFrame.RightVector
	
	-- FIXED NOT WORKING: Roblox's humanoid cancels out sudden speed changes. 
	-- Running this in a tiny loop ensures the fling successfully overpowers the game's physics.
	for i = 1, 5 do
		rootPart.AssemblyLinearVelocity = (rightVector * glitchSpeed) + Vector3.new(0, glitchSpeed / 3, 0)
		task.wait()
	end
	
	task.wait(0.2)
	isGlitching = false
end

-------------------------
-- 3. JUMP & MOVEMENT DETECTION (PC + MOBILE)
-------------------------
local function setupCharacter(newChar)
	character = newChar
	rootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	
	if glitchEnabled then
		createBox()
	end
	
	-- Listen directly to the Humanoid jumping instead of the keyboard
	humanoid.Jumping:Connect(function(isActive)
		if isActive and glitchEnabled then
			-- If the player is moving their thumbstick/keys at all, trigger the glitch
			if humanoid.MoveDirection.Magnitude > 0 then
				applySpeedGlitch()
			end
		end
	end)
end

player.CharacterAdded:Connect(setupCharacter)
-- Run setup on the current character immediately
setupCharacter(character)

-------------------------
-- 4. INPUTS & SETTINGS
-------------------------
toggleBtn.MouseButton1Click:Connect(toggleGlitch)

speedBox.FocusLost:Connect(function()
	local newSpeed = tonumber(speedBox.Text)
	if newSpeed then
		glitchSpeed = newSpeed
	else
		speedBox.Text = tostring(glitchSpeed)
	end
end)

keybindBtn.MouseButton1Click:Connect(function()
	isBinding = true
	keybindBtn.Text = "Press any key..."
	keybindBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if isBinding then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			toggleKey = input.KeyCode
			keybindBtn.Text = "Bind: " .. toggleKey.Name
			keybindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			isBinding = false
		end
		return
	end
	
	if gameProcessed then return end
	
	if input.KeyCode == toggleKey then
		toggleGlitch()
	end
end)
