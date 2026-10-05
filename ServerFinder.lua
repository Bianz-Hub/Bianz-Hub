--[[
    ⬡ BIANN HUB v2.0 ⬡
    Private Server Finder · Minecraft Pixel UI
    Simple · Clean · Functional
    User: BiannXz KalxX · N349
]]

-- === SERVICES ===
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

-- === CLEANUP ===
pcall(function()
    if CoreGui:FindFirstChild("BiannHub") then
        CoreGui.BiannHub:Destroy()
    end
end)

-- === CONFIG ===
local Config = {
    MaxThreshold = 1,
    AutoHop = false,
    SoundOn = true,
    AutoHopInterval = 5,
}

-- === MINECRAFT COLORS ===
local MC = {
    Grass = Color3.fromRGB(106, 168, 79),
    GrassLight = Color3.fromRGB(140, 200, 100),
    GrassDark = Color3.fromRGB(60, 100, 40),
    Dirt = Color3.fromRGB(134, 96, 67),
    DirtLight = Color3.fromRGB(165, 125, 90),
    DirtDark = Color3.fromRGB(90, 60, 35),
    Stone = Color3.fromRGB(128, 128, 128),
    StoneLight = Color3.fromRGB(160, 160, 160),
    StoneDark = Color3.fromRGB(80, 80, 80),
    Wood = Color3.fromRGB(156, 110, 60),
    WoodLight = Color3.fromRGB(190, 145, 90),
    WoodDark = Color3.fromRGB(105, 70, 35),
    Text = Color3.fromRGB(255, 255, 255),
    TextShadow = Color3.fromRGB(30, 30, 30),
    Gold = Color3.fromRGB(255, 215, 0),
    Diamond = Color3.fromRGB(100, 220, 255),
    Redstone = Color3.fromRGB(200, 40, 40),
    Emerald = Color3.fromRGB(80, 200, 100),
    Lapis = Color3.fromRGB(40, 80, 200),
    Coal = Color3.fromRGB(40, 40, 40),
}

-- === HELPER ===
local function PlayClick()
    if not Config.SoundOn then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://9125402735"
        s.Volume = 0.3
        s.Parent = SoundService
        s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

local function PixelBorder(parent, light, dark, thickness)
    thickness = thickness or 2
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, thickness*2, 0, thickness)
    top.Position = UDim2.new(0, -thickness, 0, -thickness)
    top.BackgroundColor3 = light
    top.BorderSizePixel = 0
    top.ZIndex = parent.ZIndex - 1
    top.Parent = parent

    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(1, thickness*2, 0, thickness)
    bottom.Position = UDim2.new(0, -thickness, 1, 0)
    bottom.BackgroundColor3 = dark
    bottom.BorderSizePixel = 0
    bottom.ZIndex = parent.ZIndex - 1
    bottom.Parent = parent

    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, thickness, 1, 0)
    left.Position = UDim2.new(0, -thickness, 0, 0)
    left.BackgroundColor3 = light
    left.BorderSizePixel = 0
    left.ZIndex = parent.ZIndex - 1
    left.Parent = parent

    local right = Instance.new("Frame")
    right.Size = UDim2.new(0, thickness, 1, 0)
    right.Position = UDim2.new(1, 0, 0, 0)
    right.BackgroundColor3 = dark
    right.BorderSizePixel = 0
    right.ZIndex = parent.ZIndex - 1
    right.Parent = parent
end

-- === SERVER FINDER ===
local function GetServers()
    local servers = {}
    local cursor = ""

    for i = 1, 3 do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s",
            game.PlaceId, cursor
        )
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and response and response.data then
            for _, server in pairs(response.data) do
                if server.playing and server.id ~= game.JobId then
                    table.insert(servers, {
                        id = server.id,
                        playing = server.playing,
                        maxPlayers = server.maxPlayers,
                    })
                end
            end
            cursor = response.nextPageCursor or ""
            if cursor == "" then break end
        else
            break
        end
    end
    return servers
end

local function FindLowestServer()
    local servers = GetServers()
    local lowest = nil
    for _, s in pairs(servers) do
        if s.playing <= Config.MaxThreshold then
            if not lowest or s.playing < lowest.playing then
                lowest = s
            end
        end
    end
    return lowest
end

local function HopToServer(server)
    if not server then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "BIANN HUB",
                Text = "Server gak ketemu, coba threshold lebih tinggi",
                Duration = 3,
            })
        end)
        return false
    end
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
    end)
    return true
end

-- === GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "BiannHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- === LOGO BUTTON ===
local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0, 54, 0, 54)
LogoBtn.Position = UDim2.new(0, 20, 0.5, -27)
LogoBtn.BackgroundColor3 = MC.Grass
LogoBtn.Text = "🌐"
LogoBtn.TextSize = 26
LogoBtn.Font = Enum.Font.Arcade
LogoBtn.BorderSizePixel = 0
LogoBtn.AutoButtonColor = false
LogoBtn.Active = true
LogoBtn.ZIndex = 10
LogoBtn.Parent = gui

PixelBorder(LogoBtn, MC.GrassLight, MC.GrassDark, 3)

-- === MENU FRAME ===
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 340, 0, 290)
MenuFrame.Position = UDim2.new(0.5, -170, 0.5, -145)
MenuFrame.BackgroundColor3 = MC.Coal
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Active = true
MenuFrame.ZIndex = 20
MenuFrame.Parent = gui

PixelBorder(MenuFrame, MC.StoneLight, MC.StoneDark, 3)

-- === HEADER ===
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = MC.Dirt
Header.BorderSizePixel = 0
Header.ZIndex = 21
Header.Parent = MenuFrame

PixelBorder(Header, MC.DirtLight, MC.DirtDark, 3)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 22)
Title.Position = UDim2.new(0, 15, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "PRIVATE SERVER FINDER"
Title.TextColor3 = MC.Text
Title.TextSize = 14
Title.Font = Enum.Font.Arcade
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0
Title.TextStrokeColor3 = MC.TextShadow
Title.ZIndex = 22
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -50, 0, 14)
SubTitle.Position = UDim2.new(0, 15, 0, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "by BiannXz KalxX"
SubTitle.TextColor3 = MC.Text
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.Arcade
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.TextStrokeTransparency = 0
SubTitle.TextStrokeColor3 = MC.TextShadow
SubTitle.ZIndex = 22
SubTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 11)
CloseBtn.BackgroundColor3 = MC.Redstone
CloseBtn.Text = "X"
CloseBtn.TextColor3 = MC.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.Arcade
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.TextStrokeTransparency = 0
CloseBtn.TextStrokeColor3 = MC.TextShadow
CloseBtn.ZIndex = 22
CloseBtn.Parent = Header

PixelBorder(CloseBtn, Color3.fromRGB(240, 80, 80), Color3.fromRGB(120, 20, 20), 2)

-- === CURRENT SERVER INFO ===
local currentLabel = Instance.new("TextLabel")
currentLabel.Size = UDim2.new(1, -30, 0, 20)
currentLabel.Position = UDim2.new(0, 15, 0, 62)
currentLabel.BackgroundTransparency = 1
currentLabel.Text = "Current Server: " .. #Players:GetPlayers() .. " player(s)"
currentLabel.TextColor3 = MC.Diamond
currentLabel.TextSize = 12
currentLabel.Font = Enum.Font.Arcade
currentLabel.TextXAlignment = Enum.TextXAlignment.Left
currentLabel.TextStrokeTransparency = 0
currentLabel.TextStrokeColor3 = MC.TextShadow
currentLabel.ZIndex = 22
currentLabel.Parent = MenuFrame

-- === THRESHOLD INPUT ===
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -30, 0, 40)
inputFrame.Position = UDim2.new(0, 15, 0, 90)
inputFrame.BackgroundColor3 = MC.StoneDark
inputFrame.BorderSizePixel = 0
inputFrame.ZIndex = 22
inputFrame.Parent = MenuFrame

PixelBorder(inputFrame, MC.StoneLight, MC.StoneDark, 2)

local thresholdInput = Instance.new("TextBox")
thresholdInput.Size = UDim2.new(1, -20, 1, -10)
thresholdInput.Position = UDim2.new(0, 10, 0, 5)
thresholdInput.BackgroundTransparency = 1
thresholdInput.Text = "1"
thresholdInput.PlaceholderText = "Max players..."
thresholdInput.TextColor3 = MC.Text
thresholdInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
thresholdInput.TextSize = 14
thresholdInput.Font = Enum.Font.Arcade
thresholdInput.TextXAlignment = Enum.TextXAlignment.Center
thresholdInput.ClearTextOnFocus = false
thresholdInput.ZIndex = 23
thresholdInput.Parent = inputFrame

thresholdInput.FocusLost:Connect(function()
    local num = tonumber(thresholdInput.Text)
    if num and num >= 1 then
        Config.MaxThreshold = math.floor(num)
    else
        thresholdInput.Text = tostring(Config.MaxThreshold)
    end
end)

-- === HOP BUTTON ===
local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(1, -30, 0, 44)
HopBtn.Position = UDim2.new(0, 15, 0, 140)
HopBtn.BackgroundColor3 = MC.Lapis
HopBtn.Text = "HOP SERVER NOW"
HopBtn.TextColor3 = MC.Text
HopBtn.TextSize = 14
HopBtn.Font = Enum.Font.Arcade
HopBtn.BorderSizePixel = 0
HopBtn.AutoButtonColor = false
HopBtn.TextStrokeTransparency = 0
HopBtn.TextStrokeColor3 = MC.TextShadow
HopBtn.ZIndex = 22
HopBtn.Parent = MenuFrame

PixelBorder(HopBtn, Color3.fromRGB(80, 130, 255), Color3.fromRGB(20, 50, 150), 3)

local hopStatus = Instance.new("TextLabel")
hopStatus.Size = UDim2.new(1, -30, 0, 16)
hopStatus.Position = UDim2.new(0, 15, 0, 188)
hopStatus.BackgroundTransparency = 1
hopStatus.Text = ""
hopStatus.TextColor3 = MC.Gold
hopStatus.TextSize = 10
hopStatus.Font = Enum.Font.Arcade
hopStatus.TextXAlignment = Enum.TextXAlignment.Left
hopStatus.TextStrokeTransparency = 0
hopStatus.TextStrokeColor3 = MC.TextShadow
hopStatus.ZIndex = 22
hopStatus.Parent = MenuFrame

-- === AUTO HOP TOGGLE ===
local AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(1, -30, 0, 38)
AutoHopBtn.Position = UDim2.new(0, 15, 0, 210)
AutoHopBtn.BackgroundColor3 = MC.StoneDark
AutoHopBtn.Text = "AUTO HOP: DISABLED"
AutoHopBtn.TextColor3 = MC.Redstone
AutoHopBtn.TextSize = 12
AutoHopBtn.Font = Enum.Font.Arcade
AutoHopBtn.BorderSizePixel = 0
AutoHopBtn.AutoButtonColor = false
AutoHopBtn.TextStrokeTransparency = 0
AutoHopBtn.TextStrokeColor3 = MC.TextShadow
AutoHopBtn.ZIndex = 22
AutoHopBtn.Parent = MenuFrame

PixelBorder(AutoHopBtn, MC.StoneLight, MC.StoneDark, 2)

-- === AUTO HOP LOGIC ===
local autoHopConn = nil

local function StartAutoHop()
    if autoHopConn then autoHopConn:Disconnect() end
    autoHopConn = task.spawn(function()
        while Config.AutoHop do
            local currentPlayers = #Players:GetPlayers()
            if currentPlayers > Config.MaxThreshold then
                hopStatus.Text = "Auto hop: cari server..."
                local server = FindLowestServer()
                if server then
                    hopStatus.Text = "Auto hop: pindah ke " .. server.playing .. " player"
                    HopToServer(server)
                    return
                else
                    hopStatus.Text = "Auto hop: server gak ketemu"
                end
            end
            task.wait(Config.AutoHopInterval)
        end
    end)
end

local function StopAutoHop()
    Config.AutoHop = false
    if autoHopConn then
        pcall(function() task.cancel(autoHopConn) end)
        autoHopConn = nil
    end
    AutoHopBtn.Text = "AUTO HOP: DISABLED"
    AutoHopBtn.TextColor3 = MC.Redstone
end

-- === BUTTON EVENTS ===
HopBtn.MouseButton1Click:Connect(function()
    PlayClick()
    hopStatus.Text = "Mencari server..."
    task.spawn(function()
        local server = FindLowestServer()
        if server then
            hopStatus.Text = "Ketemu: " .. server.playing .. "/" .. server.maxPlayers .. " player"
            task.wait(0.5)
            HopToServer(server)
        else
            hopStatus.Text = "Server gak ketemu (threshold: " .. Config.MaxThreshold .. ")"
        end
    end)
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    PlayClick()
    Config.AutoHop = not Config.AutoHop
    if Config.AutoHop then
        AutoHopBtn.Text = "AUTO HOP: ENABLED"
        AutoHopBtn.TextColor3 = MC.Emerald
        hopStatus.Text = "Auto hop aktif"
        StartAutoHop()
    else
        StopAutoHop()
        hopStatus.Text = "Auto hop mati"
    end
end)

-- === TOGGLE MENU ===
local menuOpen = false

LogoBtn.MouseButton1Click:Connect(function()
    PlayClick()
    menuOpen = not menuOpen
    if menuOpen then
        MenuFrame.Visible = true
        currentLabel.Text = "Current Server: " .. #Players:GetPlayers() .. " player(s)"
    end
    MenuFrame.Visible = menuOpen
end)

CloseBtn.MouseButton1Click:Connect(function()
    PlayClick()
    menuOpen = false
    MenuFrame.Visible = false
end)

-- === DRAG MENU ===
local draggingMenu = false
local menuDragStart
local menuStartPos

MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true
        menuDragStart = input.Position
        menuStartPos = MenuFrame.Position
    end
end)
MenuFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - menuDragStart
        MenuFrame.Position = UDim2.new(
            menuStartPos.X.Scale,
            menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale,
            menuStartPos.Y.Offset + delta.Y
        )
    end
end)

-- === DRAG LOGO ===
local draggingLogo = false
local dragStart
local startPos

LogoBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLogo = true
        dragStart = input.Position
        startPos = LogoBtn.Position
    end
end)
LogoBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLogo = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingLogo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        LogoBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- === INIT ===
MenuFrame.Visible = true
menuOpen = true

print("[BIANN HUB v2.0] Loaded · User: BiannXz KalxX")
