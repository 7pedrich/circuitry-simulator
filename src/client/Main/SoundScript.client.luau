local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:WaitForChild("Remote")
local PlayLocalSound = Remote.PlayLocalSound

PlayLocalSound.OnClientEvent:Connect(function(soundName: string)
    if SoundService:FindFirstChild(soundName) == nil then
        warn(soundName .. " can't be found within SoundService")
    else
        local Sound = SoundService:FindFirstChild(soundName)
        Sound:Play()
    end
end)
