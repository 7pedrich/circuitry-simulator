local ButtonInformation = {}
ButtonInformation.__index = ButtonInformation

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer.PlayerGui
local Interface = PlayerGui:WaitForChild("Interface")

local ButtonInformationLabel : TextLabel = Interface.ButtonInformation

local _currentDesc = ""

function ButtonInformation.__init__()
    local self = setmetatable({}, ButtonInformation)

    self:add_connections()
end

function ButtonInformation:showInfo(button: TextButton)
    if not button:GetAttribute("ButtonDescription") then return end
    local ButtonDescription = button:GetAttribute("ButtonDescription")

    ButtonInformationLabel.Visible = true
    ButtonInformationLabel.Text = [[<mark color="#333333" transparency="0.1">]] .. ButtonDescription .. "</mark>"

    _currentDesc = ButtonDescription

    RunService:BindToRenderStep("ButtonInformationLabelLocationUpdate", Enum.RenderPriority.Camera.Value, function(...)
        self:update(...)
    end)
end

function ButtonInformation:hideInfo()
    ButtonInformationLabel.Visible = false
end

function ButtonInformation:add_connections()
    for _, Descendant : Instance in Interface:GetDescendants() do
        if Descendant:IsA("GuiButton") then
            Descendant.MouseEnter:Connect(function()
                self:showInfo(Descendant)
            end)

            Descendant.MouseLeave:Connect(function()
                self:hideInfo()
            end)
        end
    end
end

function ButtonInformation:update(delta: number)
    local MouseCoordinates : Vector2 = UserInputService:GetMouseLocation()

    ButtonInformationLabel.Position = UDim2.new(0, MouseCoordinates.X, 0, MouseCoordinates.Y) 
end

return ButtonInformation