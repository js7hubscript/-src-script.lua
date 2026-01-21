-- Instância principal
local Jogadores = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Jogadores.LocalPlayer
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

-- Cores AZUIS
local COR_FUNDO = Color3.fromRGB(0, 0, 0)
local COR_BORDA = Color3.fromRGB(0, 100, 200) -- Azul
local COR_BOTAO_DESATIVADO = Color3.fromRGB(60, 60, 60)
local COR_BOTAO_ATIVO = Color3.fromRGB(0, 150, 255) -- Azul claro
local COR_TEXTO = Color3.fromRGB(255, 255, 255)
local COR_ROSADO = Color3.fromRGB(0, 200, 255) -- Azul ciano
local COR_SETA = Color3.fromRGB(0, 60, 120) -- Azul escuro

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

-- ==================== DESYNC V3 (FUNÇÃO VAZIA) ====================
local function aplicarDesync()
    -- FUNÇÃO VAZIA
    print("Desync V3 (função vazia)")
end

-- ==================== FUNÇÕES QUE VOCÊ ENVIOU ====================

-- ==================== FUNÇÃO SPEED BOOST ====================
local function toggleSpeedBoostSteal(state)
    if speedBoostConn then 
        speedBoostConn:Disconnect() 
        speedBoostConn = nil 
    end
    
    if state then
        local speedValue = 27
        speedBoostConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass('Humanoid')
            local hrp = char and char:FindFirstChild('HumanoidRootPart')
            if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = humanoid.MoveDirection.Unit * speedValue + Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
        
        local charAddedConn
        charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            local humanoid = newChar:WaitForChild('Humanoid')
            local humanoidRootPart = newChar:WaitForChild('HumanoidRootPart')
        end)
    end
end

-- ==================== PLAYER ESP SYSTEM ====================
local playerESP = {
    Enabled = false,
    Highlights = {},
    NameTags = {}
}

function playerESP:CreateHighlightForCharacter(character)
    if not character or not character:IsA('Model') then return end
    if self.Highlights[character] then return end
    
    local highlight = Instance.new('Highlight')
    highlight.Name = 'ESPHighlight'
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(220, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    self.Highlights[character] = highlight
end

function playerESP:CreateNameTag(plr, character)
    if not plr or not character then return end
    if self.NameTags[character] then return end
    
    local head = character:FindFirstChild('Head')
    if not head then return end
    
    local billboard = Instance.new('BillboardGui')
    billboard.Name = 'ESPNameTag'
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local textLabel = Instance.new('TextLabel')
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = plr.Name
    textLabel.TextColor3 = Color3.fromRGB(220, 0, 0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    self.NameTags[character] = billboard
end

function playerESP:RemoveForCharacter(character)
    if self.Highlights[character] then 
        self.Highlights[character]:Destroy() 
        self.Highlights[character] = nil 
    end
    if self.NameTags[character] then 
        self.NameTags[character]:Destroy() 
        self.NameTags[character] = nil 
    end
end

local function togglePlayerESP(state)
    playerESP.Enabled = state
    if not state then
        for character,_ in pairs(playerESP.Highlights) do 
            playerESP:RemoveForCharacter(character) 
        end
        playerESP.Highlights = {}
        playerESP.NameTags = {}
        return
    end
    
    for _, plr in ipairs(Jogadores:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            playerESP:CreateHighlightForCharacter(plr.Character)
            playerESP:CreateNameTag(plr, plr.Character)
        end
    end
    
    local playerAddedConn = Jogadores.PlayerAdded:Connect(function(plr)
        if playerESP.Enabled then
            plr.CharacterAdded:Connect(function(char)
                playerESP:CreateHighlightForCharacter(char)
                playerESP:CreateNameTag(plr, char)
            end)
        end
    end)
    
    local playerRemovingConn = Jogadores.PlayerRemoving:Connect(function(plr)
        if plr.Character then 
            playerESP:RemoveForCharacter(plr.Character) 
        end
    end)
    
    local updateConn = RunService.Heartbeat:Connect(function()
        if playerESP.Enabled then
            for _, plr in ipairs(Jogadores:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    playerESP:CreateHighlightForCharacter(plr.Character)
                    playerESP:CreateNameTag(plr, plr.Character)
                end
            end
        end
    end)
    
    if not state then
        playerAddedConn:Disconnect()
        playerRemovingConn:Disconnect()
        updateConn:Disconnect()
    end
end

-- ==================== STEAL FLOOR V1 ====================
local function toggleXRay(state)
    -- Função de X-Ray placeholder
    if state then
        print("X-Ray ativado")
    else
        print("X-Ray desativado")
    end
end

local function toggleStealFloor(state)
    if state then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        stealFloorHRP = char:FindFirstChild('HumanoidRootPart')
        platform = Instance.new('Part')
        platform.Size = Vector3.new(5, 0.6, 5)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Material = Enum.Material.Metal
        platform.Color = Color3.fromRGB(220, 0, 0)
        platform.Name = 'LiftPlatform'
        platform.Parent = Workspace
        
        followConn = RunService.Heartbeat:Connect(function()
            if platform and stealFloorHRP then
                local targetPos = Vector3.new(stealFloorHRP.Position.X, stealFloorHRP.Position.Y - 2.5, stealFloorHRP.Position.Z)
                platform.CFrame = CFrame.new(targetPos)
            end
        end)
        toggleXRay(true)
    else
        if followConn then 
            followConn:Disconnect() 
            followConn = nil 
        end
        if platform then 
            platform:Destroy() 
            platform = nil 
        end
        toggleXRay(false)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char) 
    stealFloorHRP = char:WaitForChild('HumanoidRootPart') 
end)

-- ==================== STEAL FLOOR V2 ====================
local RISE_SPEED_V2 = 15

local function safeDisconnectV2(conn) 
    if conn and typeof(conn) == "RBXScriptConnection" then 
        pcall(function() 
            conn:Disconnect() 
        end) 
    end 
end

local function getHumanoidV2() 
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") 
end

local function getHRPV2() 
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
end

local function setPlotsTransparencyV2(active)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    
    if active then
        originalPropsV2 = {}
        for _, plot in ipairs(plots:GetChildren()) do
            local containers = {
                plot:FindFirstChild("Decorations"),
                plot:FindFirstChild("AnimalPodiums")
            }
            for _, container in ipairs(containers) do
                if container then
                    for _, obj in ipairs(container:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            originalPropsV2[obj] = {
                                Transparency = obj.Transparency,
                                Material = obj.Material
                            }
                            obj.Transparency = 0.7
                        end
                    end
                end
            end
        end
    else
        for part, props in pairs(originalPropsV2) do
            if part and part.Parent then 
                part.Transparency = props.Transparency 
                part.Material = props.Material 
            end
        end
        originalPropsV2 = {}
    end
end

local function destroyPlatformV2()
    if platformV2 then 
        pcall(function() 
            platformV2:Destroy() 
        end) 
        platformV2 = nil 
    end
    activeV2 = false
    isRisingV2 = false
    safeDisconnectV2(connectionV2)
    connectionV2 = nil
    setPlotsTransparencyV2(false)
end

local function canRiseV2()
    if not platformV2 then return false end
    local origin = platformV2.Position + Vector3.new(0, platformV2.Size.Y/2, 0)
    local direction = Vector3.new(0, 2, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {platformV2, LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    return not workspace:Raycast(origin, direction, rayParams)
end

local function toggleStealFloorV2(state)
    if state then
        local hrp = getHRPV2()
        if not hrp then return end
        
        platformV2 = Instance.new("Part")
        platformV2.Size = Vector3.new(6, 0.5, 6)
        platformV2.Anchored = true
        platformV2.CanCollide = true
        platformV2.Transparency = 0
        platformV2.Material = Enum.Material.Plastic
        platformV2.Color = Color3.fromRGB(220, 0, 0)
        platformV2.Position = hrp.Position - Vector3.new(0, hrp.Size.Y/2 + platformV2.Size.Y/2, 0)
        platformV2.Parent = workspace
        
        setPlotsTransparencyV2(true)
        isRisingV2 = true
        activeV2 = true
        
        safeDisconnectV2(connectionV2)
        connectionV2 = RunService.Heartbeat:Connect(function(dt)
            if platformV2 and activeV2 then
                local cur = platformV2.Position
                local newXZ = Vector3.new(hrp.Position.X, cur.Y, hrp.Position.Z)
                if isRisingV2 and canRiseV2() then
                    platformV2.Position = newXZ + Vector3.new(0, dt * RISE_SPEED_V2, 0)
                else
                    isRisingV2 = false
                    platformV2.Position = newXZ
                end
            end
        end)
    else
        destroyPlatformV2()
    end
end

-- ==================== INF JUMP ====================
local function toggleInfJump(state)
    if infJumpConnection then 
        infJumpConnection:Disconnect() 
        infJumpConnection = nil 
    end
    
    if state then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild('HumanoidRootPart') then
                char.HumanoidRootPart.Velocity = Vector3.new(
                    char.HumanoidRootPart.Velocity.X, 
                    50, 
                    char.HumanoidRootPart.Velocity.Z
                )
            end
        end)
    end
end

-- ==================== SLOW FALLING ====================
local function toggleSlowFalling(state)
    if slowFallConn then 
        slowFallConn:Disconnect() 
        slowFallConn = nil 
    end
    
    if state then
        slowFallConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild('HumanoidRootPart')
                if hrp and hrp.Velocity.Y < 0 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -10, hrp.Velocity.Z)
                end
            end
        end)
    end
end

-- ==================== FUNÇÃO INVISÍVEL (QUE VOCÊ ENVIOU) ====================
local connections = {
    SemiInvisible = {}
}

local function cleanupSemiInvisibleConnections()
    for _, conn in ipairs(connections.SemiInvisible) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    connections.SemiInvisible = {}
end

local clone, oldRoot, hip, animTrack, isInvisible
local DEPTH_OFFSET = 0.09

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
    if not oldRoot or not oldRoot:IsDescendantOf(workspace) or not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then 
        return false 
    end
    
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

local function removeFolders()
    local playerName = LocalPlayer.Name
    local playerFolder = workspace:FindFirstChild(playerName)
    if not playerFolder then return end
    
    local doubleRig = playerFolder:FindFirstChild("DoubleRig")
    if doubleRig then doubleRig:Destroy() end
    
    local constraints = playerFolder:FindFirstChild("Constraints")
    if constraints then constraints:Destroy() end
    
    local childAddedConn = playerFolder.ChildAdded:Connect(function(child)
        if child.Name == "DoubleRig" or child.Name == "Constraints" then 
            child:Destroy() 
        end
    end)
    table.insert(connections.SemiInvisible, childAddedConn)
end

local function toggleInvisible(state)
    isInvisible = state
    
    -- Limpa conexões antigas
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

-- ==================== BOTÕES LATERAIS COM CALLBACKS ====================
-- Botão INVISÍVEL / DESYNC (troquei DEVOURER por INVISÍVEL)
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

-- Botão FLY TO BEST / TP TO BEST (placeholder - precisa das funções originais)
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

-- Botão FLY V2 (placeholder)
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

-- Configurar botão ESP BASE (placeholder)
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

-- Configurar botão HIDE SKIN (usa a função toggleInvisible)
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

-- Configurar botão ANTI DEBUFF (função vazia)
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

print("JS7 HUB carregado com sucesso!")
print("Tema AZUL aplicado!")
print("Funções disponíveis:")
print("- Speed Boost")
print("- Player ESP")
print("- Infinite Jump")
print("- Steal Floor V1 e V2")
print("- Slow Falling")
print("- Invisível/Hide Skin")
print("- Nearest Steal")
print("- Menu Lateral")
print("- Sistema de cores AZUL")
