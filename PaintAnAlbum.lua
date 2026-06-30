--Script feito pelo @felipe.kazu


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configurações
local CONFIG = {
    StartX = -76,
    EndX = 74,
    StartZ = -204,
    EndZ = -354, -- Note: Z menor é "mais fundo" no mapa
    Step = 4,    -- Distância entre teleportes (aumente se falhar, diminua para precisão)
    HeightOffset = 4, -- Altura de segurança acima do chão
    Delay = 0.00001  -- Tempo entre teleportes
}

-- Estado
local isRunning = false
local isMinimized = false
local thread = nil

-- ### CRIAÇÃO DA GUI ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CAZU_PaintGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Borda decorativa
local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(0, 255, 100)
Border.Thickness = 2
Border.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Text = "CAZU | PAINT"
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Botão Fechar (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame

-- Botão Minimizar (_)
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "_"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBlack
MinBtn.TextSize = 20
MinBtn.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Parado"
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Botão Start/Stop
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Text = "INICIAR"
ToggleBtn.Size = UDim2.new(1, -40, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0, 70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

-- Botão Minimizado (aparece só quando minimizado)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "ABRIR GUI"
MiniBtn.Size = UDim2.new(0, 120, 0, 40)
MiniBtn.Position = UDim2.new(0.5, -60, 0.5, -20)
MiniBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MiniBtn.BorderSizePixel = 1
MiniBtn.BorderColor3 = Color3.fromRGB(0, 255, 100)
MiniBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.Visible = false -- Começa invisível
MiniBtn.Parent = ScreenGui

-- ### FUNÇÕES DE LÓGICA ###

local function updateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color
end

local function getSafePosition(x, z)
    -- Raycast para encontrar o chão exato
    local origin = Vector3.new(x, 100, z)
    local direction = Vector3.new(0, -200, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = {Workspace.Terrain}
    
    local result = Workspace:Raycast(origin, direction, params)
    
    if result then
        return Vector3.new(x, result.Position.Y + CONFIG.HeightOffset, z)
    else
        -- Fallback se não achar terreno (pode precisar de ajuste no jogo específico)
        return Vector3.new(x, 10, z) 
    end
end

local function startPainting()
    if isRunning then return end
    isRunning = true
    updateStatus("Status: PINTANDO...", Color3.fromRGB(0, 255, 0))
    ToggleBtn.Text = "PARAR"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

    thread = task.spawn(function()
        -- Determinar direção do Z baseada nos valores
        local stepZ = CONFIG.StartZ < CONFIG.EndZ and CONFIG.Step or -CONFIG.Step
        
        for x = CONFIG.StartX, CONFIG.EndX, CONFIG.Step do
            if not isRunning then break end
            
            for z = CONFIG.StartZ, CONFIG.EndZ, stepZ do
                if not isRunning then break end
                
                -- Verifica se o personagem ainda existe
                if not character or not rootPart then
                    updateStatus("Erro: Personagem sumiu", Color3.fromRGB(255, 0, 0))
                    break
                end

                local targetPos = getSafePosition(x, z)
                
                -- Teleporte seguro
                humanoid.PlatformStand = true
                rootPart.CFrame = CFrame.new(targetPos)
                
                -- Pequena pausa para o jogo registrar a "pintura"
                task.wait(CONFIG.Delay)
                
                humanoid.PlatformStand = false
            end
        end
        
        if isRunning then
            updateStatus("Status: CONCLUÍDO", Color3.fromRGB(0, 255, 0))
            isRunning = false
            ToggleBtn.Text = "REINICIAR"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
    end)
end

local function stopPainting()
    if not isRunning then return end
    isRunning = false
    if thread then task.cancel(thread) end
    
    -- Retorna controle ao jogador
    humanoid.PlatformStand = false
    updateStatus("Status: Parado", Color3.fromRGB(200, 200, 200))
    ToggleBtn.Text = "INICIAR"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end

-- ### EVENTOS DA GUI ###

ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        stopPainting()
    else
        startPainting()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    stopPainting()
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniBtn.Visible = true
    isMinimized = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniBtn.Visible = false
    isMinimized = false
end)

-- Atalho de teclado para minimizar/restaurar (Tecla 'M')
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        if MainFrame.Visible then
            MinBtn:Fire()
        else
            MiniBtn:Fire()
        end
    end
end)
-- HACK: Torna a MainFrame arrastável por clique longo (hold + move)
local dragging = false
local dragStartPos = Vector2.new()
local frameStartPos = Vector2.new()

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        frameStartPos = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
    end
end

local function onInputMoved(input)
    if not dragging then return end
    local currentPos = Vector2.new(input.Position.X, input.Position.Y)
    local delta = currentPos - dragStartPos
    MainFrame.Position = UDim2.new(
        0,
        frameStartPos.X + delta.X,
        0,
        frameStartPos.Y + delta.Y
    )
end

local function onInputEnded(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputMoved)
UserInputService.InputEnded:Connect(onInputEnded)


updateStatus("Status: Pronto para iniciar", Color3.fromRGB(255, 255, 255))
