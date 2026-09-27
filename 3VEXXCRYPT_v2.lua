--// GUI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "3VEXXCRYPT"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 680, 0, 440)
Main.Position = UDim2.new(0.5, -340, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(55, 55, 70)
Stroke.Thickness = 1
Stroke.Parent = Main

--// TOP BAR

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 55)
Top.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
Top.BorderSizePixel = 0
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "3VEXXCRYPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 100, 0, 20)
Status.Position = UDim2.new(1, -145, 0, 18)
Status.BackgroundTransparency = 1
Status.Text = "● ONLINE"
Status.TextColor3 = Color3.fromRGB(90, 255, 140)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 11
Status.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -43, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 22
Close.Parent = Top

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

--// SIDEBAR

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 165, 1, -55)
Sidebar.Position = UDim2.new(0, 0, 0, 55)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.Parent = Sidebar

--// CONTENT

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -165, 1, -55)
Content.Position = UDim2.new(0, 165, 0, 55)
Content.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
Content.BorderSizePixel = 0
Content.Parent = Main

local Pages = {}

local function CreatePage(name)
	local Page = Instance.new("ScrollingFrame")
	Page.Name = name
	Page.Size = UDim2.new(1, -25, 1, -25)
	Page.Position = UDim2.new(0, 12, 0, 12)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 3
	Page.Visible = false
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.Parent = Content

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 10)
	Layout.Parent = Page

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
	end)

	Pages[name] = Page
	return Page
end

local function CreateTab(name, icon)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -18, 0, 38)
	Button.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	Button.Text = icon .. "  " .. name
	Button.TextColor3 = Color3.fromRGB(190, 190, 200)
	Button.Font = Enum.Font.GothamMedium
	Button.TextSize = 13
	Button.BorderSizePixel = 0
	Button.Parent = Sidebar

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

	Button.MouseButton1Click:Connect(function()
		for _, Page in pairs(Pages) do
			Page.Visible = false
		end

		Pages[name].Visible = true

		for _, Obj in ipairs(Sidebar:GetChildren()) do
			if Obj:IsA("TextButton") then
				Obj.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
				Obj.TextColor3 = Color3.fromRGB(190, 190, 200)
			end
		end

		Button.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	return Button
end

local function AddSection(Page, Text)
	local Section = Instance.new("TextLabel")
	Section.Size = UDim2.new(1, -5, 0, 28)
	Section.BackgroundTransparency = 1
	Section.Text = Text
	Section.TextColor3 = Color3.fromRGB(130, 130, 150)
	Section.Font = Enum.Font.GothamBold
	Section.TextSize = 12
	Section.TextXAlignment = Enum.TextXAlignment.Left
	Section.Parent = Page
end

local function AddButton(Page, Text, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 40)
	Button.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
	Button.Text = Text
	Button.TextColor3 = Color3.fromRGB(235, 235, 240)
	Button.Font = Enum.Font.GothamMedium
	Button.TextSize = 13
	Button.BorderSizePixel = 0
	Button.Parent = Page

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

	Button.MouseButton1Click:Connect(Callback)

	return Button
end

local function AddToggle(Page, Text, Default, Callback)
	local Enabled = Default

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 40)
	Button.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
	Button.Text = ""
	Button.BorderSizePixel = 0
	Button.Parent = Page

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -65, 1, 0)
	Label.Position = UDim2.new(0, 13, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(235, 235, 240)
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 38, 0, 20)
	Indicator.Position = UDim2.new(1, -50, 0.5, -10)
	Indicator.BorderSizePixel = 0
	Indicator.Parent = Button

	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

	local function Update()
		if Enabled then
			Indicator.BackgroundColor3 = Color3.fromRGB(90, 210, 130)
		else
			Indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		end

		Callback(Enabled)
	end

	Button.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		Update()
	end)

	Update()

	return Button
end

local function AddValue(Page, Text, Value)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 40)
	Button.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
	Button.Text = Text .. "    " .. tostring(Value)
	Button.TextColor3 = Color3.fromRGB(235, 235, 240)
	Button.Font = Enum.Font.GothamMedium
	Button.TextSize = 13
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.BorderSizePixel = 0
	Button.Parent = Page

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

	return Button
end

--// PAGES

local General = CreatePage("General")
local Combat = CreatePage("Combat")
local ESP = CreatePage("ESP")
local Visualize = CreatePage("Visualize")
local Movement = CreatePage("Movement")
local Health = CreatePage("Health")
local Server = CreatePage("Server")
local Misc = CreatePage("Misc")

--// TABS

local GeneralTab = CreateTab("General", "🏠")
CreateTab("Combat", "🎯")
CreateTab("ESP", "👁️")
CreateTab("Visualize", "🎨")
CreateTab("Movement", "🏃")
CreateTab("Health", "❤️")
CreateTab("Server", "🌐")
CreateTab("Misc", "⚙️")

--// GENERAL

AddSection(General, "GENERAL")

AddToggle(General, "Interface", true, function(Value)
	Main.Visible = Value
end)

AddButton(General, "Close Menu", function()
	Main.Visible = false
end)

AddSection(General, "STATUS")

AddValue(General, "Menu", "3VEXXCRYPT")
AddValue(General, "Version", "Custom")
AddValue(General, "Status", "Online")

--// COMBAT

AddSection(Combat, "AIM SETTINGS")

AddToggle(Combat, "Aim Assist", Config.Enabled, function(Value)
	Config.Enabled = Value
end)

AddToggle(Combat, "Team Check", Config.TeamCheck, function(Value)
	Config.TeamCheck = Value
end)

AddToggle(Combat, "Visible Check", Config.VisibleCheck, function(Value)
	Config.VisibleCheck = Value
end)

AddValue(Combat, "FOV", Config.FOV)
AddValue(Combat, "Strength", math.floor(Config.Strength * 100) .. "%")
AddValue(Combat, "Target Part", Config.TargetPart)

--// ESP

AddSection(ESP, "PLAYER ESP")

AddToggle(ESP, "Player ESP", Config.ESPEnabled, function(Value)
	Config.ESPEnabled = Value
end)

AddToggle(ESP, "Names", Config.ESPNames, function(Value)
	Config.ESPNames = Value
end)

AddToggle(ESP, "Distance", Config.ESPDistance, function(Value)
	Config.ESPDistance = Value
end)

--// VISUALIZE

AddSection(Visualize, "FOV")

AddToggle(Visualize, "Show FOV", Config.ShowFOV, function(Value)
	Config.ShowFOV = Value
end)

AddValue(Visualize, "FOV Size", Config.FOV)

--// MOVEMENT

AddSection(Movement, "MOVEMENT")

AddValue(Movement, "Movement", "Game controlled")
AddValue(Movement, "Controls", "Default")

--// HEALTH

AddSection(Health, "HEALTH")

AddValue(Health, "Health System", "Game controlled")
AddValue(Health, "Status", "Normal")

--// SERVER

AddSection(Server, "SERVER")

AddValue(Server, "Players", #Players:GetPlayers())

AddButton(Server, "Refresh Player Count", function()
	-- Actualiza la información al volver a abrir la pestaña.
end)

--// MISC

AddSection(Misc, "MISC")

AddButton(Misc, "Rejoin", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

AddButton(Misc, "Reset Character", function()
	if LocalPlayer.Character then
		local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid.Health = 0
		end
	end
end)

AddSection(Misc, "INFORMATION")

AddValue(Misc, "Interface", "3VEXXCRYPT")
AddValue(Misc, "Theme", "Dark")
AddValue(Misc, "Layout", "Freddy / Hermanos inspired")

--// DEFAULT TAB

General.Visible = true

for _, Obj in ipairs(Sidebar:GetChildren()) do
	if Obj:IsA("TextButton") then
		Obj.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	end
end

GeneralTab.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
GeneralTab.TextColor3 = Color3.fromRGB(255, 255, 255)

--// CLOSE

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--// DRAG

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position

		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(Input)
	if Dragging and (
		Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch
	) then

		local Delta = Input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)
