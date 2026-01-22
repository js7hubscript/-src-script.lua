-- JS7 HUB - Painel Compacto
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local TweenService = game:GetService('TweenService')
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Configuração
local CONFIG = "JS7_HUB_Config.json"
local ToggleStates = {}
local HttpService = game:GetService('HttpService')

-- Carregar estados salvos
if isfile and readfile and isfile(CONFIG) then
    pcall(function()
        ToggleStates = HttpService:JSONDecode(readfile(CONFIG))
    end)
end

-- Função para salvar estados
local function save()
    if writefile then
        pcall(function()
            writefile(CONFIG, HttpService:JSONEncode(ToggleStates))
        end)
    end
end

-- Notificação inicial
local function showNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

showNotification("JS7 HUB", "Painel carregado com sucesso!")

-- Variáveis de estado
local infJumpConnection = nil
local jumpBoostConnection = nil
local speedBoostConn = nil
local slowFallConn = nil
local playerESP = {Enabled = false, Highlights = {}, NameTags = {}}
local baseESPHighlights = {}
local baseESPConnections = {}
local espConnections = {}
local isInvisible = false

-- FUNÇÕES DO HUB

-- INF JUMP
local function toggleInfJump(state)
    if infJumpConnection then 
        infJumpConnection:Disconnect() 
        infJumpConnection = nil 
    end
    
    if state then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = player.Character
            if char and char:FindFirstChild('HumanoidRootPart') then
                char.HumanoidRootPart.Velocity = Vector3.new(
                    char.HumanoidRootPart.Velocity.X,
                    50,
                    char.HumanoidRootPart.Velocity.Z
                )
            end
        end)
    end
    
    showNotification("INF JUMP", state and "Ativado" or "Desativado")
end

-- INVISÍVEL
local clone, oldRoot, hip
local function toggleInvisible(state)
    isInvisible = state
    
    if state then
        -- Ativar invisibilidade
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            -- Método simples de invisibilidade
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end
    else
        -- Desativar invisibilidade
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
    
    showNotification("INVISÍVEL", state and "Ativado" or "Desativado")
end

-- JUMP BOOST
local jumpBoostCanBoost = true
local function toggleJumpBoost(state)
    if jumpBoostConnection then 
        jumpBoostConnection:Disconnect() 
        jumpBoostConnection = nil 
    end
    
    if state then
        local function setup()
            local char = player.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass('Humanoid')
            local rootPart = char:FindFirstChild('HumanoidRootPart')
            if not humanoid or not rootPart then return end
            
            jumpBoostConnection = humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.Jumping and jumpBoostCanBoost then
                    local currentVel = rootPart.AssemblyLinearVelocity
                    rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, 100, currentVel.Z)
                    jumpBoostCanBoost = false
                elseif newState == Enum.HumanoidStateType.Landed then
                    jumpBoostCanBoost = true
                end
            end)
        end
        
        setup()
        player.CharacterAdded:Connect(setup)
    end
    
    showNotification("JUMP BOOST", state and "Ativado" or "Desativado")
end

-- ESP BASE
local function toggleBaseESP(state)
    if not state then
        for _, highlight in pairs(baseESPHighlights) do
            if highlight then highlight:Destroy() end
        end
        baseESPHighlights = {}
        
        for _, conn in pairs(baseESPConnections) do
            if conn then conn:Disconnect() end
        end
        baseESPConnections = {}
        return
    end
    
    local function addHighlight(plot)
        local highlight = Instance.new("Highlight")
        highlight.Name = "BaseESPHighlight"
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.Adornee = plot
        highlight.Parent = plot
        baseESPHighlights[plot] = highlight
    end
    
    local plotsFolder = workspace:FindFirstChild("Plots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do 
            addHighlight(plot) 
        end
        
        local conn = plotsFolder.ChildAdded:Connect(addHighlight)
        table.insert(baseESPConnections, conn)
    end
    
    showNotification("ESP BASE", state and "Ativado" or "Desativado")
end

-- ESP PLAYER
function playerESP:CreateHighlightForCharacter(character)
    if not character or not character:IsA('Model') then return end
    if self.Highlights[character] then return end
    
    local highlight = Instance.new('Highlight')
    highlight.Name = 'PlayerESPHighlight'
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
    billboard.Name = 'PlayerESPNameTag'
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
        for character, _ in pairs(playerESP.Highlights) do 
            playerESP:RemoveForCharacter(character) 
        end
        playerESP.Highlights = {}
        playerESP.NameTags = {}
        
        for _, conn in ipairs(espConnections) do
            if conn then conn:Disconnect() end
        end
        espConnections = {}
        
        showNotification("ESP PLAYER", "Desativado")
        return
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            playerESP:CreateHighlightForCharacter(plr.Character)
            playerESP:CreateNameTag(plr, plr.Character)
        end
    end
    
    local playerAddedConn = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            playerESP:CreateHighlightForCharacter(char)
            playerESP:CreateNameTag(plr, char)
        end)
    end)
    
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
        if plr.Character then 
            playerESP:RemoveForCharacter(plr.Character) 
        end
    end)
    
    table.insert(espConnections, playerAddedConn)
    table.insert(espConnections, playerRemovingConn)
    
    showNotification("ESP PLAYER", "Ativado")
end

-- SLOW FLING
local function toggleSlowFling(state)
    if slowFallConn then 
        slowFallConn:Disconnect() 
        slowFallConn = nil 
    end
    
    if state then
        slowFallConn = RunService.RenderStepped:Connect(function()
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild('HumanoidRootPart')
                if hrp and hrp.Velocity.Y < 0 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -10, hrp.Velocity.Z)
                end
            end
        end)
    end
    
    showNotification("SLOW FLING", state and "Ativado" or "Desativado")
end

-- SPEED BOOST
local function toggleSpeedBoost(state)
    if speedBoostConn then 
        speedBoostConn:Disconnect() 
        speedBoostConn = nil 
    end
    
    if state then
        local speedValue = 27
        speedBoostConn = RunService.RenderStepped:Connect(function()
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass('Humanoid')
            local hrp = char and char:FindFirstChild('HumanoidRootPart')
            
            if humanoid and hrp and humanoid.MoveDirection.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = humanoid.MoveDirection.Unit * speedValue + Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
    end
    
    showNotification("SPEED BOOST", state and "Ativado" or "Desativado")
end

-- ==============================================
-- INTERFACE DO PAINEL - JS7 HUB
-- ==============================================

-- Criar a tela de interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JS7_HUB_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteger a GUI
if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game:GetService("CoreGui")
else
    screenGui.Parent = game:GetService("CoreGui")
end

-- Botão circular vermelho (canto inferior direito)
local menuBtn = Instance.new("Frame")
menuBtn.Name = "MenuButton"
menuBtn.Size = UDim2.new(0, 60, 0, 60)
menuBtn.Position = UDim2.new(1, -80, 1, -80)
menuBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
menuBtn.BorderSizePixel = 0
menuBtn.BackgroundTransparency = 0
menuBtn.AnchorPoint = Vector2.new(0.5, 0.5)
menuBtn.Parent = screenGui

local menuBtnUICorner = Instance.new("UICorner")
menuBtnUICorner.CornerRadius = UDim.new(1, 0)
menuBtnUICorner.Parent = menuBtn

local menuBtnStroke = Instance.new("UIStroke")
menuBtnStroke.Color = Color3.fromRGB(255, 0, 0)
menuBtnStroke.Thickness = 3
menuBtnStroke.Parent = menuBtn

local menuBtnText = Instance.new("TextLabel")
menuBtnText.Name = "Icon"
menuBtnText.Size = UDim2.new(1, 0, 1, 0)
menuBtnText.BackgroundTransparency = 1
menuBtnText.Text = "≡"
menuBtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
menuBtnText.TextScaled = true
menuBtnText.Font = Enum.Font.SourceSansBold
menuBtnText.Parent = menuBtn

-- Painel principal (inicialmente escondido)
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 350, 0, 450)
mainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
mainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainPanel.BackgroundTransparency = 0.05
mainPanel.BorderSizePixel = 0
mainPanel.Visible = false
mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = mainPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(220, 0, 0)
panelStroke.Thickness = 2
panelStroke.Parent = mainPanel

-- Cabeçalho arrastável
local panelHeader = Instance.new("Frame")
panelHeader.Name = "Header"
panelHeader.Size = UDim2.new(1, 0, 0, 40)
panelHeader.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
panelHeader.BorderSizePixel = 0
panelHeader.Parent = mainPanel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10, 0, 0)
headerCorner.Parent = panelHeader

local headerTitle = Instance.new("TextLabel")
headerTitle.Name = "Title"
headerTitle.Size = UDim2.new(0.7, 0, 1, 0)
headerTitle.Position = UDim2.new(0, 15, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "JS7 HUB"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.TextSize = 18
headerTitle.Font = Enum.Font.SourceSansBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = panelHeader

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(0, 0.5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 24
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = panelHeader

-- Container de funções
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "FunctionsContainer"
scrollFrame.Size = UDim2.new(1, -20, 1, -140)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 0, 0)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainPanel

local functionsLayout = Instance.new("UIListLayout")
functionsLayout.Padding = UDim.new(0, 10)
functionsLayout.Parent = scrollFrame

-- Seção de créditos
local creditsFrame = Instance.new("Frame")
creditsFrame.Name = "CreditsSection"
creditsFrame.Size = UDim2.new(1, -20, 0, 80)
creditsFrame.Position = UDim2.new(0, 10, 1, -100)
creditsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
creditsFrame.BorderSizePixel = 0
creditsFrame.Parent = mainPanel

local creditsCorner = Instance.new("UICorner")
creditsCorner.CornerRadius = UDim.new(0, 8)
creditsCorner.Parent = creditsFrame

local creditsStroke = Instance.new("UIStroke")
creditsStroke.Color = Color3.fromRGB(220, 0, 0)
creditsStroke.Thickness = 1
creditsStroke.Parent = creditsFrame

local creditsTitle = Instance.new("TextLabel")
creditsTitle.Name = "CreditsTitle"
creditsTitle.Size = UDim2.new(1, 0, 0, 30)
creditsTitle.BackgroundTransparency = 1
creditsTitle.Text = "CRÉDITOS"
creditsTitle.TextColor3 = Color3.fromRGB(220, 0, 0)
creditsTitle.TextSize = 16
creditsTitle.Font = Enum.Font.SourceSansBold
creditsTitle.Parent = creditsFrame

local creditsText = Instance.new("TextLabel")
creditsText.Name = "CreditsText"
creditsText.Size = UDim2.new(1, 0, 0, 40)
creditsText.Position = UDim2.new(0, 0, 0, 30)
creditsText.BackgroundTransparency = 1
creditsText.Text = "Desenvolvido por JS7\n© 2024 JS7 HUB - Todos os direitos reservados"
creditsText.TextColor3 = Color3.fromRGB(200, 200, 200)
creditsText.TextSize = 14
creditsText.Font = Enum.Font.SourceSans
creditsText.TextWrapped = true
creditsText.Parent = creditsFrame

-- Sistema de arrastar o painel
local dragging = false
local dragStart, startPos

-- Função para criar botões de função
local function createFunctionButton(title, functionName, toggleFunc)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = title .. "Button"
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = scrollFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = buttonFrame
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(220, 0, 0)
    buttonStroke.Thickness = 1
    buttonStroke.Parent = buttonFrame
    
    local buttonText = Instance.new("TextLabel")
    buttonText.Name = "ButtonText"
    buttonText.Size = UDim2.new(0.8, 0, 1, 0)
    buttonText.Position = UDim2.new(0, 10, 0, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = title
    buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonText.TextSize = 14
    buttonText.Font = Enum.Font.SourceSans
    buttonText.TextXAlignment = Enum.TextXAlignment.Left
    buttonText.Parent = buttonFrame
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "ToggleIndicator"
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(1, -35, 0.5, 0)
    toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = buttonFrame
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = toggleIndicator
    
    local buttonBtn = Instance.new("TextButton")
    buttonBtn.Name = "Button"
    buttonBtn.Size = UDim2.new(1, 0, 1, 0)
    buttonBtn.BackgroundTransparency = 1
    buttonBtn.Text = ""
    buttonBtn.Parent = buttonFrame
    
    buttonBtn.MouseButton1Click:Connect(function()
        local newState = not (ToggleStates[functionName] or false)
        ToggleStates[functionName] = newState
        save()
        
        toggleIndicator.BackgroundColor3 = newState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
        
        if toggleFunc then
            pcall(toggleFunc, newState)
        end
    end)
    
    -- Definir estado inicial
    if ToggleStates[functionName] then
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
    
    return buttonFrame
end

-- Criar botões das funções
local functionButtons = {
    {"INF JUMP", "InfJump", toggleInfJump},
    {"INVISÍVEL", "Invisible", toggleInvisible},
    {"JUMP BOOST", "JumpBoost", toggleJumpBoost},
    {"ESP BASE", "ESPBase", toggleBaseESP},
    {"ESP PLAYER", "ESPPlayer", togglePlayerESP},
    {"SLOW FLING", "SlowFling", toggleSlowFling},
    {"SPEED BOOST", "SpeedBoost", toggleSpeedBoost}
}

-- Adicionar botões ao painel
for _, buttonInfo in ipairs(functionButtons) do
    createFunctionButton(buttonInfo[1], buttonInfo[2], buttonInfo[3])
end

-- Sistema de arrastar o painel
panelHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainPanel.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainPanel.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Botões de controle do painel
menuBtnText.MouseButton1Click:Connect(function()
    mainPanel.Visible = not mainPanel.Visible
    menuBtnText.Text = mainPanel.Visible and "✕" or "≡"
end)

closeBtn.MouseButton1Click:Connect(function()
    mainPanel.Visible = false
    menuBtnText.Text = "≡"
end)

-- Efeito de hover no botão circular
menuBtn.MouseEnter:Connect(function()
    TweenService:Create(menuBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 65, 0, 65)}):Play()
end)

menuBtn.MouseLeave:Connect(function()
    TweenService:Create(menuBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)

-- Proteção adicional contra erros
task.spawn(function()
    wait(1)
    if not mainPanel:IsDescendantOf(screenGui) then
        screenGui:Destroy()
        showNotification("Erro", "Interface não carregada corretamente")
    else
        showNotification("JS7 HUB", "Clique no círculo vermelho para abrir!")
    end
end)
