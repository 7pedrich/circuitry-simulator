local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage.Remote
local _TryInteraction = Remote.TryInteraction

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()

local InteractionService = {}
InteractionService.__index = InteractionService

-- Util func
local function getTargetModel(target: BasePart?)
    if not target then
        return nil
    end

    local model = target:FindFirstAncestorWhichIsA("Model")

    if model and model.Parent == workspace.BuiltCircuitry then
        return model
    end

    return nil
end

-- Class funcs

function InteractionService.__init__()
	local self = setmetatable({}, InteractionService)

	self.inputBegan = UserInputService.InputBegan:Connect(function(...)
		self:checkInput(...)
	end)

	return self
end

function InteractionService:checkInput(inputObject: InputObject, gameProcessedEvent: boolean)
	local _success, _errorMessage = pcall(function()
		local currentTarget = Mouse.Target
		local firstAncestor = getTargetModel(currentTarget)

		if inputObject.KeyCode == Enum.KeyCode.F and not gameProcessedEvent then
			if firstAncestor.Parent == workspace.BuiltCircuitry and firstAncestor:HasTag("Interactable") then
				local _success = _TryInteraction:InvokeServer(firstAncestor)
			end
		end
	end)
end

function InteractionService:stop()
	self.inputBegan:Disconnect()
end

return InteractionService
