--[[
    UA CMD + BlehControlDeck (original) + gui2 (simplified: only Aimbot, Silent Aim, Max FOV)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- ============================================
-- TERMINAL – small, top‑center
-- ============================================

local termGui = Instance.new("ScreenGui")
termGui.Name = "UATerminal"
termGui.Parent = playerGui
termGui.ResetOnSpawn = false
termGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
termGui.Enabled = true

local mainFrame = Instance.new("Frame")
mainFrame.Parent = termGui
mainFrame.Size = UDim2.new(0, 400, 0, 280)
mainFrame.Position = UDim2.new(0.5, -200, 0, 5)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 180, 100)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BackgroundTransparency = 0.4
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "UA CMD - made by blehskid"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.Code
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 20, 1, -4)
closeBtn.Position = UDim2.new(1, -24, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.Code
closeBtn.BorderSizePixel = 0
local btnCorner = Instance.new("UICorner", closeBtn)
btnCorner.CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function()
    termGui.Enabled = false
end)

-- Scrollable output
local outputFrame = Instance.new("ScrollingFrame", mainFrame)
outputFrame.Position = UDim2.new(0, 8, 0, 28)
outputFrame.Size = UDim2.new(1, -16, 1, -56)
outputFrame.BackgroundTransparency = 1
outputFrame.ScrollBarThickness = 4
outputFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 100)
outputFrame.BorderSizePixel = 0
outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
outputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local outputLayout = Instance.new("UIListLayout", outputFrame)
outputLayout.SortOrder = Enum.SortOrder.LayoutOrder
outputLayout.Padding = UDim.new(0, 2)

-- Input line
local inputFrame = Instance.new("Frame", mainFrame)
inputFrame.Position = UDim2.new(0, 8, 1, -28)
inputFrame.Size = UDim2.new(1, -16, 0, 22)
inputFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
inputFrame.BackgroundTransparency = 0.4
inputFrame.BorderSizePixel = 0
local inputCorner = Instance.new("UICorner", inputFrame)
inputCorner.CornerRadius = UDim.new(0, 4)

local promptLabel = Instance.new("TextLabel", inputFrame)
promptLabel.Size = UDim2.new(0, 70, 1, 0)
promptLabel.BackgroundTransparency = 1
promptLabel.Text = "C:\\> "
promptLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
promptLabel.TextSize = 12
promptLabel.Font = Enum.Font.Code
promptLabel.TextXAlignment = Enum.TextXAlignment.Left

local inputBox = Instance.new("TextBox", inputFrame)
inputBox.Position = UDim2.new(0, 70, 0, 2)
inputBox.Size = UDim2.new(1, -75, 1, -4)
inputBox.BackgroundTransparency = 1
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(200, 255, 200)
inputBox.TextSize = 12
inputBox.Font = Enum.Font.Code
inputBox.PlaceholderText = "Type a command..."
inputBox.PlaceholderColor3 = Color3.fromRGB(100, 150, 100)
inputBox.ClearTextOnFocus = false

-- Draggable
local function makeDraggable(frame)
    local drag, start, pos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            start = input.Position
            pos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - start
            mainFrame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(titleBar)

-- Terminal output
local outputLines = {}
local function addLine(text, color)
    color = color or Color3.fromRGB(200, 255, 200)
    local label = Instance.new("TextLabel", outputFrame)
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 12
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.LayoutOrder = #outputLines + 1
    table.insert(outputLines, label)
    outputFrame.CanvasPosition = Vector2.new(0, outputFrame.CanvasSize.Y.Offset)
end

local function clearTerminal()
    for _, v in ipairs(outputLines) do v:Destroy() end
    outputLines = {}
end

-- ============================================
-- HOTKEY: ; toggles the terminal
-- ============================================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Semicolon then
        termGui.Enabled = not termGui.Enabled
        if termGui.Enabled then
            inputBox:CaptureFocus()
        end
    end
end)

-- ============================================
-- COMMANDS (fly, noclip, goto, speed, esp, tp, respawn, + new ones)
-- ============================================

local flyActive = false
local flySpeed = 50
local flyConn = nil
local flyBV = nil
local flyBG = nil

local function startFly()
    if flyActive then return end
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then
        addLine("Fly: Character not ready", Color3.fromRGB(255,100,100))
        return
    end
    flyActive = true
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyActive or not root.Parent then
            stopFly()
            return
        end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
        if dir.Magnitude > 0 then
            flyBV.Velocity = dir.Unit * flySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = cam.CFrame
    end)
    addLine("Fly enabled", Color3.fromRGB(0,255,150))
end

local function stopFly()
    flyActive = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    addLine("Fly disabled", Color3.fromRGB(200,200,200))
end

local noclipActive = false
local noclipConn = nil

local function startNoclip()
    if noclipActive then return end
    noclipActive = true
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipActive then return end
        local char = localPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    addLine("Noclip enabled", Color3.fromRGB(0,255,150))
end

local function stopNoclip()
    noclipActive = false
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local char = localPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    addLine("Noclip disabled", Color3.fromRGB(200,200,200))
end

local function getRoot(char)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid").RootPart
    end
    return nil
end

local function breakVelocity()
    local V3 = Vector3.new(0,0,0)
    local char = localPlayer.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity, v.RotVelocity = V3, V3
            end
        end
    end
end

local function gotoPlayer(namePattern)
    namePattern = namePattern:lower()
    local target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local pName = player.Name:lower()
            if pName:sub(1, #namePattern) == namePattern then
                target = player
                break
            end
        end
    end
    if not target then
        addLine("No player found matching: " .. namePattern, Color3.fromRGB(255,100,100))
        return
    end
    if not target.Character or not getRoot(target.Character) then
        addLine("Target character not loaded", Color3.fromRGB(255,100,100))
        return
    end
    local root = getRoot(localPlayer.Character)
    local targetRoot = getRoot(target.Character)
    if root and targetRoot then
        root.CFrame = targetRoot.CFrame + Vector3.new(0,0,2)
        breakVelocity()
        addLine("Teleported to " .. target.Name, Color3.fromRGB(0,255,150))
    else
        addLine("Failed to teleport", Color3.fromRGB(255,100,100))
    end
end

local function setSpeed(speed)
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        local spd = tonumber(speed) or 16
        hum.WalkSpeed = spd
        addLine("WalkSpeed set to " .. spd, Color3.fromRGB(0,255,150))
    else
        addLine("Character not ready", Color3.fromRGB(255,100,100))
    end
end

local espEnabled = false
local espHighlights = {}

local function addESPHighlight(player)
    if player == localPlayer or not player.Character then return end
    if localPlayer.Team and player.Team and player.Team == localPlayer.Team then return end
    if espHighlights[player] then espHighlights[player]:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(0, 255, 150)
    highlight.FillTransparency = 0.5
    highlight.Parent = player.Character
    espHighlights[player] = highlight
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            addESPHighlight(player)
        end
        addLine("ESP enabled", Color3.fromRGB(0,255,150))
    else
        for _, obj in pairs(espHighlights) do
            obj:Destroy()
        end
        espHighlights = {}
        addLine("ESP disabled", Color3.fromRGB(200,200,200))
    end
end

local function teleportToPos(x, y, z)
    local root = getRoot(localPlayer.Character)
    if root then
        local nx, ny, nz = tonumber(x), tonumber(y), tonumber(z)
        if nx and ny and nz then
            root.CFrame = CFrame.new(nx, ny, nz)
            breakVelocity()
            addLine(string.format("Teleported to %.1f, %.1f, %.1f", nx, ny, nz), Color3.fromRGB(0,255,150))
        else
            addLine("Invalid coordinates", Color3.fromRGB(255,100,100))
        end
    else
        addLine("Character not ready", Color3.fromRGB(255,100,100))
    end
end

local function respawn()
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
        addLine("Respawning...", Color3.fromRGB(200,200,100))
    else
        addLine("Character not ready", Color3.fromRGB(255,100,100))
    end
end

-- ============================================
-- NEW COMMANDS (stolen from Infinite Yield)
-- ============================================

-- anti‑fling
local antifling = nil

local function toggleAntifling()
    if antifling then
        antifling:Disconnect()
        antifling = nil
        addLine("Anti‑fling disabled", Color3.fromRGB(200,200,200))
        return
    end
    antifling = RunService.Stepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
    addLine("Anti‑fling enabled", Color3.fromRGB(0,255,150))
end

-- rejoin
local function rejoinCommand(args)
    local data = nil
    local reposition = args[2] and parseBoolean(args[2]) or false
    if reposition then
        if queue_on_teleport then
            if localPlayer.Character then
                data = localPlayer.Character:GetPivot()
                queue_on_teleport([[
                    local ok, data = pcall(function() return game:GetService("TeleportService"):GetLocalPlayerTeleportData() end)
                    if ok and typeof(data) == "CFrame" then
                        local Players = game:GetService("Players")
                        local ME = Players.LocalPlayer
                        while not ME do
                            Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
                            ME = Players.LocalPlayer
                        end
                        local Character = ME.Character or ME.CharacterAdded:Wait()
                        Character:WaitForChild("HumanoidRootPart")
                        local t = tick()
                        while (tick() - t) <= 0.3 do
                            Character:PivotTo(data)
                            task.wait()
                        end
                    end
                ]])
            end
        else
            addLine("Rejoin reposition requires queue_on_teleport", Color3.fromRGB(255,100,100))
        end
    end
    if #Players:GetPlayers() <= 1 then
        localPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(game.PlaceId, localPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer, nil, data)
    end
end

-- JERK (tool‑based, from Infinite Yield, with proper cleanup)
local jerkTool = nil
local jerkThread = nil
local jerkTrack = nil
local jerkRunning = false

local function startJerk()
    if jerkRunning then
        addLine("Jerk is already running", Color3.fromRGB(200,200,200))
        return
    end
    local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    local backpack = localPlayer:FindFirstChildWhichIsA("Backpack")
    if not humanoid or not backpack then
        addLine("Jerk: Character or backpack not ready", Color3.fromRGB(255,100,100))
        return
    end
    -- Create the tool
    jerkTool = Instance.new("Tool")
    jerkTool.Name = "Jerk Off"
    jerkTool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
    jerkTool.RequiresHandle = false
    jerkTool.Parent = backpack

    local jorkin = false
    jerkTrack = nil

    local function stopTomfoolery()
        jorkin = false
        if jerkTrack then
            jerkTrack:Stop()
            jerkTrack = nil
        end
    end

    jerkTool.Equipped:Connect(function() jorkin = true end)
    jerkTool.Unequipped:Connect(stopTomfoolery)
    humanoid.Died:Connect(function()
        stopTomfoolery()
        jerkRunning = false
        if jerkThread then
            task.cancel(jerkThread)
            jerkThread = nil
        end
        if jerkTool then
            jerkTool:Destroy()
            jerkTool = nil
        end
    end)

    jerkRunning = true
    jerkThread = task.spawn(function()
        while jerkRunning do
            if jorkin then
                local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
                if not jerkTrack then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                    jerkTrack = humanoid:LoadAnimation(anim)
                end
                if jerkTrack then
                    jerkTrack:Play()
                    jerkTrack:AdjustSpeed(isR15 and 0.7 or 0.65)
                    jerkTrack.TimePosition = 0.6
                    task.wait(0.1)
                    while jerkTrack and jerkTrack.TimePosition < (not isR15 and 0.65 or 0.7) do
                        task.wait(0.1)
                    end
                    if jerkTrack then
                        jerkTrack:Stop()
                        jerkTrack = nil
                    end
                end
            end
            task.wait()
        end
        -- cleanup when loop ends
        if jerkTool then
            jerkTool:Destroy()
            jerkTool = nil
        end
        if jerkTrack then
            jerkTrack:Stop()
            jerkTrack = nil
        end
        jerkRunning = false
    end)
    addLine("Jerk started – equip the tool in your backpack", Color3.fromRGB(0,255,150))
end

local function stopJerk()
    if not jerkRunning then
        addLine("Jerk is not running", Color3.fromRGB(200,200,200))
        return
    end
    jerkRunning = false
    if jerkThread then
        task.cancel(jerkThread)
        jerkThread = nil
    end
    if jerkTool then
        jerkTool:Destroy()
        jerkTool = nil
    end
    if jerkTrack then
        jerkTrack:Stop()
        jerkTrack = nil
    end
    addLine("Jerk stopped", Color3.fromRGB(200,200,200))
end

local function parseBoolean(raw)
    raw = tostring(raw):lower()
    return raw == "true" or raw == "t" or raw == "1" or raw == "yes" or raw == "y" or raw == "on"
end

-- ============================================
-- AIMBOT CORE (shared between both GUIs)
-- ============================================
local aimbotEnabled = false
local maxFov = 59
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "GUI2FOVOverlay"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 10000
fovGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
fovGui.Parent = playerGui
local fovCircle = Instance.new("Frame")
fovCircle.Name = "SilentAimFOV"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.ZIndex = 10000
fovCircle.Parent = fovGui
local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(255, 106, 133)
fovStroke.Thickness = 1
local silentBox = Instance.new("Frame")
silentBox.Name = "SilentAimTargetBox"
silentBox.BackgroundTransparency = 1
silentBox.BorderSizePixel = 0
silentBox.Visible = false
silentBox.ZIndex = 10002
silentBox.Parent = fovGui
local silentBoxStroke = Instance.new("UIStroke", silentBox)
silentBoxStroke.Color = Color3.fromRGB(255, 106, 133)
silentBoxStroke.Thickness = 2
local playerBox = Instance.new("SelectionBox")
playerBox.Name = "SilentAimPlayerBox"
playerBox.LineThickness = 0.04
playerBox.Color3 = Color3.fromRGB(255, 106, 133)
playerBox.SurfaceTransparency = 1
playerBox.Visible = false
playerBox.Parent = fovGui

local function hideAimOverlay()
    silentBox.Visible = false
    playerBox.Visible = false
    playerBox.Adornee = nil
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if espEnabled then addESPHighlight(player) end
    end)
end)

local function getNearestPlayer(fovDeg)
    local camera = workspace.CurrentCamera
    local character = localPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local mouse = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local radius = math.tan(math.rad(fovDeg or 59) / 2) / math.tan(math.rad(camera.FieldOfView) / 2) * camera.ViewportSize.Y / 2
    local bestTarget, bestAngle, bestDist = nil, radius, math.huge
    local function isTeammate(player)
        if localPlayer.Team and player.Team then
            return player.Team == localPlayer.Team
        end
        if localPlayer.TeamColor and player.TeamColor then
            return player.TeamColor == localPlayer.TeamColor
        end
        return false
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and not isTeammate(player) then
            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local tPos = tRoot.Position
                -- Aim for head
                local head = player.Character:FindFirstChild("Head")
                if head then tPos = head.Position end
                local projected, visible = camera:WorldToViewportPoint(tPos)
                if not visible or projected.Z <= 0 then continue end
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {localPlayer.Character}
                local hit = workspace:Raycast(camera.CFrame.Position, tPos - camera.CFrame.Position, rayParams)
                if hit and not hit.Instance:IsDescendantOf(player.Character) then continue end
                local mouseDelta = Vector2.new(projected.X, projected.Y) - mouse
                local angle = mouseDelta.Magnitude
                if angle <= bestAngle then
                    local dist = (camera.CFrame.Position - tPos).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestAngle = angle
                        bestTarget = player
                    end
                end
            end
        end
    end
    return bestTarget
end

local function performAimbot()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local fovRadius = math.tan(math.rad(maxFov) / 2) / math.tan(math.rad(camera.FieldOfView) / 2) * viewport.Y / 2
    fovCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
    -- fovGui.IgnoreGuiInset is true, so use the raw screen mouse position.
    fovCircle.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
    -- The same Maximum FOV circle gates both Aimbot and Silent Aim.
    fovCircle.Visible = aimbotEnabled
    if not aimbotEnabled then
        fovCircle.Visible = false
        hideAimOverlay()
        return
    end
    local target = getNearestPlayer(maxFov)
    if not target or not target.Character then
        hideAimOverlay()
        return
    end
    local tPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    if not tPart then
        hideAimOverlay()
        return
    end
    local screenPoint, onScreen = camera:WorldToViewportPoint(tPart.Position)
    if aimbotEnabled and onScreen then
        if screenPoint.Z <= 0 then
            hideAimOverlay()
            return
        end
        -- tracer removed; the FOV circle and avatar box identify the target.
        -- Keep a small, stable head box instead of projecting the whole model
        -- (which can explode when one body corner is behind the camera).
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        local rootPoint, rootOnScreen = root and camera:WorldToViewportPoint(root.Position)
        if rootOnScreen and rootPoint.Z > 0 then
            local distance = (root.Position - camera.CFrame.Position).Magnitude
            local boxW = math.clamp(1500 / math.max(distance, 1), 22, 52)
            local boxH = boxW * 1.35
            silentBox.Position = UDim2.fromOffset(screenPoint.X - boxW / 2, screenPoint.Y - boxH * 0.35)
            silentBox.Size = UDim2.fromOffset(boxW, boxH)
            silentBox.Visible = true
            playerBox.Adornee = target.Character
            playerBox.Visible = true
        else
            silentBox.Visible = false
            playerBox.Visible = false
        end
    else
        silentBox.Visible = false
        playerBox.Visible = false
        playerBox.Adornee = nil
    end
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, tPart.Position)
end
local aimbotConnection = RunService.RenderStepped:Connect(performAimbot)

-- ============================================
-- ORIGINAL BLEHCONTROLDECK GUI (unchanged)
-- ============================================

local blehGui = nil
local blehVisible = false

local function createBlehGUI()
    if blehGui then
        blehGui.Enabled = true
        blehVisible = true
        return blehGui
    end

    local COLORS = {
        Background = Color3.fromRGB(10, 18, 23),
        Panel = Color3.fromRGB(17, 29, 35),
        PanelLight = Color3.fromRGB(23, 40, 46),
        Hover = Color3.fromRGB(31, 53, 58),
        Border = Color3.fromRGB(48, 74, 78),
        Text = Color3.fromRGB(231, 245, 240),
        Muted = Color3.fromRGB(137, 165, 164),
        Mint = Color3.fromRGB(92, 225, 184),
        MintDark = Color3.fromRGB(34, 109, 96),
        Coral = Color3.fromRGB(247, 111, 119),
        Pink = Color3.fromRGB(245, 128, 177),
        Purple = Color3.fromRGB(160, 120, 200),
    }

    local espEnabled = false
    local flyEnabled = false
    local flySpeed = 50
    local selectedPlayer = nil
    local espObjects = {}
    local flyVelocity = nil
    local flyGyro = nil
    local flyConnection = nil
    local toastToken = 0
    local currentTab = "Main"
    local autoRefreshPlayers = true

    -- Fling variables
    local flingActive = false
    local flingLoopThread = nil
    local flingPower = 100
    local flingReturnCFrame = nil
    local fallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight

    -- Store player buttons
    local playerButtons = {}
    local status
    local flingAutoRefreshButton
    local createESP
    local removeESP

    local function restoreFlingPosition(clearSavedPosition)
        local rootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if flingReturnCFrame and rootPart then
            rootPart.CFrame = flingReturnCFrame
            rootPart.Velocity = Vector3.zero
            rootPart.RotVelocity = Vector3.zero
        end
        if clearSavedPosition then
            flingReturnCFrame = nil
        end
    end

    local function make(className, properties, parent)
        local object = Instance.new(className)
        for property, value in pairs(properties) do
            object[property] = value
        end
        object.Parent = parent
        return object
    end

    local function round(object, radius)
        make("UICorner", { CornerRadius = UDim.new(0, radius) }, object)
    end

    local function outline(object, color)
        return make("UIStroke", { Color = color, Thickness = 1 }, object)
    end

    local gui = make("ScreenGui", {
        Name = "BlehControlDeck",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, playerGui)

    local main = make("Frame", {
        Size = UDim2.fromOffset(560, 460),
        Position = UDim2.new(0.5, -280, 0.5, -230),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    round(main, 14)
    outline(main, COLORS.Border)

    local topbar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, main)
    local title = make("TextLabel", {
        Size = UDim2.new(1, -120, 0, 24),
        Position = UDim2.fromOffset(22, 10),
        BackgroundTransparency = 1,
        Text = "BLEH",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = COLORS.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, topbar)
    make("TextLabel", {
        Size = UDim2.new(1, -120, 0, 15),
        Position = UDim2.fromOffset(23, 36),
        BackgroundTransparency = 1,
        Text = "PLAYER TOOLS",
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, topbar)
    local closeButton = make("TextButton", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.new(1, -48, 0, 14),
        BackgroundColor3 = COLORS.PanelLight,
        Text = "×",
        Font = Enum.Font.GothamMedium,
        TextSize = 22,
        TextColor3 = COLORS.Muted,
        AutoButtonColor = false,
        ZIndex = 3,
    }, topbar)
    round(closeButton, 8)
    closeButton.MouseButton1Click:Connect(function()
        gui.Enabled = false
        blehVisible = false
    end)

    local content = make("Frame", {
        Size = UDim2.new(1, -40, 1, -82),
        Position = UDim2.fromOffset(20, 72),
        BackgroundTransparency = 1,
    }, main)

    -- Tab System
    local tabs = {}

    local function createTab(name, icon, callback)
        local tabButton = make("TextButton", {
            Size = UDim2.fromOffset(92, 30),
            Position = UDim2.fromOffset(#tabs * 100, 0),
            BackgroundColor3 = #tabs == 0 and COLORS.Pink or COLORS.PanelLight,
            Text = "  " .. icon .. " " .. name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = #tabs == 0 and Color3.fromRGB(255, 255, 255) or COLORS.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        }, content)
        round(tabButton, 15)
        if #tabs > 0 then outline(tabButton, COLORS.Border) end

        local tabContent = make("Frame", {
            Size = UDim2.new(1, 0, 1, -60),
            Position = UDim2.fromOffset(0, 50),
            BackgroundTransparency = 1,
            Visible = #tabs == 0,
        }, content)

        tabButton.MouseEnter:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.12), {
                BackgroundColor3 = #tabs == 0 and Color3.fromRGB(255, 150, 194) or COLORS.Hover
            }):Play()
        end)
        tabButton.MouseLeave:Connect(function()
            TweenService:Create(tabButton, TweenInfo.new(0.12), {
                BackgroundColor3 = currentTab == name and COLORS.Pink or COLORS.PanelLight
            }):Play()
        end)
        tabButton.MouseButton1Click:Connect(function()
            currentTab = name
            for _, tab in pairs(tabs) do
                tab.Button.BackgroundColor3 = COLORS.PanelLight
                tab.Button.TextColor3 = COLORS.Muted
                tab.Content.Visible = false
                if tab.Button:FindFirstChild("UIStroke") then
                    tab.Button.UIStroke:Destroy()
                end
                outline(tab.Button, COLORS.Border)
            end
            tabButton.BackgroundColor3 = COLORS.Pink
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            if tabButton:FindFirstChild("UIStroke") then
                tabButton.UIStroke:Destroy()
            end
            tabContent.Visible = true
            if callback then callback() end
        end)

        table.insert(tabs, {Button = tabButton, Content = tabContent})
        return tabContent
    end

    -- Create Tabs
    local mainTabContent = createTab("Main", "✦", function()
        status.Text = "MAIN MENU  /  Select a player below"
        status.TextColor3 = COLORS.Mint
    end)

    local teleportTabContent = createTab("Teleport", "📍", function()
        status.Text = "TELEPORT MENU  /  Choose a target below"
        status.TextColor3 = COLORS.Mint
    end)

    local flingTabContent = createTab("Fling", "⚡", function()
        status.Text = "FLING MENU  /  Choose a target below"
        status.TextColor3 = COLORS.Mint
    end)

    local flyTabContent = createTab("Fly", "✈️", function()
        status.Text = "FLY MENU  /  Use the flight controls below"
        status.TextColor3 = COLORS.Mint
    end)

    -- ESP Tab (replaces the old Rage tab)
    local espTabContent = createTab("ESP", "◉", function()
        status.Text = "ESP MENU  /  Manage player visibility"
        status.TextColor3 = COLORS.Mint
    end)

    -- ============================================
    -- STATUS BAR
    -- ============================================
    status = make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.fromOffset(0, 35),
        BackgroundTransparency = 1,
        Text = "READY  /  Choose a player to begin",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Mint,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, mainTabContent)

    local function notify(message, color)
        toastToken += 1
        local token = toastToken
        status.Text = message
        status.TextColor3 = color or COLORS.Mint
        task.delay(3, function()
            if toastToken == token then
                status.Text = "READY  /  Choose a player to begin"
                status.TextColor3 = COLORS.Mint
            end
        end)
    end

    -- ============================================
    -- PLAYER SELECTOR (Shared across tabs)
    -- ============================================
    local function createPlayerSelector(parent, yOffset)
        local container = make("Frame", {
            Size = UDim2.new(1, 0, 0, 100),
            Position = UDim2.fromOffset(0, yOffset),
            BackgroundTransparency = 1,
        }, parent)

        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            Text = "TARGET PLAYER",
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = COLORS.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, container)

        local playerButton = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.fromOffset(0, 20),
            BackgroundColor3 = COLORS.PanelLight,
            Text = "  Select a player                                      ▾",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = COLORS.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        }, container)
        round(playerButton, 8)
        outline(playerButton, COLORS.Border)

        local playerList = make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.fromOffset(0, 64),
            BackgroundColor3 = COLORS.Panel,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = COLORS.Mint,
            CanvasSize = UDim2.new(),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 20,
        }, container)
        round(playerList, 8)
        outline(playerList, COLORS.Border)
        make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, playerList)
        make("UIListLayout", { Padding = UDim.new(0, 3) }, playerList)

        local dropdownOffset = 0
        local function setDropdownOpen(isOpen)
            local count = 0
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then count += 1 end
            end
            local listHeight = math.min(140, math.max(40, count * 33 + 10))
            playerList.Visible = isOpen
            playerList.Size = isOpen and UDim2.new(1, 0, 0, listHeight) or UDim2.new(1, 0, 0, 0)

            local newOffset = isOpen and listHeight + 10 or 0
            local movement = newOffset - dropdownOffset
            if movement ~= 0 then
                for _, sibling in ipairs(parent:GetChildren()) do
                    if sibling ~= container and sibling:IsA("GuiObject") and sibling.Position.Y.Offset >= yOffset + 70 then
                        sibling.Position = UDim2.new(sibling.Position.X.Scale, sibling.Position.X.Offset, sibling.Position.Y.Scale, sibling.Position.Y.Offset + movement)
                    end
                end
            end
            dropdownOffset = newOffset
        end

        local function refreshPlayers()
            for _, child in ipairs(playerList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            local count = 0
            local playersList = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    table.insert(playersList, player)
                end
            end

            table.sort(playersList, function(a, b)
                return a.Name < b.Name
            end)

            for _, player in ipairs(playersList) do
                count += 1
                local entry = make("TextButton", {
                    Size = UDim2.new(1, -8, 0, 30),
                    BackgroundColor3 = COLORS.PanelLight,
                    Text = "  " .. player.DisplayName .. "  @" .. player.Name,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = COLORS.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = count,
                    ZIndex = 6,
                }, playerList)
                round(entry, 6)

                entry.MouseEnter:Connect(function()
                    TweenService:Create(entry, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.Hover }):Play()
                end)
                entry.MouseLeave:Connect(function()
                    TweenService:Create(entry, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.PanelLight }):Play()
                end)

                entry.MouseButton1Click:Connect(function()
                    selectedPlayer = player
                    local displayText = "  " .. player.DisplayName .. "  @" .. player.Name
                    playerButton.Text = displayText
                    setDropdownOpen(false)

                    for _, btn in pairs(playerButtons) do
                        if btn and btn ~= playerButton then
                            btn.Text = displayText
                        end
                    end

                    status.Text = "TARGET LOCKED  /  " .. player.Name
                    status.TextColor3 = COLORS.Mint
                    notify("TARGET SET  /  " .. player.Name)
                end)
            end
            playerList.CanvasSize = UDim2.fromOffset(0, count * 33 + 8)
        end

        table.insert(playerButtons, playerButton)
        refreshPlayers()

        local function onPlayerChange()
            refreshPlayers()
            if selectedPlayer and not Players:FindFirstChild(selectedPlayer.Name) then
                selectedPlayer = nil
                playerButton.Text = "  Select a player                                      ▾"
                for _, btn in pairs(playerButtons) do
                    if btn and btn ~= playerButton then
                        btn.Text = "  Select a player                                      ▾"
                    end
                end
            end
        end

        Players.PlayerAdded:Connect(onPlayerChange)
        Players.PlayerRemoving:Connect(onPlayerChange)

        playerButton.MouseButton1Click:Connect(function()
            setDropdownOpen(not playerList.Visible)
        end)

        return { Button = playerButton, List = playerList, Refresh = refreshPlayers }
    end

    local mainSelector = createPlayerSelector(mainTabContent, 55)
    local teleportSelector = createPlayerSelector(teleportTabContent, 0)

    -- ============================================
    -- MAIN TAB BUTTONS
    -- ============================================
    local function createButton(parent, text, position, color, callback)
        local object = make("TextButton", {
            Size = UDim2.new(0.5, -6, 0, 38),
            Position = position,
            BackgroundColor3 = color,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = COLORS.Text,
            AutoButtonColor = false,
        }, parent)
        round(object, 8)
        object.MouseEnter:Connect(function()
            TweenService:Create(object, TweenInfo.new(0.12), { BackgroundColor3 = COLORS.Hover }):Play()
        end)
        object.MouseLeave:Connect(function()
            TweenService:Create(object, TweenInfo.new(0.12), { BackgroundColor3 = color }):Play()
        end)
        object.MouseButton1Click:Connect(callback)
        return object
    end

    -- ESP Button
    local espButton
    espButton = createButton(mainTabContent, "ESP  /  OFF", UDim2.fromOffset(0, 170), COLORS.PanelLight, function()
        espEnabled = not espEnabled
        if espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
            notify("ESP ENABLED  /  Tracking players")
            espButton.Text = "ESP  /  ON"
            espButton.BackgroundColor3 = COLORS.MintDark
        else
            for player in pairs(espObjects) do removeESP(player) end
            notify("ESP DISABLED  /  Tracking stopped", COLORS.Muted)
            espButton.Text = "ESP  /  OFF"
            espButton.BackgroundColor3 = COLORS.PanelLight
        end
    end)

    -- Teleport Button
    createButton(mainTabContent, "TELEPORT", UDim2.new(0.5, 6, 0, 170), COLORS.MintDark, function()
        if not selectedPlayer then
            notify("NO TARGET  /  Select a player first", COLORS.Coral)
            return
        end
        local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local ownRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and ownRoot then
            ownRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 2)
            notify("TELEPORTED  /  " .. selectedPlayer.Name)
        else
            notify("TELEPORT FAILED  /  Player not loaded", COLORS.Coral)
        end
    end)

    -- Clear Target
    createButton(mainTabContent, "CLEAR TARGET", UDim2.fromOffset(0, 215), COLORS.PanelLight, function()
        selectedPlayer = nil
        local defaultText = "  Select a player                                      ▾"
        for _, btn in pairs(playerButtons) do
            if btn then
                btn.Text = defaultText
            end
        end
        notify("TARGET CLEARED", COLORS.Muted)
    end)

    -- ============================================
    -- ESP TAB (replaces Rage)
    -- ============================================
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = "◉ ESP CONTROLS",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = COLORS.Mint,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, espTabContent)

    local espTabButton = createButton(espTabContent, "ESP  /  OFF", UDim2.fromOffset(0, 35), COLORS.PanelLight, function()
        espEnabled = not espEnabled
        if espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
            espTabButton.Text = "ESP  /  ON"
            espTabButton.BackgroundColor3 = COLORS.MintDark
            notify("ESP ENABLED  /  Tracking players")
        else
            for player in pairs(espObjects) do removeESP(player) end
            espTabButton.Text = "ESP  /  OFF"
            espTabButton.BackgroundColor3 = COLORS.PanelLight
            notify("ESP DISABLED  /  Tracking stopped", COLORS.Muted)
        end
    end)

    -- ============================================
    -- TELEPORT TAB
    -- ============================================
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.fromOffset(0, 55),
        BackgroundTransparency = 1,
        Text = "TELEPORT CONTROLS",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, teleportTabContent)

    createButton(teleportTabContent, "TELEPORT TO TARGET", UDim2.fromOffset(0, 80), COLORS.MintDark, function()
        if not selectedPlayer then
            notify("NO TARGET  /  Select a player first", COLORS.Coral)
            return
        end
        local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local ownRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and ownRoot then
            ownRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 2)
            notify("TELEPORTED  /  " .. selectedPlayer.Name)
        else
            notify("TELEPORT FAILED  /  Player not loaded", COLORS.Coral)
        end
    end)

    local autoRefreshButton = createButton(teleportTabContent, "AUTO REFRESH  /  ON", UDim2.new(0.5, 6, 0, 80), COLORS.MintDark, function()
        autoRefreshPlayers = not autoRefreshPlayers
        autoRefreshButton.Text = autoRefreshPlayers and "AUTO REFRESH  /  ON" or "AUTO REFRESH  /  OFF"
        autoRefreshButton.BackgroundColor3 = autoRefreshPlayers and COLORS.MintDark or COLORS.PanelLight
        if flingAutoRefreshButton then
            flingAutoRefreshButton.Text = autoRefreshButton.Text
            flingAutoRefreshButton.BackgroundColor3 = autoRefreshButton.BackgroundColor3
        end
        notify(autoRefreshPlayers and "AUTO REFRESH ENABLED" or "AUTO REFRESH DISABLED", autoRefreshPlayers and COLORS.Mint or COLORS.Muted)
    end)

    createButton(teleportTabContent, "CLEAR TARGET", UDim2.fromOffset(0, 125), COLORS.PanelLight, function()
        selectedPlayer = nil
        local defaultText = "  Select a player                                      ▾"
        for _, btn in pairs(playerButtons) do
            if btn then
                btn.Text = defaultText
            end
        end
        notify("TARGET CLEARED", COLORS.Muted)
    end)

    -- ============================================
    -- FLING TAB (now with its own player selector)
    -- ============================================
    for _, child in ipairs(flingTabContent:GetChildren()) do
        child:Destroy()
    end

    -- Re‑create the player selector for the Fling tab
    local flingSelector = createPlayerSelector(flingTabContent, 30)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 130), -- shifted down to make room for selector
        BackgroundTransparency = 1,
        Text = "💥 FLING CONTROLS",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = COLORS.Coral,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, flingTabContent)

    make("TextLabel", {
        Size = UDim2.new(0.5, -10, 0, 18),
        Position = UDim2.fromOffset(0, 155),
        BackgroundTransparency = 1,
        Text = "FLING POWER",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, flingTabContent)

    local flingPowerValue = make("TextLabel", {
        Size = UDim2.fromOffset(60, 18),
        Position = UDim2.new(1, -10, 0, 155),
        BackgroundTransparency = 1,
        Text = "100",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Coral,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, flingTabContent)

    local flingPowerBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.fromOffset(0, 180),
        BackgroundColor3 = COLORS.PanelLight,
        BorderSizePixel = 0,
    }, flingTabContent)
    round(flingPowerBar, 4)

    local flingPowerFill = make("Frame", {
        Size = UDim2.new(0.18, 0, 1, 0),
        BackgroundColor3 = COLORS.Coral,
        BorderSizePixel = 0,
    }, flingPowerBar)
    round(flingPowerFill, 4)

    local flingPowerButton = make("TextButton", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.fromOffset(-10, -6),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, flingPowerBar)

    flingPowerButton.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - flingPowerBar.AbsolutePosition.X) / flingPowerBar.AbsoluteSize.X, 0, 1)
                flingPower = math.floor(10 + percent * 490)
                flingPowerValue.Text = tostring(flingPower)
                flingPowerFill.Size = UDim2.new(percent, 0, 1, 0)
            end
        end)
        UserInputService.InputEnded:Wait()
        connection:Disconnect()
    end)

    -- FLING ENGINE (same as before)
    local function flingTarget(targetPlayer)
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = humanoid and humanoid.RootPart
        if not character or not humanoid or not rootPart then
            return
        end

        local tChar = targetPlayer.Character
        if not tChar then
            return
        end

        local tHumanoid = tChar:FindFirstChildOfClass("Humanoid")
        if tHumanoid and tHumanoid.Sit then
            return
        end

        local tRoot = tHumanoid and tHumanoid.RootPart
        local tHead = tChar:FindFirstChild("Head")
        local accessory = tChar:FindFirstChildOfClass("Accessory")
        local handle = accessory and accessory:FindFirstChild("Handle")

        local cam = workspace.CurrentCamera
        local oldCamType = cam.CameraType
        local oldCamSubject = cam.CameraSubject
        local oldCamCFrame = cam.CFrame

        if tHead then
            cam.CameraSubject = tHead
        elseif handle then
            cam.CameraSubject = handle
        elseif tHumanoid then
            cam.CameraSubject = tHumanoid
        end

        workspace.FallenPartsDestroyHeight = 0/0

        local powerScale = flingPower / 100

        local function applyFling(basePart, posOffset, angle)
            rootPart.CFrame = CFrame.new(basePart.Position) * posOffset * angle
            character:SetPrimaryPartCFrame(CFrame.new(basePart.Position) * posOffset * angle)
            rootPart.Velocity = Vector3.new(9e7 * powerScale, 9e7 * 10 * powerScale, 9e7 * powerScale)
            rootPart.RotVelocity = Vector3.new(9e8 * powerScale, 9e8 * powerScale, 9e8 * powerScale)
        end

        local function runFlingSequence(basePart)
            local startTime = tick()
            local angle = 0
            local speed = tHumanoid and tHumanoid.WalkSpeed or 16

            repeat
                if rootPart and tHumanoid then
                    if basePart.Velocity.Magnitude < 50 then
                        angle = angle + 100
                        applyFling(basePart, CFrame.new(0, 1.5 * powerScale, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, 1.5 * powerScale, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, 1.5 * powerScale, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                    else
                        applyFling(basePart, CFrame.new(0, 1.5 * powerScale, speed * powerScale), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, -speed * powerScale), CFrame.Angles(0, 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, 1.5 * powerScale, speed * powerScale), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        applyFling(basePart, CFrame.new(0, -1.5 * powerScale, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until startTime + 2 < tick() or not flingActive
        end

        local bv = Instance.new("BodyVelocity")
        bv.Parent = rootPart
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if tRoot then
            runFlingSequence(tRoot)
        elseif tHead then
            runFlingSequence(tHead)
        elseif handle then
            runFlingSequence(handle)
        else
            bv:Destroy()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.FallenPartsDestroyHeight = fallenPartsDestroyHeight
            return
        end

        bv:Destroy()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

        cam.CameraType = oldCamType
        cam.CameraSubject = oldCamSubject
        cam.CFrame = oldCamCFrame
        workspace.FallenPartsDestroyHeight = fallenPartsDestroyHeight

        restoreFlingPosition(true)
    end

    local flingButton
    flingButton = createButton(flingTabContent, "FLING  /  OFF", UDim2.fromOffset(0, 200), COLORS.PanelLight, function()
        if flingActive then
            flingActive = false
            restoreFlingPosition()
            if flingLoopThread then
                flingLoopThread = nil
            end
            flingButton.Text = "FLING  /  OFF"
            flingButton.BackgroundColor3 = COLORS.PanelLight
            notify("FLING STOPPED", COLORS.Muted)
            return
        end

        if not selectedPlayer then
            notify("NO TARGET  /  Select a player first", COLORS.Coral)
            return
        end

        local targetChar = selectedPlayer.Character
        if not targetChar then
            notify("FLING FAILED  /  Player not loaded", COLORS.Coral)
            return
        end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            notify("FLING FAILED  /  Target not ready", COLORS.Coral)
            return
        end

        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            targetHumanoid.PlatformStand = true
        end

        local ownRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        flingReturnCFrame = ownRoot and ownRoot.CFrame or nil

        flingActive = true
        flingButton.Text = "FLING  /  ON"
        flingButton.BackgroundColor3 = COLORS.Coral
        notify("FLING STARTED  /  " .. selectedPlayer.Name, COLORS.Coral)

        local target = selectedPlayer

        flingLoopThread = task.spawn(function()
            while flingActive and target and target.Parent do
                flingTarget(target)
                task.wait(0.1)
            end
            restoreFlingPosition(true)
            if flingActive then
                flingActive = false
                flingButton.Text = "FLING  /  OFF"
                flingButton.BackgroundColor3 = COLORS.PanelLight
            end
        end)
    end)

    flingAutoRefreshButton = createButton(flingTabContent, "AUTO REFRESH  /  ON", UDim2.new(0.5, 6, 0, 200), COLORS.MintDark, function()
        autoRefreshPlayers = not autoRefreshPlayers
        local buttonText = autoRefreshPlayers and "AUTO REFRESH  /  ON" or "AUTO REFRESH  /  OFF"
        local buttonColor = autoRefreshPlayers and COLORS.MintDark or COLORS.PanelLight
        autoRefreshButton.Text = buttonText
        autoRefreshButton.BackgroundColor3 = buttonColor
        flingAutoRefreshButton.Text = buttonText
        flingAutoRefreshButton.BackgroundColor3 = buttonColor
        notify(autoRefreshPlayers and "AUTO REFRESH ENABLED" or "AUTO REFRESH DISABLED", autoRefreshPlayers and COLORS.Mint or COLORS.Muted)
    end)

    createButton(flingTabContent, "CLEAR TARGET", UDim2.fromOffset(0, 245), COLORS.PanelLight, function()
        selectedPlayer = nil
        local defaultText = "  Select a player                                      ▾"
        for _, btn in pairs(playerButtons) do
            if btn then btn.Text = defaultText end
        end
        if flingActive then
            flingActive = false
            restoreFlingPosition()
            if flingLoopThread then
                flingLoopThread = nil
            end
            flingButton.Text = "FLING  /  OFF"
            flingButton.BackgroundColor3 = COLORS.PanelLight
        end
        notify("TARGET CLEARED", COLORS.Muted)
    end)

    -- ============================================
    -- FLY TAB
    -- ============================================
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = "FLIGHT CONTROLS",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, flyTabContent)

    local flyButton
    flyButton = createButton(flyTabContent, "FLIGHT  /  OFF", UDim2.fromOffset(0, 25), COLORS.PanelLight, function()
        flyEnabled = not flyEnabled
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not flyEnabled then
            if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
            if flyGyro then flyGyro:Destroy(); flyGyro = nil end
            if humanoid then humanoid.PlatformStand = false; humanoid.AutoRotate = true end
            notify("FLIGHT DISABLED  /  Movement restored", COLORS.Muted)
            flyButton.Text = "FLIGHT  /  OFF"
            flyButton.BackgroundColor3 = COLORS.PanelLight
            return
        end
        if not root or not humanoid then
            notify("FLIGHT FAILED  /  Character not ready", COLORS.Coral)
            flyEnabled = false
            return
        end
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        flyVelocity = make("BodyVelocity", { MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero }, root)
        flyGyro = make("BodyGyro", { MaxTorque = Vector3.new(1e9, 1e9, 1e9), CFrame = root.CFrame }, root)
        notify("FLIGHT ENABLED  /  WASD + Space + Shift")
        flyButton.Text = "FLIGHT  /  ON"
        flyButton.BackgroundColor3 = COLORS.MintDark
    end)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.fromOffset(0, 75),
        BackgroundTransparency = 1,
        Text = "FLIGHT SPEED",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, flyTabContent)

    local speedValue = make("TextLabel", {
        Size = UDim2.fromOffset(50, 18),
        Position = UDim2.new(1, -50, 0, 75),
        BackgroundTransparency = 1,
        Text = "50",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = COLORS.Mint,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, flyTabContent)

    local speedBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.fromOffset(0, 103),
        BackgroundColor3 = COLORS.PanelLight,
        BorderSizePixel = 0,
    }, flyTabContent)
    round(speedBar, 4)
    local speedFill = make("Frame", {
        Size = UDim2.new(0.21, 0, 1, 0),
        BackgroundColor3 = COLORS.Mint,
        BorderSizePixel = 0,
    }, speedBar)
    round(speedFill, 4)

    local speedButton = make("TextButton", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.fromOffset(-10, -6),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, speedBar)

    speedButton.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - speedBar.AbsolutePosition.X) / speedBar.AbsoluteSize.X, 0, 1)
                flySpeed = math.floor(10 + percent * 190)
                speedValue.Text = tostring(flySpeed)
                speedFill.Size = UDim2.new(percent, 0, 1, 0)
            end
        end)
        UserInputService.InputEnded:Wait()
        connection:Disconnect()
    end)

    -- ============================================
    -- ESP FUNCTIONS
    -- ============================================
    removeESP = function(player)
        if espObjects[player] then
            for _, object in ipairs(espObjects[player]) do object:Destroy() end
            espObjects[player] = nil
        end
    end

    createESP = function(player)
        if player == localPlayer or not espEnabled then return end
        removeESP(player)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local highlight = make("Highlight", {
            Adornee = character,
            FillColor = COLORS.Mint,
            FillTransparency = 0.55,
            OutlineColor = COLORS.Mint,
            OutlineTransparency = 0.1,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        }, character)
        local tag = make("BillboardGui", {
            Adornee = root,
            Size = UDim2.fromOffset(140, 25),
            StudsOffset = Vector3.new(0, 3, 0),
            AlwaysOnTop = true,
        }, root)
        make("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = player.DisplayName,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = COLORS.Text,
            TextStrokeTransparency = 0.4,
        }, tag)
        espObjects[player] = { highlight, tag }
    end

    -- MAIN TAB (rebuild)
    for _, child in ipairs(mainTabContent:GetChildren()) do
        child.Visible = false
    end

    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Text = "MAIN CONTROLS",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COLORS.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, mainTabContent)

    -- ============================================
    -- FLY LOOP
    -- ============================================
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not flyVelocity or not flyGyro then return end
        local camera = workspace.CurrentCamera
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.yAxis end
        flyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.zero
        local character = localPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if direction.Magnitude > 0 and root then flyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + direction.Unit) end
    end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.3)
            if espEnabled then createESP(player) end
        end)
    end)

    task.spawn(function()
        while gui.Parent do
            task.wait(2)
            if autoRefreshPlayers then
                mainSelector.Refresh()
                teleportSelector.Refresh()
                flingSelector.Refresh()
            end
        end
    end)

    -- ============================================
    -- DRAG FUNCTIONALITY
    -- ============================================
    local dragging = false
    local dragStart = nil
    local startPosition = nil

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)

    blehGui = gui
    return gui
end

-- ============================================
-- SECOND GUI (Fatality‑based) – SIMPLIFIED to only Aimbot, Silent Aim, Max FOV
-- ============================================

local blehskidGui = nil
local blehskidVisible = false
local blehskidWindow = nil

local function createBlehskidGUI()
    if blehskidWindow then
        blehskidWindow:SetVisible(true)
        blehskidVisible = true
        return blehskidWindow
    end

    -- Load Fatality library (only once)
    local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))()
    local Notification = Fatality:CreateNotifier()

    Fatality:Loader({
        Name = "blehskid",
        Duration = 4
    })

    Notification:Notify({
        Title = "blehskid",
        Content = "Welcome back, " .. localPlayer.DisplayName,
        Icon = "clipboard"
    })

    local Window = Fatality.new({
        Name = "blehskid",
    })
    Window:SetExpire("")
    -- Hide Fatality's expiry label (including the default "never" value).
    task.spawn(function()
        for _ = 1, 100 do
            local roots = {playerGui, game:GetService("CoreGui")}
            if gethui then
                local ok, ui = pcall(gethui)
                if ok and ui then table.insert(roots, ui) end
            end
            for _, rootGui in ipairs(roots) do
                pcall(function()
                    for _, obj in ipairs(rootGui:GetDescendants()) do
                        local textValue = obj:IsA("TextLabel") and string.lower(obj.Text or "") or ""
                        if obj:IsA("TextLabel") and (string.find(textValue, "expires", 1, true) or textValue == "never") then
                            obj:Destroy()
                        end
                    end
                end)
            end
            task.wait(0.2)
        end
    end)

    -- Only RAGE tab, with only Aimbot, Silent Aim, Maximum FOV
    local Rage = Window:AddMenu({ Name = "RAGE", Icon = "skull" })
    local General = Rage:AddSection({ Position = 'left', Name = "GENERAL" })
    local Extra = Window:AddMenu({ Name = "EXTRA", Icon = "settings" })
    local ExtraGeneral = Extra:AddSection({ Position = 'left', Name = "GENERAL" })

    ExtraGeneral:AddToggle({
        Name = "Enemy ESP",
        Default = espEnabled,
        Callback = function(state)
            if state ~= espEnabled then
                toggleESP()
            end
        end
    })

    -- Aimbot toggle
    local aimbotToggle = General:AddToggle({
        Name = "Aimbot",
        Risky = true,
        Callback = function(state)
            aimbotEnabled = state
            addLine(aimbotEnabled and "Aimbot ENABLED" or "Aimbot DISABLED", 
                    aimbotEnabled and Color3.fromRGB(0,255,150) or Color3.fromRGB(200,200,200))
        end
    })

    -- Click the value box to set the key that toggles Aimbot.
    local aimbotKeybind = Enum.KeyCode.X
    General:AddKeybind({
        Name = "Aimbot keybind",
        Default = aimbotKeybind,
        Callback = function(keyName)
            aimbotKeybind = Enum.KeyCode[keyName]
        end
    })

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == aimbotKeybind then
            aimbotToggle:SetValue(not aimbotToggle:GetValue())
        end
    end)

    -- Maximum FOV slider
    General:AddSlider({
        Name = "Maximum fov",
        Type = " deg",
        Default = 59,
        Min = 10,
        Max = 180,
        Callback = function(val)
            maxFov = val
            addLine("Max FOV set to " .. maxFov, Color3.fromRGB(0,255,150))
        end
    })

    -- Click the value box to choose the key that shows or hides GUI2.
    local menuKeybind = Enum.KeyCode.RightShift
    General:AddKeybind({
        Name = "Menu keybind",
        Default = menuKeybind,
        Callback = function(keyName)
            menuKeybind = Enum.KeyCode[keyName]
        end
    })

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == menuKeybind then
            blehskidVisible = not blehskidVisible
            Window:SetVisible(blehskidVisible)
        end
    end)

    -- Optional: small notification button
    General:AddButton({
        Name = "Notification",
        Callback = function()
            Notification:Notify({
                Title = "blehskid",
                Content = "Aimbot, Silent Aim, FOV only",
                Duration = 3,
                Icon = "info"
            })
        end,
    })

    -- Store the GUI object
    blehskidGui = playerGui:FindFirstChild("blehskid")
    if not blehskidGui then
        for _, child in ipairs(playerGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.Name == "blehskid" then
                blehskidGui = child
                break
            end
        end
    end

    blehskidWindow = Window
    blehskidVisible = true
    return blehskidWindow
end

-- ============================================
-- COMMAND HANDLER
-- ============================================

local function executeCommand(cmd)
    cmd = cmd:gsub("^%s+", ""):gsub("%s+$", "")
    if cmd == "" then return end

    addLine("C:\\> " .. cmd, Color3.fromRGB(0, 255, 150))

    local args = {}
    for word in cmd:gmatch("%S+") do table.insert(args, word) end
    local command = args[1]:lower()

    if command == "help" then
        addLine("options", Color3.fromRGB(0,255,150))
        addLine("fly: - toggle flight", Color3.fromRGB(200,255,200))
        addLine("unfly: - disable flight", Color3.fromRGB(200,255,200))
        addLine("flyspeed: - set flight speed (default 50)", Color3.fromRGB(200,255,200))
        addLine("noclip: - toggle noclip", Color3.fromRGB(200,255,200))
        addLine("clip: - disable noclip", Color3.fromRGB(200,255,200))
        addLine("goto: - Teleport to a player (partial name works)", Color3.fromRGB(200,255,200))
        addLine("speed: - Set walkspeed (default 16)", Color3.fromRGB(200,255,200))
        addLine("esp: - toggle ESP (highlights players)", Color3.fromRGB(200,255,200))
        addLine("noesp: - Disable ESP", Color3.fromRGB(200,255,200))
        addLine("tp: - Teleport to coordinates", Color3.fromRGB(200,255,200))
        addLine("respawn: - kill your character to respawn", Color3.fromRGB(200,255,200))
        addLine("antifling: - Toggle anti‑fling", Color3.fromRGB(200,255,200))
        addLine("unantifling: - Disable anti‑fling", Color3.fromRGB(200,255,200))
        addLine("rejoin: - Rejoin the server (add 'true' to reposition)", Color3.fromRGB(200,255,200))
        addLine("jerk: - Start the jerk (equip the tool)", Color3.fromRGB(200,255,200))
        addLine("unjerk: - Stop the jerk", Color3.fromRGB(200,255,200))
        addLine("gui1: - Open the main BlehControlDeck GUI", Color3.fromRGB(200,255,200))
        addLine("gui2: - Open the simplified Fatality GUI (Aimbot, Silent Aim, FOV)", Color3.fromRGB(200,255,200))
        addLine("(Press ; to toggle the UA CMD terminal)", Color3.fromRGB(200,200,200))
    elseif command == "clear" then
        clearTerminal()
    elseif command == "echo" then
        local msg = table.concat(args, " ", 2)
        addLine(msg)
    elseif command == "gui1" then
        local guiObj = createBlehGUI()
        if guiObj then
            guiObj.Enabled = true
            blehVisible = true
            addLine("BlehControlDeck opened.")
        end
    elseif command == "gui2" then
        local guiObj = createBlehskidGUI()
        if guiObj then
            guiObj:SetVisible(true)
            blehskidVisible = true
            addLine("Simplified blehskid GUI opened (Aimbot, Silent Aim, FOV).")
        end
    elseif command == "exit" then
        termGui.Enabled = false
    -- === FLY ===
    elseif command == "fly" then
        if not flyActive then startFly() else stopFly() end
    elseif command == "unfly" then
        stopFly()
    elseif command == "flyspeed" then
        local spd = args[2] or args[1]
        if spd and tonumber(spd) then
            flySpeed = tonumber(spd)
            addLine("Fly speed set to " .. flySpeed, Color3.fromRGB(0,255,150))
        else
            addLine("Usage: flyspeed <number>", Color3.fromRGB(255,100,100))
        end
    -- === NOCLIP ===
    elseif command == "noclip" then
        if not noclipActive then startNoclip() else stopNoclip() end
    elseif command == "clip" then
        stopNoclip()
    -- === GOTO ===
    elseif command == "goto" then
        local target = args[2] or args[1]
        if target then
            gotoPlayer(target)
        else
            addLine("Usage: goto <player>", Color3.fromRGB(255,100,100))
        end
    -- === SPEED ===
    elseif command == "speed" then
        local spd = args[2] or args[1]
        if spd and tonumber(spd) then
            setSpeed(spd)
        else
            addLine("Usage: speed <number>", Color3.fromRGB(255,100,100))
        end
    -- === ESP ===
    elseif command == "esp" then
        toggleESP()
    elseif command == "noesp" then
        if espEnabled then toggleESP() end
    -- === TP ===
    elseif command == "tp" then
        if #args >= 4 then
            teleportToPos(args[2], args[3], args[4])
        else
            addLine("Usage: tp <X> <Y> <Z>", Color3.fromRGB(255,100,100))
        end
    -- === RESPAWN ===
    elseif command == "respawn" then
        respawn()
    -- === ANTIFLING ===
    elseif command == "antifling" then
        toggleAntifling()
    elseif command == "unantifling" then
        if antifling then
            antifling:Disconnect()
            antifling = nil
            addLine("Anti‑fling disabled", Color3.fromRGB(200,200,200))
        else
            addLine("Anti‑fling is already disabled", Color3.fromRGB(200,200,200))
        end
    -- === REJOIN ===
    elseif command == "rejoin" then
        rejoinCommand(args)
    -- === JERK ===
    elseif command == "jerk" then
        startJerk()
    elseif command == "unjerk" then
        stopJerk()
    else
        addLine("Unknown command: " .. cmd, Color3.fromRGB(255, 100, 100))
    end
end

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and inputBox.Text ~= "" then
        local cmd = inputBox.Text
        inputBox.Text = ""
        executeCommand(cmd)
        task.wait(0.05)
        outputFrame.CanvasPosition = Vector2.new(0, outputFrame.CanvasSize.Y.Offset)
    end
end)

-- Welcome message
addLine("UA CMD", Color3.fromRGB(0, 255, 150))
addLine("Type 'help' for commands.")
addLine("Type 'gui1' for the full BlehControlDeck.")
addLine("Type 'gui2' for the simplified menu (Aimbot, Silent Aim, FOV).")
addLine("userUA - panel")
addLine("")

inputBox:CaptureFocus()

