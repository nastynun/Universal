-- Player Tools (Pandel) - Final
-- Made by Nasty GBT 😎

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local workspace = workspace

local player = Players.LocalPlayer

-- STATE
local state = {
    gui = nil,
    frame = nil,
    openBtn = nil,
    places = {},
    noclip = false,
    infJump = false,
    instant = false,
    antiAfk = false,
    esp = false,
    fps = false,
    espObjects = {},
    fpsConn = nil,
    afkConn = nil,
    instantConn = nil,
}

-- Utility
local function new(class, parent, props)
    local o = Instance.new(class)
    if parent then o.Parent = parent end
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then o.Parent = v
            else pcall(function() o[k] = v end) end
        end
    end
    return o
end

-- Clean old GUI
pcall(function()
    local old = game.CoreGui:FindFirstChild("Pandel_PlayerTools_v1")
    if old then old:Destroy() end
end)

-- Build GUI
local function buildGui()
    -- ScreenGui
    local screenGui = new("ScreenGui", game.CoreGui, {Name = "Pandel_PlayerTools_v1", ResetOnSpawn = false})
    state.gui = screenGui

    -- Blue round draggable Menu button
    local openBtn = new("TextButton", screenGui, {
        Name = "MenuButton",
        Size = UDim2.new(0,60,0,60),
        Position = UDim2.new(0,20,0.5,-30),
        BackgroundColor3 = Color3.fromRGB(0,150,255),
        Text = "Menu",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = true,
    })
    new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
    state.openBtn = openBtn

    -- Make openBtn draggable (custom)
    do
        local dragging, dragStart, startPos
        openBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = openBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        openBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging and dragStart and startPos then
                    local delta = input.Position - dragStart
                    openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
    end

    -- Main frame (center)
    local frame = new("Frame", screenGui, {
        Name = "PandelFrame",
        Size = UDim2.new(0,320,0,520),
        Position = UDim2.new(0.5,-160,0.5,-260),
        BackgroundColor3 = Color3.fromRGB(20,40,70),
        BackgroundTransparency = 0.18,
        Visible = false,
        Active = true,
    })
    new("UICorner", frame).CornerRadius = UDim.new(0,12)
    state.frame = frame

    -- Title bar
    local titleBar = new("Frame", frame, {Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(35,60,100)})
    new("UICorner", titleBar).CornerRadius = UDim.new(0,12)
    local title = new("TextLabel", titleBar, {Text = "Pandel", BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 18, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-100,1,0), TextXAlignment = Enum.TextXAlignment.Left})

    local minBtn = new("TextButton", titleBar, {Text = "-", Size = UDim2.new(0,28,0,24), Position = UDim2.new(1,-68,0,6), BackgroundColor3 = Color3.fromRGB(100,100,0), TextColor3 = Color3.new(1,1,1)})
    new("UICorner", minBtn).CornerRadius = UDim.new(0,6)
    local closeBtn = new("TextButton", titleBar, {Text = "X", Size = UDim2.new(0,28,0,24), Position = UDim2.new(1,-34,0,6), BackgroundColor3 = Color3.fromRGB(150,0,0), TextColor3 = Color3.new(1,1,1)})
    new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    -- Content Scrolling
    local content = new("ScrollingFrame", frame, {Size = UDim2.new(1,-20,1,-96), Position = UDim2.new(0,10,0,46), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,2,0)})
    content.ScrollBarThickness = 6
    local layout = new("UIListLayout", content, {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function addLabel(text)
        return new("TextLabel", content, {Size = UDim2.new(0,280,0,20), Text = text, BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14})
    end
    local function addBtn(text, w)
        w = w or 280
        local b = new("TextButton", content, {Size = UDim2.new(0,w,0,30), BackgroundColor3 = Color3.fromRGB(60,70,90), Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham, TextSize = 14})
        new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end

    -- WalkSpeed row (buttons)
    addLabel("WalkSpeed")
    local walkRow = new("Frame", content, {Size = UDim2.new(0,280,0,36), BackgroundTransparency = 1})
    local ws25 = new("TextButton", walkRow, {Size = UDim2.new(0,86,0,30), Position = UDim2.new(0,0,0,3), Text = "25", BackgroundColor3 = Color3.fromRGB(80,90,110), Font = Enum.Font.Gotham})
    new("UICorner", ws25).CornerRadius = UDim.new(0,6)
    local ws50 = new("TextButton", walkRow, {Size = UDim2.new(0,86,0,30), Position = UDim2.new(0,96,0,3), Text = "50", BackgroundColor3 = Color3.fromRGB(80,90,110), Font = Enum.Font.Gotham})
    new("UICorner", ws50).CornerRadius = UDim.new(0,6)
    local ws100 = new("TextButton", walkRow, {Size = UDim2.new(0,86,0,30), Position = UDim2.new(0,192,0,3), Text = "100", BackgroundColor3 = Color3.fromRGB(80,90,110), Font = Enum.Font.Gotham})
    new("UICorner", ws100).CornerRadius = UDim.new(0,6)

    -- Noclip
    local noclipBtn = addBtn("Noclip: OFF")
    noclipBtn.LayoutOrder = 20

    -- Infinite Jump
    local infJumpBtn = addBtn("Infinite Jump: OFF")

    -- Instant Anything
    local instantBtn = addBtn("Instant Anything: OFF")

    -- Anti-AFK
    local antiBtn = addBtn("Anti-AFK: OFF")

    -- Teleport + vertical Save/Place pairs
    addLabel("Teleport+")
    local save1 = addBtn("Save Place 1")
    local place1 = addBtn("Place 1")
    local save2 = addBtn("Save Place 2")
    local place2 = addBtn("Place 2")
    local save3 = addBtn("Save Place 3")
    local place3 = addBtn("Place 3")

    -- ESP & FPS
    local espBtn = addBtn("ESP: OFF")
    local fpsBtn = addBtn("FPS: OFF")

    -- Rejoin & ServerHop
    local rejoinBtn = addBtn("Rejoin")
    local hopBtn = addBtn("ServerHop")

    -- Footer
    local footer = new("TextLabel", frame, {Text = "Made by Nasty GBT 😎", Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,1,-24), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,220,255), Font = Enum.Font.GothamBold, TextSize = 14})

    -- FPS Label
    local fpsLabel = new("TextLabel", screenGui, {Text = "", Size = UDim2.new(0,110,0,20), Position = UDim2.new(1,-130,1,-40), BackgroundColor3 = Color3.fromRGB(10,10,10), BackgroundTransparency = 0.6, TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 14, Visible = false})
    new("UICorner", fpsLabel).CornerRadius = UDim.new(0,6)

    -- Functionality wiring

    -- helper to get current humanoid/root
    local function getHumRoot()
        local char = player.Character or player.CharacterAdded:Wait()
        local h = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        return h, root
    end

    -- WalkSpeed handlers
    ws25.MouseButton1Click:Connect(function()
        local h = getHumRoot()
        if type(h) == "table" then h = h[1] end
        local hum = getHumRoot()
        local hh = (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
        if hh then hh.WalkSpeed = 25 end
    end)
    ws50.MouseButton1Click:Connect(function() local hh = (player.Character and player.Character:FindFirstChildOfClass("Humanoid")); if hh then hh.WalkSpeed = 50 end end)
    ws100.MouseButton1Click:Connect(function() local hh = (player.Character and player.Character:FindFirstChildOfClass("Humanoid")); if hh then hh.WalkSpeed = 100 end end)

    -- Noclip loop
    noclipBtn.MouseButton1Click:Connect(function()
        state.noclip = not state.noclip
        if state.noclip then noclipBtn.Text = "Noclip: ON"; noclipBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        else noclipBtn.Text = "Noclip: OFF"; noclipBtn.BackgroundColor3 = Color3.fromRGB(100,0,0) end
    end)
    local noclipConnection = RunService.Stepped:Connect(function()
        if state.noclip then
            local char = player.Character
            if char then
                for _,p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end
    end)

    -- Infinite jump
    infJumpBtn.MouseButton1Click:Connect(function()
        state.infJump = not state.infJump
        if state.infJump then infJumpBtn.Text = "Infinite Jump: ON"; infJumpBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        else infJumpBtn.Text = "Infinite Jump: OFF"; infJumpBtn.BackgroundColor3 = Color3.fromRGB(100,0,0) end
    end)
    UserInputService.JumpRequest:Connect(function()
        if state.infJump then
            local h = (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
            if h then h:ChangeState("Jumping") end
        end
    end)

    -- Instant Anything
    instantBtn.MouseButton1Click:Connect(function()
        state.instant = not state.instant
        if state.instant then
            instantBtn.Text = "Instant Anything: ON"; instantBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then pcall(function() v.HoldDuration = 0 end) end
            end
            if not state.instantConn then
                state.instantConn = workspace.DescendantAdded:Connect(function(obj)
                    if obj:IsA("ProximityPrompt") and state.instant then pcall(function() obj.HoldDuration = 0 end) end
                end)
            end
        else
            instantBtn.Text = "Instant Anything: OFF"; instantBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then pcall(function() v.HoldDuration = 1 end) end
            end
            if state.instantConn then state.instantConn:Disconnect(); state.instantConn = nil end
        end
    end)

    -- Anti-AFK
    antiBtn.MouseButton1Click:Connect(function()
        state.antiAfk = not state.antiAfk
        if state.antiAfk then
            antiBtn.Text = "Anti-AFK: ON"; antiBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
            if not state.afkConn then
                state.afkConn = player.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.6)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        else
            antiBtn.Text = "Anti-AFK: OFF"; antiBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
            if state.afkConn then state.afkConn:Disconnect(); state.afkConn = nil end
        end
    end)

    -- Teleport Save / Place vertical logic
    local function savePlace(i)
        local _, root = getHumRoot()
        if root then
            state.places[i] = root.CFrame
            local b = ({save1,save2,save3})[i]
            if b then b.BackgroundColor3 = Color3.fromRGB(0,120,0); task.delay(0.25, function() if b then b.BackgroundColor3 = Color3.fromRGB(60,70,90) end end) end
        end
    end
    local function goPlace(i)
        local cf = state.places[i]
        local _, root = getHumRoot()
        if cf and root then
            pcall(function() root.CFrame = cf + Vector3.new(0,1,0) end)
        end
    end
    save1.MouseButton1Click:Connect(function() savePlace(1) end)
    place1.MouseButton1Click:Connect(function() goPlace(1) end)
    save2.MouseButton1Click:Connect(function() savePlace(2) end)
    place2.MouseButton1Click:Connect(function() goPlace(2) end)
    save3.MouseButton1Click:Connect(function() savePlace(3) end)
    place3.MouseButton1Click:Connect(function() goPlace(3) end)

    -- ESP: show name + distance color (client-side)
    local function createEspForPlayer(plr)
        if not plr.Character then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
        if not root then return end
        local bill = Instance.new("BillboardGui")
        bill.Adornee = root
        bill.Size = UDim2.new(0,120,0,30)
        bill.StudsOffset = Vector3.new(0,2.6,0)
        bill.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bill)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = plr.Name
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.new(1,1,1)
        bill.Parent = workspace
        state.espObjects[plr.Name] = {bill = bill, label = lbl, player = plr}
    end
    local function destroyEspForPlayer(plrName)
        local e = state.espObjects[plrName]
        if e then
            pcall(function() if e.bill then e.bill:Destroy() end end)
            state.espObjects[plrName] = nil
        end
    end

    local function updateEspColors()
        for name, data in pairs(state.espObjects) do
            local plr = data.player
            if plr and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
                local myRoot = (player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart))
                if root and myRoot then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    local color
                    if dist < 20 then color = Color3.fromRGB(0,220,120)
                    elseif dist < 80 then color = Color3.fromRGB(240,220,60)
                    else color = Color3.fromRGB(240,100,100) end
                    pcall(function() data.label.TextColor3 = color end)
                end
            end
        end
    end

    -- Enable/disable ESP
    local function enableESP(enable)
        if enable then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    createEspForPlayer(plr)
                end
            end
            state.espConnAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function()
                    task.wait(0.4)
                    if state.esp then createEspForPlayer(plr) end
                end)
            end)
            -- also remove when player leaves
            state.leaveConn = Players.PlayerRemoving:Connect(function(plr) destroyEspForPlayer(plr.Name) end)
            -- update per frame
            state.espUpdateConn = RunService.RenderStepped:Connect(updateEspColors)
        else
            for k,_ in pairs(state.espObjects) do destroyEspForPlayer(k) end
            if state.espConnAdded then state.espConnAdded:Disconnect(); state.espConnAdded = nil end
            if state.leaveConn then state.leaveConn:Disconnect(); state.leaveConn = nil end
            if state.espUpdateConn then state.espUpdateConn:Disconnect(); state.espUpdateConn = nil end
        end
    end

    espBtn.MouseButton1Click:Connect(function()
        state.esp = not state.esp
        if state.esp then espBtn.Text = "ESP: ON"; espBtn.BackgroundColor3 = Color3.fromRGB(0,120,0); enableESP(true)
        else espBtn.Text = "ESP: OFF"; espBtn.BackgroundColor3 = Color3.fromRGB(100,0,0); enableESP(false) end
    end)

    -- FPS toggle
    fpsBtn.MouseButton1Click:Connect(function()
        state.fps = not state.fps
        fpsLabel.Visible = state.fps
        if state.fps then
            fpsBtn.Text = "FPS: ON"; fpsBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
            local last = tick(); local frames = 0
            state.fpsConn = RunService.RenderStepped:Connect(function()
                frames = frames + 1
                if tick() - last >= 1 then
                    fpsLabel.Text = "FPS: "..tostring(frames)
                    frames = 0; last = tick()
                end
            end)
        else
            fpsBtn.Text = "FPS: OFF"; fpsBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
            if state.fpsConn then state.fpsConn:Disconnect(); state.fpsConn = nil end
        end
    end)

    -- Rejoin
    rejoinBtn.MouseButton1Click:Connect(function()
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)

    -- ServerHop (best-effort rejoin different instance)
    hopBtn.MouseButton1Click:Connect(function()
        pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
    end)

    -- Minimize and Close
    minBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
    closeBtn.MouseButton1Click:Connect(function() pcall(function() screenGui:Destroy() end) end)

    -- Open button toggles
    openBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        if frame.Visible then
            -- center it when opening
            frame.Position = UDim2.new(0.5,-160,0.5,-260)
        end
    end)

    -- Respawn safe: rebind nothing necessary because GUI ResetOnSpawn=false and scripts use current character each time
    player.CharacterAdded:Connect(function()
        task.wait(0.6)
        -- if noclip was on, will resume via noclipConnection each step; instant reapply if needed
        if state.instant then
            for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then pcall(function() v.HoldDuration = 0 end) end end
        end
    end)

    -- Cleanup on destroy
    screenGui.Destroying:Connect(function()
        if state.afkConn then state.afkConn:Disconnect(); state.afkConn = nil end
        if state.instantConn then state.instantConn:Disconnect(); state.instantConn = nil end
        if state.fpsConn then state.fpsConn:Disconnect(); state.fpsConn = nil end
        if state.espUpdateConn then state.espUpdateConn:Disconnect(); state.espUpdateConn = nil end
        if noclipConnection then noclipConnection:Disconnect() end
    end)
end

-- Build
buildGui()

-- Quick loader helpful message in console (pcall wrapper advisable when executing)
print("Pandel loaded. Press the blue Menu button to open. Made by Nasty GBT 😎")
