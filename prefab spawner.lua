-------------------------------
--  SINGLETON / SCRIPT CLEANER
-------------------------------

-- If an older version is running, kill it
if getgenv().ToolSpawnerRunning then

    -- Kill old threads
    for _, thread in ipairs(getgenv().ToolSpawnerThreads or {}) do
        pcall(function()
            coroutine.close(thread)
        end)
    end

    -- Destroy old GUI
    if getgenv().ToolSpawnerGUI then
        pcall(function()
            getgenv().ToolSpawnerGUI:Destroy()
        end)
    end
end

-- Mark new instance
getgenv().ToolSpawnerRunning = true
getgenv().ToolSpawnerThreads = {}

-- Thread tracker
local function track(fn)
    local t = coroutine.create(fn)
    table.insert(getgenv().ToolSpawnerThreads, t)
    coroutine.resume(t)
end

-------------------------------
--  TOOL FINDER + SPAWNER
-------------------------------

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Find all tools in the entire game
local function FindAllTools()
    local found = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("Tool") then
            table.insert(found, obj)
        end
    end
    return found
end

-- Spawn a single tool
local function SpawnTool(tool)
    local clone = tool:Clone()
    clone.Parent = Backpack
end

-------------------------------
--  GUI CREATION (ImGui Style)
-------------------------------

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
getgenv().ToolSpawnerGUI = ScreenGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 450)
Frame.Position = UDim2.new(0.5, -175, 0.5, -225)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Tool Spawner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 20

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.BackgroundTransparency = 1

-------------------------------
--  TOOL BUTTON CREATOR
-------------------------------

local function AddToolButtons()
    local tools = FindAllTools()
    local y = 5

    for _, tool in ipairs(tools) do
        local Button = Instance.new("TextButton", Scroll)
        Button.Size = UDim2.new(1, -10, 0, 40)
        Button.Position = UDim2.new(0, 5, 0, y)
        Button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Code
        Button.TextSize = 18
        Button.Text = "Spawn: " .. tool.Name

        Button.MouseButton1Click:Connect(function()
            SpawnTool(tool)
        end)

        y = y + 45
    end

    Scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-------------------------------
--  LOAD PREFABS BUTTON
-------------------------------

local LoadButton = Instance.new("TextButton", Scroll)
LoadButton.Size = UDim2.new(1, -10, 0, 40)
LoadButton.Position = UDim2.new(0, 5, 0, 5)
LoadButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.Font = Enum.Font.Code
LoadButton.TextSize = 18
LoadButton.Text = "Load Prefabs"

LoadButton.MouseButton1Click:Connect(function()
    LoadButton.Visible = false
    AddToolButtons()
end)
