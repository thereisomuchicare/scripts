local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIGURATION & STATE
local Config = {
	Name = "Fake C4",
	Cooldown = 2,
	CanUse = true,
	CursorMode = nil -- Selected on execution: "New" (Cursor Follower) or "Old" (Classic Gun Asset)
}

-- ROBLOX BUILT-IN GUN CURSORS
local GUN_CURSOR = "rbxasset://textures/GunCursor.png"
local RELOAD_CURSOR = "rbxasset://textures/GunWaitCursor.png"

local renderConnection = nil

-- ============================================================================
-- 1. MODEL BUILDER (OFFICIAL FAKE C4 GEAR ASSET)
-- ============================================================================
local function BuildC4Handle()
	local Handle = Instance.new("Part")
	Handle.Name = "Handle"
	Handle.Size = Vector3.new(1.8, 0.7, 1.2)
	Handle.CanCollide = true
	Handle.Material = Enum.Material.SmoothPlastic

	-- Fake C4 Mesh & Texture (Catalog Asset ID: 104642566)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "rbxassetid://104642566"
	Mesh.TextureId = "rbxassetid://104642537"
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.Parent = Handle

	return Handle
end

-- ============================================================================
-- 2. BACKPACK INVENTORY ORGANIZER (SLOTS 2, 3, 4...)
-- ============================================================================
local function OrganizeBackpack()
	local char = Player.Character
	if not char then return end

	local allTools = {}
	for _, obj in ipairs(char:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end
	for _, obj in ipairs(Player.Backpack:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end

	local bombs = {}
	local others = {}

	for _, tool in ipairs(allTools) do
		if tool.Name == Config.Name then
			table.insert(bombs, tool)
		else
			table.insert(others, tool)
		end
		tool.Parent = nil
	end

	-- Slot 1: First non-bomb item (if available)
	if #others > 0 then
		others[1].Parent = Player.Backpack
	end

	-- Slots 2+: All C4 Bombs
	for _, bomb in ipairs(bombs) do
		bomb.Parent = Player.Backpack
	end

	-- Remaining Slots: Other tools
	for i = 2, #others do
		others[i].Parent = Player.Backpack
	end
end

-- ============================================================================
-- 3. GUI CREATION (STARTUP PROMPT, CURSOR OVERLAY, MAIN MENU)
-- ============================================================================

-- Startup Choice GUI
local startupGui = Instance.new("ScreenGui", PlayerGui)
startupGui.Name = "C4_StartupChoice"
startupGui.ResetOnSpawn = false

local choiceFrame = Instance.new("Frame", startupGui)
choiceFrame.Size = UDim2.new(0, 340, 0, 190)
choiceFrame.Position = UDim2.new(0.5, -170, 0.5, -95)
choiceFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
choiceFrame.BorderSizePixel = 0

local uiCornerPrompt = Instance.new("UICorner", choiceFrame)
uiCornerPrompt.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", choiceFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.Text = "SELECT CURSOR MODE"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1

local btnNew = Instance.new("TextButton", choiceFrame)
btnNew.Size = UDim2.new(0.85, 0, 0, 45)
btnNew.Position = UDim2.new(0.075, 0, 0.3, 0)
btnNew.Text = "New Mode (Follow Cursor + HUD Text)"
btnNew.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
btnNew.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNew.Font = Enum.Font.SourceSansBold
btnNew.TextSize = 14
Instance.new("UICorner", btnNew).CornerRadius = UDim.new(0, 6)

local btnOld = Instance.new("TextButton", choiceFrame)
btnOld.Size = UDim2.new(0.85, 0, 0, 45)
btnOld.Position = UDim2.new(0.075, 0, 0.62, 0)
btnOld.Text = "Classic Mode (Roblox Gun Cursor)"
btnOld.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
btnOld.TextColor3 = Color3.fromRGB(255, 255, 255)
btnOld.Font = Enum.Font.SourceSansBold
btnOld.TextSize = 14
Instance.new("UICorner", btnOld).CornerRadius = UDim.new(0, 6)

-- Custom Cursor ScreenGui (For "New" Mode)
local customCursorGui = Instance.new("ScreenGui", PlayerGui)
customCursorGui.Name = "C4_CustomCursor"
customCursorGui.ResetOnSpawn = false
customCursorGui.Enabled = false

local cursorTextLabel = Instance.new("TextLabel", customCursorGui)
cursorTextLabel.Size = UDim2.new(0, 120, 0, 25)
cursorTextLabel.BackgroundTransparency = 1
cursorTextLabel.Text = "Fake C4"
cursorTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cursorTextLabel.TextScaled = true
cursorTextLabel.Font = Enum.Font.SourceSansBold

local stroke = Instance.new("UIStroke", cursorTextLabel)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0, 0, 0)

-- Main Menu GUI
local sg = Instance.new("ScreenGui", PlayerGui)
sg.Name = "C4_Final_Menu"
sg.ResetOnSpawn = false
sg.Enabled = false

local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0, 70, 0, 40)
toggle.Position = UDim2.new(0, 10, 0.5, -20)
toggle.Text = "MENU"
toggle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 14
toggle.Draggable = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 200, 0, 210)
frame.Position = UDim2.new(0.5, -100, 0.4, -105)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local nameInput = Instance.new("TextBox", frame)
nameInput.Size = UDim2.new(0.85, 0, 0, 32)
nameInput.Position = UDim2.new(0.075, 0, 0, 12)
nameInput.Text = Config.Name
nameInput.PlaceholderText = "Item Name..."
nameInput.Font = Enum.Font.SourceSans
nameInput.TextSize = 14

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.85, 0, 0, 32)
input.Position = UDim2.new(0.075, 0, 0, 50)
input.Text = tostring(Config.Cooldown)
input.PlaceholderText = "Cooldown (sec)..."
input.Font = Enum.Font.SourceSans
input.TextSize = 14

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.85, 0, 0, 32)
btn.Position = UDim2.new(0.075, 0, 0, 88)
btn.Text = "SAVE NAME & COOLDOWN"
btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 12

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0.85, 0, 0, 32)
addBtn.Position = UDim2.new(0.075, 0, 0, 126)
addBtn.Text = "+1 BOMB"
addBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.Font = Enum.Font.SourceSansBold
addBtn.TextSize = 13

local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.new(0.85, 0, 0, 32)
refreshBtn.Position = UDim2.new(0.075, 0, 0, 164)
refreshBtn.Text = "REFRESH (RESET BOMBS)"
refreshBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.SourceSansBold
refreshBtn.TextSize = 12

-- ============================================================================
-- 4. TOOL DISPATCHER & LOGIC
-- ============================================================================
local function GiveTool()
	local Tool = Instance.new("Tool")
	Tool.Name = Config.Name
	Tool.RequiresHandle = true
	Tool.CanBeDropped = false
	Tool.Grip = CFrame.new(0, -0.2, 0.2) * CFrame.Angles(0, math.rad(180), 0)

	local Handle = BuildC4Handle()
	Handle.Parent = Tool

	-- Equip Logic
	Tool.Equipped:Connect(function()
		if UserInputService.MouseEnabled then
			if Config.CursorMode == "New" then
				UserInputService.MouseIconEnabled = false
				customCursorGui.Enabled = true
				cursorTextLabel.Text = Config.Name
				if renderConnection then renderConnection:Disconnect() end
				renderConnection = RunService.RenderStepped:Connect(function()
					local mPos = UserInputService:GetMouseLocation()
					cursorTextLabel.Position = UDim2.new(0, mPos.X - 60, 0, mPos.Y + 18)
				end)
			else
				Mouse.Icon = GUN_CURSOR
			end
		end
	end)

	-- Unequip Logic
	Tool.Unequipped:Connect(function()
		if UserInputService.MouseEnabled then
			if Config.CursorMode == "New" then
				UserInputService.MouseIconEnabled = true
				customCursorGui.Enabled = false
				if renderConnection then
					renderConnection:Disconnect()
					renderConnection = nil
				end
			else
				Mouse.Icon = ""
			end
		end
	end)

	-- Activation (Throw) Logic
	Tool.Activated:Connect(function()
		if not Config.CanUse then return end
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		Config.CanUse = false

		if UserInputService.MouseEnabled then
			if Config.CursorMode == "New" then
				cursorTextLabel.Text = "reloading"
			else
				Mouse.Icon = RELOAD_CURSOR
			end
		end

		-- Spawn dropped C4 bomb using Fake C4 Mesh
		local d_handle = BuildC4Handle()
		d_handle.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
		d_handle.Parent = game.Workspace

		-- Dropped bomb disappears after exactly 22 seconds
		Debris:AddItem(d_handle, 22)

		-- Impulse throw towards mouse location
		local bv = Instance.new("BodyVelocity", d_handle)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = ((Mouse.Hit.p - hrp.Position).Unit * 25) + Vector3.new(0, 10, 0)
		Debris:AddItem(bv, 0.1)

		-- Hide tool mesh in hand during cooldown
		Handle.Transparency = 1

		-- Independent tool return cooldown
		task.wait(Config.Cooldown)

		Handle.Transparency = 0
		Config.CanUse = true

		if Tool.Parent == char and UserInputService.MouseEnabled then
			if Config.CursorMode == "New" then
				cursorTextLabel.Text = Config.Name
			else
				Mouse.Icon = GUN_CURSOR
			end
		end
	end)

	Tool.Parent = Player.Backpack
	OrganizeBackpack()
end

-- ============================================================================
-- 5. INITIALIZATION & MENU EVENT BINDINGS
-- ============================================================================
local function InitializeScript(mode)
	Config.CursorMode = mode
	startupGui:Destroy()
	sg.Enabled = true

	GiveTool()

	Player.CharacterAdded:Connect(function()
		task.wait(1)
		GiveTool()
	end)
end

btnNew.MouseButton1Click:Connect(function() InitializeScript("New") end)
btnOld.MouseButton1Click:Connect(function() InitializeScript("Old") end)

toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

btn.MouseButton1Click:Connect(function()
	Config.Cooldown = tonumber(input.Text) or Config.Cooldown

	local newName = nameInput.Text
	if newName ~= "" and newName ~= Config.Name then
		local char = Player.Character
		for _, tool in ipairs(Player.Backpack:GetChildren()) do
			if tool.Name == Config.Name then tool.Name = newName end
		end
		if char then
			for _, tool in ipairs(char:GetChildren()) do
				if tool.Name == Config.Name then tool.Name = newName end
			end
		end
		Config.Name = newName
		if Config.CursorMode == "New" then
			cursorTextLabel.Text = Config.Name
		end
	end
	frame.Visible = false
end)

addBtn.MouseButton1Click:Connect(function()
	GiveTool()
end)

refreshBtn.MouseButton1Click:Connect(function()
	local char = Player.Character
	for _, tool in ipairs(Player.Backpack:GetChildren()) do
		if tool.Name == Config.Name then tool:Destroy() end
	end
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool.Name == Config.Name then tool:Destroy() end
		end
	end

	if UserInputService.MouseEnabled then
		if Config.CursorMode == "New" then
			UserInputService.MouseIconEnabled = true
			customCursorGui.Enabled = false
		else
			Mouse.Icon = ""
		end
	end

	Config.CanUse = true
	GiveTool()
end)
