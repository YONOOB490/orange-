-- Orange Executor v12.0 ULTRA (Enhanced Notifications & Features)
-- 🔥 ปรับปรุงการแจ้งเตือน | Anti-AFK อัปเดต | Rejoin Server | ระบบตรวจจับขั้นสูง

-- === CONFIG ===
local IS_MOBILE = game:GetService("UserInputService").TouchEnabled
local THEME_COLOR = {
    PRIMARY = Color3.fromRGB(255, 106, 0),
    SECONDARY = Color3.fromRGB(255, 158, 68),
    ACCENT = Color3.fromRGB(230, 81, 0),
    DARK = Color3.fromRGB(25, 25, 25),
    DARKER = Color3.fromRGB(20, 20, 20),
    TEXT = Color3.fromRGB(255, 255, 255),
    ERROR = Color3.fromRGB(255, 80, 80),
    SUCCESS = Color3.fromRGB(80, 255, 80),
    INFO = Color3.fromRGB(0, 150, 255),
    WARNING = Color3.fromRGB(255, 193, 7),
    SUSPICIOUS = Color3.fromRGB(255, 50, 150)
}

-- === CLEANUP ===
if getgenv()._ORANGE_EXECUTOR_ULTRA then
    pcall(function() getgenv()._ORANGE_EXECUTOR_ULTRA:Destroy() end)
end

local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local UIParent = (gethui and gethui()) or (CoreGui:FindFirstChild("RobloxGui") and CoreGui.RobloxGui) or CoreGui

-- Main Folder
local MainFolder = Instance.new("Folder")
MainFolder.Name = "OrangeExecutor_ULTRA"
MainFolder.Parent = UIParent
getgenv()._ORANGE_EXECUTOR_ULTRA = MainFolder

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI_ULTRA"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = MainFolder

-- === ENHANCED NOTIFICATION SYSTEM ===
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 350, 0, 0)
NotificationContainer.Position = UDim2.new(1, -370, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ClipsDescendants = true
NotificationContainer.ZIndex = 999
NotificationContainer.Parent = ScreenGui

local NotificationListLayout = Instance.new("UIListLayout")
NotificationListLayout.Padding = UDim.new(0, 10)
NotificationListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotificationListLayout.Parent = NotificationContainer

-- ระบบแจ้งเตือนสำคัญ (Popup)
local ImportantNotificationContainer = Instance.new("Frame")
ImportantNotificationContainer.Name = "ImportantNotificationContainer"
ImportantNotificationContainer.Size = UDim2.new(0, 400, 0, 0)
ImportantNotificationContainer.Position = UDim2.new(0.5, -200, 0.3, 0)
ImportantNotificationContainer.BackgroundTransparency = 1
ImportantNotificationContainer.ClipsDescendants = true
ImportantNotificationContainer.ZIndex = 1000
ImportantNotificationContainer.Parent = ScreenGui

local ImportantNotificationListLayout = Instance.new("UIListLayout")
ImportantNotificationListLayout.Padding = UDim.new(0, 15)
ImportantNotificationListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ImportantNotificationListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ImportantNotificationListLayout.Parent = ImportantNotificationContainer

local function showNotification(title, message, notifType, duration, isImportant)
    duration = duration or 4
    isImportant = isImportant or false
    
    local container = isImportant and ImportantNotificationContainer or NotificationContainer
    
    local notification = Instance.new("Frame")
    notification.Size = isImportant and UDim2.new(1, 0, 0, 100) or UDim2.new(1, 0, 0, 80)
    notification.BackgroundColor3 = THEME_COLOR.DARKER
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.ZIndex = isImportant and 1001 or 1000
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = notifType or THEME_COLOR.INFO
    stroke.Thickness = isImportant and 3 or 2
    stroke.Parent = notification
    
    -- เอฟเฟกต์พิเศษสำหรับการแจ้งเตือนสำคัญ
    if isImportant then
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1, 20, 1, 20)
        glow.Position = UDim2.new(0, -10, 0, -10)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://4996891970"
        glow.ImageColor3 = notifType or THEME_COLOR.INFO
        glow.ImageTransparency = 0.7
        glow.ScaleType = Enum.ScaleType.Slice
        glow.SliceCenter = Rect.new(49, 49, 450, 450)
        glow.ZIndex = 1000
        glow.Parent = notification
    end
    
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 6, 1, 0)
    accentBar.BackgroundColor3 = notifType or THEME_COLOR.INFO
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = isImportant and 1002 or 1001
    accentBar.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, isImportant and 30 or 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = notifType or THEME_COLOR.INFO
    titleLabel.TextSize = isImportant and 18 or 14
    titleLabel.Font = isImportant and Enum.Font.GothamBlack or Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = isImportant and 1002 or 1001
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, isImportant and 50 or 35)
    messageLabel.Position = UDim2.new(0, 15, 0, isImportant and 45 or 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = THEME_COLOR.TEXT
    messageLabel.TextSize = isImportant and 14 or 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.ZIndex = isImportant and 1002 or 1001
    messageLabel.Parent = notification
    
    -- ปุ่มปิดสำหรับการแจ้งเตือนสำคัญ
    if isImportant then
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 80, 0, 25)
        closeBtn.Position = UDim2.new(1, -90, 1, -35)
        closeBtn.BackgroundColor3 = notifType or THEME_COLOR.INFO
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "ปิด"
        closeBtn.TextColor3 = THEME_COLOR.TEXT
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.ZIndex = 1002
        closeBtn.Parent = notification
        
        closeBtn.MouseButton1Click:Connect(function()
            TweenService:Create(notification, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -200, -1, 0)
            }):Play()
            wait(0.3)
            notification:Destroy()
        end)
    end
    
    notification.Parent = container
    
    -- Animation
    if isImportant then
        notification.Position = UDim2.new(0.5, -200, -1, 0)
        TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    else
        notification.Position = UDim2.new(1, 400, 0, 0)
        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
    
    -- Auto remove (ยกเว้นการแจ้งเตือนสำคัญที่ต้องปิดเอง)
    if not isImportant then
        task.spawn(function()
            wait(duration)
            if notification and notification.Parent then
                TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, 400, 0, 0)
                }):Play()
                wait(0.3)
                notification:Destroy()
            end
        end)
    end
    
    return notification
end

-- ฟังก์ชันสำหรับแจ้งเตือนสำคัญเท่านั้น
local function showImportantNotification(title, message, notifType)
    return showNotification(title, message, notifType, 0, true)
end

-- === MAIN FRAME ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = THEME_COLOR.DARK
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.new(1, 10, 1, 10)
MainShadow.Position = UDim2.new(0, -5, 0, -5)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://1316045217"
MainShadow.ImageColor3 = Color3.new(0, 0, 0)
MainShadow.ImageTransparency = 0.8
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(10, 10, 118, 118)
MainShadow.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = THEME_COLOR.PRIMARY
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- === TITLE BAR ===
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = THEME_COLOR.DARKER
TitleBar.BackgroundTransparency = 0
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🦊 ORANGE EXECUTOR v12.0"
TitleLabel.TextColor3 = THEME_COLOR.TEXT
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- === CONTROL BUTTONS ===
local ControlButtons = Instance.new("Frame")
ControlButtons.Name = "ControlButtons"
ControlButtons.Size = UDim2.new(0, 70, 1, 0)
ControlButtons.Position = UDim2.new(1, -75, 0, 0)
ControlButtons.BackgroundTransparency = 1
ControlButtons.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(0, 5, 0.5, -14)
MinimizeBtn.BackgroundColor3 = THEME_COLOR.SECONDARY
MinimizeBtn.BackgroundTransparency = 0
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "─"
MinimizeBtn.TextColor3 = THEME_COLOR.TEXT
MinimizeBtn.TextSize = 12
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = ControlButtons

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0, 38, 0.5, -14)
CloseBtn.BackgroundColor3 = THEME_COLOR.ERROR
CloseBtn.BackgroundTransparency = 0
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME_COLOR.TEXT
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = ControlButtons

-- === TAB SYSTEM ===
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = THEME_COLOR.DARKER
TabContainer.BackgroundTransparency = 0
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local Tabs = {"Executor", "Profile"}
local CurrentTab = "Executor"

local TabButtons = {}
local TabContents = {}

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = TabContainer

-- === CONTENT AREA ===
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -75)
ContentFrame.Position = UDim2.new(0, 0, 0, 75)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- === สร้างแท็บ ===
for _, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "Tab"
    TabBtn.Size = UDim2.new(0, 120, 1, 0)
    TabBtn.BackgroundColor3 = THEME_COLOR.DARK
    TabBtn.BackgroundTransparency = 0
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = tabName
    TabBtn.TextColor3 = THEME_COLOR.TEXT
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabContainer
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = tabName .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = THEME_COLOR.PRIMARY
    TabContent.Visible = (tabName == "Executor")
    TabContent.Parent = ContentFrame
    
    TabButtons[tabName] = TabBtn
    TabContents[tabName] = TabContent
    
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabName then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME_COLOR.SECONDARY}):Play()
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabName then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME_COLOR.DARK}):Play()
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabName
        for name, content in pairs(TabContents) do
            content.Visible = (name == tabName)
            TweenService:Create(TabButtons[name], TweenInfo.new(0.2), {
                BackgroundColor3 = name == tabName and THEME_COLOR.PRIMARY or THEME_COLOR.DARK
            }):Play()
        end
    end)
end

-- === TAB 1: EXECUTOR ===
local ExecutorContent = TabContents["Executor"]

local ScriptBoxContainer = Instance.new("Frame")
ScriptBoxContainer.Name = "ScriptBoxContainer"
ScriptBoxContainer.Size = UDim2.new(1, -20, 1, -110)
ScriptBoxContainer.Position = UDim2.new(0, 10, 0, 10)
ScriptBoxContainer.BackgroundColor3 = THEME_COLOR.DARKER
ScriptBoxContainer.BackgroundTransparency = 0
ScriptBoxContainer.BorderSizePixel = 0
ScriptBoxContainer.Parent = ExecutorContent

local ScriptBoxStroke = Instance.new("UIStroke")
ScriptBoxStroke.Color = THEME_COLOR.SECONDARY
ScriptBoxStroke.Thickness = 1
ScriptBoxStroke.Parent = ScriptBoxContainer

local ScriptBox = Instance.new("TextBox")
ScriptBox.Name = "ScriptBox"
ScriptBox.Size = UDim2.new(1, -20, 1, -20)
ScriptBox.Position = UDim2.new(0, 10, 0, 10)
ScriptBox.BackgroundTransparency = 1
ScriptBox.TextColor3 = THEME_COLOR.TEXT
ScriptBox.TextSize = IS_MOBILE and 16 or 14
ScriptBox.Font = Enum.Font.Code
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.MultiLine = true
ScriptBox.ClearTextOnFocus = false
ScriptBox.Text = "-- เขียนสคริปต์ของคุณที่นี่...\nprint('Orange Executor v12.0 พร้อมใช้งาน!')\n\n-- ตัวอย่างฟังก์ชัน\nfunction hello()\n    print('สวัสดี!')\nend\n\nhello()"
ScriptBox.Parent = ScriptBoxContainer

-- ปุ่ม Executor
local ExecutorButtons = Instance.new("Frame")
ExecutorButtons.Name = "ExecutorButtons"
ExecutorButtons.Size = UDim2.new(1, -20, 0, 40)
ExecutorButtons.Position = UDim2.new(0, 10, 1, -50)
ExecutorButtons.BackgroundTransparency = 1
ExecutorButtons.Parent = ExecutorContent

local function createExecutorButton(name, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.2, -8, 1, 0)
    btn.BackgroundColor3 = color or THEME_COLOR.PRIMARY
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = THEME_COLOR.TEXT
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = THEME_COLOR.SECONDARY}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = color or THEME_COLOR.PRIMARY}):Play()
    end)
    
    return btn
end

local RunBtn = createExecutorButton("RunBtn", "⚡ รัน")
local ClearBtn = createExecutorButton("ClearBtn", "🗑️ เคลียร์")
local CopyBtn = createExecutorButton("CopyBtn", "📋 คัดลอก")
local PasteBtn = createExecutorButton("PasteBtn", "📌 วาง")
local InjectBtn = createExecutorButton("InjectBtn", "💉 อินเจค", THEME_COLOR.SUCCESS)

RunBtn.Position = UDim2.new(0, 0, 0, 0)
ClearBtn.Position = UDim2.new(0.2, 6, 0, 0)
CopyBtn.Position = UDim2.new(0.4, 12, 0, 0)
PasteBtn.Position = UDim2.new(0.6, 18, 0, 0)
InjectBtn.Position = UDim2.new(0.8, 24, 0, 0)

RunBtn.Parent = ExecutorButtons
ClearBtn.Parent = ExecutorButtons
CopyBtn.Parent = ExecutorButtons
PasteBtn.Parent = ExecutorButtons
InjectBtn.Parent = ExecutorButtons

-- === TAB 2: PROFILE (Enhanced) ===
local ProfileContent = TabContents["Profile"]
ProfileContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ProfileTitle = Instance.new("TextLabel")
ProfileTitle.Size = UDim2.new(1, -20, 0, 30)
ProfileTitle.Position = UDim2.new(0, 10, 0, 10)
ProfileTitle.BackgroundTransparency = 1
ProfileTitle.Text = "👤 ระบบโปรไฟล์ขั้นสูง v12.0"
ProfileTitle.TextColor3 = THEME_COLOR.PRIMARY
ProfileTitle.TextSize = 16
ProfileTitle.Font = Enum.Font.GothamBold
ProfileTitle.TextXAlignment = Enum.TextXAlignment.Left
ProfileTitle.Parent = ProfileContent

-- === SERVER INFO ===
local ServerInfoCard = Instance.new("Frame")
ServerInfoCard.Size = UDim2.new(1, -20, 0, 80)
ServerInfoCard.Position = UDim2.new(0, 10, 0, 50)
ServerInfoCard.BackgroundColor3 = THEME_COLOR.DARKER
ServerInfoCard.BackgroundTransparency = 0
ServerInfoCard.BorderSizePixel = 0
ServerInfoCard.Parent = ProfileContent

local ServerStroke = Instance.new("UIStroke")
ServerStroke.Color = THEME_COLOR.INFO
ServerStroke.Thickness = 1
ServerStroke.Parent = ServerInfoCard

local ServerTitle = Instance.new("TextLabel")
ServerTitle.Size = UDim2.new(1, -20, 0, 25)
ServerTitle.Position = UDim2.new(0, 10, 0, 5)
ServerTitle.BackgroundTransparency = 1
ServerTitle.Text = "🌐 ข้อมูลเซิร์ฟเวอร์"
ServerTitle.TextColor3 = THEME_COLOR.INFO
ServerTitle.TextSize = 14
ServerTitle.Font = Enum.Font.GothamBold
ServerTitle.TextXAlignment = Enum.TextXAlignment.Left
ServerTitle.Parent = ServerInfoCard

local PlayerCount = Instance.new("TextLabel")
PlayerCount.Size = UDim2.new(0.5, -10, 0, 20)
PlayerCount.Position = UDim2.new(0, 10, 0, 35)
PlayerCount.BackgroundTransparency = 1
PlayerCount.Text = "ผู้เล่น: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
PlayerCount.TextColor3 = THEME_COLOR.TEXT
PlayerCount.TextSize = 12
PlayerCount.Font = Enum.Font.Gotham
PlayerCount.TextXAlignment = Enum.TextXAlignment.Left
PlayerCount.Parent = ServerInfoCard

local PlaceIdLabel = Instance.new("TextLabel")
PlaceIdLabel.Size = UDim2.new(0.5, -10, 0, 20)
PlaceIdLabel.Position = UDim2.new(0.5, 0, 0, 35)
PlaceIdLabel.BackgroundTransparency = 1
PlaceIdLabel.Text = "Place ID: " .. game.PlaceId
PlaceIdLabel.TextColor3 = THEME_COLOR.TEXT
PlaceIdLabel.TextSize = 12
PlaceIdLabel.Font = Enum.Font.Gotham
PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left
PlaceIdLabel.Parent = ServerInfoCard

local JobIdLabel = Instance.new("TextLabel")
JobIdLabel.Size = UDim2.new(1, -20, 0, 20)
JobIdLabel.Position = UDim2.new(0, 10, 0, 55)
JobIdLabel.BackgroundTransparency = 1
JobIdLabel.Text = "Job ID: " .. game.JobId
JobIdLabel.TextColor3 = THEME_COLOR.SECONDARY
JobIdLabel.TextSize = 11
JobIdLabel.Font = Enum.Font.Gotham
JobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
JobIdLabel.Parent = ServerInfoCard

-- === ADVANCED PLAYER MONITORING ===
local MonitorCard = Instance.new("Frame")
MonitorCard.Size = UDim2.new(1, -20, 0, 150)
MonitorCard.Position = UDim2.new(0, 10, 0, 145)
MonitorCard.BackgroundColor3 = THEME_COLOR.DARKER
MonitorCard.BackgroundTransparency = 0
Monitor
