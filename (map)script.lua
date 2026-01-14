-- ============================================
-- CIDADE DE MOTOS COM CONTROLES DINÂMICOS
-- Botões aparecem SOMENTE quando montado na moto
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

print("🌆 CONSTRUINDO CIDADE DE MOTOS...")

-- ============================================
-- 1. LIMPAR E PREPARAR
-- ============================================

-- Limpar cidade anterior
local cidadeAntiga = workspace:FindFirstChild("CidadeMotos")
if cidadeAntiga then
    cidadeAntiga:Destroy()
end

-- Criar nova cidade
local cidade = Instance.new("Folder")
cidade.Name = "CidadeMotos"
cidade.Parent = workspace

-- ============================================
-- 2. FUNÇÕES DE CONSTRUÇÃO
-- ============================================

local function criarPredio(posicao, largura, profundidade, altura, andares, cor)
    local predio = Instance.new("Model")
    predio.Name = "Predio_"..math.random(1000,9999)
    
    for a = 1, andares do
        local andar = Instance.new("Part")
        andar.Name = "Andar_"..a
        andar.Size = Vector3.new(largura, altura/andares, profundidade)
        andar.Position = posicao + Vector3.new(0, (a-0.5)*(altura/andares), 0)
        andar.Anchored = true
        andar.CanCollide = true
        andar.BrickColor = BrickColor.new(cor)
        andar.Material = Enum.Material.Concrete
        andar.Parent = predio
        
        -- Janelas
        for i = -1, 1, 2 do
            for j = -1, 1, 2 do
                local janela = Instance.new("Part")
                janela.Size = Vector3.new(2, 1.5, 0.1)
                janela.Position = andar.Position + Vector3.new(i*(largura/2-1), 0, j*(profundidade/2-1))
                janela.Anchored = true
                janela.CanCollide = false
                janela.BrickColor = BrickColor.new("Light blue")
                janela.Transparency = 0.3
                janela.Parent = predio
            end
        end
    end
    
    predio.Parent = cidade
    return predio
end

local function criarCasa(posicao, tamanho, corTelhado)
    local casa = Instance.new("Model")
    casa.Name = "Casa"
    
    -- Base
    local base = Instance.new("Part")
    base.Size = Vector3.new(tamanho.X, 1, tamanho.Y)
    base.Position = posicao + Vector3.new(0, 0.5, 0)
    base.Anchored = true
    base.CanCollide = true
    base.BrickColor = BrickColor.new("Pastel Blue")
    base.Material = Enum.Material.Concrete
    base.Parent = casa
    
    -- Paredes (2 andares)
    local paredeFrente = Instance.new("Part")
    paredeFrente.Size = Vector3.new(tamanho.X, 8, 0.5)
    paredeFrente.Position = posicao + Vector3.new(0, 4, tamanho.Y/2)
    paredeFrente.Anchored = true
    paredeFrente.CanCollide = true
    paredeFrente.BrickColor = BrickColor.new("Pastel Blue")
    paredeFrente.Parent = casa
    
    local paredeTras = paredeFrente:Clone()
    paredeTras.Position = posicao + Vector3.new(0, 4, -tamanho.Y/2)
    paredeTras.Parent = casa
    
    local paredeEsq = Instance.new("Part")
    paredeEsq.Size = Vector3.new(0.5, 8, tamanho.Y)
    paredeEsq.Position = posicao + Vector3.new(-tamanho.X/2, 4, 0)
    paredeEsq.Anchored = true
    paredeEsq.CanCollide = true
    paredeEsq.BrickColor = BrickColor.new("Pastel Blue")
    paredeEsq.Parent = casa
    
    local paredeDir = paredeEsq:Clone()
    paredeDir.Position = posicao + Vector3.new(tamanho.X/2, 4, 0)
    paredeDir.Parent = casa
    
    -- Telhado
    local telhado = Instance.new("Part")
    telhado.Size = Vector3.new(tamanho.X + 2, 0.5, tamanho.Y + 2)
    telhado.Position = posicao + Vector3.new(0, 8.25, 0)
    telhado.Anchored = true
    telhado.CanCollide = true
    telhado.BrickColor = BrickColor.new(corTelhado)
    telhado.Material = Enum.Material.Wood
    telhado.Parent = casa
    
    -- Porta
    local porta = Instance.new("Part")
    porta.Size = Vector3.new(2, 3, 0.2)
    porta.Position = posicao + Vector3.new(0, 1.5, tamanho.Y/2 - 0.1)
    porta.Anchored = true
    porta.CanCollide = true
    porta.BrickColor = BrickColor.new("Brown")
    porta.Material = Enum.Material.Wood
    porta.Parent = casa
    
    casa.Parent = cidade
    return casa
end

local function criarEstrada(posicao, comprimento, largura, angulo)
    local estrada = Instance.new("Model")
    estrada.Name = "Estrada"
    
    local segmentos = math.ceil(comprimento / 10)
    
    for i = 1, segmentos do
        local segmento = Instance.new("Part")
        segmento.Size = Vector3.new(largura, 0.2, 10)
        segmento.Position = posicao + Vector3.new(0, 0.1, (i-0.5)*10 - comprimento/2)
        segmento.Anchored = true
        segmento.CanCollide = true
        segmento.BrickColor = BrickColor.new("Dark stone grey")
        segmento.Material = Enum.Material.Asphalt
        segmento.CFrame = CFrame.new(segmento.Position) * CFrame.Angles(0, angulo, 0)
        segmento.Parent = estrada
        
        -- Linhas divisórias
        if largura >= 8 then
            for lado = -1, 1, 2 do
                local linha = Instance.new("Part")
                linha.Size = Vector3.new(0.2, 0.21, 10)
                linha.Position = segmento.Position + segmento.CFrame.RightVector * (lado * largura/3)
                linha.Anchored = true
                linha.CanCollide = false
                linha.BrickColor = BrickColor.new("Institutional white")
                linha.Material = Enum.Material.Neon
                linha.CFrame = segmento.CFrame
                linha.Parent = estrada
            end
        end
    end
    
    estrada.Parent = cidade
    return estrada
end

-- ============================================
-- 3. CONSTRUIR CIDADE COMPLETA
-- ============================================

print("🏗️ Construindo ruas...")

-- Ruas principais (grade)
for x = -200, 200, 50 do
    criarEstrada(Vector3.new(x, 0.2, 0), 400, 12, 0)
end

for z = -200, 200, 50 do
    criarEstrada(Vector3.new(0, 0.2, z), 400, 12, math.rad(90))
end

print("🏠 Construindo bairro residencial...")

-- Bairro residencial (esquerda)
for x = -180, -60, 25 do
    for z = -180, 180, 30 do
        if math.random(1, 3) > 1 then
            local cor = math.random(1, 3) == 1 and "Red" or (math.random(1, 2) == 1 and "Dark green" or "Bright violet")
            criarCasa(Vector3.new(x, 0.5, z), Vector2.new(15, 20), cor)
        end
    end
end

-- Bairro residencial (direita)
for x = 60, 180, 25 do
    for z = -180, 180, 30 do
        if math.random(1, 3) > 1 then
            local cor = math.random(1, 3) == 1 and "Bright orange" or (math.random(1, 2) == 1 and "Bright yellow" or "Bright blue")
            criarCasa(Vector3.new(x, 0.5, z), Vector2.new(15, 20), cor)
        end
    end
end

print("🏢 Construindo centro comercial...")

-- Centro comercial
local prediosComerciais = {
    {pos = Vector3.new(-80, 0.5, -80), tam = Vector3.new(25, 50, 25), andares = 10, cor = "Light stone grey"},
    {pos = Vector3.new(-80, 0.5, 80), tam = Vector3.new(30, 60, 30), andares = 12, cor = "Medium stone grey"},
    {pos = Vector3.new(80, 0.5, -80), tam = Vector3.new(35, 70, 35), andares = 14, cor = "Dark stone grey"},
    {pos = Vector3.new(80, 0.5, 80), tam = Vector3.new(40, 80, 40), andares = 16, cor = "Black"},
}

for i, predio in ipairs(prediosComerciais) do
    criarPredio(predio.pos, predio.tam.X, predio.tam.Z, predio.tam.Y, predio.andares, predio.cor)
end

print("⛽ Construindo posto de gasolina...")

-- Posto de gasolina
local posto = Instance.new("Model")
posto.Name = "PostoGasolina"

local basePosto = Instance.new("Part")
basePosto.Size = Vector3.new(30, 0.2, 40)
basePosto.Position = Vector3.new(0, 0.1, 150)
basePosto.Anchored = true
basePosto.CanCollide = true
basePosto.BrickColor = BrickColor.new("Black")
basePosto.Material = Enum.Material.Asphalt
basePosto.Parent = posto

local loja = Instance.new("Part")
loja.Size = Vector3.new(15, 6, 12)
loja.Position = Vector3.new(0, 3, 160)
loja.Anchored = true
loja.CanCollide = true
loja.BrickColor = BrickColor.new("Bright yellow")
loja.Material = Enum.Material.Plastic
loja.Parent = posto

-- Bombas
for i = -1, 1, 2 do
    local bomba = Instance.new("Part")
    bomba.Size = Vector3.new(3, 4, 3)
    bomba.Position = Vector3.new(i * 8, 2, 140)
    bomba.Anchored = true
    bomba.CanCollide = true
    bomba.BrickColor = BrickColor.new("Bright red")
    bomba.Parent = posto
end

posto.Parent = cidade

print("🌳 Construindo parque...")

-- Parque central
local parque = Instance.new("Model")
parque.Name = "ParqueCentral"

local gramado = Instance.new("Part")
gramado.Size = Vector3.new(80, 0.2, 80)
gramado.Position = Vector3.new(-150, 0.1, 150)
gramado.Anchored = true
gramado.CanCollide = true
gramado.BrickColor = BrickColor.new("Bright green")
gramado.Material = Enum.Material.Grass
gramado.Parent = parque

-- Árvores no parque
for i = 1, 20 do
    local tronco = Instance.new("Part")
    tronco.Size = Vector3.new(2, 8, 2)
    tronco.Position = gramado.Position + Vector3.new(
        math.random(-35, 35),
        4,
        math.random(-35, 35)
    )
    tronco.Anchored = true
    tronco.CanCollide = true
    tronco.BrickColor = BrickColor.new("Brown")
    tronco.Material = Enum.Material.Wood
    tronco.Parent = parque
    
    local copa = Instance.new("Part")
    copa.Size = Vector3.new(8, 8, 8)
    copa.Shape = Enum.PartType.Ball
    copa.Position = tronco.Position + Vector3.new(0, 7, 0)
    copa.Anchored = true
    copa.CanCollide = true
    copa.BrickColor = BrickColor.new("Dark green")
    copa.Material = Enum.Material.Grass
    copa.Parent = parque
end

parque.Parent = cidade

print("🎯 Criando checkpoints...")

-- Checkpoints pela cidade
local checkpoints = {
    Vector3.new(0, 5, 0),     -- Centro
    Vector3.new(-150, 5, 0),  -- Oeste
    Vector3.new(150, 5, 0),   -- Leste
    Vector3.new(0, 5, -150),  -- Sul
    Vector3.new(0, 5, 150),   -- Norte
    Vector3.new(-150, 5, 150),-- Parque
    Vector3.new(150, 5, -150),-- Comercial
}

for i, pos in ipairs(checkpoints) do
    local checkpoint = Instance.new("Part")
    checkpoint.Name = "Checkpoint_"..i
    checkpoint.Size = Vector3.new(15, 15, 15)
    checkpoint.Position = pos
    checkpoint.Anchored = true
    checkpoint.CanCollide = false
    checkpoint.Transparency = 0.7
    checkpoint.BrickColor = BrickColor.new("Bright yellow")
    checkpoint.Material = Enum.Material.Neon
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 4, 0)
    billboard.StudsOffset = Vector3.new(0, 10, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = checkpoint
    
    local texto = Instance.new("TextLabel")
    texto.Size = UDim2.new(1, 0, 1, 0)
    texto.Text = "CP "..i
    texto.TextScaled = true
    texto.Font = Enum.Font.SciFi
    texto.TextColor3 = Color3.new(1, 1, 0)
    texto.BackgroundTransparency = 1
    texto.Parent = billboard
    
    billboard.Parent = checkpoint
    checkpoint.Parent = cidade
end

-- ============================================
-- 4. CRIAR MOTO
-- ============================================

print("🏍️ Criando moto...")

local function criarMoto()
    local moto = Instance.new("Model")
    moto.Name = "Moto_Player"
    
    -- Chassi
    local chassi = Instance.new("Part")
    chassi.Name = "Chassi"
    chassi.Size = Vector3.new(4, 1.5, 8)
    chassi.Position = Vector3.new(0, 3, 0)
    chassi.Anchored = false
    chassi.CanCollide = true
    chassi.BrickColor = BrickColor.new("Really black")
    chassi.Material = Enum.Material.Metal
    chassi.Parent = moto
    
    -- Assento
    local assento = Instance.new("Part")
    assento.Name = "Assento"
    assento.Size = Vector3.new(3, 0.8, 2.5)
    assento.Position = Vector3.new(0, 2, 0)
    assento.Anchored = false
    assento.CanCollide = true
    assento.BrickColor = BrickColor.new("Bright red")
    assento.Material = Enum.Material.Fabric
    
    local weldAssento = Instance.new("Weld")
    weldAssento.Part0 = chassi
    weldAssento.Part1 = assento
    weldAssento.C0 = CFrame.new(0, 0.5, 0)
    weldAssento.Parent = chassi
    
    assento.Parent = moto
    
    -- Rodas
    local function criarRoda(nome, posZ)
        local roda = Instance.new("Part")
        roda.Name = nome
        roda.Size = Vector3.new(2, 2, 2)
        roda.Position = Vector3.new(0, 2, posZ)
        roda.Shape = Enum.PartType.Cylinder
        roda.Anchored = false
        roda.CanCollide = true
        roda.BrickColor = BrickColor.new("Really black")
        roda.Material = Enum.Material.Metal
        
        local weld = Instance.new("Weld")
        weld.Part0 = chassi
        weld.Part1 = roda
        weld.C0 = CFrame.new(0, -1, posZ) * CFrame.Angles(0, 0, math.rad(90))
        weld.Parent = chassi
        
        roda.Parent = moto
        return roda
    end
    
    local rodaFrente = criarRoda("RodaFrente", 3.5)
    local rodaTras = criarRoda("RodaTras", -3.5)
    
    -- Guidão
    local guidao = Instance.new("Part")
    guidao.Name = "Guidão"
    guidao.Size = Vector3.new(1.5, 0.3, 0.3)
    guidao.Position = Vector3.new(0, 3.5, 2.5)
    guidao.Anchored = false
    guidao.CanCollide = false
    guidao.BrickColor = BrickColor.new("Really black")
    
    local weldGuidão = Instance.new("Weld")
    weldGuidão.Part0 = chassi
    weldGuidão.Part1 = guidao
    weldGuidão.C0 = CFrame.new(0, 1.5, 2.5)
    weldGuidão.Parent = chassi
    
    guidao.Parent = moto
    
    -- Faróis
    local farol = Instance.new("Part")
    farol.Name = "Farol"
    farol.Size = Vector3.new(0.5, 0.5, 0.5)
    farol.Position = Vector3.new(0, 2.5, 4)
    farol.Anchored = false
    farol.CanCollide = true
    farol.BrickColor = BrickColor.new("Bright yellow")
    farol.Material = Enum.Material.Neon
    
    local weldFarol = Instance.new("Weld")
    weldFarol.Part0 = chassi
    weldFarol.Part1 = farol
    weldFarol.C0 = CFrame.new(0, 0, 4)
    weldFarol.Parent = chassi
    
    farol.Parent = moto
    
    -- BodyGyro para estabilidade
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "Gyro"
    gyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    gyro.P = 1000
    gyro.D = 100
    gyro.Parent = chassi
    
    -- BodyVelocity para movimento
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "Velocity"
    bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = chassi
    
    moto.PrimaryPart = chassi
    moto:SetPrimaryPartCFrame(CFrame.new(0, 5, 0))
    
    return moto, chassi, bodyVelocity, gyro
end

-- Criar moto principal
local motoPrincipal, chassiPrincipal, velocityPrincipal, gyroPrincipal = criarMoto()
motoPrincipal.Parent = workspace

-- ============================================
-- 5. SISTEMA DE CONTROLES DINÂMICOS
-- ============================================

print("🎮 Configurando controles...")

-- Variáveis de controle
local controlesVisiveis = false
local velocidade = 0
local velocidadeMax = 100
local direcao = 0

-- Criar GUI (inicialmente invisível)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlesMoto"
screenGui.Enabled = false  -- INVISÍVEL no início
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame de fundo para controles
local frameControles = Instance.new("Frame")
frameControles.Name = "ControlesFrame"
frameControles.Size = UDim2.new(1, 0, 0.3, 0)
frameControles.Position = UDim2.new(0, 0, 0.7, 0)
frameControles.BackgroundColor3 = Color3.new(0, 0, 0)
frameControles.BackgroundTransparency = 0.5
frameControles.BorderSizePixel = 0
frameControles.Parent = screenGui

-- Botão Acelerar (direita superior)
local btnAcelerar = Instance.new("TextButton")
btnAcelerar.Name = "Acelerar"
btnAcelerar.Size = UDim2.new(0.2, 0, 0.25, 0)
btnAcelerar.Position = UDim2.new(0.75, 0, 0.05, 0)
btnAcelerar.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
btnAcelerar.Text = "⏫\nACELERAR"
btnAcelerar.TextScaled = true
btnAcelerar.Font = Enum.Font.SciFi
btnAcelerar.TextColor3 = Color3.new(1, 1, 1)
btnAcelerar.Parent = frameControles

-- Botão Frear (direita inferior)
local btnFrear = Instance.new("TextButton")
btnFrear.Name = "Frear"
btnFrear.Size = UDim2.new(0.2, 0, 0.25, 0)
btnFrear.Position = UDim2.new(0.75, 0, 0.35, 0)
btnFrear.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
btnFrear.Text = "⏬\nFREAR"
btnFrear.TextScaled = true
btnFrear.Font = Enum.Font.SciFi
btnFrear.TextColor3 = Color3.new(1, 1, 1)
btnFrear.Parent = frameControles

-- Botão Esquerda (esquerda)
local btnEsquerda = Instance.new("TextButton")
btnEsquerda.Name = "Esquerda"
btnEsquerda.Size = UDim2.new(0.2, 0, 0.5, 0)
btnEsquerda.Position = UDim2.new(0.05, 0, 0.05, 0)
btnEsquerda.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
btnEsquerda.Text = "◀\nESQUERDA"
btnEsquerda.TextScaled = true
btnEsquerda.Font = Enum.Font.SciFi
btnEsquerda.TextColor3 = Color3.new(1, 1, 1)
btnEsquerda.Parent = frameControles

-- Botão Direita (meio esquerda)
local btnDireita = Instance.new("TextButton")
btnDireita.Name = "Direita"
btnDireita.Size = UDim2.new(0.2, 0, 0.5, 0)
btnDireita.Position = UDim2.new(0.28, 0, 0.05, 0)
btnDireita.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
btnDireita.Text = "▶\nDIREITA"
btnDireita.TextScaled = true
btnDireita.Font = Enum.Font.SciFi
btnDireita.TextColor3 = Color3.new(1, 1, 1)
btnDireita.Parent = frameControles

-- Velocímetro
local frameVelocimetro = Instance.new("Frame")
frameVelocimetro.Name = "Velocimetro"
frameVelocimetro.Size = UDim2.new(0.25, 0, 0.2, 0)
frameVelocimetro.Position = UDim2.new(0.375, 0, 0.05, 0)
frameVelocimetro.BackgroundColor3 = Color3.new(0, 0, 0)
frameVelocimetro.BackgroundTransparency = 0.3
frameVelocimetro.Parent = frameControles

local textoVelocidade = Instance.new("TextLabel")
textoVelocidade.Name = "Texto"
textoVelocidade.Size = UDim2.new(1, 0, 0.6, 0)
textoVelocidade.Position = UDim2.new(0, 0, 0, 0)
textoVelocidade.Text = "0 km/h"
textoVelocidade.TextScaled = true
textoVelocidade.Font = Enum.Font.SciFi
textoVelocidade.TextColor3 = Color3.new(1, 1, 0)
textoVelocidade.BackgroundTransparency = 1
textoVelocidade.Parent = frameVelocimetro

local barraVelocidade = Instance.new("Frame")
barraVelocidade.Name = "Barra"
barraVelocidade.Size = UDim2.new(0, 0, 0.4, 0)
barraVelocidade.Position = UDim2.new(0, 0, 0.6, 0)
barraVelocidade.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
barraVelocidade.BorderSizePixel = 0
barraVelocidade.Parent = frameVelocimetro

-- Checkpoint display
local checkpointDisplay = Instance.new("TextLabel")
checkpointDisplay.Name = "CheckpointDisplay"
checkpointDisplay.Size = UDim2.new(0.4, 0, 0.15, 0)
checkpointDisplay.Position = UDim2.new(0.3, 0, 0.6, 0)
checkpointDisplay.Text = "CHECKPOINT: 0/"..#checkpoints
checkpointDisplay.TextScaled = true
checkpointDisplay.Font = Enum.Font.SciFi
checkpointDisplay.TextColor3 = Color3.new(1, 1, 0)
checkpointDisplay.BackgroundColor3 = Color3.new(0, 0, 0)
checkpointDisplay.BackgroundTransparency = 0.5
checkpointDisplay.Parent = frameControles

-- ============================================
-- 6. LÓGICA DE CONTROLES
-- ============================================

local inputs = {
    acelerar = false,
    frear = false,
    esquerda = false,
    direita = false
}

-- Configurar eventos dos botões
btnAcelerar.MouseButton1Down:Connect(function()
    inputs.acelerar = true
end)
btnAcelerar.MouseButton1Up:Connect(function()
    inputs.acelerar = false
end)

btnFrear.MouseButton1Down:Connect(function()
    inputs.frear = true
end)
btnFrear.MouseButton1Up:Connect(function()
    inputs.frear = false
end)

btnEsquerda.MouseButton1Down:Connect(function()
    inputs.esquerda = true
end)
btnEsquerda.MouseButton1Up:Connect(function()
    inputs.esquerda = false
end)

btnDireita.MouseButton1Down:Connect(function()
    inputs.direita = true
end)
btnDireita.MouseButton1Up:Connect(function()
    inputs.direita = false
end)

-- ============================================
-- 7. DETECTAR QUANDO MONTAR NA MOTO
-- ============================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoMontado = false

-- Função para mostrar/ocultar controles
local function mostrarControles(mostrar)
    screenGui.Enabled = mostrar
    controlesVisiveis = mostrar
    
    if mostrar then
        print("🎮 Controles da moto ATIVADOS")
        -- Posicionar câmera atrás da moto
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        workspace.CurrentCamera.CFrame = chassiPrincipal.CFrame * CFrame.new(0, 5, -10)
    else
        print("🎮 Controles da moto DESATIVADOS")
        -- Voltar câmera normal
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

-- Detectar quando o jogador tocar no assento da moto
local assento = motoPrincipal:WaitForChild("Assento")
assento.Touched:Connect(function(part)
    if part.Parent == character and not humanoMontado then
        humanoMontado = true
        mostrarControles(true)
        
        -- Teleportar jogador para cima da moto
        character.HumanoidRootPart.CFrame = chassiPrincipal.CFrame * CFrame.new(0, 3, 0)
        character.Humanoid.Sit = true
    end
end)

-- Detectar quando sair da moto
character.Humanoid.Seated:Connect(function(active, seat)
    if not active and humanoMontado then
        humanoMontado = false
        mostrarControles(false)
    end
end)

-- Botão para entrar na moto (fora dela)
local btnEntrarMoto = Instance.new("TextButton")
btnEntrarMoto.Name = "EntrarMoto"
btnEntrarMoto.Size = UDim2.new(0.2, 0, 0.1, 0)
btnEntrarMoto.Position = UDim2.new(0.4, 0, 0.9, 0)
btnEntrarMoto.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
btnEntrarMoto.Text = "🛵 ENTRAR NA MOTO"
btnEntrarMoto.TextScaled = true
btnEntrarMoto.Font = Enum.Font.SciFi
btnEntrarMoto.TextColor3 = Color3.new(1, 1, 1)
btnEntrarMoto.Visible = true
btnEntrarMoto.Parent = screenGui

btnEntrarMoto.MouseButton1Click:Connect(function()
    if not humanoMontado then
        humanoMontado = true
        mostrarControles(true)
        btnEntrarMoto.Visible = false
        
        character.HumanoidRootPart.CFrame = chassiPrincipal.CFrame * CFrame.new(0, 3, 0)
        character.Humanoid.Sit = true
    end
end)

-- ============================================
-- 8. SISTEMA DE CHECKPOINTS
-- ============================================

local checkpointAtual = 0

for i, checkpoint in ipairs(checkpoints) do
    local checkpointPart = cidade:FindFirstChild("Checkpoint_"..i)
    if checkpointPart then
        checkpointPart.Touched:Connect(function(part)
            if part.Parent == character and humanoMontado then
                if i == checkpointAtual + 1 then
                    checkpointAtual = i
                    checkpointDisplay.Text = "CHECKPOINT: "..checkpointAtual.."/"..#checkpoints
                    
                    -- Efeito visual
                    local tween = TweenService:Create(
                        checkpointPart,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BrickColor = BrickColor.new("Lime green")}
                    )
                    tween:Play()
                    
                    -- Completou todos?
                    if checkpointAtual == #checkpoints then
                        checkpointDisplay.Text = "🎉 MISSÃO COMPLETA! 🎉"
                        velocidadeMax = 120  -- Bônus de velocidade
                    end
                end
            end
        end)
    end
end

-- ============================================
-- 9. LOOP PRINCIPAL DO JOGO
-- ============================================

RunService.Heartbeat:Connect(function(deltaTime)
    if humanoMontado and controlesVisiveis then
        -- Controles de aceleração
        if inputs.acelerar and velocidade < velocidadeMax then
            velocidade = math.min(velocidade + 50 * deltaTime, velocidadeMax)
        elseif not inputs.acelerar and velocidade > 0 then
            velocidade = math.max(velocidade - 20 * deltaTime, 0)
        end
        
        if inputs.frear then
            velocidade = math.max(velocidade - 80 * deltaTime, -20)
        end
        
        -- Controles de direção
        direcao = 0
        if inputs.esquerda then
            direcao = -1
        elseif inputs.direita then
            direcao = 1
        end
        
        -- Aplicar movimento
        local forwardVector = chassiPrincipal.CFrame.LookVector
        local velocityVector = forwardVector * velocidade + Vector3.new(0, -10, 0)
        velocityPrincipal.Velocity = velocityVector
        
        -- Aplicar rotação
        if math.abs(velocidade) > 5 then
            local rotationSpeed = 2 * (velocidade / velocidadeMax) * direcao
            gyroPrincipal.CFrame = gyroPrincipal.CFrame * CFrame.Angles(0, rotationSpeed * deltaTime, 0)
        end
        
        -- Atualizar velocímetro
        local velocidadeKMH = math.floor(math.abs(velocidade) * 3.6)
        textoVelocidade.Text = velocidadeKMH .. " km/h"
        
        -- Atualizar barra de velocidade
        local porcentagem = math.abs(velocidade) / velocidadeMax
        barraVelocidade.Size = UDim2.new(porcentagem, 0, 0.4, 0)
        
        -- Mudar cor da barra
        if porcentagem < 0.5 then
            barraVelocidade.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif porcentagem < 0.8 then
            barraVelocidade.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            barraVelocidade.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        -- Manter jogador na moto
        if character and character.HumanoidRootPart then
            character.HumanoidRootPart.CFrame = chassiPrincipal.CFrame * CFrame.new(0, 3, 0)
        end
        
        -- Atualizar câmera
        workspace.CurrentCamera.CFrame = chassiPrincipal.CFrame * CFrame.new(0, 5, -10) * CFrame.Angles(0, math.rad(180), 0)
    end
end)

-- ============================================
-- 10. TECLAS DE ATALHO
-- ============================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E and not humanoMontado then
        -- Tecla E para entrar na moto
        humanoMontado = true
        mostrarControles(true)
        btnEntrarMoto.Visible = false
        
        character.HumanoidRootPart.CFrame = chassiPrincipal.CFrame * CFrame.new(0, 3, 0)
        character.Humanoid.Sit = true
        
    elseif input.KeyCode == Enum.KeyCode.F and humanoMontado then
        -- Tecla F para sair da moto
        humanoMontado = false
        mostrarControles(false)
        btnEntrarMoto.Visible = true
        character.Humanoid.Sit = false
        character.HumanoidRootPart.CFrame = chassiPrincipal.CFrame * CFrame.new(5, 0, 0)
        
    elseif input.KeyCode == Enum.KeyCode.Space and humanoMontado and velocidade > 30 then
        -- Turbo com espaço
        velocidade = math.min(velocidade + 30, velocidadeMax + 20)
    end
end)

-- ============================================
-- 11. MENSAGEM FINAL
-- ============================================

print("\n" .. string.rep("=", 60))
print("🏙️  CIDADE DE MOTOS CONSTRUÍDA COM SUCESSO!")
print(string.rep("=", 60))
print("📍 Localização: Sua frente")
print("🏍️  Moto disponível para uso")
print("🎮 Controles aparecem SOMENTE quando montado na moto")
print("🎯 Objetivo: Complete todos os "..#checkpoints.." checkpoints")
print("\n📋 COMANDOS:")
print("  🛵 Clique no botão 'ENTRAR NA MOTO'")
print("  🔑 Ou pressione E próximo à moto")
print("  🚪 Pressione F para sair da moto")
print("  💥 Espaço para turbo (em alta velocidade)")
print(string.rep("=", 60))
print("✅ Sistema pronto! Boa corrida pela cidade! 🏍️💨")

-- Posicionar jogador perto da moto
wait(1)
if character and character:FindFirstChild("HumanoidRootPart") then
    character.HumanoidRootPart.CFrame = chassiPrincipal.CFrame * CFrame.new(5, 0, -5)
    btnEntrarMoto.Visible = true
end

-- Efeito de luz na cidade
local luzCidade = Instance.new("PointLight")
luzCidade.Brightness = 0.5
luzCidade.Range = 100
luzCidade.Color = Color3.fromRGB(255, 255, 200)
luzCidade.Parent = workspace.Terrain

print("✨ Iluminação da cidade ativada!")
print("🌆 Aproveite sua corrida urbana! 🏙️🏍️")
