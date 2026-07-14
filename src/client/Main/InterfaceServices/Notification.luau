local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = ReplicatedStorage.UI

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local NotificationTemplate = UI.Notification

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Interface = PlayerGui:WaitForChild("Interface")

local Notification = {}

local tweenInformation = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

function Notification.new(message: string, soundName: string?)
	local newNotif = NotificationTemplate:Clone()
	newNotif.Parent = Interface.NotificationScrollingFrame
	newNotif.Text = message

	if soundName then
		local sound = SoundService[soundName]
		sound:Play()
	end

	local sizeTween = TweenService:Create(newNotif, tweenInformation, { Size = UDim2.new(1, 0, 0.02, 0) })
	sizeTween:Play()

	sizeTween.Completed:Wait()

	task.wait(2.5)
	local TextTransparencyTween = TweenService:Create(newNotif, tweenInformation, { TextTransparency = 1 })
	TextTransparencyTween:Play()

	TextTransparencyTween.Completed:Once(function(a0: Enum.PlaybackState)
		newNotif:Destroy()
	end)
end

return Notification
