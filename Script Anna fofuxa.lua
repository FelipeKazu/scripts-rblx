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
local humanoid = character:WaitForChild("Humanoid")
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local currentMode = "None" 
local originalProperties = {}
local mapConnections = {}
local attacksPaused = false 

local pinkColors = {
    Color3.fromRGB(255, 20, 147),
    Color3.fromRGB(255, 105, 180), --Script feito pelo @felipe.kazu
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
    bloom.Intensity = 0.4 
    bloom.Size = 12
    bloom.Parent = Lighting

    local cc = Lighting:FindFirstChild("AnnaCC") or Instance.new("ColorCorrectionEffect")
    cc.Name = "AnnaCC"
    cc.Saturation = 0.05
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
    billboard.Size = UDim2.new(6, 0, 3, 0) --Script feito pelo @felipe.kazu
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
    smoke.Rate = 10--Script feito pelo @felipe.kazu
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

    local partsList = {}--Script feito pelo @felipe.kazu
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
        Petals = petals,
        Stars = stars,
        IsFlying = false,
        FlyProgress = 0,
        StartPos = Vector3.new(),
        TargetPos = Vector3.new()
    }
end
--Script feito pelo @felipe.kazu
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
--Script feito pelo @felipe.kazu
local mainOrbitAngle = 0   
local beatTime = 0
local radius = 7          
local rotationSpeed = 2   
local projectileSpeed = 3.5 
--Script feito pelo @felipe.kazu
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
    
    local offsetX1 = math.sin(mainOrbitAngle) * radius
    local offsetZ1 = math.cos(mainOrbitAngle) * radius
    local pos1 = hrp.Position + Vector3.new(offsetX1, 1.5, offsetZ1)
    
    local offsetX2 = math.sin(mainOrbitAngle + math.pi) * radius
    local offsetZ2 = math.cos(mainOrbitAngle + math.pi) * radius
    local pos2 = hrp.Position + Vector3.new(offsetX2, 1.5, offsetZ2)

    
    local finalPos1
    if pinkHeart.IsFlying then
        pinkHeart.FlyProgress = pinkHeart.FlyProgress + (dt * projectileSpeed)
        pinkHeart.Smoke.Rate = 45 
        pinkHeart.Stars.Rate = 35

        if pinkHeart.FlyProgress < 1 then
            finalPos1 = pinkHeart.StartPos:Lerp(pinkHeart.TargetPos, pinkHeart.FlyProgress)
        elseif pinkHeart.FlyProgress < 2 then
            local t = pinkHeart.FlyProgress - 1
            finalPos1 = pinkHeart.TargetPos:Lerp(pos1, t)
        else
            pinkHeart.IsFlying = false --Script feito pelo @felipe.kazu
            pinkHeart.Smoke.Rate = 10
            pinkHeart.Stars.Rate = 10
            finalPos1 = pos1
        end
    else
        pinkHeart.StartPos = pos1
        finalPos1 = pos1
    end
    
    pinkHeart.Anchor.Position = finalPos1
    local baseCFrame1 = CFrame.new(finalPos1, hrp.Position)
    for _, data in ipairs(pinkHeart.Parts) do
        local localOffset = data.Offset * beatScale
        data.Part.CFrame = baseCFrame1 * CFrame.new(localOffset.X, localOffset.Y, 0)
    end
    
 
    local finalPos2
    if greenHeart.IsFlying then
        greenHeart.FlyProgress = greenHeart.FlyProgress + (dt * projectileSpeed)
        greenHeart.Smoke.Rate = 45
        greenHeart.Stars.Rate = 35

        if greenHeart.FlyProgress < 1 then
            finalPos2 = greenHeart.StartPos:Lerp(greenHeart.TargetPos, greenHeart.FlyProgress)
        elseif greenHeart.FlyProgress < 2 then
            local t = greenHeart.FlyProgress - 1
            finalPos2 = greenHeart.TargetPos:Lerp(pos2, t)
        else
            greenHeart.IsFlying = false
            greenHeart.Smoke.Rate = 10
            greenHeart.Stars.Rate = 10
            finalPos2 = pos2
        end
    else
        greenHeart.StartPos = pos2
        finalPos2 = pos2
    end
    --Script feito pelo @felipe.kazu
    greenHeart.Anchor.Position = finalPos2
    local baseCFrame2 = CFrame.new(finalPos2, hrp.Position)
    for _, data in ipairs(greenHeart.Parts) do
        local localOffset = data.Offset * beatScale
        data.Part.CFrame = baseCFrame2 * CFrame.new(localOffset.X, localOffset.Y, 0)
    end
end)

local function spawnHeartBurst()
    local burstCount = 15 
    local basePos = hrp.Position

    for i = 1, burstCount do
        task.spawn(function()
            local miniHeartModel = Instance.new("Folder")
            miniHeartModel.Name = "MiniHeart"
            miniHeartModel.Parent = folder

            local heartColor
            if currentMode == "Pink" then
                heartColor = pinkColors[math.random(1, #pinkColors)]
            elseif currentMode == "Green" then
                heartColor = greenColors[math.random(1, #greenColors)]
            else
                heartColor = (math.random() > 0.5) and pinkColors[math.random(1, #pinkColors)] or greenColors[math.random(1, #greenColors)]
            end

            local parts = {}
            local scale = 0.08 
            
            for t = 0, math.pi * 2, 0.4 do
                local x = 16 * math.sin(t)^3
                local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
                --Script feito pelo @felipe.kazu
                local p = Instance.new("Part")
                p.Size = Vector3.new(0.15, 0.15, 0.15)
                p.Material = Enum.Material.Neon
                p.Shape = Enum.PartType.Ball
                p.Color = heartColor
                p.CanCollide = false
                p.Anchored = true
                p.Parent = miniHeartModel
                
                table.insert(parts, {Part = p, Offset = Vector3.new(x * scale, y * scale, 0)})
            end

            local angle = math.rad(math.random(0, 360))
            local dist = math.random(3, 12)
            local targetX = math.sin(angle) * dist
            local targetZ = math.cos(angle) * dist
            
            local startOffset = Vector3.new(math.random(-2, 2), math.random(-1, 2), math.random(-2, 2))
            local spawnPos = basePos + startOffset
            local targetPos = basePos + Vector3.new(targetX, math.random(5, 14), targetZ)

            local lifetime = math.random(1.5, 2.5)
            local elapsed = 0

            while elapsed < lifetime do
                local dt = task.wait()
                elapsed = elapsed + dt
                local progress = elapsed / lifetime
                
                local currentPos = spawnPos:Lerp(targetPos, progress)
                local lookCf = CFrame.new(currentPos, currentPos + Vector3.new(0,0,1))

                for _, data in ipairs(parts) do
                    if data.Part and data.Part.Parent then
                        data.Part.CFrame = lookCf * CFrame.new(data.Offset.X, data.Offset.Y, 0)
                        if progress > 0.7 then
                            data.Part.Transparency = (progress - 0.7) / 0.3
                        end
                    end
                end
            end

            miniHeartModel:Destroy()
        end)
    end
end


local function spawnMegaBlackHoleExplosion(position)
    local burstFolder = Instance.new("Folder", folder)
    burstFolder.Name = "MegaBlackHoleVisualExplosion"
    
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(1, 1, 1)
    flash.Shape = Enum.PartType.Ball
    flash.Color = Color3.fromRGB(255, 255, 255)
    flash.Material = Enum.Material.Neon
    flash.Anchored = true
    flash.CanCollide = false
    flash.Position = position
    flash.Parent = burstFolder
    
    TweenService:Create(flash, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(22, 22, 22),
        Transparency = 1
    }):Play()

    local wave = Instance.new("Part")
    wave.Size = Vector3.new(2, 2, 2)
    wave.Shape = Enum.PartType.Ball
    wave.Color = Color3.fromRGB(255, 30, 140)
    wave.Material = Enum.Material.Neon
    wave.Transparency = 0.15
    wave.Anchored = true
    wave.CanCollide = false
    wave.Position = position
    wave.Parent = burstFolder
    
    TweenService:Create(wave, TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Size = Vector3.new(55, 55, 55),
        Transparency = 1
    }):Play()

    local sparkAnchor = Instance.new("Part")
    sparkAnchor.Size = Vector3.new(1, 1, 1)
    sparkAnchor.Transparency = 1
    sparkAnchor.Anchored = true
    sparkAnchor.CanCollide = false
    sparkAnchor.Position = position
    sparkAnchor.Parent = burstFolder
--Script feito pelo @felipe.kazu
    local sparks = Instance.new("ParticleEmitter", sparkAnchor)
    sparks.Texture = "rbxassetid://6071575923"
    sparks.Size = NumberSequence.new(0.4, 2.0)
    sparks.Lifetime = NumberRange.new(0.7, 1.4)
    sparks.Speed = NumberRange.new(18, 40)
    sparks.SpreadAngle = Vector2.new(360, 360)
    sparks.Color = ColorSequence.new(Color3.fromRGB(255, 80, 170), Color3.fromRGB(130, 230, 160))
    sparks.Rate = 400
    
    task.delay(0.15, function() if sparks then sparks.Enabled = false end end)

    local totalHearts = 45
    for j = 1, 4 do
        task.spawn(function()
            if j > 1 then task.wait(0.06 * (j - 1)) end
            
            for i = 1, math.floor(totalHearts / (j * 0.8)) do
                task.spawn(function()
                    local miniHeartModel = Instance.new("Folder", burstFolder)
                    local pickColor = (math.random() > 0.5) and pinkColors[math.random(1, #pinkColors)] or greenColors[math.random(1, #greenColors)]
                    
                    local parts = {}
                    local scale = math.random(8, 16) * 0.01
                    for t = 0, math.pi * 2, 0.5 do
                        local x = 16 * math.sin(t)^3
                        local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
                        local p = Instance.new("Part")
                        p.Size = Vector3.new(0.2, 0.2, 0.2)
                        p.Material = Enum.Material.Neon
                        p.Shape = Enum.PartType.Ball
                        p.Color = pickColor
                        p.CanCollide = false
                        p.Anchored = true
                        p.Parent = miniHeartModel
                        table.insert(parts, {Part = p, Offset = Vector3.new(x * scale, y * scale, 0)})
                    end
                    
                    local angle = math.rad(math.random(0, 360))
                    local elevation = math.rad(math.random(-55, 85))
                    local moveVector = Vector3.new(
                        math.cos(elevation) * math.sin(angle),
                        math.sin(elevation),
                        math.cos(elevation) * math.cos(angle)
                    ).Unit
                    
                    local startPos = position
                    local targetPos = position + (moveVector * math.random(20, 45))
                    --Script feito pelo @felipe.kazu
                    local lifetime = math.random(10, 16) * 0.1
                    local elapsed = 0
                    while elapsed < lifetime do
                        local dt = task.wait()
                        elapsed = elapsed + dt
                        local progress = elapsed / lifetime
                        local currentPos = startPos:Lerp(targetPos, progress)
                        local lookCf = CFrame.new(currentPos, currentPos + Vector3.new(0,0,1))
                        
                        for _, data in ipairs(parts) do
                            if data.Part and data.Part.Parent then
                                data.Part.CFrame = lookCf * CFrame.new(data.Offset.X, data.Offset.Y, 0)
                                data.Part.Transparency = progress
                            end
                        end
                    end
                    miniHeartModel:Destroy()
                end)
            end
        end)
    end
    game:GetService("Debris"):AddItem(burstFolder, 2.0)
end


local function castLoveBlackHole()
    if attacksPaused then return end
    attacksPaused = true

    local targetPos = mouse.Hit.Position
    local bhFolder = Instance.new("Folder", folder)
    bhFolder.Name = "LoveBlackHoleVisualInstance"

    local center = Instance.new("Part")
    center.Size = Vector3.new(1,1,1)
    center.Transparency = 1
    center.Anchored = true
    center.CanCollide = false
    center.Position = targetPos + Vector3.new(0, 2, 0)
    center.Parent = bhFolder

    local core = Instance.new("Part", bhFolder)
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(0.5, 0.5, 0.5)
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(255, 20, 147)
    core.Position = center.Position
    core.Anchored = true
    core.CanCollide = false
    --Script feito pelo @felipe.kazu
   
    TweenService:Create(core, TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = Vector3.new(4, 4, 4)}):Play()

    local particles = Instance.new("ParticleEmitter", center)
    particles.Texture = "rbxassetid://6071575923"
    particles.Size = NumberSequence.new(0.5, 2.2)
    particles.Lifetime = NumberRange.new(0.8)
    particles.Rate = 140
    particles.Speed = NumberRange.new(5, 15) 
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 30, 140), Color3.fromRGB(145, 210, 170))

    local orb1 = Instance.new("Part", bhFolder)
    orb1.Size = Vector3.new(1.8, 1.8, 1.8)
    orb1.Material = Enum.Material.Neon
    orb1.Color = Color3.fromRGB(255, 20, 147)
    orb1.Shape = Enum.PartType.Ball
    orb1.Anchored = true
    orb1.CanCollide = false

    local orb2 = orb1:Clone()
    orb2.Color = Color3.fromRGB(145, 210, 170)
    orb2.Parent = bhFolder

    local duration = 2.5 
    local startElapsed = 0

    while startElapsed < duration do
        local dt = task.wait()
        startElapsed = startElapsed + dt
        local angle = startElapsed * 16
        local currentRadius = math.max(0.2, 10 * (1 - (startElapsed / duration)))

        local offsetX = math.sin(angle) * currentRadius
        local offsetZ = math.cos(angle) * currentRadius
        
        orb1.Position = center.Position + Vector3.new(offsetX, math.sin(startElapsed * 6) * 1.5, offsetZ)
        orb2.Position = center.Position + Vector3.new(-offsetX, math.cos(startElapsed * 6) * 1.5, -offsetZ)
    end

    spawnMegaBlackHoleExplosion(center.Position)

    bhFolder:Destroy()
    attacksPaused = false
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.KeyCode.E then
        local targetPosition = mouse.Hit.Position
        
        if not pinkHeart.IsFlying then
            pinkHeart.TargetPos = targetPosition
            pinkHeart.FlyProgress = 0
            pinkHeart.IsFlying = true
        elseif not greenHeart.IsFlying then
            greenHeart.TargetPos = targetPosition
            greenHeart.FlyProgress = 0
            greenHeart.IsFlying = true
        end
        
    elseif input.KeyCode == Enum.KeyCode.V then
        spawnHeartBurst()
        
    elseif input.KeyCode == Enum.KeyCode.Q then
        task.spawn(castLoveBlackHole)
    end
end)



local function backupAndTransform(object)
    if object:IsDescendantOf(player.Character) then return end

    if object:IsA("BasePart") and not originalProperties[object] then
        originalProperties[object] = {
            Color = object.Color,
            Material = object.Material
        }
        if currentMode == "Pink" then
            object.Material = (math.random(1, 20) == 1) and Enum.Material.Neon or Enum.Material.SmoothPlastic
            object.Color = pinkColors[math.random(1, #pinkColors)]
        elseif currentMode == "Green" then
            object.Material = (math.random(1, 20) == 1) and Enum.Material.Neon or Enum.Material.SmoothPlastic
            object.Color = greenColors[math.random(1, #greenColors)]
        end
    elseif (object:IsA("Texture") or object:IsA("Decal")) and not originalProperties[object] then
        originalProperties[object] = { Color3 = object.Color3 }
        if currentMode == "Pink" then
            object.Color3 = Color3.fromRGB(255, 150, 200)
        elseif currentMode == "Green" then
            object.Color3 = Color3.fromRGB(185, 225, 200)
        end
    elseif object:IsA("Light") and not originalProperties[object] then
        originalProperties[object] = { Color = object.Color }
        if currentMode == "Pink" then
            object.Color = Color3.fromRGB(255, 120, 180)
        elseif currentMode == "Green" then
            object.Color = Color3.fromRGB(190, 230, 210)
        end
    end
end
--Script feito pelo @felipe.kazu
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
        terrain.WaterColor = (mode == "Pink") and Color3.fromRGB(255, 100, 160) or Color3.fromRGB(190, 230, 210)
    end

    originalProperties["Lighting"] = {
        ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogColor = Lighting.FogColor,
        FogEnd = Lighting.FogEnd
    }

    Lighting.ClockTime = 16.5 
    
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "UltraColorBloom"
    bloom.Parent = Lighting

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "UltraColorCC"
    cc.Parent = Lighting
    
    if mode == "Pink" then
        Lighting.Ambient = Color3.fromRGB(200, 140, 170)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 130, 150)
        Lighting.FogColor = Color3.fromRGB(240, 200, 215)
        Lighting.FogEnd = 500
        bloom.Intensity = 0.35 
        bloom.Size = 15
        cc.TintColor = Color3.fromRGB(245, 210, 225)
        cc.Saturation = 0.15  
    else 
        Lighting.Ambient = Color3.fromRGB(175, 205, 185)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 190, 170)
        Lighting.FogColor = Color3.fromRGB(215, 235, 220)
        Lighting.FogEnd = 600 
        bloom.Intensity = 0.25 
        bloom.Size = 10
        cc.TintColor = Color3.fromRGB(225, 240, 230) 
        cc.Saturation = 0.05
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        backupAndTransform(obj)
    end
--Script feito pelo @felipe.kazu
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
mainFrame.Size = UDim2.new(0, 230, 0, 210) 
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
titleBar.Text = "    Anna GUI  |  by:@felipe.kazu"
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

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(38, 38, 43)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local worldsTabBtn = Instance.new("TextButton")
worldsTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
worldsTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
worldsTabBtn.BorderSizePixel = 0
worldsTabBtn.Text = "Mundos"
worldsTabBtn.Font = titleBar.Font
worldsTabBtn.TextColor3 = Color3.new(1, 1, 1)
worldsTabBtn.TextSize = 13
worldsTabBtn.Parent = tabContainer

local settingsTabBtn = Instance.new("TextButton")
settingsTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
settingsTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
settingsTabBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
settingsTabBtn.BorderSizePixel = 0
settingsTabBtn.Text = "Settings"
settingsTabBtn.Font = titleBar.Font
settingsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
settingsTabBtn.TextSize = 13
settingsTabBtn.Parent = tabContainer
--Script feito pelo @felipe.kazu
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -60)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local worldsPage = Instance.new("Frame")
worldsPage.Size = UDim2.new(1, 0, 1, 0)
worldsPage.BackgroundTransparency = 1
worldsPage.Visible = true
worldsPage.Parent = contentFrame

local pinkButton = Instance.new("TextButton")
pinkButton.Size = UDim2.new(0, 190, 0, 40)
pinkButton.Position = UDim2.new(0.5, -95, 0, 20)
pinkButton.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
pinkButton.Text = "MUNDO ROSA"
pinkButton.TextColor3 = Color3.new(1, 1, 1)
pinkButton.TextSize = 14
pinkButton.Font = titleBar.Font
pinkButton.Parent = worldsPage

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 6)
btnCorner1.Parent = pinkButton

local greenButton = Instance.new("TextButton")
greenButton.Size = UDim2.new(0, 190, 0, 40)
greenButton.Position = UDim2.new(0.5, -95, 0, 75)
greenButton.BackgroundColor3 = Color3.fromRGB(115, 190, 140)
greenButton.Text = "MUNDO VERDE"
greenButton.TextColor3 = Color3.new(1, 1, 1)
greenButton.TextSize = 14
greenButton.Font = titleBar.Font
greenButton.Parent = worldsPage

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = greenButton

local settingsPage = Instance.new("Frame")
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false
settingsPage.Parent = contentFrame

local speedConfigBtn = Instance.new("TextButton")
speedConfigBtn.Size = UDim2.new(0, 190, 0, 32)
speedConfigBtn.Position = UDim2.new(0.5, -95, 0, 12)
speedConfigBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
speedConfigBtn.Text = "Bumerangue: Normal"
speedConfigBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
speedConfigBtn.TextSize = 13
speedConfigBtn.Font = titleBar.Font
speedConfigBtn.Parent = settingsPage

local btnCorner3 = Instance.new("UICorner")
btnCorner3.CornerRadius = UDim.new(0, 6)
btnCorner3.Parent = speedConfigBtn

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 190, 0, 90)
infoLabel.Position = UDim2.new(0.5, -95, 0, 50)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "[E] Bumerangue  |  [V] Chuva\n\n[Q] Buraco Negro"
infoLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextWrapped = true
infoLabel.Parent = settingsPage

worldsTabBtn.MouseButton1Click:Connect(function()
    worldsTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    worldsTabBtn.TextColor3 = Color3.new(1, 1, 1)
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
    settingsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    worldsPage.Visible = true
    settingsPage.Visible = false
end)

settingsTabBtn.MouseButton1Click:Connect(function()
    settingsTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    settingsTabBtn.TextColor3 = Color3.new(1, 1, 1)
    worldsTabBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
    worldsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    settingsPage.Visible = true
    worldsPage.Visible = false
end)

speedConfigBtn.MouseButton1Click:Connect(function()
    if projectileSpeed == 3.5 then
        projectileSpeed = 6.0
        speedConfigBtn.Text = "Bumerangue: Rápido"
        speedConfigBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    else
        projectileSpeed = 3.5
        speedConfigBtn.Text = "Bumerangue: Normal"
        speedConfigBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    end
end)
--Script feito pelo @felipe.kazu
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
        tabContainer.Visible = false
        mainFrame:TweenSize(UDim2.new(0, 230, 0, 30), "Out", "Quad", 0.2, true)
        minButton.Text = "+"
    else
        mainFrame:TweenSize(UDim2.new(0, 230, 0, 210), "Out", "Quad", 0.2, true, function()
            contentFrame.Visible = true
            tabContainer.Visible = true
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

--11h41m KKKAAAAZUUU
