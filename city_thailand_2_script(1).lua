--[[
    City Thailand 2 - LocalPlayer Script
    Compatible with: Synapse X, Krnl, Fluxus, Delta, Arceus X
    Features: Mobile-Optimized GUI, Teleportation, Auto-Interactions
    Version: 2025-2026
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LocalPlayer
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")

-- Game Verification
local GAME_PLACE_ID = 4503309821
local isCorrectGame = game.PlaceId == GAME_PLACE_ID

-- Anti-Detection Variables
local ScriptEnabled = true
local GUIVisible = true
local Minimized = false
local MainFrame = nil
local MinimizeButton = nil
local OriginalFrameSize = nil
local OriginalFramePosition = nil

-- Utility Functions
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[CityThailand2] Error: " .. tostring(result))
    end
    return success, result
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

-- Safe Teleport Function
local function SafeTeleport(position)
    if not ScriptEnabled then return end
    local root = GetRootPart()
    if root and position then
        SafeCall(function()
            root.CFrame = CFrame.new(position)
        end)
    end
end

-- GUI Creation
local function CreateGUI()
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CT2_GUI_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    
    -- Parent to CoreGui for executor compatibility
    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = PlayerGui
    end
    
    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Corner Radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 170, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(0.6, 0, 1, 0)
    TitleText.Position = UDim2.new(0.05, 0, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "City Thailand 2"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0.6, 0, 0, 16)
    Subtitle.Position = UDim2.new(0.05, 0, 0.6, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Mobile Optimized"
    Subtitle.TextColor3 = Color3.fromRGB(0, 170, 255)
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TitleBar
    
    -- Close Button (X)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Minimize Button (-)
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -80, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = TitleBar
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 8)
    MinimizeCorner.Parent = MinimizeBtn
    
    -- Content Frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 55)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    ContentFrame.Parent = MainFrame
    
    -- UI List Layout
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Parent = ContentFrame
    
    -- Function to create section headers
    local function CreateSection(text)
        local Section = Instance.new("TextLabel")
        Section.Size = UDim2.new(0.9, 0, 0, 25)
        Section.BackgroundTransparency = 1
        Section.Text = text
        Section.TextColor3 = Color3.fromRGB(0, 170, 255)
        Section.TextSize = 14
        Section.Font = Enum.Font.GothamBold
        Section.TextXAlignment = Enum.TextXAlignment.Left
        Section.Parent = ContentFrame
        return Section
    end
    
    -- Function to create buttons
    local function CreateButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.9, 0, 0, 45)
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.Font = Enum.Font.GothamSemibold
        Button.Parent = ContentFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 10)
        ButtonCorner.Parent = Button
        
        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = Color3.fromRGB(60, 60, 80)
        ButtonStroke.Thickness = 1
        ButtonStroke.Parent = Button
        
        -- Hover effect
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 80)}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return Button
    end
    
    -- Function to create toggle switches
    local function CreateToggle(text, defaultState, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(0.9, 0, 0, 45)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        ToggleFrame.Parent = ContentFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 10)
        ToggleCorner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Position = UDim2.new(0.05, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.GothamSemibold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
        ToggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
        ToggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 100)
        ToggleBtn.Text = defaultState and "ON" or "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 12
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.Parent = ToggleFrame
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(0, 13)
        ToggleBtnCorner.Parent = ToggleBtn
        
        local state = defaultState
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 100)
            ToggleBtn.Text = state and "ON" or "OFF"
            callback(state)
        end)
        
        return ToggleFrame, function() return state end
    end
    
    -- TELEPORTATION SECTION
    CreateSection("Teleportation")
    
    CreateButton("Teleport to Spawn", function()
        local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
        if spawnLocation then
            SafeTeleport(spawnLocation.Position + Vector3.new(0, 5, 0))
        else
            -- Try to find any spawn
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("SpawnLocation") then
                    SafeTeleport(obj.Position + Vector3.new(0, 5, 0))
                    break
                end
            end
        end
    end)
    
    CreateButton("Teleport to Hospital", function()
        -- Search for hospital-related parts
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("hospital") or name:find("โรงบาล") or name:find("medical") then
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position)
                    if pos then
                        SafeTeleport(pos + Vector3.new(0, 5, 0))
                        break
                    end
                end
            end
        end
    end)
    
    CreateButton("Teleport to Helicopter", function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("helicopter") or name:find("heli") or name:find("ฮอ") then
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local pos = obj:IsA("BasePart") and obj.Position or (obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position)
                    if pos then
                        SafeTeleport(pos + Vector3.new(0, 10, 0))
                        break
                    end
                end
            end
        end
    end)
    
    -- AUTOMATION SECTION
    CreateSection("Automation")
    
    local autoInteract = false
    CreateToggle("Auto Interact", false, function(state)
        autoInteract = state
    end)
    
    local autoFarm = false
    CreateToggle("Auto Farm (Safe)", false, function(state)
        autoFarm = state
    end)
    
    -- PLAYER SECTION
    CreateSection("Player")
    
    CreateButton("Reset Character", function()
        local char = GetCharacter()
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end)
    
    CreateButton("Full Brightness", function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.FogStart = 0
    end)
    
    -- UTILITY SECTION
    CreateSection("Utility")
    
    CreateButton("Scan Workspace", function()
        local items = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                table.insert(items, obj.Name)
            end
        end
        print("[CityThailand2] Workspace scan complete. Found " .. #items .. " objects.")
    end)
    
    CreateButton("Copy Position", function()
        local root = GetRootPart()
        if root then
            local pos = root.Position
            local posString = string.format("Vector3.new(%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
            print("[CityThailand2] Position: " .. posString)
        end
    end)
    
    -- Minimized Button (Hidden initially)
    MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizedButton"
    MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizeButton.Position = UDim2.new(1, -50, 0, 10)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    MinimizeButton.Text = "CT2"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 12
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Visible = false
    MinimizeButton.Parent = ScreenGui
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 8)
    MinBtnCorner.Parent = MinimizeButton
    
    local MinBtnStroke = Instance.new("UIStroke")
    MinBtnStroke.Color = Color3.fromRGB(255, 255, 255)
    MinBtnStroke.Thickness = 2
    MinBtnStroke.Parent = MinimizeButton
    
    -- Close Button Logic
    CloseButton.MouseButton1Click:Connect(function()
        ScriptEnabled = false
        ScreenGui:Destroy()
    end)
    
    -- Minimize Logic
    OriginalFrameSize = MainFrame.Size
    OriginalFramePosition = MainFrame.Position
    
    local function MinimizeGUI()
        Minimized = true
        MainFrame.Visible = false
        MinimizeButton.Visible = true
        
        -- Animate minimize button appearance
        MinimizeButton.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MinimizeButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 40, 0, 40)
        }):Play()
    end
    
    local function RestoreGUI()
        Minimized = false
        MinimizeButton.Visible = false
        MainFrame.Visible = true
        
        -- Animate main frame appearance
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = OriginalFrameSize,
            Position = OriginalFramePosition
        }):Play()
    end
    
    MinimizeBtn.MouseButton1Click:Connect(MinimizeGUI)
    MinimizeButton.MouseButton1Click:Connect(RestoreGUI)
    
    -- Mobile Touch Support for Minimize Button
    MinimizeButton.TouchTap:Connect(RestoreGUI)
    
    -- Auto Interact Loop
    spawn(function()
        while ScriptEnabled do
            if autoInteract then
                -- Auto-interact with nearby objects
                local char = GetCharacter()
                local root = GetRootPart()
                if char and root then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                local distance = (parent.Position - root.Position).Magnitude
                                if distance <= obj.MaxActivationDistance then
                                    pcall(function()
                                        fireproximityprompt(obj)
                                    end)
                                end
                            end
                        end
                        -- Check for ClickDetectors
                        if obj:IsA("ClickDetector") then
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                local distance = (parent.Position - root.Position).Magnitude
                                if distance <= obj.MaxActivationDistance then
                                    pcall(function()
                                        fireclickdetector(obj)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            wait(0.5)
        end
    end)
    
    -- Auto Farm Loop
    spawn(function()
        while ScriptEnabled do
            if autoFarm then
                -- Safe farming logic - collect nearby items
                local char = GetCharacter()
                local root = GetRootPart()
                if char and root then
                    -- Look for collectible items
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local name = obj.Name:lower()
                        -- Common collectible patterns
                        if name:find("coin") or name:find("money") or name:find("cash") or 
                           name:find("collect") or name:find("item") or name:find("drop") then
                            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                                local distance = (obj.Position - root.Position).Magnitude
                                if distance <= 50 then
                                    -- Teleport to item
                                    SafeTeleport(obj.Position + Vector3.new(0, 3, 0))
                                    wait(0.3)
                                end
                            end
                        end
                    end
                end
            end
            wait(1)
        end
    end)
    
    -- Character Respawn Handler
    LocalPlayer.CharacterAdded:Connect(function(char)
        if ScriptEnabled then
            wait(1) -- Wait for character to load
            -- GUI persists through respawn due to ResetOnSpawn = false
        end
    end)
    
    -- Anti-Detection: Randomize GUI name on creation
    spawn(function()
        while ScriptEnabled and ScreenGui and ScreenGui.Parent do
            wait(math.random(30, 60))
            if ScreenGui and ScreenGui.Parent then
                ScreenGui.Name = "CT2_GUI_" .. tostring(math.random(1000, 9999))
            end
        end
    end)
    
    return ScreenGui
end

-- Initialize
local function Initialize()
    if not isCorrectGame then
        warn("[CityThailand2] Warning: This script is designed for City Thailand 2 (Place ID: " .. GAME_PLACE_ID .. ")")
        warn("[CityThailand2] Current Place ID: " .. game.PlaceId)
    end
    
    -- Wait for game to load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    wait(1) -- Additional safety delay
    
    -- Create GUI
    local gui = CreateGUI()
    
    print("[CityThailand2] Script loaded successfully!")
    print("[CityThailand2] GUI created and ready.")
    
    return gui
end

-- Execute
return Initialize()
