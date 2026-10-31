--!nocheck
-- Gesso & the Ghost Dogs, client: the spec plate and the plate captions in the book's paper, the sights, Still Life's sketch,
-- the ink creeping in from the page edges when hurt, and the keys: right mouse to aim, click to throw, F snaps at the nearest
-- ink, Q is Still Life, H whistles. On a phone the same actions appear as buttons.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local E = { hud = RS:WaitForChild("Hud"), plate = RS:WaitForChild("Plate"), throw = RS:WaitForChild("Throw"), still = RS:WaitForChild("Still"), whistle = RS:WaitForChild("Whistle"), toast = RS:WaitForChild("Toast"), fx = RS:WaitForChild("Fx") }
local PAPER = Color3.fromRGB(236, 227, 202)
local INKC = Color3.fromRGB(42, 37, 28)
local SOFT = Color3.fromRGB(93, 84, 68)
local SIGNAL = Color3.fromRGB(217, 166, 64)

local gui = Instance.new("ScreenGui"); gui.Name = "Gesso"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = false; gui.Parent = player:WaitForChild("PlayerGui")

-- ---- the spec plate
local plate = Instance.new("Frame"); plate.Position = UDim2.new(0, 14, 0, 14); plate.Size = UDim2.new(0, 180, 0, 112); plate.BackgroundColor3 = PAPER; plate.BackgroundTransparency = 0.08; plate.BorderSizePixel = 0; plate.Parent = gui
local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, 0, 0, 3); bar.BackgroundColor3 = SIGNAL; bar.BorderSizePixel = 0; bar.Parent = plate
local rows = {}
for i, key in ipairs({ "Seams", "Pack", "Plates", "Ink" }) do
	local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1; l.Position = UDim2.new(0, 12, 0, 8 + (i - 1) * 25); l.Size = UDim2.new(0.5, 0, 0, 22); l.Font = Enum.Font.Code; l.TextSize = 11; l.TextColor3 = SOFT; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = string.upper(key); l.Parent = plate
	local v = Instance.new("TextLabel"); v.BackgroundTransparency = 1; v.Position = UDim2.new(0.5, 0, 0, 8 + (i - 1) * 25); v.Size = UDim2.new(0.5, -12, 0, 22); v.Font = Enum.Font.GothamBold; v.TextSize = 15; v.TextColor3 = INKC; v.TextXAlignment = Enum.TextXAlignment.Right; v.Text = "0"; v.Parent = plate
	rows[key] = v
end
E.hud.OnClientEvent:Connect(function(s)
	rows.Seams.Text = s.seams .. " / 30"; rows.Pack.Text = s.pack .. " / 6"; rows.Plates.Text = s.plates .. " / 8"; rows.Ink.Text = tostring(s.ink)
end)

-- ---- toasts and plates
local toastL = Instance.new("TextLabel"); toastL.AnchorPoint = Vector2.new(0.5, 1); toastL.Position = UDim2.new(0.5, 0, 1, -80); toastL.Size = UDim2.new(0.8, 0, 0, 30); toastL.BackgroundTransparency = 1; toastL.Font = Enum.Font.Garamond; toastL.TextSize = 26; toastL.TextColor3 = Color3.fromRGB(246, 239, 220); toastL.TextStrokeTransparency = 0.5; toastL.TextStrokeColor3 = Color3.fromRGB(10, 8, 4); toastL.Text = ""; toastL.TextTransparency = 1; toastL.Parent = gui
local toastT = 0
E.toast.OnClientEvent:Connect(function(text) toastL.Text = text; toastL.TextTransparency = 0; toastT = 3.5 end)

local card = Instance.new("Frame"); card.AnchorPoint = Vector2.new(0.5, 1); card.Position = UDim2.new(0.5, 0, 1, -24); card.Size = UDim2.new(0, 560, 0, 150); card.BackgroundColor3 = PAPER; card.BorderSizePixel = 0; card.Visible = false; card.Parent = gui
local cbar = bar:Clone(); cbar.Parent = card
local cEye = Instance.new("TextLabel"); cEye.BackgroundTransparency = 1; cEye.Position = UDim2.new(0, 20, 0, 12); cEye.Size = UDim2.new(1, -40, 0, 14); cEye.Font = Enum.Font.Code; cEye.TextSize = 11; cEye.TextColor3 = SOFT; cEye.TextXAlignment = Enum.TextXAlignment.Left; cEye.Parent = card
local cTitle = Instance.new("TextLabel"); cTitle.BackgroundTransparency = 1; cTitle.Position = UDim2.new(0, 20, 0, 28); cTitle.Size = UDim2.new(1, -40, 0, 34); cTitle.Font = Enum.Font.Garamond; cTitle.TextSize = 30; cTitle.TextColor3 = INKC; cTitle.TextXAlignment = Enum.TextXAlignment.Left; cTitle.Parent = card
local cText = Instance.new("TextLabel"); cText.BackgroundTransparency = 1; cText.Position = UDim2.new(0, 20, 0, 64); cText.Size = UDim2.new(1, -40, 0, 76); cText.Font = Enum.Font.Garamond; cText.TextSize = 18; cText.TextColor3 = Color3.fromRGB(59, 52, 39); cText.TextWrapped = true; cText.TextXAlignment = Enum.TextXAlignment.Left; cText.TextYAlignment = Enum.TextYAlignment.Top; cText.Parent = card
local cardT = 0
E.plate.OnClientEvent:Connect(function(eye, title, text) cEye.Text = string.upper(eye); cTitle.Text = title; cText.Text = text; card.Visible = true; cardT = 16 end)

-- ---- the sights
local sights = Instance.new("Frame"); sights.AnchorPoint = Vector2.new(0.5, 0.5); sights.Position = UDim2.new(0.5, 0, 0.5, 0); sights.Size = UDim2.new(0, 22, 0, 22); sights.BackgroundTransparency = 1; sights.Visible = false; sights.Parent = gui
local ring = Instance.new("Frame"); ring.Size = UDim2.new(1, 0, 1, 0); ring.BackgroundTransparency = 1; ring.Parent = sights
local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(1, 0); rc.Parent = ring
local rs = Instance.new("UIStroke"); rs.Color = Color3.fromRGB(244, 236, 216); rs.Thickness = 1.6; rs.Parent = ring
local dot = Instance.new("Frame"); dot.AnchorPoint = Vector2.new(0.5, 0.5); dot.Position = UDim2.new(0.5, 0, 0.5, 0); dot.Size = UDim2.new(0, 4, 0, 4); dot.BackgroundColor3 = Color3.fromRGB(244, 236, 216); dot.BorderSizePixel = 0; dot.Parent = sights
local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot

-- ---- ink at the page edges when hurt
local edges = {}
for i, side in ipairs({ "top", "bottom", "left", "right" }) do
	local f = Instance.new("Frame"); f.BackgroundColor3 = Color3.fromRGB(20, 15, 12); f.BorderSizePixel = 0; f.BackgroundTransparency = 1; f.Parent = gui
	local g = Instance.new("UIGradient"); g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }); g.Parent = f
	if side == "top" then f.Size = UDim2.new(1, 0, 0.3, 0); g.Rotation = 90
	elseif side == "bottom" then f.Position = UDim2.new(0, 0, 0.7, 0); f.Size = UDim2.new(1, 0, 0.3, 0); g.Rotation = -90
	elseif side == "left" then f.Size = UDim2.new(0.22, 0, 1, 0); g.Rotation = 0
	else f.Position = UDim2.new(0.78, 0, 0, 0); f.Size = UDim2.new(0.22, 0, 1, 0); g.Rotation = 180 end
	edges[i] = f
end
local hurtPulse = 0

-- ---- Still Life: the sketch
local sketch = Instance.new("ColorCorrectionEffect"); sketch.Name = "Sketch"; sketch.Enabled = false; sketch.Saturation = -1; sketch.Contrast = 0.55; sketch.Brightness = 0.12; sketch.TintColor = Color3.fromRGB(240, 232, 210); sketch.Parent = Lighting
local stillOn = false
E.still.OnClientEvent:Connect(function(on) stillOn = on; sketch.Enabled = on; if on then toastL.Text = "Still Life: every throw finds its mark."; toastL.TextTransparency = 0; toastT = 3 end end)

-- ---- little sounds from the world's own breath: none are loaded, so a flash of light stands in for each
E.fx.OnClientEvent:Connect(function(kind, pos)
	if kind == "hurt" then hurtPulse = 1 end
end)

-- ---- input
local aiming = false
local mouse = player:GetMouse()
local function origin(): Vector3?
	local c = player.Character; local hand = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or c:FindFirstChild("HumanoidRootPart"))
	return hand and hand.Position + Vector3.new(0, 1.5, 0) or nil
end
local function throwAtMouse()
	local o = origin(); if not o then return end
	local hit = mouse.Hit.Position
	local d = hit - o
	E.throw:FireServer((d + Vector3.new(0, d.Magnitude * 0.06, 0)).Unit)
end
local function snapThrow() E.throw:FireServer(nil) end
local function still() E.still:FireServer() end
local function whistle() E.whistle:FireServer() end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = true; sights.Visible = true
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if card.Visible then card.Visible = false elseif aiming or stillOn then throwAtMouse() end
	elseif input.KeyCode == Enum.KeyCode.F then snapThrow()
	elseif input.KeyCode == Enum.KeyCode.Q then still()
	elseif input.KeyCode == Enum.KeyCode.H then whistle()
	elseif input.KeyCode == Enum.KeyCode.E and card.Visible then card.Visible = false end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = false; sights.Visible = false end
end)
-- touch: the same actions as buttons
if UIS.TouchEnabled and not UIS.KeyboardEnabled then
	CAS:BindAction("Throw", function(_, st) if st == Enum.UserInputState.Begin then snapThrow() end end, true, Enum.KeyCode.ButtonX)
	CAS:BindAction("Still", function(_, st) if st == Enum.UserInputState.Begin then still() end end, true, Enum.KeyCode.ButtonY)
	CAS:BindAction("Whistle", function(_, st) if st == Enum.UserInputState.Begin then whistle() end end, true, Enum.KeyCode.ButtonB)
	CAS:SetPosition("Throw", UDim2.new(0.72, 0, 0.55, 0)); CAS:SetPosition("Still", UDim2.new(0.6, 0, 0.7, 0)); CAS:SetPosition("Whistle", UDim2.new(0.84, 0, 0.7, 0))
end

-- the camera pulls in over the shoulder while aiming
local cam = workspace.CurrentCamera
RunService.RenderStepped:Connect(function(dt)
	if toastT > 0 then toastT -= dt; if toastT <= 0 then toastL.TextTransparency = 1 end end
	if cardT > 0 then cardT -= dt; if cardT <= 0 then card.Visible = false end end
	local c = player.Character; local hum = c and c:FindFirstChildOfClass("Humanoid")
	local hp = hum and hum.Health / hum.MaxHealth or 1
	hurtPulse = math.max(0, hurtPulse - dt * 1.5)
	local k = math.clamp((1 - hp) * 0.9 + hurtPulse * 0.4, 0, 0.95)
	for _, f in ipairs(edges) do f.BackgroundTransparency = 1 - k end
	local want = aiming and 7 or 13
	if hum then hum.CameraOffset = hum.CameraOffset:Lerp(aiming and Vector3.new(1.6, 0.6, 0) or Vector3.zero, math.min(1, dt * 8)) end
	if player.CameraMaxZoomDistance ~= 40 then player.CameraMaxZoomDistance = 40; player.CameraMinZoomDistance = 6 end
	UIS.MouseIconEnabled = not aiming
end)
