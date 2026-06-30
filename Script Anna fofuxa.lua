--Script feito pelo @felipe.kazu
--Anna, saudades 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local playerGui = player:WaitForChild("PlayerGui")


local currentMode = "None" 
local originalProperties = {}
local mapConnections = {}


local pinkColors = {
	Color3.fromRGB(255, 20, 147),
	Color3.fromRGB(255, 105, 180),
	Color3.fromRGB(255, 192, 203),
	Color3.fromRGB(244, 143, 177),
}

local greenColors = {
	Color3.fromRGB(165, 225, 185), 
	Color3.fromRGB(180, 240, 200), 
	Color3.fromRGB(200, 245, 215),
	Color3.fromRGB(145, 210, 170),
}


for _, oldFolder in ipairs(workspace:GetChildren()) do
	if oldFolder.Name == "AnnaEffect_FinalOrbit" then
		oldFolder:Destroy()
	end
end

local function setupLighting()
	local bloom = Lighting:FindFirstChild("AnnaBloom") or Instance.new("BloomEffect")
	bloom.Name = "AnnaBloom"
	bloom.Intensity = 1.0 
	bloom.Size = 22
	bloom.Parent = Lighting

	local cc = Lighting:FindFirstChild("AnnaCC") or Instance.new("ColorCorrectionEffect")
	cc.Name = "AnnaCC"
	cc.Saturation = 0.1
	cc.Parent = Lighting
end
setupLighting()

local folder = Instance.new("Folder")
folder.Name = "AnnaEffect_FinalOrbit"
folder.Parent = workspace


local function createHeartAnchor(nameText, defaultColor)
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Anchored = true
	anchor.Parent = folder

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(6, 0, 3, 0) 
	billboard.AlwaysOnTop = false 
	billboard.MaxDistance = 100 
	billboard.Parent = anchor

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = ""
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextColor3 = defaultColor
	textLabel.TextScaled = true
	textLabel.Parent = billboard

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 3
	uiStroke.Color = Color3.new(1, 1, 1)
	uiStroke.Parent = textLabel

	task.spawn(function()
		while true do
			for i = 1, #nameText do
				textLabel.Text = string.sub(nameText, 1, i)
				task.wait(0.3)
			end
			task.wait(2)
			local t = TweenService:Create(uiStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Color = defaultColor})
			t:Play()
			break
		end
	end)

	local smoke = Instance.new("ParticleEmitter")
	smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	smoke.Size = NumberSequence.new(0.4, 1.5)
	smoke.Lifetime = NumberRange.new(0.8, 1.4)
	smoke.Rate = 10
	smoke.Speed = NumberRange.new(1, 2)
	smoke.Parent = anchor

	local petals = Instance.new("ParticleEmitter")
	petals.Size = NumberSequence.new(0.3)
	petals.Lifetime = NumberRange.new(2, 4)
	petals.Rate = 5
	petals.Speed = NumberRange.new(2, 5)
	petals.EmissionDirection = Enum.NormalId.Bottom
	petals.SpreadAngle = Vector2.new(30, 30)
	petals.Parent = anchor
	
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxassetid://6071575923"
	stars.Color = ColorSequence.new(Color3.new(1, 1, 0.9))
	stars.Size = NumberSequence.new(0.12, 0.35)
	stars.Lifetime = NumberRange.new(0.5, 1.2)
	stars.Rate = 10
	stars.Parent = anchor

	
	local partsList = {}
	local scale = 0.22 

	for t = 0, math.pi * 2, 0.15 do
		local x = 16 * math.sin(t)^3
		local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
		
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.28, 0.28, 0.28)
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.CanCollide = false
		p.Anchored = true
		p.Parent = folder
		
		table.insert(partsList, {Part = p, Offset = Vector3.new(x * scale, y * scale, 0)})
	end

	return {
		Anchor = anchor,
		Parts = partsList,
		Label = textLabel,
		Smoke = smoke,
		Petals = petals
	}
end


local pinkHeart = createHeartAnchor("Anna", Color3.fromRGB(255, 100, 200))
local greenHeart = createHeartAnchor("Anna", Color3.fromRGB(145, 210, 170))


local function applyHeartColors()
	if currentMode == "Pink" then
		
		pinkHeart.Label.TextColor3 = Color3.fromRGB(255, 100, 200)
		greenHeart.Label.TextColor3 = Color3.fromRGB(255, 100, 200)
		pinkHeart.Smoke.Color = ColorSequence.new(Color3.fromRGB(255, 192, 203))
		greenHeart.Smoke.Color = ColorSequence.new(Color3.fromRGB(255, 192, 203))
		pinkHeart.Petals.Color = ColorSequence.new(Color3.fromRGB(220, 20, 60))
		greenHeart.Petals.Color = ColorSequence.new(Color3.fromRGB(220, 20, 60))
		for _, v in ipairs(pinkHeart.Parts) do v.Part.Color = pinkColors[math.random(1, #pinkColors)] end
		for _, v in ipairs(greenHeart.Parts) do v.Part.Color = pinkColors[math.random(1, #pinkColors)] end
	elseif currentMode == "Green" then
		
		pinkHeart.Label.TextColor3 = Color3.fromRGB(145, 210, 170)
		greenHeart.Label.TextColor3 = Color3.fromRGB(145, 210, 170)
		pinkHeart.Smoke.Color = ColorSequence.new(Color3.fromRGB(200, 245, 215))
		greenHeart.Smoke.Color = ColorSequence.new(Color3.fromRGB(200, 245, 215))
		pinkHeart.Petals.Color = ColorSequence.new(Color3.fromRGB(145, 210, 170))
		greenHeart.Petals.Color = ColorSequence.new(Color3.fromRGB(145, 210, 170))
		for _, v in ipairs(pinkHeart.Parts) do v.Part.Color = greenColors[math.random(1, #greenColors)] end
		for _, v in ipairs(greenHeart.Parts) do v.Part.Color = greenColors[math.random(1, #greenColors)] end
	else
		
		pinkHeart.Label.TextColor3 = Color3.fromRGB(255, 100, 200)
		pinkHeart.Smoke.Color = ColorSequence.new(Color3.fromRGB(255, 192, 203))
		pinkHeart.Petals.Color = ColorSequence.new(Color3.fromRGB(220, 20, 60))
		for _, v in ipairs(pinkHeart.Parts) do v.Part.Color = (math.random() > 0.5) and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(255, 0, 0) end

		greenHeart.Label.TextColor3 = Color3.fromRGB(145, 210, 170)
		greenHeart.Smoke.Color = ColorSequence.new(Color3.fromRGB(200, 245, 215))
		greenHeart.Petals.Color = ColorSequence.new(Color3.fromRGB(145, 210, 170))
		for _, v in ipairs(greenHeart.Parts) do v.Part.Color = greenColors[math.random(1, #greenColors)] end
	end
end
applyHeartColors() 

local mainOrbitAngle = 0   
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
	beatTime = beatTime + dt * 4
	
	
	local beatScale = 1 + (math.sin(beatTime) * 0.15)
	if math.sin(beatTime) > 0.8 then beatScale = 1.2 end
	
	local baseLookCFrame = CFrame.new(Vector3.zero, hrp.Position) 
	
	
	local offsetX1 = math.sin(mainOrbitAngle) * radius
	local offsetZ1 = math.cos(mainOrbitAngle) * radius
	local pos1 = hrp.Position + Vector3.new(offsetX1, 1.5, offsetZ1)
	pinkHeart.Anchor.Position = pos1
	
	local baseCFrame1 = CFrame.new(pos1, hrp.Position)
	for _, data in ipairs(pinkHeart.Parts) do
		local localOffset = data.Offset * beatScale
		data.Part.CFrame = baseCFrame1 * CFrame.new(localOffset.X, localOffset.Y, 0)
	end
	
	
	local offsetX2 = math.sin(mainOrbitAngle + math.pi) * radius
	local offsetZ2 = math.cos(mainOrbitAngle + math.pi) * radius
	local pos2 = hrp.Position + Vector3.new(offsetX2, 1.5, offsetZ2)
	greenHeart.Anchor.Position = pos2
	
	local baseCFrame2 = CFrame.new(pos2, hrp.Position)
	for _, data in ipairs(greenHeart.Parts) do
		local localOffset = data.Offset * beatScale
		data.Part.CFrame = baseCFrame2 * CFrame.new(localOffset.X, localOffset.Y, 0)
	end
end)

--===========================================================================
-- SEGUNDA PARTEEEEE (deixar o mundo rosa e verde pq? EU SEI LA EU GOSTO)    
--===========================================================================


local function backupAndTransform(object)
	if object:IsDescendantOf(player.Character) then return end

	if object:IsA("BasePart") and not originalProperties[object] then
		originalProperties[object] = {
			Color = object.Color,
			Material = object.Material
		}
		if currentMode == "Pink" then
			object.Material = (math.random(1, 5) == 1) and Enum.Material.Neon or Enum.Material.SmoothPlastic
			object.Color = pinkColors[math.random(1, #pinkColors)]
		elseif currentMode == "Green" then
			object.Material = (math.random(1, 6) == 1) and Enum.Material.Neon or Enum.Material.SmoothPlastic
			object.Color = greenColors[math.random(1, #greenColors)]
		end
	elseif (object:IsA("Texture") or object:IsA("Decal")) and not originalProperties[object] then
		originalProperties[object] = { Color3 = object.Color3 }
		if currentMode == "Pink" then
			object.Color3 = Color3.fromRGB(255, 105, 180)
		elseif currentMode == "Green" then
			object.Color3 = Color3.fromRGB(165, 225, 185)
		end
	elseif object:IsA("Light") and not originalProperties[object] then
		originalProperties[object] = { Color = object.Color }
		if currentMode == "Pink" then
			object.Color = Color3.fromRGB(255, 50, 150)
		elseif currentMode == "Green" then
			object.Color = Color3.fromRGB(180, 240, 200)
		end
	end
end

local function disableCurrentWorld()
	for _, conn in ipairs(mapConnections) do
		conn:Disconnect()
	end
	mapConnections = {}

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

	local bloom = Lighting:FindFirstChild("UltraColorBloom")
	if bloom then bloom:Destroy() end
	local cc = Lighting:FindFirstChild("UltraColorCC")
	if cc then cc:Destroy() end
	
	currentMode = "None"
	applyHeartColors()
end

local function enableColoredWorld(mode)
	if currentMode ~= "None" then
		disableCurrentWorld()
	end
	
	currentMode = mode
	applyHeartColors()
	
	if Workspace:FindFirstChildOfClass("Terrain") then
		local terrain = Workspace:FindFirstChildOfClass("Terrain")
		originalProperties["Terrain"] = { WaterColor = terrain.WaterColor }
		
		terrain.WaterColor = (mode == "Pink") and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(180, 240, 210)
	end

	originalProperties["Lighting"] = {
		ClockTime = Lighting.ClockTime,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		FogColor = Lighting.FogColor,
		FogEnd = Lighting.FogEnd
	}

	Lighting.ClockTime = 18
	
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "UltraColorBloom"
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "UltraColorCC"
	cc.Parent = Lighting
	
	if mode == "Pink" then
		Lighting.Ambient = Color3.fromRGB(255, 150, 200)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 100, 180)
		Lighting.FogColor = Color3.fromRGB(255, 182, 193)
		Lighting.FogEnd = 350
		bloom.Intensity = 2
		bloom.Size = 30
		cc.TintColor = Color3.fromRGB(255, 180, 220)
		cc.Saturation = 0.4
	else 
		Lighting.Ambient = Color3.fromRGB(205, 235, 215)
		Lighting.OutdoorAmbient = Color3.fromRGB(185, 225, 195)
		Lighting.FogColor = Color3.fromRGB(210, 240, 220)
		Lighting.FogEnd = 450 
		bloom.Intensity = 0.8 
		bloom.Size = 12
		cc.TintColor = Color3.fromRGB(220, 245, 225) 
		cc.Saturation = 0.15
	end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		backupAndTransform(obj)
	end

	local conn = Workspace.DescendantAdded:Connect(function(descendant)
		task.wait()
		backupAndTransform(descendant)
	end)
	table.insert(mapConnections, conn)
end

local oldGui = playerGui:FindFirstChild("TudoROSAA")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TudoROSAA"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 180) 
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
titleBar.Text = "   Menu de Cores"
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


local pinkButton = Instance.new("TextButton")
pinkButton.Size = UDim2.new(0, 180, 0, 40)
pinkButton.Position = UDim2.new(0.5, -90, 0, 20)
pinkButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
pinkButton.Text = "MUNDO ROSA"
pinkButton.TextColor3 = Color3.new(1, 1, 1)
pinkButton.TextSize = 14
pinkButton.Font = titleBar.Font
pinkButton.Parent = contentFrame

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 6)
btnCorner1.Parent = pinkButton


local greenButton = Instance.new("TextButton")
greenButton.Size = UDim2.new(0, 180, 0, 40)
greenButton.Position = UDim2.new(0.5, -90, 0, 75)
greenButton.BackgroundColor3 = Color3.fromRGB(115, 190, 140)
greenButton.Text = "MUNDO VERDE"
greenButton.TextColor3 = Color3.new(1, 1, 1)
greenButton.TextSize = 14
greenButton.Font = titleBar.Font
greenButton.Parent = contentFrame

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = greenButton


local function refreshButtons()
	if currentMode == "Pink" then
		pinkButton.Text = "DESATIVAR ROSA"
		pinkButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
		
		greenButton.Text = "MUNDO VERDE"
		greenButton.BackgroundColor3 = Color3.fromRGB(115, 190, 140)
		mainStroke.Color = Color3.fromRGB(255, 105, 180)
	elseif currentMode == "Green" then
		pinkButton.Text = "MUNDO ROSA"
		pinkButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
		
		greenButton.Text = "DESATIVAR VERDE"
		greenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
		mainStroke.Color = Color3.fromRGB(145, 210, 170)
	else
		pinkButton.Text = "MUNDO ROSA"
		pinkButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
		
		greenButton.Text = "MUNDO VERDE"
		greenButton.BackgroundColor3 = Color3.fromRGB(115, 190, 140)
		mainStroke.Color = Color3.fromRGB(255, 105, 180)
	end
end

pinkButton.MouseButton1Click:Connect(function()
	if currentMode == "Pink" then
		disableCurrentWorld()
	else
		enableColoredWorld("Pink")
	end
	refreshButtons()
end)

greenButton.MouseButton1Click:Connect(function()
	if currentMode == "Green" then
		disableCurrentWorld()
	else
		enableColoredWorld("Green")
	end
	refreshButtons()
end)


local isMinimized = false
minButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		contentFrame.Visible = false
		mainFrame:TweenSize(UDim2.new(0, 220, 0, 30), "Out", "Quad", 0.2, true)
		minButton.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 220, 0, 180), "Out", "Quad", 0.2, true, function()
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



--9h41m KKKAAAAZUUU
