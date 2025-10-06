local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))();
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))();
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))();
if not (game:IsLoaded()) then game.Loaded:Wait(); end;
local Window = Library:CreateWindow({
    Title = "                          scripthookv     weird strict dad(book 2)",
    Center = true,
    AutoShow = true,
})
local Tabs = {
    Main = Window:AddTab("main"),
    ['settings'] = Window:AddTab('settings'),
}
local MainBox = Tabs.Main:AddLeftGroupbox("main")
MainBox:AddButton({
    Text = "enable prompts",
    Func = function()
        local count = 0
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and not obj.Enabled then
                obj.Enabled = true
                count += 1
            end
        end
    end,
    Tooltip = 'force enables curtains, gas, lights, ect at the beginning',
});
MainBox:AddButton("no fog", function()
    local Lighting = cloneref(game:GetService("Lighting"))
    Lighting.FogStart = 10000
    Lighting.FogEnd = 10000
    Library:Notify("fog removed", 3)
end);
MainBox:AddButton("rejoin server", function()
    game.Players.LocalPlayer:Kick("rejoining")
    wait()
    queue_on_teleport[[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xectray1/realloader/refs/heads/main/books.lua"))()
    ]]
    cloneref(game:GetService("TeleportService")):Teleport(game.PlaceId, game.Players.LocalPlayer);
end);

local TweenService = game:GetService("TweenService")
local AlreadyRan = false
local HadSeatsBefore = false
local FarmDigsExistedBefore = false

local function TelportTo(part)
    if not game.Players.LocalPlayer.Character or not part then return end
    local RootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if RootPart then
        RootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

local function TelportToPosition(pos)
    if not game.Players.LocalPlayer.Character then return end
    local RootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if RootPart then
        RootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end
local function FirePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt)
    end
end
local function EquipShovel()
    local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Shovel")
    if tool then
        tool.Parent = game.Players.LocalPlayer.Character
    end
end
local function ShouldBlockScript()
    local Backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
    local HasSeatsNow = Backpack and Backpack:FindFirstChild("Seats") ~= nil
    local Suspicion1 = HasSeatsNow
    local Farm = workspace:FindFirstChild("Farm")
    local DigExistsNow = Farm and Farm:FindFirstChild("Dig") and Farm.Dig:FindFirstChild("FarmDigs")
    local Suspicion2 = not DigExistsNow and HadSeatsBefore and FarmDigsExistedBefore
    local Suspicion3 = AlreadyRan
    return Suspicion1 and Suspicion2 and Suspicion3
end
local function GetSeats()
    AlreadyRan = true
    local Backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
    if Backpack and Backpack:FindFirstChild("Seats") then
        HadSeatsBefore = true
    end

    local Farm = workspace:FindFirstChild("Farm")
    local Dig = Farm and Farm:FindFirstChild("Dig")
    local FarmDigs = Dig and Dig:FindFirstChild("FarmDigs")
    if FarmDigs then
        FarmDigsExistedBefore = true
    end
    if ShouldBlockScript() then
        Library:Notify("you already got seats")
        return
    end

local Grabbables = workspace:FindFirstChild("Grabbables")
local ShovelFolder = Grabbables and Grabbables:FindFirstChild("Shovel")
local Shovel = ShovelFolder and ShovelFolder:FindFirstChild("Shovel")
if not Shovel then
    TelportToPosition(Vector3.new(140, 56, 907))
    local timeout = 1.5
    local StartTime = tick()

    repeat
        task.wait(0.1)
        Grabbables = workspace:FindFirstChild("Grabbables")
        ShovelFolder = Grabbables and Grabbables:FindFirstChild("Shovel")
        Shovel = ShovelFolder and ShovelFolder:FindFirstChild("Shovel")
    until Shovel or tick() - StartTime > timeout
    if not Shovel then
        return
    end
end
local ShovelPrompt = Shovel:FindFirstChildOfClass("ProximityPrompt")
local DigSpot = FarmDigs or (Dig and Dig:WaitForChild("FarmDigs"))
local DigPrompt = DigSpot and DigSpot:FindFirstChildOfClass("ProximityPrompt")

    TelportTo(Shovel)
    task.wait(0.1)
    FirePrompt(ShovelPrompt)
    task.wait(0.1)

    if DigSpot then
        TelportTo(DigSpot)
        task.wait(0.1)
        EquipShovel()
        task.wait(0.1)
        FirePrompt(DigPrompt)
    end
end
MainBox:AddButton("get seats", GetSeats)
local InstantInteractEnabled = false
local OriginalHoldDuration = {}
local connections = {}
local function ApplyPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if InstantInteractEnabled then
        if OriginalHoldDuration[prompt] == nil then
            OriginalHoldDuration[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end

local function RestorePrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if OriginalHoldDuration[prompt] ~= nil then
        prompt.HoldDuration = OriginalHoldDuration[prompt]
        OriginalHoldDuration[prompt] = nil
    end
end

local function SetInstantInteract(enabled)
    InstantInteractEnabled = enabled

    if enabled then
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            ApplyPrompt(obj)
        end

        connections.DescendantAdded = game.Workspace.DescendantAdded:Connect(function(obj)
            ApplyPrompt(obj)
        end)

        connections.DescendantRemoving = game.Workspace.DescendantRemoving:Connect(function(obj)
            RestorePrompt(obj)
        end)
    else
        for prompt, _ in pairs(OriginalHoldDuration) do
            if prompt and prompt:IsDescendantOf(game.Workspace) then
                RestorePrompt(prompt)
            end
        end

        for _, conn in pairs(connections) do
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end

        connections = {}
    end
end
MainBox:AddToggle("InstantInteract", {
    Text = "instant interact",
    Default = false,
    Callback = SetInstantInteract,
})

local INFStamEnabled = false
local StaminaConnection
local function InfiniteStamina(enabled)
    INFStamEnabled = enabled

    if StaminaConnection then
        StaminaConnection:Disconnect()
        StaminaConnection = nil
    end

    if enabled then
        local StaminaValue = game.Players.LocalPlayer.PlayerGui.Time:GetChildren()[7].stamina
        local lastValue = StaminaValue.Value

        StaminaConnection = cloneref(game:GetService("RunService")).Heartbeat:Connect(function()
            if StaminaValue.Value ~= 250 then
                StaminaValue.Value = 250
            end
        end)
    end
end

MainBox:AddToggle("InfiniteStamina", {
    Text = "infinite stamina",
    Default = false,
    Callback = InfiniteStamina,
})

local FullBrightEnabled = false
local FullBrightConnection
local OriginalLightingSettings = {}

local function ToggleFullBright(enabled)
    local Lighting = cloneref(game:GetService("Lighting"))

    if FullBrightConnection then
        FullBrightConnection:Disconnect()
        FullBrightConnection = nil
    end

    FullBrightEnabled = enabled

    if enabled then
        OriginalLightingSettings = {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd
        }

        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000

        FullBrightConnection = cloneref(game:GetService("RunService")).RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        end)

    else
        if OriginalLightingSettings and next(OriginalLightingSettings) then
            Lighting.Brightness = OriginalLightingSettings.Brightness
            Lighting.Ambient = OriginalLightingSettings.Ambient
            Lighting.OutdoorAmbient = OriginalLightingSettings.OutdoorAmbient
            Lighting.FogStart = OriginalLightingSettings.FogStart
            Lighting.FogEnd = OriginalLightingSettings.FogEnd
        end

    end
end

MainBox:AddToggle("FullBright", {
    Text = "full bright",
    Default = false,
    Callback = ToggleFullBright,
})
local function ToggleThirdPerson(enabled)
    local player = cloneref(game:GetService("Players")).LocalPlayer

    if enabled then
        player.CameraMode = Enum.CameraMode.Classic
        player.CameraMaxZoomDistance = 128
        player.CameraMinZoomDistance = 0.5
    else
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end
MainBox:AddToggle("ThirdPerson", {
    Text = "third person",
    Default = false,
    Callback = ToggleThirdPerson,
})

local MainBox1 = Tabs.Main:AddRightGroupbox("teleports")
local function getKeys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return keys
end

local TeleportLocations = {
    ["lake"] = CFrame.new(133, 57, 445),
    ["gate of robloxia"] = CFrame.new(807, 56, -119),
    ["shelter"] = CFrame.new(57, 56, -118),
    ["bed"] = CFrame.new(23, 58, -124),
    ["wheel"] = CFrame.new(1144, 57, 210),
    ["engine"] = CFrame.new(603, 60, 916),
    ["hammer"] = CFrame.new(650, 56, 902),
    ["paint"] = CFrame.new(1017, 71, 865),
    ["shovel"] = CFrame.new(135, 56, 908),
    ["bigger farm"] = CFrame.new(147, 56, 914)
}
local SelectedLocation = ""

MainBox1:AddDropdown("TeleportLocationDropdown", {
    Values = getKeys(TeleportLocations), 
    Default = 1,
    Multi = false,
    Text = "locations",
    Tooltip = "seats is in bigger farm",
    Callback = function(value)
        SelectedLocation = value
    end
})

MainBox1:AddButton("teleport", function()
    local HRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then
        return
    end

    local TargetCFrame = TeleportLocations[SelectedLocation]
    if TargetCFrame then
        HRP.CFrame = TargetCFrame
        Library:Notify("teleported to " .. SelectedLocation, 3)
    else
        Library:Notify("location not found", 3)
    end
end)

local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end
FLYING = false
QEfly = true
iyflyspeed = 50
vehicleflyspeed = 50
local flyKeyDown, flyKeyUp
function sFLY(vfly)
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	if T then
		T.CanCollide = false
	end

	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0
	local UIS = game:GetService("UserInputService")
	local function GetSpeed()
        return vfly and vehicleflyspeed or iyflyspeed
    end
if not UIS:GetFocusedTextBox() then
    CONTROL.F = UIS:IsKeyDown(Enum.KeyCode.W) and GetSpeed() or 0
    CONTROL.B = UIS:IsKeyDown(Enum.KeyCode.S) and -GetSpeed() or 0
    CONTROL.L = UIS:IsKeyDown(Enum.KeyCode.A) and -GetSpeed() or 0
    CONTROL.R = UIS:IsKeyDown(Enum.KeyCode.D) and GetSpeed() or 0
    if QEfly then
        CONTROL.E = UIS:IsKeyDown(Enum.KeyCode.Space) and GetSpeed() * 2 or 0
        CONTROL.Q = UIS:IsKeyDown(Enum.KeyCode.C) and -GetSpeed() * 2 or 0
    end
else
    CONTROL.F = 0
    CONTROL.B = 0
    CONTROL.L = 0
    CONTROL.R = 0
    CONTROL.E = 0
    CONTROL.Q = 0
end

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			while FLYING do
				for _, part in pairs(char:GetDescendants()) do
					if part:IsA("BasePart") and not part.Anchored then
						part.CanCollide = false
					end
				end
				task.wait(0.1)
			end
		end)

		task.spawn(function()
            repeat
                task.wait()
                local camera = workspace.CurrentCamera
                if not vfly and humanoid then
                    humanoid.PlatformStand = true
                    T.CanCollide = false
                end
                if not UIS:GetFocusedTextBox() then
                    CONTROL.F = UIS:IsKeyDown(Enum.KeyCode.W) and GetSpeed() or 0
	                CONTROL.B = UIS:IsKeyDown(Enum.KeyCode.S) and -GetSpeed() or 0
	                CONTROL.L = UIS:IsKeyDown(Enum.KeyCode.A) and -GetSpeed() or 0
	                CONTROL.R = UIS:IsKeyDown(Enum.KeyCode.D) and GetSpeed() or 0
                    if QEfly then
                        CONTROL.E = UIS:IsKeyDown(Enum.KeyCode.Space) and GetSpeed() * 2 or 0
		                CONTROL.Q = UIS:IsKeyDown(Enum.KeyCode.C) and -GetSpeed() * 2 or 0
                    end
                else
                    CONTROL.F = 0
                    CONTROL.B = 0
	                CONTROL.L = 0
	                CONTROL.R = 0
	                CONTROL.E = 0
	                CONTROL.Q = 0
                end
                
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = GetSpeed() * 0.01
                elseif SPEED ~= 0 then
                    SPEED = 0
                end
                
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) +
                    ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R,
                    (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif SPEED ~= 0 then
                    BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) +
                    ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R,
                    (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = camera.CFrame
            until not FLYING

			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 1
			BG:Destroy()
			BV:Destroy()

			if humanoid then
				humanoid.PlatformStand = false
			end

			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored then
					part.CanCollide = true
				end
			end
		end)
	end

flyKeyDown = UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.W then
        CONTROL.F = GetSpeed()
    elseif input.KeyCode == Enum.KeyCode.S then
        CONTROL.B = -GetSpeed()
    elseif input.KeyCode == Enum.KeyCode.A then
        CONTROL.L = -GetSpeed()
    elseif input.KeyCode == Enum.KeyCode.D then
        CONTROL.R = GetSpeed()
    elseif input.KeyCode == Enum.KeyCode.Space and QEfly then
        CONTROL.E = GetSpeed() * 2
    elseif input.KeyCode == Enum.KeyCode.C and QEfly then
        CONTROL.Q = -GetSpeed() * 2
    end
end)

flyKeyUp = UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.W then
        CONTROL.F = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        CONTROL.B = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        CONTROL.L = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        CONTROL.R = 0
    elseif input.KeyCode == Enum.KeyCode.Space then
        CONTROL.E = 0
    elseif input.KeyCode == Enum.KeyCode.C then
        CONTROL.Q = 0
		end
	end)
	FLY()
end
function NOFLY()
	FLYING = false

	if flyKeyDown then
		flyKeyDown:Disconnect()
	end
	if flyKeyUp then
		flyKeyUp:Disconnect()
	end

	local char = Players.LocalPlayer.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored then
			part.CanCollide = true
		end
	end

	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end
local FlightToggle = MainBox1:AddToggle("flighttoggle", {
    Text = "Fly",
    Default = false,
    Callback = function(state)
        if state then
            sFLY(false)
        else
            NOFLY()
        end
    end
})

FlightToggle:AddKeyPicker("flighttoggle_key", {
    Default = "X",
    NoUI = false,
    Text = "fly",
    Mode = "Toggle",
    SyncToggleState = true,
})

MainBox1:AddSlider("flightspeed", {
    Text = "speed",
    Default = 50,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
        iyflyspeed = value
        vehicleflyspeed = value
    end
})

local NoclipEnabled = false
local NoclipConnection
local function ToggleNoclip(enabled)
    NoclipEnabled = enabled

    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    if enabled then
        local player = game.Players.LocalPlayer
        NoclipConnection = cloneref(game:GetService("RunService")).RenderStepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end
local NoclipToggle = MainBox1:AddToggle("NoclipToggle", {
    Text = "noclip",
    Default = false,
    Callback = ToggleNoclip,
});
NoclipToggle:AddKeyPicker("NoclipToggleKey", {
    Default = "Z",
    NoUI = false,
    Text = "noclip",
    Mode = "Toggle",
    SyncToggleState = true,
});
local WalkSpeedEnabled = false
local WalkSpeedMultiplier = 1
local WalkSpeedConnection
local function ToggleWalkSpeed(enabled)
    WalkSpeedEnabled = enabled

    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end

    if enabled then
        local player = game.Players.LocalPlayer
        WalkSpeedConnection = cloneref(game:GetService("RunService")).Heartbeat:Connect(function(deltaTime)
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local HRP = character.HumanoidRootPart
                local humanoid = character.Humanoid
                local MoveDirection = humanoid.MoveDirection
                if MoveDirection.Magnitude > 0 then
                    local moveDelta = MoveDirection.Unit * humanoid.WalkSpeed * WalkSpeedMultiplier * deltaTime
                    HRP.CFrame = HRP.CFrame + moveDelta
                end
            end
        end)
    end
end
local WalkSpeedToggle = MainBox1:AddToggle("WalkSpeedToggle", {
    Text = "speed",
    Default = false,
    Callback = ToggleWalkSpeed,
})
WalkSpeedToggle:AddKeyPicker("WalkSpeedToggleKey", {
    Default = "C",
    NoUI = false,
    Text = "speed",
    Mode = "Toggle",
    SyncToggleState = true,
})
MainBox1:AddSlider("WalkSpeedMultiplier", {
    Text = "amount",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Compact = true,
    Callback = function(value)
        WalkSpeedMultiplier = value
    end,
})
Library.KeybindFrame.Visible = true;
local MenuGroup = Tabs['settings']:AddLeftGroupbox('ui')
MenuGroup:AddLabel('toggle ui'):AddKeyPicker("uitoggle", { Default = 'End', NoUI = true, Text = 'UI Bind' })
MenuGroup:AddButton('Unload', function() Library:Unload() end)
Library.ToggleKeybind = Options.uitoggle
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'uitoggle' })
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs['settings'])
ThemeManager:ApplyToTab(Tabs['settings'])
