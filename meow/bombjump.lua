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
	PlacementMode = nil -- "CursorTarget" (Real Gear Style) or "ClassicThrow"
}

-- ROBLOX BUILT-IN GUN CURSORS
local GUN_CURSOR = "rbxasset://textures/GunCursor.png"
local RELOAD_CURSOR = "rbxasset://textures/GunWaitCursor.png"

-- ============================================================================
-- 1. MODEL BUILDER (GUARANTEED VISIBLE)
-- ============================================================================
local function BuildC4Handle()
	local Handle = Instance.new("Part")
	Handle.Name = "Handle"
	Handle.Size = Vector3.new(1.5, 0.6, 1.2)
	Handle.Color = Color3.fromRGB(30, 30, 30) -- Dark gray/black C4 color
	Handle.Material = Enum.Material.Plastic
	Handle.CanCollide = true
	Handle.Transparency = 0
	
	-- Add a red "light" on top to make it look like C4
	local Light = Instance.new("Part")
	Light.Name = "LightIndicator"
	Light.Size = Vector3.new(0.4, 0.2, 0.4)
	Light.Color = Color3.fromRGB(255, 0, 0)
	Light.Material = Enum.Material.Neon
	Light.CanCollide = false
	Light.Massless = true
	
	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = Handle
	Weld.Part1 = Light
	Weld.Parent = Handle
	
	Light.CFrame = Handle.CFrame * CFrame.new(0, 0.3, 0)
	Light.Parent = Handle

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

	if #others > 0 then others[1].Parent = Player.Backpack end
	for _, bomb in ipairs(bombs) do bomb.Parent = Player.Backpack end
	for i = 2, #others do others[i].Parent = Player.Backpack end
end

-- ============================================================================
-- 3. GUI CREATION (STARTUP CHOICE & MAIN MENU)
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
btnNew.Text = "New Mode (Spawns exactly at Mouse Click)"
btnNew.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
btnNew.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNew.Font = Enum.Font.SourceSansBold
btnNew.TextSize = 14
Instance.new("UICorner", btnNew).CornerRadius = UDim.new(0, 6)

local btnOld = Instance.new("TextButton", choiceFrame)
btnOld.Size = UDim2.new(0.85, 0, 0, 45)
btnOld.Position = UDim2.new(0.075, 0, 0.62, 0)
btnOld.Text = "Classic Mode (Spawns at feet & Thrown)"
btnOld.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
btnOld.TextColor3 = Color3.fromRGB(255, 255, 255)
btnOld.Font = Enum.Font.SourceSansBold
btnOld.TextSize = 14
Instance.new("UICorner", btnOld).CornerRadius = UDim.new(0, 6)

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
	Tool.Grip = CFrame.new(0, -0.2, 0.2)
	
	-- Applies the official Fake C4 catalog thumbnail to your backpack icon
	Tool.TextureId = "rbxthumb://type=Asset&id=104642566&w=150&h=150"

	local C4Handle = BuildC4Handle()
	C4Handle.Parent = Tool

	Tool.Equipped:Connect(function()
		if UserInputService.MouseEnabled then
			Mouse.Icon = GUN_CURSOR
		end
	end)

	Tool.Unequipped:Connect(function()
		if UserInputService.MouseEnabled then
			Mouse.Icon = ""
		end
	end)

	Tool.Activated:Connect(function()
		if not Config.CanUse then return end
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		Config.CanUse = false

		if UserInputService.MouseEnabled then
			Mouse.Icon = RELOAD_CURSOR
		end

		local d_handle = BuildC4Handle()

		if Config.PlacementMode == "CursorTarget" then
			-- NEW FEATURE: Spawns exactly at the 3D mouse hit location (real gear behavior)
			-- Added a slight Y offset so it sits on top of the ground instead of glitching into it
			local targetHit = Mouse.Hit
			d_handle.CFrame = CFrame.new(targetHit.Position + Vector3.new(0, 0.3, 0))
		else
			-- OLD FEATURE: Drops under avatar and launches forward
			d_handle.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
			local bv = Instance.new("BodyVelocity", d_handle)
			bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bv.Velocity = ((Mouse.Hit.p - hrp.Position).Unit * 25) + Vector3.new(0, 10, 0)
			Debris:AddItem(bv, 0.1)
		end

		d_handle.Parent = game.Workspace
		Debris:AddItem(d_handle, 22)

		-- Hide tool in hand during cooldown
		for _, p in pairs(Tool:GetChildren()) do
			if p:IsA("BasePart") then p.Transparency = 1 end
		end

		task.wait(Config.Cooldown)

		-- Show tool again
		for _, p in pairs(Tool:GetChildren()) do
			if p:IsA("BasePart") then p.Transparency = 0 end
		end
		Config.CanUse = true

		if Tool.Parent == char and UserInputService.MouseEnabled then
			Mouse.Icon = GUN_CURSOR
		end
	end)

	Tool.Parent = Player.Backpack
	OrganizeBackpack()
end

-- ============================================================================
-- 5. INITIALIZATION & MENU EVENT BINDINGS
-- ============================================================================
local function InitializeScript(mode)
	Config.PlacementMode = mode
	startupGui:Destroy()
	sg.Enabled = true

	GiveTool()

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
			if tool.Name == Config.Name then tool.Name = newName end
		end
		if char then
			for _, tool in ipairs(char:GetChildren()) do
				if tool.Name == Config.Name then tool.Name = newName end
			end
		end
		Config.Name = newName
	end
	frame.Visible = false
end)

addBtn.MouseButton1Click:Connect(function() GiveTool() end)

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
		Mouse.Icon = ""
	end

	Config.CanUse = true
	GiveTool()
end)
