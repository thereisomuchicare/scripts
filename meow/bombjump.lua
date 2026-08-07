local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local Config = {
	Name = "Gold C4 Bomb",
	Cooldown = 2,
	CanUse = true
}

-- ROBLOX BUILT-IN GUN CURSORS
local GUN_CURSOR = "rbxasset://textures/GunCursor.png"
local RELOAD_CURSOR = "rbxasset://textures/GunWaitCursor.png"

-- FUNCTION TO CREATE EXACTLY 1 SINGLE PART
local function BuildC4()
	local Main = Instance.new("Part")
	Main.Name = "Handle"
	Main.Size = Vector3.new(1.8, 0.7, 1.2)
	Main.Color = Color3.fromRGB(255, 180, 50)
	Main.Material = Enum.Material.Metal
	Main.CanCollide = true
	return Main
end

-- BACKPACK ORGANIZATION FUNCTION (FORCES BOMBS INTO SLOTS 2, 3, 4...)
local function OrganizeBackpack()
	local char = Player.Character
	if not char then return end

	local allTools = {}
	
	-- Get all tools currently equipped and in backpack
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end
	for _, obj in pairs(Player.Backpack:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end

	local bombs = {}
	local others = {}

	-- Categorize bombs and other items, temporarily removing them from backpack
	for _, tool in pairs(allTools) do
		if tool.Name == Config.Name then
			table.insert(bombs, tool)
		else
			table.insert(others, tool)
		end
		tool.Parent = nil
	end

	-- Slot 1: First non-bomb item (if any)
	if #others > 0 then
		others[1].Parent = Player.Backpack
	end

	-- Slots 2, 3, 4...: All bombs
	for _, bomb in pairs(bombs) do
		bomb.Parent = Player.Backpack
	end

	-- Remaining slots: Other items
	for i = 2, #others do
		others[i].Parent = Player.Backpack
	end
end

-- ============================================================================
-- CREATE GUI MENU (REDESIGNED UI)
-- ============================================================================
local sg = Instance.new("ScreenGui", PlayerGui)
sg.Name = "C4_Final_Menu"
sg.ResetOnSpawn = false

local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0, 70, 0, 40)
toggle.Position = UDim2.new(0, 15, 0.5, -20)
toggle.Text = "MENU"
toggle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggle.TextColor3 = Color3.fromRGB(30, 30, 30)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 14
toggle.Draggable = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 220, 0, 240)
frame.Position = UDim2.new(0.5, -110, 0.4, -120)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Use UIListLayout to automatically space buttons evenly
local listLayout = Instance.new("UIListLayout", frame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local padding = Instance.new("UIPadding", frame)
padding.PaddingTop = UDim.new(0, 15)
padding.PaddingBottom = UDim.new(0, 15)

-- Helper function to create UI elements cleanly
local function createTextBox(placeholder, text, order)
	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(0.9, 0, 0, 32)
	tb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tb.TextColor3 = Color3.fromRGB(255, 255, 255)
	tb.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
	tb.Text = text
	tb.PlaceholderText = placeholder
	tb.Font = Enum.Font.SourceSansSemibold
	tb.TextSize = 14
	tb.LayoutOrder = order
	Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
	tb.Parent = frame
	return tb
end

local function createButton(text, bgColor, textColor, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.9, 0, 0, 32)
	b.BackgroundColor3 = bgColor
	b.TextColor3 = textColor
	b.Text = text
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 13
	b.LayoutOrder = order
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.Parent = frame
	return b
end

-- Initialize Inputs and Buttons
local nameInput = createTextBox("Item name...", Config.Name, 1)
local input = createTextBox("Cooldown seconds...", tostring(Config.Cooldown), 2)
local btn = createButton("SAVE NAME & COOLDOWN", Color3.fromRGB(255, 215, 0), Color3.fromRGB(30, 30, 30), 3)
local addBtn = createButton("+1 BOMB", Color3.fromRGB(50, 205, 50), Color3.fromRGB(255, 255, 255), 4)
local refreshBtn = createButton("REFRESH (CLEAR & RESET)", Color3.fromRGB(220, 60, 50), Color3.fromRGB(255, 255, 255), 5)


-- ============================================================================
-- MAIN TOOL FUNCTIONALITY
-- ============================================================================
local function GiveTool()
	local Tool = Instance.new("Tool")
	Tool.Name = Config.Name
	Tool.RequiresHandle = true
	Tool.CanBeDropped = false
	
	Tool.Grip = CFrame.new(0, -0.2, 0.2) * CFrame.Angles(0, math.rad(180), 0)
	
	local C4Part = BuildC4()
	C4Part.Parent = Tool
	
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
		
		local d_handle = BuildC4()
		d_handle.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
		d_handle.Parent = game.Workspace
		
		game.Debris:AddItem(d_handle, 22)

		local bv = Instance.new("BodyVelocity", d_handle)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = ((Mouse.Hit.p - hrp.Position).Unit * 25) + Vector3.new(0, 10, 0)
		
		game.Debris:AddItem(bv, 0.1)
		
		local parts = {}
		for _, p in pairs(Tool:GetChildren()) do
			if p:IsA("BasePart") then 
				parts[p] = p.Transparency 
				p.Transparency = 1 
			end
		end
		
		task.wait(Config.Cooldown)
		
		for p, trans in pairs(parts) do 
			if p then p.Transparency = trans end 
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
-- MENU BUTTON EVENTS
-- ============================================================================
toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

btn.MouseButton1Click:Connect(function() 
	Config.Cooldown = tonumber(input.Text) or Config.Cooldown
	
	local newName = nameInput.Text
	if newName ~= "" and newName ~= Config.Name then
		local char = Player.Character
		-- Update the name of all existing bombs
		for _, tool in pairs(Player.Backpack:GetChildren()) do
			if tool.Name == Config.Name then tool.Name = newName end
		end
		if char then
			for _, tool in pairs(char:GetChildren()) do
				if tool.Name == Config.Name then tool.Name = newName end
			end
		end
		Config.Name = newName
	end
	frame.Visible = false
end)

addBtn.MouseButton1Click:Connect(function()
	GiveTool() -- Add 1 new bomb and automatically reorganize backpack
end)

refreshBtn.MouseButton1Click:Connect(function()
	local char = Player.Character
	-- Delete all current bombs in backpack and hand
	for _, tool in pairs(Player.Backpack:GetChildren()) do
		if tool.Name == Config.Name then tool:Destroy() end
	end
	if char then
		for _, tool in pairs(char:GetChildren()) do
			if tool.Name == Config.Name then tool:Destroy() end
		end
	end
	-- Restore default cursor in case a held bomb was deleted
	if UserInputService.MouseEnabled then Mouse.Icon = "" end
	
	Config.CanUse = true -- Reset cooldown if stuck
	GiveTool() -- Give a single bomb back
end)

Player.CharacterAdded:Connect(function() 
	task.wait(1) 
	GiveTool() 
end)

GiveTool()
