-- SERVIÇOS
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- PLAYER
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId

-- ===========================
-- SISTEMA DE APROVAÇÃO SIMPLES
-- ===========================
local approvalSystem = {
    approved = false,
    expirationTime = 0,
    adminPassword = "js7admin2026", -- MUDE ESTA SENHA!
}

-- LISTA DE IDs APROVADOS MANUALMENTE
local MANUAL_APPROVED_IDS = {
    -- ADICIONE IDs AQUI (ex: 123456789,)
}

-- Verificar se está na lista manual
local function checkManualApproval()
    for _, id in ipairs(MANUAL_APPROVED_IDS) do
        if UserId == id then
            return true
        end
    end
    return false
end

-- Função para mostrar notificação
local function showNotification(title, message, color)
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "Notification"
    notifyGui.ResetOnSpawn = false
    notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = color
    uiStroke.Thickness = 2
    uiStroke.Parent = frame
    
    frame.Parent = notifyGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Arcade
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 50)
    messageLabel.Position = UDim2.new(0, 10, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextSize = 12
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = frame
    
    -- Animação de entrada
    frame:TweenPosition(UDim2.new(1, -320, 0, 20), 
        Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5)
    
    -- Fechar após 4 segundos
    task.delay(4, function()
        if frame and frame.Parent then
            frame:TweenPosition(UDim2.new(1, 400, 0, 20), 
                Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true, 
                function()
                    notifyGui:Destroy()
                end)
        end
    end)
    
    -- Fechar ao clicar
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            notifyGui:Destroy()
        end
    end)
end

-- ===========================
-- INTERFACE DE SENHA
-- ===========================
local function createPasswordInterface()
    local passwordGui = Instance.new("ScreenGui")
    passwordGui.Name = "JS7Hub_Access"
    passwordGui.ResetOnSpawn = false
    
    -- AGUARDAR PlayerGui
    while not LocalPlayer:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    passwordGui.Parent = LocalPlayer.PlayerGui
    
    -- Overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Parent = passwordGui
    
    -- Painel principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    mainFrame.Parent = passwordGui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔐 JS7 HUB - ACESSO"
    title.Font = Enum.Font.Arcade
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Parent = mainFrame
    
    -- Instruções
    local instructions = Instance.new("TextLabel")
    instructions.Size = UDim2.new(0.9, 0, 0, 80)
    instructions.Position = UDim2.new(0.05, 0, 0.22, 0)
    instructions.BackgroundTransparency = 1
    instructions.Text = "Entre em contato com JS7 para obter a senha\n\n📱 Discord: js7_stores\n🎮 Ou peça no ttk JS7 NEUROSE"
    instructions.Font = Enum.Font.SourceSans
    instructions.TextSize = 14
    instructions.TextColor3 = Color3.fromRGB(200, 200, 220)
    instructions.TextWrapped = true
    instructions.Parent = mainFrame
    
    -- Caixa de senha
    local passwordBox = Instance.new("TextBox")
    passwordBox.Size = UDim2.new(0.8, 0, 0, 40)
    passwordBox.Position = UDim2.new(0.1, 0, 0.55, 0)
    passwordBox.PlaceholderText = "Digite a senha de acesso..."
    passwordBox.Font = Enum.Font.SourceSansSemibold
    passwordBox.TextSize = 16
    passwordBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", passwordBox).CornerRadius = UDim.new(0, 8)
    passwordBox.Parent = mainFrame
    
    -- Botão de entrar
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.8, 0, 0, 45)
    submitBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
    submitBtn.Text = "🔓 ENTRAR NO PAINEL"
    submitBtn.Font = Enum.Font.Arcade
    submitBtn.TextSize = 14
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)
    submitBtn.Parent = mainFrame
    
    -- Label de status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
    statusLabel.Position = UDim2.new(0.1, 0, 0.92, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextSize = 12
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- Verificação de senha
    submitBtn.MouseButton1Click:Connect(function()
        local password = passwordBox.Text
        
        -- Senhas válidas
        local validPasswords = {
            ["JS7HUB24H"] = 24,      -- 24 horas
            ["JS7HUB7D"] = 168,      -- 7 dias
            ["JS7HUB30D"] = 720,     -- 30 dias
            ["JS7HUBPERM"] = 0,      -- Permanente
            [approvalSystem.adminPassword] = 24  -- Senha padrão
        }
        
        if validPasswords[password] then
            local duration = validPasswords[password]
            
            -- Salvar aprovação
            approvalSystem.approved = true
            if duration > 0 then
                approvalSystem.expirationTime = os.time() + (duration * 3600)
            else
                approvalSystem.expirationTime = 0  -- Permanente
            end
            
            -- Mostrar mensagem
            if duration == 0 then
                showNotification("✅ ACESSO PERMANENTE", 
                    "Painel liberado permanentemente!", 
                    Color3.fromRGB(0, 255, 0))
            else
                showNotification("✅ ACESSO CONCEDIDO", 
                    "Painel liberado por " .. duration .. " horas!", 
                    Color3.fromRGB(0, 200, 255))
            end
            
            -- Fechar interface de senha
            passwordGui:Destroy()
            
            -- AGORA CARREGAR O PAINEL DIRETAMENTE
            loadJS7Hub()
            
        else
            statusLabel.Text = "❌ Senha incorreta!"
            task.wait(1.5)
            statusLabel.Text = ""
            passwordBox.Text = ""
        end
    end)
    
    -- Fechar ao clicar fora
    overlay.MouseButton1Click:Connect(function()
        passwordGui:Destroy()
        showNotification("❌ ACESSO NEGADO", 
            "É necessário senha para acessar o painel.", 
            Color3.fromRGB(255, 100, 100))
    end)
end

-- ===========================
-- SEUS CÓDIGOS ORIGINAIS (CORRIGIDOS)
-- ===========================

-- CONTROLES
local toggleStatus = {
    ESPBase = false,
    DesyncV3 = false,
    JumpBoost = false,
    Teleguiado = false,
}

-- Função para carregar o hub principal (MODIFICADA)
function loadJS7Hub()
    print("🚀 Iniciando carregamento do JS7 Hub...")
    
    -- GUI PRINCIPAL
    local gui = Instance.new("ScreenGui")
    gui.Name = "JS7HubV2"
    gui.ResetOnSpawn = false
    
    -- AGUARDAR PlayerGui
    while not LocalPlayer:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    gui.Parent = LocalPlayer.PlayerGui

    print("✅ PlayerGui encontrado, criando interface...")

    -- BOTÃO FLUTUANTE
    local float = Instance.new("ImageButton")
    float.Size = UDim2.new(0, 55, 0, 55)
    float.Position = UDim2.new(0, 15, 0.5, -27)
    float.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    float.BackgroundTransparency = 0.4
    float.BorderSizePixel = 0
    float.Image = "rbxassetid://101332224741678"
    float.ScaleType = Enum.ScaleType.Fit

    -- Deixar redondo
    Instance.new("UICorner", float).CornerRadius = UDim.new(1, 0)

    -- Arrastável
    do
        local drag, startPos, startUI
        float.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                startPos = i.Position
                startUI = float.Position
            end
        end)
        float.InputEnded:Connect(function() drag = false end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - startPos
                float.Position = UDim2.new(startUI.X.Scale, startUI.X.Offset + delta.X, startUI.Y.Scale, startUI.Y.Offset + delta.Y)
            end
        end)
    end

    float.Parent = gui

    -- PAINEL PRINCIPAL
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 144, 0, 208)
    menu.Position = UDim2.new(0.5, -72, 0.5, -104)
    menu.BackgroundColor3 = Color3.fromRGB(15,15,18)
    menu.BackgroundTransparency = 0.35
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Active = true
    menu.Draggable = true
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0,14)

    menu.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,25)
    title.Position = UDim2.new(0,0,0,2)
    title.BackgroundTransparency = 1
    title.Text = "JS7 HUB"
    title.Font = Enum.Font.Arcade
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(0,255,255)
    title.Parent = menu

    -- Botão para abrir/fechar menu
    float.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        print("🎯 Menu visível: " .. tostring(menu.Visible))
    end)

    -- FUNÇÃO PARA CRIAR BOTÕES (SUA FUNÇÃO ORIGINAL)
    local function addBtn(text,size,pos,isAltColor,subText,callback)
        local b = Instance.new("TextButton", menu)
        b.Size = size
        b.Position = pos
        b.Text = text or ""
        b.Font = Enum.Font.Arcade
        b.TextSize = 8
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.TextWrapped = true
        b.BackgroundColor3 = isAltColor and Color3.fromRGB(0,255,255) or Color3.fromRGB(30,30,35)
        b.BackgroundTransparency = 0.6
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

        local s = Instance.new("UIStroke", b)
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = Color3.fromRGB(0,0,0)
        s.Thickness = 1.2
        s.Transparency = 0.2

        if subText then
            local sub = Instance.new("TextLabel", b)
            sub.Size = UDim2.new(1,0,0,8)
            sub.Position = UDim2.new(0,0,0.6,0)
            sub.BackgroundTransparency = 1
                sub.Text = subText
            sub.TextColor3 = Color3.fromRGB(0,255,255)
            sub.Font = Enum.Font.Arcade
            sub.TextSize = 4
        end

        if callback then
            b.MouseButton1Click:Connect(function()
                local active = callback()
                b.BackgroundColor3 = active and Color3.fromRGB(0,170,255) or (isAltColor and Color3.fromRGB(0,255,255) or Color3.fromRGB(30,30,35))
            end)
        end

        return b
    end

    -- POSIÇÕES
    local Y_START = 0.14
    local Y_GAP = 0.165
    local BTN_H = 31

    print("🎨 Criando botões do painel...")

    -- BOTÕES DO PAINEL (SEUS CÓDIGOS ORIGINAIS)
    local espBaseBtn = addBtn("ESP BASE", UDim2.new(0,64,0,BTN_H), UDim2.new(0.04,0,Y_START,0), false, nil, function()
        toggleStatus.ESPBase = not toggleStatus.ESPBase
        local active = toggleStatus.ESPBase

        if active then
            showNotification("ESP BASE", "Ativado com sucesso!", Color3.fromRGB(0, 255, 255))
            
            if not _G.SAB then _G.SAB = {} end
            if not _G.SAB.BigPlotTimers then
                _G.SAB.BigPlotTimers = {enabled=false,isRunning=false}
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
                                            billboard.Size = UDim2.fromScale(35,50)
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
                                        billboard.Size = UDim2.fromScale(7,10)
                                    end
                                end
                            end
                        end
                    end)
                    self.isRunning = false
                end)
            end
            plotTimers:Toggle(true)
        else
            showNotification("ESP BASE", "Desativado!", Color3.fromRGB(255, 100, 100))
        end

        return active
    end)

    local desyncBtn = addBtn("DESYNC V3", UDim2.new(0,64,0,BTN_H), UDim2.new(0.51,0,Y_START,0), false, nil, function()
        toggleStatus.DesyncV3 = not toggleStatus.DesyncV3
        local active = toggleStatus.DesyncV3

        if active then
            showNotification("DESYNC V3", "Ativado com sucesso!", Color3.fromRGB(0, 255, 255))
            
            local FFlags = { GameNetPVHeaderRotationalVelocityZeroCutoffExponent=-5000,LargeReplicatorWrite5=true,LargeReplicatorEnabled9=true,AngularVelociryLimit=360,TimestepArbiterVelocityCriteriaThresholdTwoDt=2147483646,S2PhysicsSenderRate=15000,DisableDPIScale=true,MaxDataPacketPerSend=2147483647,PhysicsSenderMaxBandwidthBps=20000,TimestepArbiterHumanoidLinearVelThreshold=21,MaxMissedWorldStepsRemembered=-2147483648,PlayerHumanoidPropertyUpdateRestrict=true,SimDefaultHumanoidTimestepMultiplier=0,StreamJobNOUVolumeLengthCap=2147483647,DebugSendDistInSteps=-2147483648,GameNetDontSendRedundantNumTimes=1,CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent=1,CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth=1,LargeReplicatorSerializeRead3=true,ReplicationFocusNouExtentsSizeCutoffForPauseStuds=2147483647,CheckPVCachedVelThresholdPercent=10,CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth=1,GameNetDontSendRedundantDeltaPositionMillionth=1,InterpolationFrameVelocityThresholdMillionth=5,StreamJobNOUVolumeCap=2147483647,InterpolationFrameRotVelocityThresholdMillionth=5,CheckPVCachedRotVelThresholdPercent=10,WorldStepMax=30,InterpolationFramePositionThresholdMillionth=5,TimestepArbiterHumanoidTurningVelThreshold=1,SimOwnedNOUCountThresholdMillionth=2147483647,GameNetPVHeaderLinearVelocityZeroCutoffExponent=-5000,NextGenReplicatorEnabledWrite4=true,TimestepArbiterOmegaThou=1073741823,MaxAcceptableUpdateDelay=1,LargeReplicatorSerializeWrite4=true }
            local player = Players.LocalPlayer
            local function respawnar(plr)
                local rcdEnabled, wasHidden = false,false
                if gethidden then rcdEnabled,wasHidden=gethidden(workspace,'RejectCharacterDeletions')~=Enum.RejectCharacterDeletions.Disabled end
                if rcdEnabled and replicatesignal then
                    replicatesignal(plr.ConnectDiedSignalBackend)
                    task.wait(Players.RespawnTime-0.1)
                    replicatesignal(plr.Kill)
                else
                    local char = plr.Character
                    local hum = char:FindFirstChildWhichIsA('Humanoid')
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
                    char:ClearAllChildren()
                    local newChar = Instance.new('Model')
                    newChar.Parent = workspace
                    plr.Character = newChar
                    task.wait()
                    plr.Character = char
                    newChar:Destroy()
                end
            end
            for name,value in pairs(FFlags) do pcall(function() setfflag(tostring(name),tostring(value)) end) end
            respawnar(player)
        else
            showNotification("DESYNC V3", "Desativado!", Color3.fromRGB(255, 100, 100))
        end

        return active
    end)

    local jumpBoostBtn = addBtn("JUMP BOOST", UDim2.new(0,133,0,BTN_H), UDim2.new(0.04,0,Y_START+Y_GAP,0), false, nil, function()
        toggleStatus.JumpBoost = not toggleStatus.JumpBoost
        local active = toggleStatus.JumpBoost

        if active then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 65
                humanoid.UseJumpPower = true
                showNotification("JUMP BOOST", "Pulo aumentado para 65!", Color3.fromRGB(0, 255, 100))
            end
        else
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
                showNotification("JUMP BOOST", "Pulo normalizado!", Color3.fromRGB(255, 150, 50))
            end
        end

        return active
    end)

    local teleguiadoBtn = addBtn("TELEGUIADO", UDim2.new(0,133,0,BTN_H), UDim2.new(0.04,0,Y_START+Y_GAP*2,0), false, nil, function()
        toggleStatus.Teleguiado = not toggleStatus.Teleguiado
        local active = toggleStatus.Teleguiado

        if active then
            showNotification("TELEGUIADO", "Ativado! Mova-se com a câmera.", Color3.fromRGB(0, 200, 255))
            
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local cam = workspace.CurrentCamera
            if hrp and cam then
                RunService.Heartbeat:Connect(function()
                    if toggleStatus.Teleguiado then
                        local moveDir = cam.CFrame.LookVector * 22
                        hrp.AssemblyLinearVelocity = moveDir
                    end
                end)
            end
        else
            showNotification("TELEGUIADO", "Desativado!", Color3.fromRGB(255, 100, 100))
            
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
        end

        return active
    end)

    -- BOTÃO DISCORD EMBAIXO
    local discordBtn = addBtn("DISCORD", UDim2.new(0,64,0,20), UDim2.new(0.5, -32,1, -30), false, nil, function()
        setclipboard("https://discord.gg/55BBE7czB")
        showNotification("Discord", "Link copiado para a área de transferência!", Color3.fromRGB(88, 101, 242))
        return false
    end)
    discordBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    
    -- BOTÃO DE STATUS
    local statusBtn = addBtn("STATUS", UDim2.new(0,64,0,20), UDim2.new(0.04,0,1, -30), false, nil, function()
        if approvalSystem.expirationTime == 0 then
            showNotification("STATUS", "✅ Acesso PERMANENTE", Color3.fromRGB(0, 255, 0))
        elseif approvalSystem.expirationTime > os.time() then
            local timeLeft = approvalSystem.expirationTime - os.time()
            local hours = math.floor(timeLeft / 3600)
            local minutes = math.floor((timeLeft % 3600) / 60)
            showNotification("STATUS", 
                "⏰ Expira em: " .. hours .. "h " .. minutes .. "m", 
                Color3.fromRGB(255, 255, 0))
        else
            showNotification("STATUS", 
                "❌ Acesso expirado! Entre novamente.", 
                Color3.fromRGB(255, 50, 50))
        end
        return false
    end)
    statusBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Verificador de expiração
    task.spawn(function()
        while task.wait(60) do
            if approvalSystem.expirationTime > 0 and approvalSystem.expirationTime < os.time() then
                showNotification("❌ ACESSO EXPIRADO", 
                    "Seu acesso ao painel expirou!", 
                    Color3.fromRGB(255, 0, 0))
                gui:Destroy()
                createPasswordInterface()
                break
            end
        end
    end)
    
    -- Mensagem de boas-vindas
    showNotification("🎮 JS7 HUB v2.0", 
        "Painel carregado com sucesso!\nBem-vindo, " .. LocalPlayer.Name, 
        Color3.fromRGB(0, 255, 255))
    
    print("✅ JS7 Hub carregado com sucesso!")
    print("👤 Usuário: " .. LocalPlayer.Name)
    print("🆔 ID: " .. UserId)
    print("🎯 Clique no botão flutuante para abrir o menu")
end

-- ===========================
-- INICIALIZAÇÃO DO SISTEMA
-- ===========================

-- Aguardar o PlayerGui existir
local function waitForPlayerGui()
    local maxAttempts = 20
    local attempt = 0
    
    while attempt < maxAttempts do
        if LocalPlayer:FindFirstChild("PlayerGui") then
            print("✅ PlayerGui encontrado!")
            return true
        end
        task.wait(0.5)
        attempt = attempt + 1
        print("⏳ Aguardando PlayerGui... (" .. attempt .. "/" .. maxAttempts .. ")")
    end
    
    warn("⚠️ PlayerGui não encontrado após " .. maxAttempts .. " tentativas")
    return false
end

-- Iniciar sistema
task.spawn(function()
    print("🚀 Iniciando JS7 Hub v2.0...")
    print("👤 Usuário: " .. LocalPlayer.Name)
    print("🆔 ID: " .. UserId)
    
    if waitForPlayerGui() then
        -- Verificar lista manual primeiro
        if checkManualApproval() then
            print("✅ Acesso via lista manual concedido!")
            approvalSystem.approved = true
            approvalSystem.expirationTime = 0
            loadJS7Hub()
        else
            -- Se não está na lista, mostrar tela de senha
            print("🔐 Mostrando tela de senha...")
            createPasswordInterface()
        end
    else
        warn("❌ Não foi possível inicializar o sistema")
    end
end)

-- TESTE: Para ver se o script está rodando
print("========================================")
print("🎮 JS7 HUB v2.0 - Sistema de Aprovação")
print("✅ Script inicializado com sucesso!")
print("========================================")
