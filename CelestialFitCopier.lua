-- CelestialFit Copier (Clean Rebuilt Edition)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove existing instance if re-executed
local existingGui = PlayerGui:FindFirstChild("CelestialFitCopier")
if existingGui then
	existingGui:Destroy()
end

-- Celestial Theme Palette
local COLORS = {
	BgDark = Color3.fromRGB(11, 12, 22),
	BgPanel = Color3.fromRGB(17, 19, 34),
	BgCard = Color3.fromRGB(24, 28, 48),
	LogBg = Color3.fromRGB(7, 8, 15),
	AccentViolet = Color3.fromRGB(138, 110, 255),
	AccentCyan = Color3.fromRGB(72, 219, 251),
	AccentGold = Color3.fromRGB(255, 209, 102),
	TextPrimary = Color3.fromRGB(238, 242, 255),
	TextMuted = Color3.fromRGB(132, 144, 175),
	DangerRed = Color3.fromRGB(255, 95, 110),
	DangerBg = Color3.fromRGB(45, 20, 32),
	ToggleOff = Color3.fromRGB(36, 40, 68),
	ToggleOn = Color3.fromRGB(98, 72, 210),
}

-- Speed Presets
local SPEED_MODES = {
	celestial = 0.30,
	safe = 0.20,
	fast = 0.08,
	turbo = 0.02,
}

local currentMode = "safe"
local antiCopyEnabled = false
local lockedDescription = nil
local isCopying = false
local connections = {}
local playerCards = {}

-- Helper for creating UI instances cleanly
local function create(className, props, children)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

-- ScreenGui & Main Frame
local screenGui = create("ScreenGui", {
	Name = "CelestialFitCopier",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = PlayerGui,
})

local mainFrame = create("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 400, 0, 610),
	Position = UDim2.new(0.5, -200, 0.5, -305),
	BackgroundColor3 = COLORS.BgDark,
	BorderSizePixel = 0,
	Active = true,
	Parent = screenGui,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 12) }),
	create("UIStroke", {
		Color = COLORS.AccentViolet,
		Thickness = 1.5,
		Transparency = 0.25,
	}),
})

-- Header
local headerFrame = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 56),
	BackgroundColor3 = COLORS.BgPanel,
	BorderSizePixel = 0,
	Parent = mainFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 12) }),
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = COLORS.BgPanel,
		BorderSizePixel = 0,
	}),
	create("Frame", {
		Size = UDim2.new(0, 34, 0, 34),
		Position = UDim2.new(0, 14, 0, 11),
		BackgroundColor3 = COLORS.AccentViolet,
		BorderSizePixel = 0,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "✦",
			TextColor3 = COLORS.TextPrimary,
			Font = Enum.Font.GothamBlack,
			TextSize = 19,
		}),
	}),
	create("TextLabel", {
		Size = UDim2.new(1, -100, 0, 20),
		Position = UDim2.new(0, 56, 0, 10),
		BackgroundTransparency = 1,
		Text = "CELESTIAL FIT COPIER",
		TextColor3 = COLORS.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}),
	create("TextLabel", {
		Size = UDim2.new(1, -100, 0, 14),
		Position = UDim2.new(0, 56, 0, 28),
		BackgroundTransparency = 1,
		Text = "Yadsan · all items · scales + skin synced",
		TextColor3 = COLORS.AccentCyan,
		Font = Enum.Font.Code,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
	}),
})

local closeButton = create("TextButton", {
	Size = UDim2.new(0, 30, 0, 30),
	Position = UDim2.new(1, -40, 0, 13),
	BackgroundColor3 = COLORS.DangerBg,
	Text = "✕",
	TextColor3 = COLORS.DangerRed,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = false,
	Parent = headerFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 6) }),
})

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Speed Mode Bar
local modeBar = create("Frame", {
	Size = UDim2.new(1, -24, 0, 30),
	Position = UDim2.new(0, 12, 0, 68),
	BackgroundColor3 = COLORS.BgPanel,
	BorderSizePixel = 0,
	Parent = mainFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 8) }),
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}),
})

local modeButtons = {}

-- Anti-Copy / Outfit Lock Toggle
local antiCopyButton = create("TextButton", {
	Size = UDim2.new(1, -24, 0, 36),
	Position = UDim2.new(0, 12, 0, 106),
	BackgroundColor3 = COLORS.ToggleOff,
	Text = "🛡 ANTIOUTFITSTEAL LOCK: OFF",
	TextColor3 = COLORS.TextPrimary,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	AutoButtonColor = false,
	Parent = mainFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 8) }),
})

-- Progress Bar & Status
local progressTrack = create("Frame", {
	Size = UDim2.new(1, -24, 0, 6),
	Position = UDim2.new(0, 12, 0, 149),
	BackgroundColor3 = COLORS.BgCard,
	BorderSizePixel = 0,
	Parent = mainFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(1, 0) }),
})

local progressFill = create("Frame", {
	Size = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = COLORS.AccentViolet,
	BorderSizePixel = 0,
	Parent = progressTrack,
}, {
	create("UICorner", { CornerRadius = UDim.new(1, 0) }),
})

local statusLabel = create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 14),
	Position = UDim2.new(0, 12, 0, 159),
	BackgroundTransparency = 1,
	Text = "Ready · select a player to copy",
	TextColor3 = COLORS.TextMuted,
	Font = Enum.Font.Code,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = mainFrame,
})

-- Mini Console Log
local logContainer = create("Frame", {
	Size = UDim2.new(1, -24, 0, 58),
	Position = UDim2.new(0, 12, 0, 178),
	BackgroundColor3 = COLORS.LogBg,
	BorderSizePixel = 0,
	Parent = mainFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 6) }),
})

local logScroll = create("ScrollingFrame", {
	Size = UDim2.new(1, -8, 1, -8),
	Position = UDim2.new(0, 4, 0, 4),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = COLORS.AccentViolet,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = logContainer,
}, {
	create("UIListLayout", { Padding = UDim.new(0, 1) }),
	create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }),
})

local function addLog(message, color)
	local lines = logScroll:GetChildren()
	if #lines > 35 then
		for _, child in ipairs(lines) do
			if child:IsA("TextLabel") then
				child:Destroy()
				break
			end
		end
	end

	create("TextLabel", {
		Size = UDim2.new(1, -8, 0, 12),
		BackgroundTransparency = 1,
		Text = "✦ " .. message,
		TextColor3 = color or COLORS.TextMuted,
		Font = Enum.Font.Code,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = logScroll,
	})

	task.defer(function()
		logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y)
	end)
end

local function setProgress(alpha, text)
	if text then
		statusLabel.Text = text
	end
	TweenService:Create(progressFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(math.clamp(alpha, 0, 1), 0, 1, 0),
	}):Play()
end

-- Speed Mode Selection
local function selectMode(modeKey)
	currentMode = modeKey
	for key, btn in pairs(modeButtons) do
		local active = (key == modeKey)
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = active and COLORS.AccentCyan or COLORS.BgCard,
			TextColor3 = active and COLORS.BgDark or COLORS.TextMuted,
		}):Play()
	end
	addLog("Speed set to " .. string.upper(modeKey) .. " (" .. SPEED_MODES[modeKey] .. "s)", COLORS.AccentCyan)
end

for _, key in ipairs({ "celestial", "safe", "fast", "turbo" }) do
	local btn = create("TextButton", {
		Size = UDim2.new(0, 88, 0, 22),
		BackgroundColor3 = COLORS.BgCard,
		Text = string.upper(key),
		TextColor3 = COLORS.TextMuted,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		AutoButtonColor = false,
		Parent = modeBar,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	btn.MouseButton1Click:Connect(function()
		selectMode(key)
	end)
	modeButtons[key] = btn
end

-- Outfit Lock Toggle Logic
antiCopyButton.MouseButton1Click:Connect(function()
	antiCopyEnabled = not antiCopyEnabled
	if antiCopyEnabled then
		local myChar = LocalPlayer.Character
		local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if myHum then
			local ok, desc = pcall(function()
				return myHum:GetAppliedDescription()
			end)
			if ok then
				lockedDescription = desc
			end
		end
		antiCopyButton.Text = "🛡 ANTIOUTFITSTEAL LOCK: ON"
		addLog("Outfit snapshot locked", COLORS.AccentGold)
	else
		lockedDescription = nil
		antiCopyButton.Text = "🛡 ANTIOUTFITSTEAL LOCK: OFF"
		addLog("Outfit lock disabled", COLORS.TextMuted)
	end

	TweenService:Create(antiCopyButton, TweenInfo.new(0.15), {
		BackgroundColor3 = antiCopyEnabled and COLORS.ToggleOn or COLORS.ToggleOff,
	}):Play()
end)

-- Smooth Header Dragging (Mouse & Touch)
do
	local dragging = false
	local dragStart, startPos

	headerFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end))

	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

-- Outfit Extraction & Application
local function applyOutfit(targetPlayer, wearButton)
	if isCopying then
		addLog("Already copying an outfit...", COLORS.AccentGold)
		return
	end

	local targetChar = targetPlayer.Character
	local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then
		addLog("No character found for @" .. targetPlayer.Name, COLORS.DangerRed)
		return
	end

	isCopying = true
	wearButton.Text = "…"
	wearButton.BackgroundColor3 = COLORS.AccentGold
	wearButton.TextColor3 = COLORS.BgDark

	task.spawn(function()
		local delayStep = SPEED_MODES[currentMode] or 0.2
		setProgress(0.2, "Reading @" .. targetPlayer.Name .. "...")
		addLog("Reading outfit from @" .. targetPlayer.Name, COLORS.TextPrimary)

		local ok, desc = pcall(function()
			return targetHumanoid:GetAppliedDescription()
		end)

		if not ok or not desc then
			addLog("Failed to read HumanoidDescription", COLORS.DangerRed)
			setProgress(0, "Error reading outfit")
			wearButton.Text = "WEAR"
			wearButton.BackgroundColor3 = COLORS.AccentViolet
			wearButton.TextColor3 = COLORS.TextPrimary
			isCopying = false
			return
		end

		task.wait(delayStep)
		setProgress(0.55, "Syncing clothes, body colors & accessories...")

		local accessories = desc:GetAccessories(true)
		addLog(
			string.format("Synced Shirt:%d Pants:%d Acc:%d", desc.Shirt, desc.Pants, #accessories),
			COLORS.AccentCyan
		)

		task.wait(delayStep)
		setProgress(0.85, "Applying outfit...")

		--[[
			SERVER REMOTE HOOK:
			Connect your target game's avatar RemoteEvent(s) below so other players
			in the server see the copied outfit:

			local avatarRemote = ReplicatedStorage:FindFirstChild("YourGameAvatarRemote", true)
			if avatarRemote then
				avatarRemote:FireServer(desc.Shirt, desc.Pants, accessories)
			end
		]]

		-- Client-side visual application fallback
		local myChar = LocalPlayer.Character
		local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if myHumanoid then
			pcall(function()
				myHumanoid:ApplyDescription(desc)
			end)
		end

		task.wait(delayStep)
		setProgress(1, "Equipped @" .. targetPlayer.Name)
		addLog("Equipped outfit from @" .. targetPlayer.Name, COLORS.AccentViolet)

		wearButton.Text = "DONE"
		wearButton.BackgroundColor3 = COLORS.AccentCyan
		task.wait(0.8)

		if wearButton and wearButton.Parent then
			wearButton.Text = "WEAR"
			wearButton.BackgroundColor3 = COLORS.AccentViolet
			wearButton.TextColor3 = COLORS.TextPrimary
		end
		setProgress(0, "Ready · select a player to copy")
		isCopying = false
	end)
end

-- Search Bar & Players Section
create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 14),
	Position = UDim2.new(0, 12, 0, 244),
	BackgroundTransparency = 1,
	Text = "✦ SERVER PLAYERS",
	TextColor3 = COLORS.TextMuted,
	Font = Enum.Font.Code,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = mainFrame,
})

local searchBox = create("TextBox", {
	Size = UDim2.new(1, -24, 0, 28),
	Position = UDim2.new(0, 12, 0, 262),
	BackgroundColor3 = COLORS.BgPanel,
	BorderSizePixel = 0,
	PlaceholderText = "Search player name or @username...",
	PlaceholderColor3 = COLORS.TextMuted,
	Text = "",
	TextColor3 = COLORS.TextPrimary,
	Font = Enum.Font.Code,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	Parent = mainFrame,
}, {
	create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
})

local playerListScroll = create("ScrollingFrame", {
	Size = UDim2.new(1, -24, 1, -308),
	Position = UDim2.new(0, 12, 0, 298),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = COLORS.AccentViolet,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = mainFrame,
}, {
	create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local function matchesSearch(player)
	local query = string.lower(searchBox.Text or "")
	if query == "" then
		return true
	end
	return string.find(string.lower(player.Name), query, 1, true) ~= nil
		or string.find(string.lower(player.DisplayName), query, 1, true) ~= nil
end

local function filterPlayerCards()
	for player, card in pairs(playerCards) do
		if card and card.Parent then
			card.Visible = matchesSearch(player)
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(filterPlayerCards)

local function removePlayerCard(player)
	local card = playerCards[player]
	if card then
		card:Destroy()
		playerCards[player] = nil
	end
end

local function addPlayerCard(player)
	if player == LocalPlayer or playerCards[player] then
		return
	end

	local card = create("Frame", {
		Name = player.Name,
		Size = UDim2.new(1, -6, 0, 48),
		BackgroundColor3 = COLORS.BgCard,
		BorderSizePixel = 0,
		Visible = matchesSearch(player),
		Parent = playerListScroll,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 8) }),
	})

	local avatarImg = create("ImageLabel", {
		Size = UDim2.new(0, 38, 0, 38),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundColor3 = COLORS.BgPanel,
		BorderSizePixel = 0,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=100&h=100",
		Parent = card,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 19) }),
	})

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(
				player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
		end)
		if ok and thumb and avatarImg.Parent then
			avatarImg.Image = thumb
		end
	end)

	create("TextLabel", {
		Size = UDim2.new(1, -120, 0, 14),
		Position = UDim2.new(0, 50, 0, 6),
		BackgroundTransparency = 1,
		Text = player.DisplayName,
		TextColor3 = COLORS.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})

	create("TextLabel", {
		Size = UDim2.new(1, -120, 0, 12),
		Position = UDim2.new(0, 50, 0, 22),
		BackgroundTransparency = 1,
		Text = "@" .. player.Name,
		TextColor3 = COLORS.TextMuted,
		Font = Enum.Font.Code,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})

	local wearBtn = create("TextButton", {
		Size = UDim2.new(0, 60, 0, 28),
		Position = UDim2.new(1, -66, 0, 10),
		BackgroundColor3 = COLORS.AccentViolet,
		Text = "WEAR",
		TextColor3 = COLORS.TextPrimary,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		AutoButtonColor = false,
		Parent = card,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	wearBtn.MouseButton1Click:Connect(function()
		applyOutfit(player, wearBtn)
	end)

	playerCards[player] = card
end

-- Populate existing players & bind join/leave events
for _, player in ipairs(Players:GetPlayers()) do
	addPlayerCard(player)
end

table.insert(connections, Players.PlayerAdded:Connect(function(player)
	addPlayerCard(player)
	addLog("Joined: @" .. player.Name, COLORS.TextMuted)
end))

table.insert(connections, Players.PlayerRemoving:Connect(function(player)
	removePlayerCard(player)
	addLog("Left: @" .. player.Name, COLORS.TextMuted)
end))

-- Clean up connections on close
screenGui.Destroying:Connect(function()
	for _, conn in ipairs(connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
end)

-- Initialize default mode
selectMode("safe")
addLog("CelestialFit loaded for @" .. LocalPlayer.Name, COLORS.AccentViolet)

-- Announcement
task.spawn(function()
    local text = "------------------//////CELESTIAL OUTFIT COPIER LOADED (Made by Yadsan_Godverse 🔱-- CELESTIAL SYNDICATE ON TOP🔮🏴) ////////--------------------"
    local textChatService = game:GetService("TextChatService")
    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = textChatService:FindFirstChild("TextChannels") and textChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(text)
        end
    else
        local defaultEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if defaultEvents and defaultEvents:FindFirstChild("SayMessageRequest") then
            defaultEvents.SayMessageRequest:FireServer(text, "All")
        end
    end
end)
