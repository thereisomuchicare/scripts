local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIGURATION & STATE
local Config = {
	Name = "Fake C4",
	Cooldown = 2,
	CanUse = true,
	PlacementMode = "ClassicThrow", -- "CursorTarget" or "ClassicThrow"
	ThrowPower = 65
}

-- ROBLOX BUILT-IN GUN CURSORS
local GUN_CURSOR = "rbxasset://textures/GunCursor.png"
local RELOAD_CURSOR = "rbxasset://textures/GunWaitCursor.png"

-- ============================================================================
-- 1. HELPER FUNCTIONS
-- ============================================================================

-- Sets transparency for handle and any nested meshes/decals
local function SetHandleTransparency(handle, alpha)
	if not handle then return end
	handle.Transparency = alpha
	for _, child in ipairs(handle:GetDescendants()) do
		if child:IsA("BasePart") or child:IsA("Decal") or child:IsA("Texture") then
			child.Transparency = alpha
		end
	end
end

-- Backpack Auto-Organizer (Places C4 items starting at Slot 2)
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

	if #others > 0 then others[1].Parent = Player.Backpack end
	for _, bomb in ipairs(bombs) do bomb.Parent = Player.Backpack end
	for i = 2, #others do others[i].Parent = Player.Backpack end
end

-- Find an existing Fake C4 tool in Backpack or Character to use as master template
local function GetMasterTemplate()
	local char = Player.Character
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Tool") and item:FindFirstChild("Handle") then
				return item
			end
		end
	end
	for _, item in ipairs(Player.Backpack:GetChildren()) do
		if item:IsA("Tool") and item:FindFirstChild("Handle") then
			return item
		end
	end
	return nil
end

-- ============================================================================
-- 2. GUI CREATION (STARTUP CHOICE & MAIN MENU)
-- ============================================================================

local startupGui = Instance.new("ScreenGui", PlayerGui)
startupGui.Name = "C4_StartupChoice"
startupGui.ResetOnSpawn = false

local choiceFrame = Instance.new("Frame", startupGui)
choiceFrame.Size = UDim2.new(0, 360, 0, 190)
choiceFrame.Position = UDim2.new(0.5, -180, 0.5, -95)
choiceFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
choiceFrame.BorderSizePixel = 0
Instance.new("UICorner", choiceFrame).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", choiceFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.Text = "SELECT C4 SPAWN BEHAVIOR"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1

local btnNew = Instance.new("TextButton", choiceFrame)
btnNew.Size = UDim2.new(0.85, 0, 0, 45)
btnNew.Position = UDim2.new(0.075, 0, 0.3, 0)
btnNew.Text = "New Mode (Spawns at Mouse Click)"
btnNew.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
btnNew.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNew.Font = Enum.Font.SourceSansBold
btnNew.TextSize = 14
Instance.new("UICorner", btnNew).CornerRadius = UDim.new(0, 6)

local btnOld = Instance.new("TextButton", choiceFrame)
btnOld.Size = UDim2.new(0.85, 0, 0, 45)
btnOld.Position = UDim2.new(0.075, 0, 0.62, 0)
btnOld.Text = "Classic Mode (Arc Throw Forward)"
btnOld.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
btnOld.TextColor3 = Color3.fromRGB(255, 255, 255)
btnOld.Font = Enum.Font.SourceSansBold
btnOld.TextSize = 14
Instance.new("UICorner", btnOld).CornerRadius = UDim.new(0, 6)

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
btn.Text = "SAVE COOLDOWN & NAME"
btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 11

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
-- 3. TOOL SETUP & COMBINED THROWING MECHANICS
-- ============================================================================

local masterTemplateTool = nil

local function BindToolLogic(Tool)
	Tool.Name = Config.Name
	Tool.RequiresHandle = true
	Tool.CanBeDropped = false
	
	-- Preserve or apply official catalog icon
	if Tool.TextureId == "" then
		Tool.TextureId = "rbxthumb://type=Asset&id=104642566&w=150&h=150"
	end

	local handle = Tool:FindFirstChild("Handle")
	if not handle then return end

	-- Mouse Gun Cursor Events
	Tool.Equipped:Connect(function()
		if UserInputService.MouseEnabled then
			Mouse.Icon = GUN_CURSOR
		end
	end)

	Tool.Unequipped:Connect(function()
		if UserInputService.MouseEnabled then
			Mouse.Icon = ""
		end
		SetHandleTransparency(handle, 0)
	end)

	-- Activation Mechanics
	Tool.Activated:Connect(function()
		if not Config.CanUse then return end
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp or not handle then return end

		Config.CanUse = false

		if UserInputService.MouseEnabled then
			Mouse.Icon = RELOAD_CURSOR
		end

		-- Clone REAL handle (mesh & textures intact)
		local c4 = handle:Clone()
		c4.Name = "ThrownFakeC4"
		c4.CanCollide = true
		c4.Anchored = false

		-- Remove internal welds so it doesn't stick to the avatar's hand
		for _, child in ipairs(c4:GetChildren()) do
			if child:IsA("Weld") or child:IsA("JointInstance") then
				child:Destroy()
			end
		end

		if Config.PlacementMode == "CursorTarget" then
			-- NEW MODE: Spawns directly at Mouse target position
			local targetHit = Mouse.Hit.Position
			c4.CFrame = CFrame.new(targetHit + Vector3.new(0, 0.4, 0))
			c4.Anchored = true
		else
			-- CLASSIC MODE: Spawns in front of avatar and throws towards mouse
			local spawnPos = hrp.CFrame.Position + (hrp.CFrame.LookVector * 2.5) + Vector3.new(0, 1, 0)
			c4.CFrame = CFrame.new(spawnPos, Mouse.Hit.Position)
			
			local direction = (Mouse.Hit.Position - spawnPos).Unit
			c4.AssemblyLinearVelocity = direction * Config.ThrowPower + Vector3.new(0, 15, 0)
			c4.AssemblyAngularVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

			-- Stick to surfaces on touch
			local hasLanded = false
			c4.Touched:Connect(function(hit)
				if hasLanded or hit:IsDescendantOf(char) then return end
				hasLanded = true
				c4.Anchored = true
				c4.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				c4.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end)
		end

		c4.Parent = workspace
		Debris:AddItem(c4, 15)

		-- Hide current held item during cooldown
		SetHandleTransparency(handle, 1)

		task.wait(Config.Cooldown)

		-- Re-enable held item
		SetHandleTransparency(handle, 0)
		Config.CanUse = true

		if Tool.Parent == char and UserInputService.MouseEnabled then
			Mouse.Icon = GUN_CURSOR
		end
	end)
end

local function GiveTool()
	if not masterTemplateTool then
		masterTemplateTool = GetMasterTemplate()
	end

	local newTool
	if masterTemplateTool then
		newTool = masterTemplateTool:Clone()
	else
		-- Fallback if no tool exists in StarterPack/Backpack
		newTool = Instance.new("Tool")
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(1.8, 0.7, 1.2)
		
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshId = "rbxassetid://104642566"
		mesh.TextureId = "rbxassetid://104642537"
		mesh.Parent = handle
		handle.Parent = newTool
	end

	BindToolLogic(newTool)
	newTool.Parent = Player.Backpack
	OrganizeBackpack()
end

-- ============================================================================
-- 4. INITIALIZATION & MENU EVENT BINDINGS
-- ============================================================================

local function InitializeScript(mode)
	Config.PlacementMode = mode
	startupGui:Destroy()
	sg.Enabled = true

	-- Find master C4 item in inventory and bind or create
	local existingTool = GetMasterTemplate()
	if existingTool then
		masterTemplateTool = existingTool:Clone()
		BindToolLogic(existingTool)
		OrganizeBackpack()
	else
		GiveTool()
	end

	Player.CharacterAdded:Connect(function()
		task.wait(1)
		GiveTool()
	end)
end

btnNew.MouseButton1Click:Connect(function() InitializeScript("CursorTarget") end)
btnOld.MouseButton1Click:Connect(function() InitializeScript("ClassicThrow") end)

toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

btn.MouseButton1Click:Connect(function()
	Config.Cooldown = tonumber(input.Text) or Config.Cooldown

	local newName = nameInput.Text
	if newName ~= "" and newName ~= Config.Name then
		local char = Player.Character
		for _, tool in ipairs(Player.Backpack:GetChildren()) do
			if tool:IsA("Tool") then tool.Name = newName end
		end
		if char then
			for _, tool in ipairs(char:GetChildren()) do
				if tool:IsA("Tool") then tool.Name = newName end
			end
		end
		Config.Name = newName
	end
	frame.Visible = false
end)

addBtn.MouseButton1Click:Connect(function()
	GiveTool()
end)

refreshBtn.MouseButton1Click:Connect(function()
	local char = Player.Character
	for _, tool in ipairs(Player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Handle") then tool:Destroy() end
	end
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") and tool:FindFirstChild("Handle") then tool:Destroy() end
		end
	end

	if UserInputService.MouseEnabled then
		Mouse.Icon = ""
	end

	Config.CanUse = true
	GiveTool()
end)
