local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- State Variables
local glitchEnabled = false
local glitchBox = nil
local glitchSpeed = 150 -- Default speed
local toggleKey = Enum.KeyCode.Z -- Default toggle keybind
local isBinding = false -- Used when setting a new keybind

-------------------------
-- 1. GUI CLEANUP & CREATION
-------------------------
local guiName = "SpeedGlitchGuiV2"
local guiParent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

-- Remove old GUI if it exists
if guiParent:FindFirstChild(guiName) then
	guiParent[guiName]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Main Background Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.7, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Allows you to drag the GUI around
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Speed Glitch Settings"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 35)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "Status: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

-- Speed Input Container
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

-- Keybind Button
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
	glitchBox.Size = Vector3.new(2, 5, 2)
	glitchBox.Color = Color3.fromRGB(150, 150, 150)
	glitchBox.Transparency = 0.5
	glitchBox.CanCollide = false
	glitchBox.Massless = true
	glitchBox.Parent = character
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rootPart
	weld.Part1 = glitchBox
	weld.Parent = glitchBox
	
	glitchBox.CFrame = rootPart.CFrame * CFrame.new(3, 0, 0)
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
	local rightVector = rootPart.CFrame.RightVector
	-- Throw the player to the right based on the custom speed (Y-axis jump force is scaled based on speed)
	rootPart.AssemblyLinearVelocity = (rightVector * glitchSpeed) + Vector3.new(0, glitchSpeed / 3, 0)
end

-- Re-apply box if the player resets/dies
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	rootPart = character:WaitForChild("HumanoidRootPart")
	if glitchEnabled then
		createBox()
	end
end)

-------------------------
-- 3. INPUTS & SETTINGS
-------------------------
-- Toggle Button Click
toggleBtn.MouseButton1Click:Connect(toggleGlitch)

-- Update Speed Setting
speedBox.FocusLost:Connect(function()
	local newSpeed = tonumber(speedBox.Text)
	if newSpeed then
		glitchSpeed = newSpeed
	else
		-- Reset back to previous valid speed if they typed letters instead of numbers
		speedBox.Text = tostring(glitchSpeed)
	end
end)

-- Keybind Setup
keybindBtn.MouseButton1Click:Connect(function()
	isBinding = true
	keybindBtn.Text = "Press any key..."
	keybindBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50) -- Turn yellow while listening
end)

-- Keyboard Input Listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- 1. Handle Keybinding first
	if isBinding then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			toggleKey = input.KeyCode
			keybindBtn.Text = "Bind: " .. toggleKey.Name
			keybindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			isBinding = false
		end
		return
	end
	
	-- Ignore chat and other menus
	if gameProcessed then return end
	
	-- 2. Handle Toggle via Hotkey
	if input.KeyCode == toggleKey then
		toggleGlitch()
	end
	
	-- 3. Handle Speed Glitch Execution (Jump + D)
	if glitchEnabled and input.KeyCode == Enum.KeyCode.Space then
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			applySpeedGlitch()
		end
	end
end)
