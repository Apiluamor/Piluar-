local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "GrigoHub"
screenGui.ResetOnSpawn = false

-- Border Frame (purple outline)
local borderFrame = Instance.new("Frame")
borderFrame.Size = UDim2.new(0, 206, 0, 156)
borderFrame.Position = UDim2.new(0.5, -103, 0.5, -78)
borderFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
borderFrame.BorderSizePixel = 0
borderFrame.Active = true
borderFrame.Parent = screenGui

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 17)
borderCorner.Parent = borderFrame

-- Efecto giratorio dorado
local goldEffect = Instance.new("Frame")
goldEffect.Size = UDim2.new(1, 10, 1, 10)
goldEffect.Position = UDim2.new(0, -5, 0, -5)
goldEffect.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
goldEffect.BackgroundTransparency = 0.6
goldEffect.BorderSizePixel = 0
goldEffect.Parent = borderFrame

local goldCorner = Instance.new("UICorner")
goldCorner.CornerRadius = UDim.new(0, 20)
goldCorner.Parent = goldEffect

-- Animación giratoria
local rotationAngle = 0
RunService.RenderStepped:Connect(function()
	rotationAngle = rotationAngle + 2
	goldEffect.Rotation = rotationAngle
	goldEffect.BackgroundTransparency = 0.4 + math.sin(rotationAngle / 30) * 0.3
end)

-- Main Frame sits INSIDE borderFrame (3px outline visible)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = borderFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Title (cambiado a Grigo Hub)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Grigo Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextStrokeColor3 = Color3.fromRGB(255, 215, 0)
title.TextStrokeTransparency = 0
title.Parent = mainFrame

-- Button factory
local function createButton(name, pos, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 160, 0, 35)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 14
	btn.Parent = mainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn
	return btn
end

local autoBuyBtn = createButton("Auto Buy: OFF", UDim2.new(0.5, -80, 0, 50), Color3.fromRGB(40, 40, 40))
local anchoredBtn = createButton("Anchored: OFF", UDim2.new(0.5, -80, 0, 95), Color3.fromRGB(40, 40, 40))

--- DRAGGING ---

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local dragging = false
local dragStartPos = nil
local frameStartPos = nil

if isMobile then
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = input.Position
			frameStartPos = borderFrame.Position
		end
	end)

	title.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStartPos
			borderFrame.Position = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end)

	title.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
else
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStartPos = input.Position
			frameStartPos = borderFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and dragStartPos and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStartPos
			borderFrame.Position = UDim2.new(
				frameStartPos.X.Scale,
				frameStartPos.X.Offset + delta.X,
				frameStartPos.Y.Scale,
				frameStartPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

--- LOGIC ---

local autoBuyActive = false
local anchored = false

-- Auto Buy
autoBuyBtn.MouseButton1Click:Connect(function()
	autoBuyActive = not autoBuyActive
	autoBuyBtn.Text = autoBuyActive and "Auto Buy: ON" or "Auto Buy: OFF"
	autoBuyBtn.BackgroundColor3 = autoBuyActive and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(40, 40, 40)
end)

RunService.Stepped:Connect(function()
	if autoBuyActive then
		for _, prompt in pairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
				prompt:InputHoldBegin()
				prompt:InputHoldEnd()
			end
		end
	end
end)

-- Anchored
anchoredBtn.MouseButton1Click:Connect(function()
	anchored = not anchored
	anchoredBtn.Text = anchored and "Anchored: ON" or "Anchored: OFF"
	anchoredBtn.BackgroundColor3 = anchored and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(40, 40, 40)

	local char = player.Character or player.CharacterAdded:Wait()
	if char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = anchored
			end
		end
	end
end)

-- Notificación actualizada
game.StarterGui:SetCore("SendNotification", {
	Title = "Grigo Hub",
	Text = "Script cargado - Borde dorado giratorio",
	Duration = 2
})
