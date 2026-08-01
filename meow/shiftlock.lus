local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local playerScripts = localPlayer:WaitForChild("PlayerScripts")

-- 1. Ensure Developer allows Shift Lock in settings
localPlayer.DevEnableMouseLock = true

-- 2. Dynamically Generate the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomShiftLockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 80)
frame.Position = UDim2.new(1, -230, 1, -90) -- Positions at Bottom Right
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

local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
local cameras = playerModule:GetCameras()
local activeMouseLock = cameras and cameras.activeMouseLock

-- 4. Shift Lock Toggle Handler
local function onShiftLockToggled(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin and activeMouseLock then
		isShiftLocked = not isShiftLocked
		activeMouseLock:EnableMouseLock(isShiftLocked)
	end
	return Enum.ContextActionResult.Pass
end

-- 5. Function to apply the new keybind globally
local function applyKeybind(newKey)
	-- Remove the default Roblox Shift keybind so they don't conflict
	ContextActionService:UnbindAction("MouseLockSwitchAction")
	
	-- Unbind any old custom keys
	ContextActionService:UnbindAction("CustomShiftLockAction")
	
	-- Bind the newly selected key
	ContextActionService:BindAction("CustomShiftLockAction", onShiftLockToggled, false, newKey)
end

-- Wait a moment for Roblox to finish loading its default systems, then apply ours
task.spawn(function()
	task.wait(1)
	applyKeybind(currentKey)
end)

-- 6. GUI Interaction Logic (Clicking and Binding)
bindButton.MouseButton1Click:Connect(function()
	if isListening then return end
	isListening = true
	bindButton.Text = "Press any key..."
	bindButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Turns red while listening
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	-- Only listen for keyboard inputs to avoid binding the mouse click
	if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
		
		-- If they press Escape, cancel the binding process
		if input.KeyCode == Enum.KeyCode.Escape then
			isListening = false
			bindButton.Text = "Current Key: " .. currentKey.Name
			bindButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			return
		end
		
		-- Assign the new key
		currentKey = input.KeyCode
		isListening = false
		bindButton.Text = "Current Key: " .. currentKey.Name
		bindButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		
		-- Apply it to the game
		applyKeybind(currentKey)
	end
end)
