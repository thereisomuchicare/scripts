local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local playerScripts = localPlayer:WaitForChild("PlayerScripts")

-- 1. Ensure Developer allows Shift Lock
localPlayer.DevEnableMouseLock = true

-- 2. Dynamically Generate the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomShiftLockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 80)
frame.Position = UDim2.new(1, -230, 1, -90)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.Text = "Shift Lock Keybind"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = frame

local bindButton = Instance.new("TextButton")
bindButton.Size = UDim2.new(0.9, 0, 0.4, 0)
bindButton.Position = UDim2.new(0.05, 0, 0.45, 0)
bindButton.Text = "Current Key: LeftControl"
bindButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
bindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bindButton.Font = Enum.Font.Gotham
bindButton.TextSize = 14
bindButton.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = bindButton

-- 3. Core Shift Lock Logic Variables
local isListening = false
local currentKey = Enum.KeyCode.LeftControl
local isShiftLocked = false

-- 4. Clear Roblox's Default Shift Keys so they don't interfere
task.spawn(function()
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local cameras = playerModule:GetCameras()
	
	-- Wait until Roblox finishes loading the mouse lock controller
	while not cameras.activeMouseLock do
		task.wait(0.1)
	end
	
	-- Empty the default keys so standard Shift no longer does anything
	cameras.activeMouseLock.boundKeys = {}
end)

-- 5. GUI Interaction Logic (Clicking to Bind)
bindButton.MouseButton1Click:Connect(function()
	if isListening then return end
	isListening = true
	bindButton.Text = "Press any key..."
	bindButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Turns red while waiting
end)

-- 6. Input Handling (Setting the key & Toggling)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- A. If we are currently binding a new key...
	if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Escape then
			isListening = false
			bindButton.Text = "Current Key: " .. currentKey.Name
			bindButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			return
		end
		
		-- Save the new key
		currentKey = input.KeyCode
		isListening = false
		bindButton.Text = "Current Key: " .. currentKey.Name
		bindButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		return
	end

	-- B. If we are playing normally, check if they pressed the custom toggle key
	if not gameProcessed and not isListening then
		if input.KeyCode == currentKey then
			isShiftLocked = not isShiftLocked -- Flip the state (On/Off)
		end
	end
end)

-- 7. The Enforcer: Forces Shift Lock on or off every single frame
RunService.RenderStepped:Connect(function()
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local cameras = playerModule:GetCameras()
	local activeMouseLock = cameras and cameras.activeMouseLock
	
	if activeMouseLock then
		-- This forcefully bypasses the ESC Menu setting by applying it constantly
		activeMouseLock:EnableMouseLock(isShiftLocked)
	end
end)
