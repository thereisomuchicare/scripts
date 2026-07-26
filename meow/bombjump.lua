local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local Config = {
	Cooldown = 2,
	CanUse = true
}

local CurrentDroppedBomb = nil -- Quản lý bom dưới đất để xóa khi hết cooldown

-- ROBLOX BUILT-IN GUN CURSORS
local GUN_CURSOR = "rbxasset://textures/GunCursor.png"
local RELOAD_CURSOR = "rbxasset://textures/GunWaitCursor.png"

-- HÀM TẠO ĐÚNG 1 PART DUY NHẤT
local function BuildC4()
	local Main = Instance.new("Part")
	Main.Name = "Handle"
	Main.Size = Vector3.new(1.8, 0.7, 1.2)
	Main.Color = Color3.fromRGB(255, 180, 50)
	Main.Material = Enum.Material.Metal
	Main.CanCollide = true
	return Main
end

-- TẠO MENU GUI
local sg = Instance.new("ScreenGui", PlayerGui)
sg.Name = "C4_Final_Menu"
sg.ResetOnSpawn = false

local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0, 60, 0, 40)
toggle.Position = UDim2.new(0, 10, 0.5, 0)
toggle.Text = "MENU"
toggle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggle.Draggable = true

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.5, -90, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8, 0, 0, 30)
input.Position = UDim2.new(0.1, 0, 0.2, 0)
input.Text = tostring(Config.Cooldown)
input.PlaceholderText = "Giây hồi..."

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.8, 0, 0, 30)
btn.Position = UDim2.new(0.1, 0, 0.6, 0)
btn.Text = "LƯU"
btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)

toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
btn.MouseButton1Click:Connect(function() 
	Config.Cooldown = tonumber(input.Text) or 0
	frame.Visible = false
end)

-- CHỨC NĂNG TOOL
local function GiveTool()
	local Tool = Instance.new("Tool")
	Tool.Name = "Gold C4 Bomb"
	Tool.RequiresHandle = true
	Tool.CanBeDropped = false
	
	Tool.Grip = CFrame.new(0, -0.2, 0.2) * CFrame.Angles(0, math.rad(180), 0)
	
	local C4Part = BuildC4()
	C4Part.Parent = Tool
	
	-- EQUIP EVENT
	Tool.Equipped:Connect(function()
		-- Only show custom cursor on PC/Laptop (mouse enabled)
		if UserInputService.MouseEnabled then
			Mouse.Icon = GUN_CURSOR
		end
	end)
	
	-- UNEQUIP EVENT
	Tool.Unequipped:Connect(function()
		if UserInputService.MouseEnabled then
			Mouse.Icon = ""
		end
	end)
	
	-- ACTIVATED EVENT
	Tool.Activated:Connect(function()
		if not Config.CanUse then return end
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		Config.CanUse = false
		
		-- Switch to Roblox reloading cursor if on PC/Laptop
		if UserInputService.MouseEnabled then
			Mouse.Icon = RELOAD_CURSOR
		end
		
		if CurrentDroppedBomb then CurrentDroppedBomb:Destroy() end
		
		local d_handle = BuildC4()
		d_handle.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
		d_handle.Parent = game.Workspace
		
		CurrentDroppedBomb = d_handle

		local bv = Instance.new("BodyVelocity", d_handle)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = ((Mouse.Hit.p - hrp.Position).Unit * 25) + Vector3.new(0, 10, 0)
		
		game.Debris:AddItem(bv, 0.1)
		
		local parts = {}
		for _, p in pairs(Tool:GetChildren()) do
			if p:IsA("BasePart") then parts[p] = p.Transparency p.Transparency = 1 end
		end
		
		task.wait(Config.Cooldown)
		
		if CurrentDroppedBomb then 
			CurrentDroppedBomb:Destroy() 
			CurrentDroppedBomb = nil
		end
		
		for p, trans in pairs(parts) do if p then p.Transparency = trans end end
		Config.CanUse = true
		
		-- Restore normal gun cursor after reloading if tool is equipped and on PC
		if Tool.Parent == char and UserInputService.MouseEnabled then
			Mouse.Icon = GUN_CURSOR
		end
	end)
	
	Tool.Parent = Player.Backpack
end

Player.CharacterAdded:Connect(function() task.wait(1) GiveTool() end)
GiveTool()
