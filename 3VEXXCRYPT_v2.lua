--[[
    3VEXXCRYPT v2
    Roblox Studio / propio juego
    Player ESP + Item ESP + FOV + Aim Assist + Modern UI

    Controles:
      RightShift = mostrar/ocultar menú
      F1 = Player ESP
      F2 = Item ESP
      F3 = Aim Assist
      RMB = mantener para usar Aim Assist
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    PlayerESP = true,
    ItemESP = true,
    AimAssist = false,
    HoldToAim = true,
    FOV = 160,
    Smoothness = 0.14,
    MaxDistance = 1500,
}

local esp = {}
local menuVisible = true
local aiming = false

--// Helpers
local function getRoot(model)
    return model and (model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart"))
end

local function distanceFromCamera(part)
    if not part then return 0 end
    return (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude
end

--// ESP
local function destroyESP(instance)
    local data = esp[instance]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    esp[instance] = nil
end

local function makeESP(instance, labelText, fillColor)
    if not instance or esp[instance] then return end
    local root = getRoot(instance)
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "3VEXXCRYPT_Highlight"
    highlight.Adornee = instance
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0.05
    highlight.FillColor = fillColor
    highlight.OutlineColor = fillColor
    highlight.Parent = instance

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "3VEXXCRYPT_Label"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(190, 44)
    billboard.StudsOffset = Vector3.new(0, 3.1, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = Config.MaxDistance
    billboard.Parent = PlayerGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.TextStrokeTransparency = 0.35
    text.TextColor3 = fillColor
    text.Text = labelText
    text.Parent = billboard

    esp[instance] = {
        highlight = highlight,
        billboard = billboard,
        text = text,
        root = root,
        color = fillColor,
        baseText = labelText,
    }
end

local function updateESPLabels()
    for instance, data in pairs(esp) do
        if not instance.Parent or not data.root.Parent then
            destroyESP(instance)
        else
            local d = math.floor(distanceFromCamera(data.root))
            data.text.Text = string.format("%s  •  %dm", data.baseText, d)
            data.highlight.Enabled =
                (data.color == Color3.fromRGB(255, 80, 95) and Config.PlayerESP)
                or (data.color == Color3.fromRGB(70, 255, 150) and Config.ItemESP)
        end
    end
end

local function refreshPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = getRoot(player.Character)
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and Config.PlayerESP then
                makeESP(
                    player.Character,
                    player.Name .. "  [" .. math.floor(hum.Health) .. " HP]",
                    Color3.fromRGB(255, 80, 95)
                )
            end
        end
    end
end

local itemWords = {
    item=true, loot=true, drop=true, crate=true,
    chest=true, coin=true, gem=true, pickup=true,
}

local function looksLikeItem(obj)
    local n = obj.Name:lower()
    for word in pairs(itemWords) do
        if n:find(word, 1, true) then return true end
    end
    return false
end

local function refreshItems()
    if not Config.ItemESP then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart"))
            and not obj:FindFirstChildOfClass("Humanoid")
            and looksLikeItem(obj) then
            if getRoot(obj) then
                makeESP(obj, obj.Name, Color3.fromRGB(70, 255, 150))
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        refreshPlayers()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then destroyESP(player.Character) end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if esp[obj] then destroyESP(obj) end
end)

--// FOV visual
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "3VEXXCRYPT_FOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.Parent = PlayerGui

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOV"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = Config.AimAssist
fovCircle.Parent = fovGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 2
fovStroke.Transparency = 0.15
fovStroke.Color = Color3.fromRGB(150, 100, 255)
fovStroke.Parent = fovCircle

local function updateFOV()
    fovCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
    fovCircle.Visible = Config.AimAssist
end

--// Aim assist: cámara, solo para el propio juego
local function closestTarget()
    local camera = workspace.CurrentCamera
    local mouse = UserInputService:GetMouseLocation()
    local bestRoot, bestDistance = nil, Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character:FindFirstChild("Head")
                or player.Character:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and root then
                local point, visible = camera:WorldToViewportPoint(root.Position)
                if visible and point.Z > 0 then
                    local d = (Vector2.new(point.X, point.Y) - mouse).Magnitude
                    if d < bestDistance then
                        bestDistance = d
                        bestRoot = root
                    end
                end
            end
        end
    end

    return bestRoot
end

local function aimStep()
    if not Config.AimAssist then return end
    if Config.HoldToAim and not aiming then return end

    local target = closestTarget()
    if not target then return end

    local camera = workspace.CurrentCamera
    local desired = CFrame.lookAt(camera.CFrame.Position, target.Position)
    camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(Config.Smoothness, 0.02, 1))
end

--// Modern UI
local gui = Instance.new("ScreenGui")
gui.Name = "3VEXXCRYPT"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(330, 390)
main.Position = UDim2.new(0, 28, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(17, 17, 23)
main.BackgroundTransparency = 0.04
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(125, 80, 220)
stroke.Thickness = 1.5
stroke.Transparency = 0.25
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -28, 0, 48)
title.Position = UDim2.fromOffset(14, 8)
title.BackgroundTransparency = 1
title.Text = "3VEXXCRYPT"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 25
title.TextColor3 = Color3.fromRGB(235, 225, 255)
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -28, 0, 22)
subtitle.Position = UDim2.fromOffset(14, 48)
subtitle.BackgroundTransparency = 1
subtitle.Text = "ESP  •  AIM ASSIST  •  STUDIO"
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(150, 145, 165)
subtitle.Parent = main

local function button(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -28, 0, 42)
    b.Position = UDim2.fromOffset(14, y)
    b.BackgroundColor3 = Color3.fromRGB(29, 28, 38)
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(230, 230, 240)
    b.Text = text
    b.Parent = main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = b

    return b
end

local playerBtn = button("PLAYER ESP     ON", 82)
local itemBtn = button("ITEM ESP       ON", 132)
local aimBtn = button("AIM ASSIST     OFF", 182)

local fovText = Instance.new("TextLabel")
fovText.Size = UDim2.new(1, -28, 0, 26)
fovText.Position = UDim2.fromOffset(14, 238)
fovText.BackgroundTransparency = 1
fovText.TextXAlignment = Enum.TextXAlignment.Left
fovText.Font = Enum.Font.GothamBold
fovText.TextSize = 13
fovText.TextColor3 = Color3.fromRGB(200, 195, 215)
fovText.Parent = main

local fovBox = Instance.new("TextBox")
fovBox.Size = UDim2.new(1, -28, 0, 38)
fovBox.Position = UDim2.fromOffset(14, 266)
fovBox.BackgroundColor3 = Color3.fromRGB(29, 28, 38)
fovBox.Text = tostring(Config.FOV)
fovBox.PlaceholderText = "FOV"
fovBox.ClearTextOnFocus = false
fovBox.Font = Enum.Font.GothamBold
fovBox.TextSize = 14
fovBox.TextColor3 = Color3.fromRGB(235, 230, 245)
fovBox.Parent = main

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 10)
fc.Parent = fovBox

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -28, 0, 45)
info.Position = UDim2.fromOffset(14, 315)
info.BackgroundTransparency = 1
info.Text = "RightShift: menú  •  RMB: aim\nF1/F2/F3: toggles"
info.TextXAlignment = Enum.TextXAlignment.Left
info.Font = Enum.Font.GothamMedium
info.TextSize = 11
info.TextColor3 = Color3.fromRGB(135, 130, 150)
info.Parent = main

playerBtn.MouseButton1Click:Connect(function()
    Config.PlayerESP = not Config.PlayerESP
    playerBtn.Text = "PLAYER ESP     " .. (Config.PlayerESP and "ON" or "OFF")
    if Config.PlayerESP then refreshPlayers() end
end)

itemBtn.MouseButton1Click:Connect(function()
    Config.ItemESP = not Config.ItemESP
    itemBtn.Text = "ITEM ESP       " .. (Config.ItemESP and "ON" or "OFF")
    if Config.ItemESP then refreshItems() end
end)

aimBtn.MouseButton1Click:Connect(function()
    Config.AimAssist = not Config.AimAssist
    aimBtn.Text = "AIM ASSIST     " .. (Config.AimAssist and "ON" or "OFF")
    updateFOV()
end)

fovBox.FocusLost:Connect(function()
    local value = tonumber(fovBox.Text)
    if value then
        Config.FOV = math.clamp(value, 40, 500)
    end
    fovBox.Text = tostring(Config.FOV)
    updateFOV()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        menuVisible = not menuVisible
        main.Visible = menuVisible
    elseif input.KeyCode == Enum.KeyCode.F1 then
        Config.PlayerESP = not Config.PlayerESP
        playerBtn.Text = "PLAYER ESP     " .. (Config.PlayerESP and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.ItemESP = not Config.ItemESP
        itemBtn.Text = "ITEM ESP       " .. (Config.ItemESP and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.AimAssist = not Config.AimAssist
        aimBtn.Text = "AIM ASSIST     " .. (Config.AimAssist and "ON" or "OFF")
        updateFOV()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

--// Loops ligeros para no escanear Workspace cada frame
task.spawn(function()
    while gui.Parent do
        refreshPlayers()
        refreshItems()
        updateESPLabels()
        task.wait(0.5)
    end
end)

RunService:BindToRenderStep(
    "3VEXXCRYPT_Aim",
    Enum.RenderPriority.Camera.Value + 1,
    aimStep
)

print("3VEXXCRYPT v2 cargado")
