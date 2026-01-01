local Jogadores = game:GetService("Players")
local LocalPlayer = Jogadores.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==================== SISTEMA BYPASS ====================
local BypassSystem = {
    Enabled = true,
    SafeMode = false,
    LastAction = tick(),
    ActionCount = 0,
    RandomSeed = math.random(1, 9999),
}

local function getRandomDelay(min, max)
    math.randomseed((tick() * 1000) % 100000 + BypassSystem.RandomSeed)
    return math.random(min * 1000, max * 1000) / 1000
end

local function humanWait(seconds)
    local variedTime = seconds * getRandomDelay(0.9, 1.1)
    task.wait(variedTime)
end

local function canPerformAction()
    local now = tick()
    if BypassSystem.SafeMode then return false end
    if now - BypassSystem.LastAction < 1.5 then return false end
    if BypassSystem.ActionCount >= 3 then
        BypassSystem.ActionCount = 0
        humanWait(getRandomDelay(2.0, 3.0))
        return false
    end
    return true
end

local function protectedAction(actionFunc)
    if not BypassSystem.Enabled or not canPerformAction() then 
        return false 
    end
    
    humanWait(getRandomDelay(0.1, 0.3))
    BypassSystem.ActionCount = BypassSystem.ActionCount + 1
    
    local success, result = pcall(actionFunc)
    BypassSystem.LastAction = tick()
    
    if success then
        humanWait(getRandomDelay(0.15, 0.25))
    end
    
    return success, result
end

local function protectedFireRemote(remote, ...)
    if not remote or not remote:IsA("RemoteEvent") then return false end
    return protectedAction(function()
        remote:FireServer(...)
    end)
end

local function protectedHeartbeat(callback)
    return RunService.Heartbeat:Connect(function()
        if BypassSystem.Enabled and not BypassSystem.SafeMode then
            protectedAction(callback)
        end
    end)
end


local guiPrincipal = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
guiPrincipal.Name = "InterfacePrincipal"
guiPrincipal.ResetOnSpawn = false

local COR_FUNDO = Color3.fromRGB(0, 0, 0)
local COR_BORDA = Color3.fromRGB(139, 0, 0)
local COR_BOTAO_DESATIVADO = Color3.fromRGB(60, 60, 60)
local COR_BOTAO_ATIVO = Color3.fromRGB(220, 0, 0)
local COR_TEXTO = Color3.fromRGB(255, 255, 255)
local COR_ROSADO = Color3.fromRGB(255, 105, 180)

local LARGURA_PAINEL = 200
local ALTURA_PAINEL = 240
local ALTURA_TITULO = 30
local MARGEM = 7
local TOPO = 1
local RODAPE = 10
local ESPACO = 6

local painelPrincipal = Instance.new("Frame", guiPrincipal)
painelPrincipal.Size = UDim2.new(0, LARGURA_PAINEL, 0, ALTURA_PAINEL)
painelPrincipal.Position = UDim2.new(0.5, -LARGURA_PAINEL/2, 0.5, -ALTURA_PAINEL/2)
painelPrincipal.BackgroundColor3 = COR_FUNDO
painelPrincipal.BackgroundTransparency = 0.4
painelPrincipal.Active = true
painelPrincipal.Draggable = true
painelPrincipal.Visible = false

Instance.new("UICorner", painelPrincipal).CornerRadius = UDim.new(0, 15)

local tituloPrincipal = Instance.new("TextLabel", painelPrincipal)
tituloPrincipal.Size = UDim2.new(1, 0, 0, ALTURA_TITULO)
tituloPrincipal.Text = "GOKU BLACK HUB"
tituloPrincipal.TextSize = 16
tituloPrincipal.Font = Enum.Font.Arcade
tituloPrincipal.TextColor3 = COR_ROSADO
tituloPrincipal.TextXAlignment = Enum.TextXAlignment.Center
tituloPrincipal.BackgroundTransparency = 1

-- Botão flutuante com imagem redonda - NOVA IMAGEM
local botaoFlutuante = Instance.new("ImageButton", guiPrincipal)
botaoFlutuante.Size = UDim2.new(0, 58, 0, 58)
botaoFlutuante.Position = UDim2.new(0, 10, 0.5, -29)
botaoFlutuante.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
botaoFlutuante.BackgroundTransparency = 0
botaoFlutuante.Image = "rbxassetid://105722429865"
botaoFlutuante.ImageColor3 = Color3.fromRGB(255, 255, 255)
botaoFlutuante.ScaleType = Enum.ScaleType.Fit
botaoFlutuante.Active = true
botaoFlutuante.Draggable = true

-- Sistema de fallback para caso a imagem não carregue
spawn(function()
    wait(1)
    if botaoFlutuante.Image == "" then
        print("Imagem não carregou, configurando fallback...")
        botaoFlutuante.Image = ""
        local fallbackLabel = Instance.new("TextLabel", botaoFlutuante)
        fallbackLabel.Size = UDim2.new(1, 0, 1, 0)
        fallbackLabel.Text = "⚫"
        fallbackLabel.TextSize = 32
        fallbackLabel.Font = Enum.Font.GothamBlack
        fallbackLabel.TextColor3 = COR_BOTAO_ATIVO
        fallbackLabel.BackgroundTransparency = 1
    else
        print("Imagem carregada com sucesso!")
    end
end)

-- Criar um frame container para melhor controle da imagem
local containerImagem = Instance.new("Frame", botaoFlutuante)
containerImagem.Size = UDim2.new(1, -4, 1, -4)
containerImagem.Position = UDim2.new(0, 2, 0, 2)
containerImagem.BackgroundTransparency = 1

local imagemPrincipal = Instance.new("ImageLabel", containerImagem)
imagemPrincipal.Size = UDim2.new(1, 0, 1, 0)
imagemPrincipal.Position = UDim2.new(0, 0, 0, 0)
imagemPrincipal.BackgroundTransparency = 1
imagemPrincipal.Image = "rbxassetid://105722429865"
imagemPrincipal.ImageColor3 = Color3.fromRGB(255, 255, 255)
imagemPrincipal.ScaleType = Enum.ScaleType.Fit

local cornerContainer = Instance.new("UICorner", containerImagem)
cornerContainer.CornerRadius = UDim.new(1, 0)

local cornerBotao = Instance.new("UICorner", botaoFlutuante)
cornerBotao.CornerRadius = UDim.new(1, 0)

local bordaVermelha = Instance.new("UIStroke", botaoFlutuante)
bordaVermelha.Color = COR_BOTAO_ATIVO
bordaVermelha.Thickness = 2.5
bordaVermelha.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local sombra = Instance.new("UIGradient", containerImagem)
sombra.Rotation = 90
sombra.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.3, 0.2),
    NumberSequenceKeypoint.new(0.7, 0.2),
    NumberSequenceKeypoint.new(1, 0.8)
})

-- Efeitos de interação
botaoFlutuante.MouseEnter:Connect(function()
    bordaVermelha.Thickness = 3.5
    botaoFlutuante.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    imagemPrincipal.ImageColor3 = Color3.fromRGB(255, 220, 220)
    botaoFlutuante.ImageColor3 = Color3.fromRGB(255, 220, 220)
end)

botaoFlutuante.MouseLeave:Connect(function()
    bordaVermelha.Thickness = 2.5
    botaoFlutuante.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    imagemPrincipal.ImageColor3 = Color3.fromRGB(255, 255, 255)
    botaoFlutuante.ImageColor3 = Color3.fromRGB(255, 255, 255)
end)

botaoFlutuante.MouseButton1Down:Connect(function()
    botaoFlutuante.Size = UDim2.new(0, 54, 0, 54)
    botaoFlutuante.Position = UDim2.new(0, 12, 0.5, -27)
    containerImagem.Size = UDim2.new(1, -2, 1, -2)
    containerImagem.Position = UDim2.new(0, 1, 0, 1)
end)

botaoFlutuante.MouseButton1Up:Connect(function()
    botaoFlutuante.Size = UDim2.new(0, 58, 0, 58)
    botaoFlutuante.Position = UDim2.new(0, 10, 0.5, -29)
    containerImagem.Size = UDim2.new(1, -4, 1, -4)
    containerImagem.Position = UDim2.new(0, 2, 0, 2)
end)

botaoFlutuante.MouseButton1Click:Connect(function()
    painelPrincipal.Visible = not painelPrincipal.Visible
end)

-- ==================== FUNÇÕES DOS BOTÕES DO PAINEL PRINCIPAL ====================
local function criarBotao(y, texto, altura, funcao)
    local botao = Instance.new("TextButton", painelPrincipal)
    botao.Size = UDim2.new(1, -(MARGEM*2), 0, altura)
    botao.Position = UDim2.new(0, MARGEM, 0, y)
    botao.BackgroundColor3 = COR_BOTAO_DESATIVADO
    botao.Text = texto or ""
    botao.TextSize = 14
    botao.Font = Enum.Font.Arcade
    botao.TextColor3 = COR_TEXTO
    botao.TextYAlignment = Enum.TextYAlignment.Center
    botao.BorderSizePixel = 0
    
    Instance.new("UICorner", botao).CornerRadius = UDim.new(0,9)
    
    local borda = Instance.new("UIStroke", botao)
    borda.Color = COR_BORDA
    borda.Thickness = 1.2
    borda.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local ativo = false
    botao.MouseButton1Click:Connect(function()
        ativo = not ativo
        botao.BackgroundColor3 = ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        if funcao then funcao(botao) end
    end)
end

local function criarParBotoes(y, texto1, texto2, altura)
    local metadeLargura = math.floor((LARGURA_PAINEL - (MARGEM*2 + ESPACO)) / 2)
    
    local function criarBotaoUnico(x, texto)
        local botao = Instance.new("TextButton", painelPrincipal)
        botao.Size = UDim2.new(0, metadeLargura, 0, altura)
        botao.Position = UDim2.new(0, x, 0, y)
        botao.BackgroundColor3 = COR_BOTAO_DESATIVADO
        botao.Text = texto or ""
        botao.TextSize = 14
        botao.Font = Enum.Font.Arcade
        botao.TextColor3 = COR_TEXTO
        botao.TextYAlignment = Enum.TextYAlignment.Center
        botao.BorderSizePixel = 0
        
        Instance.new("UICorner", botao).CornerRadius = UDim.new(0,9)
        
        local borda = Instance.new("UIStroke", botao)
        borda.Color = COR_BORDA
        borda.Thickness = 1.2
        borda.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local ativo = false
        botao.MouseButton1Click:Connect(function()
            ativo = not ativo
            botao.BackgroundColor3 = ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        end)
    end
    
    criarBotaoUnico(MARGEM, texto1)
    criarBotaoUnico(MARGEM + metadeLargura + ESPACO, texto2)
end

local function criarPrimeiraLinhaBotoes(y, altura)
    local tercoLargura = math.floor((LARGURA_PAINEL - (MARGEM*2 + ESPACO*2)) / 3)
    local paresBotoes = {
        {"ESP", "BEST"},
        {"ESP", "PLAYER"},
        {"ESP", "BASE"}
    }
    
    for i, par in ipairs(paresBotoes) do
        local botao = Instance.new("TextButton", painelPrincipal)
        botao.Size = UDim2.new(0, tercoLargura, 0, altura)
        botao.Position = UDim2.new(0, MARGEM + (tercoLargura+ESPACO)*(i-1), 0, y)
        botao.BackgroundColor3 = COR_BOTAO_DESATIVADO
        botao.Text = par[1] .. "\n" .. par[2]
        botao.TextSize = 12
        botao.Font = Enum.Font.Arcade
        botao.TextColor3 = COR_TEXTO
        botao.TextYAlignment = Enum.TextYAlignment.Center
        botao.BorderSizePixel = 0
        botao.TextWrapped = true
        
        Instance.new("UICorner", botao).CornerRadius = UDim.new(0,9)
        
        local borda = Instance.new("UIStroke", botao)
        borda.Color = COR_BORDA
        borda.Thickness = 1.2
        borda.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local ativo = false
        botao.MouseButton1Click:Connect(function()
            ativo = not ativo
            botao.BackgroundColor3 = ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        end)
    end
end

local posicaoY = ALTURA_TITULO + TOPO
local alturaDisponivel = ALTURA_PAINEL - ALTURA_TITULO - TOPO - RODAPE
local alturaLinha = math.floor((alturaDisponivel - ESPACO*5) / 6)

criarPrimeiraLinhaBotoes(posicaoY, alturaLinha)
posicaoY = posicaoY + alturaLinha + ESPACO

criarParBotoes(posicaoY, "X-RAY", "FPS BOOST", alturaLinha)
posicaoY = posicaoY + alturaLinha + ESPACO

criarParBotoes(posicaoY, "UNWALK", "HIDE SKIN", alturaLinha)
posicaoY = posicaoY + alturaLinha + ESPACO

local botaoMenuLateral = Instance.new("TextButton", painelPrincipal)
botaoMenuLateral.Size = UDim2.new(1, -(MARGEM*2), 0, alturaLinha)
botaoMenuLateral.Position = UDim2.new(0, MARGEM, 0, posicaoY)
botaoMenuLateral.BackgroundColor3 = COR_BOTAO_DESATIVADO
botaoMenuLateral.Text = "MENU LATERAL"
botaoMenuLateral.TextSize = 14
botaoMenuLateral.Font = Enum.Font.Arcade
botaoMenuLateral.TextColor3 = COR_TEXTO
botaoMenuLateral.TextYAlignment = Enum.TextYAlignment.Center
botaoMenuLateral.BorderSizePixel = 0

Instance.new("UICorner", botaoMenuLateral).CornerRadius = UDim.new(0,9)

local bordaMenu = Instance.new("UIStroke", botaoMenuLateral)
bordaMenu.Color = COR_BORDA
bordaMenu.Thickness = 1.2
bordaMenu.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

posicaoY = posicaoY + alturaLinha + ESPACO

criarParBotoes(posicaoY, "ANTI RAGDOLL", "AUTO KICK", alturaLinha)
posicaoY = posicaoY + alturaLinha + ESPACO

criarParBotoes(posicaoY, "NEREAST", "ANTI DEBUFF", alturaLinha)

-- ==================== GUI LATERAL ====================
local guiLateral = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
guiLateral.Name = "InterfaceLateral"
guiLateral.ResetOnSpawn = false

local LARGURA_LATERAL = 150
local ALTURA_LATERAL = 220
local ALTURA_TITULO_LATERAL = 26
local MARGEM_LATERAL = 7
local TOPO_LATERAL = 1
local RODAPE_LATERAL = 10
local ESPACO_LATERAL = 6
local COR_SETA = Color3.fromRGB(85, 0, 0)

local painelLateral = Instance.new("Frame", guiLateral)
painelLateral.Size = UDim2.new(0, LARGURA_LATERAL, 0, ALTURA_LATERAL)
painelLateral.Position = UDim2.new(1, -LARGURA_LATERAL - 10, 0.5, -ALTURA_LATERAL/2)
painelLateral.BackgroundColor3 = COR_FUNDO
painelLateral.BackgroundTransparency = 0.4
painelLateral.Active = true
painelLateral.Draggable = true
painelLateral.Visible = false

Instance.new("UICorner", painelLateral).CornerRadius = UDim.new(0, 15)

local tituloLateral = Instance.new("TextLabel", painelLateral)
tituloLateral.Size = UDim2.new(1, -30, 0, ALTURA_TITULO_LATERAL)
tituloLateral.Position = UDim2.new(0, 35, 0, 2)
tituloLateral.Text = "GOKU BLACK V2"
tituloLateral.TextSize = 14
tituloLateral.Font = Enum.Font.Arcade
tituloLateral.TextColor3 = COR_ROSADO
tituloLateral.TextXAlignment = Enum.TextXAlignment.Left
tituloLateral.BackgroundTransparency = 1

local iconeBolinha = Instance.new("ImageLabel", painelLateral)
iconeBolinha.Size = UDim2.new(0, 20, 0, 20)
iconeBolinha.Position = UDim2.new(0, 6, 0, 3)
iconeBolinha.BackgroundTransparency = 1
iconeBolinha.Image = "rbxassetid://105722429865"
iconeBolinha.ImageColor3 = COR_BOTAO_ATIVO
iconeBolinha.ScaleType = Enum.ScaleType.Fit

local bordaIcone = Instance.new("UIStroke", iconeBolinha)
bordaIcone.Color = COR_BOTAO_ATIVO
bordaIcone.Thickness = 1.5
bordaIcone.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

Instance.new("UICorner", iconeBolinha).CornerRadius = UDim.new(1, 0)

-- ==================== FUNÇÃO ATUALIZADA PARA BOTÕES LATERAIS ====================
local function criarBotaoLateral(y, informacao)
    local container = Instance.new("Frame", painelLateral)
    container.Size = UDim2.new(1, -(MARGEM_LATERAL*2), 0, informacao.altura)
    container.Position = UDim2.new(0, MARGEM_LATERAL, 0, y)
    container.BackgroundTransparency = 1
    
    local botao = Instance.new("TextButton", container)
    botao.Size = informacao.temSeta and UDim2.new(0.75, -4, 1, 0) or UDim2.new(1, 0, 1, 0)
    botao.Position = UDim2.new(0, 0, 0, 0)
    botao.BackgroundColor3 = COR_BOTAO_DESATIVADO
    botao.Text = informacao.nome1
    botao.TextSize = 14
    botao.Font = Enum.Font.Arcade
    botao.TextColor3 = COR_TEXTO
    botao.TextYAlignment = Enum.TextYAlignment.Center
    botao.BorderSizePixel = 0
    
    Instance.new("UICorner", botao).CornerRadius = UDim.new(0,9)
    
    local borda = Instance.new("UIStroke", botao)
    borda.Color = COR_BORDA
    borda.Thickness = 1.2
    borda.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local callbackPersonalizado = informacao.callback
    
    botao.MouseButton1Click:Connect(function()
        if callbackPersonalizado then
            callbackPersonalizado(botao)
        else
            local ativo = botao.BackgroundColor3 == COR_BOTAO_ATIVO
            botao.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        end
    end)
    
    if informacao.temSeta then
        local seta = Instance.new("TextButton", container)
        seta.Size = UDim2.new(0.25, -4, 1, 0)
        seta.Position = UDim2.new(0.75, 4, 0, 0)
        seta.BackgroundColor3 = COR_SETA
        seta.Text = "⇄"
        seta.Font = Enum.Font.Arcade
        seta.TextSize = 15
        seta.TextColor3 = COR_TEXTO
        seta.TextYAlignment = Enum.TextYAlignment.Center
        seta.BorderSizePixel = 0
        
        Instance.new("UICorner", seta).CornerRadius = UDim.new(0,9)
        
        local bordaSeta = Instance.new("UIStroke", seta)
        bordaSeta.Color = COR_BORDA
        bordaSeta.Thickness = 1.2
        bordaSeta.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local modo = 1
        seta.MouseButton1Click:Connect(function()
            modo = (modo == 1 and 2 or 1)
            botao.Text = (modo == 1) and informacao.nome1 or informacao.nome2
            botao.BackgroundColor3 = COR_BOTAO_DESATIVADO
        end)
    end
    
    return botao
end

local function criarParBotoesLateral(y, informacao1, informacao2, altura)
    local metadeLargura = math.floor((LARGURA_LATERAL - (MARGEM_LATERAL*2 + ESPACO_LATERAL)) / 2)
    
    local function criarBotaoUnico(x, informacao)
        local botao = Instance.new("TextButton", painelLateral)
        botao.Size = UDim2.new(0, metadeLargura, 0, altura)
        botao.Position = UDim2.new(0, x, 0, y)
        botao.BackgroundColor3 = COR_BOTAO_DESATIVADO
        botao.Text = informacao.nome1
        botao.TextSize = 12
        botao.Font = Enum.Font.Arcade
        botao.TextColor3 = COR_TEXTO
        botao.TextYAlignment = Enum.TextYAlignment.Center
        botao.BorderSizePixel = 0
        
        Instance.new("UICorner", botao).CornerRadius = UDim.new(0,9)
        
        local borda = Instance.new("UIStroke", botao)
        borda.Color = COR_BORDA
        borda.Thickness = 1.2
        borda.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        if informacao.callback then
            botao.MouseButton1Click:Connect(function()
                informacao.callback(botao)
            end)
        else
            local ativo = false
            botao.MouseButton1Click:Connect(function()
                ativo = not ativo
                botao.BackgroundColor3 = ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
            end)
        end
    end
    
    criarBotaoUnico(MARGEM_LATERAL, informacao1)
    criarBotaoUnico(MARGEM_LATERAL + metadeLargura + ESPACO_LATERAL, informacao2)
end

local posicaoYLateral = ALTURA_TITULO_LATERAL + TOPO_LATERAL
local alturaDisponivelLateral = ALTURA_LATERAL - ALTURA_TITULO_LATERAL - TOPO_LATERAL - RODAPE_LATERAL
local alturaLinhaLateral = math.floor((alturaDisponivelLateral - ESPACO_LATERAL*4) / 5)

-- ==================== SISTEMA NEAREST STEAL ====================
local NearestStealSystem = {}
NearestStealSystem.Enabled = false
NearestStealSystem.ScanTask = nil

local S = {
    Players = Jogadores,
    ReplicatedStorage = ReplicatedStorage,
    RunService = RunService,
    LocalPlayer = LocalPlayer
}

local Packages = S.ReplicatedStorage:WaitForChild("Packages", 5)
local Datas = S.ReplicatedStorage:WaitForChild("Datas", 5)
local Shared = S.ReplicatedStorage:WaitForChild("Shared", 5)
local Utils = S.ReplicatedStorage:WaitForChild("Utils", 5)

local Synchronizer = nil
local ok, syncModule = pcall(require, Packages and Packages:FindFirstChild("Synchronizer"))
if ok and syncModule then Synchronizer = syncModule end

local AnimalsData = nil
local ok2, dataModule = pcall(require, Datas and Datas:FindFirstChild("Animals"))
if ok2 and dataModule then AnimalsData = dataModule end

local AnimalsShared = nil
local ok3, sharedModule = pcall(require, Shared and Shared:FindFirstChild("Animals"))
if ok3 and sharedModule then AnimalsShared = sharedModule end

local CONFIG = {
    AUTO_STEAL_NEAREST_ENABLED = false
}

local allAnimalsCache = {}
local PromptMemoryCache = {}
local InternalStealCache = {}
local stealConnection = nil
local AUTO_STEAL_PROX_RADIUS = 20

if not AnimalsShared or not AnimalsShared.GetGeneration then
    AnimalsShared = {
        GetGeneration = function()
            return 1
        end
    }
end

local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot then return false end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    if Synchronizer then
        local channel = Synchronizer:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            if owner then
                local ownerUserId = nil
                if typeof(owner) == "Instance" and owner:IsA("Player") then
                    ownerUserId = owner.UserId
                elseif typeof(owner) == "table" and owner.UserId then
                    ownerUserId = owner.UserId
                end
                if ownerUserId then
                    return ownerUserId == S.LocalPlayer.UserId
                end
                if typeof(owner) == "Instance" then
                    return owner == S.LocalPlayer
                end
            end
        end
    end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cachedPrompt = PromptMemoryCache[animalData.uid]
    if cachedPrompt and cachedPrompt.Parent then
        return cachedPrompt
    end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

local function getAnimalPosition(animalData)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    if podium:IsA("Model") then
        return podium:GetPivot().Position
    elseif podium:IsA("BasePart") then
        return podium.Position
    end
    return nil
end

local function getNearestAnimal()
    local character = S.LocalPlayer.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest = nil
    local minDist = math.huge
    for _, animalData in ipairs(allAnimalsCache) do
        if isMyBaseAnimal(animalData) then
            continue
        end
        local pos = getAnimalPosition(animalData)
        if pos then
            local dist = (hrp.Position - pos).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = animalData
            end
        end
    end
    return nearest
end

local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = {
        holdCallbacks = {},
        triggerCallbacks = {},
        ready = true
    }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
        InternalStealCache[prompt] = data
    end
end

local function executeInternalStealAsync(prompt)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    task.spawn(function()
        if #data.holdCallbacks > 0 then
            for _, fn in ipairs(data.holdCallbacks) do
                task.spawn(fn)
            end
        end
        task.wait(1.3)
        if #data.triggerCallbacks > 0 then
            for _, fn in ipairs(data.triggerCallbacks) do
                task.spawn(fn)
            end
        end
        task.wait(0.1)
        data.ready = true
    end)
    return true
end

local function attemptSteal(prompt)
    if not prompt or not prompt.Parent then
        return false
    end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then
        return false
    end
    return executeInternalStealAsync(prompt)
end

local function scanAllPlots()
    if not Synchronizer or not AnimalsData then
        return 0
    end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return 0 end
    local newCache = {}
    for _, plot in ipairs(plots:GetChildren()) do
        local channel = Synchronizer:Get(plot.Name)
        if not channel then continue end
        local animalList = channel:Get("AnimalList")
        if not animalList then continue end
        local owner = channel:Get("Owner")
        if not owner then continue end
        local ownerName = "Unknown"
        if typeof(owner) == "Instance" and owner:IsA("Player") then
            ownerName = owner.Name
        elseif typeof(owner) == "table" and owner.Name then
            ownerName = owner.Name
        end
        for slot, animalData in pairs(animalList) do
            if type(animalData) == "table" then
                local animalName = animalData.Index
                local animalInfo = AnimalsData[animalName]
                if not animalInfo then continue end
                local genValue = AnimalsShared:GetGeneration(
                    animalName,
                    animalData.Mutation,
                    animalData.Traits,
                    nil
                )
                table.insert(newCache, {
                    name = animalInfo.DisplayName or animalName,
                    genValue = genValue,
                    mutation = animalData.Mutation or "None",
                    traits = (animalData.Traits and #animalData.Traits > 0)
                        and table.concat(animalData.Traits, ", ")
                        or "None",
                    owner = ownerName,
                    plot = plot.Name,
                    slot = tostring(slot),
                    uid = plot.Name .. "_" .. tostring(slot)
                })
            end
        end
    end
    allAnimalsCache = newCache
    table.sort(allAnimalsCache, function(a, b)
        return a.genValue > b.genValue
    end)
    return #allAnimalsCache
end

local function startAutoSteal()
    if stealConnection then return end
    stealConnection = S.RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_NEAREST_ENABLED then return end
        local targetAnimal = getNearestAnimal()
        if not targetAnimal then return end
        local character = S.LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local animalPos = getAnimalPosition(targetAnimal)
        if not animalPos then return end
        local dist = (hrp.Position - animalPos).Magnitude
        if dist > AUTO_STEAL_PROX_RADIUS then return end
        local prompt = PromptMemoryCache[targetAnimal.uid]
        if not prompt or not prompt.Parent then
            prompt = findProximityPromptForAnimal(targetAnimal)
        end
        if prompt then
            attemptSteal(prompt)
        end
    end)
end

function NearestStealSystem:Start()
    if self.Enabled then return end
    self.Enabled = true
    CONFIG.AUTO_STEAL_NEAREST_ENABLED = true
    if not self.ScanTask then
        self.ScanTask = task.spawn(function()
            while NearestStealSystem.Enabled do
                scanAllPlots()
                task.wait(5)
            end
        end)
    end
    scanAllPlots()
    startAutoSteal()
end

function NearestStealSystem:Stop()
    if not self.Enabled then return end
    self.Enabled = false
    CONFIG.AUTO_STEAL_NEAREST_ENABLED = false
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
    if self.ScanTask then
        task.cancel(self.ScanTask)
        self.ScanTask = nil
    end
    table.clear(allAnimalsCache)
    table.clear(PromptMemoryCache)
    table.clear(InternalStealCache)
end

-- ==================== GO TO BEST HUB ====================
local GoToBestHub = {
    Enabled = false,
    Connections = {},
    currentBestPet = nil,
    isStopping = false,
}

function GoToBestHub:extractValue(text)
    if not text then return 0 end
    local clean = text:gsub("[%$,/s]", ""):gsub(",", "")
    local mult = 1
    if clean:match("[kK]") then mult = 1e3 clean = clean:gsub("[kK]", "") end
    if clean:match("[mM]") then mult = 1e6 clean = clean:gsub("[mM]", "") end
    if clean:match("[bB]") then mult = 1e9 clean = clean:gsub("[bB]", "") end
    if clean:match("[tT]") then mult = 1e12 clean = clean:gsub("[tT]", "") end
    local num = tonumber(clean)
    return num and num * mult or 0
end

local function findBestBrainrotData()
    if GoToBestHub.isStopping then return nil end
    local allPets = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if GoToBestHub.isStopping then break end
        if obj.Name == "AnimalOverhead" then
            local petValue = 0
            local petName = "Brainrot"
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("TextLabel") then
                    local text = child.Text
                    if text and text:find("$") and text:find("/s") then
                        petValue = GoToBestHub:extractValue(text)
                    end
                    if child.Name == "DisplayName" and text ~= "" then
                        petName = text
                    end
                end
            end
            local position = nil
            local current = obj.Parent
            while current and current ~= Workspace do
                if current:IsA("BasePart") then
                    position = current.Position + Vector3.new(0, 5, 0)
                    break
                end
                current = current.Parent
            end
            if position and petValue > 0 then
                table.insert(allPets, {
                    position = position,
                    name = petName,
                    value = petValue
                })
            end
        end
    end
    if #allPets > 0 and not GoToBestHub.isStopping then
        table.sort(allPets, function(a, b) return a.value > b.value end)
        return allPets[1]
    end
    return nil
end

function GoToBestHub:equipGrappleHook()
    if self.isStopping then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    local grappleHook = backpack:FindFirstChild("Grapple Hook") or char:FindFirstChild("Grapple Hook")
    if not grappleHook then return nil end
    if grappleHook.Parent == backpack then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(grappleHook)
        end
    end
    return grappleHook
end

function GoToBestHub:spamGrappleHook()
    if self.isStopping then return end
    local REUseItem = ReplicatedStorage:FindFirstChild("Packages")
    if REUseItem then
        REUseItem = REUseItem:FindFirstChild("Net")
        if REUseItem then
            REUseItem = REUseItem:FindFirstChild("RE/UseItem")
            if REUseItem then
                pcall(function()
                    REUseItem:FireServer(0.23450689315795897)
                end)
            end
        end
    end
end

function GoToBestHub:flyToPosition(targetPos, speed)
    if self.isStopping then return 0 end
    local char = LocalPlayer.Character
    if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    local direction = (targetPos - hrp.Position).Unit
    hrp.AssemblyLinearVelocity = direction * speed
    local distance = (hrp.Position - targetPos).Magnitude
    return distance
end

function GoToBestHub:stabilizePlayer()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

-- ==================== TP TO BEST SYSTEM ====================
local TpToBestSystem = {}
TpToBestSystem.Enabled = false
TpToBestSystem.Connections = {}
TpToBestSystem.isStopping = false
TpToBestSystem.hasReachedHeight = false
TpToBestSystem.targetHeight = nil
TpToBestSystem.currentBestPet = nil
TpToBestSystem.lastEquipTime = 0
TpToBestSystem.lastSpamTime = 0
TpToBestSystem.lastScanTime = 0
TpToBestSystem.baseCoordinates = {
    ["Base 1"] = Vector3.new(-479.5, 13.4, -103.1),
    ["Base 2"] = Vector3.new(-339.8, 13.4, -98.5),
    ["Base 3"] = Vector3.new(-340.3, 13.4, 6.0),
    ["Base 4"] = Vector3.new(-340.0, 13.4, 113.1),
    ["Base 5"] = Vector3.new(-339.7, 14.0, 221.8),
    ["Base 6"] = Vector3.new(-479.3, 13.4, 218.5),
    ["Base 7"] = Vector3.new(-478.5, 13.4, 116.3),
    ["Base 8"] = Vector3.new(-478.2, 13.4, 5.8)
}

function TpToBestSystem:extractValueGTB(text)
    if not text then return 0 end
    local clean = text:gsub("[%$,/s]", ""):gsub(",", "")
    local mult = 1
    if clean:match("[kK]") then
        mult = 1e3
        clean = clean:gsub("[kK]", "")
    elseif clean:match("[mM]") then
        mult = 1e6
        clean = clean:gsub("[mM]", "")
    elseif clean:match("[bB]") then
        mult = 1e9
        clean = clean:gsub("[bB]", "")
    elseif clean:match("[tT]") then
        mult = 1e12
        clean = clean:gsub("[tT]", "")
    end
    local num = tonumber(clean)
    return num and num * mult or 0
end

function TpToBestSystem:findMostExpensiveBrainrot()
    if self.isStopping then return nil end
    local allPets = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if self.isStopping then break end
        if obj.Name == "AnimalOverhead" then
            local petValue = 0
            local petName = "Brainrot"
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("TextLabel") then
                    local text = child.Text
                    if text and text:find("$") and text:find("/s") then
                        petValue = self:extractValueGTB(text)
                    end
                    if child.Name == "DisplayName" and text ~= "" then
                        petName = text
                    end
                end
            end
            local position = nil
            local current = obj.Parent
            while current and current ~= Workspace do
                if current:IsA("BasePart") then
                    position = current.Position
                    break
                end
                current = current.Parent
            end
            if position and petValue > 0 then
                table.insert(allPets, {
                    position = position,
                    name = petName,
                    value = petValue,
                    baseName = self:findClosestBase(position)
                })
            end
        end
    end
    if #allPets > 0 and not self.isStopping then
        table.sort(allPets, function(a, b)
            return a.value > b.value
        end)
        return allPets[1]
    end
    return nil
end

function TpToBestSystem:findClosestBase(petPosition)
    local closestBase = nil
    local closestDistance = math.huge
    for baseName, baseCoord in pairs(self.baseCoordinates) do
        local distance = (petPosition - baseCoord).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            closestBase = baseName
        end
    end
    return closestBase
end

function TpToBestSystem:equipGrappleHook()
    if self.isStopping then return nil end
    local now = tick()
    if now - self.lastEquipTime < 2 then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    local grappleHook = backpack:FindFirstChild("Grapple Hook") or char:FindFirstChild("Grapple Hook")
    if not grappleHook then return nil end
    if grappleHook.Parent == backpack then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(grappleHook)
            self.lastEquipTime = now
        end
    end
    return grappleHook
end

function TpToBestSystem:spamGrappleHook()
    if self.isStopping then return end
    local now = tick()
    if now - self.lastSpamTime < 0.2 then return end
    local REUseItem = ReplicatedStorage:FindFirstChild("Packages")
    if REUseItem then
        REUseItem = REUseItem:FindFirstChild("Net")
        if REUseItem then
            REUseItem = REUseItem:FindFirstChild("RE/UseItem")
            if REUseItem then
                pcall(function()
                    REUseItem:FireServer(0.23450689315795897)
                    self.lastSpamTime = now
                end)
            end
        end
    end
end

function TpToBestSystem:equipFlyingCarpet()
    if self.isStopping then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    local flyingCarpet = backpack:FindFirstChild("Flying Carpet")
    if not flyingCarpet then
        for _, item in ipairs(backpack:GetChildren()) do
            if (item.Name:lower():find("flying") or item.Name:lower():find("carpet")) and item:IsA("Tool") then
                flyingCarpet = item
                break
            end
        end
    end
    if flyingCarpet then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(flyingCarpet)
            return flyingCarpet
        end
    end
    return nil
end

function TpToBestSystem:teleportToBestBrainrot()
    if self.isStopping then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    if not self.currentBestPet then return end
    self:equipFlyingCarpet()
    local targetBase = self.baseCoordinates[self.currentBestPet.baseName]
    if targetBase then
        humanoidRootPart.CFrame = CFrame.new(targetBase)
        print("Teleportado para base: " .. self.currentBestPet.baseName)
    else
        humanoidRootPart.CFrame = CFrame.new(self.currentBestPet.position)
        print("Teleportado para Brainrot!")
    end
    task.wait(0.5)
    self:Toggle()
end

function TpToBestSystem:stopMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

function TpToBestSystem:cleanStop()
    self.isStopping = true
    self.hasReachedHeight = false
    self.targetHeight = nil
    self.currentBestPet = nil
    self.lastEquipTime = 0
    self.lastSpamTime = 0
    self.lastScanTime = 0
    for name, conn in pairs(self.Connections) do
        if conn then
            conn:Disconnect()
            self.Connections[name] = nil
        end
    end
    self:stopMovement()
    task.wait(0.1)
    self.isStopping = false
end

function TpToBestSystem:startSystem()
    self.isStopping = false
    self.hasReachedHeight = false
    self.targetHeight = nil
    self.lastEquipTime = 0
    self.lastSpamTime = 0
    self.lastScanTime = 0
    self.currentBestPet = self:findMostExpensiveBrainrot()
    if not self.currentBestPet then
        print("Nenhum Brainrot encontrado no servidor")
        self:Toggle()
        return
    end
    print("Brainrot encontrado na base: " .. self.currentBestPet.baseName)
    task.wait(0.5)
    self:equipGrappleHook()
    task.wait(0.5)
    self.Connections.movement = RunService.Heartbeat:Connect(function()
        if self.isStopping or not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not self.hasReachedHeight then
            if not self.targetHeight then
                self.targetHeight = Vector3.new(hrp.Position.X, hrp.Position.Y + 35, hrp.Position.Z)
            end
            local distanceToHeight = (hrp.Position - self.targetHeight).Magnitude
            if distanceToHeight > 3 then
                local direction = (self.targetHeight - hrp.Position).Unit
                hrp.AssemblyLinearVelocity = direction * 50
            else
               self.hasReachedHeight = true
                self:stopMovement()
                task.wait(0.1)
                self:teleportToBestBrainrot()
            end
        end
    end)
end

function TpToBestSystem:Toggle()
    if self.isStopping then return end
    self.Enabled = not self.Enabled
    if self.Enabled then
        self:startSystem()
    else
        self:cleanStop()
    end
end

-- ==================== ESP BASE SYSTEM ====================
local ESPSystem = {}
ESPSystem.Enabled = false

function ESPSystem:Toggle()
    if not _G.SAB then
        _G.SAB = {}
    end
    
    if not _G.SAB.BigPlotTimers then
        _G.SAB.BigPlotTimers = {
            enabled = false,
            isRunning = false
        }
    end
    
    local plotTimers = _G.SAB.BigPlotTimers
    
    function plotTimers:Toggle(enable)
        if enable and not self.isRunning then
            self.enabled = true
        elseif not enable and self.enabled then
            self.enabled = false
        end
        
        self.isRunning = true
        
        task.spawn(function()
            while task.wait() and self.enabled do
                pcall(function()
                    for _, plot in Workspace.Plots:GetChildren() do
                        if plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock") then
                            local plotBlock = plot.Purchases.PlotBlock
                            if plotBlock:FindFirstChild("Main") then
                                local main = plotBlock.Main
                                if main:FindFirstChild("BillboardGui") then
                                    local billboard = main.BillboardGui
                                    billboard.AlwaysOnTop = true
                                    billboard.MaxDistance = 1000
                                    billboard.Size = UDim2.fromScale(35, 50)
                                end
                            end
                        end
                    end
                end)
            end
            
            pcall(function()
                for _, plot in Workspace.Plots:GetChildren() do
                    if plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock") then
                        local plotBlock = plot.Purchases.PlotBlock
                        if plotBlock:FindFirstChild("Main") then
                            local main = plotBlock.Main
                            if main:FindFirstChild("BillboardGui") then
                                local billboard = main.BillboardGui
                                billboard.AlwaysOnTop = false
                                billboard.MaxDistance = 60
                                billboard.Size = UDim2.fromScale(7, 10)
                            end
                        end
                    end
                end
            end)
            
            self.isRunning = false
        end)
    end
    
    local newState = not plotTimers.enabled
    plotTimers:Toggle(newState)
    self.Enabled = newState
    return newState
end

-- ==================== DESYNC V3 ====================
local function aplicarDesync()
    local FFlags = { 
        GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000, 
        LargeReplicatorWrite5 = true, 
        LargeReplicatorEnabled9 = true, 
        AngularVelociryLimit = 360, 
        TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646, 
        S2PhysicsSenderRate = 15000, 
        DisableDPIScale = true, 
        MaxDataPacketPerSend = 2147483647, 
        PhysicsSenderMaxBandwidthBps = 20000, 
        TimestepArbiterHumanoidLinearVelThreshold = 21, 
        MaxMissedWorldStepsRemembered = -2147483648, 
        PlayerHumanoidPropertyUpdateRestrict = true, 
        SimDefaultHumanoidTimestepMultiplier = 0, 
        StreamJobNOUVolumeLengthCap = 2147483647, 
        DebugSendDistInSteps = -2147483648, 
        GameNetDontSendRedundantNumTimes = 1, 
        CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1, 
        CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1, 
        LargeReplicatorSerializeRead3 = true, 
        ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647, 
        CheckPVCachedVelThresholdPercent = 10, 
        CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1, 
        GameNetDontSendRedundantDeltaPositionMillionth = 1, 
        InterpolationFrameVelocityThresholdMillionth = 5, 
        StreamJobNOUVolumeCap = 2147483647, 
        InterpolationFrameRotVelocityThresholdMillionth = 5, 
        CheckPVCachedRotVelThresholdPercent = 10, 
        WorldStepMax = 30, 
        InterpolationFramePositionThresholdMillionth = 5, 
        TimestepArbiterHumanoidTurningVelThreshold = 1, 
        SimOwnedNOUCountThresholdMillionth = 2147483647, 
        GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000, 
        NextGenReplicatorEnabledWrite4 = true, 
        TimestepArbiterOmegaThou = 1073741823, 
        MaxAcceptableUpdateDelay = 1, 
        LargeReplicatorSerializeWrite4 = true 
    }
    
    for name, value in pairs(FFlags) do
        pcall(function()
            setfflag(tostring(name), tostring(value))
        end)
    end
    
    local function respawnar(plr)
        local rcdEnabled, wasHidden = false, false
        if gethidden then 
            rcdEnabled, wasHidden = gethidden(workspace, 'RejectCharacterDeletions') ~= Enum.RejectCharacterDeletions.Disabled 
        end
        
        if rcdEnabled and replicatesignal then
            replicatesignal(plr.ConnectDiedSignalBackend)
            task.wait(Players.RespawnTime - 0.1)
            replicatesignal(plr.Kill)
        else
            local char = plr.Character
            local hum = char:FindFirstChildWhichIsA('Humanoid')
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Dead)
            end
            char:ClearAllChildren()
            local newChar = Instance.new('Model')
            newChar.Parent = workspace
            plr.Character = newChar
            task.wait()
            plr.Character = char
            newChar:Destroy()
        end
    end
    
    respawnar(LocalPlayer)
    print("Desync V3 aplicado!")
end

-- ==================== BOTÕES LATERAIS COM CALLBACKS ====================
-- Botão DEVOURER
criarParBotoesLateral(posicaoYLateral, 
    {nome1 = "DEVOURER"}, 
    {nome1 = "DESYNC", callback = function(btn)
        aplicarDesync()
        btn.BackgroundColor3 = COR_BOTAO_ATIVO
        task.wait(0.5)
        btn.BackgroundColor3 = COR_BOTAO_DESATIVADO
    end}, 
    alturaLinhaLateral
)
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão FLY TO BEST / TP TO BEST
criarBotaoLateral(posicaoYLateral, {
    nome1 = "FLY TO BEST", 
    nome2 = "TP TO BEST", 
    temSeta = true, 
    altura = alturaLinhaLateral,
    
    callback = function(button)
        local isFlyMode = button.Text == "FLY TO BEST"
        
        if isFlyMode then
            -- Modo FLY (GoToBestHub)
            if GoToBestHub.Enabled then
                GoToBestHub.Enabled = false
                GoToBestHub.isStopping = true
                GoToBestHub:stabilizePlayer()
                button.BackgroundColor3 = COR_BOTAO_DESATIVADO
                print("Fly to Best desativado")
            else
                GoToBestHub.Enabled = true
                GoToBestHub.isStopping = false
                button.BackgroundColor3 = COR_BOTAO_ATIVO
                print("Fly to Best ativado")
                
                -- Inicia o processo
                task.spawn(function()
                    while GoToBestHub.Enabled and not GoToBestHub.isStopping do
                        local bestPet = findBestBrainrotData()
                        if bestPet then
                            GoToBestHub.currentBestPet = bestPet
                            print("Indo até:", bestPet.name, "Valor:", bestPet.value)
                            
                            local grappleHook = GoToBestHub:equipGrappleHook()
                            if grappleHook then
                                local maxAttempts = 80
                                local attempt = 0
                                
                                while attempt < maxAttempts and GoToBestHub.Enabled and not GoToBestHub.isStopping do
                                    local distance = GoToBestHub:flyToPosition(bestPet.position, 110)
                                    
                                    if attempt % math.random(8, 12) == 0 then
                                        GoToBestHub:spamGrappleHook()
                                    end
                                    
                                    if distance < 12 then
                                        print("Chegou ao destino!")
                                        GoToBestHub:stabilizePlayer()
                                        break
                                    end
                                    
                                    attempt += 1
                                    task.wait(0.15)
                                end
                            end
                        end
                        task.wait(3)
                    end
                end)
            end
        else
            -- Modo TP (TpToBestSystem)
            TpToBestSystem:Toggle()
            button.BackgroundColor3 = TpToBestSystem.Enabled and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        end
    end
})
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão SPEED E INF JUMP
criarParBotoesLateral(posicaoYLateral, 
    {nome1 = "SPEED"}, 
    {nome1 = "INF JUMP"}, 
    alturaLinhaLateral
)
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão STEAL FLOOR / FLOOR V2
criarBotaoLateral(posicaoYLateral, {
    nome1 = "STEAL FLOOR", 
    nome2 = "FLOOR V2", 
    temSeta = true, 
    altura = alturaLinhaLateral
})
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão FLY V2
criarBotaoLateral(posicaoYLateral, {
    nome1 = "FLY V2", 
    temSeta = false, 
    altura = alturaLinhaLateral
})

-- ==================== CONFIGURAÇÃO DOS BOTÕES DO PAINEL PRINCIPAL ====================
local menuLateralAtivo = false

botaoMenuLateral.MouseButton1Click:Connect(function()
    menuLateralAtivo = not menuLateralAtivo
    botaoMenuLateral.BackgroundColor3 = menuLateralAtivo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
    painelLateral.Visible = menuLateralAtivo
end)

-- Configurar botão ESP BASE
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "ESP\nBASE" then
            child.MouseButton1Click:Connect(function()
                local estado = ESPSystem:Toggle()
                child.BackgroundColor3 = estado and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
            end)
            break
        end
    end
end)

-- Configurar botão NEREAST
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "NEREAST" then
            child.MouseButton1Click:Connect(function()
                local ativo = child.BackgroundColor3 == COR_BOTAO_ATIVO
                
                if not ativo then
                    NearestStealSystem:Start()
                    child.BackgroundColor3 = COR_BOTAO_ATIVO
                    print("Nearest Steal ativado")
                else
                    NearestStealSystem:Stop()
                    child.BackgroundColor3 = COR_BOTAO_DESATIVADO
                    print("Nearest Steal desativado")
                end
            end)
            break
        end
    end
end)

-- Configurar botão ANTI DEBUFF (aplicar Desync V3)
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "ANTI DEBUFF" then
            child.MouseButton1Click:Connect(function()
                aplicarDesync()
                child.BackgroundColor3 = COR_BOTAO_ATIVO
                task.wait(0.5)
                child.BackgroundColor3 = COR_BOTAO_DESATIVADO
            end)
            break
        end
    end
end)

print("GOKU BLACK HUB carregado com sucesso!")
print("Sistemas integrados:")
print("- Nearest Steal System")
print("- GoToBest Hub (Fly Mode)")
print("- TpToBest System (TP Mode)")
print("- ESP Base System")
print("- Desync V3")
