local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")

local Config = {
	Name = "C4",
	Cooldown = 2,
	CanUse = true,
	CursorMode = nil -- Sẽ được chọn ở menu đầu tiên: "New" hoặc "Old"
}

local CurrentDroppedBomb = nil
local renderConnection = nil

-- ROBLOX BUILT-IN GUN CURSORS
local GUN_CURSOR = "rbxasset://textures/GunCursor.png"
local RELOAD_CURSOR = "rbxasset://textures/GunWaitCursor.png"

-- HÀM TẠO MÔ HÌNH BOMB SỬ DỤNG GEAR ID CHÍNH HÃNG (104642566)
local function BuildC4()
	local ToolModel = Instance.new("Model")
	ToolModel.Name = "Handle"

	-- Part chính để xử lý vật lý và va chạm
	local Main = Instance.new("Part")
	Main.Name = "PrimaryPart"
	Main.Size = Vector3.new(2, 0.8, 1.5)
	Main.Transparency = 1 -- Ẩn part gốc, để hiện Mesh thực tế
	Main.CanCollide = true
	Main.Parent = ToolModel
	ToolModel.PrimaryPart = Main

	-- Chèn Mesh của Fake C4 (ID: 104642566)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshId = "rbxassetid://104642566"
	Mesh.TextureId = "rbxassetid://104642537"
	Mesh.Scale = Vector3.new(1, 1, 1)
	Mesh.Parent = Main

	return ToolModel
end

-- HÀM SẮP XẾP TÚI ĐỒ (GIỮ BOMB TỪ SLOT 2 TRỞ ĐI)
local function OrganizeBackpack()
	local char = Player.Character
	if not char then return end

	local allTools = {}
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end
	for _, obj in pairs(Player.Backpack:GetChildren()) do
		if obj:IsA("Tool") then table.insert(allTools, obj) end
	end

	local bombs = {}
	local others = {}

	for _, tool in pairs(allTools) do
		if tool.Name == Config.Name then
			table.insert(bombs, tool)
		else
			table.insert(others, tool)
		end
		tool.Parent = nil
	end

	if #others > 0 then
		others[1].Parent = Player.Backpack
	end

	for _, bomb in pairs(bombs) do
		bomb.Parent = Player.Backpack
	end

	for i = 2, #others do
		others[i].Parent = Player.Backpack
	end
end

-- TẠO GIAO DIỆN CHỌN CHẾ ĐỘ CON TRỎ (HIỆN LẦN ĐẦU KHI CHẠY SCRIPT)
local startupGui = Instance.new("ScreenGui", PlayerGui)
startupGui.Name = "C4_StartupChoice"
startupGui.ResetOnSpawn = false

local choiceFrame = Instance.new("Frame", startupGui)
choiceFrame.Size = UDim2.new(0, 320, 0, 180)
choiceFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
choiceFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
choiceFrame.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", choiceFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "CHỌN KIỂU CON TRỎ (CURSOR)"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BackgroundTransparency = 1

local btnNew = Instance.new("TextButton", choiceFrame)
btnNew.Size = UDim2.new(0.8, 0, 0, 45)
btnNew.Position = UDim2.new(0.1, 0, 0.3, 0)
btnNew.Text = "Kiểu Mới (Theo sát con trỏ + Text)"
btnNew.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
btnNew.TextColor3 = Color3.fromRGB(255, 255, 255)
btnNew.Font = Enum.Font.SourceSansBold
btnNew.TextSize = 14

local btnOld = Instance.new("TextButton", choiceFrame)
btnOld.Size = UDim2.new(0.8, 0, 0, 45)
btnOld.Position = UDim2.new(0.1, 0, 0.65, 0)
btnOld.Text = "Kiểu Cũ (Gun Cursor mặc định)"
btnOld.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnOld.TextColor3 = Color3.fromRGB(255, 255, 255)
btnOld.Font = Enum.Font.SourceSansBold
btnOld.TextSize = 14

-- TẠO GIAO DIỆN CON TRỎ MỚI (NẾU CHỌN KIỂU MỚI)
local customCursorGui = Instance.new("ScreenGui", PlayerGui)
customCursorGui.Name = "C4_CustomCursor"
customCursorGui.ResetOnSpawn = false
customCursorGui.Enabled = false

local cursorTextLabel = Instance.new("TextLabel", customCursorGui)
cursorTextLabel.Size = UDim2.new(0, 100, 0, 25)
cursorTextLabel.BackgroundTransparency = 1
cursorTextLabel.Text = "Fake C4"
cursorTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cursorTextLabel.TextScaled = true
cursorTextLabel.Font = Enum.Font.SourceSansBold
local stroke = Instance.new("UIStroke", cursorTextLabel)
stroke.Thickness = 1.5

-- KHỞI TẠO MENU CHÍNH (ẨN ĐẾN KHI CHỌN XONG SETUP)
local sg = Instance.new("ScreenGui", PlayerGui)
sg.Name = "C4_Final_Menu"
sg.ResetOnSpawn = false
sg.Enabled = false

local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0, 60, 0, 40)
toggle.Position = UDim2.new(0, 10, 0.5, 0)
toggle.Text = "MENU"
toggle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
toggle.Draggable = true

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 180, 0, 200)
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

-- HÀM TẠO TOOL C4 CHÍNH THỨC
local function GiveTool()
	local Tool = Instance.new("Tool")
	Tool.Name = Config.Name
	Tool.RequiresHandle = true
	Tool.CanBeDropped = false
	Tool.Grip = CFrame.new(0, -0.2, 0.2) * CFrame.Angles(0, math.rad(180), 0)
	
	local c4Model = BuildC4()
	c4Model.Parent = Tool
	
	Tool.Equipped:Connect(function()
		if UserInputService.MouseEnabled then
			if Config.CursorMode == "New" then
				UserInputService.MouseIconEnabled = false
				customCursorGui.Enabled = true
				cursorTextLabel.Text = Config.Name
				if renderConnection then renderConnection:Disconnect() end
				renderConnection = RunService.RenderStepped:Connect(function()
					local mPos = UserInputService:GetMouseLocation()
					cursorTextLabel.Position = UDim2.new(0, mPos.X - 50, 0, mPos.Y + 18)
				end)
			else
				Mouse.Icon = GUN_CURSOR
			end
		end
	end)
	
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
		
		if CurrentDroppedBomb then CurrentDroppedBomb:Destroy() end
		
		local d_model = BuildC4()
		d_model.PrimaryPart.CFrame = hrp.CFrame * CFrame.new(0, -3.2, 0)
		d_model.Parent = game.Workspace
		
		game.Debris:AddItem(d_model, 22)

		local bv = Instance.new("BodyVelocity", d_model.PrimaryPart)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = ((Mouse.Hit.p - hrp.Position).Unit * 25) + Vector3.new(0, 10, 0)
		
		game.Debris:AddItem(bv, 0.1)
		
		-- Ẩn model trên tay
		local originalTrans = {}
		for _, desc in pairs(Tool:GetDescendants()) do
			if desc:IsA("BasePart") then
				originalTrans[desc] = desc.Transparency
				desc.Transparency = 1
			end
		end
		
		task.wait(Config.Cooldown)
		
		for desc, trans in pairs(originalTrans) do
			if desc and desc.Parent then desc.Transparency = trans end
		end
		
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

-- XỬ LÝ SỰ KIỆN CHỌN CHẾ ĐỘ BAN ĐẦU
local function InitializeScript(mode)
	Config.CursorMode = mode
	startupGui:Destroy() -- Xóa bảng chọn
	sg.Enabled = true    -- Bật menu chính lên
	
	GiveTool()
	
	Player.CharacterAdded:Connect(function()
		task.wait(1)
		GiveTool()
	end)
end

btnNew.MouseButton1Click:Connect(function()
	InitializeScript("New")
end)

btnOld.MouseButton1Click:Connect(function()
	InitializeScript("Old")
end)

-- SỰ KIỆN MENU CHÍNH
toggle.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

btn.MouseButton1Click:Connect(function() 
	Config.Cooldown = tonumber(input.Text) or Config.Cooldown
	
	local newName = nameInput.Text
	if newName ~= "" and newName ~= Config.Name then
		local char = Player.Character
		for _, tool in pairs(Player.Backpack:GetChildren()) do
			if tool.Name == Config.Name then tool.Name = newName end
		end
		if char then
			for _, tool in pairs(char:GetChildren()) do
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
	for _, tool in pairs(Player.Backpack:GetChildren()) do
		if tool.Name == Config.Name then tool:Destroy() end
	end
	if char then
		for _, tool in pairs(char:GetChildren()) do
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
