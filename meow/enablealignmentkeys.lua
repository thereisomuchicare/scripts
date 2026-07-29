local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- 1. Disable the Emotes Menu to free up the keys
local success, errorMessage = pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

if not success then
    warn("Failed to disable Emotes Menu: " .. tostring(errorMessage))
end

-- 2. Reactivate Camera Alignment Keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Ignore the input if the player is typing in chat or interacting with another UI element
    if gameProcessed then return end 
    
    local camera = Workspace.CurrentCamera
    if not camera then return end

    -- Comma (,) key pans the camera left
    if input.KeyCode == Enum.KeyCode.Comma then
        camera:PanUnits(-1)
        
    -- Period (.) key pans the camera right
    elseif input.KeyCode == Enum.KeyCode.Period then
        camera:PanUnits(1)
    end
end)
