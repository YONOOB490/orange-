-- SoundHub Music Player v7.2 | Fixed Minimize Button + All Maps Support
-- ⚠️ เสียงได้ยินเฉพาะคุณเท่านั้น (Client-Side Only)
-- ✅ ทำงานได้ทุกแมพ ไม่ต้องใช้ BoomBox!

-- ตั้งค่าเริ่มต้น
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MusicPlayerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- เฟรมหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 165)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -82)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = ""
TitleBar.Parent = MainFrame

-- ชื่อ
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎵 SoundHub Player"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- ปุ่มปิด
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.AutoButtonColor = false
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

-- ปุ่มย่อ (แก้บัค: ใส่ Parent ให้ถูกตำแหน่ง)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -60, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 140, 255)
MinimizeButton.AutoButtonColor = false
MinimizeButton.Text = "−"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Parent = MainFrame -- ✅ ใส่ Parent ถูกตำแหน่งแล้ว

-- คำเตือน
local WarningLabel = Instance.new("TextLabel")
WarningLabel.Size = UDim2.new(1, -20, 0, 14)
WarningLabel.Position = UDim2.new(0, 10, 0, 37)
WarningLabel.BackgroundTransparency = 1
WarningLabel.Text = "⚠️ เสียงได้ยินเฉพาะคุณเท่านั้น"
WarningLabel.Font = Enum.Font.Gotham
WarningLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
WarningLabel.TextSize = 9
WarningLabel.TextXAlignment = Enum.TextXAlignment.Center
WarningLabel.Parent = MainFrame

-- กล่องใส่ ID
local IDBox = Instance.new("TextBox")
IDBox.Size = UDim2.new(1, -20, 0, 32)
IDBox.Position = UDim2.new(0, 10, 0, 55)
IDBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
IDBox.PlaceholderText = "ใส่รหัสเพลง Roblox..."
IDBox.Text = ""
IDBox.Font = Enum.Font.Gotham
IDBox.TextColor3 = Color3.fromRGB(200, 200, 200)
IDBox.TextSize = 13
IDBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = IDBox

-- ปุ่มเล่น
local PlayButton = Instance.new("TextButton")
PlayButton.Size = UDim2.new(0.48, 0, 0, 30)
PlayButton.Position = UDim2.new(0, 10, 0, 92)
PlayButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
PlayButton.AutoButtonColor = false
PlayButton.Text = "▶️ เล่น"
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.TextSize = 12
PlayButton.Parent = MainFrame

-- ปุ่มหยุด
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.48, 0, 0, 30)
StopButton.Position = UDim2.new(0.52, 0, 0, 92)
StopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
StopButton.AutoButtonColor = false
StopButton.Text = "⏹️ หยุด"
StopButton.Font = Enum.Font.GothamBold
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 12
StopButton.Parent = MainFrame

-- ✅ กล่องใส่ระดับเสียง (0-250%)
local VolumeLabel = Instance.new("TextLabel")
VolumeLabel.Size = UDim2.new(0.3, 0, 0, 25)
VolumeLabel.Position = UDim2.new(0, 10, 0, 130)
VolumeLabel.BackgroundTransparency = 1
VolumeLabel.Text = "💥 เสียง:"
VolumeLabel.Font = Enum.Font.GothamBold
VolumeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
VolumeLabel.TextSize = 11
VolumeLabel.TextXAlignment = Enum.TextXAlignment.Left
VolumeLabel.Parent = MainFrame

local VolumeInputBox = Instance.new("TextBox")
VolumeInputBox.Size = UDim2.new(0.2, 0, 0, 25)
VolumeInputBox.Position = UDim2.new(0.32, 0, 0, 130)
VolumeInputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
VolumeInputBox.Text = "50"
VolumeInputBox.Font = Enum.Font.Gotham
VolumeInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
VolumeInputBox.TextSize = 12
VolumeInputBox.Parent = MainFrame

local VolumePercent = Instance.new("TextLabel")
VolumePercent.Size = UDim2.new(0.4, 0, 0, 25)
VolumePercent.Position = UDim2.new(0.54, 0, 0, 130)
VolumePercent.BackgroundTransparency = 1
VolumePercent.Text = "% (0-250)"
VolumePercent.Font = Enum.Font.Gotham
VolumePercent.TextColor3 = Color3.fromRGB(150, 150, 150)
VolumePercent.TextSize = 9
VolumePercent.TextXAlignment = Enum.TextXAlignment.Left
VolumePercent.Parent = MainFrame

local VolumeCorner = Instance.new("UICorner")
VolumeCorner.CornerRadius = UDim.new(0, 6)
VolumeCorner.Parent = VolumeInputBox

-- ตัวแปร
local currentSound = nil
local isMinimized = false
local currentVolume = 0.5

-- ฟังก์ชัน Tween (ลื่นสุด!)
local function tween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, props):Play()
end

local function notify(text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = "🎵 SoundHub";
        Text = text;
        Duration = duration or 3;
    })
end

-- ✅ ฟังก์ชันอัปเดตเสียง (250%)
local function updateVolume()
    local text = VolumeInputBox.Text
    local number = tonumber(text)
    
    if number then
        currentVolume = math.clamp(number / 100, 0, 2.5)
        
        if currentVolume > 1.5 then
            VolumeInputBox.TextColor3 = Color3.fromRGB(255, 100, 100)
        elseif currentVolume > 1 then
            VolumeInputBox.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            VolumeInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        if currentSound then
            currentSound.Volume = currentVolume
        end
        
        VolumeInputBox.Text = tostring(math.round(currentVolume * 100))
    else
        VolumeInputBox.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- ✅ ฟังก์ชันเล่นเพลง (ทำงานได้ทุกแมพ!)
local function playMusic(musicId)
    -- ล้างเพลงเก่า
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
    end
    
    -- ✅ สร้างเสียงใหม่ใน SoundService (ไม่ต้องใช้ BoomBox!)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. musicId
    sound.Parent = SoundService -- ใช้ SoundService แทน Workspace
    
    -- โหลดเสียง
    local success = pcall(function()
        sound.Loaded:Wait()
        currentSound = sound
        currentSound.Volume = currentVolume
        currentSound:Play()
        notify("✅ กำลังเล่นเพลง ID: " .. musicId, 3)
        
        currentSound.Ended:Connect(function()
            notify("⏹️ เพลงเล่นจบแล้ว", 2)
        end)
    end)
    
    if not success then
        notify("❌ ไม่พบเพลงหรือ ID ผิด", 3)
    end
end

-- ✅ Events ทั้งหมด

-- ปุ่มเล่น
PlayButton.MouseButton1Click:Connect(function()
    local id = IDBox.Text:match("%d+")
    if id and tonumber(id) then
        playMusic(tonumber(id))
    else
        notify("❌ กรุณาใส่ ID ให้ถูกต้อง", 3)
    end
end)

-- ปุ่มหยุด
StopButton.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
        notify("⏹️ หยุดเล่นเพลงแล้ว", 2)
    end
end)

-- ปุ่มปิด
CloseButton.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound:Destroy()
    end
    tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
    wait(0.3)
    ScreenGui:Destroy()
    notify("👋 ปิด SoundHub แล้ว", 2)
end)

-- ปุ่มย่อ (แก้บัค: ใช้ Tween + visible ให้ถูกต้อง)
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- ย่อแบบลื่นๆ
        tween(MainFrame, {Size = UDim2.new(0, 320, 0, 35)}, 0.3)
        wait(0.15)
        IDBox.Visible = false
        PlayButton.Visible = false
        StopButton.Visible = false
        VolumeLabel.Visible = false
        VolumeInputBox.Visible = false
        VolumePercent.Visible = false
        WarningLabel.Visible = false
    else
        -- ขยายแบลื่นๆ
        tween(MainFrame, {Size = UDim2.new(0, 320, 0, 165)}, 0.3)
        wait(0.15)
        IDBox.Visible = true
        PlayButton.Visible = true
        StopButton.Visible = true
        VolumeLabel.Visible = true
        VolumeInputBox.Visible = true
        VolumePercent.Visible = true
        WarningLabel.Visible = true
    end
end)

-- กล่องระดับเสียง
VolumeInputBox.FocusLost:Connect(function()
    updateVolume()
    local vol = math.round(currentVolume * 100)
    if vol > 100 then
        notify("🔊 ปรับเสียงเป็น " .. vol .. "% (สูงมาก!)", 3)
    else
        notify("🔊 ปรับเสียงเป็น " .. vol .. "%", 2)
    end
end)

-- Hover Effects (ลื่นสุด!)
PlayButton.MouseEnter:Connect(function()
    tween(PlayButton, {BackgroundColor3 = Color3.fromRGB(0, 230, 0)}, 0.15)
end)
PlayButton.MouseLeave:Connect(function()
    tween(PlayButton, {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}, 0.15)
end)

StopButton.MouseEnter:Connect(function()
    tween(StopButton, {BackgroundColor3 = Color3.fromRGB(230, 0, 0)}, 0.15)
end)
StopButton.MouseLeave:Connect(function()
    tween(StopButton, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}, 0.15)
end)

CloseButton.MouseEnter:Connect(function()
    tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.15)
end)
CloseButton.MouseLeave:Connect(function()
    tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}, 0.15)
end)

MinimizeButton.MouseEnter:Connect(function()
    tween(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(100, 170, 255)}, 0.15)
end)
MinimizeButton.MouseLeave:Connect(function()
    tween(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(70, 140, 255)}, 0.15)
end)

-- ตั้งค่าเริ่มต้น
VolumeInputBox.Text = "50"
updateVolume(0.5)

-- แจ้งเตือน
notify("🎵 SoundHub พร้อมใช้งาน!", 3)
notify("⚠️ เสียงได้ยินเฉพาะคุณเท่านั้น", 5)
notify("✅ ทำงานได้ทุกแมพ ไม่ต้องใช้ BoomBox!", 4)
