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

-- HÀM SẮP XẾP TÚI ĐỒ (FORCE BOMB VÀO SLOT 2, 3, 4...)
local function OrganizeBackpack()
	local char = Player.Character
	if not char then return end

	local allTools = {}
	
	-- Lấy tất cả tool đang cầm và trong túi
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end
	for _, obj in pairs(Player.Backpack:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end

	local bombs = {}
	local others = {}

	-- Phân loại bom và các vật phẩm khác, đồng thời gỡ chúng ra khỏi túi tạm thời
	for _, tool in pairs(allTools) do
		if tool.Name == Config.Name then
			table.insert(bombs, tool)
		else
			table.insert(others, tool)
		end
		tool.Parent = nil
	end

	-- Slot 1: Vật phẩm đầu tiên không phải bom (nếu có)
	if #others > 0 then
		others[1].Parent = Player.Backpack
	end

	-- Slot 2, 3, 4...: Tất cả các bom
	for _, bomb in pairs(bombs) do
		bomb.Parent = Player.Backpack
	end

	-- Các Slot còn lại: Các vật phẩm khác
	for i = 2, #others do
		others[i].Parent = Player.Backpack
	end
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
frame.Size = UDim2.new(0, 180, 0, 200) -- Expanded for new buttons
frame.Position = UDim2.new(0.5, -90, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false

local nameInput = Instance.new("TextBox", frame)
nameInput.Size = UDim2.new(0.8, 0, 0, 30)
nameInput.Position = UDim2.new(0.1, 0, 0, 10)
nameInput.Text = Config.Name
nameInput.PlaceholderText = "Tên vật phẩm..."

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.8, 0, 0, 30)
input.Position = UDim2.new(0.1, 0, 0, 45)
input.Text = tostring(Config.Cooldown)
input.PlaceholderText = "Giây hồi..."

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.8, 0, 0, 30)
btn.Position = UDim2.new(0.1, 0, 0, 80)
btn.Text = "LƯU TÊN & HỒI CHIÊU"
btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)

local addBtn = Instance.new("TextButton", frame)
addBtn.Size = UDim2.new(0.8, 0, 0, 30)
addBtn.Position = UDim2.new(0.1, 0, 0, 115)
addBtn.Text = "+1 BOMB"
addBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)

local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.new(0.8, 0, 0, 30)
refreshBtn.Position = UDim2.new(0.1, 0, 0, 150)
refreshBtn.Text = "REFRESH (XÓA & LÀM MỚI)"
refreshBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 0)

-- CHỨC NĂNG TOOL CHÍNH
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

-- MENU BUTTON EVENTS
toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

btn.MouseButton1Click:Connect(function() 
	Config.Cooldown = tonumber(input.Text) or Config.Cooldown
	
	local newName = nameInput.Text
	if newName ~= "" and newName ~= Config.Name then
		local char = Player.Character
		-- Cập nhật tên tất cả các bom đang có
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
	GiveTool() -- Thêm 1 bom mới và tự động sắp xếp lại túi đồ
end)

refreshBtn.MouseButton1Click:Connect(function()
	local char = Player.Character
	-- Xóa toàn bộ bom hiện tại trong túi và tay
	for _, tool in pairs(Player.Backpack:GetChildren()) do
		if tool.Name == Config.Name then tool:Destroy() end
	end
	if char then
		for _, tool in pairs(char:GetChildren()) do
			if tool.Name == Config.Name then tool:Destroy() end
		end
	end
	-- Khôi phục chuột mặc định phòng trường hợp đang cầm bom bị xóa
	if UserInputService.MouseEnabled then Mouse.Icon = "" end
	
	Config.CanUse = true -- Reset cooldown nếu bị kẹt
	GiveTool() -- Cấp lại 1 bom duy nhất
end)

Player.CharacterAdded:Connect(function() 
	task.wait(1) 
	GiveTool() 
end)

GiveTool()
