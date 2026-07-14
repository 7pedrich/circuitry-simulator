local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PlayerMouse = LocalPlayer:GetMouse()

local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage.Remote

local _SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local Notification = require(StarterPlayer.StarterPlayerScripts.Client.Main.InterfaceServices.Notification)

local ConnectHighlightTemplate = ReplicatedStorage.VisualEffects.BondBox

local PlayerGui = LocalPlayer.PlayerGui
local Interface = PlayerGui.Interface

local Controls = Interface.Controls
local selectionAText, selectionBText = Controls.SelectionA, Controls.SelectionB

local EditingMode = Interface.EditingMode

-- Constructor

local Connector = {}
Connector.__index = Connector

local CurrentConnector = nil

local SelectedA = nil
local _SelectedB = nil

-- Util Func

-- Rem
local _TryBond = Remote.TryBond

function Connector.new()
	local self = setmetatable({}, Connector)

	self._highlightA = nil
	self._highlightB = nil
	self._canDeleteHighlightA = true
	self._canDeleteHighlightB = true

	if CurrentConnector then
		CurrentConnector:Destroy()
	end

	CurrentConnector = self
	EditingMode.Text = "Connecting Mode (LMB)"

	RunService:BindToRenderStep("CONNECTION_HIGHLIGHT", Enum.RenderPriority.Camera.Value, function(...)
		self:update(...)
	end)

	ContextActionService:BindAction("SELECT_ACTION", function(...)
		self:select(...)
	end, false, Enum.UserInputType.MouseButton1)

	return self
end

function Connector:select(_, state, _)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local mouseTarget = PlayerMouse.Target
	local type: "Input" | "Output" | "Flipflop" | "Invalid" = nil

	if not mouseTarget then return end

	if mouseTarget.Name:find("Input") then
		type = "Input"
	elseif mouseTarget.Name:find("Output") then
		type = "Output"
	elseif mouseTarget.Name:find("Switch") then
		type = "Flipflop"
	else
		type = "Invalid"
	end

	if type == "Invalid" then
		return Notification.new("Please only connect elements that are exclusively inputs/outputs/flip-flops.", "Error")
	end

	if not SelectedA then
		if type == "Input" then
			return Notification.new("Inputs can't send signals.")
		else
			self._canDeleteHighlightA = false
			SelectedA = mouseTarget
		end
	else
		if type == "Output" then
			return Notification.new("Outputs can't receive signals.")
		else
			--> Connect
			if type == "Input" then
				local Connections = mouseTarget.Connections
				if Connections:FindFirstChildWhichIsA("ObjectValue") then
					return Notification.new("Inputs can only receive one signal.")
				else
					SelectedB = mouseTarget
					self._canDeleteHighlightB = false

					local success = _TryBond:InvokeServer(SelectedA, SelectedB)

					if success then
						SelectedB = nil
						SelectedA = nil

						self._canDeleteHighlightA = true
						self._canDeleteHighlightB = true
					end
				end
			end
			if type == "Flipflop" then
				return Notification.new("Flipflops can't receive signals.")
			end
		end
	end

	return ""
end

function Connector:Destroy()
	RunService:UnbindFromRenderStep("CONNECTION_HIGHLIGHT")
	ContextActionService:UnbindAction("SELECT_ACTION")
	selectionBText.Text = "selectionB: *"
	selectionAText.Text = "selectionA: *"
	SelectedA = nil
	SelectedB = nil
	if self._highlightA then
		self._highlightA:Destroy()
	end
	if self._highlightB then
		self._highlightB:Destroy()
	end
	CurrentConnector = nil
	EditingMode.Text = ""
end

function Connector.DestroyCurrent()
	CurrentConnector:Destroy()
end

function Connector:update(delta: number)
	local Target = PlayerMouse.Target

	if not Target then
		return
	end

	if Target.Name:find("Input") or Target.Name:find("Output") or Target.Name:find("Switch") or Target.Parent:GetAttribute("UniqueId") then
		if not SelectedA then
			if not self._highlightA then
				self._highlightA = ConnectHighlightTemplate:Clone()
				self._highlightA.Parent = workspace
			end
			self._highlightA.Adornee = Target
		else
			if not self._highlightB then
				self._highlightB = ConnectHighlightTemplate:Clone()
				self._highlightB.Parent = workspace
			end
			self._highlightB.Adornee = Target
		end
	elseif self._highlightA then
		if self._canDeleteHighlightA then
			self._highlightA:Destroy()
			self._highlightA = nil
		end
	elseif self._highlightB then
		if self._canDeleteHighlightB then
			self._highlightB:Destroy()
			self._highlightB = nil
		end
	end

	if SelectedA then
		selectionAText.Text = "selectionA: " .. SelectedA.Parent.Name .. "[" .. SelectedA.Name .. "]"
	else
		selectionAText.Text = "selectionA: *"
	end

	if SelectedB then
		selectionBText.Text = "selectionB: " .. SelectedB.Parent.Name .. "[" .. SelectedB.Name .. "]"
	else
		selectionBText.Text = "selectionB: *"
	end
end

function Connector.IsActive()
	return (if CurrentConnector then true else false)
end

return Connector
