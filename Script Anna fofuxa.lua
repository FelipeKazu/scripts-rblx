--Script feito pelo @felipe.kazu
--Anna, saudades 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")


for _, oldFolder in ipairs(workspace:GetChildren()) do
	if oldFolder.Name == "AnnaEffect_FinalOrbit" then
		oldFolder:Destroy()
	end
end


local function setupLighting()
	local bloom = Lighting:FindFirstChild("AnnaBloom") or Instance.new("BloomEffect")
	bloom.Name = "AnnaBloom"
	bloom.Intensity = 1.2
	bloom.Size = 25
	bloom.Parent = Lighting

	local cc = Lighting:FindFirstChild("AnnaCC") or Instance.new("ColorCorrectionEffect")
	cc.Name = "AnnaCC"
	cc.Saturation = 0.2
	cc.Parent = Lighting
end
setupLighting()


local folder = Instance.new("Folder")
folder.Name = "AnnaEffect_FinalOrbit"
folder.Parent = workspace

local heartAnchor = Instance.new("Part")
heartAnchor.Size = Vector3.new(1, 1, 1)
heartAnchor.Transparency = 1
heartAnchor.CanCollide = false
heartAnchor.Anchored = true
heartAnchor.Parent = folder


local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(6, 0, 3, 0) 
billboard.AlwaysOnTop = false 
billboard.MaxDistance = 100 
billboard.Parent = heartAnchor

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.BackgroundTransparency = 1
textLabel.Text = ""
textLabel.Font = Enum.Font.FredokaOne
textLabel.TextColor3 = Color3.fromRGB(255, 100, 200)
textLabel.TextScaled = true
textLabel.Parent = billboard

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 3
uiStroke.Color = Color3.new(1, 1, 1)
uiStroke.Parent = textLabel

task.spawn(function()
	local target = "Anna"
	while true do
		for i = 1, #target do
			textLabel.Text = string.sub(target, 1, i)
			task.wait(0.3)
		end
		task.wait(2)
		local t = TweenService:Create(uiStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Color = Color3.fromRGB(255, 182, 193)})
		t:Play()
		break
	end
end)


local heartParts = {}
local scale = 0.22 

for t = 0, math.pi * 2, 0.15 do
	local x = 16 * math.sin(t)^3
	local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
	
	local p = Instance.new("Part")
	p.Size = Vector3.new(0.3, 0.3, 0.3)
	p.Material = Enum.Material.Neon
	p.Shape = Enum.PartType.Ball
	p.CanCollide = false
	p.Anchored = true
	p.Color = (math.random() > 0.5) and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(255, 0, 0)
	p.Parent = folder
	
	table.insert(heartParts, {Part = p, Offset = Vector3.new(x * scale, y * scale, 0)})
end

--. Emissores Fumaça, Pétalas, Estrelas (LEMBRAR DESSA PORRA)
local function createEmitter(parent)
	local smoke = Instance.new("ParticleEmitter")
	smoke.Color = ColorSequence.new(Color3.fromRGB(255, 192, 203))
	smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	smoke.Size = NumberSequence.new(0.5, 1.8)
	smoke.Lifetime = NumberRange.new(0.8, 1.5)
	smoke.Rate = 12
	smoke.Speed = NumberRange.new(1, 2)
	smoke.Parent = parent

	local petals = Instance.new("ParticleEmitter")
	petals.Color = ColorSequence.new(Color3.fromRGB(220, 20, 60))
	petals.Size = NumberSequence.new(0.35)
	petals.Lifetime = NumberRange.new(2, 4)
	petals.Rate = 6
	petals.Speed = NumberRange.new(3, 6)
	petals.EmissionDirection = Enum.NormalId.Bottom
	petals.SpreadAngle = Vector2.new(30, 30)
	petals.Parent = parent
	
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxassetid://6071575923"
	stars.Color = ColorSequence.new(Color3.new(1, 1, 0.8))
	stars.Size = NumberSequence.new(0.15, 0.4)
	stars.Lifetime = NumberRange.new(0.5, 1.2)
	stars.Rate = 12
	stars.Parent = parent
end
createEmitter(heartAnchor)


local orbitPart = Instance.new("Part")
orbitPart.Size = Vector3.new(0.3, 0.3, 0.3)
orbitPart.Color = Color3.new(1, 1, 1)
orbitPart.Material = Enum.Material.Neon
orbitPart.CanCollide = false
orbitPart.Anchored = true
orbitPart.Parent = folder

local orbitTrail = Instance.new("Trail")
local attachment0 = Instance.new("Attachment", orbitPart)
attachment0.Position = Vector3.new(0, 0.15, 0)
local attachment1 = Instance.new("Attachment", orbitPart)
attachment1.Position = Vector3.new(0, -0.15, 0)
orbitTrail.Attachment0 = attachment0
orbitTrail.Attachment1 = attachment1
orbitTrail.Color = ColorSequence.new(Color3.new(1, 0.8, 0.9))
orbitTrail.Lifetime = 0.4
orbitTrail.Parent = orbitPart


local mainOrbitAngle = 0   
local minorOrbitAngle = 0  
local beatTime = 0
local radius = 7          
local rotationSpeed = 2   


local connection
connection = RunService.RenderStepped:Connect(function(dt)

	if not character or not character:IsDescendantOf(workspace) or not hrp or not hrp.Parent then
		folder:Destroy()
		connection:Disconnect()
		return
	end
	

	mainOrbitAngle = mainOrbitAngle + (dt * rotationSpeed)
	

	local offsetX = math.sin(mainOrbitAngle) * radius
	local offsetZ = math.cos(mainOrbitAngle) * radius
	local targetPos = hrp.Position + Vector3.new(offsetX, 1.5, offsetZ)
	
	heartAnchor.Position = targetPos
	
	
	beatTime = beatTime + dt * 4
	local beatScale = 1 + (math.sin(beatTime) * 0.15)
	if math.sin(beatTime) > 0.8 then beatScale = 1.2 end
	
	
	local baseCFrame = CFrame.new(targetPos, hrp.Position)
	
	
	for _, data in ipairs(heartParts) do
		local localOffset = data.Offset * beatScale
		data.Part.CFrame = baseCFrame * CFrame.new(localOffset.X, localOffset.Y, 0)
	end
	
	
	minorOrbitAngle = minorOrbitAngle + dt * 5
	local ox = math.sin(minorOrbitAngle) * 3
	local oy = math.cos(minorOrbitAngle) * 3
	local oz = math.sin(minorOrbitAngle) * 1.5
	orbitPart.Position = targetPos + Vector3.new(ox, oy, oz)
end)

--====================================================================
-- SEGUNDA PARTEEEEE (deixar o mundo rosa, pq? EU SEI LA É LEGAL)    
--====================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local originalProperties = {}
local isPinkEnabled = false
local connections = {}


local pinkColors = {
	Color3.fromRGB(255, 20, 147),
	Color3.fromRGB(255, 105, 180),
	Color3.fromRGB(255, 192, 203),
	Color3.fromRGB(244, 143, 177),
}


local function backupAndTransform(object)
	if object:IsDescendantOf(player.Character) then return end

	if object:IsA("BasePart") and not originalProperties[object] then
		originalProperties[object] = {
			Color = object.Color,
			Material = object.Material
		}
		if isPinkEnabled then
			object.Material = (math.random(1, 5) == 1) and Enum.Material.Neon or Enum.Material.SmoothPlastic
			object.Color = pinkColors[math.random(1, #pinkColors)]
		end
	elseif (object:IsA("Texture") or object:IsA("Decal")) and not originalProperties[object] then
		originalProperties[object] = { Color3 = object.Color3 }
		if isPinkEnabled then
			object.Color3 = Color3.fromRGB(255, 105, 180)
		end
	elseif object:IsA("Light") and not originalProperties[object] then
		originalProperties[object] = { Color = object.Color }
		if isPinkEnabled then
			object.Color = Color3.fromRGB(255, 50, 150)
		end
	end
end

local function enablePinkWorld()
	isPinkEnabled = true
	
	
	if Workspace:FindFirstChildOfClass("Terrain") then
		local terrain = Workspace:FindFirstChildOfClass("Terrain")
		originalProperties["Terrain"] = { WaterColor = terrain.WaterColor }
		terrain.WaterColor = Color3.fromRGB(255, 20, 147)
	end

	originalProperties["Lighting"] = {
		ClockTime = Lighting.ClockTime,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		FogColor = Lighting.FogColor,
		FogEnd = Lighting.FogEnd
	}

	Lighting.ClockTime = 18
	Lighting.Ambient = Color3.fromRGB(255, 150, 200)
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 100, 180)
	Lighting.FogColor = Color3.fromRGB(255, 182, 193)
	Lighting.FogEnd = 350

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "UltraPinkBloom"
	bloom.Intensity = 2
	bloom.Size = 30
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "UltraPinkCC"
	cc.TintColor = Color3.fromRGB(255, 180, 220)
	cc.Saturation = 0.4
	cc.Parent = Lighting

	for _, obj in ipairs(Workspace:GetDescendants()) do
		backupAndTransform(obj)
	end

	local conn = Workspace.DescendantAdded:Connect(function(descendant)
		task.wait()
		backupAndTransform(descendant)
	end)
	table.insert(connections, conn)
end

local function disablePinkWorld()
	isPinkEnabled = false
	

	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}


	for obj, props in pairs(originalProperties) do
		if obj == "Terrain" and Workspace:FindFirstChildOfClass("Terrain") then
			Workspace:FindFirstChildOfClass("Terrain").WaterColor = props.WaterColor
		elseif obj == "Lighting" then
			Lighting.ClockTime = props.ClockTime
			Lighting.Ambient = props.Ambient
			Lighting.OutdoorAmbient = props.OutdoorAmbient
			Lighting.FogColor = props.FogColor
			Lighting.FogEnd = props.FogEnd
		elseif typeof(obj) == "Instance" and obj.Parent then
			if obj:IsA("BasePart") then
				obj.Color = props.Color
				obj.Material = props.Material
			elseif obj:IsA("Texture") or obj:IsA("Decal") then
				obj.Color3 = props.Color3
			elseif obj:IsA("Light") then
				obj.Color = props.Color
			end
		end
	end
	
	originalProperties = {}

	
	local bloom = Lighting:FindFirstChild("UltraPinkBloom")
	if bloom then bloom:Destroy() end
	local cc = Lighting:FindFirstChild("UltraPinkCC")
	if cc then cc:Destroy() end
end


local oldGui = playerGui:FindFirstChild("TudoROSAA")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TudoROSAA"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui


local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 140)
mainFrame.Position = UDim2.new(0, 20, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(255, 105, 180)
mainStroke.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
titleBar.Text = "   Tudo ROSAA"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
local fontSuccess, _ = pcall(function() titleBar.Font = Enum.Font.FredokaOne end)
if not fontSuccess then titleBar.Font = Enum.Font.SourceSansBold end
titleBar.TextSize = 14
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar


local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 25, 0, 25)
minButton.Position = UDim2.new(1, -30, 0, 2.5)
minButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
minButton.Text = "-"
minButton.TextColor3 = Color3.new(1, 1, 1)
minButton.TextSize = 16
minButton.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minButton


local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame


local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(0, 180, 0, 40)
actionButton.Position = UDim2.new(0.5, -90, 0.5, -20)
actionButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
actionButton.Text = "ATIVAR"
actionButton.TextColor3 = Color3.new(1, 1, 1)
actionButton.TextSize = 18
actionButton.Font = titleBar.Font
actionButton.Parent = contentFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = actionButton


actionButton.MouseButton1Click:Connect(function()
	if not isPinkEnabled then
		enablePinkWorld()
		actionButton.Text = "DESATIVAR"
		actionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	else
		disablePinkWorld()
		actionButton.Text = "ATIVAR"
		actionButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
	end
end)


local isMinimized = false
minButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		contentFrame.Visible = false
		mainFrame:TweenSize(UDim2.new(0, 220, 0, 30), "Out", "Quad", 0.2, true)
		minButton.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 220, 0, 140), "Out", "Quad", 0.2, true, function()
			contentFrame.Visible = true
		end)
		minButton.Text = "-"
	end
end)


local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)



--07h41m
