local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local _Mouse = LocalPlayer:GetMouse()

local Interface = PlayerGui:WaitForChild("Interface")

local BuildingTools = Interface.BuildingTools
local Windows = Interface.Windows
local BuildingWindow = Windows.BuildingWindow

-- Services
local Builder = require(script.Parent.BuildingServices.BuildingService)
local Remover = require(script.Parent.BuildingServices.RemovingService)
local Connector = require(script.Parent.BuildingServices.ConnectingService)
local Multiselect = require(script.Parent.BuildingServices.MultiselectionService)

BuildingTools.MouseButton1Click:Connect(function()
    SoundService.Click:Play()
    BuildingWindow.Visible = not BuildingWindow.Visible
    if Remover.IsActive() then Remover.DestroyCurrentRemover() end
    if Connector.IsActive() then Connector.DestroyCurrent() end
    if Multiselect.IsActive() then Multiselect.DestroyCurrent() end

    if BuildingWindow.Visible == false then
        if Builder.IsActive() then Builder.DestroyCurrentBuilder() end
    end
end)

local _EditingMode = Interface.EditingMode

for index, child in BuildingWindow.ScrollingFrame:GetChildren() do 
    if child:IsA("ImageButton") then
        child.MouseButton1Click:Connect(function()
            SoundService.Click:Play()

            if Remover.IsActive() then Remover.DestroyCurrentRemover() end
            if Connector.IsActive() then Connector.DestroyCurrent() end
            if Multiselect.IsActive() then Multiselect.DestroyCurrent() end

            if Builder.IsActive() then
                if Builder.GetCurrentBuildingCircuitName() == child.Name:upper() then
                    Builder.DestroyCurrentBuilder()
                else
                    local _Builder = Builder.new(child.Name:upper())
                    Remover.DestroyCurrentRemover()
                end
            else
                local _Builder = Builder.new(child.Name:upper())
                Remover.DestroyCurrentRemover()
            end
        end)
    end
end

local Recycle = Interface.Recycle
local Connect = Interface.Connect
local MultiselectButton = Interface.Multiselect

Recycle.MouseButton1Click:Connect(function()
    if Connector.IsActive() then Connector.DestroyCurrent() end
    if Builder.IsActive() then Builder.DestroyCurrentBuilder() end
    if Multiselect.IsActive() then Multiselect.DestroyCurrent() end

    SoundService.Click:Play()
    if not Remover.IsActive() then
        local _newRemover = Remover.new()
    else
        Remover.DestroyCurrentRemover()
    end
end)

Connect.MouseButton1Click:Connect(function()
    if Remover.IsActive() then Remover.DestroyCurrentRemover() end
    if Builder.IsActive() then Builder.DestroyCurrentBuilder() end
    if Multiselect.IsActive() then Multiselect.DestroyCurrent() end

    SoundService.Click:Play()
    if not Connector.IsActive() then
        local _newConnector = Connector.new()
    else
        Connector.DestroyCurrent()
    end
end)

MultiselectButton.MouseButton1Click:Connect(function()
    if Connector.IsActive() then Connector.DestroyCurrent() end
    if Builder.IsActive() then Builder.DestroyCurrentBuilder() end
    if Remover.IsActive() then Remover.DestroyCurrentRemover() end

    SoundService.Click:Play()
    if not Multiselect.IsActive() then
        local _newMultiselect = Multiselect.new()
    else
        Multiselect.DestroyCurrent()
    end
end)

-- Interaction Service

local _InteractionService = require(script.Parent.RemoteServices.InteractionService)
_InteractionService.__init__()