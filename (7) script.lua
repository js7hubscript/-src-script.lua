-- Delta Executor - Painel de Funções Arcade
-- Compatível com Delta Executor e similares

if not isfolder then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro Delta Executor",
        Text = "Este script requer Delta Executor",
        Duration = 5
    })
    return
end

-- Configurações
local Settings = {
    ButtonColor = Color3.fromRGB(255, 50, 50),
    PanelColor = Color3.fromRGB(20, 20, 40),
    BorderColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    ButtonSize = 60,
    PanelWidth = 320,
    PanelHeight = 400,
    Font = Enum.Font.Arcade
}

-- Variáveis globais
local DrawingLib = draw or drawing
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Verificar se DrawingLib está disponível
if not DrawingLib then
    warn("Delta Drawing Library não encontrada!")
    return
end

-- Estado do painel
local PanelState = {
    IsOpen = false,
    IsDragging = false,
    DragObject = nil,
    ButtonPosition = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 80, workspace.CurrentCamera.ViewportSize.Y - 80),
    PanelPosition = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2 - 160, workspace.CurrentCamera.ViewportSize.Y/2 - 200),
    Dragging = false,
    DragStart = Vector2.new(0, 0),
    ElementStart = Vector2.new(0, 0)
}

-- Elementos de desenho
local Drawings = {
    Button = {
        Circle = nil,
        Text = nil
    },
    Panel = {
        Background = nil,
        Border = nil,
        Header = nil,
        Title = nil,
        CloseButton = nil,
        CloseText = nil
    },
    Functions = {}
}

-- Funções de exemplo
local ExampleFunctions = {
    {Name = "TP para Spawn", Function = function()
        local character = game.Players.LocalPlayer.Character
        if character then
            character:MoveTo(Vector3.new(0, 5, 0))
        end
    end},
    {Name = "Super Pulo", Function = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = 100
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end},
    {Name = "Velocidade 2x", Function = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 32
        end
    end},
    {Name = "Noclip (Toggle)", Function = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not part.CanCollide
            end
        end
    end},
    {Name = "Gerar Dinheiro", Function = function()
        -- Exemplo: Procurar por um gui de dinheiro para modificar
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name:lower():find("cash") or obj.Name:lower():find("money") then
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    obj.Value = obj.Value + 1000
                end
            end
        end
    end},
    {Name = "ESP (Toggle)", Function = function()
        -- Sistema ESP simples
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                local character = player.Character
                if character then
                    local highlight = character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight:Destroy()
                    else
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Highlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                        highlight.Parent = character
                    end
                end
            end
        end
    end},
    {Name = "Fly (Toggle)", Function = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end},
    {Name = "Infinita Vida", Function = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.MaxHealth = math.huge
            character.Humanoid.Health = math.huge
        end
    end},
    {Name = "Arma Infinita", Function = function()
        for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for _, v in pairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name == "Ammo" or v.Name == "Clip") then
                        v.Value = 9999
                    end
                end
            end
        end
    end},
    {Name = "Modo Deus", Function = function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.MaxHealth = math.huge
            character.Humanoid.Health = math.huge
            character.Humanoid.WalkSpeed = 50
            character.Humanoid.JumpPower = 100
        end
    end}
}

-- Criar elementos de desenho
local function CreateDrawingObjects()
    -- Botão redondo
    Drawings.Button.Circle = DrawingLib.new("Circle")
    Drawings.Button.Circle.Visible = true
    Drawings.Button.Circle.Color = Settings.ButtonColor
    Drawings.Button.Circle.Thickness = 2
    Drawings.Button.Circle.Filled = true
    Drawings.Button.Circle.Radius = Settings.ButtonSize / 2
    Drawings.Button.Circle.Position = PanelState.ButtonPosition
    
    -- Texto do botão
    Drawings.Button.Text = DrawingLib.new("Text")
    Drawings.Button.Text.Visible = true
    Drawings.Button.Text.Color = Settings.TextColor
    Drawings.Button.Text.Size = 20
    Drawings.Button.Text.Text = "F"
    Drawings.Button.Text.Center = true
    Drawings.Button.Text.Position = PanelState.ButtonPosition
    Drawings.Button.Text.Font = 3  -- Fonte em negrito
    
    -- Painel de fundo
    Drawings.Panel.Background = DrawingLib.new("Square")
    Drawings.Panel.Background.Visible = false
    Drawings.Panel.Background.Color = Settings.PanelColor
    Drawings.Panel.Background.Filled = true
    Drawings.Panel.Background.Size = Vector2.new(Settings.PanelWidth, Settings.PanelHeight)
    Drawings.Panel.Background.Position = PanelState.PanelPosition
    Drawings.Panel.Background.Thickness = 1
    
    -- Borda do painel
    Drawings.Panel.Border = DrawingLib.new("Square")
    Drawings.Panel.Border.Visible = false
    Drawings.Panel.Border.Color = Settings.BorderColor
    Drawings.Panel.Border.Filled = false
    Drawings.Panel.Border.Size = Vector2.new(Settings.PanelWidth, Settings.PanelHeight)
    Drawings.Panel.Border.Position = PanelState.PanelPosition
    Drawings.Panel.Border.Thickness = 2
    
    -- Cabeçalho do painel
    Drawings.Panel.Header = DrawingLib.new("Square")
    Drawings.Panel.Header.Visible = false
    Drawings.Panel.Header.Color = Color3.fromRGB(40, 40, 70)
    Drawings.Panel.Header.Filled = true
    Drawings.Panel.Header.Size = Vector2.new(Settings.PanelWidth, 40)
    Drawings.Panel.Header.Position = PanelState.PanelPosition
    Drawings.Panel.Header.Thickness = 1
    
    -- Título do painel
    Drawings.Panel.Title = DrawingLib.new("Text")
    Drawings.Panel.Title.Visible = false
    Drawings.Panel.Title.Color = Settings.TextColor
    Drawings.Panel.Title.Size = 18
    Drawings.Panel.Title.Text = "DELTA FUNCTIONS PANEL"
    Drawings.Panel.Title.Position = PanelState.PanelPosition + Vector2.new(10, 10)
    Drawings.Panel.Title.Font = 3
    
    -- Botão de fechar
    Drawings.Panel.CloseButton = DrawingLib.new("Circle")
    Drawings.Panel.CloseButton.Visible = false
    Drawings.Panel.CloseButton.Color = Settings.ButtonColor
    Drawings.Panel.CloseButton.Filled = true
    Drawings.Panel.CloseButton.Radius = 12
    Drawings.Panel.CloseButton.Position = PanelState.PanelPosition + Vector2.new(Settings.PanelWidth - 25, 20)
    Drawings.Panel.CloseButton.Thickness = 1
    
    -- Texto do botão fechar
    Drawings.Panel.CloseText = DrawingLib.new("Text")
    Drawings.Panel.CloseText.Visible = false
    Drawings.Panel.CloseText.Color = Settings.TextColor
    Drawings.Panel.CloseText.Size = 16
    Drawings.Panel.CloseText.Text = "X"
    Drawings.Panel.CloseText.Center = true
    Drawings.Panel.CloseText.Position = PanelState.PanelPosition + Vector2.new(Settings.PanelWidth - 25, 20)
    Drawings.Panel.CloseText.Font = 3
    
    -- Criar botões das funções
    for i, func in ipairs(ExampleFunctions) do
        local yPos = 50 + (i - 1) * 35
        
        -- Fundo do botão
        local buttonBg = DrawingLib.new("Square")
        buttonBg.Visible = false
        buttonBg.Color = Color3.fromRGB(60, 60, 90)
        buttonBg.Filled = true
        buttonBg.Size = Vector2.new(Settings.PanelWidth - 20, 30)
        buttonBg.Position = PanelState.PanelPosition + Vector2.new(10, yPos)
        buttonBg.Thickness = 1
        
        -- Texto do botão
        local buttonText = DrawingLib.new("Text")
        buttonText.Visible = false
        buttonText.Color = Settings.TextColor
        buttonText.Size = 14
        buttonText.Text = func.Name
        buttonText.Position = PanelState.PanelPosition + Vector2.new(15, yPos + 8)
        buttonText.Font = 3
        
        -- Borda do botão (aparece no hover)
        local buttonBorder = DrawingLib.new("Square")
        buttonBorder.Visible = false
        buttonBorder.Color = Settings.BorderColor
        buttonBorder.Filled = false
        buttonBorder.Size = Vector2.new(Settings.PanelWidth - 20, 30)
        buttonBorder.Position = PanelState.PanelPosition + Vector2.new(10, yPos)
        buttonBorder.Thickness = 1
        
        Drawings.Functions[i] = {
            Background = buttonBg,
            Text = buttonText,
            Border = buttonBorder,
            Function = func.Function,
            Index = i
        }
    end
end

-- Mostrar/ocultar painel
local function TogglePanel()
    PanelState.IsOpen = not PanelState.IsOpen
    
    Drawings.Panel.Background.Visible = PanelState.IsOpen
    Drawings.Panel.Border.Visible = PanelState.IsOpen
    Drawings.Panel.Header.Visible = PanelState.IsOpen
    Drawings.Panel.Title.Visible = PanelState.IsOpen
    Drawings.Panel.CloseButton.Visible = PanelState.IsOpen
    Drawings.Panel.CloseText.Visible = PanelState.IsOpen
    
    for _, func in ipairs(Drawings.Functions) do
        func.Background.Visible = PanelState.IsOpen
        func.Text.Visible = PanelState.IsOpen
    end
    
    if PanelState.IsOpen then
        -- Efeito de abertura
        local originalSize = Drawings.Panel.Background.Size
        Drawings.Panel.Background.Size = Vector2.new(10, 10)
        
        -- Animar abertura
        local startTime = tick()
        local duration = 0.3
        
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local elapsed = tick() - startTime
            local progress = math.min(elapsed / duration, 1)
            local ease = 1 - math.pow(1 - progress, 3)  -- Ease out
            
            if progress >= 1 then
                conn:Disconnect()
                Drawings.Panel.Background.Size = originalSize
            else
                local currentWidth = 10 + (originalSize.X - 10) * ease
                local currentHeight = 10 + (originalSize.Y - 10) * ease
                Drawings.Panel.Background.Size = Vector2.new(currentWidth, currentHeight)
                Drawings.Panel.Border.Size = Drawings.Panel.Background.Size
            end
        end)
    end
end

-- Verificar clique em elemento
local function IsMouseOverElement(position, size)
    local mousePos = UserInputService:GetMouseLocation()
    return mousePos.X >= position.X and mousePos.X <= position.X + size.X and
           mousePos.Y >= position.Y and mousePos.Y <= position.Y + size.Y
end

-- Verificar clique no botão redondo
local function IsMouseOverButton()
    local mousePos = UserInputService:GetMouseLocation()
    local buttonCenter = Drawings.Button.Circle.Position
    local distance = (mousePos - buttonCenter).Magnitude
    return distance <= Drawings.Button.Circle.Radius
end

-- Verificar clique no botão de fechar
local function IsMouseOverCloseButton()
    local mousePos = UserInputService:GetMouseLocation()
    local buttonCenter = Drawings.Panel.CloseButton.Position
    local distance = (mousePos - buttonCenter).Magnitude
    return distance <= Drawings.Panel.CloseButton.Radius
end

-- Atualizar posições dos elementos do painel
local function UpdatePanelElements()
    if not PanelState.IsOpen then return end
    
    Drawings.Panel.Background.Position = PanelState.PanelPosition
    Drawings.Panel.Border.Position = PanelState.PanelPosition
    Drawings.Panel.Header.Position = PanelState.PanelPosition
    Drawings.Panel.Title.Position = PanelState.PanelPosition + Vector2.new(10, 10)
    Drawings.Panel.CloseButton.Position = PanelState.PanelPosition + Vector2.new(Settings.PanelWidth - 25, 20)
    Drawings.Panel.CloseText.Position = PanelState.PanelPosition + Vector2.new(Settings.PanelWidth - 25, 20)
    
    for i, func in ipairs(Drawings.Functions) do
        local yPos = 50 + (i - 1) * 35
        func.Background.Position = PanelState.PanelPosition + Vector2.new(10, yPos)
        func.Text.Position = PanelState.PanelPosition + Vector2.new(15, yPos + 8)
        func.Border.Position = PanelState.PanelPosition + Vector2.new(10, yPos)
    end
end

-- Iniciar arrasto
local function StartDrag(dragType)
    PanelState.Dragging = true
    PanelState.DragStart = UserInputService:GetMouseLocation()
    
    if dragType == "button" then
        PanelState.ElementStart = PanelState.ButtonPosition
        PanelState.DragObject = "button"
    elseif dragType == "panel" then
        PanelState.ElementStart = PanelState.PanelPosition
        PanelState.DragObject = "panel"
    end
end

-- Atualizar arrasto
local function UpdateDrag()
    if not PanelState.Dragging then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    local delta = mousePos - PanelState.DragStart
    
    if PanelState.DragObject == "button" then
        PanelState.ButtonPosition = PanelState.ElementStart + delta
        
        Drawings.Button.Circle.Position = PanelState.ButtonPosition
        Drawings.Button.Text.Position = PanelState.ButtonPosition
    elseif PanelState.DragObject == "panel" and PanelState.IsOpen then
        PanelState.PanelPosition = PanelState.ElementStart + delta
        UpdatePanelElements()
    end
end

-- Finalizar arrasto
local function EndDrag()
    PanelState.Dragging = false
    PanelState.DragObject = nil
end

-- Verificar hover nos botões de função
local function CheckFunctionHover()
    if not PanelState.IsOpen then return end
    
    for _, func in ipairs(Drawings.Functions) do
        local isHovering = IsMouseOverElement(func.Background.Position, func.Background.Size)
        func.Border.Visible = isHovering
        
        if isHovering then
            func.Background.Color = Color3.fromRGB(80, 80, 120)
        else
            func.Background.Color = Color3.fromRGB(60, 60, 90)
        end
    end
end

-- Inicializar
CreateDrawingObjects()

-- Loop principal
RunService.RenderStepped:Connect(function()
    -- Atualizar arrasto
    if PanelState.Dragging then
        UpdateDrag()
    end
    
    -- Verificar hover nas funções
    CheckFunctionHover()
    
    -- Verificar clique do mouse
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        if not PanelState.WasMouseDown then
            PanelState.WasMouseDown = true
            
            -- Verificar clique no botão redondo
            if IsMouseOverButton() and not PanelState.Dragging then
                StartDrag("button")
            -- Verificar clique no cabeçalho do painel
            elseif PanelState.IsOpen and IsMouseOverElement(PanelState.PanelPosition, Vector2.new(Settings.PanelWidth, 40)) then
                StartDrag("panel")
            end
        end
    else
        if PanelState.WasMouseDown then
            PanelState.WasMouseDown = false
            
            -- Se estava arrastando, parar
            if PanelState.Dragging then
                EndDrag()
            else
                -- Verificar clique para ações
                if IsMouseOverButton() then
                    TogglePanel()
                elseif PanelState.IsOpen and IsMouseOverCloseButton() then
                    TogglePanel()
                elseif PanelState.IsOpen then
                    -- Verificar clique nas funções
                    for _, func in ipairs(Drawings.Functions) do
                        if IsMouseOverElement(func.Background.Position, func.Background.Size) then
                            -- Executar função com proteção
                            pcall(func.Function)
                            
                            -- Feedback visual
                            local originalColor = func.Background.Color
                            func.Background.Color = Settings.ButtonColor
                            
                            task.wait(0.1)
                            func.Background.Color = originalColor
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- Atualizar visibilidade do texto do botão
    Drawings.Button.Text.Visible = not PanelState.Dragging
end)

-- Limpar quando o script for encerrado
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        EndDrag()
    end
end)

-- Ajustar quando a tela for redimensionada
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    -- Garantir que os elementos não fiquem fora da tela
    local viewportSize = workspace.CurrentCamera.ViewportSize
    
    if PanelState.ButtonPosition.X > viewportSize.X - 30 then
        PanelState.ButtonPosition = Vector2.new(viewportSize.X - 80, PanelState.ButtonPosition.Y)
        Drawings.Button.Circle.Position = PanelState.ButtonPosition
        Drawings.Button.Text.Position = PanelState.ButtonPosition
    end
    
    if PanelState.ButtonPosition.Y > viewportSize.Y - 30 then
        PanelState.ButtonPosition = Vector2.new(PanelState.ButtonPosition.X, viewportSize.Y - 80)
        Drawings.Button.Circle.Position = PanelState.ButtonPosition
        Drawings.Button.Text.Position = PanelState.ButtonPosition
    end
    
    if PanelState.IsOpen then
        if PanelState.PanelPosition.X > viewportSize.X - 100 then
            PanelState.PanelPosition = Vector2.new(viewportSize.X - Settings.PanelWidth - 10, PanelState.PanelPosition.Y)
            UpdatePanelElements()
        end
        
        if PanelState.PanelPosition.Y > viewportSize.Y - 100 then
            PanelState.PanelPosition = Vector2.new(PanelState.PanelPosition.X, viewportSize.Y - Settings.PanelHeight - 10)
            UpdatePanelElements()
        end
    end
end)

-- Mensagem de inicialização
print("======================================")
print("Delta Executor - Painel de Funções")
print("======================================")
print("Botão 'F' vermelho: Arraste para mover")
print("Clique no botão 'F': Abre/fecha painel")
print("Arraste o cabeçalho: Move o painel")
print("Clique em 'X': Fecha painel")
print("Clique nas funções: Executa ações")
print("======================================")

-- Notificação de inicialização
if game:GetService("StarterGui"):GetCore("SendNotification") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Delta Painel Carregado",
        Text = "Painel de funções ativado!",
        Duration = 3
    })
end

-- Função para fechar o painel (pode ser chamada externamente)
local function ClosePanel()
    if PanelState.IsOpen then
        TogglePanel()
    end
end

-- Retornar API para controle externo
return {
    TogglePanel = TogglePanel,
    ClosePanel = ClosePanel,
    AddFunction = function(name, func)
        table.insert(ExampleFunctions, {Name = name, Function = func})
        -- Aqui seria necessário recriar os elementos de desenho
        -- Implementação simplificada por enquanto
    end
                        }
