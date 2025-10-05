local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))();
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))();
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))();
if not (game:IsLoaded()) then game.Loaded:Wait(); end;
local Window = Library:CreateWindow({
    Title = "                          scripthookv       weird strict dad(book 2)",
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
    cloneref(game:GetService("TeleportService")):Teleport(game.PlaceId, game.Players.LocalPlayer);
end);

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

local RunService = game:GetService("RunService")
local CFloop
local CFspeed = 50
local function isNumber(value)
    return typeof(value) == "number"
end
local function ToggleFlight(state)
    local player = game.Players.LocalPlayer
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local head = player.Character:FindFirstChild("Head")
    if not humanoid or not head then return end

    if state then
        humanoid.PlatformStand = true
        head.Anchored = true

        if CFloop then CFloop:Disconnect() end
        CFloop = RunService.Heartbeat:Connect(function(deltaTime)
            local MoveDirection = humanoid.MoveDirection * (CFspeed * deltaTime)
            local headCFrame = head.CFrame
            local camera = workspace.CurrentCamera
            local cameraCFrame = camera.CFrame
            local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
            cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
            local cameraPosition = cameraCFrame.Position
            local HeadPosition = headCFrame.Position
            local ObjectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(HeadPosition.X, cameraPosition.Y, HeadPosition.Z)):VectorToObjectSpace(MoveDirection)
            head.CFrame = CFrame.new(HeadPosition) * (cameraCFrame - cameraPosition) * CFrame.new(ObjectSpaceVelocity)
        end)
    else
        if CFloop then
            CFloop:Disconnect()
            CFloop = nil
        end

        humanoid.PlatformStand = false
        head.Anchored = false
    end
end
local FlightToggle = MainBox1:AddToggle("flighttoggle", {
    Text = "fly",
    Default = false,
    Callback = function(state)
        ToggleFlight(state)
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
    Text = "fly speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = true,
    Callback = function(value)
        CFspeed = value
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
        NoclipConnection = cloneref(game:GetService("RunService")).Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
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
            for _, part in pairs(character:GetChildren()) do
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
        WalkSpeedConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
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
