local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constraint = require(ReplicatedStorage.Shared.Services.ConstraintService.Constraint)

return function(SelectedA, SelectedB)
    local ConnectionsA = SelectedA.Connections
	local ConnectionsB = SelectedB.Connections

	-- Removed restriction
	--if SelectedA.Parent == SelectedB.Parent then
		--return {message = "That sounds a bit too irrational don't you think", success = true}
	--end

	-- check if the desired connection does not already exist.
	for _, connection : ObjectValue in ConnectionsA:GetChildren() do
		if connection.Value == SelectedB then
			return {message = "There is already an existing connection between those two elements.", success = false}
		end
	end

	local sentSignal = SelectedA:GetAttribute("Toggle")
	
	SelectedB:SetAttribute("Toggle", sentSignal)
	SelectedB.BrickColor = if sentSignal then BrickColor.White() else BrickColor.Black()

	local ConnectionAB = Instance.new("ObjectValue", ConnectionsA)
	local ConnectionBA = Instance.new("ObjectValue", ConnectionsB)

	ConnectionAB.Name, ConnectionBA.Name = HttpService:GenerateGUID(false), HttpService:GenerateGUID(false)
	ConnectionAB.Value, ConnectionBA.Value = SelectedB, SelectedA

	SelectedA.Destroying:Once(function()
		ConnectionBA:Destroy()
	end)

	SelectedB.Destroying:Once(function()
		ConnectionAB:Destroy()
	end)

	local Wire = Constraint.new(SelectedA, SelectedB)
	Wire:AddTag("Selectable")

	return {message = "Connected " .. SelectedA.Name .. " to " .. SelectedB.Parent.Name .. "'s " .. SelectedB.Name, success = true}
end