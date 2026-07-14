local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Services = Shared.Services
local ServerServices = script.Parent.ServerServices

local CircuitService = require(Services.CircuitService).new()
local Connect = require(ServerServices.Connect)

local Remote = ReplicatedStorage:WaitForChild("Remote")

local SendNotification = Remote.SendNotification

local _TryPlace = Remote.TryPlace
local _TryRemoval = Remote.TryRemoval
local _TryBond = Remote.TryBond

local MAX_BUILDING_HEIGHT = 3

_TryRemoval.OnServerInvoke = function(player: Player, object)
	if object.Parent == workspace.Constraints then
		local wiredA, wiredB = object.wiredA.Value, object.wiredB.Value
		local connectionsA, connectionsB = wiredA.Connections, wiredB.Connections
		local connectionAB, connectionBA

		local signalBoolean = wiredA:GetAttribute("Toggle")

		for _, connection in connectionsA:GetChildren() do
			if connection.Value == wiredB then
				connectionAB = connection
				break
			end
		end

		for _, connection in connectionsB:GetChildren() do
			if connection.Value == wiredA then
				connectionBA = connection
				break
			end
		end
		if signalBoolean then
			wiredB:SetAttribute("Toggle", false)
		end

		connectionAB:Destroy()
		connectionBA:Destroy()

		object:Destroy()
	elseif object.Parent == workspace.BuiltCircuitry then
		for _, part in object:GetChildren() do
			if not part:FindFirstChild("Connections") then
				continue
			end

			for _, connectionAB in part.Connections:GetChildren() do
				local connectionBA = connectionAB.Value

				for _, connection in connectionBA.Connections:GetChildren() do
					if connection.Value == part then
						connection:Destroy()
					end
				end

				connectionAB:Destroy()
			end
		end

		object:Destroy()
	end
end

_TryBond.OnServerInvoke = function(player: Player, SelectedA, SelectedB)
	if not SelectedA or not SelectedB then
		SendNotification:FireClient(player, "Nonexistent part (?)", "Error")
		return false
	end

	local message = Connect(SelectedA, SelectedB)	

	if message then
		SendNotification:FireClient(player, message.message, "Click")
	end

	return message.success
end

_TryPlace.OnServerInvoke = function(player: Player, previewName: string, previewModelPivot: CFrame)
	local condition1 = previewModelPivot.Y <= MAX_BUILDING_HEIGHT

	if condition1 then
		local Circuitry = ReplicatedStorage.Circuitry
		local selectedCircuit = Circuitry[previewName]

		local newCircuit = selectedCircuit:Clone()

		newCircuit:PivotTo(previewModelPivot)
		newCircuit.Parent = workspace.BuiltCircuitry

		CircuitService:setupCircuit(newCircuit)
	else
		SendNotification:FireClient(player, "Reached height limit (3 studs)", "Error")
		return false
	end

	return condition1
end