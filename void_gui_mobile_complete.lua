-- VOID ACCESS TERMINAL GUI - ENHANCED VERSION WITH MOBILE SUPPORT
-- Author: Dark Terminal
-- Version: 2.1.0 (Enhanced with Mobile Compatibility)
-- Enhanced GUI with Game Features for Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")

-- Utility Functions
local Utils = {}

function Utils.Create(name, className, parent)
    local obj = Instance.new(className)
    obj.Name = name
    obj.Parent = parent
    return obj
end

function Utils.UICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = parent
    return corner
end

function Utils.UIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

function Utils.CreateButton(name, text, parent)
    local btn = Utils.Create(name, "TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    btn.TextColor3 = Color3.fromRGB(190, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.AutoButtonColor = false
    
    Utils.UICorner(btn, 4)
    Utils.UIStroke(btn, Color3.fromRGB(120, 0, 0), 1)
    
    -- Hover effect (for non-mobile devices)
    if not UserInputService.TouchEnabled then
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 0, 0),
                TextColor3 = Color3.fromRGB(255, 0, 0)
            }):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40, 0, 0),
                TextColor3 = Color3.fromRGB(190, 0, 0)
            }):Play()
        end)
    end
    
    return btn
end

-- Main GUI Class
local VoidGUI = {}
VoidGUI.__index = VoidGUI

function VoidGUI.new()
    local self = setmetatable({}, VoidGUI)
    
    -- Game State Variables
    self.SpeedEnabled = false
    self.FlyEnabled = false
    self.NoClipEnabled = false
    self.ESPEnabled = false
    self.FullbrightEnabled = false
    self.InfiniteJumpEnabled = false
    self.XRayEnabled = false
    self.WalkSpeed = 16
    self.JumpPower = 50
    self.FlySpeed = 50
    
    -- Mobile-specific variables
    self.IsMobile = UserInputService.TouchEnabled
    self.MobileFlyControls = nil
    self.FlyMoveVector = Vector3.new(0, 0, 0)
    self.FlyUpPressed = false
    self.FlyDownPressed = false
    self.MobileJoystick = nil
    self.JoystickActive = false
    self.JoystickStartPos = nil
    self.JoystickCurrentPos = nil
    self.JoystickRadius = 60
    
    -- Connections
    self.Connections = {}
    self.FlyConnections = {}
    
    -- ScreenGui Container
    self.ScreenGui = Utils.Create("VoidAccessGUI", "ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self:BuildMainFrame()
    self:BuildEffects()
    self:BuildConfirmDialog()
    
    self.IsMinimized = false
    self.ActiveTab = "CONSOLE"
    
    -- Initialize pages
    self:InitializePages()
    
    -- Connect button events
    self:ConnectEvents()
    
    -- Start effects
    self:StartEffects()
    
    return self
end

function VoidGUI:BuildMainFrame()
    -- Main Window
    self.MainFrame = Utils.Create("MainFrame", "Frame", self.ScreenGui)
    self.MainFrame.BackgroundColor3 = Color3.fromHex("#020202")
    self.MainFrame.Size = UDim2.new(0, 520, 0, 360)
    self.MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.ClipsDescendants = true
    
    Utils.UICorner(self.MainFrame, 6)
    Utils.UIStroke(self.MainFrame, Color3.fromHex("#780000"), 2)
    
    -- Top Bar
    self.TopBar = Utils.Create("TopBar", "Frame", self.MainFrame)
    self.TopBar.BackgroundColor3 = Color3.fromHex("#0a0a0a")
    self.TopBar.Size = UDim2.new(1, 0, 0, 42)
    self.TopBar.ZIndex = 3
    
    Utils.UICorner(self.TopBar, 6)
    Utils.UIStroke(self.TopBar, Color3.fromHex("#780000"), 1)
    
    -- Title
    self.Title = Utils.Create("Title", "TextLabel", self.TopBar)
    self.Title.Text = "VOID ACCESS // FINAL SESSION EXT"
    self.Title.Font = Enum.Font.Code
    self.Title.TextColor3 = Color3.fromHex("#BE0000")
    self.Title.TextSize = 16
    self.Title.BackgroundTransparency = 1
    self.Title.Size = UDim2.new(1, -120, 1, 0)
    self.Title.Position = UDim2.new(0, 12, 0, 0)
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Top Buttons Container
    local buttonContainer = Utils.Create("ButtonContainer", "Frame", self.TopBar)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(0, 100, 1, 0)
    buttonContainer.Position = UDim2.new(1, -108, 0, 0)
    
    -- Minimize Button
    self.MinimizeBtn = Utils.CreateButton("MinimizeBtn", "_", buttonContainer)
    self.MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeBtn.Position = UDim2.new(0, 0, 0.5, -15)
    
    -- Maximize Button
    self.MaximizeBtn = Utils.CreateButton("MaximizeBtn", "▢", buttonContainer)
    self.MaximizeBtn.Size = UDim2.new(0, 30, 0, 30)
    self.MaximizeBtn.Position = UDim2.new(0, 34, 0.5, -15)
    
    -- Close Button
    self.CloseBtn = Utils.CreateButton("CloseBtn", "X", buttonContainer)
    self.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    self.CloseBtn.Position = UDim2.new(0, 68, 0.5, -15)
    self.CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    
    -- Content Area
    self.ContentArea = Utils.Create("ContentArea", "Frame", self.MainFrame)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Size = UDim2.new(1, -20, 1, -62)
    self.ContentArea.Position = UDim2.new(0, 10, 0, 52)
    
    -- Tabs Container (Left)
    self.TabsContainer = Utils.Create("TabsContainer", "Frame", self.ContentArea)
    self.TabsContainer.BackgroundColor3 = Color3.fromHex("#0a0a0a")
    self.TabsContainer.Size = UDim2.new(0, 140, 1, 0)
    
    Utils.UICorner(self.TabsContainer, 4)
    Utils.UIStroke(self.TabsContainer, Color3.fromHex("#780000"), 1)
    
    -- Pages Container (Right)
    self.PagesContainer = Utils.Create("PagesContainer", "Frame", self.ContentArea)
    self.PagesContainer.BackgroundColor3 = Color3.fromHex("#0a0a0a")
    self.PagesContainer.Size = UDim2.new(1, -150, 1, 0)
    self.PagesContainer.Position = UDim2.new(0, 150, 0, 0)
    
    Utils.UICorner(self.PagesContainer, 4)
    Utils.UIStroke(self.PagesContainer, Color3.fromHex("#780000"), 1)
end

function VoidGUI:BuildEffects()
    -- Scanline Effect
    self.Scanline = Utils.Create("Scanline", "Frame", self.MainFrame)
    self.Scanline.BackgroundColor3 = Color3.fromHex("#BE0000")
    self.Scanline.Size = UDim2.new(1, 0, 0, 1)
    self.Scanline.Position = UDim2.new(0, 0, 0, 0)
    self.Scanline.BackgroundTransparency = 0.3
    self.Scanline.ZIndex = 2
    
    -- Noise Overlay
    self.NoiseOverlay = Utils.Create("NoiseOverlay", "Frame", self.MainFrame)
    self.NoiseOverlay.BackgroundTransparency = 0.94
    self.NoiseOverlay.Size = UDim2.new(1, 0, 1, 0)
    self.NoiseOverlay.ZIndex = 4
end

function VoidGUI:BuildConfirmDialog()
    -- Confirm Dialog (Initially Hidden)
    self.ConfirmDialog = Utils.Create("ConfirmDialog", "Frame", self.ScreenGui)
    self.ConfirmDialog.BackgroundColor3 = Color3.fromHex("#020202")
    self.ConfirmDialog.Size = UDim2.new(0, 320, 0, 150)
    self.ConfirmDialog.Position = UDim2.new(0.5, -160, 0.5, -75)
    self.ConfirmDialog.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ConfirmDialog.Visible = false
    self.ConfirmDialog.ZIndex = 10
    
    Utils.UICorner(self.ConfirmDialog, 6)
    Utils.UIStroke(self.ConfirmDialog, Color3.fromHex("#BE0000"), 2)
    
    -- Dialog Title
    local dialogTitle = Utils.Create("DialogTitle", "TextLabel", self.ConfirmDialog)
    dialogTitle.Text = "TERMINATE IMMUTABLE SESSION ?"
    dialogTitle.Font = Enum.Font.Code
    dialogTitle.TextColor3 = Color3.fromHex("#BE0000")
    dialogTitle.TextSize = 18
    dialogTitle.BackgroundTransparency = 1
    dialogTitle.Size = UDim2.new(1, -20, 0, 40)
    dialogTitle.Position = UDim2.new(0, 10, 0, 10)
    
    -- Buttons Container
    local dialogButtons = Utils.Create("DialogButtons", "Frame", self.ConfirmDialog)
    dialogButtons.BackgroundTransparency = 1
    dialogButtons.Size = UDim2.new(1, -40, 0, 40)
    dialogButtons.Position = UDim2.new(0, 20, 1, -60)
    
    -- Execute Button
    self.ExecuteBtn = Utils.CreateButton("ExecuteBtn", "EXECUTE", dialogButtons)
    self.ExecuteBtn.Size = UDim2.new(0.5, -10, 1, 0)
    self.ExecuteBtn.Position = UDim2.new(0, 0, 0, 0)
    self.ExecuteBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    
    -- Abort Button
    self.AbortBtn = Utils.CreateButton("AbortBtn", "ABORT", dialogButtons)
    self.AbortBtn.Size = UDim2.new(0.5, -10, 1, 0)
    self.AbortBtn.Position = UDim2.new(0.5, 10, 0, 0)
end

function VoidGUI:InitializePages()
    -- Create Tab Buttons
    self.Tabs = {
        CONSOLE = {name = "CONSOLE", frame = nil, button = nil},
        PLAYER = {name = "PLAYER", frame = nil, button = nil},
        VISUAL = {name = "VISUAL", frame = nil, button = nil},
        TELEPORT = {name = "TELEPORT", frame = nil, button = nil},
        ABOUT = {name = "ABOUT", frame = nil, button = nil}
    }
    
    local tabY = 10
    for _, tabName in ipairs({"CONSOLE", "PLAYER", "VISUAL", "TELEPORT", "ABOUT"}) do
        local tabData = self.Tabs[tabName]
        -- Tab Button
        tabData.button = Utils.CreateButton(tabName .. "Tab", tabName, self.TabsContainer)
        tabData.button.Size = UDim2.new(1, -20, 0, 32)
        tabData.button.Position = UDim2.new(0, 10, 0, tabY)
        tabData.button.TextColor3 = Color3.fromHex("#780000")
        tabY = tabY + 38
        
        -- Page Frame
        tabData.frame = Utils.Create(tabName .. "Page", "Frame", self.PagesContainer)
        tabData.frame.BackgroundTransparency = 1
        tabData.frame.Size = UDim2.new(1, -20, 1, -20)
        tabData.frame.Position = UDim2.new(0, 10, 0, 10)
        tabData.frame.Visible = false
    end
    
    -- Build individual pages
    self:BuildConsolePage()
    self:BuildPlayerPage()
    self:BuildVisualPage()
    self:BuildTeleportPage()
    self:BuildAboutPage()
    
    -- Activate console tab by default
    self:SwitchTab("CONSOLE")
end

function VoidGUI:BuildConsolePage()
    local page = self.Tabs.CONSOLE.frame
    
    local consoleLabel = Utils.Create("ConsoleLabel", "TextLabel", page)
    consoleLabel.Text = ""
    consoleLabel.Font = Enum.Font.Code
    consoleLabel.TextColor3 = Color3.fromHex("#BE0000")
    consoleLabel.TextSize = 13
    consoleLabel.BackgroundTransparency = 1
    consoleLabel.Size = UDim2.new(1, 0, 1, 0)
    consoleLabel.TextXAlignment = Enum.TextXAlignment.Left
    consoleLabel.TextYAlignment = Enum.TextYAlignment.Top
    consoleLabel.TextWrapped = true
    
    self.ConsoleLabel = consoleLabel
    
    -- Initial console message
    local initialText = [[
initializing void core... 
loading modules...
establishing connection...
void terminal ready.

SYSTEM: ACTIVE
MODE: ENHANCED
FEATURES: LOADED
MOBILE: ]] .. (self.IsMobile and "ENABLED" or "DISABLED")
    
    self:TypeText(consoleLabel, initialText, 0.02)
end

function VoidGUI:BuildPlayerPage()
    local page = self.Tabs.PLAYER.frame
    
    -- ScrollingFrame for buttons
    local scrollFrame = Utils.Create("ScrollFrame", "ScrollingFrame", page)
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromHex("#BE0000")
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    
    local yPos = 5
    
    -- Speed Hack Button
    self.SpeedBtn = Utils.CreateButton("SpeedBtn", "SPEED HACK [OFF]", scrollFrame)
    self.SpeedBtn.Size = UDim2.new(1, -10, 0, 35)
    self.SpeedBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- Fly Button
    self.FlyBtn = Utils.CreateButton("FlyBtn", "FLY [OFF]", scrollFrame)
    self.FlyBtn.Size = UDim2.new(1, -10, 0, 35)
    self.FlyBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- NoClip Button
    self.NoClipBtn = Utils.CreateButton("NoClipBtn", "NOCLIP [OFF]", scrollFrame)
    self.NoClipBtn.Size = UDim2.new(1, -10, 0, 35)
    self.NoClipBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- Infinite Jump Button
    self.InfJumpBtn = Utils.CreateButton("InfJumpBtn", "INFINITE JUMP [OFF]", scrollFrame)
    self.InfJumpBtn.Size = UDim2.new(1, -10, 0, 35)
    self.InfJumpBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- God Mode Button
    self.GodModeBtn = Utils.CreateButton("GodModeBtn", "GOD MODE", scrollFrame)
    self.GodModeBtn.Size = UDim2.new(1, -10, 0, 35)
    self.GodModeBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- Reset Character Button
    self.ResetBtn = Utils.CreateButton("ResetBtn", "RESET CHARACTER", scrollFrame)
    self.ResetBtn.Size = UDim2.new(1, -10, 0, 35)
    self.ResetBtn.Position = UDim2.new(0, 5, 0, yPos)
end

function VoidGUI:BuildVisualPage()
    local page = self.Tabs.VISUAL.frame
    
    local yPos = 5
    
    -- ESP Button
    self.ESPBtn = Utils.CreateButton("ESPBtn", "ESP [OFF]", page)
    self.ESPBtn.Size = UDim2.new(1, -10, 0, 35)
    self.ESPBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- Fullbright Button
    self.FullbrightBtn = Utils.CreateButton("FullbrightBtn", "FULLBRIGHT [OFF]", page)
    self.FullbrightBtn.Size = UDim2.new(1, -10, 0, 35)
    self.FullbrightBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- Remove Fog Button
    self.RemoveFogBtn = Utils.CreateButton("RemoveFogBtn", "REMOVE FOG", page)
    self.RemoveFogBtn.Size = UDim2.new(1, -10, 0, 35)
    self.RemoveFogBtn.Position = UDim2.new(0, 5, 0, yPos)
    yPos = yPos + 40
    
    -- X-Ray Button
    self.XRayBtn = Utils.CreateButton("XRayBtn", "X-RAY [OFF]", page)
    self.XRayBtn.Size = UDim2.new(1, -10, 0, 35)
    self.XRayBtn.Position = UDim2.new(0, 5, 0, yPos)
    self.XRayEnabled = false
end

function VoidGUI:BuildTeleportPage()
    local page = self.Tabs.TELEPORT.frame
    
    -- ScrollingFrame for teleport buttons
    local scrollFrame = Utils.Create("TpScrollFrame", "ScrollingFrame", page)
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromHex("#BE0000")
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    
    local yPos = 5
    
    -- Teleport to Players
    local tpLabel = Utils.Create("TpLabel", "TextLabel", scrollFrame)
    tpLabel.Text = "TELEPORT TO PLAYERS:"
    tpLabel.Font = Enum.Font.Code
    tpLabel.TextColor3 = Color3.fromHex("#BE0000")
    tpLabel.TextSize = 14
    tpLabel.BackgroundTransparency = 1
    tpLabel.Size = UDim2.new(1, -10, 0, 25)
    tpLabel.Position = UDim2.new(0, 5, 0, yPos)
    tpLabel.TextXAlignment = Enum.TextXAlignment.Left
    yPos = yPos + 30
    
    -- Function to refresh teleport buttons
    local function refreshTeleportButtons()
        -- Clear existing buttons
        for _, btn in ipairs(self.TpButtons or {}) do
            btn:Destroy()
        end
        self.TpButtons = {}
        
        -- Create new buttons
        local currentY = yPos
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local btn = Utils.CreateButton("Tp_" .. player.Name, "TP TO: " .. player.Name, scrollFrame)
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.Position = UDim2.new(0, 5, 0, currentY)
                btn.MouseButton1Click:Connect(function()
                    self:TeleportToPlayer(player)
                end)
                table.insert(self.TpButtons, btn)
                currentY = currentY + 35
            end
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)
    end
    
    -- Initial creation
    refreshTeleportButtons()
    
    -- Refresh when players join/leave
    local playerAddedConn = Players.PlayerAdded:Connect(function()
        refreshTeleportButtons()
    end)
    
    local playerRemovingConn = Players.PlayerRemoving:Connect(function()
        refreshTeleportButtons()
    end)
    
    table.insert(self.Connections, playerAddedConn)
    table.insert(self.Connections, playerRemovingConn)
end

function VoidGUI:BuildAboutPage()
    local page = self.Tabs.ABOUT.frame
    
    local aboutLabel = Utils.Create("AboutLabel", "TextLabel", page)
    aboutLabel.Text = [[
VOID TERMINAL - ENHANCED
VERSION 2.1.0

FEATURES:
- SPEED HACK
- FLY MODE (MOBILE)
- NOCLIP
- ESP
- FULLBRIGHT
- TELEPORT
- GOD MODE
- INFINITE JUMP

MOBILE SUPPORT: ENABLED
PLATFORM: ]] .. (self.IsMobile and "MOBILE" or "DESKTOP")
    aboutLabel.Font = Enum.Font.Code
    aboutLabel.TextColor3 = Color3.fromHex("#BE0000")
    aboutLabel.TextSize = 13
    aboutLabel.BackgroundTransparency = 1
    aboutLabel.Size = UDim2.new(1, 0, 1, 0)
    aboutLabel.TextXAlignment = Enum.TextXAlignment.Left
    aboutLabel.TextYAlignment = Enum.TextYAlignment.Top
    aboutLabel.TextWrapped = true
end

-- MOBILE FLY CONTROLS
function VoidGUI:CreateMobileFlyControls()
    if self.MobileFlyControls then return end
    
    self.MobileFlyControls = Utils.Create("MobileFlyControls", "Frame", self.ScreenGui)
    self.MobileFlyControls.BackgroundTransparency = 1
    self.MobileFlyControls.Size = UDim2.new(1, 0, 1, 0)
    self.MobileFlyControls.ZIndex = 5
    
    -- Virtual Joystick for movement
    self.MobileJoystick = Utils.Create("MobileJoystick", "Frame", self.MobileFlyControls)
    self.MobileJoystick.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    self.MobileJoystick.BackgroundTransparency = 0.7
    self.MobileJoystick.Size = UDim2.new(0, 120, 0, 120)
    self.MobileJoystick.Position = UDim2.new(0, 30, 1, -150)
    Utils.UICorner(self.MobileJoystick, 60)
    Utils.UIStroke(self.MobileJoystick, Color3.fromRGB(190, 0, 0), 2)
    
    -- Joystick thumb
    local joystickThumb = Utils.Create("JoystickThumb", "Frame", self.MobileJoystick)
    joystickThumb.BackgroundColor3 = Color3.fromRGB(190, 0, 0)
    joystickThumb.Size = UDim2.new(0, 40, 0, 40)
    joystickThumb.Position = UDim2.new(0.5, -20, 0.5, -20)
    Utils.UICorner(joystickThumb, 20)
    self.JoystickThumb = joystickThumb
    
    -- Fly up button
    local flyUpBtn = Utils.CreateButton("FlyUpBtn", "▲", self.MobileFlyControls)
    flyUpBtn.Size = UDim2.new(0, 70, 0, 70)
    flyUpBtn.Position = UDim2.new(1, -80, 0.5, -100)
    flyUpBtn.ZIndex = 6
    flyUpBtn.TextSize = 24
    
    flyUpBtn.MouseButton1Down:Connect(function()
        self.FlyUpPressed = true
    end)
    
    flyUpBtn.MouseButton1Up:Connect(function()
        self.FlyUpPressed = false
    end)
    
    flyUpBtn.MouseLeave:Connect(function()
        if self.FlyUpPressed then
            self.FlyUpPressed = false
        end
    end)
    
    -- Fly down button
    local flyDownBtn = Utils.CreateButton("FlyDownBtn", "▼", self.MobileFlyControls)
    flyDownBtn.Size = UDim2.new(0, 70, 0, 70)
    flyDownBtn.Position = UDim2.new(1, -80, 0.5, -10)
    flyDownBtn.ZIndex = 6
    flyDownBtn.TextSize = 24
    
    flyDownBtn.MouseButton1Down:Connect(function()
        self.FlyDownPressed = true
    end)
    
    flyDownBtn.MouseButton1Up:Connect(function()
        self.FlyDownPressed = false
    end)
    
    flyDownBtn.MouseLeave:Connect(function()
        if self.FlyDownPressed then
            self.FlyDownPressed = false
        end
    end)
    
    -- Speed indicator
    local speedIndicator = Utils.Create("SpeedIndicator", "TextLabel", self.MobileFlyControls)
    speedIndicator.Text = "FLY SPEED: " .. self.FlySpeed
    speedIndicator.Font = Enum.Font.Code
    speedIndicator.TextColor3 = Color3.fromHex("#BE0000")
    speedIndicator.TextSize = 14
    speedIndicator.BackgroundTransparency = 0.8
    speedIndicator.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    speedIndicator.Size = UDim2.new(0, 150, 0, 30)
    speedIndicator.Position = UDim2.new(0, 20, 1, -40)
    speedIndicator.ZIndex = 6
    Utils.UICorner(speedIndicator, 4)
    self.FlySpeedIndicator = speedIndicator
    
    -- Joystick input handling
    local function handleJoystickInput(input, processed)
        if processed then return end
        
        if input.UserInputType == Enum.UserInputType.Touch then
            local joystickPos = self.MobileJoystick.AbsolutePosition
            local joystickSize = self.MobileJoystick.AbsoluteSize
            local joystickCenter = joystickPos + joystickSize / 2
            
            if input.UserInputState == Enum.UserInputState.Begin then
                if (input.Position - joystickCenter).Magnitude <= self.JoystickRadius then
                    self.JoystickActive = true
                    self.JoystickStartPos = joystickCenter
                    self.JoystickCurrentPos = joystickCenter
                end
            elseif input.UserInputState == Enum.UserInputState.Change then
                if self.JoystickActive then
                    self.JoystickCurrentPos = input.Position
                    
                    -- Calculate movement vector
                    local delta = self.JoystickCurrentPos - self.JoystickStartPos
                    local distance = math.min(delta.Magnitude, self.JoystickRadius)
                    
                    if distance > 5 then
                        local direction = delta.Unit
                        self.FlyMoveVector = Vector3.new(direction.X, 0, direction.Y) * (distance / self.JoystickRadius)
                        
                        -- Update joystick thumb position
                        local thumbPos = direction * math.min(distance, self.JoystickRadius - 20)
                        self.JoystickThumb.Position = UDim2.new(
                            0.5, thumbPos.X - 20,
                            0.5, thumbPos.Y - 20
                        )
                    else
                        self.FlyMoveVector = Vector3.new(0, 0, 0)
                        self.JoystickThumb.Position = UDim2.new(0.5, -20, 0.5, -20)
                    end
                end
            elseif input.UserInputState == Enum.UserInputState.End then
                if self.JoystickActive then
                    self.JoystickActive = false
                    self.FlyMoveVector = Vector3.new(0, 0, 0)
                    self.JoystickThumb.Position = UDim2.new(0.5, -20, 0.5, -20)
                end
            end
        end
    end
    
    -- Connect joystick input
    self.MobileJoystick.InputBegan:Connect(function(input)
        handleJoystickInput(input, false)
    end)
    
    self.MobileJoystick.InputChanged:Connect(function(input)
        handleJoystickInput(input, false)
    end)
    
    self.MobileJoystick.InputEnded:Connect(function(input)
        handleJoystickInput(input, false)
    end)
end

function VoidGUI:RemoveMobileFlyControls()
    if self.MobileFlyControls then
        self.MobileFlyControls:Destroy()
        self.MobileFlyControls = nil
        self.FlyMoveVector = Vector3.new(0, 0, 0)
        self.FlyUpPressed = false
        self.FlyDownPressed = false
        self.JoystickActive = false
    end
end

-- ENHANCED FLY MODE WITH MOBILE SUPPORT
function VoidGUI:ToggleFly()
    self.FlyEnabled = not self.FlyEnabled
    local player = Players.LocalPlayer
    
    if self.FlyEnabled then
        self.FlyBtn.Text = "FLY [ON]"
        self.FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local character = player.Character
        if not character then 
            self:LogConsole("ERROR: No character found for Fly Mode")
            self.FlyEnabled = false
            self.FlyBtn.Text = "FLY [OFF]"
            self.FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
            return 
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then 
            self:LogConsole("ERROR: No HumanoidRootPart found")
            self.FlyEnabled = false
            self.FlyBtn.Text = "FLY [OFF]"
            self.FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
            return 
        end
        
        -- Create mobile controls if on mobile
        if self.IsMobile then
            self:CreateMobileFlyControls()
        end
        
        -- Use CFrame approach for better compatibility
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.P = 1250
        bodyVelocity.Parent = humanoidRootPart
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(50000, 0, 50000)
        bodyGyro.P = 3000
        bodyGyro.D = 100
        bodyGyro.Parent = humanoidRootPart
        
        local flyConnection
        flyConnection = RunService.Heartbeat:Connect(function(dt)
            if not self.FlyEnabled or not character or not humanoidRootPart then
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                if flyConnection then flyConnection:Disconnect() end
                return
            end
            
            local camera = workspace.CurrentCamera
            if not camera then return end
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            if self.IsMobile then
                -- Mobile controls
                local forward = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                
                -- Apply joystick movement
                moveDirection = moveDirection + (forward * -self.FlyMoveVector.Z)
                moveDirection = moveDirection + (right * self.FlyMoveVector.X)
                
                -- Apply up/down buttons
                if self.FlyUpPressed then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if self.FlyDownPressed then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                -- Update speed indicator
                if self.FlySpeedIndicator then
                    self.FlySpeedIndicator.Text = "FLY SPEED: " .. self.FlySpeed
                end
            else
                -- PC controls
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
            end
            
            -- Normalize and apply speed
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * self.FlySpeed
            end
            
            -- Apply movement
            bodyVelocity.Velocity = moveDirection
            
            -- Maintain orientation (only horizontal)
            local currentCFrame = camera.CFrame
            bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, 
                Vector3.new(currentCFrame.LookVector.X * 1000 + humanoidRootPart.Position.X, 
                          humanoidRootPart.Position.Y, 
                          currentCFrame.LookVector.Z * 1000 + humanoidRootPart.Position.Z))
        end)
        
        table.insert(self.FlyConnections, flyConnection)
        self:LogConsole("FLY MODE ACTIVATED" .. (self.IsMobile and " (MOBILE)" or ""))
    else
        self.FlyBtn.Text = "FLY [OFF]"
        self.FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        -- Remove mobile controls
        if self.IsMobile then
            self:RemoveMobileFlyControls()
        end
        
        -- Disconnect all fly connections
        for _, connection in ipairs(self.FlyConnections) do
            if connection and connection.Disconnect then
                connection:Disconnect()
            end
        end
        self.FlyConnections = {}
        
        -- Reset character physics
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
end

-- IMPROVED TOUCH INPUT HANDLING
function VoidGUI:ConnectEvents()
    -- Drag functionality with touch support
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
    
    self.TopBar.InputBegan:Connect(beginDrag)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Button Events
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.MaximizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        self.ConfirmDialog.Visible = true
    end)
    
    -- Confirm Dialog Events
    self.ExecuteBtn.MouseButton1Click:Connect(function()
        -- Cleanup all connections
        for _, connection in ipairs(self.Connections) do
            if connection and connection.Disconnect then
                connection:Disconnect()
            end
        end
        for _, connection in ipairs(self.FlyConnections) do
            if connection and connection.Disconnect then
                connection:Disconnect()
            end
        end
        self.ScreenGui:Destroy()
    end)
    
    self.AbortBtn.MouseButton1Click:Connect(function()
        self.ConfirmDialog.Visible = false
    end)
    
    -- Tab Events
    for tabName, tabData in pairs(self.Tabs) do
        tabData.button.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
    end
    
    -- Player Page Button Events
    if self.SpeedBtn then
        self.SpeedBtn.MouseButton1Click:Connect(function()
            self:ToggleSpeed()
        end)
    end
    
    if self.FlyBtn then
        self.FlyBtn.MouseButton1Click:Connect(function()
            self:ToggleFly()
        end)
    end
    
    if self.NoClipBtn then
        self.NoClipBtn.MouseButton1Click:Connect(function()
            self:ToggleNoClip()
        end)
    end
    
    if self.InfJumpBtn then
        self.InfJumpBtn.MouseButton1Click:Connect(function()
            self:ToggleInfiniteJump()
        end)
    end
    
    if self.GodModeBtn then
        self.GodModeBtn.MouseButton1Click:Connect(function()
            self:ActivateGodMode()
        end)
    end
    
    if self.ResetBtn then
        self.ResetBtn.MouseButton1Click:Connect(function()
            self:ResetCharacter()
        end)
    end
    
    -- Visual Page Button Events
    if self.ESPBtn then
        self.ESPBtn.MouseButton1Click:Connect(function()
            self:ToggleESP()
        end)
    end
    
    if self.FullbrightBtn then
        self.FullbrightBtn.MouseButton1Click:Connect(function()
            self:ToggleFullbright()
        end)
    end
    
    if self.RemoveFogBtn then
        self.RemoveFogBtn.MouseButton1Click:Connect(function()
            self:RemoveFog()
        end)
    end
    
    if self.XRayBtn then
        self.XRayBtn.MouseButton1Click:Connect(function()
            self:ToggleXRay()
        end)
    end
end

function VoidGUI:SwitchTab(tabName)
    -- Deactivate all tabs
    for name, tabData in pairs(self.Tabs) do
        tabData.frame.Visible = false
        tabData.button.TextColor3 = Color3.fromHex("#780000")
        tabData.button.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    end
    
    -- Activate selected tab
    if self.Tabs[tabName] then
        self.Tabs[tabName].frame.Visible = true
        self.Tabs[tabName].button.TextColor3 = Color3.fromHex("#BE0000")
        self.Tabs[tabName].button.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        self.ActiveTab = tabName
    end
end

function VoidGUI:ToggleMinimize()
    if self.IsMinimized then
        -- Restore
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 520, 0, 360)
        }):Play()
        self.IsMinimized = false
    else
        -- Minimize
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 520, 0, 42)
        }):Play()
        self.IsMinimized = true
    end
end

function VoidGUI:ToggleMaximize()
    if self.MainFrame.Size == UDim2.new(0, 520, 0, 360) then
        -- Maximize
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 600, 0, 400)
        }):Play()
    else
        -- Restore original size
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 520, 0, 360)
        }):Play()
    end
end

function VoidGUI:StartEffects()
    -- Scanline Animation
    local scanlineConnection
    scanlineConnection = RunService.RenderStepped:Connect(function()
        if self.Scanline then
            local currentY = self.Scanline.Position.Y.Offset
            local newY = currentY + 2
            if newY > self.MainFrame.AbsoluteSize.Y then
                newY = -2
            end
            self.Scanline.Position = UDim2.new(0, 0, 0, newY)
        else
            scanlineConnection:Disconnect()
        end
    end)
    
    -- Noise Effect
    local noiseConnection
    noiseConnection = RunService.RenderStepped:Connect(function()
        if self.NoiseOverlay then
            self.NoiseOverlay.BackgroundColor3 = Color3.fromRGB(
                math.random(0, 10),
                math.random(0, 5),
                math.random(0, 10)
            )
        else
            noiseConnection:Disconnect()
        end
    end)
    
    -- Flicker Effect
    local flickerConnection
    flickerConnection = RunService.Heartbeat:Connect(function()
        if self.MainFrame and math.random(1, 100) < 10 then
            local baseColor = Color3.fromHex("#020202")
            local r = math.clamp(baseColor.R + (math.random(-5, 5)/255), 0, 0.02)
            local g = math.clamp(baseColor.G + (math.random(-3, 3)/255), 0, 0.01)
            local b = math.clamp(baseColor.B + (math.random(-5, 5)/255), 0, 0.02)
            
            TweenService:Create(self.MainFrame, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.new(r, g, b)
            }):Play()
        end
    end)
end

function VoidGUI:TypeText(label, text, speed)
    label.Text = ""
    local i = 1
    local typingConnection
    typingConnection = RunService.Heartbeat:Connect(function()
        if i <= #text then
            label.Text = string.sub(text, 1, i)
            i = i + 1
        else
            typingConnection:Disconnect()
        end
    end)
end

function VoidGUI:ToggleSpeed()
    self.SpeedEnabled = not self.SpeedEnabled
    local player = Players.LocalPlayer
    
    if self.SpeedEnabled then
        self.SpeedBtn.Text = "SPEED HACK [ON]"
        self.SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = self.WalkSpeed
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
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
        self:LogConsole("SPEED HACK DEACTIVATED")
    end
end

function VoidGUI:ToggleNoClip()
    self.NoClipEnabled = not self.NoClipEnabled
    local player = Players.LocalPlayer
    
    if self.NoClipEnabled then
        self.NoClipBtn.Text = "NOCLIP [ON]"
        self.NoClipBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = RunService.Stepped:Connect(function()
            if not self.NoClipEnabled then
                connection:Disconnect()
                return
            end
            
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        table.insert(self.Connections, connection)
        self:LogConsole("NOCLIP ACTIVATED")
    else
        self.NoClipBtn.Text = "NOCLIP [OFF]"
        self.NoClipBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        
        self:LogConsole("NOCLIP DEACTIVATED")
    end
end

function VoidGUI:ToggleInfiniteJump()
    self.InfiniteJumpEnabled = not self.InfiniteJumpEnabled
    
    if self.InfiniteJumpEnabled then
        self.InfJumpBtn.Text = "INFINITE JUMP [ON]"
        self.InfJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        local connection
        connection = UserInputService.JumpRequest:Connect(function()
            if self.InfiniteJumpEnabled then
                local player = Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            else
                connection:Disconnect()
            end
        end)
        
        table.insert(self.Connections, connection)
        self:LogConsole("INFINITE JUMP ACTIVATED")
    else
        self.InfJumpBtn.Text = "INFINITE JUMP [OFF]"
        self.InfJumpBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        self:LogConsole("INFINITE JUMP DEACTIVATED")
    end
end

function VoidGUI:ActivateGodMode()
    local player = Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.MaxHealth = math.huge
        player.Character.Humanoid.Health = math.huge
        self:LogConsole("GOD MODE ACTIVATED")
    end
end

function VoidGUI:ResetCharacter()
    local player = Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
        self:LogConsole("CHARACTER RESET")
    end
end

function VoidGUI:ToggleESP()
    self.ESPEnabled = not self.ESPEnabled
    
    if self.ESPEnabled then
        self.ESPBtn.Text = "ESP [ON]"
        self.ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                self:AddESP(player)
            end
        end
        
        local connection
        connection = Players.PlayerAdded:Connect(function(player)
            if self.ESPEnabled then
                self:AddESP(player)
            else
                connection:Disconnect()
            end
        end)
        
        table.insert(self.Connections, connection)
        self:LogConsole("ESP ACTIVATED")
    else
        self.ESPBtn.Text = "ESP [OFF]"
        self.ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, player in ipairs(Players:GetPlayers()) do
            self:RemoveESP(player)
        end
        
        self:LogConsole("ESP DEACTIVATED")
    end
end

function VoidGUI:AddESP(player)
    local function createESP(character)
        if character:FindFirstChild("ESPBox") then return end
        
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then return end
        
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESPBox"
        billboardGui.Adornee = humanoidRootPart
        billboardGui.Size = UDim2.new(4, 0, 5, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = character
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.7
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        frame.Parent = billboardGui
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, -25)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextSize = 14
        nameLabel.Parent = billboardGui
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 1, 5)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.Font = Enum.Font.Code
        distanceLabel.TextSize = 12
        distanceLabel.Parent = billboardGui
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not self.ESPEnabled or not character or not character.Parent then
                connection:Disconnect()
                if billboardGui then billboardGui:Destroy() end
                return
            end
            
            local localChar = Players.LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") and humanoidRootPart then
                local distance = (localChar.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                distanceLabel.Text = string.format("%.1f studs", distance)
            end
        end)
        
        table.insert(self.Connections, connection)
    end
    
    if player.Character then
        createESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        if self.ESPEnabled then
            createESP(character)
        end
    end)
end

function VoidGUI:RemoveESP(player)
    if player.Character and player.Character:FindFirstChild("ESPBox") then
        player.Character.ESPBox:Destroy()
    end
end

function VoidGUI:ToggleFullbright()
    self.FullbrightEnabled = not self.FullbrightEnabled
    
    if self.FullbrightEnabled then
        self.FullbrightBtn.Text = "FULLBRIGHT [ON]"
        self.FullbrightBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        
        self:LogConsole("FULLBRIGHT ACTIVATED")
    else
        self.FullbrightBtn.Text = "FULLBRIGHT [OFF]"
        self.FullbrightBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        
        self:LogConsole("FULLBRIGHT DEACTIVATED")
    end
end

function VoidGUI:RemoveFog()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    self:LogConsole("FOG REMOVED")
end

function VoidGUI:ToggleXRay()
    self.XRayEnabled = not self.XRayEnabled
    
    if self.XRayEnabled then
        self.XRayBtn.Text = "X-RAY [ON]"
        self.XRayBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                obj.LocalTransparencyModifier = 0.7
            end
        end
        
        self:LogConsole("X-RAY ACTIVATED")
    else
        self.XRayBtn.Text = "X-RAY [OFF]"
        self.XRayBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
        
        self:LogConsole("X-RAY DEACTIVATED")
    end
end

function VoidGUI:TeleportToPlayer(targetPlayer)
    local player = Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            self:LogConsole("TELEPORTED TO: " .. targetPlayer.Name)
        end
    end
end

function VoidGUI:LogConsole(message)
    if self.ConsoleLabel then
        local timestamp = os.date("%H:%M:%S")
        self.ConsoleLabel.Text = self.ConsoleLabel.Text .. "\n[" .. timestamp .. "] " .. message
    end
end

-- Public API
local PublicAPI = {
    GUI = nil,
    
    Create = function()
        local gui = VoidGUI.new()
        PublicAPI.GUI = gui
        return gui
    end,
    
    Log = function(message)
        if PublicAPI.GUI and PublicAPI.GUI.ConsoleLabel then
            local currentText = PublicAPI.GUI.ConsoleLabel.Text
            PublicAPI.GUI.ConsoleLabel.Text = currentText .. "\n> " .. message
        end
    end
}

-- Initialize GUI
return PublicAPI.Create()
