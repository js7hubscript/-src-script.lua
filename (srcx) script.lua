loadstring([[
-- SERVIÇOS
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local player = lp

local gui = Instance.new("ScreenGui")
gui.Name = "JS7HubV2"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

-- BOTÃO FLUTUANTE
local float = Instance.new("TextButton", gui)
float.Size = UDim2.new(0, 55, 0, 55)
float.Position = UDim2.new(0, 15, 0.5, -27)
float.Text = ""  
float.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
float.BackgroundTransparency = 0.4
float.BorderSizePixel = 0
Instance.new("UICorner", float).CornerRadius = UDim.new(1, 0)

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

-- PAINEL 1 (ORIGINAL - AZUL)
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 144, 0, 208)
menu.Position = UDim2.new(0.5, -72, 0.5, -104)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
menu.BackgroundTransparency = 0.35
menu.BorderSizePixel = 0
menu.Visible = false
menu.Active = true
menu.Draggable = true
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 2) 
title.BackgroundTransparency = 1
title.Text = "JS7 HUB"
title.Font = Enum.Font.Arcade
title.TextSize = 11
title.TextColor3 = Color3.fromRGB(0, 255, 255)

float.MouseButton1Click:Connect(function() 
    menu.Visible = not menu.Visible 
end)

local function addBtn(text, size, pos, isAltColor, subText, callback)
    local b = Instance.new("TextButton", menu)
    b.Size = size
    b.Position = pos
    b.Text = text or ""
    b.Font = Enum.Font.Arcade 
    b.TextSize = 8 
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextWrapped = true
    b.BackgroundColor3 = isAltColor and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(30, 30, 35)
    b.BackgroundTransparency = 0.6 
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    
    local s = Instance.new("UIStroke", b)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(0, 0, 0) 
    s.Thickness = 1.2 
    s.Transparency = 0.2

    if subText then
        local sub = Instance.new("TextLabel", b)
        sub.Size = UDim2.new(1, 0, 0, 8)
        sub.Position = UDim2.new(0, 0, 0.60, 0) 
        sub.BackgroundTransparency = 1
        sub.Text = subText
        sub.TextColor3 = Color3.fromRGB(0, 255, 255) 
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

local Y_START = 0.14
local Y_GAP = 0.165 
local BTN_H = 31

-- Toggle status
local toggleStatus = {
    antiTurret = false,
    desyncV3 = false,
    flyV2 = false,
    flyToBest = false,
}

-- ANTI TURRET
addBtn("ANTI TURRET", UDim2.new(0, 64, 0, BTN_H), UDim2.new(0.04, 0, Y_START, 0), false, nil, function()
    toggleStatus.antiTurret = not toggleStatus.antiTurret
    local active = toggleStatus.antiTurret

    -- Seu código original do Anti Turret
    local autoSentry = active
    local playerSentries = {}

    local function findPlayerBase()
        local char = player.Character
        if not char then return nil end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in pairs(plots:GetChildren()) do
            if plot:FindFirstChild("Owner") and plot.Owner.Value == player then
                return plot
            end
        end
        return nil
    end

    local function isPlayerSentry(sentryObj)
        if playerSentries[sentryObj] then return true end
        local char = player.Character
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
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not part then return end
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local originalTool = humanoid:FindFirstChildOfClass("Tool")
        local bat = originalTool or player.Backpack:FindFirstChild("Bat") or player.Backpack:FindFirstChild("bat")
        if bat then
            if originalTool ~= bat then
                pcall(function() humanoid:EquipTool(bat) end)
                task.wait(0.2)
            end
            task.spawn(function()
                while autoSentry and part.Parent do
                    pcall(function() part.CFrame = hrp.CFrame * CFrame.new(0,0,-3) end)
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
        task.spawn(function()
            while autoSentry do
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name:lower():find("sentry_") then
                        if not isPlayerSentry(obj) then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then AttackSentry(part) end
                        end
                    end
                end
                task.wait(0.4)
            end
        end)
    end

    if active then StartAutoSentry() end

    return active
end)

-- DESYNC V3
addBtn("DESYNC V3", UDim2.new(0, 64, 0, BTN_H), UDim2.new(0.51, 0, Y_START, 0), false, nil, function()
    toggleStatus.desyncV3 = not toggleStatus.desyncV3
    local active = toggleStatus.desyncV3

    if active then
        -- Código original do DESYNC V3
        local FFlags = { GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000, LargeReplicatorWrite5 = true, LargeReplicatorEnabled9 = true, AngularVelociryLimit = 360, TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646, S2PhysicsSenderRate = 15000, DisableDPIScale = true, MaxDataPacketPerSend = 2147483647, PhysicsSenderMaxBandwidthBps = 20000, TimestepArbiterHumanoidLinearVelThreshold = 21, MaxMissedWorldStepsRemembered = -2147483648, PlayerHumanoidPropertyUpdateRestrict = true, SimDefaultHumanoidTimestepMultiplier = 0, StreamJobNOUVolumeLengthCap = 2147483647, DebugSendDistInSteps = -2147483648, GameNetDontSendRedundantNumTimes = 1, CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1, CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1, LargeReplicatorSerializeRead3 = true, ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647, CheckPVCachedVelThresholdPercent = 10, CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1, GameNetDontSendRedundantDeltaPositionMillionth = 1, InterpolationFrameVelocityThresholdMillionth = 5, StreamJobNOUVolumeCap = 2147483647, InterpolationFrameRotVelocityThresholdMillionth = 5, CheckPVCachedRotVelThresholdPercent = 10, WorldStepMax = 30, InterpolationFramePositionThresholdMillionth = 5, TimestepArbiterHumanoidTurningVelThreshold = 1, SimOwnedNOUCountThresholdMillionth = 2147483647, GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000, NextGenReplicatorEnabledWrite4 = true, TimestepArbiterOmegaThou = 1073741823, MaxAcceptableUpdateDelay = 1, LargeReplicatorSerializeWrite4 = true }
        local player = Players.LocalPlayer
        local function respawnar(plr)
            local rcdEnabled, wasHidden = false, false
            if gethidden then rcdEnabled, wasHidden = gethidden(workspace, 'RejectCharacterDeletions') ~= Enum.RejectCharacterDeletions.Disabled end
            if rcdEnabled and replicatesignal then
                replicatesignal(plr.ConnectDiedSignalBackend)
                task.wait(Players.RespawnTime - 0.1)
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
        for name, value in pairs(FFlags) do
            pcall(function() setfflag(tostring(name), tostring(value)) end)
        end
        respawnar(player)
    end

    return active
end)

-- FLY V2
addBtn("FLY V2", UDim2.new(0, 133, 0, BTN_H), UDim2.new(0.04, 0, Y_START + (Y_GAP*4), 0), false, nil, function()
    toggleStatus.flyV2 = not toggleStatus.flyV2
    local active = toggleStatus.flyV2

    if active then
        -- Seu código original Fly V2
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local Fly = { Speed = 80, Up = false, Down = false, Enabled = true }

        local function equipGrappleHook()
            local char = player.Character
            if not char then return end
            local backpack = player:FindFirstChild("Backpack")
            if not backpack then return end
            local hook = backpack:FindFirstChild("Grapple Hook") or char:FindFirstChild("Grapple Hook")
            if not hook then return end
            if hook.Parent == backpack then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(hook) end
            end
        end

        local function spamGrappleHook()
            local pkg = ReplicatedStorage:FindFirstChild("Packages")
            if not pkg then return end
            pkg = pkg:FindFirstChild("Net")
            if not pkg then return end
            local remote = pkg:FindFirstChild("RE/UseItem")
            if not remote then return end
            pcall(function() remote:FireServer(0.23450689315795897) end)
        end

        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end

        task.wait(0.2)
        humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)

        local flyConn
        flyConn = RunService.Heartbeat:Connect(function()
            if not toggleStatus.flyV2 then
                flyConn:Disconnect()
                return
            end
            if not player.Character then return end
            local move = Vector3.zero
            move = move + (humanoid.MoveDirection * Fly.Speed)
            if Fly.Up then move = move + Vector3.new(0, Fly.Speed, 0) end
            if Fly.Down then move = move + Vector3.new(0, -Fly.Speed, 0) end
            if move.Magnitude < 1 then hrp.AssemblyLinearVelocity = Vector3.zero
            else hrp.AssemblyLinearVelocity = move end
        end)

        task.spawn(function()
            while toggleStatus.flyV2 do
                task.wait(1)
                equipGrappleHook()
            end
        end)
        RunService.Heartbeat:Connect(spamGrappleHook)
    end

    return active
end)

-- Outros botões básicos
addBtn("NOR", UDim2.new(0, 36, 0, BTN_H), UDim2.new(0.40, 0, Y_START + Y_GAP, 0))
addBtn("⇄", UDim2.new(0, 30, 0, BTN_H), UDim2.new(0.67, 0, Y_START + Y_GAP, 0))
addBtn("SPEED", UDim2.new(0, 64, 0, BTN_H), UDim2.new(0.04, 0, Y_START + (Y_GAP*2), 0), true)
addBtn("INF JUMP", UDim2.new(0, 64, 0, BTN_H), UDim2.new(0.51, 0, Y_START + (Y_GAP*2), 0))
addBtn("STEAL FLOOR", UDim2.new(0, 94, 0, BTN_H), UDim2.new(0.04, 0, Y_START + (Y_GAP*3), 0))
addBtn("⇄", UDim2.new(0, 32, 0, BTN_H), UDim2.new(0.71, 0, Y_START + (Y_GAP*3), 0))

-- ==============================================
-- PAINEL 2 (NOVO - LATERAL COM FUNÇÕES ESPECÍFICAS)
-- ==============================================

local sidePanel = Instance.new("Frame", gui)
sidePanel.Size = UDim2.new(0, 100, 0, 320)
sidePanel.Position = UDim2.new(1, -105, 0.5, -160)
sidePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 18) -- AZUL IGUAL AO PRIMEIRO
sidePanel.BackgroundTransparency = 0.35
sidePanel.BorderSizePixel = 0
sidePanel.Active = true
sidePanel.Draggable = true
Instance.new("UICorner", sidePanel).CornerRadius = UDim.new(0, 14)

-- DRAG PARA O PAINEL 2
do
    local drag, startPos, startUI
    sidePanel.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startPos = i.Position
            startUI = sidePanel.Position
        end
    end)
    sidePanel.InputEnded:Connect(function() drag = false end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - startPos
            sidePanel.Position = UDim2.new(startUI.X.Scale, startUI.X.Offset + delta.X, startUI.Y.Scale, startUI.Y.Offset + delta.Y)
        end
    end)
end

local sideTitle = Instance.new("TextLabel", sidePanel)
sideTitle.Size = UDim2.new(1, 0, 0, 20)
sideTitle.Position = UDim2.new(0, 0, 0, 5)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "JS7 HUB"
sideTitle.Font = Enum.Font.Arcade
sideTitle.TextSize = 10
sideTitle.TextColor3 = Color3.fromRGB(0, 255, 255) -- CIANO IGUAL AO PRIMEIRO

-- STATUS DOS TOGGLES DO PAINEL 2
local sideToggleStatus = {
    espBest = false,
    espBase = false,
    espPlayer = false,
    autoKick = false,
    nearest = false,
    xray = false,
    fpsBoost = false,
    anti = false,
    unwalk = false,
    antiRagdoll = false,
    hideSkin = false,
    discord = false,
    kbind = false
}

-- FUNÇÃO PARA CRIAR BOTÕES (PAINEL 2 - MESMO ESTILO AZUL)
local function createSideBtn(text, size, pos, callback)
    local b = Instance.new("TextButton", sidePanel)
    b.Size = size
    b.Position = pos
    b.Text = text or ""
    b.Font = Enum.Font.Arcade
    b.TextSize = 7
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextWrapped = true
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- AZUL ESCURO
    b.BackgroundTransparency = 0.6
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local s = Instance.new("UIStroke", b)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(0, 0, 0)
    s.Thickness = 1.2
    s.Transparency = 0.2

    if callback then
        b.MouseButton1Click:Connect(function()
            local active = callback()
            b.BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 35)
            return active
        end)
    end

    return b
end

-- DIMENSÕES DOS BOTÕES (PAINEL 2)
local BTN_WIDTH = 90
local BTN_HEIGHT_SMALL = 22
local BTN_HEIGHT_LARGE = 25
local LEFT_POS = 0.05
local RIGHT_POS = 0.52
local VERTICAL_SPACING = 0.08

-- 📍 LINHA 1: ESP BEST (botão grande, centralizado)
createSideBtn("ESP BEST", 
    UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT_LARGE), 
    UDim2.new(0.05, 0, 0.12, 0), function()
    sideToggleStatus.espBest = not sideToggleStatus.espBest
    local active = sideToggleStatus.espBest
    -- Adicione aqui o código da ESP Best
    return active
end)

-- 📍 LINHA 2: ESP BASE (esquerdo) e ESP PLAYER (direito)
createSideBtn("ESP BASE", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(LEFT_POS, 0, 0.23, 0), function()
    sideToggleStatus.espBase = not sideToggleStatus.espBase
    local active = sideToggleStatus.espBase
    -- Adicione aqui o código da ESP Base
    return active
end)

createSideBtn("ESP PLAYER", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(RIGHT_POS, 0, 0.23, 0), function()
    sideToggleStatus.espPlayer = not sideToggleStatus.espPlayer
    local active = sideToggleStatus.espPlayer
    -- Adicione aqui o código da ESP Player
    return active
end)

-- 📍 LINHA 3: AUTO KICK (esquerdo) e NEAREST (direito)
createSideBtn("AUTO KICK", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(LEFT_POS, 0, 0.31, 0), function()
    sideToggleStatus.autoKick = not sideToggleStatus.autoKick
    local active = sideToggleStatus.autoKick
    -- Adicione aqui o código do Auto Kick
    return active
end)

createSideBtn("NEAREST", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(RIGHT_POS, 0, 0.31, 0), function()
    sideToggleStatus.nearest = not sideToggleStatus.nearest
    local active = sideToggleStatus.nearest
    -- Adicione aqui o código do Nearest
    return active
end)

-- 📍 LINHA 4: X-RAY (esquerdo) e FPS BOOST (direito)
createSideBtn("X-RAY", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(LEFT_POS, 0, 0.39, 0), function()
    sideToggleStatus.xray = not sideToggleStatus.xray
    local active = sideToggleStatus.xray
    -- Adicione aqui o código do X-Ray
    return active
end)

createSideBtn("FPS BOOST", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(RIGHT_POS, 0, 0.39, 0), function()
    sideToggleStatus.fpsBoost = not sideToggleStatus.fpsBoost
    local active = sideToggleStatus.fpsBoost
    -- Adicione aqui o código do FPS Boost
    return active
end)

-- 📍 LINHA 5: ANTI (esquerdo) e UNWALK (direito)
createSideBtn("ANTI", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(LEFT_POS, 0, 0.47, 0), function()
    sideToggleStatus.anti = not sideToggleStatus.anti
    local active = sideToggleStatus.anti
    -- Adicione aqui o código do Anti
   return active
end)

createSideBtn("UNWALK", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(RIGHT_POS, 0, 0.47, 0), function()
    sideToggleStatus.unwalk = not sideToggleStatus.unwalk
    local active = sideToggleStatus.unwalk
    -- Adicione aqui o código do Unwalk
    return active
end)

-- 📍 LINHA 6: ANTIRAGDOLL (esquerdo) e HIDE SKIN (direito)
createSideBtn("ANTIRAGDOLL", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(LEFT_POS, 0, 0.55, 0), function()
    sideToggleStatus.antiRagdoll = not sideToggleStatus.antiRagdoll
    local active = sideToggleStatus.antiRagdoll
    -- Adicione aqui o código do Anti Ragdoll
    return active
end)

createSideBtn("HIDE SKIN", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(RIGHT_POS, 0, 0.55, 0), function()
    sideToggleStatus.hideSkin = not sideToggleStatus.hideSkin
    local active = sideToggleStatus.hideSkin
    -- Adicione aqui o código do Hide Skin
    return active
end)

-- 📍 PARTE INFERIOR: DISCORD (esquerdo) e KBIND (direito)
createSideBtn("DISCORD", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(LEFT_POS, 0, 0.88, 0), function()
    sideToggleStatus.discord = not sideToggleStatus.discord
    local active = sideToggleStatus.discord
    setclipboard("https://discord.gg/55BBE7czB")
    return active
end)

createSideBtn("KBIND", 
    UDim2.new(0, 42, 0, BTN_HEIGHT_SMALL), 
    UDim2.new(RIGHT_POS, 0, 0.88, 0), function()
    sideToggleStatus.kbind = not sideToggleStatus.kbind
    local active = sideToggleStatus.kbind
    -- Adicione aqui o código do KBind
    return active
end)

-- ANIMAÇÃO DE ENTRADA DO PAINEL 2
do
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {Position = UDim2.new(1, -105, 0.5, -160)}
    local tween = TweenService:Create(sidePanel, tweenInfo, goal)
    sidePanel.Position = UDim2.new(1, 5, 0.5, -160)
    tween:Play()
end
]])()
