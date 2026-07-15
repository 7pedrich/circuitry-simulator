local GateLogic = require(script.GateLogic)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local CircuitService = {}
CircuitService.__index = CircuitService

local CurrentService = nil

function CircuitService.new()
    local self = setmetatable({}, CircuitService)

    if CurrentService then
        return CurrentService
    end

    self.currentCircuits = {}
    CurrentService = self

    RunService.Heartbeat:Connect(function(...)
        self:updateCircuitToggles(...)
    end)

    return self
end

function CircuitService:setupCircuit(circuitModel: Model)
    local circuitName = circuitModel.Name

    local newCircuitIndex = #self.currentCircuits + 1

    self.currentCircuits[newCircuitIndex] = {
        _type = circuitName,
        model = circuitModel
    }

    if not circuitModel:GetAttribute("UniqueId") then
        circuitModel:SetAttribute("UniqueId", HttpService:GenerateGUID(false))
    end

    circuitModel.Destroying:Connect(function()
        self.currentCircuits[newCircuitIndex] = nil
    end)
end

function CircuitService:stop()
    RunService:UnbindFromRenderStep("CIRCUIT_SERVICE")
end

function CircuitService:updateCircuitToggles(delta: number)
    for _, circuitInformation in self.currentCircuits do
        local booleanCheckFunction = GateLogic[circuitInformation._type]

        -- Load up outputs for logic gates IRT
        if circuitInformation._type == "AND"
            or circuitInformation._type == "NAND"
            or circuitInformation._type == "OR"
            or circuitInformation._type == "XOR"
            or circuitInformation._type == "NOR"
         then
            local _input1, _input2, _output
            local model = circuitInformation.model

            _input1, _input2, _output = model.Input1, model.Input2, model.Output

            local input1C, input2C = _input1.Connections, _input2.Connections

            if #input1C:GetChildren() == 0 then
                _input1:SetAttribute("Toggle", false)
            else
                for _, connection in input1C:GetChildren() do
                    local connected = connection.Value
                    if connected:GetAttribute("Toggle") == true then
                        _input1:SetAttribute("Toggle", true)
                        break
                    end
                end
            end

            if #input2C:GetChildren() == 0 then
                _input2:SetAttribute("Toggle", false)
            else
                for _, connection in input2C:GetChildren() do
                    local connected = connection.Value
                    if connected:GetAttribute("Toggle") == true then
                        _input2:SetAttribute("Toggle", true)
                        break
                    end
                end
            end

            _input1, _input2 = _input1:GetAttribute("Toggle"), _input2:GetAttribute("Toggle")

            local outputResult = booleanCheckFunction(_input1, _input2)

            _output:SetAttribute("Toggle", outputResult)
            _output.BrickColor = (if outputResult then BrickColor.White() else BrickColor.Black())

            model.Input1.BrickColor = if _input1 then BrickColor.White() else BrickColor.Black()
            model.Input2.BrickColor = if _input2 then BrickColor.White() else BrickColor.Black()
        elseif circuitInformation._type == "NOT" then
            local _input1, _output
            local model = circuitInformation.model

            _input1, _output = model.Input1, model.Output
            local input1C = _input1.Connections

            if #input1C:GetChildren() == 0 then
                _input1:SetAttribute("Toggle", false)
            else
                for _, connection in input1C:GetChildren() do
                    local connected = connection.Value
                    if connected:GetAttribute("Toggle") == true then
                        _input1:SetAttribute("Toggle", true)
                        break
                    end
                end
            end

            _input1 = _input1:GetAttribute("Toggle")

            local outputResult = booleanCheckFunction(_input1)

            _output:SetAttribute("Toggle", outputResult)
            _output.BrickColor = (if outputResult then BrickColor.White() else BrickColor.Black())

            model.Input1.BrickColor = if _input1 then BrickColor.White() else BrickColor.Black()
        elseif circuitInformation._type == "LED" then
            local _input1, _light
            local model = circuitInformation.model

            _input1, _light = model.Input1, model.Light
            local newAttributeValue = _input1:GetAttribute("Toggle")

            if #_input1.Connections:GetChildren() == 0 then
                _input1:SetAttribute("Toggle", false)
            end

            if newAttributeValue == true then
                _light.BrickColor = BrickColor.White()
            else
                 _light.BrickColor = BrickColor.Black()
            end
        elseif circuitInformation._type == "FLIP_FLOP" then
            local model = circuitInformation.model
            local switch = model.Switch

            local updateToggleIcon = function()
                local currentSwitchAttribute = switch:GetAttribute("Toggle")

                if currentSwitchAttribute then
                    local surfaceGui = switch.SurfaceGui
                    local icon = surfaceGui.Icon

                    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                else
                    local surfaceGui = switch.SurfaceGui
                    local icon = surfaceGui.Icon

                    icon.ImageColor3 = Color3.fromRGB(100, 100, 100)
                end
            end

            updateToggleIcon()
        end
    end
end

return CircuitService