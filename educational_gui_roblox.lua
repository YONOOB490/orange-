-- GUI สำหรับการศึกษา - Educational GUI for Roblox Studio
-- ใช้สำหรับการเรียนรู้ในเซิร์ฟเวอร์ส่วนตัวเท่านั้น
-- สร้าง: 2026-02-12

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- สีที่กำหนด
local COLORS = {
    background = Color3.fromRGB(20, 20, 28),
    header = Color3.fromRGB(28, 28, 38),
    border = Color3.fromRGB(70, 70, 120),
    text = Color3.fromRGB(255, 255, 255),
    tabInactive = Color3.fromRGB(35, 35, 45),
    tabActive = Color3.fromRGB(50, 50, 70),
    buttonMinimize = Color3.fromRGB(255, 165, 0),
    buttonMaximize = Color3.fromRGB(50, 205, 50),
    buttonClose = Color3.fromRGB(220, 50, 50),
    placeholderText = Color3.fromRGB(150, 150, 170)
}

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EducationalGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- สร้าง Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 340)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -170)
mainFrame.BackgroundColor3 = COLORS.background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- ขอบ UIStroke
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = COLORS.border
uiStroke.Thickness = 1
uiStroke.Parent = mainFrame

-- สร้าง Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = COLORS.header
header.BorderSizePixel = 0
header.Active = true
header.Parent = mainFrame

-- ข้อความหัวเรื่อง
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "GUI สำหรับการศึกษา"
titleLabel.TextColor3 = COLORS.text
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- ปุ่มควบคุม
local function createControlButton(name, position, color, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 28, 0, 28)
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = header

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    return button
end

local minimizeBtn = createControlButton("MinimizeBtn", UDim2.new(1, -90, 0, 3), COLORS.buttonMinimize, "-")
local maximizeBtn = createControlButton("MaximizeBtn", UDim2.new(1, -60, 0, 3), COLORS.buttonMaximize, "□")
local closeBtn = createControlButton("CloseBtn", UDim2.new(1, -30, 0, 3), COLORS.buttonClose, "×")

-- ระบบลาก
local isDragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- สร้างแท็บปุ่ม
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabContainer

local tabs = {}
local tabContents = {}
local tabNames = {"หลัก", "แสดงผล", "เครื่องมือ", "เพิ่มเติม", "ตั้งค่า"}

-- สร้างเนื้อหาแท็บ
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -10, 1, -75)
contentContainer.Position = UDim2.new(0, 5, 0, 70)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

for i, tabName in ipairs(tabNames) do
    -- ปุ่มแท็บ
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "Tab"
    tabBtn.Size = UDim2.new(0, 75, 1, 0)
    tabBtn.BackgroundColor3 = i == 1 and COLORS.tabActive or COLORS.tabInactive
    tabBtn.Text = tabName
    tabBtn.TextColor3 = COLORS.text
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.LayoutOrder = i
    tabBtn.Parent = tabContainer
    tabs[tabName] = tabBtn

    -- เนื้อหาแท็บ
    local content = Instance.new("Frame")
    content.Name = tabName .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = i == 1
    content.Parent = contentContainer
    tabContents[tabName] = content

    -- ข้อความ placeholder
    local placeholder = Instance.new("TextLabel")
    placeholder.Name = "Placeholder"
    placeholder.Size = UDim2.new(1, 0, 1, 0)
    placeholder.BackgroundTransparency = 1
    placeholder.Text = "พื้นที่ว่างสำหรับพัฒนาฟีเจอร์"
    placeholder.TextColor3 = COLORS.placeholderText
    placeholder.TextSize = 14
    placeholder.Font = Enum.Font.Gotham
    placeholder.Parent = content
end

-- ระบบสลับแท็บ
local function switchTab(activeTabName)
    for name, btn in pairs(tabs) do
        if name == activeTabName then
            btn.BackgroundColor3 = COLORS.tabActive
            tabContents[name].Visible = true
        else
            btn.BackgroundColor3 = COLORS.tabInactive
            tabContents[name].Visible = false
        end
    end
end

for name, btn in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
        -- Tween เอฟเฟกต์คลิก
        local tween = TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = COLORS.tabActive})
        tween:Play()
    end)
end

-- ระบบย่อ/ขยาย/ปิด
local isMinimized = false
local isMaximized = false
local originalSize = mainFrame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        mainFrame.Visible = false
        isMinimized = true
    end
end)

maximizeBtn.MouseButton1Click:Connect(function()
    if not isMaximized then
        mainFrame.Size = UDim2.new(0, 400, 0, 500)
        isMaximized = true
    else
        mainFrame.Size = originalSize
        isMaximized = false
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- สร้างไอคอนย่อ (Minimize Icon)
local minimizeIcon = Instance.new("TextButton")
minimizeIcon.Name = "MinimizeIcon"
minimizeIcon.Size = UDim2.new(0, 40, 0, 40)
minimizeIcon.Position = UDim2.new(1, -50, 0, 60)
minimizeIcon.BackgroundColor3 = COLORS.background
minimizeIcon.Text = "∆"
minimizeIcon.TextColor3 = COLORS.text
minimizeIcon.TextSize = 18
minimizeIcon.Font = Enum.Font.GothamBold
minimizeIcon.Visible = false
minimizeIcon.Parent = screenGui

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = COLORS.border
iconStroke.Thickness = 1
iconStroke.Parent = minimizeIcon

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 4)
iconCorner.Parent = minimizeIcon

minimizeIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    minimizeIcon.Visible = false
    isMinimized = false
end)

-- แก้ไขปุ่มย่อให้แสดงไอคอน
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizeIcon.Visible = true
    isMinimized = true
end)

-- Tween เอฟเฟกต์สำหรับปุ่มควบคุม
local function addButtonTween(button)
    button.MouseButton1Down:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 26, 0, 26)})
        tween:Play()
    end)

    button.MouseButton1Up:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 0, 28)})
        tween:Play()
    end)

    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 28, 0, 28)})
        tween:Play()
    end)
end

addButtonTween(minimizeBtn)
addButtonTween(maximizeBtn)
addButtonTween(closeBtn)

-- ข้อความแสดงเมื่อโหลดเสร็จ
print("GUI สำหรับการศึกษาโหลดเรียบร้อยแล้ว")
print("ใช้สำหรับการเรียนรู้ในเซิร์ฟเวอร์ส่วนตัวเท่านั้น")
print("โปรดเคารพกฎของเกมและผู้เล่นคนอื่น")
