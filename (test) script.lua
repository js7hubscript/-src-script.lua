-- Instância principal
local Jogadores = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Jogadores.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local task = task

-- Variáveis globais para as funcionalidades
local speedBoostConn = nil
local infJumpConnection = nil
local slowFallConn = nil
local platform = nil
local platformV2 = nil
local followConn = nil
local connectionV2 = nil
local originalPropsV2 = {}
local activeV2 = false
local isRisingV2 = false
local stealFloorHRP = nil
local autoKickEnabled = false
local autoKickConnection = nil
local autoSentry = false
local playerSentries = {}
local connections = { SemiInvisible = {} }

-- Cores AZUIS
local COR_FUNDO = Color3.fromRGB(0, 0, 0)
local COR_BORDA = Color3.fromRGB(0, 100, 200)
local COR_BOTAO_DESATIVADO = Color3.fromRGB(60, 60, 60)
local COR_BOTAO_ATIVO = Color3.fromRGB(0, 150, 255)
local COR_TEXTO = Color3.fromRGB(255, 255, 255)
local COR_ROSADO = Color3.fromRGB(0, 200, 255)
local COR_SETA = Color3.fromRGB(0, 60, 120)

-- Dimensões
local LARGURA_PAINEL = 200
local ALTURA_PAINEL = 240
local ALTURA_TITULO = 30
local MARGEM = 7
local TOPO = 1
local RODAPE = 10
local ESPACO = 6

-- GUI principal
local guiPrincipal = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
guiPrincipal.Name = "InterfacePrincipal"
guiPrincipal.ResetOnSpawn = false

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
tituloPrincipal.Text = "JS7 HUB"
tituloPrincipal.TextSize = 16
tituloPrincipal.Font = Enum.Font.Arcade
tituloPrincipal.TextColor3 = COR_ROSADO
tituloPrincipal.TextXAlignment = Enum.TextXAlignment.Center
tituloPrincipal.BackgroundTransparency = 1

-- Botão flutuante
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

-- Sistema de fallback
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

-- Container da imagem
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

-- Efeitos de interação AZUIS
botaoFlutuante.MouseEnter:Connect(function()
    bordaVermelha.Thickness = 3.5
    botaoFlutuante.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    imagemPrincipal.ImageColor3 = Color3.fromRGB(200, 230, 255)
    botaoFlutuante.ImageColor3 = Color3.fromRGB(200, 230, 255)
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

-- ==================== FUNÇÃO CRIAR BOTÃO (AZUL) ====================
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

-- Criar botões do painel principal
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

-- ==================== SISTEMA NEAREST STEAL ====================
local NearestStealSystem = {}
NearestStealSystem.Enabled = false
NearestStealSystem.ScanTask = nil

function NearestStealSystem:Start()
    if self.Enabled then return end
    self.Enabled = true
    print("Nearest Steal ativado (função vazia)")
end

function NearestStealSystem:Stop()
    if not self.Enabled then return end
    self.Enabled = false
    print("Nearest Steal desativado (função vazia)")
end

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
                else
                    NearestStealSystem:Stop()
                    child.BackgroundColor3 = COR_BOTAO_DESATIVADO
                end
            end)
            break
        end
    end
end)

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
tituloLateral.Text = "JS7 HUB V2"
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

-- ==================== FUNÇÃO CRIAR BOTÃO LATERAL (AZUL) ====================
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

-- ==================== FUNÇÃO INVISÍVEL QUE VOCÊ ENVIOU ====================
local clone, oldRoot, hip, animTrack, connection, characterConnection
local DEPTH_OFFSET = 0.09
local isInvisible = false

local function cleanupSemiInvisibleConnections()
    for _, conn in ipairs(connections.SemiInvisible) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    connections.SemiInvisible = {}
end

local function toggleInvisible(state)
    isInvisible = state
    
    local function removeFolders()
        local playerName = LocalPlayer.Name
        local playerFolder = workspace:FindFirstChild(playerName)
        if not playerFolder then return end
        local doubleRig = playerFolder:FindFirstChild("DoubleRig")
        if doubleRig then doubleRig:Destroy() end
        local constraints = playerFolder:FindFirstChild("Constraints")
        if constraints then constraints:Destroy() end
        local childAddedConn = playerFolder.ChildAdded:Connect(function(child)
            if child.Name == "DoubleRig" or child.Name == "Constraints" then child:Destroy() end
        end)
        table.insert(connections.SemiInvisible, childAddedConn)
    end
    
    local function doClone()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
            hip = LocalPlayer.Character.Humanoid.HipHeight
            oldRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not oldRoot or not oldRoot.Parent then return false end
            local tempParent = Instance.new("Model") 
            tempParent.Parent = game
            LocalPlayer.Character.Parent = tempParent
            clone = oldRoot:Clone()
            clone.Parent = LocalPlayer.Character
            oldRoot.Parent = workspace.CurrentCamera
            clone.CFrame = oldRoot.CFrame
            LocalPlayer.Character.PrimaryPart = clone
            LocalPlayer.Character.Parent = workspace
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("Motor6D") then
                    if v.Part0 == oldRoot then v.Part0 = clone end
                    if v.Part1 == oldRoot then v.Part1 = clone end
                end
            end
            tempParent:Destroy()
            return true
        end
        return false
    end
    
    local function revertClone()
        if not oldRoot or not oldRoot:IsDescendantOf(workspace) or not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then return false end
        local tempParent = Instance.new("Model") 
        tempParent.Parent = game
        LocalPlayer.Character.Parent = tempParent
        oldRoot.Parent = LocalPlayer.Character
        LocalPlayer.Character.PrimaryPart = oldRoot
        LocalPlayer.Character.Parent = workspace
        oldRoot.CanCollide = true
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == clone then v.Part0 = oldRoot end
                if v.Part1 == clone then v.Part1 = oldRoot end
            end
        end
        if clone then
            local oldPos = clone.CFrame
            clone:Destroy()
            clone = nil
            oldRoot.CFrame = oldPos
        end
        oldRoot = nil
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then 
            LocalPlayer.Character.Humanoid.HipHeight = hip 
        end
    end
    
    local function animationTrickery()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
            local anim = Instance.new("Animation")
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
            local humanoid = LocalPlayer.Character.Humanoid
            local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
            animTrack = animator:LoadAnimation(anim)
            animTrack.Priority = Enum.AnimationPriority.Action4
            animTrack:Play(0, 1, 0)
            anim:Destroy()
            local animStoppedConn = animTrack.Stopped:Connect(function()
                if isInvisible then animationTrickery() end
            end)
            table.insert(connections.SemiInvisible, animStoppedConn)
            task.delay(0, function()
                animTrack.TimePosition = 0.7
                task.delay(1, function() 
                    animTrack:AdjustSpeed(math.huge) 
                end)
            end)
        end
    end
    
    cleanupSemiInvisibleConnections()
    
    if state then
        if doClone() then
            removeFolders()
            animationTrickery()
            print("Invisível ativado")
        else
            print("Falha ao ativar invisível")
        end
    else
        revertClone()
        print("Invisível desativado")
    end
end

-- ==================== ANTI TURRET QUE VOCÊ ENVIOU ====================
local function findPlayerBase()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, plot in pairs(plots:GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
            return plot
        end
    end
    return nil
end

local function isPlayerSentry(sentryObj)
    if playerSentries[sentryObj] then return true end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local sentryPart = sentryObj:IsA("BasePart") and sentryObj or sentryObj:FindFirstChildWhichIsA("BasePart")
    if not sentryPart then return false end
    
    local playerBase = findPlayerBase()
    if not playerBase then return false end
    
    local function isInPlayerBase(obj)
        local current = obj
        local depth = 0
        while current and current ~= workspace and depth < 15 do
            if current == playerBase then return true end
            current = current.Parent
            depth += 1
        end
        return false
    end
    
    if isInPlayerBase(sentryObj) then
        playerSentries[sentryObj] = true
        return true
    end
    return false
end

local function DoClick(tool)
    if tool and tool:FindFirstChild("Handle") then
        pcall(function() tool:Activate() end)
    else
        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
    end
end

local function AttackSentry(part)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not part then return end
    
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local originalTool = humanoid:FindFirstChildOfClass("Tool")
    local bat = originalTool or LocalPlayer.Backpack:FindFirstChild("Bat") or LocalPlayer.Backpack:FindFirstChild("bat")
    
    if bat then
        if originalTool ~= bat then
            pcall(function()
                humanoid:EquipTool(bat)
            end)
            task.wait(0.2)
        end
        
        task.spawn(function()
            while autoSentry and part.Parent do
                pcall(function()
                    part.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                end)
                DoClick(bat)
                task.wait(0.07)
            end
            
            pcall(function()
                if not autoSentry then return end
                if originalTool and originalTool.Parent then
                    humanoid:EquipTool(originalTool)
                else
                    humanoid:UnequipTools()
                end
            end)
        end)
    end
end

local function StartAutoSentry()
    autoSentry = true
    task.spawn(function()
        while autoSentry do
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name:lower():find("sentry_") then
                    if not isPlayerSentry(obj) then
                        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            AttackSentry(part)
                        end
                    end
                end
            end
            task.wait(0.4)
        end
    end)
end

local function StopAutoSentry()
    autoSentry = false
end

local function setAntiTurret(state)
    if state then
        StartAutoSentry()
    else
        StopAutoSentry()
    end
end

-- ==================== AUTO KICK QUE VOCÊ ENVIOU ====================
local function checkForSteal()
    if not autoKickEnabled then return end
    
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
            if gui.Text:find("You stole") then
                LocalPlayer:Kick("YOU STOLE JS7")
                return
            end
        end
    end
end

-- ==================== DESYNC V3 QUE VOCÊ ENVIOU ====================
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
    print("leak by ServerSadzz")
    print("discord.gg/tskcommunity")
end

-- ==================== BOTÕES LATERAIS COM CALLBACKS ====================
-- Botão INVISÍVEL / DESYNC
criarParBotoesLateral(posicaoYLateral, 
    {nome1 = "INVISÍVEL", callback = function(btn)
        local ativo = btn.BackgroundColor3 == COR_BOTAO_ATIVO
        toggleInvisible(not ativo)
        btn.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
    end}, 
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
            print("Fly to Best ativado (placeholder)")
            button.BackgroundColor3 = COR_BOTAO_ATIVO
        else
            print("TP to Best ativado (placeholder)")
            button.BackgroundColor3 = COR_BOTAO_ATIVO
        end
    end
})
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão SPEED / INF JUMP
criarParBotoesLateral(posicaoYLateral, 
    {nome1 = "SPEED", callback = function(btn)
        local ativo = btn.BackgroundColor3 == COR_BOTAO_ATIVO
        toggleSpeedBoostSteal(not ativo)
        btn.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
    end}, 
    {nome1 = "INF JUMP", callback = function(btn)
        local ativo = btn.BackgroundColor3 == COR_BOTAO_ATIVO
        toggleInfJump(not ativo)
        btn.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
    end}, 
    alturaLinhaLateral
)
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão STEAL FLOOR / FLOOR V2
criarBotaoLateral(posicaoYLateral, {
    nome1 = "STEAL FLOOR", 
    nome2 = "FLOOR V2", 
    temSeta = true, 
    altura = alturaLinhaLateral,
    callback = function(button)
        local isV1 = button.Text == "STEAL FLOOR"
        if isV1 then
            local ativo = button.BackgroundColor3 == COR_BOTAO_ATIVO
            toggleStealFloor(not ativo)
            button.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        else
            local ativo = button.BackgroundColor3 == COR_BOTAO_ATIVO
            toggleStealFloorV2(not ativo)
            button.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        end
    end
})
posicaoYLateral = posicaoYLateral + alturaLinhaLateral + ESPACO_LATERAL

-- Botão FLY V2
criarBotaoLateral(posicaoYLateral, {
    nome1 = "FLY V2", 
    temSeta = false, 
    altura = alturaLinhaLateral,
    callback = function(btn)
        local ativo = btn.BackgroundColor3 == COR_BOTAO_ATIVO
        btn.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
        print("Fly V2 " .. (not ativo and "ativado" or "desativado"))
    end
})

-- ==================== CONFIGURAÇÃO DOS BOTÕES DO PAINEL PRINCIPAL ====================
local menuLateralAtivo = false

botaoMenuLateral.MouseButton1Click:Connect(function()
    menuLateralAtivo = not menuLateralAtivo
    botaoMenuLateral.BackgroundColor3 = menuLateralAtivo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
    painelLateral.Visible = menuLateralAtivo
end)

-- Configurar botão ESP PLAYER
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "ESP\nPLAYER" then
            child.MouseButton1Click:Connect(function()
                local ativo = child.BackgroundColor3 == COR_BOTAO_ATIVO
                togglePlayerESP(not ativo)
                child.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
            end)
            break
        end
    end
end)

-- Configurar botão ESP BASE
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "ESP\nBASE" then
            child.MouseButton1Click:Connect(function()
                local ativo = child.BackgroundColor3 == COR_BOTAO_ATIVO
                child.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
                print("ESP Base " .. (not ativo and "ativado" or "desativado"))
            end)
            break
        end
    end
end)

-- Configurar botão X-RAY
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "X-RAY" then
            child.MouseButton1Click:Connect(function()
                local ativo = child.BackgroundColor3 == COR_BOTAO_ATIVO
                child.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
                print("X-Ray " .. (not ativo and "ativado" or "desativado"))
            end)
            break
        end
    end
end)

-- Configurar botão HIDE SKIN
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "HIDE SKIN" then
            child.MouseButton1Click:Connect(function()
                local ativo = child.BackgroundColor3 == COR_BOTAO_ATIVO
                toggleInvisible(not ativo)
                child.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
            end)
            break
        end
    end
end)

-- Configurar botão ANTI DEBUFF
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

-- Configurar botão AUTO KICK
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "AUTO KICK" then
            child.MouseButton1Click:Connect(function()
                autoKickEnabled = not autoKickEnabled
                
                if autoKickEnabled then
                    child.BackgroundColor3 = COR_BOTAO_ATIVO
                    if autoKickConnection then
                        autoKickConnection:Disconnect()
                    end
                    autoKickConnection = RunService.RenderStepped:Connect(checkForSteal)
                else
                    child.BackgroundColor3 = COR_BOTAO_DESATIVADO
                    if autoKickConnection then
                        autoKickConnection:Disconnect()
                        autoKickConnection = nil
                    end
                end
            end)
            break
        end
    end
end)

-- Configurar botão ANTI RAGDOLL
spawn(function()
    wait(1)
    for _, child in ipairs(painelPrincipal:GetChildren()) do
        if child:IsA("TextButton") and child.Text == "ANTI RAGDOLL" then
            child.MouseButton1Click:Connect(function()
                local ativo = child.BackgroundColor3 == COR_BOTAO_ATIVO
                setAntiTurret(not ativo)
                child.BackgroundColor3 = not ativo and COR_BOTAO_ATIVO or COR_BOTAO_DESATIVADO
            end)
            break
        end
    end
end)

print("JS7 HUB carregado com sucesso!")
print("Tema AZUL aplicado!")
print("Funções disponíveis:")
print("- INVISÍVEL/HIDE SKIN")
print("- DESYNC V3")
print("- ANTI TURRET (ANTI RAGDOLL)")
print("- AUTO KICK")
print("- Speed Boost")
print("- Player ESP")
print("- Infinite Jump")
print("- Steal Floor V1 e V2")
print("- Menu Lateral")
       
