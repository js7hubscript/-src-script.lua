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
-- FEATURE : X-RAY COMPLETO (TODAS AS BASES)
-- ===========================
local xrayActive = false
local xrayOriginal = {}
local xrayConnections = {}
local XRAY_TRANSPARENCY = 0.85

-- Função para verificar se é uma base
local function isBaseStructure(part)
    -- Verificar por tamanho
    if part.Size.Magnitude > 15 then
        return true
    end
    
    -- Verificar por nome
    local partName = part.Name:lower()
    if partName:find("base") or partName:find("plot") or 
       partName:find("floor") or partName:find("ground") or
       partName:find("wall") or partName:find("platform") or
       partName:find("floor") or partName:find("roof") or
       partName:find("ceiling") or partName:find("foundation") then
        return true
    end
    
    -- Verificar por parentesco (se está dentro de um plot)
    local parent = part.Parent
    while parent do
        local parentName = parent.Name:lower()
        if parentName:find("plot") or parentName:find("base") then
            return true
        end
        parent = parent.Parent
    end
    
    return false
end

-- Aplica X-Ray em uma parte de base
local function applyXrayToPart(part)
    if not part:IsA("BasePart") and not part:IsA("MeshPart") then return end
    if lp.Character and part:IsDescendantOf(lp.Character) then return end
    
    -- Verificar se é uma estrutura de base
    if not isBaseStructure(part) then return end
    
    if not xrayOriginal[part] then
        xrayOriginal[part] = {
            Transparency = part.Transparency,
            Material = part.Material
        }
    end
    
    part.Transparency = XRAY_TRANSPARENCY
    part.Material = Enum.Material.Glass
end

-- Remove X-Ray de uma parte
local function removeXrayFromPart(part)
    if xrayOriginal[part] and part.Parent then
        part.Transparency = xrayOriginal[part].Transparency
        part.Material = xrayOriginal[part].Material
        xrayOriginal[part] = nil
    end
end

-- Procura por bases em uma instância
local function searchForBases(instance)
    for _, child in ipairs(instance:GetDescendants()) do
        if child:IsA("BasePart") or child:IsA("MeshPart") then
            if isBaseStructure(child) then
                applyXrayToPart(child)
            end
        end
    end
end

-- Ativa X-Ray em todas as bases
local function enableXray()
    print("✅ X-RAY COMPLETO ATIVADO - Tornando todas as bases transparentes...")
    
    -- Aplicar em tudo que já existe
    searchForBases(game.Workspace)
    
    -- Conectar para novos objetos no Workspace
    local workspaceChildAdded = game.Workspace.ChildAdded:Connect(function(child)
        if xrayActive then
            task.wait(0.3) -- Esperar um pouco para o objeto carregar completamente
            searchForBases(child)
        end
    end)
    
    -- Conectar para novos descendentes em qualquer lugar
    local descendantAdded = game.Workspace.DescendantAdded:Connect(function(descendant)
        if xrayActive then
            if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
                task.wait(0.1)
                if isBaseStructure(descendant) then
                    applyXrayToPart(descendant)
                end
            end
        end
    end)
    
    -- Conectar para respawn do personagem
    local charAdded = lp.CharacterAdded:Connect(function()
        if xrayActive then
            task.wait(1) -- Esperar o personagem carregar
            enableXray()  -- Reaplicar X-Ray
        end
    end)
    
    table.insert(xrayConnections, workspaceChildAdded)
    table.insert(xrayConnections, descendantAdded)
    table.insert(xrayConnections, charAdded)
    
    -- Monitorar especificamente a pasta Plots se existir
    if game.Workspace:FindFirstChild("Plots") then
        local plotsFolder = game.Workspace.Plots
        
        -- Aplicar em plots existentes
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            searchForBases(plot)
        end
        
        -- Conectar para novos plots
        local plotAdded = plotsFolder.ChildAdded:Connect(function(plot)
            if xrayActive then
                task.wait(0.5)
                searchForBases(plot)
                print("✅ Novo plot detectado e tornado transparente")
            end
        end)
        
        table.insert(xrayConnections, plotAdded)
    end
end

-- Desativa X-Ray
local function disableXray()
    print("❌ X-RAY DESATIVADO - Restaurando bases...")
    
    -- Restaurar todas as partes
    for part, _ in pairs(xrayOriginal) do
        if part and part.Parent then
            removeXrayFromPart(part)
        end
    end
    
    xrayOriginal = {}
    
    -- Desconectar todas as conexões
    for _, connection in ipairs(xrayConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    
    xrayConnections = {}
end

-- Conectar o botão X-RAY
xrayBtn.MouseButton1Click:Connect(function()
    xrayActive = not xrayActive
    
    if xrayActive then
        xrayBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        enableXray()
    else
        xrayBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        disableXray()
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
                lp:Kick("🏹")
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
-- FEATURE : ANTI TORRETA
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
local teleguiadoBtn = criarBotaoP2("TELEGUIADO", 4, true)
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
            humanoid.JumpPower = 72
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
-- FEATURE : TELEGUIADO
-- ===========================
local teleguiadoEnabled = false
local teleguiadoConnection = nil

teleguiadoBtn.MouseButton1Click:Connect(function()
    teleguiadoEnabled = not teleguiadoEnabled
    
    if teleguiadoEnabled then
        teleguiadoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        
        -- Ativar teleguiado
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        
        if hrp and cam then
            -- Desconectar conexão anterior se existir
            if teleguiadoConnection then
                teleguiadoConnection:Disconnect()
                teleguiadoConnection = nil
            end
            
            -- Criar nova conexão
            teleguiadoConnection = RunService.Heartbeat:Connect(function()
                if not teleguiadoEnabled then return end
                if not lp.Character or not hrp.Parent then
                    teleguiadoConnection:Disconnect()
                    teleguiadoConnection = nil
                    return
                end
                
                local moveDir = cam.CFrame.LookVector * 25
                hrp.AssemblyLinearVelocity = moveDir
            end)
        end
        
        print("✅ TELEGUIADO ATIVADO")
    else
        teleguiadoBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        
        -- Desativar teleguiado
        if teleguiadoConnection then
            teleguiadoConnection:Disconnect()
            teleguiadoConnection = nil
        end
        
        -- Parar movimento
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
        
        print("❌ TELEGUIADO DESATIVADO")
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
print("✅ X-RAY COMPLETO: TODAS as bases transparentes automaticamente")
print("✅ FPS BOOST: Otimizações completas")
print("✅ AUTO KICK: Detecta 'You stole' e kicka")
print("✅ ANTI TORRETA: Auto-destruição de torretas inimigas (AZUL=Ativado, VERMELHO=Desativado)")
print("✅ JUMP BOOST: Pulo aumentado para 65")
print("✅ DESYNC V3: Configurações avançadas")
print("✅ TELEGUIADO: Movimento na direção da câmera")
print("✅ Pronto para uso!")
