--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Circuitry = ReplicatedStorage.Circuitry

local Shared = ReplicatedStorage.Shared
local Services = Shared.Services

local CircuitService = require(Services.CircuitService).new()

-- Dependencies
local ServerScriptService = game:GetService("ServerScriptService")
local ServerServices = ServerScriptService.Server.ServerServices

local Connect = require(ServerServices.Connect)

local BuiltCircuitry = workspace.BuiltCircuitry

-- Serialization Service
-- // Probably one of the hardest scripts I'll ever make in my life

local Serializer = {}
Serializer.__index = Serializer

export type SerializedCircuitry = {
	Circuits: {
		[number]: SerializedCircuit,
	},
	Wires: { SerializedWire },
}

export type SerializedCircuit = {
	_type: string,
	_position: Vector3,
	_pins: {
		[number]: boolean, --> idx 3 means output .. (no logic gate with 3 inputs exist)
	}?,
	_rotational_angle: number,
	_uniqueId: string,
}

export type SerializedWire = {
	elementAindex: number,
	elementBindex: number,
	pinAindex: number, --> elementA[pins][pinAindex]
	pinBindex: number, --> elementB[pins][pinBindex] or 1
}

function Serializer.new()
	local self = setmetatable({}, Serializer)

	return self
end

function Serializer:SerializeVector3(Vec3: Vector3)
	return {
		X = Vec3.X,
		Y = Vec3.Y,
		Z = Vec3.Z,
	}
end

function Serializer:getCircuitIndexFromUniqueId(needle: string, haystack: { [number]: SerializedCircuit })
	for circuitIndex, circuit in haystack do
		if circuit._uniqueId == needle then
			return circuitIndex
		end
	end

	return nil
end

function Serializer:getCircuitFromUniqueId(needle: string): Model
	local haystack = BuiltCircuitry

	for _, circuitModel: Model in haystack:GetChildren() do
		if circuitModel:GetAttribute("UniqueId") == needle then
			return circuitModel
		end
	end

	return nil
end

function Serializer:Serialize(Circuitry: Folder): SerializedCircuitry
	local Circuits = Circuitry:GetChildren()
	local SerializedCircuitry: SerializedCircuitry = {
		Circuits = {},
		Wires = {},
	}

	for CircuitIndex, CircuitModel in Circuits do
		local PrimaryPart = CircuitModel.PrimaryPart
		local circuitPins = {}

		-- Set up the pins
		if CircuitModel.Name ~= "FLIP_FLOP" then
			for _, Part in CircuitModel:GetChildren() do
				if Part.Name:find("Input") or Part.Name:find("Output") then
					circuitPins[#circuitPins + 1] = Part:GetAttribute("Toggle")
				end
			end
		else
			circuitPins[1] = CircuitModel.Switch:GetAttribute("Toggle")
		end

		SerializedCircuitry.Circuits[#SerializedCircuitry.Circuits + 1] = {
			_position = self:SerializeVector3(PrimaryPart.Position),
			_rotational_angle = math.floor(PrimaryPart.Orientation.Y),
			_pins = circuitPins,
			_type = CircuitModel.Name,
			_uniqueId = CircuitModel:GetAttribute("UniqueId"),
		}
	end

	-- Wire setup loop
	for CircuitIndex, CircuitModel in Circuits do
		for pinIndex, Pin: BasePart in CircuitModel:GetChildren() do
			if not Pin:IsA("BasePart") then
				continue
			end

			local connections = Pin:FindFirstChild("Connections")
			if not connections then
				continue
			end

			if CircuitModel.Name == "FLIP_FLOP" then
				for connectionIndex: number, connection: ObjectValue in connections:GetChildren() do
					local elementB = connection.Value
					local circuitB = elementB.Parent

					local elementAindex = CircuitIndex
					local elementBindex = self:getCircuitIndexFromUniqueId(
						circuitB:GetAttribute("UniqueId"),
						SerializedCircuitry.Circuits
					)

					local rawIndex, _ = elementB.Name:gsub("Input", "")
					local _pinBIndex = tonumber(rawIndex)

					table.insert(SerializedCircuitry.Wires, {
						elementAindex = elementAindex,
						elementBindex = elementBindex,
						pinAindex = pinIndex,
						pinBindex = _pinBIndex,
					})
				end
			end
		end
	end

	return SerializedCircuitry
end

function Serializer:Deserialize(serializedCircuitry: SerializedCircuitry)
	local BuiltCircuitry = workspace.BuiltCircuitry

	-- Element types
	local Circuits = serializedCircuitry.Circuits
	local Wires = serializedCircuitry.Wires

	-- Begin by circuits
	for CircuitIndex, CircuitInformation in Circuits do
		local _type = CircuitInformation._type
		local circuitModel: Model = Circuitry[_type]:Clone()

		local _pins = CircuitInformation._pins

		local targetCFrame =
			CFrame.new(CircuitInformation._position.X, CircuitInformation._position.Y, CircuitInformation._position.Z)
		local _rotation = CircuitInformation._rotational_angle

		if #_pins ~= 0 then
			if #_pins ~= 1 then
				for pinIndex, pinToggle in _pins do
					if pinIndex == 3 then
						circuitModel.Output:SetAttribute("Toggle", pinToggle)
					else
						circuitModel["Input" .. pinIndex]:SetAttribute("Toggle", pinToggle)
					end
				end
            else
                circuitModel.Switch:SetAttribute("Toggle", _pins[1])
			end
		end

		circuitModel:PivotTo(targetCFrame * CFrame.Angles(0, math.rad(_rotation), 0))
		circuitModel:SetAttribute("UniqueId", CircuitInformation._uniqueId)

		circuitModel.Parent = BuiltCircuitry

		CircuitService:setupCircuit(circuitModel)
	end

	-- Connect stuff up
	for _, Wire : SerializedWire in Wires do
		local elementAindex = Wire.elementAindex
		local elementBindex = Wire.elementBindex

		local pinAindex = Wire.pinAindex
		local pinBindex = Wire.pinBindex

		local elementA, elementB = Circuits[elementAindex], Circuits[elementBindex]
		local pinA, pinB

		elementA, elementB =
			self:getCircuitFromUniqueId(elementA._uniqueId), self:getCircuitFromUniqueId(elementB._uniqueId)

		if pinAindex == 3 then --> Pin is output
			pinA = elementA.Output
			pinB = elementB["Input" .. pinBindex] --> The receiving pin is always an input.
		elseif pinAindex == 1 then --> Pin is a signal-sending flipflop.
			pinA = elementA.Switch
			pinB = elementB["Input" .. pinBindex] --> The receiving pin is always an input.
		end

		Connect(pinA, pinB)
	end

	return true
end

return Serializer
