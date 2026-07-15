--!nocheck
-- Datamodel Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Deps
local Remote = ReplicatedStorage.Remote

local Shared = ReplicatedStorage.Shared

-- Util
local Utils = Shared.Utils
local WorldUtil = require(Utils.WorldUtil)

-- Remote
local _TryInteraction = Remote.TryInteraction
local _SendNotification = Remote.SendNotification
local _PlayLocalSound = Remote.PlayLocalSound

_TryInteraction.OnServerInvoke = function(player: Player, toInteract: Model)
	local circuitType = toInteract.Name

	local character = player.Character
	local hrpPos = character.PrimaryPart.Position

	local circuitPos = toInteract.PrimaryPart.Position
	local distance = WorldUtil.Distance(hrpPos, circuitPos)

	if distance > 15 then
		_SendNotification:FireClient(player, "You're not close enough to the circuit.", "Error")
		return false
	end

	-- Handle interaction
	if circuitType == "FLIP_FLOP" then
		local switch = toInteract.Switch

		local sentSignal = not switch:GetAttribute("Toggle")
		switch:SetAttribute("Toggle", sentSignal)

		_PlayLocalSound:FireClient(player, "Toggle")
	end

	return true
end
