-- Service dependencies
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Util dep
local RaycastUtil = require(script.RaycastUtil)
local PointInRect = RaycastUtil.pointInRect

-- Variable
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Interface = PlayerGui:WaitForChild("Interface")

local Camera = workspace.CurrentCamera

local EditingMode = Interface.EditingMode

local Multiselect = {}
Multiselect.__index = Multiselect

local CurrentService = nil
local IsDragging = false
local toSetAnchorPoint = true

local _currentAnchorPoint = nil

local DragBox = Interface.MarqueeDrag

function Multiselect.new()
	local self = setmetatable({}, Multiselect)

    self.currentlySelected = {}
    self.selectionBoxes = {}

	CurrentService = self
	EditingMode.Text = "Multiselect Mode"

	RunService:BindToRenderStep("MARQUEE_TOOL_UPDATE", Enum.RenderPriority.Camera.Value, function(...)
		self:Update(...)
	end)

	return self
end

function Multiselect:Raycast2dBox3d()
	if not _currentAnchorPoint then
		return {}
	end

	local mouse = UserInputService:GetMouseLocation()
	local min = Vector2.new(math.min(_currentAnchorPoint.X, mouse.X), math.min(_currentAnchorPoint.Y, mouse.Y))
	local max = Vector2.new(math.max(_currentAnchorPoint.X, mouse.X), math.max(_currentAnchorPoint.Y, mouse.Y))

	local selected = {}

	for _, object in CollectionService:GetTagged("Selectable") do
		local position

		if object:IsA("Model") then
			local cf = object:GetPivot()
			position = cf.Position
		elseif object:IsA("BasePart") then
			position = object.Position
		else
			continue
		end

		local screenPos, visible = Camera:WorldToViewportPoint(position)

		if visible then
			local point = Vector2.new(screenPos.X, screenPos.Y)

			if PointInRect(point, min, max) then
				table.insert(selected, object)
			end
		end
	end

	return selected
end

function Multiselect:RedrawBox()
	local mouse = UserInputService:GetMouseLocation()

	if toSetAnchorPoint then
		toSetAnchorPoint = false
		_currentAnchorPoint = mouse
	end

	local minX = math.min(_currentAnchorPoint.X, mouse.X)
	local minY = math.min(_currentAnchorPoint.Y, mouse.Y)

	local width = math.abs(mouse.X - _currentAnchorPoint.X)
	local height = math.abs(mouse.Y - _currentAnchorPoint.Y)

	DragBox.Position = UDim2.fromOffset(minX, minY)
	DragBox.Size = UDim2.fromOffset(width, height)
end

function Multiselect:addHighlight(selected: {})
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local VisualEffects = ReplicatedStorage.VisualEffects

    for _, selectedObject in selected do
        local SelectionBox = VisualEffects.SelectionBox:Clone()

        if not selectedObject:FindFirstChildWhichIsA("SelectionBox") then
            SelectionBox.Parent = selectedObject
            SelectionBox.Adornee = selectedObject

            self.selectionBoxes[#self.selectionBoxes + 1] = SelectionBox
        end
    end
end

function Multiselect:removeHighlights()
    for _, selectionBox: SelectionBox in self.selectionBoxes do
        selectionBox:Destroy()
    end

    table.clear(self.selectionBoxes) -- prevent mem leaks
end

function Multiselect:Update(delta: number)
	IsDragging = (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
	DragBox.Visible = IsDragging

	if IsDragging then
		self:RedrawBox()
        local selected = self:Raycast2dBox3d()

        self:removeHighlights()
        self:addHighlight(selected)
        self.currentlySelected = selected
	else
		toSetAnchorPoint = true
		_currentAnchorPoint = nil
	end
end

function Multiselect:Destroy()
	RunService:UnbindFromRenderStep("MARQUEE_TOOL_UPDATE")
	CurrentService = nil

	EditingMode.Text = ""
end

function Multiselect.IsActive()
	return (CurrentService ~= nil)
end

function Multiselect.DestroyCurrent()
	CurrentService:Destroy()
end

return Multiselect
