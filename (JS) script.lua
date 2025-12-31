-- -Euqwj Pack Open Source Sab

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local Workspace = workspace
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Theme colors
local activePurple = Color3.fromRGB(142, 68, 173)
local inactiveGray = Color3.fromRGB(18, 18, 18)
local accentText = Color3.fromRGB(200,200,200)
local bgDark = Color3.fromRGB(12,12,12)
local notifYellow = Color3.fromRGB(255,255,0)

-- Config file helpers
local CONFIG_FOLDER = "PoisonConfigs"
local CONFIG_FILE = CONFIG_FOLDER .. "/settings.json"
local function safeMakeFolder(path) pcall(function() if makefolder then makefolder(path) end end) end
local function safeWriteFile(path, content) pcall(function() if writefile then writefile(path, content) end end) end
local function safeReadFile(path) local ok, out = pcall(function() if readfile then return readfile(path) end end) if ok then return out end return nil end
local function safeIsFile(path) local ok, out = pcall(function() if isfile then return isfile(path) end end); if ok then return out or false end; return false end

-- Settings load/save
local Settings = {}
local function loadSettings()
	Settings = {}
	if safeIsFile(CONFIG_FILE) then
		local raw = safeReadFile(CONFIG_FILE)
		if raw then pcall(function() Settings = HttpService:JSONDecode(raw) or {} end) end
	end
	Settings.PoisonBoost = Settings.PoisonBoost or { JumpBoost = false, InfJump = false, SpeedBoost = { Enabled = false, Value = 85 }, MiniVisible = false }
	Settings.Functions = Settings.Functions or { Visible = false, Noclip = false, GoBest = false, AntiTurret = false, Aimbot = false, BestESP = true, AutoBuy = false }
end
local function saveSettings()
	pcall(function()
		safeMakeFolder(CONFIG_FOLDER)
		safeWriteFile(CONFIG_FILE, HttpService:JSONEncode(Settings or {}))
	end)
end
loadSettings()

-- Notifications
local notifications = {}
local NOTIF_W, NOTIF_H = 340, 44
local function updateNotificationPositions()
	for i, item in ipairs(notifications) do
		local targetY = 10 + (i-1) * (NOTIF_H + 8)
		pcall(function()
			TweenService:Create(item.Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, -NOTIF_W/2, 0, targetY)
			}):Play()
		end)
	end
end
local function showNotification(msg, duration)
	duration = duration or 3
	pcall(function()
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
		frame.Position = UDim2.new(0.5, -NOTIF_W/2, 0, -NOTIF_H)
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 1
		frame.Parent = playerGui
		local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 14)
		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(1, -12, 1, 0)
		label.Position = UDim2.new(0, 6, 0, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = notifYellow
		label.Font = Enum.Font.GothamBold
		label.TextSize = 18
		label.Text = "[ " .. tostring(msg) .. " ]"
		label.TextTransparency = 1
		table.insert(notifications, {Frame = frame, Label = label})
		updateNotificationPositions()
		local tweenIn = TweenService:Create(frame, TweenInfo.new(0.22), {BackgroundTransparency = 0.3})
		local labelIn = TweenService:Create(label, TweenInfo.new(0.22), {TextTransparency = 0})
		tweenIn:Play(); labelIn:Play()
		task.delay(duration, function()
			local tweenOut = TweenService:Create(frame, TweenInfo.new(0.22), {BackgroundTransparency = 1})
			local labelOut = TweenService:Create(label, TweenInfo.new(0.22), {TextTransparency = 1})
			tweenOut:Play(); labelOut:Play()
			local conn
			conn = tweenOut.Completed:Connect(function()
				conn:Disconnect()
				for i, v in ipairs(notifications) do
					if v.Frame == frame then table.remove(notifications, i); break end
				end
				frame:Destroy()
				updateNotificationPositions()
			end)
		end)
	end)
end

-- UI scale helper
local UI_SCALE = 0.85
local function s(n) return math.floor(n * UI_SCALE + 0.5) end

-- draggable helper
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	local header = frame:FindFirstChild("Header") or frame
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then return end
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)
end

-- Player ESP
local PLAYER_ESPS = {}
local function ensurePlayerEspFor(pl)
	if PLAYER_ESPS[pl] then return end
	local function onCharacterAdded(char)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "Poison_PlayerESP"
		box.Adornee = hrp
		box.Size = Vector3.new(3.5, 6, 2)
		box.AlwaysOnTop = true
		box.ZIndex = 10
		box.Color3 = Color3.fromRGB(40,130,255)
		box.Transparency = 0.18
		box.Parent = hrp
		PLAYER_ESPS[pl] = box
	end
	if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
		onCharacterAdded(pl.Character)
	end
	pl.CharacterAdded:Connect(onCharacterAdded)
end
local function enablePlayersESP()
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= player then ensurePlayerEspFor(pl) end
	end
	Players.PlayerAdded:Connect(function(pl) if pl ~= player then ensurePlayerEspFor(pl) end end)
	Players.PlayerRemoving:Connect(function(pl) if PLAYER_ESPS[pl] then pcall(function() PLAYER_ESPS[pl]:Destroy() end); PLAYER_ESPS[pl] = nil end end)
end

-- Helper: findDescendantByNameCI
local function findDescendantByNameCI(root, name)
	if not root then return nil end
	if string.lower(root.Name) == string.lower(name) then return root end
	for _, child in ipairs(root:GetChildren()) do
		local found = findDescendantByNameCI(child, name)
		if found then return found end
	end
	return nil
end

-- BestPlot visual module
local BestPlot = {}
do
	local REFRESH_INTERVAL = 3
	local HIGHLIGHT_TAG = "BestPlotESP_Highlight"
	local PLAYER_HIGHLIGHT_TAG = "BestPlotESP_PlayerHighlight"
	local BILLBOARD_TAG = "BestPlotESP_BillboardContainer"
	local PLOTS_NAME = "Plots"
	local LINE_PART_NAME = "BestPlotESP_Line_" .. tostring(player.UserId)
	local DECOR_FILL = Color3.fromRGB(0, 200, 150)
	local DECOR_OUTLINE = Color3.fromRGB(255, 255, 255)
	local NAME_COLOR = Color3.fromRGB(255,255,255)
	local VALUE_COLOR = Color3.fromRGB(255,221,51)
	local TEXT_STROKE = Color3.fromRGB(0,0,0)
	local LINE_THICKNESS = 0.7

	local currentAdorneePart = nil
	local currentLinePart = nil
	local renderConn = nil
	local running = false
	local loopThread = nil

	local trackedBest = nil
	local trackedBestMissingSince = nil
	local MISSING_GRACE = 2.5

	local function parseSuffixNumber(str)
		if not str then return nil end
		if type(str) ~= "string" then str = tostring(str) end
		local s = string.gsub(str, "%s+", ""):lower()
		s = string.gsub(s, ",", "")
		s = string.gsub(s, "%+", "")
		if string.sub(s, 1, 1) == "$" then s = string.sub(s, 2) end
		s = string.gsub(s, "/.*$", "")
		s = string.gsub(s, "[^%w%.]+$", "")
		local numPart, suffix = string.match(s, "^([%d%.]+)([kmgtbq]?)")
		if not numPart then
			numPart = string.match(s, "([%d%.]+)")
			if not numPart then return nil end
			suffix = string.match(s, "[%d%.]+([kmgtbq])") or ""
		end
		local n = tonumber(numPart)
		if not n then return nil end
		local multipliers = { k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15 }
		local mul = 1
		if suffix and suffix ~= "" then mul = multipliers[suffix] or 1 end
		return n * mul
	end

	local function getGenerationTextFromInstance(inst)
		if not inst then return nil end
		local txt = nil
		if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then txt = inst.Text end
		if (not txt) and inst:IsA("ValueBase") then local v = inst.Value if v ~= nil then txt = tostring(v) end end
		if (not txt) then local ok, genericTxt = pcall(function() return inst.Text end) if ok and genericTxt then txt = genericTxt end end
		if not txt then return nil end
		local cleaned_txt = string.gsub(txt, "%s+", "")
		if string.sub(cleaned_txt, 1, 1) == "$" then return txt end
		return nil
	end

	local function findBasePartForPodium(podium)
		if not podium then return nil end
		local base = findDescendantByNameCI(podium, "Base")
		if base and base:IsA("BasePart") then return base end
		if base then
			for _, d in ipairs(base:GetDescendants()) do if d:IsA("BasePart") then return d end end
		end
		for _, d in ipairs(podium:GetDescendants()) do if d:IsA("BasePart") then return d end end
		return nil
	end

	local function clearESP(keepLine)
		if keepLine == nil then keepLine = true end
		for _, desc in ipairs(playerGui:GetDescendants()) do
			if desc:IsA("Highlight") then
				if desc.Name == HIGHLIGHT_TAG then pcall(function() desc:Destroy() end)
				elseif not keepLine and desc.Name == PLAYER_HIGHLIGHT_TAG then pcall(function() desc:Destroy() end)
				end
			end
			if desc:IsA("ScreenGui") and desc.Name == BILLBOARD_TAG then pcall(function() desc:Destroy() end) end
		end
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc:IsA("Highlight") and desc.Name == HIGHLIGHT_TAG then pcall(function() desc:Destroy() end) end
		end
		if not keepLine then
			if renderConn then pcall(function() renderConn:Disconnect() end); renderConn = nil end
			if currentLinePart and currentLinePart.Parent then pcall(function() currentLinePart:Destroy() end) end
			currentLinePart = nil
			currentAdorneePart = nil
		end
	end

	local function createHighlightForTarget(target)
		if not target then return end
		local highlight = Instance.new("Highlight")
		highlight.Name = HIGHLIGHT_TAG
		highlight.Adornee = target
		highlight.FillColor = DECOR_FILL
		highlight.FillTransparency = 0.6
		highlight.OutlineColor = DECOR_OUTLINE
		highlight.OutlineTransparency = 0
		highlight.Parent = playerGui
		return highlight
	end

	local function createPlayerOutline()
		local char = player.Character
		if not char then char = player.CharacterAdded and player.CharacterAdded:Wait() or nil if not char then return end end
		local adornee = char
		for _, d in ipairs(playerGui:GetDescendants()) do
			if d:IsA("Highlight") and d.Name == PLAYER_HIGHLIGHT_TAG then
				d.Adornee = adornee
				return d
			end
		end
		local highlight = Instance.new("Highlight")
		highlight.Name = PLAYER_HIGHLIGHT_TAG
		highlight.Adornee = adornee
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = DECOR_FILL
		highlight.FillColor = DECOR_FILL
		highlight.Parent = playerGui
		return highlight
	end

	local function findPartForDecorations(decorations)
		if not decorations then return nil end
		if decorations:IsA("BasePart") then return decorations end
		if decorations:IsA("Model") then
			if decorations.PrimaryPart and decorations.PrimaryPart:IsA("BasePart") then return decorations.PrimaryPart end
		end
		for _, d in ipairs(decorations:GetDescendants()) do if d:IsA("BasePart") then return d end end
		return nil
	end

	local function createNameValueBillboard(adorneePart, nameText, valueText)
		if not adorneePart or not adorneePart:IsA("BasePart") then return end
		local container = playerGui:FindFirstChild(BILLBOARD_TAG)
		if not container then
			local sg = Instance.new("ScreenGui")
			sg.Name = BILLBOARD_TAG
			sg.ResetOnSpawn = false
			sg.Parent = playerGui
			container = sg
		end
		local bbg = Instance.new("BillboardGui")
		bbg.Name = "BestGenerationBillboard"
		bbg.Adornee = adorneePart
		bbg.Size = UDim2.new(0, 220, 0, 52)
		bbg.AlwaysOnTop = true
		bbg.StudsOffset = Vector3.new(0, adorneePart.Size.Y + 1.6, 0)
		bbg.Parent = container
		local nameLabel = Instance.new("TextLabel", bbg)
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -8, 0, 24)
		nameLabel.Position = UDim2.new(0, 4, 0, 2)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = tostring(nameText or "")
		nameLabel.TextColor3 = NAME_COLOR
		nameLabel.TextStrokeColor3 = TEXT_STROKE
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextScaled = true
		local valLabel = Instance.new("TextLabel", bbg)
		valLabel.Name = "GenLabel"
		valLabel.Size = UDim2.new(1, -8, 0, 24)
		valLabel.Position = UDim2.new(0, 4, 0, 26)
		valLabel.BackgroundTransparency = 1
		valLabel.Text = tostring(valueText or "")
		valLabel.TextColor3 = VALUE_COLOR
		valLabel.TextStrokeColor3 = TEXT_STROKE
		valLabel.TextStrokeTransparency = 0
		valLabel.Font = Enum.Font.GothamBold
		valLabel.TextScaled = true
		return bbg
	end

	local function isPodiumIndex(name)
		if not name then return false end
		local n = tonumber(name)
		return n and n >= 1 and n <= 50 and math.floor(n) == n
	end

	local function highlightBestPodiumDecorations(podium, decorationsOverride)
		if not podium then return nil end
		local decorations = decorationsOverride
		if not decorations then
			local base = findDescendantByNameCI(podium, "Base") or podium:FindFirstChild("Base")
			if base then decorations = base:FindFirstChild("Decorations") or findDescendantByNameCI(base, "Decorations") end
			if not decorations then decorations = podium:FindFirstChild("Decorations") or findDescendantByNameCI(podium, "Decorations") end
		end
		if decorations then
			if decorations:IsA("Model") or decorations:IsA("BasePart") then createHighlightForTarget(decorations); return decorations end
			for _, decoChild in ipairs(decorations:GetChildren()) do
				if decoChild:IsA("BasePart") or decoChild:IsA("Model") then createHighlightForTarget(decoChild); return decoChild end
				for _, d in ipairs(decoChild:GetDescendants()) do
					if d:IsA("BasePart") or d:IsA("Model") then createHighlightForTarget(d); return d end
				end
			end
		end
		return nil
	end

	local function findGenerationInDecorations(decorations)
		if not decorations then return nil end
		local bestNum, bestText, bestGenInst = nil, nil, nil
		local function checkInst(inst)
			local genText = getGenerationTextFromInstance(inst)
			if genText then
				local numeric = parseSuffixNumber(genText)
				if numeric then
					if (not bestNum) or numeric > bestNum then bestNum = numeric; bestText = genText; bestGenInst = inst end
				end
			end
		end
		checkInst(decorations)
		for _, desc in ipairs(decorations:GetDescendants()) do
			if string.find(string.lower(desc.Name), "generation") then checkInst(desc)
			else
				if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") or desc:IsA("StringValue") or desc:IsA("ValueBase") then
					checkInst(desc)
				end
			end
		end
		if bestNum then return bestNum, bestText, bestGenInst end
		return nil
	end

	local function findGlobalBest()
		local plotsFolder = Workspace:FindFirstChild(PLOTS_NAME)
		if not plotsFolder then
			for _, c in ipairs(Workspace:GetChildren()) do
				if string.lower(c.Name) == string.lower(PLOTS_NAME) then plotsFolder = c; break end
			end
		end
		if not plotsFolder then return nil end
		local best = nil
		for _, plot in ipairs(plotsFolder:GetChildren()) do
			local animalPodiums = plot:FindFirstChild("AnimalPodiums") or findDescendantByNameCI(plot, "AnimalPodiums")
			if animalPodiums then
				for _, podium in ipairs(animalPodiums:GetChildren()) do
					if isPodiumIndex(podium.Name) then
						local base = findDescendantByNameCI(podium, "Base") or podium:FindFirstChild("Base")
						local decorations = nil
						if base then decorations = base:FindFirstChild("Decorations") or findDescendantByNameCI(base, "Decorations") end
						if not decorations then decorations = podium:FindFirstChild("Decorations") or findDescendantByNameCI(podium, "Decorations") end
						local numeric, rawText = nil, nil
						if decorations then local n, t = findGenerationInDecorations(decorations) if n then numeric = n rawText = t end end
						if not numeric then
							local genInst = podium:FindFirstChild("Generation") or findDescendantByNameCI(podium, "Generation")
							if not genInst then
								local overhead = podium:FindFirstChild("AnimalOverhead") or findDescendantByNameCI(podium, "AnimalOverhead")
								if overhead then genInst = overhead:FindFirstChild("Generation") or findDescendantByNameCI(overhead, "Generation") end
							end
							if not genInst then
								for _, desc in ipairs(podium:GetDescendants()) do
									if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") or desc:IsA("StringValue") or desc:IsA("ValueBase") then
										if getGenerationTextFromInstance(desc) then genInst = desc; break end
									end
								end
							end
							if genInst then
								local genText = getGenerationTextFromInstance(genInst)
								if genText then numeric = parseSuffixNumber(genText); rawText = genText end
							end
						end
						if numeric then
							local basePart = findBasePartForPodium(podium)
							if (not best) or numeric > best.value then
								best = { value = numeric, rawText = rawText, podium = podium, plot = plot, basePart = basePart, decorations = decorations }
							end
						end
					end
				end
			end
		end
		return best
	end

	local function getDisplayFromInstance(inst)
		if not inst then return nil end
		if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then return inst.Text end
		if inst:IsA("ValueBase") then return tostring(inst.Value) end
		local ok, v = pcall(function() return inst.Value or inst.Text end)
		if ok and v then return tostring(v) end
		return nil
	end

	local function getDisplayName_abmsm_style(decorationsContainer, decorationTarget)
		local function tryNamesInRoot(root, names)
			if not root then return nil end
			for _, nm in ipairs(names) do
				local found = findDescendantByNameCI(root, nm)
				if found then
					local v = getDisplayFromInstance(found)
					if v and v ~= "" then return v end
				end
			end
			return nil
		end

		local preferNames = { "DisplayName", "Displayname", "displayname" }
		local fallbackNames = { "Display", "Name" }

		if decorationsContainer then
			local v = tryNamesInRoot(decorationsContainer, preferNames)
			if v and v ~= "" then return v end
			v = tryNamesInRoot(decorationsContainer, fallbackNames)
			if v and v ~= "" then return v end
		end

		if decorationTarget then
			local v = tryNamesInRoot(decorationTarget, preferNames)
			if v and v ~= "" then return v end
			v = tryNamesInRoot(decorationTarget, fallbackNames)
			if v and v ~= "" then return v end
		end

		if decorationTarget and decorationTarget.Parent then
			local p = decorationTarget.Parent
			local v = tryNamesInRoot(p, preferNames)
			if v and v ~= "" then return v end
			v = tryNamesInRoot(p, fallbackNames)
			if v and v ~= "" then return v end
			if p.Parent then
				local gp = p.Parent
				v = tryNamesInRoot(gp, preferNames)
				if v and v ~= "" then return v end
				v = tryNamesInRoot(gp, fallbackNames)
				if v and v ~= "" then return v end
			end
		end

		if decorationsContainer then
			for _, desc in ipairs(decorationsContainer:GetDescendants()) do
				if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") or desc:IsA("StringValue") or desc:IsA("ValueBase") then
					local txt = getDisplayFromInstance(desc)
					if txt and txt ~= "" then
						local low = string.lower(txt)
						if not string.find(low, "%$") and not string.find(low, "/s") and not string.find(low, "per") then
							return txt
						end
					end
				end
			end
		end

		if decorationTarget and decorationTarget.Name and decorationTarget.Name ~= "" then return decorationTarget.Name end
		if decorationsContainer and decorationsContainer.Name and decorationsContainer.Name ~= "" then return decorationsContainer.Name end

		return nil
	end

	local function createLinePart()
		local old = Workspace:FindFirstChild(LINE_PART_NAME)
		if old and old:IsA("BasePart") then old:Destroy() end
		local line = Instance.new("Part")
		line.Name = LINE_PART_NAME
		line.Anchored = true
		line.CanCollide = false
		line.CastShadow = false
		line.Size = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, 1)
		line.Material = Enum.Material.Neon
		line.Color = DECOR_FILL
		line.Transparency = 0
		line.Parent = Workspace
		line.Locked = true
		return line
	end

	local function updateLinePartPerFrame()
		if not currentLinePart or not currentAdorneePart then return end
		local char = player.Character
		if not char then return end
		local playerPart = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
		if not playerPart then return end
		local pPos = playerPart.Position
		local tPos = currentAdorneePart.Position
		local dir = tPos - pPos
		local dist = dir.Magnitude
		if dist <= 0.01 then currentLinePart.Transparency = 1; return else currentLinePart.Transparency = 0 end
		local midpoint = (pPos + tPos) / 2
		currentLinePart.Size = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, dist)
		currentLinePart.CFrame = CFrame.new(midpoint, tPos)
		local highlight = playerGui:FindFirstChild(HIGHLIGHT_TAG)
		if highlight and highlight:IsA("Highlight") then currentLinePart.Color = highlight.FillColor or DECOR_FILL else currentLinePart.Color = DECOR_FILL end
	end

	local function isTrackedBestValid()
		if not trackedBest then return false end
		if trackedBest.podium and trackedBest.podium.Parent then
			local decorations = trackedBest.decorations or trackedBest.podium:FindFirstChild("Decorations") or findDescendantByNameCI(trackedBest.podium, "Decorations")
			local numeric = nil
			if decorations then
				local n, t = findGenerationInDecorations(decorations)
				if n then numeric = n end
			end
			if not numeric then
				local genInst = trackedBest.podium:FindFirstChild("Generation") or findDescendantByNameCI(trackedBest.podium, "Generation")
				if genInst then
					local genText = getGenerationTextFromInstance(genInst)
					if genText then numeric = parseSuffixNumber(genText) end
				end
			end
			if numeric and numeric > 0 then
				if numeric >= trackedBest.value then
					trackedBest.value = numeric
					trackedBestMissingSince = nil
					return true
				end
			else
				if not trackedBestMissingSince then
					trackedBestMissingSince = tick()
					return true
				else
					if tick() - trackedBestMissingSince < MISSING_GRACE then
						return true
					else
						trackedBestMissingSince = nil
						return false
					end
				end
			end
		end
		return false
	end

	local function updateESP()
		local didChange = false
		if trackedBest then
			if not isTrackedBestValid() then
				trackedBest = findGlobalBest()
				trackedBestMissingSince = nil
				didChange = true
			else
				local plotsFolder = Workspace:FindFirstChild(PLOTS_NAME)
				if not plotsFolder then
					for _, c in ipairs(Workspace:GetChildren()) do
						if string.lower(c.Name) == string.lower(PLOTS_NAME) then plotsFolder = c; break end
					end
				end
				if plotsFolder then
					local potentialHigher = nil
					for _, plot in ipairs(plotsFolder:GetChildren()) do
						if plot ~= trackedBest.plot then
							local animalPodiums = plot:FindFirstChild("AnimalPodiums") or findDescendantByNameCI(plot, "AnimalPodiums")
							if animalPodiums then
								for _, podium in ipairs(animalPodiums:GetChildren()) do
									if isPodiumIndex(podium.Name) then
										local base = findDescendantByNameCI(podium, "Base") or podium:FindFirstChild("Base")
										local decorations = nil
										if base then decorations = base:FindFirstChild("Decorations") or findDescendantByNameCI(base, "Decorations") end
										if not decorations then decorations = podium:FindFirstChild("Decorations") or findDescendantByNameCI(podium, "Decorations") end
										local numeric, rawText = nil, nil
										if decorations then local n, t = findGenerationInDecorations(decorations) if n then numeric = n rawText = t end end
										if not numeric then
											local genInst = podium:FindFirstChild("Generation") or findDescendantByNameCI(podium, "Generation")
											if not genInst then
												local overhead = podium:FindFirstChild("AnimalOverhead") or findDescendantByNameCI(podium, "AnimalOverhead")
												if overhead then genInst = overhead:FindFirstChild("Generation") or findDescendantByNameCI(overhead, "Generation") end
											end
											if genInst then
												local genText = getGenerationTextFromInstance(genInst)
												if genText then numeric = parseSuffixNumber(genText); rawText = genText end
											end
										end
										if numeric and numeric > (trackedBest.value or 0) then
											potentialHigher = { value = numeric, rawText = rawText, podium = podium, plot = plot, basePart = findBasePartForPodium(podium), decorations = decorations }
											break
										end
									end
								end
							end
							if potentialHigher then break end
						end
					end
					if potentialHigher then
						trackedBest = potentialHigher
						trackedBestMissingSince = nil
						didChange = true
					end
				end
			end
		else
			trackedBest = findGlobalBest()
			trackedBestMissingSince = nil
			didChange = true
		end

		if trackedBest and trackedBest.basePart then
			local highlightExists = nil
			for _, desc in ipairs(playerGui:GetDescendants()) do
				if desc:IsA("Highlight") and desc.Name == HIGHLIGHT_TAG then highlightExists = desc; break end
			end
			if didChange or not highlightExists then
				clearESP(true)
				highlightBestPodiumDecorations(trackedBest.podium, trackedBest.decorations)
				local adorneePart = trackedBest.basePart or findBasePartForPodium(trackedBest.podium)
				if not adorneePart and trackedBest.decorations then adorneePart = findPartForDecorations(trackedBest.decorations) end
				if adorneePart then
					createNameValueBillboard(adorneePart, getDisplayName_abmsm_style(trackedBest.decorations, trackedBest.decorations) or trackedBest.podium.Name or "", trackedBest.rawText or "")
					if not currentLinePart then currentLinePart = createLinePart() end
					currentAdorneePart = adorneePart
					if not renderConn then
						renderConn = RunService.Heartbeat:Connect(function() pcall(updateLinePartPerFrame) end)
					end
				else
					if renderConn then pcall(function() renderConn:Disconnect() end); renderConn = nil end
					if currentLinePart and currentLinePart.Parent then pcall(function() currentLinePart:Destroy() end) end
					currentLinePart = nil
					currentAdorneePart = nil
				end
			end
		else
			clearESP(false)
			trackedBest = nil
			trackedBestMissingSince = nil
		end
	end

	function BestPlot.start()
		if running then return end
		running = true
		pcall(createPlayerOutline)
		loopThread = coroutine.create(function()
			while running do
				local ok, err = pcall(updateESP)
				if not ok then warn("BestPlotESP - error in updateESP: ", err) end
				local waited = 0
				while waited < REFRESH_INTERVAL and running do
					task.wait(0.25)
					waited = waited + 0.25
				end
			end
		end)
		coroutine.resume(loopThread)
	end

	function BestPlot.stop()
		if not running then return end
		running = false
		if renderConn then pcall(function() renderConn:Disconnect() end); renderConn = nil end
		if currentLinePart and currentLinePart.Parent then pcall(function() currentLinePart:Destroy() end) end
		currentLinePart = nil
		currentAdorneePart = nil
		trackedBest = nil
		trackedBestMissingSince = nil
		clearESP(false)
	end

	function BestPlot.toggle()
		if BestPlot.isRunning() then BestPlot.stop() else BestPlot.start() end
	end

	function BestPlot.isRunning()
		return running
	end
end

-- Plot time billboard and utilities
local timeEspMap = {}
local TB_BILLBOARD_SIZE = UDim2.new(0, 120, 0, 36)
local TB_LABEL_FONT = Enum.Font.Arcade
local TB_LABEL_COLOR = Color3.fromRGB(0, 255, 0)
local TB_CENTER_HEIGHT = 3.5

local function formatSecondsToS(origText)
	if not origText or origText == "" then return "" end
	local mm, ss = origText:match("(%d+):(%d+)%s*$")
	if mm and ss then
		local s = tonumber(ss) or 0
		return tostring(s) .. "S"
	end
	local num = origText:match("(%d+)%s*[sS]?$") or origText:match("(%d+)")
	if num then
		local n = tonumber(num) or 0
		return tostring(n) .. "S"
	end
	return ""
end

local function getPlotCenter(plot)
	local sum = Vector3.new(0,0,0)
	local count = 0
	for _, part in ipairs(plot:GetDescendants()) do
		if part:IsA("BasePart") then
			sum = sum + part.Position
			count = count + 1
		end
	end
	if count == 0 then return nil end
	return sum / count
end

local function getBestAdorneeForPlot(plot)
	local center = getPlotCenter(plot)
	if not center then
		local bp = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
		return bp, (bp and bp.Position) or nil
	end
	local bestPart = nil
	local bestDist = math.huge
	for _, part in ipairs(plot:GetDescendants()) do
		if part:IsA("BasePart") then
			local d = (part.Position - center).Magnitude
			if d < bestDist then
				bestDist = d
				bestPart = part
			end
		end
	end
	return bestPart, center
end

local function findRemainingTimeLabels(plot)
	local labels = {}
	for _, obj in ipairs(plot:GetDescendants()) do
		if obj:IsA("TextLabel") and obj.Name == "RemainingTime" and obj.Text and obj.Text ~= "" then
			table.insert(labels, obj)
		end
	end
	return labels
end

local function pickBestTimeText(plot)
	local labels = findRemainingTimeLabels(plot)
	local bestVal = nil
	local bestText = nil
	for _, lbl in ipairs(labels) do
		local txt = lbl.Text
		local mm, ss = txt:match("(%d+):(%d+)%s*$")
		local val = nil
		if ss then
			val = tonumber(ss)
		else
			local n = txt:match("(%d+)%s*[sS]?$") or txt:match("(%d+)")
			if n then val = tonumber(n) end
		end
		if val then
			if val >= 0 and (bestVal == nil or val < bestVal) then
				bestVal = val
				bestText = tostring(val) .. "S"
			end
		else
			if not bestText then
				local formatted = formatSecondsToS(txt)
				if formatted ~= "" then bestText = formatted end
			end
		end
	end
	return bestText
end

local function ensureGuiForPlot(plot)
	if not plot or not plot.Parent then return end
	local entry = timeEspMap[plot]
	local adornee, center = getBestAdorneeForPlot(plot)
	if not adornee then return end

	if not entry or not entry.gui or not entry.gui.Parent then
		local bb = Instance.new("BillboardGui")
		bb.Name = "PoisonTimeCenter"
		bb.Size = TB_BILLBOARD_SIZE
		bb.Adornee = adornee
		bb.AlwaysOnTop = true
		bb.MaxDistance = 99999
		bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		bb.StudsOffset = Vector3.new(0, TB_CENTER_HEIGHT, 0)
		bb.Parent = plot

		local label = Instance.new("TextLabel", bb)
		label.Name = "PoisonTimeLabel"
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 1, 0)
		label.Position = UDim2.new(0, 0, 0, 0)
		label.Font = TB_LABEL_FONT
		label.TextSize = 24
		label.TextColor3 = TB_LABEL_COLOR
		label.TextStrokeTransparency = 0.6
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center

		timeEspMap[plot] = { gui = bb, label = label, adornee = adornee }
	else
		if entry.adornee ~= adornee then
			entry.gui.Adornee = adornee
			entry.adornee = adornee
		end
	end
end

local function updateAllPlotsOnce()
	local plotsFolder = Workspace:FindFirstChild("Plots")
	if not plotsFolder then return end
	for _, plot in ipairs(plotsFolder:GetChildren()) do
		if plot:IsA("Model") then
			ensureGuiForPlot(plot)
			local best = pickBestTimeText(plot)
			local entry = timeEspMap[plot]
			if entry and entry.label then
				entry.label.Text = best or ""
			end
		end
	end
end

-- Anti-lag function
local antiLagState = { modified = {} }
local function applyAntiLagOnce()
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("Decal") or inst:IsA("Texture") then
			antiLagState.modified[inst] = antiLagState.modified[inst] or { Texture = inst.Texture }
			pcall(function()
				inst.Texture = ""
			end)
		elseif inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
			antiLagState.modified[inst] = antiLagState.modified[inst] or { Enabled = inst.Enabled }
			pcall(function() inst.Enabled = false end)
		elseif inst:IsA("BasePart") then
			antiLagState.modified[inst] = antiLagState.modified[inst] or { Material = inst.Material, CastShadow = inst.CastShadow }
			pcall(function()
				inst.Material = Enum.Material.Plastic
				inst.CastShadow = false
			end)
			if inst:IsA("MeshPart") then
				pcall(function()
					if inst.TextureID and inst.TextureID ~= "" then
						antiLagState.modified[inst].TextureID = inst.TextureID
						inst.TextureID = ""
					end
				end)
			end
		end
	end
	antiLagState.lighting = antiLagState.lighting or {
		GlobalShadows = Lighting.GlobalShadows,
		ClockTime = Lighting.ClockTime,
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		ColorShift_Bottom = Lighting.ColorShift_Bottom,
		ColorShift_Top = Lighting.ColorShift_Top
	}
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(127,127,127)
		Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
		Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
	end)
end

local function restoreAntiLag()
	for inst, data in pairs(antiLagState.modified) do
		if inst and inst.Parent then
			pcall(function()
				if data.Texture and (inst:IsA("Decal") or inst:IsA("Texture")) then inst.Texture = data.Texture end
				if data.Enabled ~= nil and (inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail")) then inst.Enabled = data.Enabled end
				if data.Material and inst:IsA("BasePart") then inst.Material = data.Material end
				if data.CastShadow ~= nil and inst:IsA("BasePart") then inst.CastShadow = data.CastShadow end
				if data.TextureID and inst:IsA("MeshPart") then inst.TextureID = data.TextureID end
			end)
		end
	end
	antiLagState.modified = {}
	if antiLagState.lighting then
		pcall(function()
			Lighting.GlobalShadows = antiLagState.lighting.GlobalShadows
			Lighting.ClockTime = antiLagState.lighting.ClockTime
			Lighting.Brightness = antiLagState.lighting.Brightness
			Lighting.Ambient = antiLagState.lighting.Ambient
			Lighting.ColorShift_Bottom = antiLagState.lighting.ColorShift_Bottom
			Lighting.ColorShift_Top = antiLagState.lighting.ColorShift_Top
		end)
		antiLagState.lighting = nil
	end
end

applyAntiLagOnce()

-- PoisonBoost mini UI creation
local PoisonBoostMiniGui = nil
local JumpBoost = { enabled = Settings.PoisonBoost.JumpBoost or false, saved = {}, JUMP_POWER = 80 }
local InfinityJump = { enabled = Settings.PoisonBoost.InfJump or false, conn = nil, smallVelocity = 53 }
local SpeedBoost = { enabled = Settings.PoisonBoost.SpeedBoost.Enabled or false, Connections = {}, isStopping = false, SPEED_INCREASE = 1.19, DEFAULT_SPEED = 85, MIN_SPEED = 1, MAX_SPEED = 250 }

local function applyJumpToHumanoid(hum)
	if not hum then return end
	if JumpBoost.enabled then
		if not JumpBoost.saved[hum] then JumpBoost.saved[hum] = { JumpPower = hum.JumpPower, UseJumpPower = hum.UseJumpPower } end
		pcall(function() hum.UseJumpPower = true; hum.JumpPower = JumpBoost.JUMP_POWER end)
	else
		local s = JumpBoost.saved[hum]
		if s then pcall(function() hum.UseJumpPower = s.UseJumpPower; hum.JumpPower = s.JumpPower end); JumpBoost.saved[hum] = nil end
	end
end

local function onCharacterForBoosts(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		applyJumpToHumanoid(hum)
	end
end
player.CharacterAdded:Connect(function(char) task.wait(0.2); onCharacterForBoosts(char) end)

local function startInfinityJump()
	if InfinityJump.conn then return end
	InfinityJump.enabled = true
	InfinityJump.conn = UserInputService.JumpRequest:Connect(function()
		local char = player.Character
		if not char then return end
		local humanoid = char:FindFirstChildOfClass("Humanoid");
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not humanoid or not hrp then return end
		local state = humanoid:GetState();
		local inAir = not (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Seated)
		if not InfinityJump.enabled then return end
		if not inAir then return end
		local vel = hrp.AssemblyLinearVelocity;
		local newY = InfinityJump.smallVelocity
		if vel.Y < newY then pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(vel.X, newY, vel.Z) end) end
	end)
	Settings.PoisonBoost.InfJump = true; saveSettings()
end

local function stopInfinityJump()
	InfinityJump.enabled = false
	if InfinityJump.conn then pcall(function() InfinityJump.conn:Disconnect() end); InfinityJump.conn = nil end
	Settings.PoisonBoost.InfJump = false; saveSettings()
end

local function equipGrappleHook_shared()
	if SpeedBoost.isStopping then return nil end
	local now = tick()
	if now - (SpeedBoost.lastEquipTime or 0) < 2 then return nil end
	local char = player.Character;
	if not char then return nil end
	local backpack = player:FindFirstChild("Backpack");
	if not backpack then return nil end
	local grappleHook = backpack:FindFirstChild("Grapple Hook") or char:FindFirstChild("Grapple Hook")
	if not grappleHook then for _, item in ipairs(backpack:GetChildren()) do if item:IsA("Tool") and string.find(string.lower(item.Name),"grapple") then grappleHook=item; break end end end
	if not grappleHook then return nil end
	if grappleHook.Parent == backpack then local humanoid = char:FindFirstChildOfClass("Humanoid");
	if humanoid then pcall(function() humanoid:EquipTool(grappleHook) end); SpeedBoost.lastEquipTime = tick(); task.wait(0.03) end end
	return grappleHook
end

local function spamUseItem_shared()
	if SpeedBoost.isStopping then return end
	local now = tick()
	if now - (SpeedBoost.lastSpamTime or 0) < 0.2 then return end
	local pkgs = ReplicatedStorage:FindFirstChild("Packages")
	if pkgs then local netFolder = pkgs:FindFirstChild("Net") if netFolder then
		local re = netFolder:FindFirstChild("RE/UseItem") or netFolder:FindFirstChild("UseItem") or netFolder:FindFirstChild("RE_UseItem")
		if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(0.23450689315795897); SpeedBoost.lastSpamTime = now end); return end
		for _, desc in ipairs(netFolder:GetDescendants()) do if desc:IsA("RemoteEvent") and string.find(string.lower(desc.Name),"use") and string.find(string.lower(desc.Name),"item") then pcall(function() desc:FireServer(0.23450689315795897); SpeedBoost.lastSpamTime = now end); return end end
	end end
end

local function applyAssemblyVelocity_local(desiredSpeed)
	local char = player.Character; if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart");
	if not hrp then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid"); if not humanoid then return end
	local moveDir = humanoid.MoveDirection or Vector3.new(0,0,0);
	local moveMag = moveDir.Magnitude
	if moveMag <= 0.001 or desiredSpeed <= 0 then local curY = hrp.AssemblyLinearVelocity.Y; pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, curY, 0) end); return end
	local targetXZ = Vector3.new(moveDir.X, 0, moveDir.Z) * desiredSpeed;
	local currentY = hrp.AssemblyLinearVelocity.Y
	pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(targetXZ.X, currentY, targetXZ.Z) end)
end

local function startSpeed()
	SpeedBoost.isStopping = false; SpeedBoost.lastEquipTime = 0; SpeedBoost.lastSpamTime = 0
	if SpeedBoost.Connections.heartbeat then pcall(function() SpeedBoost.Connections.heartbeat:Disconnect() end) end
	SpeedBoost.Connections.heartbeat = RunService.Heartbeat:Connect(function()
		if SpeedBoost.isStopping or not SpeedBoost.enabled then return end
		local desired = tonumber(Settings.PoisonBoost.SpeedBoost.Value) or SpeedBoost.DEFAULT_SPEED
		desired = math.clamp(desired, SpeedBoost.MIN_SPEED, SpeedBoost.MAX_SPEED)
		desired = desired * SpeedBoost.SPEED_INCREASE
		applyAssemblyVelocity_local(desired)
		local now = tick()
		if now - (SpeedBoost.lastEquipTime or 0) >= 2 then pcall(equipGrappleHook_shared) end
		if now - (SpeedBoost.lastSpamTime or 0) >= 0.2 then pcall(spamUseItem_shared) end
	end)
end

local function stopSpeed()
	SpeedBoost.enabled = false
	SpeedBoost.isStopping = true
	if SpeedBoost.Connections.heartbeat then pcall(function() SpeedBoost.Connections.heartbeat:Disconnect() end) end
	SpeedBoost.Connections = {}
end

local function createPoisonBoostMini()
	local name = "PoisonBoostMiniGui"
	if PoisonBoostMiniGui and PoisonBoostMiniGui.Parent then PoisonBoostMiniGui:Destroy(); PoisonBoostMiniGui = nil end
	local gui = Instance.new("ScreenGui"); gui.Name = name; gui.ResetOnSpawn = false; gui.Parent = CoreGui; gui.Enabled = Settings.PoisonBoost.MiniVisible or false

	local mini = Instance.new("Frame", gui)
	mini.Name = "PoisonBoostMini"; mini.Size = UDim2.fromOffset(s(200), s(130)); mini.Position = UDim2.new(1, - (s(200) + 12), 0, 40)
	mini.BackgroundColor3 = bgDark; mini.BorderSizePixel = 0
	local corner = Instance.new("UICorner", mini); corner.CornerRadius = UDim.new(0,10)
	local stroke = Instance.new("UIStroke", mini); stroke.Color = activePurple; stroke.Thickness = 2

	local headerF = Instance.new("Frame", mini); headerF.Name = "Header"; headerF.Size = UDim2.new(1,0,0, s(28)); headerF.BackgroundTransparency = 1
	local title = Instance.new("TextLabel", headerF); title.Size = UDim2.new(1, -10, 1, 0); title.Position = UDim2.new(0,6,0,0); title.BackgroundTransparency = 1; title.Font = Enum.Font.Arcade; title.TextSize = 16 * UI_SCALE;
	title.TextColor3 = activePurple; title.Text = "Poison Boost"; title.TextXAlignment = Enum.TextXAlignment.Left

	local content = Instance.new("Frame", mini); content.Position = UDim2.new(0,s(8),0,s(30));
	content.Size = UDim2.new(1, -s(16), 1, -s(36)); content.BackgroundTransparency = 1

	local function makeToggle(y, text)
		local btn = Instance.new("TextButton", content)
		btn.Size = UDim2.new(1,0,0,s(24));
		btn.Position = UDim2.new(0,0,0,s(y))
		btn.AutoButtonColor = true; btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12 * UI_SCALE; btn.TextColor3 = accentText;
		btn.BackgroundColor3 = inactiveGray
		local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,8)
		local stroke = Instance.new("UIStroke", btn); stroke.Color = activePurple;
		stroke.Thickness = 1
		return btn
	end

	local jumpBtn = makeToggle(0, JumpBoost.enabled and "Jump Boost: ON" or "Jump Boost: OFF")
	local infBtn = makeToggle(28, InfinityJump.enabled and "Inf Jump: ON" or "Inf Jump: OFF")
	local speedBtn = makeToggle(56, SpeedBoost.enabled and "Speed Boost: ON" or "Speed Boost: OFF")

	if JumpBoost.enabled then jumpBtn.BackgroundColor3 = activePurple; jumpBtn.Text = "Jump Boost: ON" else jumpBtn.BackgroundColor3 = inactiveGray; jumpBtn.Text = "Jump Boost: OFF" end
	if InfinityJump.enabled then infBtn.BackgroundColor3 = activePurple; infBtn.Text = "Inf Jump: ON" else infBtn.BackgroundColor3 = inactiveGray; infBtn.Text = "Inf Jump: OFF" end
	if SpeedBoost.enabled then speedBtn.BackgroundColor3 = activePurple; speedBtn.Text = "Speed Boost: ON" else speedBtn.BackgroundColor3 = inactiveGray; speedBtn.Text = "Speed Boost: OFF" end

	jumpBtn.MouseButton1Click:Connect(function()
		JumpBoost.enabled = not JumpBoost.enabled
		if JumpBoost.enabled then
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then applyJumpToHumanoid(hum) end
			jumpBtn.BackgroundColor3 = activePurple; jumpBtn.Text = "Jump Boost: ON"
		else
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then applyJumpToHumanoid(hum) end
			jumpBtn.BackgroundColor3 = inactiveGray; jumpBtn.Text = "Jump Boost: OFF"
		end
		Settings.PoisonBoost.JumpBoost = JumpBoost.enabled; saveSettings()
	end)

	infBtn.MouseButton1Click:Connect(function()
		InfinityJump.enabled = not InfinityJump.enabled
		if InfinityJump.enabled then startInfinityJump(); infBtn.BackgroundColor3 = activePurple; infBtn.Text = "Inf Jump: ON"
		else stopInfinityJump(); infBtn.BackgroundColor3 = inactiveGray; infBtn.Text = "Inf Jump: OFF" end
		Settings.PoisonBoost.InfJump = InfinityJump.enabled; saveSettings()
	end)

	speedBtn.MouseButton1Click:Connect(function()
		SpeedBoost.enabled = not SpeedBoost.enabled
		if SpeedBoost.enabled then
			SpeedBoost.isStopping = false
			Settings.PoisonBoost.SpeedBoost.Enabled = true
			Settings.PoisonBoost.SpeedBoost.Value = Settings.PoisonBoost.SpeedBoost.Value or 85
			speedBtn.BackgroundColor3 = activePurple; speedBtn.Text = "Speed Boost: ON"
			startSpeed()
		else
			Settings.PoisonBoost.SpeedBoost.Enabled = false
			speedBtn.BackgroundColor3 = inactiveGray; speedBtn.Text = "Speed Boost: OFF"
			SpeedBoost.isStopping = true
			stopSpeed()
		end
		saveSettings()
	end)

	makeDraggable(mini)
	PoisonBoostMiniGui = gui
	return gui
end

-- Aimbot functions
local aimbotState = Settings.Functions.Aimbot or false
local aimbotConn = nil
local function hasApprovedAimbotToolEquipped()
	local char = player.Character
	if not char then return false end
	for _, obj in ipairs(char:GetChildren()) do
		if obj:IsA("Tool") and obj.Name then
			local nm = string.lower(obj.Name)
			if (nm:find("web") and (nm:find("slinger") or nm:find("sling"))) or nm == "webslinger" or nm == "web slinger" or nm == "web-slinger" then
				return true
			end
			if (nm:find("laser") and nm:find("cape")) or nm == "laser cape" or nm == "lasercape" or nm == "laser-cape" then
				return true
			end
		end
	end
	return false
end
local function runAimbot()
	if not aimbotState then return end
	if not hasApprovedAimbotToolEquipped() then return end
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	local best, bd = nil, math.huge
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
			local d = (pl.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
			if d < bd then bd = d; best = pl end
		end
	end
	if not best then return end
	local targetHRP = best.Character and best.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end
	local pkgs = ReplicatedStorage:FindFirstChild("Packages")
	if pkgs then
		local netFolder = pkgs:FindFirstChild("Net")
		if netFolder then
			local useItemRemote = netFolder:FindFirstChild("RE/UseItem") or netFolder:FindFirstChild("UseItem") or netFolder:FindFirstChild("RE_UseItem")
			if useItemRemote and useItemRemote:IsA("RemoteEvent") then
				pcall(function() useItemRemote:FireServer(targetHRP.Position, targetHRP) end)
			end
		end
	end
end
local function startAimbot()
	if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
	if not aimbotState then return end
	aimbotConn = RunService.Heartbeat:Connect(function()
		pcall(runAimbot)
	end)
end
local function stopAimbot()
	if aimbotConn then pcall(function() aimbotConn:Disconnect() end); aimbotConn = nil end
end

-- Go To Best implementation
local GoBest = {}
do
	local goEnabled = Settings.Functions.GoBest or false
	local connections = {}
	local currentBestPet = nil
	local isStopping = false
	local hasFlownUp = false
	local lastEquipTime = 0
	local lastSpamTime = 0
	local lastScanTime = 0
	local liftTargetPos = nil
	local LIFT_STUDS = 20
	local SPEED_INCREASE = 1.19

	local function extractValue(text)
		if not text then return 0 end
		local clean = tostring(text):gsub("[%$,/s]", ""):gsub(",", "")
		local mult = 1
		if clean:match("[kK]") then
			mult = 1e3
			clean = clean:gsub("[kK]", "")
		end
		if clean:match("[mM]") then
			mult = 1e6
			clean = clean:gsub("[mM]", "")
		end
		if clean:match("[bB]") then
			mult = 1e9
			clean = clean:gsub("[bB]", "")
		end
		local num = tonumber(clean)
		return num and num * mult or 0
	end

	local function findMostExpensiveBrainrot()
		if isStopping then return nil end
		local allPets = {}
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if isStopping then break end
			if obj.Name == "AnimalOverhead" then
				local petValue = 0
				local petName = "Brainrot"
				for _, child in ipairs(obj:GetChildren()) do
					if child:IsA("TextLabel") then
						local text = child.Text
						if text and text:find("$") and text:find("/s") then
							petValue = extractValue(text)
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
					table.insert(allPets, { position = position, name = petName, value = petValue })
				end
			end
		end
		if #allPets > 0 and not isStopping then
			table.sort(allPets, function(a,b) return a.value > b.value end)
			return allPets[1]
		end
		return nil
	end

	local function flyUpFirst()
		if isStopping then return end
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		if not liftTargetPos then liftTargetPos = hrp.Position + Vector3.new(0, LIFT_STUDS, 0) end
		local startTime = tick()
		local liftSpeed = 60 * SPEED_INCREASE
		while tick() - startTime < 2.5 and not isStopping do
			local dir = (liftTargetPos - hrp.Position)
			local dist = dir.Magnitude
			if dist <= 1.5 then break end
			local unitDir = dir.Magnitude > 0 and dir.Unit or Vector3.new(0, 1, 0)
			hrp.AssemblyLinearVelocity = unitDir * liftSpeed
			task.wait(0.06)
		end
		pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
		hasFlownUp = true
	end

	local function equipGrappleHook()
		local now = tick()
		if now - lastEquipTime < 2 then return nil end
		local char = player.Character
		if not char then return nil end
		local backpack = player:FindFirstChild("Backpack")
		if not backpack then return nil end
		local grappleHook = backpack:FindFirstChild("Grapple Hook") or char:FindFirstChild("Grapple Hook")
		if not grappleHook then
			for _, item in ipairs(backpack:GetChildren()) do if item:IsA("Tool") and string.find(string.lower(item.Name), "grapple") then grappleHook = item; break end end
			for _, item in ipairs(char:GetChildren()) do if item:IsA("Tool") and string.find(string.lower(item.Name), "grapple") then grappleHook = item; break end end
		end
		if not grappleHook then return nil end
		if grappleHook.Parent == backpack then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then pcall(function() humanoid:EquipTool(grappleHook) end); lastEquipTime = tick(); task.wait(0.03) end
		end
		return grappleHook
	end

	local function spamGrappleHook()
		local now = tick()
		if now - lastSpamTime < 0.2 then return end
		local pkgs = ReplicatedStorage:FindFirstChild("Packages")
		if pkgs then
			local netFolder = pkgs:FindFirstChild("Net")
			if netFolder then
				local re = netFolder:FindFirstChild("RE/UseItem") or netFolder:FindFirstChild("UseItem") or netFolder:FindFirstChild("RE_UseItem")
				if re and re:IsA("RemoteEvent") then pcall(function() re:FireServer(0.23450689315795897); lastSpamTime = now end); return end
				for _, desc in ipairs(netFolder:GetDescendants()) do
					if desc:IsA("RemoteEvent") and string.find(string.lower(desc.Name), "use") and string.find(string.lower(desc.Name), "item") then
						pcall(function() desc:FireServer(0.23450689315795897); lastSpamTime = now end); return
					end
				end
			end
		end
	end

	local function flyToPosition(targetPos, speed)
		if isStopping then return 0 end
		local char = player.Character
		if not char then return 0 end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return 0 end
		local direction = (targetPos - hrp.Position)
		local unitDir = direction.Magnitude > 0 and direction.Unit or Vector3.new(0,0,0)
		hrp.AssemblyLinearVelocity = unitDir * speed
		local distance = (hrp.Position - targetPos).Magnitude
		return distance
	end

	local function stabilizePlayer()
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end

	local function cleanStopInternal()
		isStopping = true
		stabilizePlayer()
		for name, conn in pairs(connections) do
			if conn then pcall(function() conn:Disconnect() end) end
		end
		connections = {}
		currentBestPet = nil
		hasFlownUp = false
		lastEquipTime = 0
		lastSpamTime = 0
		lastScanTime = 0
		liftTargetPos = nil
		task.wait(0.05)
		isStopping = false
	end

	local function startGoToBestInternal()
		isStopping = false
		hasFlownUp = false
		lastEquipTime = 0
		lastSpamTime = 0
		lastScanTime = 0
		liftTargetPos = nil
		cleanStopInternal()
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				liftTargetPos = hrp.Position + Vector3.new(0, LIFT_STUDS, 0)
			end
		end
		task.spawn(function()
			flyUpFirst()
			if not isStopping then currentBestPet = findMostExpensiveBrainrot() end
		end)
		connections.movement = RunService.Heartbeat:Connect(function()
			if isStopping or not goEnabled then return end
			local char = player.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local now = tick()
			if now - lastEquipTime >= 2 then equipGrappleHook() end
			if now - lastSpamTime >= 0.2 then spamGrappleHook() end
			if not hasFlownUp then
				if not liftTargetPos then liftTargetPos = hrp.Position + Vector3.new(0, LIFT_STUDS, 0) end
				local distToLift = (hrp.Position - liftTargetPos).Magnitude
				if distToLift > 1.5 then flyToPosition(liftTargetPos, 60 * SPEED_INCREASE); return
				else hasFlownUp = true; stabilizePlayer(); if not isStopping then currentBestPet = findMostExpensiveBrainrot(); lastScanTime = tick() end
				end
			end
			local shouldScan = false
			if now - lastScanTime >= 3 then shouldScan = true; lastScanTime = now end
			if currentBestPet and currentBestPet.position then
				local targetPos = currentBestPet.position
				local distance = (hrp.Position - targetPos).Magnitude
				local speed = 80 * SPEED_INCREASE
				if distance < 15 then speed = 30 * SPEED_INCREASE end
				flyToPosition(targetPos, speed)
				if distance < 8 or shouldScan then task.spawn(function() if not isStopping then currentBestPet = findMostExpensiveBrainrot() end end) end
			else
				if shouldScan and not isStopping then currentBestPet = findMostExpensiveBrainrot() end
				if not currentBestPet then stabilizePlayer() end
			end
		end)
	end

	function GoBest.Toggle()
		goEnabled = not goEnabled
		Settings.Functions.GoBest = goEnabled; saveSettings()
		if goEnabled then
			startGoToBestInternal()
			showNotification("Go To Best enabled", 1.2)
		else
			cleanStopInternal()
			showNotification("Go To Best disabled", 1.2)
		end
	end

	function GoBest.IsEnabled() return goEnabled end
	function GoBest.Stop() goEnabled = false; cleanStopInternal() end

	player.CharacterAdded:Connect(function()
		task.delay(0.6, function()
			if not goEnabled then cleanStopInternal() else startGoToBestInternal() end
		end)
	end)
end

-- Anti-Turret implementation
local AntiTurret = {}
do
	local antiTurretEnabled = Settings.Functions.AntiTurret or false
	local antiTurretConn = nil
	local playerSentries = {}
	local function findPlayerBase()
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v.Name == "Base" and v:IsA("Model") then
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp and v.PrimaryPart then
					if (hrp.Position - v.PrimaryPart.Position).Magnitude < 30 then return v end
				end
			end
		end
		return nil
	end
	local function isPlayerSentry(sentryObj)
		if playerSentries[sentryObj] then return true end
		local playerBase = findPlayerBase()
		if not playerBase then return false end
		local function isInPlayerBase(obj)
			local current = obj
			local depth = 0
			while current and current ~= workspace and depth < 20 do
				if current == playerBase then return true end
				current = current.Parent
				depth = depth + 1
			end
			return false
		end
		if isInPlayerBase(sentryObj) then playerSentries[sentryObj] = true; return true end
		return false
	end

	local function DoClick(tool)
		if tool and tool:FindFirstChild("Handle") then
			pcall(function() tool:Activate() end)
		else
			pcall(function()
				VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 0)
				task.wait(0.05)
				VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 0)
			end)
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
			if originalTool ~= bat then pcall(function() humanoid:EquipTool(bat) end); task.wait(0.2) end
			task.spawn(function()
				while antiTurretEnabled and part.Parent do
					pcall(function() part.CFrame = hrp.CFrame * CFrame.new(0,0,-3) end)
					DoClick(bat)
					task.wait(0.07)
				end
				pcall(function()
					if originalTool and originalTool.Parent then humanoid:EquipTool(originalTool) else humanoid:UnequipTools() end
				end)
			end)
		end
	end

	local function StartAntiTurret()
		if antiTurretConn then return end
		antiTurretEnabled = true
		Settings.Functions.AntiTurret = true; saveSettings()
		antiTurretConn = RunService.Heartbeat:Connect(function()
			for _, obj in ipairs(workspace:GetDescendants()) do
				local name = tostring(obj.Name):lower()
				if name:find("sentry_") or name:find("turret") or name:find("sentry") then
					if not isPlayerSentry(obj) then
						local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
						if part and part.Parent then AttackSentry(part) end
					end
				end
			end
		end)
		showNotification("Anti-Turret enabled", 1.2)
	end

	local function StopAntiTurret()
		antiTurretEnabled = false
		Settings.Functions.AntiTurret = false; saveSettings()
		if antiTurretConn then pcall(function() antiTurretConn:Disconnect() end); antiTurretConn = nil end
		playerSentries = {}
		showNotification("Anti-Turret disabled", 1.2)
	end

	function AntiTurret.Toggle()
		if antiTurretEnabled then StopAntiTurret() else StartAntiTurret() end
	end
	function AntiTurret.IsEnabled() return antiTurretEnabled end
end

-- Functions GUI
local FunctionsGui = nil
local function createFunctionsGui()
	if FunctionsGui and FunctionsGui.Parent then return FunctionsGui end
	local baseWidth = math.floor(300 * UI_SCALE * 0.81 + 0.5)
	local headerH = math.floor(40 * UI_SCALE * 0.81 + 0.5)
	local contentOffsetY = math.floor(48 * UI_SCALE * 0.81 + 0.5)
	local btnH = math.floor(34 * UI_SCALE * 0.81 + 0.5)
	local buttonYs = {0, 44, 88, 132}
	local maxBtnYPx = 0
	for _, y in ipairs(buttonYs) do
		local py = math.floor(y * UI_SCALE * 0.81 + 0.5)
		if py > maxBtnYPx then maxBtnYPx = py end
	end
	local bottomPadding = math.floor(12 * UI_SCALE + 0.5)
	local totalHeight = contentOffsetY + maxBtnYPx + btnH + bottomPadding

	local gui = Instance.new("ScreenGui"); gui.Name = "FunctionsGui"; gui.ResetOnSpawn = false; gui.Parent = playerGui; gui.Enabled = Settings.Functions.Visible or false

	local frame = Instance.new("Frame", gui)
	frame.Name = "FunctionsFrame"
	frame.Size = UDim2.new(0, baseWidth, 0, totalHeight)
	frame.Position = UDim2.new(0.5, -math.floor(baseWidth/2 + 0.5), 0.18, 0)
	frame.BackgroundColor3 = bgDark; frame.BorderSizePixel = 0
	local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke", frame); stroke.Color = activePurple; stroke.Thickness = 2

	local header = Instance.new("Frame", frame); header.Name = "Header"; header.Size = UDim2.new(1,0,0, headerH); header.BackgroundTransparency = 1
	local title = Instance.new("TextLabel", header);
	title.Size = UDim2.new(1, -12, 1, 0); title.Position = UDim2.new(0,6,0,0); title.BackgroundTransparency = 1; title.Font = Enum.Font.Arcade; title.TextSize = 18 * UI_SCALE * 0.81;
	title.TextColor3 = activePurple; title.Text = "Functions"

	local content = Instance.new("Frame", frame); content.Position = UDim2.new(0, math.floor(8 * UI_SCALE * 0.81 + 0.5), 0, contentOffsetY);
	content.Size = UDim2.new(1, -math.floor(16 * UI_SCALE * 0.81 + 0.5), 1, -contentOffsetY); content.BackgroundTransparency = 1

	local function makeBtn(y, text)
		local btn = Instance.new("TextButton", content)
		btn.Size = UDim2.new(1, 0, 0, btnH)
		btn.Position = UDim2.new(0, 0, 0, math.floor(y * UI_SCALE * 0.81 + 0.5))
		btn.BackgroundColor3 = inactiveGray
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 16 * UI_SCALE * 0.81
		btn.TextColor3 = accentText
		btn.Text = text
		local cb = Instance.new("UICorner", btn); cb.CornerRadius = UDim.new(0,8)
		return btn
	end

	local noclipBtn = makeBtn(0, "Noclip Floor")
	local gobestBtn = makeBtn(44, "Go To Best")
	local antiTurretBtn = makeBtn(88, "Anti-Turret: OFF")
	local aimbotToggleBtn = makeBtn(132, aimbotState and "Aimbot: ON" or "Aimbot: OFF")

	makeDraggable(frame)

	local ext_platform = nil
	local ext_active = Settings.Functions.Noclip or false
	local ext_stopped = false
	local ext_transparencySet = {}
	local ext_loopConn = nil

	local function applyTransparency_ext()
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Transparency ~= 1 then
				ext_transparencySet[obj] = obj.Transparency
				obj.Transparency = 0.8
			end
		end
	end
	local function restoreTransparency_ext()
		for obj, original in pairs(ext_transparencySet) do
			if obj and obj.Parent then
				obj.Transparency = original
			end
		end
		ext_transparencySet = {}
	end
	local function createPlatform_ext(rootPart)
		if ext_platform and ext_platform.Parent then pcall(function() ext_platform:Destroy() end) end
		ext_platform = Instance.new("Part")
		ext_platform.Size = Vector3.new(6, 1, 6)
		ext_platform.Anchored = true
		ext_platform.CanCollide = true
		ext_platform.Transparency = 0.8
		ext_platform.Position = rootPart.Position - Vector3.new(0, 3, 0)
		ext_platform.Name = "PoisonX_NoclipPlatform"
		ext_platform.Parent = Workspace
	end
	local function checkCollision_ext(rootPart)
		if not ext_platform then return false end
		local touching = ext_platform:GetTouchingParts()
		for _, part in pairs(touching) do
			if part:IsA("BasePart") and part ~= rootPart and part ~= ext_platform then
				return true
			end
		end
		return false
	end
	local function startExternalNoclipLoop(getRootAndHumanoid)
		if ext_loopConn then return end
		ext_loopConn = RunService.RenderStepped:Connect(function()
			if ext_active and ext_platform then
				local rootPart, humanoid = getRootAndHumanoid()
				if not rootPart then return end
				local pos = ext_platform.Position
				if not ext_stopped then
					pos = Vector3.new(rootPart.Position.X, rootPart.Position.Y - 3, rootPart.Position.Z)
					if checkCollision_ext(rootPart) then
						ext_stopped = true
					end
				else
					pos = Vector3.new(rootPart.Position.X, pos.Y, rootPart.Position.Z)
					if not checkCollision_ext(rootPart) then
						ext_stopped = false
					end
				end
				ext_platform.Position = pos
			end
		end)
	end

	local function stopNoclip()
		ext_active = false
		ext_stopped = false
		if ext_loopConn then pcall(function() ext_loopConn:Disconnect() end); ext_loopConn = nil end
		if ext_platform and ext_platform.Parent then pcall(function() ext_platform:Destroy() end); ext_platform = nil end
		restoreTransparency_ext()
		noclipBtn.BackgroundColor3 = inactiveGray
		noclipBtn.Text = "Noclip Floor"
		showNotification("Noclip deactivated", 1.2)
		Settings.Functions.Noclip = false; saveSettings()
	end

	local function getRootAndHumanoid_local()
		local char = player.Character or player.CharacterAdded:Wait()
		if not char then return nil, nil end
		local rootPart = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		return rootPart, humanoid
	end

	noclipBtn.MouseButton1Click:Connect(function()
		ext_active = not ext_active
		ext_stopped = false
		local rootPart, humanoid = getRootAndHumanoid_local()
		if ext_active then
			noclipBtn.BackgroundColor3 = activePurple
			noclipBtn.Text = "Noclip Floor: ON"
			if rootPart then
				rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 5, 0)
				createPlatform_ext(rootPart)
			end
			applyTransparency_ext()
			startExternalNoclipLoop(getRootAndHumanoid_local)
			showNotification("Noclip activated", 1.2)
			Settings.Functions.Noclip = true; saveSettings()
		else
			stopNoclip()
		end
	end)
	if ext_active then noclipBtn.BackgroundColor3 = activePurple; noclipBtn.Text = "Noclip Floor: ON" else noclipBtn.BackgroundColor3 = inactiveGray; noclipBtn.Text = "Noclip Floor" end

	gobestBtn.MouseButton1Click:Connect(function()
		GoBest.Toggle()
		if GoBest.IsEnabled() then gobestBtn.BackgroundColor3 = activePurple; gobestBtn.Text = "Go To Best: ON"
		else gobestBtn.BackgroundColor3 = inactiveGray; gobestBtn.Text = "Go To Best" end
	end)

	antiTurretBtn.MouseButton1Click:Connect(function()
		AntiTurret.Toggle()
		if AntiTurret.IsEnabled() then antiTurretBtn.BackgroundColor3 = activePurple; antiTurretBtn.Text = "Anti-Turret: ON"
		else antiTurretBtn.BackgroundColor3 = inactiveGray; antiTurretBtn.Text = "Anti-Turret: OFF" end
	end)

	aimbotToggleBtn.MouseButton1Click:Connect(function()
		aimbotState = not aimbotState
		Settings.Functions.Aimbot = aimbotState; saveSettings()
		if aimbotState then
			aimbotToggleBtn.BackgroundColor3 = activePurple
			aimbotToggleBtn.Text = "Aimbot: ON"
			startAimbot()
		else
			aimbotToggleBtn.BackgroundColor3 = inactiveGray
			aimbotToggleBtn.Text = "Aimbot: OFF"
			stopAimbot()
		end
	end)
	if aimbotState then startAimbot() end

	gui:GetPropertyChangedSignal("Enabled"):Connect(function() Settings.Functions.Visible = gui.Enabled; saveSettings() end)

	FunctionsGui = gui
	return FunctionsGui
end

-- Launchers
local function createPoisonBoostLauncher()
	if playerGui:FindFirstChild("PoisonBoostLauncherGui") then playerGui.PoisonBoostLauncherGui:Destroy() end
	local gui = Instance.new("ScreenGui", playerGui); gui.Name = "PoisonBoostLauncherGui"; gui.ResetOnSpawn = false
	local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, s(200), 0, s(50)); frame.Position = UDim2.new(0, 8, 0, 8); frame.BackgroundColor3 = bgDark
	local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0,8)
	local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(1, -12, 1, -12); btn.Position = UDim2.new(0,6,0,6)
	btn.BackgroundColor3 = Settings.PoisonBoost.MiniVisible and activePurple or inactiveGray; btn.Font = Enum.Font.GothamBold; btn.TextColor3 = accentText; btn.TextSize = 16 * UI_SCALE; btn.Text = "Poison Boost"

	local miniGui = nil
	btn.MouseButton1Click:Connect(function()
		local new = not (Settings.PoisonBoost.MiniVisible or false)
		Settings.PoisonBoost.MiniVisible = new
		saveSettings()
		if new then
			miniGui = createPoisonBoostMini()
			if miniGui then miniGui.Enabled = true end
			btn.BackgroundColor3 = activePurple
		else
			if PoisonBoostMiniGui and PoisonBoostMiniGui.Parent then PoisonBoostMiniGui:Destroy(); PoisonBoostMiniGui = nil end
			miniGui = nil
			btn.BackgroundColor3 = inactiveGray
		end
	end)
	if Settings.PoisonBoost.MiniVisible then
		miniGui = createPoisonBoostMini()
		if miniGui then miniGui.Enabled = true end
	end
end

local function createFunctionsLauncher()
	if playerGui:FindFirstChild("FunctionsLauncherGui") then playerGui.FunctionsLauncherGui:Destroy() end
	local gui = Instance.new("ScreenGui", playerGui); gui.Name = "FunctionsLauncherGui"; gui.ResetOnSpawn = false
	local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, s(200), 0, s(50)); frame.Position = UDim2.new(0, 8, 0, 8 + s(60)); frame.BackgroundColor3 = bgDark
	local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0,8)
	local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(1, -12, 1, -12); btn.Position = UDim2.new(0,6,0,6); btn.BackgroundColor3 = Settings.Functions.Visible and activePurple or inactiveGray; btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = accentText; btn.TextSize = 16 * UI_SCALE; btn.Text = "Functions"

	local functionsGui = nil
	btn.MouseButton1Click:Connect(function()
		local new = not (Settings.Functions.Visible or false)
		Settings.Functions.Visible = new
		saveSettings()
		if new then
			functionsGui = createFunctionsGui()
			if functionsGui then functionsGui.Enabled = true end
			btn.BackgroundColor3 = activePurple
		else
			if functionsGui and functionsGui.Parent then functionsGui:Destroy() end
			functionsGui = nil
			btn.BackgroundColor3 = inactiveGray
		end
	end)
	if Settings.Functions.Visible then
		functionsGui = createFunctionsGui()
		if functionsGui then functionsGui.Enabled = true end
	end
end

local function createAutoBuyLauncher() end

-- enable players esp
enablePlayersESP()

-- start BestPlot visuals if configured
if Settings.Functions.BestESP then pcall(function() BestPlot.start() end) end

-- update plots loop (time labels)
spawn(function()
	while true do
		pcall(updateAllPlotsOnce)
		task.wait(0.28)
	end
end)

createPoisonBoostLauncher()
createFunctionsLauncher()

-- Apply initial boosts
task.spawn(function()
	task.wait(0.5)
	if Settings.PoisonBoost.JumpBoost then
		JumpBoost.enabled = true
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then applyJumpToHumanoid(hum) end
		end
	end
	if Settings.PoisonBoost.InfJump then
		InfinityJump.enabled = true
		startInfinityJump()
	end
	if Settings.PoisonBoost.SpeedBoost and Settings.PoisonBoost.SpeedBoost.Enabled then
		SpeedBoost.enabled = true
		startSpeed()
	end
end)

task.spawn(function()
	while true do
		task.wait(30)
		saveSettings()
	end
end)

-- Discord link UI
do
	local gui = Instance.new("ScreenGui")
	gui.Name = "PoisonDiscordGui"
	gui.ResetOnSpawn = false
	gui.Parent = CoreGui

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(0, 600, 0, 28)
	label.Position = UDim2.new(0.5, 0, -0.06, 4)
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Text = "https://discord.gg/3SgRMetdye"
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(0,0,0)
	label.TextTransparency = 0
	label.TextWrapped = false
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.RichText = false

	local colorA = Color3.fromRGB(142, 68, 173)
	local colorB = Color3.fromRGB(100, 80, 190)
	local waveSpeed = 1.02
	local waveAmplitude = 0.5
	local startTime = tick()

	RunService.Heartbeat:Connect(function(dt)
		local t = tick() - startTime
		local v = (math.sin(t * math.pi * 2 * waveSpeed) * 0.5 + 0.5)
		local eased = (1 - math.cos(v * math.pi)) * 0.5
		local final = eased * waveAmplitude + (1 - waveAmplitude) * v
		local col = Color3.new(
			colorA.R + (colorB.R - colorA.R) * final,
			colorA.G + (colorB.G - colorA.G) * final,
			colorA.B + (colorB.B - colorA.B) * final
		)
		label.TextColor3 = col
	end)
end

showNotification("Poison X Hub loaded — All toggles active", 2)

-- helper
function isPodiumIndex(name)
    if not name then return false end
    local n = tonumber(name)
    return n and n >= 1 and n <= 50 and math.floor(n) == n
end
