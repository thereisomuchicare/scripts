local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local timeStanding = 0
local STAND_TIME_THRESHOLD = 5

RunService.Heartbeat:Connect(function(deltaTime)
	-- Don't execute if the player's character is dead
	if humanoid.Health <= 0 then return end

	-- Get the character's velocity, ignoring the Y axis (so falling doesn't count as moving)
	local velocity = rootPart.AssemblyLinearVelocity
	local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

	-- If the speed is near zero, the player is standing still
	if horizontalSpeed < 0.1 then
		timeStanding += deltaTime
		
		if timeStanding >= STAND_TIME_THRESHOLD then
			humanoid.Jump = true
			timeStanding = 0 -- Reset the timer after they jump
		end
	else
		-- The player is moving, reset the timer
		timeStanding = 0
	end
end)
