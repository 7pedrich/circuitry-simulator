local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local boxOutlineTemplate = ReplicatedStorage.VisualEffects.PreviewBox
local Circuitry = ReplicatedStorage:WaitForChild("Circuitry")

local Remote = ReplicatedStorage.Remote
local TryPlace: RemoteFunction = Remote:WaitForChild("TryPlace")

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local mouse = LocalPlayer:GetMouse()

local PlayerGui = LocalPlayer.PlayerGui
local Interface = PlayerGui.Interface

local EditingMode = Interface.EditingMode

local currentBuilder = nil
local currentBuildName = ""

local Windows = Interface.Windows
local _BuildSettingsWindow = Windows.BuildSettingsWindow

local Settings = Interface.Windows.BuildSettingsWindow.Settings

local RotationalAngle = Settings.RotationalAngle
local GridSnapEnabled = Settings.GridSnap
local SnapStudAmount = Settings.SnapStudAmount

-- constr
local Builder = {}
Builder.__index = Builder

-- const
local PLACE_ACTION = "Place"
local ROTATE_ACTION = "Rotate"

-- Grid snap stuff
local function snapToGrid(val, step)
	return math.floor(val / step + 0.5) * step
end


local function castMouse(excludeInstances: { Instance }?)
	local camera = workspace.CurrentCamera
	local mouseLocationVector2 = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouseLocationVector2.X, mouseLocationVector2.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excludeInstances or {}

	return workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
end

function Builder.new(circuitName: string)
	local self = setmetatable({}, Builder)
	local selectedCircuit = Circuitry[circuitName]

	EditingMode.Text = "Building Mode"

	if currentBuilder then
		currentBuilder:Destroy()
	end
	currentBuilder = self

	self.ROTATION = 0
	self._renderStepName = "BuilderPreview_" .. tostring(self)

	currentBuildName = circuitName

	self:start_preview(selectedCircuit)
	ContextActionService:BindAction(PLACE_ACTION, function(...)
		self:attempt_placement(...)
	end, false, Enum.UserInputType.MouseButton1)

	ContextActionService:BindAction(ROTATE_ACTION, function(...)
		self:rotate_preview_model(...)
	end, false, Enum.KeyCode.R)

	return self
end

function Builder:attempt_placement(_, state, _) --> CAS params
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local success = TryPlace:InvokeServer(self.Preview.Name, self.Preview:GetPivot())

	if not success then
		SoundService.Error:Play()
	else
		SoundService.Build:Play()
	end
end

function Builder:start_preview(circuit: Model)
	self:prepare_preview_model(circuit)

	RunService:BindToRenderStep(self._renderStepName, Enum.RenderPriority.Camera.Value, function(...)
		self:render_preview(...)
	end)
end

function Builder:render_preview(delta: number)
	local mouseCast = castMouse({ self.Preview })

	if mouseCast and mouseCast.Position then
		local unitRay = mouse.UnitRay
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { self.Preview }

		local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)

		if raycastResult then
			local preview : Model = self.Preview

			local snappedX, snappedZ
			local targetY = raycastResult.Position.Y
			local rot = CFrame.Angles(0, math.rad(self.ROTATION), 0)

			local newCF

			if GridSnapEnabled.Value == true then
				snappedX = snapToGrid(raycastResult.Position.X, SnapStudAmount.Value)
				snappedZ = snapToGrid(raycastResult.Position.Z, SnapStudAmount.Value)
			else
				snappedX = raycastResult.Position.X
				snappedZ = raycastResult.Position.Z
			end

			newCF = CFrame.new(snappedX, targetY + (self.Preview.PrimaryPart.Size.Y / 2), snappedZ) * rot

			preview:PivotTo(newCF)
		end
	end
end

function Builder:rotate_preview_model(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	self.ROTATION += RotationalAngle.Value
end

function Builder:prepare_preview_model(model: Model)
	if self.Preview then
		self.Preview:Destroy()
	end

	self.Preview = model:Clone()

	for _, part in self.Preview:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.Transparency = 0.5
			part.CanQuery = false
			part.Anchored = true

			local boxOutline = boxOutlineTemplate:Clone()
			boxOutline.Adornee = self.Preview
			boxOutline.Parent = part
		end
	end

	self.Preview.Parent = workspace
end

function Builder:Destroy()
	pcall(function()
		self.Preview:Destroy()
		self.Preview = nil
	end)

	if self._renderStepName then
		RunService:UnbindFromRenderStep(self._renderStepName)
	end

	ContextActionService:UnbindAction(PLACE_ACTION)
	ContextActionService:UnbindAction(ROTATE_ACTION)

	currentBuildName = ""
	EditingMode.Text = ""
end

function Builder.IsActive()
	return if currentBuilder then true else false
end

function Builder.DestroyCurrentBuilder()
	if currentBuilder then
		currentBuilder:Destroy()
	end
end

function Builder.GetCurrentBuildingCircuitName()
	return currentBuildName
end

function Builder.isPreviewing()
	return (currentBuilder.Preview ~= nil)
end

return Builder
