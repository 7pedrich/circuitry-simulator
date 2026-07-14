local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Remote = ReplicatedStorage.Remote
local TryRemoval = Remote.TryRemoval

-- constr
local RemovingService = {}
RemovingService.__index = RemovingService

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local EditingMode = Interface:WaitForChild("EditingMode")

local PlayerMouse = LocalPlayer:GetMouse()

local REMOVE_ACTION = "REMOVE_ACTION"
local RENDER_STEP_NAME = "RemovingService"

local CurrentRemover = nil

function RemovingService.new()
	if RemovingService.IsActive() then
		RemovingService.DestroyCurrentRemover()
	end

	local self = setmetatable({}, RemovingService)

	self._highlight = nil
	CurrentRemover = self

	EditingMode.Text = "Recycling Mode"

	RunService:BindToRenderStep(RENDER_STEP_NAME, Enum.RenderPriority.Camera.Value, function(...)
		self:update(...)
	end)

	ContextActionService:BindAction(REMOVE_ACTION, function(...)
		self:remove(...)
	end, false, Enum.UserInputType.MouseButton1)

	return self
end

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

function RemovingService:remove(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local Target = PlayerMouse.Target
	local model = getTargetModel(Target)

	if model then
        if model.Parent == workspace.BuiltCircuitry then
            TryRemoval:InvokeServer(model)
            SoundService.Recycle:Play()
        end
    else
        if Target.Parent == workspace.Constraints then
            TryRemoval:InvokeServer(Target)
            SoundService.Recycle:Play()
        end
    end
end

function RemovingService:update()
	local Target = PlayerMouse.Target
	local model = getTargetModel(Target)

	if model then
		if not self._highlight then
			self._highlight = ReplicatedStorage.VisualEffects.RemovalBox:Clone()
			self._highlight.Parent = workspace
		end
		self._highlight.Adornee = model
    elseif Target.Parent == workspace.Constraints then
        if not self._highlight then
			self._highlight = ReplicatedStorage.VisualEffects.RemovalBox:Clone()
			self._highlight.Parent = workspace
		end
		self._highlight.Adornee = Target
	elseif self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end
end

function RemovingService:Destroy()
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
	ContextActionService:UnbindAction(REMOVE_ACTION)

	if self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end

	EditingMode.Text = ""
	CurrentRemover = nil
end

function RemovingService.IsActive()
	return CurrentRemover ~= nil
end

function RemovingService.DestroyCurrentRemover()
	if CurrentRemover then
		CurrentRemover:Destroy()
	end
end

return RemovingService
