local Constraint = {}
Constraint.__index = Constraint

function Constraint.new(partA: BasePart, partB: BasePart, color: Color3?)
	if not partA or not partB then return end

	local wire = Instance.new("Part")
	wire.Name = "Wire"
	wire.Material = Enum.Material.SmoothPlastic
	wire.Color = Color3.fromRGB(248, 248, 248) or color
	wire.Anchored = true
	wire.CanCollide = false
	wire.CanTouch = false
	wire.CanQuery = true
	
	local posA = partA.Position
	local posB = partB.Position
	local distance = (posA - posB).Magnitude
	local midpoint = (posA + posB) / 2

	wire.Size = Vector3.new(0.2, 0.2, distance)
	wire.CFrame = CFrame.lookAt(midpoint, posB)
	
	wire.Parent = workspace:WaitForChild("Constraints")

    local wiredObjectA = Instance.new("ObjectValue", wire)
    local wiredObjectB = Instance.new("ObjectValue", wire)

    wiredObjectA.Name = "wiredA"
    wiredObjectB.Name = "wiredB"
    wiredObjectA.Value = partA
    wiredObjectB.Value = partB

	partA.Destroying:Once(function()
		if wire then wire:Destroy() end
	end)

	partB.Destroying:Once(function()
		if wire then wire:Destroy() end
	end)

	return wire
end

return Constraint