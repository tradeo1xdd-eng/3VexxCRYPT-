--[[
    3VEXXCRYPT
    Player ESP + Item ESP + Aim Assist
    Para Roblox Studio / tu propio juego
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_ENABLED = true
local ITEM_ESP_ENABLED = true
local AIM_ENABLED = false

local AIM_FOV = 150
local AIM_SMOOTHNESS = 0.12

local espObjects = {}

local function addESP(object, text, color)
    if espObjects[object] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "3VEXXCRYPT_ESP"
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "3VEXXCRYPT_Info"
    billboard.Size = UDim2.fromOffset(180, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.Parent = billboard

    espObjects[object] = {
        highlight = highlight,
        billboard = billboard
    }
end

local function removeESP(object)
    local data = espObjects[object]
    if not data then return end

    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end

    espObjects[object] = nil
end

local function updatePlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character

            if character and character:FindFirstChild("HumanoidRootPart") then
                if ESP_ENABLED then
                    addESP(character, player.Name, Color3.fromRGB(255, 80, 80))
                else
                    removeESP(character)
                end
            end
        end
    end
end

local function updateItems()
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") or object:IsA("Model") then
            local isCharacter = object:FindFirstChildOfClass("Humanoid") ~= nil

            if not isCharacter and ITEM_ESP_ENABLED then
                local name = object.Name:lower()

                if name:find("item")
                    or name:find("loot")
                    or name:find("drop")
                    or name:find("crate")
                    or name:find("chest")
                    or name:find("coin") then

                    addESP(object, object.Name, Color3.fromRGB(80, 255, 120))
                end
            end
        end
    end
end

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AIM_FOV
    local mousePosition = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and root then
                local screenPosition, visible =
                    Camera:WorldToViewportPoint(root.Position)

                if visible then
                    local distance = (
                        Vector2.new(screenPosition.X, screenPosition.Y)
                        - mousePosition
                    ).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = root
                    end
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    updatePlayers()
    updateItems()

    if AIM_ENABLED then
        local target = getClosestPlayer()

        if target then
            local cameraPosition = Camera.CFrame.Position
            local targetCFrame = CFrame.lookAt(
                cameraPosition,
                target.Position
            )

            Camera.CFrame = Camera.CFrame:Lerp(
                targetCFrame,
                AIM_SMOOTHNESS
            )
        end
    end
end)

-- 3VEXXCRYPT UI
local gui = Instance.new("ScreenGui")
gui.Name = "3VEXXCRYPT"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 220)
frame.Position = UDim2.new(0, 25, 0.5, -110)
frame.BackgroundTransparency = 0.08
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "3VEXXCRYPT"
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local function createButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -30, 0, 40)
    button.Position = UDim2.fromOffset(15, y)
    button.Text = text
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    return button
end

local playerButton = createButton("Player ESP: ON", 55)
playerButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    playerButton.Text = "Player ESP: " .. (ESP_ENABLED and "ON" or "OFF")
end)

local itemButton = createButton("Item ESP: ON", 105)
itemButton.MouseButton1Click:Connect(function()
    ITEM_ESP_ENABLED = not ITEM_ESP_ENABLED
    itemButton.Text = "Item ESP: " .. (ITEM_ESP_ENABLED and "ON" or "OFF")
end)

local aimButton = createButton("Aim Assist: OFF", 155)
aimButton.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    aimButton.Text = "Aim Assist: " .. (AIM_ENABLED and "ON" or "OFF")
end)

print("3VEXXCRYPT cargado correctamente")
