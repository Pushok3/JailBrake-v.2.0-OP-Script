--[[
    Project: Jailbrake Script [YT:icanshowtoyou]
    Features: Categorized Sidebar UI, Team Check for Aimbot, TitleBar-only Draggable Window, Bottom-Right Local Health HUD, ESP Tracers, 2D Box ESP + Health, Always Sprint, Hitbox Expander
    Language: Luau (Roblox)
]]

-- SERVICES
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- CONFIGURATION & SETTINGS
local Settings = {
    Tracers = false,
    ESP = false,
    Aimbot = false,
    HealthHUD = false,
    AlwaysSprint = false,
    SprintSpeed = 28,
    HitboxExpander = false,
    HitboxSize = Vector3.new(6, 6, 6),
    HitboxTransparency = 0.5
}

-- CLEANUP OLD GUI IF EXISTS
if CoreGui:FindFirstChild("MacOSJailbreakHub") then
    CoreGui.MacOSJailbreakHub:Destroy()
end
if LocalPlayer.PlayerGui:FindFirstChild("MacOSJailbreakHub") then
    LocalPlayer.PlayerGui.MacOSJailbreakHub:Destroy()
end

-- MACOS UI LIBRARY CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacOSJailbreakHub"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if ScreenGui.Parent ~= CoreGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Window (Draggable disabled by default, controlled via TitleBar)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 420)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Top macOS Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

-- TITLEBAR DRAGGING IMPLEMENTATION
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Traffic Lights
local TrafficLightsContainer = Instance.new("Frame")
TrafficLightsContainer.Size = UDim2.new(0, 60, 1, 0)
TrafficLightsContainer.Position = UDim2.new(0, 12, 0, 0)
TrafficLightsContainer.BackgroundTransparency = 1
TrafficLightsContainer.Parent = TitleBar

local function createCircleButton(color, xPos)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, 12, 0, 12)
    btn.Position = UDim2.new(0, xPos, 0.5, -6)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Parent = TrafficLightsContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    return btn
end

createCircleButton(Color3.fromRGB(255, 95, 86), 0)
createCircleButton(Color3.fromRGB(255, 189, 46), 18)
createCircleButton(Color3.fromRGB(39, 201, 63), 36)

-- Centered Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.Text = "Jailbrake Script [YT:icanshowtoyou]"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = TitleBar

-- Sidebar (Left Categories)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- Pages Container Frame
local ContainerHolder = Instance.new("Frame")
ContainerHolder.Name = "ContainerHolder"
ContainerHolder.Size = UDim2.new(1, -140, 1, -45)
ContainerHolder.Position = UDim2.new(0, 140, 0, 40)
ContainerHolder.BackgroundTransparency = 1
ContainerHolder.Parent = MainFrame

-- Dictionary to store category scrolling frames
local Pages = {}
local CategoryButtons = {}
local activeCategory = "All"

local categories = {"All", "Aimbot", "Combat", "Visual"}

for _, catName in ipairs(categories) do
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name = catName .. "Scroll"
    ContentScroll.Size = UDim2.new(1, 0, 1, 0)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 450)
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.Visible = (catName == "All")
    ContentScroll.Parent = ContainerHolder

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ContentScroll

    Pages[catName] = ContentScroll
end

-- Function to switch tabs
local function switchTab(catName)
    activeCategory = catName
    for name, page in pairs(Pages) do
        page.Visible = (name == catName)
    end
    for name, btn in pairs(CategoryButtons) do
        if name == catName then
            btn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 54)
            btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
    end
end

-- Create Sidebar Buttons
for _, catName in ipairs(categories) do
    local CatBtn = Instance.new("TextButton")
    CatBtn.Size = UDim2.new(1, 0, 0, 34)
    CatBtn.BackgroundColor3 = (catName == "All") and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(45, 45, 54)
    CatBtn.BorderSizePixel = 0
    CatBtn.AutoButtonColor = false
    CatBtn.Font = Enum.Font.GothamMedium
    CatBtn.Text = catName
    CatBtn.TextColor3 = (catName == "All") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
    CatBtn.TextSize = 12
    CatBtn.Parent = Sidebar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = CatBtn
    
    CategoryButtons[catName] = CatBtn
    
    CatBtn.MouseButton1Click:Connect(function()
        switchTab(catName)
    end)
end

-- Element Universal Creator (Appends to specific category AND automatically to "All")
local function createElement(category, creatorFunc)
    creatorFunc(Pages[category])
    if category ~= "All" then
        creatorFunc(Pages["All"])
    end
end

-- Toggle Creator
local function createToggle(category, name, default, callback)
    createElement(category, function(parentScroll)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -14, 0, 42)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 54)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = parentScroll
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Position = UDim2.new(0, 14, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamMedium
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(230, 230, 235)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 40, 0, 22)
        Switch.Position = UDim2.new(1, -50, 0.5, -11)
        Switch.BackgroundColor3 = default and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(70, 70, 80)
        Switch.AutoButtonColor = false
        Switch.Text = ""
        Switch.Parent = ToggleFrame
        
        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = Switch
        
        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Parent = Switch
        
        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = Circle
        
        local state = default
        Switch.MouseButton1Click:Connect(function()
            state = not state
            Switch.BackgroundColor3 = state and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(70, 70, 80)
            Circle:TweenPosition(
                state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quart,
                0.2,
                true
            )
            callback(state)
        end)
    end)
end

-- Slider Creator
local function createSlider(category, name, min, max, default, callback)
    createElement(category, function(parentScroll)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -14, 0, 52)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 54)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = parentScroll
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 14, 0, 6)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamMedium
        Label.Text = name .. ": " .. tostring(default)
        Label.TextColor3 = Color3.fromRGB(230, 230, 235)
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -28, 0, 6)
        Track.Position = UDim2.new(0, 14, 0, 32)
        Track.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        Track.BorderSizePixel = 0
        Track.Parent = SliderFrame
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill
        
        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = UDim2.new(1, -7, 0.5, -7)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Parent = Fill
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local draggingSlider = false

        local function updateValue(input)
            local pos = input.Position.X
            local relX = math.clamp((pos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(relX, 0, 1, 0)
            local val = math.floor(min + ((max - min) * relX))
            Label.Text = name .. ": " .. tostring(val)
            callback(val)
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                updateValue(input)
            end
        end)

        Knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateValue(input)
            end
        end)
    end)
end

-- POPULATING CATEGORIES & CONTROLS
createToggle("Aimbot", "Aimbot (ShiftLock + RMB + Visible Only)", false, function(state)
    Settings.Aimbot = state
end)

createToggle("Combat", "Hitbox Expander", false, function(state)
    Settings.HitboxExpander = state
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = 1
                player.Character.HumanoidRootPart.CanCollide = true
            end
        end
    end
end)

createSlider("Combat", "Hitbox Size", 2, 20, 6, function(val)
    Settings.HitboxSize = Vector3.new(val, val, val)
end)

createSlider("Combat", "Hitbox Transparency (% x10)", 0, 10, 5, function(val)
    Settings.HitboxTransparency = val / 10
end)

createToggle("Combat", "Always Sprint (Speed 28)", false, function(state)
    Settings.AlwaysSprint = state
    if not state and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)

createToggle("Visual", "ESP Tracers", false, function(state)
    Settings.Tracers = state
end)

createToggle("Visual", "2D Box ESP + Health", false, function(state)
    Settings.ESP = state
end)

createToggle("Visual", "Health Bar HUD (Bottom-Right)", false, function(state)
    Settings.HealthHUD = state
end)

-- BOTTOM-RIGHT HEALTH HUD CREATION
local HealthHudFrame = Instance.new("Frame")
HealthHudFrame.Name = "HealthHudFrame"
HealthHudFrame.Size = UDim2.new(0, 220, 0, 65)
HealthHudFrame.Position = UDim2.new(1, -235, 1, -80)
HealthHudFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
HealthHudFrame.BackgroundTransparency = 0.25
HealthHudFrame.BorderSizePixel = 0
HealthHudFrame.Visible = false
HealthHudFrame.Parent = ScreenGui

local HealthHudCorner = Instance.new("UICorner")
HealthHudCorner.CornerRadius = UDim.new(0, 10)
HealthHudCorner.Parent = HealthHudFrame

local HealthHudStroke = Instance.new("UIStroke")
HealthHudStroke.Color = Color3.fromRGB(60, 60, 70)
HealthHudStroke.Transparency = 0.5
HealthHudStroke.Thickness = 1
HealthHudStroke.Parent = HealthHudFrame

local HealthTitle = Instance.new("TextLabel")
HealthTitle.Size = UDim2.new(1, -20, 0, 20)
HealthTitle.Position = UDim2.new(0, 12, 0, 8)
HealthTitle.BackgroundTransparency = 1
HealthTitle.Font = Enum.Font.GothamSemibold
HealthTitle.Text = "PLAYER HEALTH"
HealthTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
HealthTitle.TextSize = 11
HealthTitle.TextXAlignment = Enum.TextXAlignment.Left
HealthTitle.Parent = HealthHudFrame

local HealthValueLabel = Instance.new("TextLabel")
HealthValueLabel.Size = UDim2.new(1, -20, 0, 20)
HealthValueLabel.Position = UDim2.new(0, 0, 0, 8)
HealthValueLabel.BackgroundTransparency = 1
HealthValueLabel.Font = Enum.Font.GothamSemibold
HealthValueLabel.Text = "100 / 100"
HealthValueLabel.TextColor3 = Color3.fromRGB(48, 209, 88)
HealthValueLabel.TextSize = 11
HealthValueLabel.TextXAlignment = Enum.TextXAlignment.Right
HealthValueLabel.Parent = HealthHudFrame

local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -24, 0, 8)
HealthBarBg.Position = UDim2.new(0, 12, 0, 36)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
HealthBarBg.BorderSizePixel = 0
HealthBarBg.Parent = HealthHudFrame

local HealthBarBgCorner = Instance.new("UICorner")
HealthBarBgCorner.CornerRadius = UDim.new(1, 0)
HealthBarBgCorner.Parent = HealthBarBg

local HealthBarFill = Instance.new("Frame")
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(48, 209, 88)
HealthBarFill.BorderSizePixel = 0
HealthBarFill.Parent = HealthBarBg

local HealthBarFillCorner = Instance.new("UICorner")
HealthBarFillCorner.CornerRadius = UDim.new(1, 0)
HealthBarFillCorner.Parent = HealthBarFill

-- DRAWING STORAGE FOR ESP & TRACERS
local EspDrawings = {}

local function removeEsp(player)
    if EspDrawings[player] then
        for _, obj in pairs(EspDrawings[player]) do
            pcall(function() obj:Remove() end)
        end
        EspDrawings[player] = nil
    end
end

Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

-- HELPER: GET TEAM COLOR (Police = Blue, Criminal/Prisoner = Red/Orange)
local function getTeamColor(player)
    local teamName = player.Team and player.Team.Name or ""
    if teamName == "Police" then
        return Color3.fromRGB(0, 122, 255)
    elseif teamName == "Criminal" then
        return Color3.fromRGB(255, 69, 58)
    elseif teamName == "Prisoner" then
        return Color3.fromRGB(255, 149, 0)
    end
    return Color3.fromRGB(200, 200, 200)
end

-- HELPER: CHECK IF PLAYER IS AN ENEMY (Jailbreak Team Check)
local function isEnemy(player)
    if not LocalPlayer.Team or not player.Team then
        return true
    end
    return LocalPlayer.Team ~= player.Team
end

-- HELPER: CHECK IF SHIFT-LOCK IS ACTIVE
local function isShiftLockActive()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

-- HELPER: WALL CHECK (Raycast to verify line of sight)
local function isVisible(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then 
        return false 
    end
    local origin = LocalPlayer.Character.Head.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result then
        local hitPart = result.Instance
        if hitPart:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end

-- RENDERLOOP FOR ESP, TRACERS, AIMBOT, HUD, AND SPEED
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Always Sprint Enforcer
        if Settings.AlwaysSprint and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= Settings.SprintSpeed then
                humanoid.WalkSpeed = Settings.SprintSpeed
            end
        end

        -- Health Bar HUD Logic
        if Settings.HealthHUD then
            HealthHudFrame.Visible = true
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local health = math.max(0, math.floor(humanoid.Health))
                    local maxHealth = math.max(1, math.floor(humanoid.MaxHealth))
                    local ratio = math.clamp(health / maxHealth, 0, 1)
                    
                    HealthValueLabel.Text = tostring(health) .. " / " .. tostring(maxHealth)
                    HealthBarFill.Size = UDim2.new(ratio, 0, 1, 0)
                    HealthBarFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
                end
            end
        else
            HealthHudFrame.Visible = false
        end

        -- Hitbox Expander loop
        if Settings.HitboxExpander then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        hrp.Size = Settings.HitboxSize
                        hrp.Transparency = Settings.HitboxTransparency
                        hrp.CanCollide = false
                    end
                end
            end
        end

        -- Aimbot Logic: ShiftLock + RMB + OnScreen + Wall Check + Team Check (Enemies Only)
        if Settings.Aimbot and isShiftLockActive() and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closestPlayer = nil
            local shortestDist = math.huge
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    local head = player.Character.Head
                    if humanoid and humanoid.Health > 0 and isVisible(head) then
                        local pos, onScreen = CurrentCamera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(CurrentCamera.ViewportSize.X/2, CurrentCamera.ViewportSize.Y/2)).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
                local targetHead = closestPlayer.Character.Head
                CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, targetHead.Position)
            end
        end

        -- 2D Box ESP & Tracers Loop
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not EspDrawings[player] then
                    EspDrawings[player] = {
                        BoxOutline = Drawing.new("Square"),
                        Box = Drawing.new("Square"),
                        HealthBarBg = Drawing.new("Square"),
                        HealthBar = Drawing.new("Square"),
                        Tracer = Drawing.new("Line")
                    }
                    EspDrawings[player].BoxOutline.Thickness = 3
                    EspDrawings[player].BoxOutline.Filled = false
                    EspDrawings[player].BoxOutline.Color = Color3.new(0, 0, 0)
                    
                    EspDrawings[player].Box.Thickness = 1
                    EspDrawings[player].Box.Filled = false

                    EspDrawings[player].HealthBarBg.Thickness = 1
                    EspDrawings[player].HealthBarBg.Filled = true
                    EspDrawings[player].HealthBarBg.Color = Color3.new(0, 0, 0)

                    EspDrawings[player].HealthBar.Thickness = 1
                    EspDrawings[player].HealthBar.Filled = true

                    EspDrawings[player].Tracer.Thickness = 1
                end

                local drawings = EspDrawings[player]
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local teamColor = getTeamColor(player)

                if character and hrp and humanoid and humanoid.Health > 0 and (Settings.ESP or Settings.Tracers) then
                    local vector, onScreen = CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local head = character:FindFirstChild("Head")
                        local rootPos = hrp.Position
                        local topPos = head and head.Position + Vector3.new(0, 0.5, 0) or rootPos + Vector3.new(0, 3, 0)
                        local legPos = rootPos - Vector3.new(0, 3, 0)
                        
                        local topVector = CurrentCamera:WorldToViewportPoint(topPos)
                        local legVector = CurrentCamera:WorldToViewportPoint(legPos)
                        
                        local height = math.abs(topVector.Y - legVector.Y)
                        local width = height / 2
                        local boxX = topVector.X - width / 2
                        local boxY = topVector.Y

                        -- 2D Box ESP
                        if Settings.ESP then
                            drawings.Box.Color = teamColor

                            drawings.BoxOutline.Visible = true
                            drawings.BoxOutline.Size = Vector2.new(width, height)
                            drawings.BoxOutline.Position = Vector2.new(boxX, boxY)

                            drawings.Box.Visible = true
                            drawings.Box.Size = Vector2.new(width, height)
                            drawings.Box.Position = Vector2.new(boxX, boxY)

                            -- Health Bar
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            local barHeight = height * healthPercent
                            
                            drawings.HealthBarBg.Visible = true
                            drawings.HealthBarBg.Size = Vector2.new(4, height + 2)
                            drawings.HealthBarBg.Position = Vector2.new(boxX - 6, boxY - 1)

                            drawings.HealthBar.Visible = true
                            drawings.HealthBar.Size = Vector2.new(2, barHeight)
                            drawings.HealthBar.Position = Vector2.new(boxX - 5, boxY + (height - barHeight))
                            drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        else
                            drawings.BoxOutline.Visible = false
                            drawings.Box.Visible = false
                            drawings.HealthBarBg.Visible = false
                            drawings.HealthBar.Visible = false
                        end

                        -- Tracers
                        if Settings.Tracers then
                            drawings.Tracer.Color = teamColor
                            drawings.Tracer.Visible = true
                            drawings.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
                            drawings.Tracer.To = Vector2.new(vector.X, vector.Y)
                        else
                            drawings.Tracer.Visible = false
                        end
                    else
                        drawings.BoxOutline.Visible = false
                        drawings.Box.Visible = false
                        drawings.HealthBarBg.Visible = false
                        drawings.HealthBar.Visible = false
                        drawings.Tracer.Visible = false
                    end
                else
                    drawings.BoxOutline.Visible = false
                    drawings.Box.Visible = false
                    drawings.HealthBarBg.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.Tracer.Visible = false
                end
            end
        end
    end)
end)