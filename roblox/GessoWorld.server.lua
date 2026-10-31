--!nocheck
-- Gesso & the Ghost Dogs, for Roblox. The whole world is built here at start: the painted plain as terrain, the eight plates,
-- thirty green seams, the pack of ghost dogs, and the ink that rises out of the plain by night. The client script draws the
-- spec plate, the sights and the sketch, and sends throws, whistles and Still Life. No assets are loaded from anywhere.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function ev(name: string): RemoteEvent local e = Instance.new("RemoteEvent"); e.Name = name; e.Parent = RS; return e end
local E = { hud = ev("Hud"), plate = ev("Plate"), throw = ev("Throw"), still = ev("Still"), whistle = ev("Whistle"), toast = ev("Toast"), fx = ev("Fx") }

local PLASTER = Color3.fromRGB(239, 230, 207)
local MINT = Color3.fromRGB(143, 211, 184)
local INK = Color3.fromRGB(18, 14, 11)
local SEED = 7
local rng = Random.new(SEED)

-- ================================================================ the light of the painting
Lighting.ClockTime = 9.5
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(118, 104, 80)
Lighting.OutdoorAmbient = Color3.fromRGB(156, 140, 108)
Lighting.ExposureCompensation = 0.15
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.5
Lighting.EnvironmentDiffuseScale = 0.6
Lighting.EnvironmentSpecularScale = 0.3
for _, c in ipairs(Lighting:GetChildren()) do c:Destroy() end
local atm = Instance.new("Atmosphere"); atm.Density = 0.34; atm.Offset = 0.3; atm.Color = Color3.fromRGB(214, 192, 152); atm.Decay = Color3.fromRGB(122, 100, 70); atm.Glare = 0.4; atm.Haze = 1.8; atm.Parent = Lighting
local paint = Instance.new("ColorCorrectionEffect"); paint.Name = "Paint"; paint.TintColor = Color3.fromRGB(255, 238, 204); paint.Saturation = -0.32; paint.Contrast = 0.1; paint.Brightness = 0.02; paint.Parent = Lighting
local bloom = Instance.new("BloomEffect"); bloom.Intensity = 0.35; bloom.Size = 28; bloom.Threshold = 1.2; bloom.Parent = Lighting
local rays = Instance.new("SunRaysEffect"); rays.Intensity = 0.12; rays.Spread = 0.6; rays.Parent = Lighting
local dof = Instance.new("DepthOfFieldEffect"); dof.FarIntensity = 0.06; dof.FocusDistance = 40; dof.InFocusRadius = 60; dof.NearIntensity = 0; dof.Parent = Lighting

-- ================================================================ the plain
local T = workspace.Terrain
T:Clear()
for _, n in ipairs({ "Baseplate", "SpawnLocation" }) do local o = workspace:FindFirstChild(n); if o then o:Destroy() end end   -- a baseplate place becomes the plain
T:SetMaterialColor(Enum.Material.Sand, Color3.fromRGB(198, 172, 122))
T:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(148, 128, 92))
T:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(150, 150, 100))
T:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(120, 110, 96))
T.WaterColor = Color3.fromRGB(92, 150, 135); T.WaterTransparency = 0.6; T.WaterReflectance = 0.2; T.WaterWaveSize = 0.05; T.WaterWaveSpeed = 4
local HALF, RES, WATER = 512, 4, -3

local function heightAt(x: number, z: number): number
	local n = math.noise(x / 300 + 3.1, z / 300 + 7.7) * 26 + math.noise(x / 90 + 11, z / 90) * 6 + math.noise(x / 24, z / 24 + 5) * 1.4
	local rim = math.max(0, (math.sqrt(x * x + z * z) - 400) / 100)   -- the rim of the plain rises into hills
	return n + 8 + rim * rim * 12
end

do
	local CH = 128
	for cx = -HALF, HALF - 1, CH do
		for cz = -HALF, HALF - 1, CH do
			local region = Region3.new(Vector3.new(cx, -40, cz), Vector3.new(cx + CH, 60, cz + CH))
			local nx, ny, nz = CH // RES, 100 // RES, CH // RES
			local mats, occ = table.create(nx), table.create(nx)
			for i = 1, nx do
				local mx, ox = table.create(ny), table.create(ny)
				for j = 1, ny do
					local my, oy = table.create(nz), table.create(nz)
					local y = -40 + (j - 1) * RES
					for k = 1, nz do
						local wx, wz = cx + (i - 0.5) * RES, cz + (k - 0.5) * RES
						local h = heightAt(wx, wz)
						local m, o = Enum.Material.Air, 0
						if y + RES <= h then
							o = 1; m = (math.noise(wx / 40, wz / 40) > 0.12) and Enum.Material.Ground or Enum.Material.Sand
						elseif y < h then
							o = (h - y) / RES; m = Enum.Material.Sand
						elseif y < WATER then
							o = 1; m = Enum.Material.Water
						end
						my[k] = m; oy[k] = o
					end
					mx[j] = my; ox[j] = oy
				end
				mats[i] = mx; occ[i] = ox
			end
			T:WriteVoxels(region, RES, mats, occ)
		end
		task.wait()
	end
end

local function ground(x: number, z: number): number return math.max(heightAt(x, z), WATER) end

local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, parent: Instance?): Part
	local p = Instance.new("Part"); p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true; p.CanCollide = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth; p.Parent = parent or workspace
	return p
end

local props = Instance.new("Folder"); props.Name = "Plain"; props.Parent = workspace
-- rocks and the tall dead trees of the plain
for i = 1, 220 do
	local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(40, 470)
	local x, z = math.cos(a) * r, math.sin(a) * r
	local h = heightAt(x, z); if h < WATER + 1 then continue end
	if rng:NextNumber() < 0.7 then
		local s = rng:NextNumber(2, 7)
		local p = part("Rock", Vector3.new(s * 1.4, s * 0.8, s), CFrame.new(x, h + s * 0.2, z) * CFrame.Angles(rng:NextNumber(-0.2, 0.2), a, rng:NextNumber(-0.15, 0.15)), Color3.fromRGB(118, 106, 88), Enum.Material.Slate, props)
		p.Shape = Enum.PartType.Block
	else
		local th = rng:NextNumber(14, 30)
		local trunk = part("Tree", Vector3.new(0.7, th, 0.7), CFrame.new(x, h + th / 2, z) * CFrame.Angles(0, 0, rng:NextNumber(-0.08, 0.08)), Color3.fromRGB(150, 140, 118), Enum.Material.SmoothPlastic, props)
		for b = 1, 3 do
			local bl = rng:NextNumber(3, 6)
			part("Branch", Vector3.new(0.35, bl, 0.35), trunk.CFrame * CFrame.new(0, th / 2 - rng:NextNumber(0, 3), 0) * CFrame.Angles(rng:NextNumber(-0.7, 0.7), rng:NextNumber(0, 6.3), rng:NextNumber(-0.7, 0.7)) * CFrame.new(0, bl / 2, 0), Color3.fromRGB(150, 140, 118), nil, props)
		end
		local bud = part("Bud", Vector3.new(1.2, 1.2, 1.2), CFrame.new(x, h + th + 0.6, z), MINT, Enum.Material.Neon, props); bud.Shape = Enum.PartType.Ball
	end
end
-- two crawlers: the machines that still roll (one of them rolls its circle)
local function crawler(x: number, z: number, moving: boolean)
	local m = Instance.new("Model"); m.Name = "Crawler"; m.Parent = props
	local h = ground(x, z)
	local body = part("Body", Vector3.new(26, 9, 12), CFrame.new(x, h + 11, z), Color3.fromRGB(96, 84, 64), Enum.Material.Metal, m)
	part("Cab", Vector3.new(8, 6, 10), CFrame.new(x + 10, h + 18, z), Color3.fromRGB(110, 96, 72), Enum.Material.Metal, m)
	for _, dx in ipairs({ -8, 8 }) do
		for _, dz in ipairs({ -7, 7 }) do
			local w = part("Wheel", Vector3.new(4, 10, 10), CFrame.new(x + dx, h + 5, z + dz) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(40, 36, 30), Enum.Material.Rubber, m)
			w.Shape = Enum.PartType.Cylinder
		end
	end
	if moving then
		local a = 0
		RunService.Heartbeat:Connect(function(dt)
			a += dt * 0.05
			local cx, cz = x + math.cos(a) * 60, z + math.sin(a) * 60
			local look = CFrame.lookAt(Vector3.new(cx, 0, cz), Vector3.new(cx - math.sin(a), 0, cz + math.cos(a)))
			m:PivotTo(look + Vector3.new(0, ground(cx, cz) + 11, 0))
		end)
	end
end
crawler(120, 280, true); crawler(-300, -260, false)

-- ================================================================ the plates
local LM = {
	{ num = "I", name = "The Reaching Wall", text = "Gesso was cast against this wall with one arm already reaching. Two dogs came out of the paint to keep it company. The relief shows where they all began." },
	{ num = "II", name = "The Great Spine", text = "Something enormous lay down in the dunes and kept only its spine. The vertebrae hum when the wind runs through them, and the discs between them still glow." },
	{ num = "III", name = "The Mere of Seams", text = "The water is the same green as the seams. The stone in the middle has three of them, and on still nights you can see the joins in your own reflection." },
	{ num = "IV", name = "The Leaning Tower", text = "Eight floors of arches, all of them tipping the same way. The two armoured figures at the stair have been arguing about whether it will fall for longer than anyone has watched them." },
	{ num = "V", name = "Crawler Six", text = "A machine built to carry a town across the plain. Its twin still rolls in slow circles through the meadow, and the pink blooms grow back behind its wheels." },
	{ num = "VI", name = "The Golden Field", text = "A landing field striped in gold, kept polished for ships that rarely come. The blue spheres sweep it anyway, and the crew still waits by the glass table." },
	{ num = "VII", name = "The Spires", text = "The rock here grows upward in thin twisted fingers. From this stone the moon sits right on the horizon, as large as it ever gets." },
	{ num = "VIII", name = "The Plinth", text = "A drum of carved stone with a ship perched on top, nose to the sky. Six dogs could stand around its base at once, if you found them all." },
}
local STELES = { { 5, -15 }, { 300, -280 }, { -300, 60 }, { -250, -300 }, { 150, 275 }, { 380, 135 }, { -210, 245 }, { -245, 296 } }
local state = { seams = 0, plates = {}, pack = 2, ink = 0 }
local function hud() E.hud:FireAllClients({ seams = state.seams, plates = #state.plates, pack = state.pack, ink = state.ink }) end
local function toast(player: Player?, text: string) if player then E.toast:FireClient(player, text) else E.toast:FireAllClients(text) end end

local plates = Instance.new("Folder"); plates.Name = "Plates"; plates.Parent = workspace
for i, pos in ipairs(STELES) do
	local x, z = pos[1], pos[2]; local h = ground(x, z)
	local m = Instance.new("Model"); m.Name = "Plate" .. LM[i].num; m.Parent = plates
	local body = part("Stone", Vector3.new(4.5, 6.5, 1.3), CFrame.new(x, h + 3.2, z) * CFrame.Angles(0, math.atan2(-x, -z), 0), Color3.fromRGB(184, 168, 130), Enum.Material.Sandstone, m)
	local top = part("Top", Vector3.new(1.3, 4.5, 4.5), body.CFrame * CFrame.new(0, 3.25, 0) * CFrame.Angles(0, math.pi / 2, 0), Color3.fromRGB(184, 168, 130), Enum.Material.Sandstone, m); top.Shape = Enum.PartType.Cylinder
	local halo = part("Halo", Vector3.new(1, 1, 1), body.CFrame * CFrame.new(0, 3.3, 0), MINT, Enum.Material.Neon, m); halo.Shape = Enum.PartType.Ball; halo.Transparency = 0.5; halo.CanCollide = false
	local light = Instance.new("PointLight"); light.Color = MINT; light.Range = 18; light.Brightness = 1.2; light.Parent = halo
	local label = Instance.new("SurfaceGui"); label.Face = Enum.NormalId.Front; label.Parent = body
	local tl = Instance.new("TextLabel"); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1; tl.Text = LM[i].num; tl.TextColor3 = Color3.fromRGB(60, 50, 38); tl.Font = Enum.Font.Garamond; tl.TextScaled = true; tl.Parent = label
	local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Read plate " .. LM[i].num; prompt.ObjectText = LM[i].name; prompt.HoldDuration = 0; prompt.MaxActivationDistance = 12; prompt.Parent = body
	prompt.Triggered:Connect(function(player)
		if not table.find(state.plates, i) then table.insert(state.plates, i); halo.Transparency = 1; light.Enabled = false; hud() end
		E.plate:FireClient(player, "Plate " .. LM[i].num, LM[i].name, LM[i].text)
	end)
end

-- ================================================================ the seams
local seams = Instance.new("Folder"); seams.Name = "Seams"; seams.Parent = workspace
local seamList = {}
for i = 1, 30 do
	local x, z
	repeat
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(30, 460); x, z = math.cos(a) * r, math.sin(a) * r
	until heightAt(x, z) > WATER + 1
	local h = heightAt(x, z)
	local s = part("Seam", Vector3.new(0.5, 2.2, 1.1), CFrame.new(x, h + 2.6, z), MINT, Enum.Material.Neon, seams); s.CanCollide = false
	local light = Instance.new("PointLight"); light.Color = MINT; light.Range = 10; light.Brightness = 0.8; light.Parent = s
	local rec = { part = s, x = x, z = z, y = h + 2.6, taken = false, marked = false, pillar = nil :: Part? }
	seamList[i] = rec
	s.Touched:Connect(function(hit)
		if rec.taken then return end
		local char = hit:FindFirstAncestorOfClass("Model"); local player = char and Players:GetPlayerFromCharacter(char)
		if not player then return end
		rec.taken = true; state.seams += 1; s:Destroy(); if rec.pillar then rec.pillar:Destroy() end; hud()
		E.fx:FireAllClients("seam", Vector3.new(x, h + 2.6, z))
		toast(nil, state.seams == 30 and "Every seam is gathered. The plain looks a little more finished than it did." or ("Seam gathered · " .. state.seams .. " of 30"))
	end)
end
RunService.Heartbeat:Connect(function()
	local t = os.clock()
	for i, rec in ipairs(seamList) do
		if not rec.taken then rec.part.CFrame = CFrame.new(rec.x, rec.y + math.sin(t * 2 + i) * 0.4, rec.z) * CFrame.Angles(0, t * 1.2 + i, 0) end
	end
end)

-- ================================================================ the pack
local DOGS = { { "Vellum", nil }, { "Sepia", nil }, { "Umber", { -120, -330 } }, { "Ochre", { 330, -60 } }, { "Lamp", { -340, 300 } }, { "Nib", { 410, 240 } } }
local dogFolder = Instance.new("Folder"); dogFolder.Name = "Pack"; dogFolder.Parent = workspace
local dogs = {}
local function buildDog(name: string, home)
	local m = Instance.new("Model"); m.Name = name; m.Parent = dogFolder
	local tint = Color3.fromRGB(236, 228, 206)
	local function ghost(size: Vector3, cf: CFrame, nm: string): Part
		local p = part(nm, size, cf, tint, Enum.Material.Glass, m); p.Transparency = 0.42; p.CanCollide = false; p.CastShadow = false; return p
	end
	local body = ghost(Vector3.new(1.6, 1.5, 3.6), CFrame.new(0, 2, 0), "Body")
	local head = ghost(Vector3.new(1.2, 1.1, 1.6), CFrame.new(0, 2.6, 2.3), "Head")
	local muzzle = ghost(Vector3.new(0.7, 0.6, 0.9), CFrame.new(0, 2.35, 3.3), "Muzzle")
	local earL = ghost(Vector3.new(0.3, 0.8, 0.5), CFrame.new(-0.45, 3.3, 2.1), "Ear"); local earR = ghost(Vector3.new(0.3, 0.8, 0.5), CFrame.new(0.45, 3.3, 2.1), "Ear")
	local tail = ghost(Vector3.new(0.3, 0.3, 1.6), CFrame.new(0, 2.5, -2.4), "Tail")
	local legs = {}
	for li, off in ipairs({ Vector3.new(-0.55, 1, 1.3), Vector3.new(0.55, 1, 1.3), Vector3.new(-0.55, 1, -1.3), Vector3.new(0.55, 1, -1.3) }) do
		legs[li] = { p = ghost(Vector3.new(0.4, 1.6, 0.4), CFrame.new(off), "Leg"), off = off }
	end
	-- the spine shows through the glass, as in the painting
	for k = 0, 6 do local v = part("Vertebra", Vector3.new(0.5, 0.35, 0.3), CFrame.new(0, 2.85, 1.6 - k * 0.55), PLASTER, Enum.Material.SmoothPlastic, m); v.CanCollide = false; v.CastShadow = false end
	local eyeL = part("Eye", Vector3.new(0.12, 0.22, 0.3), CFrame.new(-0.35, 2.75, 3.0), MINT, Enum.Material.Neon, m); eyeL.CanCollide = false
	local eyeR = part("Eye", Vector3.new(0.12, 0.22, 0.3), CFrame.new(0.35, 2.75, 3.0), MINT, Enum.Material.Neon, m); eyeR.CanCollide = false
	local light = Instance.new("PointLight"); light.Color = MINT; light.Range = 14; light.Brightness = 0.6; light.Parent = body
	m.PrimaryPart = body
	local d = { model = m, name = name, legs = legs, tail = tail, ears = { earL, earR }, x = 0, z = 0, y = 0, head = 0, vx = 0, vz = 0, spd = 0, gait = 0, state = home and "lost" or "follow", target = nil, timer = 0, sit = 0, joined = home == nil, home = home }
	if home then
		d.x, d.z = home[1], home[2]
		local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Call " .. name; prompt.ObjectText = "A lost dog"; prompt.MaxActivationDistance = 14; prompt.HoldDuration = 0; prompt.Parent = body
		prompt.Triggered:Connect(function(player)
			if d.joined then return end
			d.joined = true; d.state = "follow"; state.pack += 1; prompt:Destroy(); light.Brightness = 0.6; hud()
			E.fx:FireAllClients("join", body.Position)
			toast(nil, name .. " joins the pack." .. (state.pack == 6 and " The whole pack is with you now." or ""))
		end)
		light.Brightness = 0.2
	end
	table.insert(dogs, d)
	return d
end
for _, def in ipairs(DOGS) do buildDog(def[1], def[2]) end

local function nearestPlayerPos(x: number, z: number): (Vector3?, Player?)
	local best, bp, bd = nil, nil, math.huge
	for _, pl in ipairs(Players:GetPlayers()) do
		local c = pl.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp then local d = (Vector3.new(x, 0, z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude; if d < bd then bd = d; best = hrp.Position; bp = pl end end
	end
	return best, bp
end

local function poseDog(d, dt: number)
	local m = d.model
	local bob = math.abs(math.sin(d.gait)) * 0.25 * math.min(1, d.spd / 10)
	local base = CFrame.new(d.x, d.y + bob - d.sit * 0.6, d.z) * CFrame.Angles(0, d.head, 0) * CFrame.Angles(d.sit * 0.35, 0, 0)
	local t = os.clock()
	m.Body.CFrame = base * CFrame.new(0, 2, 0)
	m.Head.CFrame = base * CFrame.new(0, 2.6 + d.sit * 0.2, 2.3) * CFrame.Angles(-0.1 + math.sin(t * 1.3) * 0.05, 0, 0)
	m.Muzzle.CFrame = base * CFrame.new(0, 2.35 + d.sit * 0.2, 3.3)
	for i, e in ipairs(d.ears) do e.CFrame = base * CFrame.new((i == 1 and -0.45 or 0.45), 3.3, 2.1) * CFrame.Angles(-0.5 * math.min(1, d.spd / 8) + math.sin(t * 3 + i) * 0.1, 0, (i == 1 and -0.3 or 0.3)) end
	m.Tail.CFrame = base * CFrame.new(0, 2.5, -2.4) * CFrame.Angles(0.3 + math.sin(t * 8) * 0.2, math.sin(t * 6) * 0.35, 0)
	for li, L in ipairs(d.legs) do
		local swing = math.sin(d.gait + ((li == 1 or li == 4) and 0 or math.pi)) * 0.7 * math.min(1, d.spd / 8)
		L.p.CFrame = base * CFrame.new(L.off) * CFrame.new(0, 0.8, 0) * CFrame.Angles(swing, 0, 0) * CFrame.new(0, -0.8 + d.sit * 0.5, 0)
	end
	local vi = 0
	for _, c in ipairs(m:GetChildren()) do if c.Name == "Vertebra" then c.CFrame = base * CFrame.new(0, 2.85 + bob * 0.3, 1.6 - vi * 0.55); vi += 1 end end
	local eyes = 0
	for _, c in ipairs(m:GetChildren()) do if c.Name == "Eye" then c.CFrame = base * CFrame.new(eyes == 0 and -0.35 or 0.35, 2.75 + d.sit * 0.2, 3.0); eyes += 1 end end
end

RunService.Heartbeat:Connect(function(dt)
	local slot = 0
	for _, d in ipairs(dogs) do
		local ppos, player = nearestPlayerPos(d.x, d.z)
		local tx, tz, maxS, wantSit = d.x, d.z, 24, 0
		if d.state == "lost" or not ppos then
			d.spd = 0; d.sit = math.min(1, d.sit + dt * 2)
			if ppos then d.head = math.atan2(ppos.X - d.x, ppos.Z - d.z) end
			d.y = ground(d.x, d.z); poseDog(d, dt); continue
		elseif d.state == "seek" and d.target then
			tx, tz, maxS = d.target.x, d.target.z, 40
			if d.target.taken then d.state = "follow" elseif (Vector3.new(tx - d.x, 0, tz - d.z)).Magnitude < 4 then
				d.state = "point"; d.timer = 6; d.target.marked = true
				if not d.target.pillar then local pl = part("Pillar", Vector3.new(1.2, 60, 1.2), CFrame.new(d.target.x, d.target.y + 30, d.target.z), MINT, Enum.Material.Neon, seams); pl.Transparency = 0.7; pl.CanCollide = false; d.target.pillar = pl end
				E.fx:FireAllClients("howl", Vector3.new(d.x, d.y, d.z))
			end
		elseif d.state == "point" then
			d.timer -= dt; wantSit = 1; if d.timer <= 0 then d.state = "follow" end
		else
			local k = slot; slot += 1
			local back, side = 6 + 3 * (k // 2), ((k % 2 == 0) and -1 or 1) * (3.5 + 1.2 * (k // 2))
			local pyaw = 0
			if player and player.Character then local hrp = player.Character:FindFirstChild("HumanoidRootPart"); if hrp then pyaw = math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z) end end
			local fx, fz = -math.sin(pyaw), -math.cos(pyaw)
			tx = ppos.X - fx * back + fz * side + math.sin(os.clock() * 0.3 + k) * 2
			tz = ppos.Z - fz * back - fx * side + math.cos(os.clock() * 0.25 + k) * 2
			if (Vector3.new(ppos.X - d.x, 0, ppos.Z - d.z)).Magnitude > 180 then d.x, d.z = ppos.X - fx * 12, ppos.Z - fz * 12 end
		end
		local dx, dz = tx - d.x, tz - d.z; local dist = math.sqrt(dx * dx + dz * dz)
		local want = dist < 1 and 0 or math.min(maxS, dist * 2.2)
		local kk = math.min(1, dt * 5)
		d.vx += ((dist > 0 and dx / dist * want or 0) - d.vx) * kk; d.vz += ((dist > 0 and dz / dist * want or 0) - d.vz) * kk
		d.x += d.vx * dt; d.z += d.vz * dt; d.spd = math.sqrt(d.vx * d.vx + d.vz * d.vz)
		d.y = ground(d.x, d.z)
		if d.spd > 0.5 and d.state ~= "point" then local a = math.atan2(d.vx, d.vz); local da = math.atan2(math.sin(a - d.head), math.cos(a - d.head)); d.head += da * math.min(1, dt * 8) end
		if d.state == "point" and d.target then d.head = math.atan2(d.target.x - d.x, d.target.z - d.z) end
		d.gait += dt * (2 + d.spd * 0.55)
		local ws = (wantSit == 1 and d.spd < 1) and 1 or 0
		d.sit += (ws - d.sit) * math.min(1, dt * 4)
		poseDog(d, dt)
	end
end)

E.whistle.OnServerEvent:Connect(function(player)
	local c = player.Character; local hrp = c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	-- in a fight the pack goes for the ink; otherwise it runs off to point at the nearest seams
	local targets = {}
	for _, rec in ipairs(seamList) do if not rec.taken and not rec.marked then table.insert(targets, { rec = rec, d = (Vector3.new(rec.x, 0, rec.z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude }) end end
	table.sort(targets, function(a, b) return a.d < b.d end)
	local pack = {}
	for _, d in ipairs(dogs) do if d.joined and d.state ~= "seek" then table.insert(pack, d) end end
	local n = math.min(#pack, 3, #targets)
	E.fx:FireAllClients("whistle", hrp.Position)
	if n == 0 then toast(player, #targets > 0 and "The pack is already out searching." or "Your dogs have found everything there is to find."); return end
	for k = 1, n do pack[k].state = "seek"; pack[k].target = targets[k].rec end
	toast(player, n == 1 and (pack[1].name .. " runs off to search.") or (pack[1].name .. " and " .. pack[2].name .. " run off to search."))
end)

-- ================================================================ the ink
local inkFolder = Instance.new("Folder"); inkFolder.Name = "Ink"; inkFolder.Parent = workspace
local wraiths = {}
local STILL = { on = false, until_ = 0 }
local function isNight(): boolean local c = Lighting.ClockTime; return c > 18.3 or c < 5.7 end

local function spawnWraith(x: number, z: number)
	local m = Instance.new("Model"); m.Name = "Inkwraith"; m.Parent = inkFolder
	local body = part("Body", Vector3.new(3.2, 7, 2.6), CFrame.new(x, -10, z), INK, Enum.Material.SmoothPlastic, m); body.CanCollide = false; body.Transparency = 0.1
	local hood = part("Hood", Vector3.new(3.4, 3.4, 3.4), CFrame.new(x, -10, z), INK, Enum.Material.SmoothPlastic, m); hood.Shape = Enum.PartType.Ball; hood.CanCollide = false
	local peak = part("Peak", Vector3.new(0.5, 1.6, 0.5), CFrame.new(x, -10, z), INK, Enum.Material.SmoothPlastic, m); peak.CanCollide = false
	local eyeL = part("Eye", Vector3.new(0.7, 0.18, 0.2), CFrame.new(x, -10, z), Color3.fromRGB(246, 240, 223), Enum.Material.Neon, m); eyeL.CanCollide = false
	local eyeR = part("Eye", Vector3.new(0.7, 0.18, 0.2), CFrame.new(x, -10, z), Color3.fromRGB(246, 240, 223), Enum.Material.Neon, m); eyeR.CanCollide = false
	local sleeves = { part("Sleeve", Vector3.new(0.9, 4.2, 0.9), CFrame.new(x, -10, z), INK, nil, m), part("Sleeve", Vector3.new(0.9, 4.2, 0.9), CFrame.new(x, -10, z), INK, nil, m) }
	for _, s in ipairs(sleeves) do s.CanCollide = false end
	local pe = Instance.new("ParticleEmitter"); pe.Color = ColorSequence.new(INK); pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 2.4) }); pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	pe.Lifetime = NumberRange.new(1.2, 2.2); pe.Rate = 18; pe.Speed = NumberRange.new(1.5, 3); pe.SpreadAngle = Vector2.new(30, 30); pe.LightEmission = 0; pe.Parent = body
	local pool = part("Pool", Vector3.new(7, 0.2, 7), CFrame.new(x, ground(x, z) + 0.1, z), INK, Enum.Material.SmoothPlastic, m); pool.Shape = Enum.PartType.Cylinder; pool.CFrame = CFrame.new(x, ground(x, z) + 0.1, z) * CFrame.Angles(0, 0, math.pi / 2); pool.Size = Vector3.new(0.2, 7, 7); pool.CanCollide = false; pool.Transparency = 0.25
	m.PrimaryPart = body
	local w = { model = m, body = body, hood = hood, peak = peak, eyes = { eyeL, eyeR }, sleeves = sleeves, pool = pool, x = x, z = z, hp = 3, rise = 0, state = "rise", t = 0, spread = 0, atk = rng:NextNumber(3, 6), orbit = 0, dir = rng:NextNumber() < 0.5 and -1 or 1, head = 0, lx = 0, lz = 0, dead = false, hitDone = false }
	table.insert(wraiths, w)
	E.fx:FireAllClients("rise", Vector3.new(x, ground(x, z), z))
	return w
end

local function placeWraith(w)
	local gy = ground(w.x, w.z); local rise = w.rise
	local base = CFrame.new(w.x, gy - 7 + 7 * rise + 3.5 + math.sin(os.clock() * 1.7) * 0.15, w.z) * CFrame.Angles(0, w.head, 0)
	w.body.CFrame = base
	w.hood.CFrame = base * CFrame.new(0, 3.8, 0)
	w.peak.CFrame = base * CFrame.new(0, 5.8, 0)
	w.eyes[1].CFrame = base * CFrame.new(-0.6, 4.2, 1.6) * CFrame.Angles(0, 0, 0.3)
	w.eyes[2].CFrame = base * CFrame.new(0.6, 4.2, 1.6) * CFrame.Angles(0, 0, -0.3)
	local sp = w.spread
	w.sleeves[1].CFrame = base * CFrame.new(-1.9 - sp * 1.6, 1.2 + sp * 2.6, 0.3) * CFrame.Angles(0, 0, 0.3 + sp * 1.2)
	w.sleeves[2].CFrame = base * CFrame.new(1.9 + sp * 1.6, 1.2 + sp * 2.6, 0.3) * CFrame.Angles(0, 0, -0.3 - sp * 1.2)
	w.pool.Size = Vector3.new(0.2, 7 * (0.5 + 0.5 * rise) + sp * 3, 7 * (0.5 + 0.5 * rise) + sp * 3)
end

local function killWraith(w, byPlayer: Player?)
	if w.dead then return end
	w.dead = true; state.ink += 1; hud()
	E.fx:FireAllClients("wash", w.body.Position)
	for _, p in ipairs(w.model:GetDescendants()) do
		if p:IsA("BasePart") then
			TweenService:Create(p, TweenInfo.new(0.6), { Color = PLASTER }):Play()
			task.delay(0.8, function() TweenService:Create(p, TweenInfo.new(1.2), { Transparency = 1 }):Play() end)
		elseif p:IsA("ParticleEmitter") then p.Enabled = false end
	end
	task.delay(2.2, function() w.model:Destroy() end)
	local gy = ground(w.x, w.z)
	local stain = part("Gesso", Vector3.new(0.2, 9, 9), CFrame.new(w.x, gy + 0.12, w.z) * CFrame.Angles(0, 0, math.pi / 2), PLASTER, Enum.Material.SmoothPlastic, inkFolder); stain.Shape = Enum.PartType.Cylinder; stain.CanCollide = false
	task.delay(60, function() TweenService:Create(stain, TweenInfo.new(6), { Transparency = 1 }):Play(); task.delay(6, function() stain:Destroy() end) end)
	toast(nil, "Whitewashed · " .. state.ink .. " ink")
end

local function hitWraith(w, pos: Vector3, byPlayer: Player?)
	if w.dead then return end
	local head = pos.Y > w.hood.Position.Y - 1.2
	w.hp -= head and 3 or 1
	local splat = part("Splat", Vector3.new(1.4, 1.4, 0.3), CFrame.new(pos) * CFrame.Angles(0, w.head, 0), PLASTER, Enum.Material.SmoothPlastic, w.model); splat.CanCollide = false
	E.fx:FireAllClients("splat", pos)
	if w.hp <= 0 then killWraith(w, byPlayer); return end
	w.state = "stagger"; w.t = 0
end

local function hurt(player: Player, amount: number, from: Vector3)
	local c = player.Character; local hum = c and c:FindFirstChildOfClass("Humanoid"); local hrp = c and c:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp or hum.Health <= 0 then return end
	hum:TakeDamage(amount)
	hrp:ApplyImpulse((hrp.Position - from).Unit * 300 + Vector3.new(0, 150, 0))
	E.fx:FireClient(player, "hurt", hrp.Position)
end

local nextInk = 40
RunService.Heartbeat:Connect(function(dt)
	-- the day: seven minutes
	Lighting.ClockTime = (Lighting.ClockTime + dt * 24 / 420) % 24
	-- the director: ink rises near a player, more often and bolder by night
	if #wraiths == 0 and #Players:GetPlayers() > 0 then
		nextInk -= dt * (isNight() and 2 or 1)
		if nextInk <= 0 then
			local pl = Players:GetPlayers()[rng:NextInteger(1, #Players:GetPlayers())]
			local hrp = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local n = isNight() and rng:NextInteger(2, 3) or 1
				local a = rng:NextNumber(0, math.pi * 2)
				for k = 1, n do
					local r = 55 + k * 9; local x, z = hrp.Position.X + math.cos(a + k * 0.25) * r, hrp.Position.Z + math.sin(a + k * 0.25) * r
					if heightAt(x, z) > WATER + 1 then task.delay(k * 0.5, function() spawnWraith(x, z) end) end
				end
				toast(nil, isNight() and "The ink is bold tonight." or "Ink is rising out of the plain. Hold the right mouse button to aim, and click to throw gesso.")
			end
			nextInk = isNight() and rng:NextNumber(60, 100) or rng:NextNumber(120, 180)
		end
	end
	if STILL.on and os.clock() > STILL.until_ then STILL.on = false; E.still:FireAllClients(false) end
	local night = isNight() and 1 or 0
	for i = #wraiths, 1, -1 do
		local w = wraiths[i]
		if w.dead then table.remove(wraiths, i); continue end
		if STILL.on then placeWraith(w); continue end
		w.t += dt
		local ppos, player = nearestPlayerPos(w.x, w.z)
		if not ppos then w.state = "sink"; end
		local dx, dz = ppos and (ppos.X - w.x) or 0, ppos and (ppos.Z - w.z) or 0
		local dist = math.sqrt(dx * dx + dz * dz); local ux, uz = dist > 0 and dx / dist or 0, dist > 0 and dz / dist or 0
		local tx, tz, sp, spread = w.x, w.z, 0, 0
		if w.state == "rise" then
			w.rise = math.min(1, w.rise + dt * 0.7); if w.rise >= 1 then w.state = "stalk"; w.t = 0 end
		elseif w.state == "stalk" then
			if dist > 260 then w.state = "sink" end
			local R = 26 + night * 0
			if dist > R + 10 then tx, tz, sp = ppos.X, ppos.Z, 14 + night * 4 else w.orbit += dt * 0.3 * w.dir; tx, tz, sp = ppos.X + math.sin(w.orbit) * R, ppos.Z + math.cos(w.orbit) * R, 9 end
			w.atk -= dt * (1 + 0.4 * night)
			if w.atk <= 0 and dist < 40 then w.state = "windup"; w.t = 0; E.fx:FireAllClients("windup", w.body.Position) end
		elseif w.state == "windup" then
			spread = math.min(1, w.t / 0.8)
			if w.t >= 0.8 and ppos then w.lx, w.lz = ux, uz; w.state = "lunge"; w.t = 0; w.hitDone = false; E.fx:FireAllClients("lunge", w.body.Position) end
		elseif w.state == "lunge" then
			spread = 1 - w.t; w.x += w.lx * 48 * dt; w.z += w.lz * 48 * dt
			if not w.hitDone and dist < 6 and player then w.hitDone = true; hurt(player, 18 + 6 * night, w.body.Position) end
			if w.t > 0.7 then w.state = "recoil"; w.t = 0; w.atk = rng:NextNumber(4, 8) end
		elseif w.state == "recoil" then
			tx, tz, sp = w.x - ux * 12, w.z - uz * 12, 10; if w.t > 1 then w.state = "stalk"; w.t = 0 end
		elseif w.state == "stagger" then
			tx, tz, sp = w.x - ux * 5, w.z - uz * 5, 6; if w.t > 0.7 then w.state = "stalk"; w.t = 0 end
		elseif w.state == "sink" then
			w.rise = math.max(0, w.rise - dt * 0.8); if w.rise <= 0 then w.model:Destroy(); table.remove(wraiths, i); continue end
		end
		if w.state ~= "lunge" and sp > 0 then
			local ddx, ddz = tx - w.x, tz - w.z; local dd = math.sqrt(ddx * ddx + ddz * ddz)
			if dd > 0.5 then local step = math.min(sp * dt, dd); w.x += ddx / dd * step; w.z += ddz / dd * step end
		end
		if ppos then w.head = math.atan2(ppos.X - w.x, ppos.Z - w.z) end
		w.spread += (spread - w.spread) * math.min(1, dt * 8)
		placeWraith(w)
	end
end)

-- ================================================================ throwing gesso
local function throwFrom(player: Player, dir: Vector3?, homing)
	local c = player.Character; if not c then return end
	local hrp = c:FindFirstChild("HumanoidRootPart"); local hand = c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or hrp
	if not hrp or not hand then return end
	local origin = hand.Position + Vector3.new(0, 1.5, 0)
	local target
	if homing then
		local best, bd = nil, math.huge
		for _, w in ipairs(wraiths) do if not w.dead and w.rise > 0.5 then local d = (w.body.Position - origin).Magnitude; if d < bd then bd = d; best = w end end end
		if not best then return end
		target = best
		dir = (best.hood.Position - origin).Unit
	elseif not dir then
		local best, bd = nil, math.huge
		for _, w in ipairs(wraiths) do if not w.dead and w.rise > 0.5 then local d = (w.body.Position - origin).Magnitude; if d < 160 and d < bd then bd = d; best = w end end end
		if best then local d = best.hood.Position - origin; dir = (d + Vector3.new(0, d.Magnitude * 0.08, 0)).Unit else dir = hrp.CFrame.LookVector end
	end
	if typeof(dir) ~= "Vector3" or dir.Magnitude < 0.5 then return end
	dir = dir.Unit
	local ball = part("Gesso", Vector3.new(1, 1, 1), CFrame.new(origin + dir * 2.5), PLASTER, Enum.Material.SmoothPlastic, inkFolder)
	ball.Shape = Enum.PartType.Ball; ball.Anchored = false; ball.CanCollide = false; ball.Massless = true
	ball.AssemblyLinearVelocity = dir * 120 + (homing and Vector3.zero or Vector3.new(0, 10, 0))
	local done = false
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if done then conn:Disconnect(); return end
		local p = ball.Position
		if homing and target and not target.dead then ball.AssemblyLinearVelocity = (target.hood.Position - p).Unit * 130 end
		for _, w in ipairs(wraiths) do
			if w.dead or w.rise < 0.3 then continue end
			local q = p - w.body.Position
			if math.abs(q.Y) < 6 and Vector3.new(q.X, 0, q.Z).Magnitude < 2.4 then done = true; hitWraith(w, p, player); ball:Destroy(); return end
		end
		if p.Y < ground(p.X, p.Z) + 0.3 then
			done = true; ball:Destroy()
			local st = part("Gesso", Vector3.new(0.2, 2.2, 2.2), CFrame.new(p.X, ground(p.X, p.Z) + 0.12, p.Z) * CFrame.Angles(0, 0, math.pi / 2), PLASTER, Enum.Material.SmoothPlastic, inkFolder); st.Shape = Enum.PartType.Cylinder; st.CanCollide = false
			task.delay(40, function() st:Destroy() end)
		end
	end)
	task.delay(4, function() if not done then done = true; ball:Destroy() end end)
	E.fx:FireAllClients("throw", origin)
end
E.throw.OnServerEvent:Connect(function(player, dir) throwFrom(player, dir, STILL.on) end)

-- Still Life: the painting holds still for four seconds and every throw finds its mark
E.still.OnServerEvent:Connect(function(player)
	if STILL.on then return end
	STILL.on = true; STILL.until_ = os.clock() + 4
	E.still:FireAllClients(true)
end)

-- ================================================================ Gesso himself: every player is cast in plaster
local spawn = Instance.new("SpawnLocation"); spawn.Name = "Spawn"; spawn.Size = Vector3.new(8, 1, 8); spawn.Anchored = true; spawn.Transparency = 1; spawn.CanCollide = false
spawn.CFrame = CFrame.new(0, ground(0, 14) + 4, 14); spawn.Parent = workspace

local function cast(char: Model)
	local hum = char:WaitForChild("Humanoid") :: Humanoid
	hum.WalkSpeed = 20; hum.JumpPower = 45
	task.wait(0.2)
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") then c:Destroy() end
	end
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then p.Material = Enum.Material.SmoothPlastic; p.Color = PLASTER
		elseif p:IsA("Decal") then p:Destroy() end
	end
	local head = char:FindFirstChild("Head")
	if head then
		for _, off in ipairs({ Vector3.new(-0.22, 0.08, -0.5), Vector3.new(0.22, 0.08, -0.5) }) do
			local s = Instance.new("Part"); s.Size = Vector3.new(0.3, 0.26, 0.12); s.Color = Color3.fromRGB(44, 38, 28); s.Material = Enum.Material.SmoothPlastic; s.CanCollide = false; s.Massless = true
			s.CFrame = head.CFrame * CFrame.new(off); s.Parent = char
			local weld = Instance.new("WeldConstraint"); weld.Part0 = head; weld.Part1 = s; weld.Parent = s
		end
		local nose = Instance.new("Part"); nose.Size = Vector3.new(0.14, 0.22, 0.1); nose.Color = Color3.fromRGB(60, 52, 40); nose.Material = Enum.Material.SmoothPlastic; nose.CanCollide = false; nose.Massless = true
		nose.CFrame = head.CFrame * CFrame.new(0, -0.14, -0.5); nose.Parent = char
		local w2 = Instance.new("WeldConstraint"); w2.Part0 = head; w2.Part1 = nose; w2.Parent = nose
	end
end
local function welcome(player: Player)
	player.CharacterAdded:Connect(cast)
	if player.Character then task.spawn(cast, player.Character) end
	task.delay(1, function()
		E.hud:FireClient(player, { seams = state.seams, plates = #state.plates, pack = state.pack, ink = state.ink })
		E.toast:FireClient(player, "Press H to whistle. Your dogs will sniff out the green seams.")
	end)
end
Players.PlayerAdded:Connect(welcome)
for _, player in ipairs(Players:GetPlayers()) do welcome(player) end   -- anyone who arrived while the plain was still being painted
