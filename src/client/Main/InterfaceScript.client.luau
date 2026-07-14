local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remote")

local SoundService = game:GetService("SoundService")

local ButtonInformation = require(script.Parent.InterfaceServices.ButtonInfo)
ButtonInformation.__init__()

Remote.SendNotification.OnClientEvent:Connect(function(message: string, soundName: string?)
	local InterfaceServices = script.Parent.InterfaceServices
	local Notification = require(InterfaceServices.Notification)

	Notification.new(message, (soundName or nil))
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui

local Interface = PlayerGui.Interface

local Windows = Interface.Windows
local BuildSettingsWindow = Windows.BuildSettingsWindow

local Settings = BuildSettingsWindow.Settings

local ToggleWindow = Interface.ToggleWindow

BuildSettingsWindow.GridSnapEnabled.SettingsValue.MouseButton1Click:Connect(function()
    SoundService.Click:Play()
    BuildSettingsWindow.GridSnapEnabled.SettingsValue.Text = if BuildSettingsWindow.GridSnapEnabled.SettingsValue.Text == "✔" then "❌" else "✔"
    BuildSettingsWindow.GridSnapEnabled.SettingsValue.BackgroundColor3 = if BuildSettingsWindow.GridSnapEnabled.SettingsValue.BackgroundColor3 == Color3.fromRGB(74, 127, 93) then
        Color3.fromRGB(127, 17, 17) else Color3.fromRGB(74, 127, 93)
end)

function UPDATE_BUILDING_SETTINGS(...)
	local RotationalAngle = Settings.RotationalAngle
	local GridSnap = Settings.GridSnap
	local SnapStudAmount = Settings.SnapStudAmount

    local RotationalAngleFrame = BuildSettingsWindow.RotationalAngle
    local GridSnapFrame = BuildSettingsWindow.GridSnapEnabled
    local SnapStudAmountFrame = BuildSettingsWindow.GridSnapStudAmount

    local RotationalAngleSetting = RotationalAngleFrame.SettingsValue.Text
    local GridSnapFrameSetting =  GridSnapFrame.SettingsValue.Text
    local SnapStudAmountSetting = SnapStudAmountFrame.SettingsValue.Text

    RotationalAngle.Value = tonumber(RotationalAngleSetting, 10) or RotationalAngle.Value
    SnapStudAmount.Value = tonumber(SnapStudAmountSetting, 10) or SnapStudAmount.Value

    GridSnap.Value = (if GridSnapFrameSetting == "✔" then true else false)
end

ToggleWindow.MouseButton1Click:Connect(function()
	ToggleWindow.Text = (if ToggleWindow.Text == ">" then "<" else ">")
	ToggleWindow.Position = (
		if ToggleWindow.Position == UDim2.new(0.249, 0, 0.473)
			then UDim2.new(0.072, 0, 0.473)
			else UDim2.new(0.249, 0, 0.473)
	)

	BuildSettingsWindow.Visible = not BuildSettingsWindow.Visible
	SoundService.Click:Play()
end)

RunService:BindToRenderStep("UPDATE_BUILDING_SETTINGS", Enum.RenderPriority.Camera.Value, function(...)
	UPDATE_BUILDING_SETTINGS(...)
end)
