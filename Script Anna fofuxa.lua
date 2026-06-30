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


--07h41m
