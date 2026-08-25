local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- =========================================================
-- 🌫️ BLUR
-- =========================================================

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game:GetService("Lighting")

-- =========================================================
-- 🔊 SOUNDS
-- =========================================================

local function makeSound(id)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = 0.7
	sound.Parent = workspace
	return sound
end

local clickSound = makeSound(12221967)
local popSound = makeSound(12222054)
local tpSound = makeSound(12222152)
local viewSound = makeSound(12221944)
local autoBackSound = makeSound(12221990)

local function play(sound)
	if sound then
		sound:Play()
	end
end

-- =========================================================
-- GUI
-- =========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

-- =========================================================
-- HELPER
-- =========================================================

local function addCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = object
end

-- =========================================================
-- STATE
-- =========================================================

local mode = "TP"
local isOpen = false
local controlsOpen = false

local viewingPlayer = nil
local playerList = {}
local currentIndex = 0

local updateList
local toggleMenu
local autoBack

-- =========================================================
-- 📐 SAFE AREA
-- =========================================================

local function getSafeTop()
	local topLeftInset = GuiService:GetGuiInset()
	return topLeftInset.Y
end

-- =========================================================
-- ⬛ TOGGLE
-- =========================================================

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "RobloxStyleToggle"

toggleButton.Size = UDim2.new(0, 42, 0, 42)

toggleButton.Position = UDim2.new(
	0,
	10,
	0,
	getSafeTop() + 8
)

toggleButton.Text = "☰"
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold

toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.BackgroundTransparency = 0.1

toggleButton.TextColor3 = Color3.new(1, 1, 1)

toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true

toggleButton.ZIndex = 20
toggleButton.Parent = gui

addCorner(toggleButton, 10)

-- =========================================================
-- TP BUTTON
-- =========================================================

local tpButton = Instance.new("TextButton")
tpButton.Name = "TPButton"

tpButton.Size = UDim2.new(0, 55, 0, 30)

tpButton.Position = UDim2.new(
	0,
	62,
	0,
	getSafeTop() + 14
)

tpButton.Text = "TP"
tpButton.TextScaled = true
tpButton.Font = Enum.Font.GothamBold

tpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpButton.BackgroundTransparency = 0.1

tpButton.TextColor3 = Color3.new(1, 1, 1)

tpButton.BorderSizePixel = 0
tpButton.Visible = false

tpButton.ZIndex = 19
tpButton.Parent = gui

addCorner(tpButton, 8)

-- =========================================================
-- VIEW BUTTON
-- =========================================================

local viewButton = Instance.new("TextButton")
viewButton.Name = "ViewButton"

viewButton.Size = UDim2.new(0, 55, 0, 30)

viewButton.Position = UDim2.new(
	0,
	62,
	0,
	getSafeTop() + 48
)

viewButton.Text = "View"
viewButton.TextScaled = true
viewButton.Font = Enum.Font.GothamBold

viewButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
viewButton.BackgroundTransparency = 0.1

viewButton.TextColor3 = Color3.new(1, 1, 1)

viewButton.BorderSizePixel = 0
viewButton.Visible = false

viewButton.ZIndex = 19
viewButton.Parent = gui

addCorner(viewButton, 8)

-- =========================================================
-- UPDATE SAFE POSITION
-- =========================================================

local function updateSafePosition()

	local safeTop = getSafeTop()

	toggleButton.Position = UDim2.new(
		0,
		10,
		0,
		safeTop + 8
	)

	tpButton.Position = UDim2.new(
		0,
		62,
		0,
		safeTop + 14
	)

	viewButton.Position = UDim2.new(
		0,
		62,
		0,
		safeTop + 48
	)

end

-- =========================================================
-- TITLE
-- =========================================================

local title = Instance.new("TextLabel")
title.Name = "Title"

title.Size = UDim2.new(0, 220, 0, 25)

title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, 50)

title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BackgroundTransparency = 0.35

title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

title.Visible = false
title.Parent = gui

addCorner(title, 8)

-- =========================================================
-- PLAYER SCROLL MENU
-- =========================================================

local frame = Instance.new("ScrollingFrame")
frame.Name = "PlayerList"

frame.Size = UDim2.new(0, 220, 0, 0)

frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 80)

frame.Visible = false

frame.ScrollBarThickness = 5

frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.35

frame.CanvasSize = UDim2.new(0, 0, 0, 0)

frame.Parent = gui

addCorner(frame, 10)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = frame

-- =========================================================
-- VIEW BACK
-- =========================================================

local backButton = Instance.new("TextButton")

backButton.Name = "BackButton"

backButton.Size = UDim2.new(0, 60, 0, 30)

backButton.Position = UDim2.new(
	1,
	-70,
	0,
	getSafeTop() + 60
)

backButton.Text = "Back"
backButton.TextScaled = true
backButton.Font = Enum.Font.GothamBold

backButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
backButton.BackgroundTransparency = 0.3

backButton.TextColor3 = Color3.new(1, 1, 1)

backButton.Visible = false

backButton.Parent = gui

addCorner(backButton, 8)

-- =========================================================
-- VIEW TP
-- =========================================================

local viewTPButton = Instance.new("TextButton")

viewTPButton.Name = "ViewTPButton"

viewTPButton.Size = UDim2.new(0, 60, 0, 30)

viewTPButton.Position = UDim2.new(
	1,
	-140,
	0,
	getSafeTop() + 60
)

viewTPButton.Text = "TP"
viewTPButton.TextScaled = true
viewTPButton.Font = Enum.Font.GothamBold

viewTPButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
viewTPButton.BackgroundTransparency = 0.3

viewTPButton.TextColor3 = Color3.new(1, 1, 1)

viewTPButton.Visible = false

viewTPButton.Parent = gui

addCorner(viewTPButton, 8)

-- =========================================================
-- ❤️ HEALTH INDICATOR
-- =========================================================

local healthLabel = Instance.new("TextLabel")

healthLabel.Name = "HealthLabel"

healthLabel.Size = UDim2.new(0, 150, 0, 25)

healthLabel.AnchorPoint = Vector2.new(0.5, 1)

healthLabel.Position = UDim2.new(
	0.5,
	0,
	1,
	-40
)

healthLabel.BackgroundTransparency = 1

healthLabel.TextColor3 = Color3.new(1, 1, 1)

healthLabel.TextScaled = true
healthLabel.Font = Enum.Font.GothamBold

healthLabel.Text = "100/100"

healthLabel.Visible = false

healthLabel.Parent = gui

-- =========================================================
-- VIEW LABEL
-- =========================================================

local viewingLabel = Instance.new("TextLabel")

viewingLabel.Name = "ViewingLabel"

viewingLabel.Size = UDim2.new(0, 250, 0, 30)

viewingLabel.AnchorPoint = Vector2.new(0.5, 1)

viewingLabel.Position = UDim2.new(
	0.5,
	0,
	1,
	-10
)

viewingLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
viewingLabel.BackgroundTransparency = 0.35

viewingLabel.TextColor3 = Color3.new(1, 1, 1)
viewingLabel.TextScaled = true
viewingLabel.Font = Enum.Font.GothamBold

viewingLabel.Visible = false

viewingLabel.Parent = gui

addCorner(viewingLabel, 10)

-- =========================================================
-- LEFT VIEW
-- =========================================================

local leftButton = Instance.new("TextButton")

leftButton.Name = "LeftButton"

leftButton.Size = UDim2.new(0, 35, 0, 35)

leftButton.Position = UDim2.new(
	0.5,
	-170,
	1,
	-45
)

leftButton.Text = "<"
leftButton.TextScaled = true
leftButton.Font = Enum.Font.GothamBold

leftButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
leftButton.BackgroundTransparency = 0.3

leftButton.TextColor3 = Color3.new(1, 1, 1)

leftButton.Visible = false

leftButton.Parent = gui

addCorner(leftButton, 8)

-- =========================================================
-- RIGHT VIEW
-- =========================================================

local rightButton = Instance.new("TextButton")

rightButton.Name = "RightButton"

rightButton.Size = UDim2.new(0, 35, 0, 35)

rightButton.Position = UDim2.new(
	0.5,
	135,
	1,
	-45
)

rightButton.Text = ">"
rightButton.TextScaled = true
rightButton.Font = Enum.Font.GothamBold

rightButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
rightButton.BackgroundTransparency = 0.3

rightButton.TextColor3 = Color3.new(1, 1, 1)

rightButton.Visible = false

rightButton.Parent = gui

addCorner(rightButton, 8)

-- =========================================================
-- PLAYER LIST
-- =========================================================

local function refreshPlayerList()

	playerList = {}

	for _, plr in ipairs(Players:GetPlayers()) do

		if plr ~= player then
			table.insert(playerList, plr)
		end

	end

end

-- =========================================================
-- TELEPORT
-- =========================================================

local function teleportTo(plr)

	if not plr then
		return false
	end

	local character = player.Character or player.CharacterAdded:Wait()

	local myRoot = character:FindFirstChild("HumanoidRootPart")

	if not myRoot then
		return false
	end

	if not plr.Character then
		return false
	end

	local targetRoot =
		plr.Character:FindFirstChild("HumanoidRootPart")

	if not targetRoot then
		return false
	end

	myRoot.CFrame =
		targetRoot.CFrame + Vector3.new(0, 5, 0)

	play(tpSound)

	return true

end

-- =========================================================
-- AUTO BACK
-- =========================================================

autoBack = function()

	play(autoBackSound)

	if player.Character then

		local humanoid =
			player.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then

			camera.CameraSubject = humanoid
			camera.CameraType = Enum.CameraType.Custom

		end

	end

	viewingPlayer = nil

	backButton.Visible = false
	viewTPButton.Visible = false
	viewingLabel.Visible = false
	healthLabel.Visible = false
	leftButton.Visible = false
	rightButton.Visible = false

end

-- =========================================================
-- VIEW PLAYER
-- =========================================================

local function viewPlayer(plr)

	if not plr then
		return
	end

	refreshPlayerList()

	for i, p in ipairs(playerList) do

		if p == plr then

			currentIndex = i
			break

		end

	end

	viewingPlayer = plr

	backButton.Visible = true
	viewTPButton.Visible = true
	viewingLabel.Visible = true
	healthLabel.Visible = true
	leftButton.Visible = true
	rightButton.Visible = true

	viewingLabel.Text =
		"  " .. plr.Name .. "  "

	play(viewSound)

	if plr.Character then

		local humanoid =
			plr.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then

			-- Actualizar vida
			local function updateHealth()

				if viewingPlayer == plr then

					healthLabel.Text =
						math.floor(humanoid.Health)
						.. "/"
						.. math.floor(humanoid.MaxHealth)

				end

			end

			updateHealth()

			humanoid.HealthChanged:Connect(function()
				updateHealth()
			end)

			camera.CameraSubject = humanoid
			camera.CameraType = Enum.CameraType.Follow

			humanoid.Died:Connect(function()

				if viewingPlayer == plr then

					task.wait(1)
					autoBack()

				end

			end)

		else

			healthLabel.Text = "N/A"

		end

	else

		healthLabel.Text = "N/A"

	end

end

-- =========================================================
-- MENU ANIMATION
-- =========================================================

toggleMenu = function(show)

	if show then

		frame.Visible = true
		title.Visible = true

		play(popSound)

		TweenService:Create(
			frame,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			),
			{
				Size = UDim2.new(
					0,
					220,
					0,
					300
				)
			}
		):Play()

		TweenService:Create(
			blur,
			TweenInfo.new(0.25),
			{
				Size = 12
			}
		):Play()

	else

		play(popSound)

		local tween = TweenService:Create(
			frame,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.In
			),
			{
				Size = UDim2.new(
					0,
					220,
					0,
					0
				)
			}
		)

		tween:Play()

		TweenService:Create(
			blur,
			TweenInfo.new(0.2),
			{
				Size = 0
			}
		):Play()

		tween.Completed:Connect(function()

			if not isOpen then

				frame.Visible = false
				title.Visible = false

			end

		end)

	end

end

-- =========================================================
-- UPDATE PLAYER LIST
-- =========================================================

updateList = function()

	for _, child in ipairs(frame:GetChildren()) do

		if child:IsA("Frame") then
			child:Destroy()
		end

	end

	refreshPlayerList()

	for _, plr in ipairs(playerList) do

		-- =====================================================
		-- ITEM
		-- =====================================================

		local item = Instance.new("Frame")

		item.Size = UDim2.new(
			1,
			-12,
			0,
			55
		)

		item.BackgroundColor3 =
			Color3.fromRGB(30, 30, 30)

		item.BackgroundTransparency = 0.35

		item.Parent = frame

		addCorner(item, 7)

		-- =====================================================
		-- AVATAR
		-- =====================================================

		local avatar = Instance.new("ImageLabel")

		avatar.Size = UDim2.new(
			0,
			40,
			0,
			40
		)

		avatar.Position = UDim2.new(
			0,
			5,
			0,
			7
		)

		avatar.BackgroundTransparency = 1

		avatar.Parent = item

		task.spawn(function()

			local success, image =
				pcall(function()

					return Players:GetUserThumbnailAsync(
						plr.UserId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size150x150
					)

				end)

			if success then
				avatar.Image = image
			end

		end)

		-- =====================================================
		-- TEAM
		-- =====================================================

		local teamName = "N/A"

		if plr.Team then
			teamName = plr.Team.Name
		end

		-- =====================================================
		-- PLAYER NAME
		-- =====================================================

		local nameLabel = Instance.new("TextLabel")

		nameLabel.Size = UDim2.new(
			1,
			-55,
			0,
			25
		)

		nameLabel.Position = UDim2.new(
			0,
			50,
			0,
			3
		)

		nameLabel.Text = plr.Name

		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.GothamBold

		nameLabel.BackgroundTransparency = 1

		nameLabel.TextColor3 =
			Color3.new(1, 1, 1)

		nameLabel.TextXAlignment =
			Enum.TextXAlignment.Left

		nameLabel.ZIndex = 2
		nameLabel.Parent = item

		-- =====================================================
		-- TEAM LABEL
		-- =====================================================

		local teamLabel = Instance.new("TextLabel")

		teamLabel.Size = UDim2.new(
			1,
			-55,
			0,
			20
		)

		teamLabel.Position = UDim2.new(
			0,
			50,
			0,
			29
		)

		teamLabel.Text = teamName

		teamLabel.TextScaled = true
		teamLabel.Font = Enum.Font.Gotham

		teamLabel.BackgroundTransparency = 1

		if plr.Team then
			teamLabel.TextColor3 =
				plr.Team.TeamColor.Color
		else
			teamLabel.TextColor3 =
				Color3.fromRGB(200, 200, 200)
		end

		teamLabel.TextXAlignment =
			Enum.TextXAlignment.Left

		teamLabel.ZIndex = 2
		teamLabel.Parent = item

		-- =====================================================
		-- CLICK
		-- =====================================================

		local click = Instance.new("TextButton")

		click.Size = UDim2.new(
			1,
			0,
			1,
			0
		)

		click.BackgroundTransparency = 1
		click.Text = ""

		click.ZIndex = 5
		click.Parent = item

		click.MouseButton1Click:Connect(function()

			play(clickSound)

			if mode == "TP" then

				teleportTo(plr)

				isOpen = false
				toggleMenu(false)

			else

				viewPlayer(plr)

				isOpen = false
				toggleMenu(false)

			end

		end)

	end

	task.wait()

	frame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 10
	)

end

-- =========================================================
-- OPEN TAB
-- =========================================================

local function openTab(newMode)

	mode = newMode
	isOpen = true

	if mode == "TP" then
		title.Text = "TP MENU"
	else
		title.Text = "VIEW MENU"
	end

	updateList()
	toggleMenu(true)

end

-- =========================================================
-- ⬛ TOGGLE
-- =========================================================

toggleButton.MouseButton1Click:Connect(function()

	controlsOpen = not controlsOpen

	play(clickSound)

	if controlsOpen then

		tpButton.Visible = true
		viewButton.Visible = true

		toggleButton.Text = "×"

	else

		tpButton.Visible = false
		viewButton.Visible = false

		toggleButton.Text = "⚙️"

	end

end)

-- =========================================================
-- TP
-- =========================================================

tpButton.MouseButton1Click:Connect(function()

	play(clickSound)

	if isOpen and mode == "TP" then

		isOpen = false
		toggleMenu(false)

	else

		openTab("TP")

	end

end)

-- =========================================================
-- VIEW
-- =========================================================

viewButton.MouseButton1Click:Connect(function()

	play(clickSound)

	if isOpen and mode == "VIEW" then

		isOpen = false
		toggleMenu(false)

	else

		openTab("VIEW")

	end

end)

-- =========================================================
-- BACK
-- =========================================================

backButton.MouseButton1Click:Connect(function()

	play(clickSound)

	autoBack()

end)

-- =========================================================
-- TP FROM VIEW
-- =========================================================

viewTPButton.MouseButton1Click:Connect(function()

	if viewingPlayer then

		local target = viewingPlayer

		if teleportTo(target) then
			autoBack()
		end

	end

end)

-- =========================================================
-- PREVIOUS PLAYER
-- =========================================================

leftButton.MouseButton1Click:Connect(function()

	refreshPlayerList()

	if #playerList > 0 then

		currentIndex -= 1

		if currentIndex < 1 then
			currentIndex = #playerList
		end

		viewPlayer(
			playerList[currentIndex]
		)

	end

end)

-- =========================================================
-- NEXT PLAYER
-- =========================================================

rightButton.MouseButton1Click:Connect(function()

	refreshPlayerList()

	if #playerList > 0 then

		currentIndex += 1

		if currentIndex > #playerList then
			currentIndex = 1
		end

		viewPlayer(
			playerList[currentIndex]
		)

	end

end)

-- =========================================