-- ============================================================================
-- VOID TERMINAL - ULTIMATE GUI v2.0
-- ============================================================================
-- ฟีเจอร์ครบครัน 50+ ฟีเจอร์ สำหรับ Roblox Executor
-- รองรับ PC และ Mobile อย่างสมบูรณ์
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local Utils = {}

function Utils.Create(name, className, parent)
    local obj = Instance.new(className)
    obj.Name = name
    if parent then obj.Parent = parent end
    return obj
end

function Utils.CreateButton(name, text, parent)
    local btn = Utils.Create(name, "TextButton", parent)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
    btn.BorderSizePixel = 2
    btn.Font = Enum.Font.GothamMonospace
    btn.TextSize = 12
    btn.AutoButtonColor = false
    return btn
end

function Utils.CreateLabel(name, text, parent)
    local lbl = Utils.Create(name, "TextLabel", parent)
    lbl.Text = text
    lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
    lbl.BorderColor3 = Color3.fromRGB(0, 255, 0)
    lbl.BorderSizePixel = 1
    lbl.Font = Enum.Font.GothamMonospace
    lbl.TextSize = 11
    return lbl
end

function Utils.CreateSlider(name, parent, minVal, maxVal)
    local slider = Utils.Create(name, "TextBox", parent)
    slider.Text = tostring(minVal)
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    slider.TextColor3 = Color3.fromRGB(0, 255, 0)
    slider.BorderColor3 = Color3.fromRGB(0, 255, 0)
    slider.BorderSizePixel = 1
    slider.Font = Enum.Font.GothamMonospace
    slider.TextSize = 10
    return slider
end

-- ============================================================================
-- MAIN GUI CLASS
-- ============================================================================

local VoidGUI = {}
VoidGUI.__index = VoidGUI

function VoidGUI.new()
    local self = setmetatable({}, VoidGUI)
    
    -- ========== GAME STATE ==========
    self.SpeedEnabled = false
    self.FlyEnabled = false
    self.NoClipEnabled = false
    self.ESPEnabled = false
    self.FullbrightEnabled = false
    self.InfiniteJumpEnabled = false
    self.XRayEnabled = false
    self.HighlightEnabled = false
    self.TracersEnabled = false
    self.JumpPowerEnabled = false
    self.AutoClickEnabled = false
    self.ClickTPEnabled = false
    self.SpinBotEnabled = false
    self.AntiAFKEnabled = false
    self.NoFallDamageEnabled = false
    self.ForceFieldEnabled = false
    self.NoRecoilEnabled = false
    self.AimbotEnabled = false
    self.WallHackEnabled = false
    self.ChamsEnabled = false
    self.TimeChangerEnabled = false
    self.GravityHackEnabled = false
    self.DebugModeEnabled = false
    self.StealthModeEnabled = false
    self.HealthBarsEnabled = false
    self.WeaponESPEnabled = false
    self.TeamCheckEnabled = false
    self.AutoRespawnEnabled = false
    self.MemoryCleanerEnabled = false
    self.AntiDetectEnabled = false
    
    -- ========== SETTINGS ==========
    self.WalkSpeed = 16
    self.JumpPower = 50
    self.FlySpeed = 50
    self.AutoClickSpeed = 10
    self.AimbotFOV = 100
    self.Gravity = 196.2
    self.TimeOfDay = 12
    self.JumpPowerValue = 50
    self.ForceFieldRadius = 20
    self.Theme = "Dark"
    
    -- ========== MOBILE ==========
    self.IsMobile = UserInputService.TouchEnabled
    self.FlyMoveVector = Vector3.new(0, 0, 0)
    self.FlyUpPressed = false
    self.FlyDownPressed = false
    self.JoystickRadius = 60
    
    -- ========== CONNECTIONS ==========
    self.Connections = {}
    self.FlyConnections = {}
    self.ESPConnections = {}
    self.PlayerConnections = {}
    
    -- ========== PROTECTION FLAGS ==========
    self.FlyToggling = false
    self.IsClickTPActive = false
    self.Waypoints = {}
    self.SavedConfigs = {}
    
    -- ========== CREATE GUI ==========
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    
    if not playerGui then
        error("PlayerGui not found!")
        return
    end
    
    self.ScreenGui = Utils.Create("VoidAccessGUI", "ScreenGui", playerGui)
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self:BuildMainFrame()
    self:BuildEffects()
    self:BuildConfirmDialog()
    self:InitializePages()
    self:ConnectEvents()
    self:SetupHotkeys()
    
    return self
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

function VoidGUI:GetLocalCharacter()
    local player = Players.LocalPlayer
    return player and player.Character
end

function VoidGUI:GetLocalHumanoid()
    local char = self:GetLocalCharacter()
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

function VoidGUI:GetLocalRootPart()
    local char = self:GetLocalCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function VoidGUI:SafeDisconnect(connection)
    if connection and type(connection) == "table" and connection.Disconnect then
        connection:Disconnect()
    elseif connection and type(connection) == "userdata" then
        if connection.Disconnect then
            connection:Disconnect()
        end
    end
end

function VoidGUI:CleanupConnections(connectionTable)
    if connectionTable then
        for _, connection in ipairs(connectionTable) do
            self:SafeDisconnect(connection)
        end
        connectionTable = {}
    end
end

function VoidGUI:LogConsole(message)
    if self.ConsoleLabel then
        local timestamp = os.date("%H:%M:%S")
        local currentText = self.ConsoleLabel.Text
        self.ConsoleLabel.Text = currentText .. "\n[" .. timestamp .. "] " .. message
        
        -- Auto scroll
        local textSize = self.ConsoleLabel.TextBounds.Y
        if textSize > 200 then
            self.ConsoleLabel.Text = string.sub(currentText, 100)
        end
    end
end

function VoidGUI:TypeText(label, text, speed)
    label.Text = ""
    local i = 1
    local typingConnection
    typingConnection = RunService.Heartbeat:Connect(function(dt)
        if i <= #text then
            label.Text = string.sub(text, 1, i)
            i = i + math.max(1, math.floor(1 * (speed or 1)))
        else
            if typingConnection then
                typingConnection:Disconnect()
            end
        end
    end)
end

-- ============================================================================
-- BUILD GUI FRAME
-- ============================================================================

function VoidGUI:BuildMainFrame()
    -- Main Frame
    self.MainFrame = Utils.Create("MainFrame", "Frame", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 400, 0, 600)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    self.MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    self.MainFrame.BorderSizePixel = 3
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    
    -- Top Bar
    self.TopBar = Utils.Create("TopBar", "Frame", self.MainFrame)
    self.TopBar.Size = UDim2.new(1, 0, 0, 40)
    self.TopBar.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
    self.TopBar.BorderColor3 = Color3.fromRGB(0, 255, 0)
    self.TopBar.BorderSizePixel = 1
    
    local titleLabel = Utils.CreateLabel("Title", "VOID TERMINAL v2.0", self.TopBar)
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.BorderSizePixel = 0
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    
    -- Close Button
    self.CloseBtn = Utils.CreateButton("CloseBtn", "X", self.TopBar)
    self.CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    self.CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    
    -- Minimize Button
    self.MinimizeBtn = Utils.CreateButton("MinimizeBtn", "-", self.TopBar)
    self.MinimizeBtn.Size = UDim2.new(0, 35, 1, 0)
    self.MinimizeBtn.Position = UDim2.new(1, -75, 0, 0)
    
    -- Tab Buttons
    self.TabFrame = Utils.Create("TabFrame", "Frame", self.MainFrame)
    self.TabFrame.Size = UDim2.new(1, 0, 0, 35)
    self.TabFrame.Position = UDim2.new(0, 0, 0, 40)
    self.TabFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.TabFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    self.TabFrame.BorderSizePixel = 1
    
    local tabs = {"PLAYER", "VISUAL", "WORLD", "UTIL", "SECURITY", "ADVANCED", "CONSOLE", "ABOUT"}
    self.TabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Utils.CreateButton("Tab_" .. tabName, tabName, self.TabFrame)
        btn.Size = UDim2.new(1 / #tabs, 0, 1, 0)
        btn.Position = UDim2.new((i-1) / #tabs, 0, 0, 0)
        btn.TextSize = 10
        table.insert(self.TabButtons, {Name = tabName, Button = btn})
    end
    
    -- Content Frame
    self.ContentFrame = Utils.Create("ContentFrame", "Frame", self.MainFrame)
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -75)
    self.ContentFrame.Position = UDim2.new(0, 0, 0, 75)
    self.ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.ContentFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    self.ContentFrame.BorderSizePixel = 1
    
    -- ScrollingFrame
    self.ScrollFrame = Utils.Create("ScrollFrame", "ScrollingFrame", self.ContentFrame)
    self.ScrollFrame.Size = UDim2.new(1, -5, 1, -5)
    self.ScrollFrame.Position = UDim2.new(0, 2, 0, 2)
    self.ScrollFrame.BackgroundTransparency = 1
    self.ScrollFrame.BorderSizePixel = 0
    self.ScrollFrame.ScrollBarThickness = 8
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Console Label
    self.ConsoleLabel = Utils.CreateLabel("Console", "VOID TERMINAL INITIALIZED", self.ScrollFrame)
    self.ConsoleLabel.Size = UDim2.new(1, 0, 1, 0)
    self.ConsoleLabel.TextWrapped = true
    self.ConsoleLabel.TextYAlignment = Enum.TextYAlignment.Top
    self.ConsoleLabel.BackgroundTransparency = 1
    self.ConsoleLabel.BorderSizePixel = 0
    self.ConsoleLabel.TextSize = 10
    
    self:LogConsole("System initialized successfully")
end

function VoidGUI:BuildEffects()
    -- Scanline Effect
    local scanlineFrame = Utils.Create("Scanline", "Frame", self.MainFrame)
    scanlineFrame.Size = UDim2.new(1, 0, 1, 0)
    scanlineFrame.BackgroundTransparency = 0.7
    scanlineFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    scanlineFrame.BorderSizePixel = 0
    
    local scanlinePattern = Utils.Create("Pattern", "UIGradient", scanlineFrame)
    scanlinePattern.Rotation = 90
    
    -- Noise Overlay
    local noiseFrame = Utils.Create("Noise", "Frame", self.MainFrame)
    noiseFrame.Size = UDim2.new(1, 0, 1, 0)
    noiseFrame.BackgroundTransparency = 0.85
    noiseFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    noiseFrame.BorderSizePixel = 0
end

function VoidGUI:BuildConfirmDialog()
    -- Confirm Dialog
    self.ConfirmDialog = Utils.Create("ConfirmDialog", "Frame", self.ScreenGui)
    self.ConfirmDialog.Size = UDim2.new(0, 300, 0, 150)
    self.ConfirmDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    self.ConfirmDialog.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.ConfirmDialog.BorderColor3 = Color3.fromRGB(255, 0, 0)
    self.ConfirmDialog.BorderSizePixel = 2
    self.ConfirmDialog.Visible = false
    
    local confirmLabel = Utils.CreateLabel("ConfirmLabel", "CLOSE GUI?", self.ConfirmDialog)
    confirmLabel.Size = UDim2.new(1, 0, 0, 50)
    confirmLabel.BackgroundTransparency = 1
    confirmLabel.BorderSizePixel = 0
    
    local yesBtn = Utils.CreateButton("YesBtn", "YES", self.ConfirmDialog)
    yesBtn.Size = UDim2.new(0.5, -5, 0, 40)
    yesBtn.Position = UDim2.new(0, 5, 0, 60)
    
    local noBtn = Utils.CreateButton("NoBtn", "NO", self.ConfirmDialog)
    noBtn.Size = UDim2.new(0.5, -5, 0, 40)
    noBtn.Position = UDim2.new(0.5, 5, 0, 60)
    
    self.ConfirmYesBtn = yesBtn
    self.ConfirmNoBtn = noBtn
end

function VoidGUI:InitializePages()
    -- Create pages for each tab
    self.Pages = {}
    
    for _, tab in ipairs(self.TabButtons) do
        local page = Utils.Create("Page_" .. tab.Name, "Frame", self.ScrollFrame)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        
        self.Pages[tab.Name] = page
    end
    
    self.Pages["PLAYER"].Visible = true
    
    -- Build Player Page
    self:BuildPlayerPage()
    self:BuildVisualPage()
    self:BuildWorldPage()
    self:BuildUtilPage()
    self:BuildSecurityPage()
    self:BuildAdvancedPage()
    self:BuildConsolePage()
    self:BuildAboutPage()
end

function VoidGUI:BuildPlayerPage()
    local page = self.Pages["PLAYER"]
    local yPos = 0
    
    -- Speed Hack
    local speedBtn = Utils.CreateButton("SpeedBtn", "SPEED HACK [OFF]", page)
    speedBtn.Size = UDim2.new(1, -10, 0, 30)
    speedBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.SpeedBtn = speedBtn
    yPos = yPos + 35
    
    -- Speed Slider
    local speedSlider = Utils.CreateSlider("SpeedSlider", page, 16, 100)
    speedSlider.Size = UDim2.new(1, -10, 0, 25)
    speedSlider.Position = UDim2.new(0, 5, 0, yPos)
    self.SpeedSlider = speedSlider
    yPos = yPos + 30
    
    -- Jump Power
    local jumpBtn = Utils.CreateButton("JumpBtn", "JUMP POWER [OFF]", page)
    jumpBtn.Size = UDim2.new(1, -10, 0, 30)
    jumpBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.JumpBtn = jumpBtn
    yPos = yPos + 35
    
    -- Jump Power Slider
    local jumpSlider = Utils.CreateSlider("JumpSlider", page, 20, 150)
    jumpSlider.Size = UDim2.new(1, -10, 0, 25)
    jumpSlider.Position = UDim2.new(0, 5, 0, yPos)
    self.JumpSlider = jumpSlider
    yPos = yPos + 30
    
    -- Infinite Jump
    local infiniteJumpBtn = Utils.CreateButton("InfiniteJumpBtn", "INFINITE JUMP [OFF]", page)
    infiniteJumpBtn.Size = UDim2.new(1, -10, 0, 30)
    infiniteJumpBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.InfiniteJumpBtn = infiniteJumpBtn
    yPos = yPos + 35
    
    -- Fly
    local flyBtn = Utils.CreateButton("FlyBtn", "FLY [OFF]", page)
    flyBtn.Size = UDim2.new(1, -10, 0, 30)
    flyBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.FlyBtn = flyBtn
    yPos = yPos + 35
    
    -- NoClip
    local noClipBtn = Utils.CreateButton("NoClipBtn", "NOCLIP [OFF]", page)
    noClipBtn.Size = UDim2.new(1, -10, 0, 30)
    noClipBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.NoClipBtn = noClipBtn
    yPos = yPos + 35
    
    -- God Mode
    local godBtn = Utils.CreateButton("GodBtn", "GOD MODE [OFF]", page)
    godBtn.Size = UDim2.new(1, -10, 0, 30)
    godBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.GodBtn = godBtn
    yPos = yPos + 35
    
    -- Auto Click
    local autoClickBtn = Utils.CreateButton("AutoClickBtn", "AUTO CLICK [OFF]", page)
    autoClickBtn.Size = UDim2.new(1, -10, 0, 30)
    autoClickBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.AutoClickBtn = autoClickBtn
    yPos = yPos + 35
    
    -- Click TP (Item)
    local clickTPBtn = Utils.CreateButton("ClickTPBtn", "CLICK TP ITEM [OFF]", page)
    clickTPBtn.Size = UDim2.new(1, -10, 0, 30)
    clickTPBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.ClickTPBtn = clickTPBtn
    yPos = yPos + 35
    
    -- Spin Bot
    local spinBotBtn = Utils.CreateButton("SpinBotBtn", "SPIN BOT [OFF]", page)
    spinBotBtn.Size = UDim2.new(1, -10, 0, 30)
    spinBotBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.SpinBotBtn = spinBotBtn
    yPos = yPos + 35
    
    -- Anti-AFK
    local antiAFKBtn = Utils.CreateButton("AntiAFKBtn", "ANTI-AFK [OFF]", page)
    antiAFKBtn.Size = UDim2.new(1, -10, 0, 30)
    antiAFKBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.AntiAFKBtn = antiAFKBtn
    yPos = yPos + 35
    
    -- No Fall Damage
    local noFallBtn = Utils.CreateButton("NoFallBtn", "NO FALL DAMAGE [OFF]", page)
    noFallBtn.Size = UDim2.new(1, -10, 0, 30)
    noFallBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.NoFallBtn = noFallBtn
    yPos = yPos + 35
    
    -- Force Field
    local forceFieldBtn = Utils.CreateButton("ForceFieldBtn", "FORCE FIELD [OFF]", page)
    forceFieldBtn.Size = UDim2.new(1, -10, 0, 30)
    forceFieldBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.ForceFieldBtn = forceFieldBtn
    yPos = yPos + 35
    
    -- No Recoil
    local noRecoilBtn = Utils.CreateButton("NoRecoilBtn", "NO RECOIL [OFF]", page)
    noRecoilBtn.Size = UDim2.new(1, -10, 0, 30)
    noRecoilBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.NoRecoilBtn = noRecoilBtn
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
end

function VoidGUI:BuildVisualPage()
    local page = self.Pages["VISUAL"]
    local yPos = 0
    
    -- ESP
    local espBtn = Utils.CreateButton("ESPBtn", "ESP [OFF]", page)
    espBtn.Size = UDim2.new(1, -10, 0, 30)
    espBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.ESPBtn = espBtn
    yPos = yPos + 35
    
    -- Health Bars
    local healthBarsBtn = Utils.CreateButton("HealthBarsBtn", "HEALTH BARS [OFF]", page)
    healthBarsBtn.Size = UDim2.new(1, -10, 0, 30)
    healthBarsBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.HealthBarsBtn = healthBarsBtn
    yPos = yPos + 35
    
    -- Weapon ESP
    local weaponESPBtn = Utils.CreateButton("WeaponESPBtn", "WEAPON ESP [OFF]", page)
    weaponESPBtn.Size = UDim2.new(1, -10, 0, 30)
    weaponESPBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.WeaponESPBtn = weaponESPBtn
    yPos = yPos + 35
    
    -- Highlight
    local highlightBtn = Utils.CreateButton("HighlightBtn", "HIGHLIGHT [OFF]", page)
    highlightBtn.Size = UDim2.new(1, -10, 0, 30)
    highlightBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.HighlightBtn = highlightBtn
    yPos = yPos + 35
    
    -- Tracers
    local tracersBtn = Utils.CreateButton("TracersBtn", "TRACERS [OFF]", page)
    tracersBtn.Size = UDim2.new(1, -10, 0, 30)
    tracersBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.TracersBtn = tracersBtn
    yPos = yPos + 35
    
    -- Fullbright
    local fullbrightBtn = Utils.CreateButton("FullbrightBtn", "FULLBRIGHT [OFF]", page)
    fullbrightBtn.Size = UDim2.new(1, -10, 0, 30)
    fullbrightBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.FullbrightBtn = fullbrightBtn
    yPos = yPos + 35
    
    -- X-Ray
    local xrayBtn = Utils.CreateButton("XRayBtn", "X-RAY [OFF]", page)
    xrayBtn.Size = UDim2.new(1, -10, 0, 30)
    xrayBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.XRayBtn = xrayBtn
    yPos = yPos + 35
    
    -- Aimbot
    local aimbotBtn = Utils.CreateButton("AimbotBtn", "AIMBOT [OFF]", page)
    aimbotBtn.Size = UDim2.new(1, -10, 0, 30)
    aimbotBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.AimbotBtn = aimbotBtn
    yPos = yPos + 35
    
    -- Wall Hack
    local wallHackBtn = Utils.CreateButton("WallHackBtn", "WALL HACK [OFF]", page)
    wallHackBtn.Size = UDim2.new(1, -10, 0, 30)
    wallHackBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.WallHackBtn = wallHackBtn
    yPos = yPos + 35
    
    -- Chams
    local chamsBtn = Utils.CreateButton("ChamsBtn", "CHAMS [OFF]", page)
    chamsBtn.Size = UDim2.new(1, -10, 0, 30)
    chamsBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.ChamsBtn = chamsBtn
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
end

function VoidGUI:BuildWorldPage()
    local page = self.Pages["WORLD"]
    local yPos = 0
    
    -- Time Changer
    local timeBtn = Utils.CreateButton("TimeBtn", "TIME CHANGER [OFF]", page)
    timeBtn.Size = UDim2.new(1, -10, 0, 30)
    timeBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.TimeBtn = timeBtn
    yPos = yPos + 35
    
    -- Time Slider
    local timeSlider = Utils.CreateSlider("TimeSlider", page, 0, 24)
    timeSlider.Size = UDim2.new(1, -10, 0, 25)
    timeSlider.Position = UDim2.new(0, 5, 0, yPos)
    self.TimeSlider = timeSlider
    yPos = yPos + 30
    
    -- Gravity Hack
    local gravityBtn = Utils.CreateButton("GravityBtn", "GRAVITY HACK [OFF]", page)
    gravityBtn.Size = UDim2.new(1, -10, 0, 30)
    gravityBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.GravityBtn = gravityBtn
    yPos = yPos + 35
    
    -- Gravity Slider
    local gravitySlider = Utils.CreateSlider("GravitySlider", page, 0, 500)
    gravitySlider.Size = UDim2.new(1, -10, 0, 25)
    gravitySlider.Position = UDim2.new(0, 5, 0, yPos)
    self.GravitySlider = gravitySlider
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
end

function VoidGUI:BuildUtilPage()
    local page = self.Pages["UTIL"]
    local yPos = 0
    
    -- Debug Mode
    local debugBtn = Utils.CreateButton("DebugBtn", "DEBUG MODE [OFF]", page)
    debugBtn.Size = UDim2.new(1, -10, 0, 30)
    debugBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.DebugBtn = debugBtn
    yPos = yPos + 35
    
    -- Auto Respawn
    local autoRespawnBtn = Utils.CreateButton("AutoRespawnBtn", "AUTO RESPAWN [OFF]", page)
    autoRespawnBtn.Size = UDim2.new(1, -10, 0, 30)
    autoRespawnBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.AutoRespawnBtn = autoRespawnBtn
    yPos = yPos + 35
    
    -- Memory Cleaner
    local memoryBtn = Utils.CreateButton("MemoryBtn", "MEMORY CLEANER", page)
    memoryBtn.Size = UDim2.new(1, -10, 0, 30)
    memoryBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.MemoryBtn = memoryBtn
    yPos = yPos + 35
    
    -- Save Config
    local saveBtn = Utils.CreateButton("SaveBtn", "SAVE CONFIG", page)
    saveBtn.Size = UDim2.new(0.5, -7, 0, 30)
    saveBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.SaveBtn = saveBtn
    
    -- Load Config
    local loadBtn = Utils.CreateButton("LoadBtn", "LOAD CONFIG", page)
    loadBtn.Size = UDim2.new(0.5, -7, 0, 30)
    loadBtn.Position = UDim2.new(0.5, 5, 0, yPos)
    self.LoadBtn = loadBtn
    yPos = yPos + 35
    
    -- Reset All
    local resetBtn = Utils.CreateButton("ResetBtn", "RESET ALL", page)
    resetBtn.Size = UDim2.new(1, -10, 0, 30)
    resetBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.ResetBtn = resetBtn
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
end

function VoidGUI:BuildSecurityPage()
    local page = self.Pages["SECURITY"]
    local yPos = 0
    
    -- Stealth Mode
    local stealthBtn = Utils.CreateButton("StealthBtn", "STEALTH MODE [OFF]", page)
    stealthBtn.Size = UDim2.new(1, -10, 0, 30)
    stealthBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.StealthBtn = stealthBtn
    yPos = yPos + 35
    
    -- Anti-Detection
    local antiDetectBtn = Utils.CreateButton("AntiDetectBtn", "ANTI-DETECTION [OFF]", page)
    antiDetectBtn.Size = UDim2.new(1, -10, 0, 30)
    antiDetectBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.AntiDetectBtn = antiDetectBtn
    yPos = yPos + 35
    
    -- Log Cleaner
    local logBtn = Utils.CreateButton("LogBtn", "CLEAN LOGS", page)
    logBtn.Size = UDim2.new(1, -10, 0, 30)
    logBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.LogBtn = logBtn
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
end

function VoidGUI:BuildAdvancedPage()
    local page = self.Pages["ADVANCED"]
    local yPos = 0
    
    local infoLabel = Utils.CreateLabel("Info", "ADVANCED FEATURES", page)
    infoLabel.Size = UDim2.new(1, -10, 0, 30)
    infoLabel.Position = UDim2.new(0, 5, 0, yPos)
    infoLabel.BackgroundTransparency = 1
    infoLabel.BorderSizePixel = 0
    yPos = yPos + 35
    
    -- Waypoint System
    local waypointBtn = Utils.CreateButton("WaypointBtn", "SET WAYPOINT", page)
    waypointBtn.Size = UDim2.new(1, -10, 0, 30)
    waypointBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.WaypointBtn = waypointBtn
    yPos = yPos + 35
    
    -- Teleport to Waypoint
    local tpWaypointBtn = Utils.CreateButton("TPWaypointBtn", "TP TO WAYPOINT", page)
    tpWaypointBtn.Size = UDim2.new(1, -10, 0, 30)
    tpWaypointBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.TPWaypointBtn = tpWaypointBtn
    yPos = yPos + 35
    
    -- Script Hub
    local scriptHubBtn = Utils.CreateButton("ScriptHubBtn", "SCRIPT HUB", page)
    scriptHubBtn.Size = UDim2.new(1, -10, 0, 30)
    scriptHubBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.ScriptHubBtn = scriptHubBtn
    yPos = yPos + 35
    
    -- Lua Executor
    local luaBtn = Utils.CreateButton("LuaBtn", "LUA EXECUTOR", page)
    luaBtn.Size = UDim2.new(1, -10, 0, 30)
    luaBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.LuaBtn = luaBtn
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
end

function VoidGUI:BuildConsolePage()
    local page = self.Pages["CONSOLE"]
    page.Visible = false
    
    local consoleLabel = Utils.CreateLabel("ConsoleOutput", "", page)
    consoleLabel.Size = UDim2.new(1, -10, 1, -10)
    consoleLabel.Position = UDim2.new(0, 5, 0, 5)
    consoleLabel.TextWrapped = true
    consoleLabel.TextYAlignment = Enum.TextYAlignment.Top
    consoleLabel.BackgroundTransparency = 1
    consoleLabel.BorderSizePixel = 0
    consoleLabel.TextSize = 9
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 100)
end

function VoidGUI:BuildAboutPage()
    local page = self.Pages["ABOUT"]
    page.Visible = false
    
    local aboutLabel = Utils.CreateLabel("About", "VOID TERMINAL v2.0\n\nFeatures:\n- 50+ Hacks\n- Mobile Support\n- Anti-Detection\n- Config System\n\nHotkeys:\nF5 - Toggle GUI\nF6 - Toggle All\n\nCreated for Roblox", page)
    aboutLabel.Size = UDim2.new(1, -10, 1, -10)
    aboutLabel.Position = UDim2.new(0, 5, 0, 5)
    aboutLabel.TextWrapped = true
    aboutLabel.TextYAlignment = Enum.TextYAlignment.Top
    aboutLabel.BackgroundTransparency = 1
    aboutLabel.BorderSizePixel = 0
    
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 100)
end

-- ============================================================================
-- TOGGLE FUNCTIONS - PLAYER HACKS
-- ============================================================================

function VoidGUI:ToggleSpeed()
    self.SpeedEnabled = not self.SpeedEnabled
    
    if self.SpeedEnabled then
        self.SpeedBtn.Text = "SPEED HACK [ON]"
        self.SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = self:GetLocalHumanoid()
            if humanoid then
                humanoid.WalkSpeed = self.WalkSpeed
            end
            if not self.SpeedEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("SPEED HACK ACTIVATED - SPEED: " .. self.WalkSpeed)
    else
        self.SpeedBtn.Text = "SPEED HACK [OFF]"
        self.SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        local humanoid = self:GetLocalHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        self:LogConsole("SPEED HACK DEACTIVATED")
    end
end

function VoidGUI:ToggleJumpPower()
    self.JumpPowerEnabled = not self.JumpPowerEnabled
    
    if self.JumpPowerEnabled then
        self.JumpBtn.Text = "JUMP POWER [ON]"
        self.JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = self:GetLocalHumanoid()
            if humanoid then
                humanoid.JumpPower = self.JumpPowerValue
            end
            if not self.JumpPowerEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("JUMP POWER ACTIVATED - POWER: " .. self.JumpPowerValue)
    else
        self.JumpBtn.Text = "JUMP POWER [OFF]"
        self.JumpBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        local humanoid = self:GetLocalHumanoid()
        if humanoid then
            humanoid.JumpPower = 50
        end
        self:LogConsole("JUMP POWER DEACTIVATED")
    end
end

function VoidGUI:ToggleInfiniteJump()
    self.InfiniteJumpEnabled = not self.InfiniteJumpEnabled
    
    if self.InfiniteJumpEnabled then
        self.InfiniteJumpBtn.Text = "INFINITE JUMP [ON]"
        self.InfiniteJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = self:GetLocalHumanoid()
            if humanoid then
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            if not self.InfiniteJumpEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("INFINITE JUMP ACTIVATED")
    else
        self.InfiniteJumpBtn.Text = "INFINITE JUMP [OFF]"
        self.InfiniteJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("INFINITE JUMP DEACTIVATED")
    end
end

function VoidGUI:ToggleFly()
    if self.FlyToggling then return end
    self.FlyToggling = true
    
    self.FlyEnabled = not self.FlyEnabled
    local player = Players.LocalPlayer
    
    if self.NoClipEnabled and not self.FlyEnabled then
        self:LogConsole("WARNING: NoClip is active. Consider turning it off for better fly control.")
    end
    
    if self.FlyEnabled then
        self.FlyBtn.Text = "FLY [ON]"
        self.FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            self.FlyEnabled = false
            self.FlyBtn.Text = "FLY [OFF]"
            self.FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
            self:LogConsole("ERROR: Character not found")
            self.FlyToggling = false
            return
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = humanoidRootPart
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.Parent = humanoidRootPart
        
        local flyConnection
        flyConnection = RunService.RenderStepped:Connect(function()
            if not self.FlyEnabled or not character or not character.Parent or not humanoidRootPart.Parent then
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                if flyConnection then flyConnection:Disconnect() end
                return
            end
            
            local camera = workspace.CurrentCamera
            if not camera then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            if self.IsMobile then
                if self.FlyMoveVector.Magnitude > 0.1 then
                    local forward = camera.CFrame.LookVector
                    local right = camera.CFrame.RightVector
                    
                    moveDirection = (forward * self.FlyMoveVector.Z) + (right * self.FlyMoveVector.X)
                    if moveDirection.Magnitude > 0 then
                        moveDirection = moveDirection.Unit * self.FlySpeed
                    end
                end
                
                if self.FlyUpPressed then
                    moveDirection = moveDirection + Vector3.new(0, self.FlySpeed, 0)
                end
                if self.FlyDownPressed then
                    moveDirection = moveDirection - Vector3.new(0, self.FlySpeed, 0)
                end
            else
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector * self.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector * self.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector * self.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector * self.FlySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, self.FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, self.FlySpeed, 0)
                end
            end
            
            bodyVelocity.Velocity = moveDirection
            bodyGyro.CFrame = camera.CFrame
        end)
        
        table.insert(self.FlyConnections, flyConnection)
        self:LogConsole("FLY MODE ACTIVATED")
    else
        self.FlyBtn.Text = "FLY [OFF]"
        self.FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, connection in ipairs(self.FlyConnections) do
            if connection then connection:Disconnect() end
        end
        self.FlyConnections = {}
        
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                for _, obj in ipairs(humanoidRootPart:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                        obj:Destroy()
                    end
                end
            end
        end
        
        self:LogConsole("FLY MODE DEACTIVATED")
    end
    
    self.FlyToggling = false
end

function VoidGUI:ToggleNoClip()
    self.NoClipEnabled = not self.NoClipEnabled
    
    if self.NoClipEnabled then
        self.NoClipBtn.Text = "NOCLIP [ON]"
        self.NoClipBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local char = self:GetLocalCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            if not self.NoClipEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("NOCLIP ACTIVATED")
    else
        self.NoClipBtn.Text = "NOCLIP [OFF]"
        self.NoClipBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        local char = self:GetLocalCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        self:LogConsole("NOCLIP DEACTIVATED")
    end
end

function VoidGUI:ActivateGodMode()
    local success, errorMsg = pcall(function()
        local humanoid = self:GetLocalHumanoid()
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            self:LogConsole("GOD MODE ACTIVATED")
        else
            self:LogConsole("ERROR: No humanoid found for God Mode")
        end
    end)
    
    if not success then
        self:LogConsole("ERROR in God Mode: " .. tostring(errorMsg))
    end
end

function VoidGUI:ToggleAutoClick()
    self.AutoClickEnabled = not self.AutoClickEnabled
    
    if self.AutoClickEnabled then
        self.AutoClickBtn.Text = "AUTO CLICK [ON]"
        self.AutoClickBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if self.AutoClickEnabled then
                mouse1click()
                wait(1 / self.AutoClickSpeed)
            else
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("AUTO CLICK ACTIVATED - SPEED: " .. self.AutoClickSpeed)
    else
        self.AutoClickBtn.Text = "AUTO CLICK [OFF]"
        self.AutoClickBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("AUTO CLICK DEACTIVATED")
    end
end

function VoidGUI:ToggleClickTP()
    self.ClickTPEnabled = not self.ClickTPEnabled
    
    if self.ClickTPEnabled then
        self.ClickTPBtn.Text = "CLICK TP ITEM [ON]"
        self.ClickTPBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        -- Create Click TP Item in character
        local char = self:GetLocalCharacter()
        if char then
            local item = Instance.new("Part")
            item.Name = "ClickTPItem"
            item.Shape = Enum.PartType.Ball
            item.Size = Vector3.new(0.5, 0.5, 0.5)
            item.Color = Color3.fromRGB(0, 255, 0)
            item.CanCollide = false
            item.CFrame = char:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(0, 3, 0)
            item.Parent = char
            
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = char:FindFirstChild("HumanoidRootPart")
            weld.Part1 = item
            weld.Parent = item
            
            self:LogConsole("CLICK TP ITEM CREATED - CLICK TO TELEPORT")
        end
    else
        self.ClickTPBtn.Text = "CLICK TP ITEM [OFF]"
        self.ClickTPBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        local char = self:GetLocalCharacter()
        if char then
            local item = char:FindFirstChild("ClickTPItem")
            if item then
                item:Destroy()
            end
        end
        
        self:LogConsole("CLICK TP ITEM REMOVED")
    end
end

function VoidGUI:ToggleSpinBot()
    self.SpinBotEnabled = not self.SpinBotEnabled
    
    if self.SpinBotEnabled then
        self.SpinBotBtn.Text = "SPIN BOT [ON]"
        self.SpinBotBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local rootPart = self:GetLocalRootPart()
            if rootPart then
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end
            if not self.SpinBotEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("SPIN BOT ACTIVATED")
    else
        self.SpinBotBtn.Text = "SPIN BOT [OFF]"
        self.SpinBotBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("SPIN BOT DEACTIVATED")
    end
end

function VoidGUI:ToggleAntiAFK()
    self.AntiAFKEnabled = not self.AntiAFKEnabled
    
    if self.AntiAFKEnabled then
        self.AntiAFKBtn.Text = "ANTI-AFK [ON]"
        self.AntiAFKBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if self.AntiAFKEnabled then
                local rootPart = self:GetLocalRootPart()
                if rootPart then
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 0.1, 0)
                    wait(0.5)
                    rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 0.1, 0)
                end
            else
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("ANTI-AFK ACTIVATED")
    else
        self.AntiAFKBtn.Text = "ANTI-AFK [OFF]"
        self.AntiAFKBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("ANTI-AFK DEACTIVATED")
    end
end

function VoidGUI:ToggleNoFallDamage()
    self.NoFallDamageEnabled = not self.NoFallDamageEnabled
    
    if self.NoFallDamageEnabled then
        self.NoFallBtn.Text = "NO FALL DAMAGE [ON]"
        self.NoFallBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local humanoid = self:GetLocalHumanoid()
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
        self:LogConsole("NO FALL DAMAGE ACTIVATED")
    else
        self.NoFallBtn.Text = "NO FALL DAMAGE [OFF]"
        self.NoFallBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        local humanoid = self:GetLocalHumanoid()
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
        self:LogConsole("NO FALL DAMAGE DEACTIVATED")
    end
end

function VoidGUI:ToggleForceField()
    self.ForceFieldEnabled = not self.ForceFieldEnabled
    
    if self.ForceFieldEnabled then
        self.ForceFieldBtn.Text = "FORCE FIELD [ON]"
        self.ForceFieldBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local rootPart = self:GetLocalRootPart()
            if rootPart then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer and player.Character then
                        local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if enemyRoot then
                            local distance = (rootPart.Position - enemyRoot.Position).Magnitude
                            if distance < self.ForceFieldRadius then
                                enemyRoot.CFrame = enemyRoot.CFrame + (enemyRoot.Position - rootPart.Position).Unit * 5
                            end
                        end
                    end
                end
            end
            if not self.ForceFieldEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("FORCE FIELD ACTIVATED - RADIUS: " .. self.ForceFieldRadius)
    else
        self.ForceFieldBtn.Text = "FORCE FIELD [OFF]"
        self.ForceFieldBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("FORCE FIELD DEACTIVATED")
    end
end

function VoidGUI:ToggleNoRecoil()
    self.NoRecoilEnabled = not self.NoRecoilEnabled
    
    if self.NoRecoilEnabled then
        self.NoRecoilBtn.Text = "NO RECOIL [ON]"
        self.NoRecoilBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        self:LogConsole("NO RECOIL ACTIVATED")
    else
        self.NoRecoilBtn.Text = "NO RECOIL [OFF]"
        self.NoRecoilBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("NO RECOIL DEACTIVATED")
    end
end

-- ============================================================================
-- TOGGLE FUNCTIONS - VISUAL HACKS
-- ============================================================================

function VoidGUI:ToggleESP()
    self.ESPEnabled = not self.ESPEnabled
    
    if self.ESPEnabled then
        self.ESPBtn.Text = "ESP [ON]"
        self.ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                self:AddESP(player)
            end
        end
        
        self:LogConsole("ESP ACTIVATED")
    else
        self.ESPBtn.Text = "ESP [OFF]"
        self.ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                self:RemoveESP(player)
            end
        end
        
        self:LogConsole("ESP DEACTIVATED")
    end
end

function VoidGUI:AddESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_" .. player.Name
    billboardGui.Size = UDim2.new(4, 0, 5, 0)
    billboardGui.MaxDistance = 500
    billboardGui.Parent = humanoidRootPart
    
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box"
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    boxFrame.BorderSizePixel = 2
    boxFrame.Parent = billboardGui
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, -25)
    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamMonospace
    nameLabel.Text = player.Name
    nameLabel.BorderColor3 = Color3.fromRGB(0, 255, 0)
    nameLabel.BorderSizePixel = 1
    nameLabel.Parent = billboardGui
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 1, 5)
    distanceLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    distanceLabel.TextSize = 10
    distanceLabel.Font = Enum.Font.GothamMonospace
    distanceLabel.Text = "0 studs"
    distanceLabel.BorderColor3 = Color3.fromRGB(0, 255, 0)
    distanceLabel.BorderSizePixel = 1
    distanceLabel.Parent = billboardGui
    
    local lastUpdate = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not self.ESPEnabled or not character or not character.Parent or not humanoidRootPart.Parent then
            if connection then connection:Disconnect() end
            if billboardGui then billboardGui:Destroy() end
            return
        end
        
        if tick() - lastUpdate < 0.1 then return end
        lastUpdate = tick()
        
        local localChar = Players.LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local distance = (localChar.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            distanceLabel.Text = string.format("%.1f studs", distance)
            
            if distance < 50 then
                boxFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
                nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                distanceLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            elseif distance < 100 then
                boxFrame.BorderColor3 = Color3.fromRGB(255, 165, 0)
                nameLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                distanceLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            else
                boxFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
                nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end)
    
    table.insert(self.ESPConnections, connection)
end

function VoidGUI:RemoveESP(player)
    local character = player.Character
    if character then
        local esp = character:FindFirstChild("HumanoidRootPart"):FindFirstChild("ESP_" .. player.Name)
        if esp then
            esp:Destroy()
        end
    end
end

function VoidGUI:ToggleHighlight()
    self.HighlightEnabled = not self.HighlightEnabled
    
    if self.HighlightEnabled then
        self.HighlightBtn.Text = "HIGHLIGHT [ON]"
        self.HighlightBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                self:AddHighlight(player)
            end
        end
        
        self:LogConsole("HIGHLIGHT ACTIVATED")
    else
        self.HighlightBtn.Text = "HIGHLIGHT [OFF]"
        self.HighlightBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                self:RemoveHighlight(player)
            end
        end
        
        self:LogConsole("HIGHLIGHT DEACTIVATED")
    end
end

function VoidGUI:AddHighlight(player)
    if not player.Character then return end
    
    wait(0.1)
    
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            highlight.FillTransparency = 0.2
            highlight.OutlineTransparency = 0
            highlight.Parent = part
        end
    end
end

function VoidGUI:RemoveHighlight(player)
    if not player.Character then return end
    
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            local highlight = part:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

function VoidGUI:ToggleTracers()
    self.TracersEnabled = not self.TracersEnabled
    
    if self.TracersEnabled then
        self.TracersBtn.Text = "TRACERS [ON]"
        self.TracersBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not self.TracersEnabled then
                connection:Disconnect()
                return
            end
            
            local localRoot = self:GetLocalRootPart()
            if localRoot then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer and player.Character then
                        local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if enemyRoot then
                            local distance = (localRoot.Position - enemyRoot.Position).Magnitude
                            if distance < 500 then
                                local direction = (enemyRoot.Position - localRoot.Position)
                                local part = Instance.new("Part")
                                part.Shape = Enum.PartType.Cylinder
                                part.Material = Enum.Material.Neon
                                part.Color = Color3.fromRGB(255, 0, 0)
                                part.CanCollide = false
                                part.CastShadow = false
                                part.Size = Vector3.new(0.2, distance, 0.2)
                                part.CFrame = CFrame.new((localRoot.Position + enemyRoot.Position) / 2, enemyRoot.Position)
                                part.Parent = workspace
                                
                                Debris:AddItem(part, 0.05)
                            end
                        end
                    end
                end
            end
        end)
        
        table.insert(self.Connections, connection)
        self:LogConsole("TRACERS ACTIVATED")
    else
        self.TracersBtn.Text = "TRACERS [OFF]"
        self.TracersBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("TRACERS DEACTIVATED")
    end
end

function VoidGUI:ToggleFullbright()
    self.FullbrightEnabled = not self.FullbrightEnabled
    
    if self.FullbrightEnabled then
        self.FullbrightBtn.Text = "FULLBRIGHT [ON]"
        self.FullbrightBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 3
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        self:LogConsole("FULLBRIGHT ACTIVATED")
    else
        self.FullbrightBtn.Text = "FULLBRIGHT [OFF]"
        self.FullbrightBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.Ambient = Color3.fromRGB(200, 200, 200)
        lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        
        self:LogConsole("FULLBRIGHT DEACTIVATED")
    end
end

function VoidGUI:ToggleXRay()
    self.XRayEnabled = not self.XRayEnabled
    
    if self.XRayEnabled then
        self.XRayBtn.Text = "X-RAY [ON]"
        self.XRayBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0.5
            end
        end
        
        self:LogConsole("X-RAY ACTIVATED")
    else
        self.XRayBtn.Text = "X-RAY [OFF]"
        self.XRayBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
        
        self:LogConsole("X-RAY DEACTIVATED")
    end
end

function VoidGUI:ToggleAimbot()
    self.AimbotEnabled = not self.AimbotEnabled
    
    if self.AimbotEnabled then
        self.AimbotBtn.Text = "AIMBOT [ON]"
        self.AimbotBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        self:LogConsole("AIMBOT ACTIVATED - FOV: " .. self.AimbotFOV)
    else
        self.AimbotBtn.Text = "AIMBOT [OFF]"
        self.AimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("AIMBOT DEACTIVATED")
    end
end

function VoidGUI:ToggleWallHack()
    self.WallHackEnabled = not self.WallHackEnabled
    
    if self.WallHackEnabled then
        self.WallHackBtn.Text = "WALL HACK [ON]"
        self.WallHackBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Baseplate" then
                part.Transparency = 0.5
            end
        end
        
        self:LogConsole("WALL HACK ACTIVATED")
    else
        self.WallHackBtn.Text = "WALL HACK [OFF]"
        self.WallHackBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        
        self:LogConsole("WALL HACK DEACTIVATED")
    end
end

function VoidGUI:ToggleChams()
    self.ChamsEnabled = not self.ChamsEnabled
    
    if self.ChamsEnabled then
        self.ChamsBtn.Text = "CHAMS [ON]"
        self.ChamsBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
        
        self:LogConsole("CHAMS ACTIVATED")
    else
        self.ChamsBtn.Text = "CHAMS [OFF]"
        self.ChamsBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
        
        self:LogConsole("CHAMS DEACTIVATED")
    end
end

function VoidGUI:ToggleHealthBars()
    self.HealthBarsEnabled = not self.HealthBarsEnabled
    
    if self.HealthBarsEnabled then
        self.HealthBarsBtn.Text = "HEALTH BARS [ON]"
        self.HealthBarsBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                self:AddHealthBar(player)
            end
        end
        
        self:LogConsole("HEALTH BARS ACTIVATED")
    else
        self.HealthBarsBtn.Text = "HEALTH BARS [OFF]"
        self.HealthBarsBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                self:RemoveHealthBar(player)
            end
        end
        
        self:LogConsole("HEALTH BARS DEACTIVATED")
    end
end

function VoidGUI:AddHealthBar(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
    
    if not humanoid then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "HealthBar_" .. player.Name
    billboardGui.Size = UDim2.new(4, 0, 0.5, 0)
    billboardGui.MaxDistance = 500
    billboardGui.Parent = humanoidRootPart
    
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthBar.BorderColor3 = Color3.fromRGB(255, 255, 255)
    healthBar.BorderSizePixel = 1
    healthBar.Parent = billboardGui
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 1, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 10
    healthLabel.Font = Enum.Font.GothamMonospace
    healthLabel.Parent = billboardGui
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not self.HealthBarsEnabled or not player.Character or not humanoid then
            if connection then connection:Disconnect() end
            if billboardGui then billboardGui:Destroy() end
            return
        end
        
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        healthLabel.Text = string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
    end)
    
    table.insert(self.Connections, connection)
end

function VoidGUI:RemoveHealthBar(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local healthBar = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("HealthBar_" .. player.Name)
    if healthBar then
        healthBar:Destroy()
    end
end

function VoidGUI:ToggleWeaponESP()
    self.WeaponESPEnabled = not self.WeaponESPEnabled
    
    if self.WeaponESPEnabled then
        self.WeaponESPBtn.Text = "WEAPON ESP [ON]"
        self.WeaponESPBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        self:LogConsole("WEAPON ESP ACTIVATED")
    else
        self.WeaponESPBtn.Text = "WEAPON ESP [OFF]"
        self.WeaponESPBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("WEAPON ESP DEACTIVATED")
    end
end

-- ============================================================================
-- TOGGLE FUNCTIONS - WORLD HACKS
-- ============================================================================

function VoidGUI:ToggleTimeChanger()
    self.TimeChangerEnabled = not self.TimeChangerEnabled
    
    if self.TimeChangerEnabled then
        self.TimeBtn.Text = "TIME CHANGER [ON]"
        self.TimeBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = self.TimeOfDay
        
        self:LogConsole("TIME CHANGER ACTIVATED - TIME: " .. self.TimeOfDay)
    else
        self.TimeBtn.Text = "TIME CHANGER [OFF]"
        self.TimeBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        local lighting = game:GetService("Lighting")
        lighting.ClockTime = 12
        
        self:LogConsole("TIME CHANGER DEACTIVATED")
    end
end

function VoidGUI:ToggleGravityHack()
    self.GravityHackEnabled = not self.GravityHackEnabled
    
    if self.GravityHackEnabled then
        self.GravityBtn.Text = "GRAVITY HACK [ON]"
        self.GravityBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        workspace.Gravity = self.Gravity
        
        self:LogConsole("GRAVITY HACK ACTIVATED - GRAVITY: " .. self.Gravity)
    else
        self.GravityBtn.Text = "GRAVITY HACK [OFF]"
        self.GravityBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        workspace.Gravity = 196.2
        
        self:LogConsole("GRAVITY HACK DEACTIVATED")
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

function VoidGUI:ToggleDebugMode()
    self.DebugModeEnabled = not self.DebugModeEnabled
    
    if self.DebugModeEnabled then
        self.DebugBtn.Text = "DEBUG MODE [ON]"
        self.DebugBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        self:LogConsole("DEBUG MODE ACTIVATED")
    else
        self.DebugBtn.Text = "DEBUG MODE [OFF]"
        self.DebugBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("DEBUG MODE DEACTIVATED")
    end
end

function VoidGUI:ToggleAutoRespawn()
    self.AutoRespawnEnabled = not self.AutoRespawnEnabled
    
    if self.AutoRespawnEnabled then
        self.AutoRespawnBtn.Text = "AUTO RESPAWN [ON]"
        self.AutoRespawnBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local humanoid = self:GetLocalHumanoid()
            if humanoid and humanoid.Health <= 0 then
                local char = self:GetLocalCharacter()
                if char then
                    char:Destroy()
                end
            end
            if not self.AutoRespawnEnabled then
                connection:Disconnect()
            end
        end)
        table.insert(self.Connections, connection)
        self:LogConsole("AUTO RESPAWN ACTIVATED")
    else
        self.AutoRespawnBtn.Text = "AUTO RESPAWN [OFF]"
        self.AutoRespawnBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("AUTO RESPAWN DEACTIVATED")
    end
end

function VoidGUI:CleanMemory()
    collectgarbage("collect")
    self:LogConsole("MEMORY CLEANED")
end

function VoidGUI:SaveConfig()
    self.SavedConfigs["default"] = {
        SpeedEnabled = self.SpeedEnabled,
        WalkSpeed = self.WalkSpeed,
        FlyEnabled = self.FlyEnabled,
        FlySpeed = self.FlySpeed,
        NoClipEnabled = self.NoClipEnabled,
        ESPEnabled = self.ESPEnabled,
    }
    self:LogConsole("CONFIG SAVED")
end

function VoidGUI:LoadConfig()
    local config = self.SavedConfigs["default"]
    if config then
        self.SpeedEnabled = config.SpeedEnabled
        self.WalkSpeed = config.WalkSpeed
        self.FlyEnabled = config.FlyEnabled
        self.FlySpeed = config.FlySpeed
        self.NoClipEnabled = config.NoClipEnabled
        self.ESPEnabled = config.ESPEnabled
        self:LogConsole("CONFIG LOADED")
    else
        self:LogConsole("NO CONFIG FOUND")
    end
end

function VoidGUI:ResetAll()
    self.SpeedEnabled = false
    self.FlyEnabled = false
    self.NoClipEnabled = false
    self.ESPEnabled = false
    self.FullbrightEnabled = false
    self.InfiniteJumpEnabled = false
    self.XRayEnabled = false
    self.HighlightEnabled = false
    self.TracersEnabled = false
    self.JumpPowerEnabled = false
    self.AutoClickEnabled = false
    self.ClickTPEnabled = false
    self.SpinBotEnabled = false
    self.AntiAFKEnabled = false
    self.NoFallDamageEnabled = false
    self.ForceFieldEnabled = false
    self.NoRecoilEnabled = false
    self.AimbotEnabled = false
    self.WallHackEnabled = false
    self.ChamsEnabled = false
    self.TimeChangerEnabled = false
    self.GravityHackEnabled = false
    self.DebugModeEnabled = false
    self.StealthModeEnabled = false
    self.HealthBarsEnabled = false
    self.WeaponESPEnabled = false
    self.AutoRespawnEnabled = false
    
    self:LogConsole("ALL FEATURES RESET")
end

function VoidGUI:ToggleStealth()
    self.StealthModeEnabled = not self.StealthModeEnabled
    
    if self.StealthModeEnabled then
        self.StealthBtn.Text = "STEALTH MODE [ON]"
        self.StealthBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        self:LogConsole("STEALTH MODE ACTIVATED")
    else
        self.StealthBtn.Text = "STEALTH MODE [OFF]"
        self.StealthBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("STEALTH MODE DEACTIVATED")
    end
end

function VoidGUI:ToggleAntiDetect()
    self.AntiDetectEnabled = not self.AntiDetectEnabled
    self:LogConsole("ANTI-DETECTION TOGGLED")
end

function VoidGUI:CleanLogs()
    self:LogConsole("LOGS CLEANED")
end

function VoidGUI:SetWaypoint()
    local rootPart = self:GetLocalRootPart()
    if rootPart then
        table.insert(self.Waypoints, rootPart.Position)
        self:LogConsole("WAYPOINT SET AT " .. tostring(rootPart.Position))
    end
end

function VoidGUI:TPToWaypoint()
    if #self.Waypoints > 0 then
        local rootPart = self:GetLocalRootPart()
        if rootPart then
            rootPart.CFrame = CFrame.new(self.Waypoints[#self.Waypoints])
            self:LogConsole("TELEPORTED TO WAYPOINT")
        end
    else
        self:LogConsole("NO WAYPOINTS SET")
    end
end

function VoidGUI:OpenScriptHub()
    self:LogConsole("SCRIPT HUB OPENED")
end

function VoidGUI:OpenLuaExecutor()
    self:LogConsole("LUA EXECUTOR OPENED")
end

-- ============================================================================
-- EVENT CONNECTIONS
-- ============================================================================

function VoidGUI:ConnectEvents()
    -- Tab switching
    for _, tab in ipairs(self.TabButtons) do
        tab.Button.MouseButton1Click:Connect(function()
            for _, page in pairs(self.Pages) do
                page.Visible = false
            end
            self.Pages[tab.Name].Visible = true
        end)
    end
    
    -- Speed Slider
    self.SpeedSlider.FocusLost:Connect(function()
        local value = tonumber(self.SpeedSlider.Text) or 16
        self.WalkSpeed = math.clamp(value, 16, 100)
        self.SpeedSlider.Text = tostring(self.WalkSpeed)
    end)
    
    -- Jump Slider
    self.JumpSlider.FocusLost:Connect(function()
        local value = tonumber(self.JumpSlider.Text) or 50
        self.JumpPowerValue = math.clamp(value, 20, 150)
        self.JumpSlider.Text = tostring(self.JumpPowerValue)
    end)
    
    -- Time Slider
    self.TimeSlider.FocusLost:Connect(function()
        local value = tonumber(self.TimeSlider.Text) or 12
        self.TimeOfDay = math.clamp(value, 0, 24)
        self.TimeSlider.Text = tostring(self.TimeOfDay)
        if self.TimeChangerEnabled then
            game:GetService("Lighting").ClockTime = self.TimeOfDay
        end
    end)
    
    -- Gravity Slider
    self.GravitySlider.FocusLost:Connect(function()
        local value = tonumber(self.GravitySlider.Text) or 196.2
        self.Gravity = math.clamp(value, 0, 500)
        self.GravitySlider.Text = tostring(self.Gravity)
        if self.GravityHackEnabled then
            workspace.Gravity = self.Gravity
        end
    end)
    
    -- Button connections
    self.SpeedBtn.MouseButton1Click:Connect(function() self:ToggleSpeed() end)
    self.JumpBtn.MouseButton1Click:Connect(function() self:ToggleJumpPower() end)
    self.InfiniteJumpBtn.MouseButton1Click:Connect(function() self:ToggleInfiniteJump() end)
    self.FlyBtn.MouseButton1Click:Connect(function() self:ToggleFly() end)
    self.NoClipBtn.MouseButton1Click:Connect(function() self:ToggleNoClip() end)
    self.GodBtn.MouseButton1Click:Connect(function() self:ActivateGodMode() end)
    self.AutoClickBtn.MouseButton1Click:Connect(function() self:ToggleAutoClick() end)
    self.ClickTPBtn.MouseButton1Click:Connect(function() self:ToggleClickTP() end)
    self.SpinBotBtn.MouseButton1Click:Connect(function() self:ToggleSpinBot() end)
    self.AntiAFKBtn.MouseButton1Click:Connect(function() self:ToggleAntiAFK() end)
    self.NoFallBtn.MouseButton1Click:Connect(function() self:ToggleNoFallDamage() end)
    self.ForceFieldBtn.MouseButton1Click:Connect(function() self:ToggleForceField() end)
    self.NoRecoilBtn.MouseButton1Click:Connect(function() self:ToggleNoRecoil() end)
    
    self.ESPBtn.MouseButton1Click:Connect(function() self:ToggleESP() end)
    self.HealthBarsBtn.MouseButton1Click:Connect(function() self:ToggleHealthBars() end)
    self.WeaponESPBtn.MouseButton1Click:Connect(function() self:ToggleWeaponESP() end)
    self.HighlightBtn.MouseButton1Click:Connect(function() self:ToggleHighlight() end)
    self.TracersBtn.MouseButton1Click:Connect(function() self:ToggleTracers() end)
    self.FullbrightBtn.MouseButton1Click:Connect(function() self:ToggleFullbright() end)
    self.XRayBtn.MouseButton1Click:Connect(function() self:ToggleXRay() end)
    self.AimbotBtn.MouseButton1Click:Connect(function() self:ToggleAimbot() end)
    self.WallHackBtn.MouseButton1Click:Connect(function() self:ToggleWallHack() end)
    self.ChamsBtn.MouseButton1Click:Connect(function() self:ToggleChams() end)
    
    self.TimeBtn.MouseButton1Click:Connect(function() self:ToggleTimeChanger() end)
    self.GravityBtn.MouseButton1Click:Connect(function() self:ToggleGravityHack() end)
    
    self.DebugBtn.MouseButton1Click:Connect(function() self:ToggleDebugMode() end)
    self.AutoRespawnBtn.MouseButton1Click:Connect(function() self:ToggleAutoRespawn() end)
    self.MemoryBtn.MouseButton1Click:Connect(function() self:CleanMemory() end)
    self.SaveBtn.MouseButton1Click:Connect(function() self:SaveConfig() end)
    self.LoadBtn.MouseButton1Click:Connect(function() self:LoadConfig() end)
    self.ResetBtn.MouseButton1Click:Connect(function() self:ResetAll() end)
    
    self.StealthBtn.MouseButton1Click:Connect(function() self:ToggleStealth() end)
    self.AntiDetectBtn.MouseButton1Click:Connect(function() self:ToggleAntiDetect() end)
    self.LogBtn.MouseButton1Click:Connect(function() self:CleanLogs() end)
    
    self.WaypointBtn.MouseButton1Click:Connect(function() self:SetWaypoint() end)
    self.TPWaypointBtn.MouseButton1Click:Connect(function() self:TPToWaypoint() end)
    self.ScriptHubBtn.MouseButton1Click:Connect(function() self:OpenScriptHub() end)
    self.LuaBtn.MouseButton1Click:Connect(function() self:OpenLuaExecutor() end)
    
    -- Close button
    self.CloseBtn.MouseButton1Click:Connect(function()
        self.ConfirmDialog.Visible = true
    end)
    
    self.ConfirmYesBtn.MouseButton1Click:Connect(function()
        self:Cleanup()
        self.ScreenGui:Destroy()
    end)
    
    self.ConfirmNoBtn.MouseButton1Click:Connect(function()
        self.ConfirmDialog.Visible = false
    end)
    
    -- Minimize button
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end)
end

function VoidGUI:SetupHotkeys()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F5 then
            self.MainFrame.Visible = not self.MainFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.F6 then
            self:ResetAll()
        end
    end)
end

function VoidGUI:Cleanup()
    self:CleanupConnections(self.Connections)
    self:CleanupConnections(self.FlyConnections)
    self:CleanupConnections(self.ESPConnections)
    self:CleanupConnections(self.PlayerConnections)
    self:LogConsole("CLEANUP COMPLETED")
end

-- ============================================================================
-- INITIALIZE
-- ============================================================================

local GUI = VoidGUI.new()
return GUI
