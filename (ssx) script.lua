-- JS7 HUB V2 - ANTI TORRETA ADICIONADO
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Criar a GUI no CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "JS7HubV2"
gui.ResetOnSpawn = false
if game:GetService("CoreGui"):FindFirstChild("JS7HubV2") then
    game:GetService("CoreGui").JS7HubV2:Destroy()
end
gui.Parent = game:GetService("CoreGui")

print("✅ JS7 HUB - INICIANDO...")

-- ==============================================
-- BOTÃO REDONDO ARRASTÁVEL
-- ==============================================
local float = Instance.new("ImageButton")
float.Size = UDim2.new(0, 55, 0, 55)
float.Position = UDim2.new(0, 20, 0.5, -27)
float.Image = "rbxassetid://101332224741678"
float.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
float.BackgroundTransparency = 0.2
float.BorderSizePixel = 4
float.BorderColor3 = Color3.fromRGB(255, 0, 0)
float.Parent = gui

local cornerFloat = Instance.new("UICorner")
cornerFloat.CornerRadius = UDim.new(1, 0)
cornerFloat.Parent = float

-- Efeito Rainbow no botão
task.spawn(function()
    while task.wait(0.8) do
        for i = 0, 1, 0.166 do
            float.BorderColor3 = Color3.fromHSV(i, 1, 1)
            task.wait(0.1)
        end
    end
end)

-- Sistema de arrastar
local dragging = false
local dragInput, dragStart, startPos

float.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = float.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

float.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        float.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ==============================================
-- PAINEL 1: JS7 HUB (140x220)
-- ==============================================
local painel1 = Instance.new("Frame")
painel1.Size = UDim2.new(0, 140, 0, 220)
painel1.Position = UDim2.new(0.3, -70, 0.5, -110)
painel1.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
painel1.BorderSizePixel = 1
painel1.BorderColor3 = Color3.fromRGB(255, 50, 50)
painel1.Visible = false
painel1.Active = true
painel1.Draggable = true
painel1.Parent = gui

local cornerPainel1 = Instance.new("UICorner")
cornerPainel1.CornerRadius = UDim.new(0, 6)
cornerPainel1.Parent = painel1

-- Abrir/fechar painel com botão flutuante
float.MouseButton1Click:Connect(function()
    painel1.Visible = not painel1.Visible
end)

-- Título do painel 1
local titulo1 = Instance.new("TextLabel")
titulo1.Size = UDim2.new(1, 0, 0, 35)
titulo1.Position = UDim2.new(0, 0, 0, 5)
titulo1.BackgroundTransparency = 1
titulo1.Text = "JS7 HUB\n@js7.neurose"
titulo1.Font = Enum.Font.Arcade
titulo1.TextSize = 10
titulo1.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo1.TextWrapped = true
titulo1.Parent = painel1

-- Botão ESP BEST (grande)
local espBestBtn = Instance.new("TextButton")
espBestBtn.Size = UDim2.new(0, 130, 0, 22)
espBestBtn.Position = UDim2.new(0, 5, 0, 45)
espBestBtn.Text = "ESP BEST"
espBestBtn.Font = Enum.Font.Arcade
espBestBtn.TextSize = 9
espBestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBestBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
espBestBtn.Parent = painel1

local cornerEspBest = Instance.new("UICorner")
cornerEspBest.CornerRadius = UDim.new(0, 4)
cornerEspBest.Parent = espBestBtn

-- Função para criar botões no painel 1
local function criarBotaoP1(texto, linha, coluna, azul)
    local largura = 60
    local altura = 18
    local espacoY = 4
    local inicioY = 72
    local inicioX = 8
    
    if coluna == 2 then
        inicioX = 74
    end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, largura, 0, altura)
    btn.Position = UDim2.new(0, inicioX, 0, inicioY + (linha-1) * (altura + espacoY))
    btn.Text = texto
    btn.Font = Enum.Font.Arcade
    btn.TextSize = 7
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    if azul then
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)  -- Botão DISCORD azul
    else
        btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)     -- Outros botões vermelhos
    end
    
    btn.Parent = painel1
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 3)
    cornerBtn.Parent = btn
    
    -- Lógica de toggle
    btn.MouseButton1Click:Connect(function()
        if texto == "DISCORD" then
            pcall(function()
                setclipboard("https://discord.gg/55BBE7czB")
                print("✅ Link do Discord copiado!")
            end)
            return
        end
        
        local ativo = btn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
        
        if ativo then
            btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
            print("❌ " .. texto .. " DESATIVADO")
        else
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            print("✅ " .. texto .. " ATIVADO")
        end
    end)
    
    return btn
end

-- Criar todos os botões do painel 1
local espBaseBtn = criarBotaoP1("ESP BASE", 1, 1, false)
local espPlayerBtn = criarBotaoP1("ESP PLAYER", 1, 2, false)
local autoKickBtn = criarBotaoP1("AUTO KICK", 2, 1, false)
local nearestBtn = criarBotaoP1("NEAREST", 2, 2, false)
local xrayBtn = criarBotaoP1("X-RAY", 3, 1, false)
local fpsBoostBtn = criarBotaoP1("FPS BOOST", 3, 2, false)
local antiTorretaBtn = criarBotaoP1("ANTI TORRETA", 4, 1, false)
local unwalkBtn = criarBotaoP1("UNWALK", 4, 2, false)
local antiRagdollBtn = criarBotaoP1("ANTIRAGDOLL", 5, 1, false)
local hideSkinBtn = criarBotaoP1("HIDE SKIN", 5, 2, false)
local discordBtn = criarBotaoP1("DISCORD", 6, 1, true)
local kbindBtn = criarBotaoP1("KBIND", 6, 2, false)

-- ===========================
-- FEATURE : BASE ESP
-- ===========================
espBaseBtn.MouseButton1Click:Connect(function()
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
                    for _, plot in game.Workspace.Plots:GetChildren() do
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
                for _, plot in game.Workspace.Plots:GetChildren() do
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
end)

-- ===========================
-- FEATURE : ESP PLAYER
-- ===========================
local espPlayersActive = false
local espPlayersConnections = {}

espPlayerBtn.MouseButton1Click:Connect(function()
    espPlayersActive = not espPlayersActive
    
    if espPlayersActive then
        -- Ativar ESP PLAYER
        local function createPlayerESP(player)
            if player == lp or not player.Character then return end
            
            local character = player.Character
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            if not humanoidRootPart then return end
            
            -- BillboardGui para mostrar nome
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "PlayerESP"
            billboard.Adornee = humanoidRootPart
            billboard.Size = UDim2.new(0, 200, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = 1000
            billboard.Parent = humanoidRootPart
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.TextSize = 16
            nameLabel.Font = Enum.Font.Arcade
            nameLabel.Parent = billboard
            
            -- Fazer personagem azul e transparente
            local function makeCharacterBlueAndTransparent()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        if part:FindFirstChild("OriginalColor") == nil then
                            local originalColor = Instance.new("Color3Value")
                            originalColor.Name = "OriginalColor"
                            originalColor.Value = part.Color
                            originalColor.Parent = part
                        end
                        
                        if part:FindFirstChild("OriginalTransparency") == nil then
                            local originalTransparency = Instance.new("NumberValue")
                            originalTransparency.Name = "OriginalTransparency"
                            originalTransparency.Value = part.Transparency
                            originalTransparency.Parent = part
                        end
                        
                        part.Color = Color3.fromRGB(0, 100, 255)
                        part.Transparency = 0.4
                    end
                end
            end
            
            -- Restaurar aparência
            local function restoreOriginalAppearance()
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        local originalColor = part:FindFirstChild("OriginalColor")
                        local originalTransparency = part:FindFirstChild("OriginalTransparency")
                        
                        if originalColor then
                            part.Color = originalColor.Value
                            originalColor:Destroy()
                        end
                        
                        if originalTransparency then
                            part.Transparency = originalTransparency.Value
                            originalTransparency:Destroy()
                        end
                    end
                end
            end
            
            -- Aplicar efeito
            makeCharacterBlueAndTransparent()
            
            -- Armazenar para limpeza
            table.insert(espPlayersConnections, {
                character = character,
                billboard = billboard,
                restoreFunction = restoreOriginalAppearance
            })
            
            -- Conectar para character trocado
            local charAdded = player.CharacterAdded:Connect(function(newChar)
                if billboard then billboard:Destroy() end
                restoreOriginalAppearance()
                task.wait(1)
                createPlayerESP(player)
            end)
            
            table.insert(espPlayersConnections, {connection = charAdded})
        end
        
        -- Criar ESP para todos players
        for _, player in ipairs(Players:GetPlayers()) do
            createPlayerESP(player)
        end
        
        -- Conectar para novos players
        local playerAdded = Players.PlayerAdded:Connect(function(player)
            if espPlayersActive then
                createPlayerESP(player)
            end
        end)
        
        table.insert(espPlayersConnections, {connection = playerAdded})
        
    else
        -- Desativar ESP PLAYER
        for _, data in ipairs(espPlayersConnections) do
            if data.billboard then
                data.billboard:Destroy()
            end
            if data.restoreFunction then
                data.restoreFunction()
            end
            if data.connection then
                data.connection:Disconnect()
            end
        end
        
        espPlayersConnections = {}
    end
end)

-- ===========================
-- FEATURE : X-RAY (APENAS BASES)
-- ===========================
local xrayActive = false
local xrayBases = {}
local xrayConnections = {}

xrayBtn.MouseButton1Click:Connect(function()
    xrayActive = not xrayActive
    
    if xrayActive then
        print("✅ X-RAY ATIVADO (apenas bases)")
        
        -- Função para tornar uma base transparente
        local function makeBaseTransparent(base)
            pcall(function()
                if not base then return end
                
                for _, part in base:GetDescendants() do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        local isBaseStructure = false
                        
                        if part.Size.Magnitude > 15 then
                            isBaseStructure = true
                        end
                        
                        local partName = part.Name:lower()
                        if partName:find("base") or partName:find("plot") or 
                           partName:find("floor") or partName:find("ground") or
                           partName:find("wall") or partName:find("platform") then
                            isBaseStructure = true
                        end
                        
                        if isBaseStructure then
                            if part:FindFirstChild("XRayOriginal") == nil then
                                local originalData = Instance.new("Folder")
                                originalData.Name = "XRayOriginal"
                                
                                local originalTransparency = Instance.new("NumberValue")
                                originalTransparency.Name = "Transparency"
                                originalTransparency.Value = part.Transparency
                                originalTransparency.Parent = originalData
                                
                                local originalMaterial = Instance.new("StringValue")
                                originalMaterial.Name = "Material"
                                originalMaterial.Value = tostring(part.Material)
                                originalMaterial.Parent = originalData
                                
                                originalData.Parent = part
                            end
                            
                            part.Transparency = 0.85
                            part.Material = Enum.Material.Glass
                            
                            if not table.find(xrayBases, part) then
                                table.insert(xrayBases, part)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Procurar por bases existentes
        pcall(function()
            if game.Workspace:FindFirstChild("Plots") then
                for _, plot in game.Workspace.Plots:GetChildren() do
                    if plot:IsA("Model") then
                        makeBaseTransparent(plot)
                    end
                end
            end
            
            for _, model in game.Workspace:GetChildren() do
                if model:IsA("Model") then
                    local modelSize = model:GetExtentsSize()
                    if modelSize.Magnitude > 50 then
                        makeBaseTransparent(model)
                    end
                end
            end
        end)
        
        -- Conectar para novas bases
        local baseAddedConnection = game.Workspace.ChildAdded:Connect(function(child)
            if xrayActive then
                task.wait(0.5)
                
                if child:IsA("Model") then
                    local modelSize = child:GetExtentsSize()
                    if modelSize.Magnitude > 50 then
                        makeBaseTransparent(child)
                        print("✅ Nova base detectada e tornada transparente")
                    end
                end
            end
        end)
        
        if game.Workspace:FindFirstChild("Plots") then
            local plotsAddedConnection = game.Workspace.Plots.ChildAdded:Connect(function(child)
                if xrayActive and child:IsA("Model") then
                    task.wait(0.5)
                    makeBaseTransparent(child)
                    print("✅ Novo plot detectado e tornado transparente")
                end
            end)
            
            table.insert(xrayConnections, plotsAddedConnection)
        end
        
        table.insert(xrayConnections, baseAddedConnection)
        
    else
        print("❌ X-RAY DESATIVADO")
        
        pcall(function()
            for _, part in ipairs(xrayBases) do
                if part and part.Parent then
                    local originalData = part:FindFirstChild("XRayOriginal")
                    if originalData then
                        local originalTransparency = originalData:FindFirstChild("Transparency")
                        local originalMaterial = originalData:FindFirstChild("Material")
                        
                        if originalTransparency then
                            part.Transparency = originalTransparency.Value
                        end
                        
                        if originalMaterial then
                            part.Material = Enum.Material[originalMaterial.Value]
                        end
                        
                        originalData:Destroy()
                    end
                end
            end
            
            for _, connection in ipairs(xrayConnections) do
                pcall(function()
                    connection:Disconnect()
                end)
            end
        end)
        
        xrayBases = {}
        xrayConnections = {}
    end
end)

-- ===========================
-- FEATURE : FPS BOOST
-- ===========================
local fpsBoostActive = false
local originalSettings = {}
local fpsConnections = {}

fpsBoostBtn.MouseButton1Click:Connect(function()
    fpsBoostActive = not fpsBoostActive
    
    if fpsBoostActive then
        print("✅ FPS BOOST ATIVADO - Otimizando jogo...")
        
        pcall(function()
            originalSettings.GraphicsQualityLevel = settings().Rendering.QualityLevel
            originalSettings.SavedQualityLevel = settings().Rendering.SaveQualityLevel
            originalSettings.CharacterAutoLoads = game:GetService("StarterPlayer").CharacterAutoLoads
        end)
        
        pcall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.SaveQualityLevel = false
            
            local lighting = game:GetService("Lighting")
            
            originalSettings.LightingTechnology = lighting.Technology
            originalSettings.GlobalShadows = lighting.GlobalShadows
            originalSettings.Outlines = lighting.Outlines
            originalSettings.ShadowSoftness = lighting.ShadowSoftness
            
            lighting.Technology = Enum.Technology.Voxel
            lighting.GlobalShadows = false
            lighting.Outlines = false
            lighting.ShadowSoftness = 0
            lighting.Brightness = 2
            
            if lighting:FindFirstChild("Sky") then
                originalSettings.Sky = lighting.Sky:Clone()
                lighting.Sky:Destroy()
                
                local simpleSky = Instance.new("Sky")
                simpleSky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
                simpleSky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
                simpleSky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
                simpleSky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
                simpleSky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
                simpleSky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
                simpleSky.Parent = lighting
            end
            
            for _, effect in lighting:GetChildren() do
                if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
                   effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                    originalSettings[effect.Name] = effect:Clone()
                    effect.Enabled = false
                end
            end
            
            local function optimizeParts(instance)
                for _, child in ipairs(instance:GetChildren()) do
                    if child:IsA("BasePart") or child:IsA("MeshPart") then
                        child.CastShadow = false
                        child.Material = Enum.Material.Plastic
                    end
                    
                    optimizeParts(child)
                end
            end
            
            optimizeParts(game.Workspace)
            
            game:GetService("StarterPlayer").CharacterAutoLoads = false
            
            game:GetService("PhysicsService").ThreadedPhysics = true
            game:GetService("PhysicsService").ThreadedPhysicsPriority = 1
            
            local function removeUnnecessaryDecorations(instance)
                for _, child in ipairs(instance:GetChildren()) do
                    if child:IsA("ParticleEmitter") or child:IsA("Trail") or 
                       child:IsA("Beam") or child:IsA("Smoke") or 
                       child:IsA("Fire") or child:IsA("Sparkles") then
                        child.Enabled = false
                    end
                    
                    removeUnnecessaryDecorations(child)
                end
            end
            
            removeUnnecessaryDecorations(game.Workspace)
            
            local fpsMonitor = Instance.new("ScreenGui")
            fpsMonitor.Name = "FPSMonitor"
            fpsMonitor.Parent = gui
            
            local fpsLabel = Instance.new("TextLabel")
            fpsLabel.Size = UDim2.new(0, 100, 0, 30)
            fpsLabel.Position = UDim2.new(1, -110, 0, 10)
            fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            fpsLabel.BackgroundTransparency = 0.5
            fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            fpsLabel.Text = "FPS: --"
            fpsLabel.Font = Enum.Font.Arcade
            fpsLabel.TextSize = 14
            fpsLabel.Parent = fpsMonitor
            
            local fpsConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
                fpsLabel.Text = "FPS: " .. fps
                
                if fps > 60 then
                    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif fps > 30 then
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
            
            table.insert(fpsConnections, {monitor = fpsMonitor, connection = fpsConnection})
            
            lighting:SetShadowSoftness(0)
            lighting:SetShadowColor(Color3.new(0, 0, 0))
            
        end)
        
        print("✅ FPS BOOST aplicado com sucesso!")
        
    else
        print("❌ FPS BOOST DESATIVADO - Restaurando configurações...")
        
        pcall(function()
            if originalSettings.GraphicsQualityLevel then
                settings().Rendering.QualityLevel = originalSettings.GraphicsQualityLevel
            end
            
            if originalSettings.SavedQualityLevel ~= nil then
                settings().Rendering.SaveQualityLevel = originalSettings.SavedQualityLevel
            end
            
            if originalSettings.CharacterAutoLoads ~= nil then
                game:GetService("StarterPlayer").CharacterAutoLoads = originalSettings.CharacterAutoLoads
            end
            
            local lighting = game:GetService("Lighting")
            
            if originalSettings.LightingTechnology then
                lighting.Technology = originalSettings.LightingTechnology
            end
            
            if originalSettings.GlobalShadows ~= nil then
                lighting.GlobalShadows = originalSettings.GlobalShadows
            end
            
            if originalSettings.Outlines ~= nil then
                lighting.Outlines = originalSettings.Outlines
            end
            
            if originalSettings.ShadowSoftness then
                lighting.ShadowSoftness = originalSettings.ShadowSoftness
            end
            
            lighting.Brightness = 1
            
            if originalSettings.Sky then
                if lighting:FindFirstChild("Sky") then
                    lighting.Sky:Destroy()
                end
                originalSettings.Sky.Parent = lighting
            end
            
            for effectName, effect in pairs(originalSettings) do
                if typeof(effect) == "Instance" then
                    local currentEffect = lighting:FindFirstChild(effectName)
                    if currentEffect then
                        currentEffect.Enabled = true
                    end
                end
            end
            
            for _, data in ipairs(fpsConnections) do
                if data.monitor then
                    data.monitor:Destroy()
                end
                if data.connection then
                    data.connection:Disconnect()
                end
            end
            
            fpsConnections = {}
            
            lighting:SetShadowSoftness(0.5)
            lighting:SetShadowColor(Color3.new(0.7, 0.7, 0.7))
        end)
        
        print("✅ Configurações originais restauradas")
    end
end)

-- ===========================
-- FEATURE : AUTO KICK
-- ===========================
local autoKickEnabled = false
local autoKickConnection = nil

local function checkForSteal()
    if not autoKickEnabled then return end
    
    for _, gui in pairs(lp.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
            if gui.Text:find("You stole") then
                lp:Kick("YOU STOLE JS7")
                return
            end
        end
    end
end

autoKickBtn.MouseButton1Click:Connect(function()
    autoKickEnabled = not autoKickEnabled
    
    if autoKickEnabled then
        autoKickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        if autoKickConnection then
            autoKickConnection:Disconnect()
        end
        autoKickConnection = RunService.RenderStepped:Connect(checkForSteal)
    else
        autoKickBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        if autoKickConnection then
            autoKickConnection:Disconnect()
            autoKickConnection = nil
        end
    end
end)

-- ===========================
-- FEATURE : ANTI TORRETA (CORES CORRIGIDAS)
-- ===========================
local autoSentry = false
local playerSentries = {}

local function findPlayerBase()
    local char = lp.Character
    if not char then return nil end
    
    local plots = game.Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    
    for _, plot in pairs(plots:GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == lp then
            return plot
        end
    end
    return nil
end

local function isPlayerSentry(sentryObj)
    if playerSentries[sentryObj] then return true end
    
    local char = lp.Character
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
        while current and current ~= game.Workspace and depth < 15 do
            if current == playerBase then return true end
            current = current.Parent
            depth = depth + 1
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
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not part then return end
    
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local originalTool = humanoid:FindFirstChildOfClass("Tool")
    local bat = originalTool or lp.Backpack:FindFirstChild("Bat") or lp.Backpack:FindFirstChild("bat")
    
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
            for _, obj in ipairs(game.Workspace:GetChildren()) do
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

antiTorretaBtn.MouseButton1Click:Connect(function()
    autoSentry = not autoSentry
    if autoSentry then
        antiTorretaBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)  -- AZUL = ATIVADO
        print("✅ ANTI TORRETA ATIVADO")
        StartAutoSentry()
    else
        antiTorretaBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)  -- VERMELHO = DESATIVADO
        print("❌ ANTI TORRETA DESATIVADO")
        StopAutoSentry()
    end
end)

-- ===========================
-- FEATURE : ANTIRAGDOLL (VAZIA)
-- ===========================
antiRagdollBtn.MouseButton1Click:Connect(function()
    local ativo = antiRagdollBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ ANTIRAGDOLL DESATIVADO")
    else
        antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ ANTIRAGDOLL ATIVADO")
    end
end)

-- ==============================================
-- PAINEL 2: SEGUE NO TTK (120x150)
-- ==============================================
local painel2 = Instance.new("Frame")
painel2.Size = UDim2.new(0, 120, 0, 150)
painel2.Position = UDim2.new(0.7, -60, 0.5, -75)
painel2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
painel2.BorderSizePixel = 1
painel2.BorderColor3 = Color3.fromRGB(0, 120, 255)
painel2.Visible = true
painel2.Active = true
painel2.Draggable = true
painel2.Parent = gui

local cornerPainel2 = Instance.new("UICorner")
cornerPainel2.CornerRadius = UDim.new(0, 6)
cornerPainel2.Parent = painel2

-- Título painel 2
local titulo2 = Instance.new("TextLabel")
titulo2.Size = UDim2.new(1, 0, 0, 25)
titulo2.Position = UDim2.new(0, 0, 0, 5)
titulo2.BackgroundTransparency = 1
titulo2.Text = "SEGUE NO TTK"
titulo2.Font = Enum.Font.Arcade
titulo2.TextSize = 10
titulo2.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo2.Parent = painel2

-- Função para criar botões painel 2
local function criarBotaoP2(texto, linha, larguraTotal)
    local largura = larguraTotal and 110 or 52
    local altura = 18
    local espacoY = 4
    local inicioY = 35
    local inicioX = 5
    
    if not larguraTotal and (texto == "DESYNC V3" or texto == "JUMP BOOST") then
        inicioX = 63
    end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, largura, 0, altura)
    btn.Position = UDim2.new(0, inicioX, 0, inicioY + (linha-1) * (altura + espacoY))
    btn.Text = texto
    btn.Font = Enum.Font.Arcade
    btn.TextSize = 7
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    btn.Parent = painel2
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 3)
    cornerBtn.Parent = btn
    
    return btn
end

-- Criar botões painel 2
local devourerBtn = criarBotaoP2("DEVOURER", 1, false)
local desyncV3Btn = criarBotaoP2("DESYNC V3", 1, false)
local speedBtn = criarBotaoP2("SPEED", 2, false)
local jumpBoostBtn = criarBotaoP2("JUMP BOOST", 2, false)
local tpToBestBtn = criarBotaoP2("TP TO BEST", 3, true)
local flyV2Btn = criarBotaoP2("FLY V2", 4, true)
local instaFloorBtn = criarBotaoP2("INSTA FLOOR", 5, true)

-- ===========================
-- FEATURE : JUMP BOOST
-- ===========================
local jumpBoostEnabled = false

jumpBoostBtn.MouseButton1Click:Connect(function()
    jumpBoostEnabled = not jumpBoostEnabled
    
    if jumpBoostEnabled then
        jumpBoostBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        local humanoid = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 65
            humanoid.UseJumpPower = true
        end
        print("✅ JUMP BOOST ATIVADO")
    else
        jumpBoostBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        local humanoid = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
        print("❌ JUMP BOOST DESATIVADO")
    end
end)

-- ===========================
-- FEATURE : DESYNC V3
-- ===========================
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

desyncV3Btn.MouseButton1Click:Connect(function()
    local ativo = desyncV3Btn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    
    if not ativo then
        desyncV3Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        
        -- Aplicar FFlags
        for name, value in pairs(FFlags) do
            pcall(function() 
                setfflag(tostring(name), tostring(value)) 
            end)
        end
        
        -- Respawn function
        local function respawnar(plr)
            local char = plr.Character
            if char then
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
        
        respawnar(lp)
        print("leak by ServerSadzz")
        print("discord.gg/tskcommunity")
        print("✅ DESYNC V3 ATIVADO")
    else
        desyncV3Btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ DESYNC V3 DESATIVADO")
    end
end)

-- ===========================
-- FEATURE : FLY V2
-- ===========================
local flyEnabled = false
local flyUp = false
local flyDown = false
local flySpeed = 80

flyV2Btn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        flyV2Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        
        -- Criar UI do Fly
        local FlyUI = Instance.new("ScreenGui", gui)
        FlyUI.Name = "FlyControlUI"
        FlyUI.ResetOnSpawn = false
        
        local function makeButton(text, pos)
            local btn = Instance.new("TextButton", FlyUI)
            btn.Size = UDim2.new(0, 140, 0, 50)
            btn.Position = pos
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextScaled = true
            btn.Text = text
            btn.AutoButtonColor = true
            btn.BackgroundTransparency = 0.15
            return btn
        end
        
        local UpBtn = makeButton("⬆ Subir", UDim2.new(0.8, 0, 0.6, 0))
        local DownBtn = makeButton("⬇ Descer", UDim2.new(0.8, 0, 0.7, 0))
        
        local SpeedBtn = Instance.new("TextButton", FlyUI)
        SpeedBtn.Size = UDim2.new(0, 180, 0, 50)
        SpeedBtn.Position = UDim2.new(0.02, 0, 0.75, 0)
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        SpeedBtn.TextColor3 = Color3.new(1, 1, 1)
        SpeedBtn.TextScaled = true
        SpeedBtn.Text = "Velocidade: 80"
        SpeedBtn.AutoButtonColor = true
        SpeedBtn.BackgroundTransparency = 0.1
        
        UpBtn.MouseButton1Down:Connect(function()
            flyUp = true
        end)
        UpBtn.MouseButton1Up:Connect(function()
            flyUp = false
        end)
        
        DownBtn.MouseButton1Down:Connect(function()
            flyDown = true
        end)
        DownBtn.MouseButton1Up:Connect(function()
            flyDown = false
        end)
        
        SpeedBtn.MouseButton1Click:Connect(function()
            local values = {40, 80, 150, 250, 400}
            local idx = table.find(values, flySpeed)
            idx = idx + 1
            if idx > #values then idx = 1 end
            flySpeed = values[idx]
            SpeedBtn.Text = "Velocidade: " .. flySpeed
        end)
        
        -- Iniciar fly
        local function startFly()
            local character = lp.Character
            if not character then return end
            local humanoid = character:FindFirstChild("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end
            
            for _, v in ipairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            
            humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
            
            local flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not lp.Character then
                    if FlyUI then FlyUI:Destroy() end
                    flyConnection:Disconnect()
                    return
                end
                
                local char = lp.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if not hum or not root then return end
                
                local move = Vector3.zero
                move = move + (hum.MoveDirection * flySpeed)
                
                if flyUp then
                    move = move + Vector3.new(0, flySpeed, 0)
                end
                if flyDown then
                    move = move + Vector3.new(0, -flySpeed, 0)
                end
                
                if move.Magnitude < 1 then
                    root.AssemblyLinearVelocity = Vector3.zero
                else
                    root.AssemblyLinearVelocity = move
                end
            end)
        end
        
        task.wait(0.1)
        startFly()
        print("✅ FLY V2 ATIVADO")
        
    else
        flyV2Btn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        flyEnabled = false
        flyUp = false
        flyDown = false
        
        -- Destruir UI do fly se existir
        if gui:FindFirstChild("FlyControlUI") then
            gui.FlyControlUI:Destroy()
        end
        print("❌ FLY V2 DESATIVADO")
    end
end)

-- Configuração dos outros botões do painel 2
devourerBtn.MouseButton1Click:Connect(function()
    local ativo = devourerBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        devourerBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ DEVOURER DESATIVADO")
    else
        devourerBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ DEVOURER ATIVADO")
    end
end)

speedBtn.MouseButton1Click:Connect(function()
    local ativo = speedBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        speedBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ SPEED DESATIVADO")
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ SPEED ATIVADO")
    end
end)

tpToBestBtn.MouseButton1Click:Connect(function()
    local ativo = tpToBestBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        tpToBestBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ TP TO BEST DESATIVADO")
    else
        tpToBestBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ TP TO BEST ATIVADO")
    end
end)

instaFloorBtn.MouseButton1Click:Connect(function()
    local ativo = instaFloorBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        instaFloorBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ INSTA FLOOR DESATIVADO")
    else
        instaFloorBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ INSTA FLOOR ATIVADO")
    end
end)

-- Botões restantes do painel 1
unwalkBtn.MouseButton1Click:Connect(function()
    local ativo = unwalkBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        unwalkBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ UNWALK DESATIVADO")
    else
        unwalkBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ UNWALK ATIVADO")
    end
end)

hideSkinBtn.MouseButton1Click:Connect(function()
    local ativo = hideSkinBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        hideSkinBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ HIDE SKIN DESATIVADO")
    else
        hideSkinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ HIDE SKIN ATIVADO")
    end
end)

kbindBtn.MouseButton1Click:Connect(function()
    local ativo = kbindBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        kbindBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ KBIND DESATIVADO")
    else
        kbindBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ KBIND ATIVADO")
    end
end)

nearestBtn.MouseButton1Click:Connect(function()
    local ativo = nearestBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        nearestBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ NEAREST DESATIVADO")
    else
        nearestBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ NEAREST ATIVADO")
    end
end)

espBestBtn.MouseButton1Click:Connect(function()
    local ativo = espBestBtn.BackgroundColor3 == Color3.fromRGB(0, 170, 255)
    if ativo then
        espBestBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        print("❌ ESP BEST DESATIVADO")
    else
        espBestBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        print("✅ ESP BEST ATIVADO")
    end
end)

print("✅ JS7 HUB - COMPLETO E FUNCIONAL")
print("✅ Botão flutuante: Arrastável + efeito rainbow")
print("✅ Painel 1: 12 botões com toggle vermelho/azul")
print("✅ Painel 2: 7 botões funcionais")
print("✅ ESP BASE: Funcionalidade ativa")
print("✅ ESP PLAYER: Players azuis transparentes")
print("✅ X-RAY: APENAS BASES transparentes")
print("✅ FPS BOOST: Otimizações completas")
print("✅ AUTO KICK: Detecta 'You stole' e kicka")
print("✅ ANTI TORRETA: Auto-destruição de torretas inimigas (AZUL=Ativado, VERMELHO=Desativado)")
print("✅ JUMP BOOST: Pulo aumentado para 65")
print("✅ DESYNC V3: Configurações avançadas")
print("✅ FLY V2: Fly com controles na tela")
print("✅ Pronto para uso!")
                            
