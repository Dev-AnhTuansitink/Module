-- =====================================================================
-- SUPER POTATO MODE & PERFORMANCE BOOSTER (SAFE VERSION)
-- Đã thêm pcall, tối ưu vòng lặp và format chuẩn xác
-- =====================================================================

-- 1. Đợi game tải hoàn tất an toàn
pcall(function()
    repeat task.wait() until game:IsLoaded()
end)

-- 2. Khởi tạo các Services cần thiết
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace.Terrain
local LocalPlayer = Players.LocalPlayer

-- 3. Xử lý các sự kiện thu phóng cửa sổ (Sửa lỗi thiếu hàm ở bản gốc)
local function WindowFocusReleasedFunction()
    -- Thêm logic giảm FPS khi alt-tab ra ngoài ở đây (nếu cần)
end

local function WindowFocusedFunction()
    -- Khôi phục FPS khi quay lại màn hình game
end

pcall(function()
    UserInputService.WindowFocusReleased:Connect(WindowFocusReleasedFunction)
    UserInputService.WindowFocused:Connect(WindowFocusedFunction)
    UserSettings():GetService("UserGameSettings").MasterVolume = 0 -- Tắt âm lượng
end)

-- ===============================
-- HẠ CẤP MÔI TRƯỜNG & ÁNH SÁNG
-- ===============================
pcall(function()
    -- Sử dụng sethiddenproperty (nếu executor hỗ trợ)
    if sethiddenproperty then
        pcall(function() sethiddenproperty(Lighting, "Technology", 2) end)
        pcall(function() sethiddenproperty(Terrain, "Decoration", false) end)
    end
    
    -- Tắt hiệu ứng nước và ánh sáng
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- Xóa các hiệu ứng hậu kỳ trong Lighting
for _, effect in ipairs(Lighting:GetChildren()) do
    pcall(function()
        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end)
end

-- ===============================
-- TỐI ƯU HÓA VẬT THỂ (XÓA ĐỒ HỌA)
-- ===============================
local decalsyeeted = true

-- Hàm xử lý chung để tái sử dụng cho cả đồ họa cũ và đồ họa mới sinh ra
local function OptimizeObject(v)
    pcall(function()
        -- 1. Biến mọi thứ thành vô hình (Transparency = 1)
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end

        -- 2. Tước bỏ vật liệu và kết cấu
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif v:IsA("MeshPart") and decalsyeeted then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.TextureID = "rbxassetid://10385902758728957"
        elseif v:IsA("SpecialMesh") and decalsyeeted then
            v.TextureId = ""
        elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
            v.Texture = ""
            
        -- 3. Xóa hiệu ứng VFX
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
            
        -- 4. Xóa quần áo
        elseif v:IsA("ShirtGraphic") and decalsyeeted then
            v.Graphic = ""
        elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
            v[v.ClassName.."Template"] = ""
        end
    end)
end

-- Áp dụng cho các vật thể đang có sẵn trong map
for _, v in ipairs(Workspace:GetDescendants()) do
    OptimizeObject(v)
end

-- Áp dụng cho các vật thể mới được sinh ra (Tránh lag khi map load thêm)
Workspace.DescendantAdded:Connect(OptimizeObject)


-- ===============================
-- FAST MODE & TẮT GAME VFX
-- ===============================

-- ========= FAST MODE =========
local function EnableFastMode()
    if _G.FastMode then return end
    pcall(function()
        _G.FastMode = true
        _G.reducing = true
        _G.FastModeCache = {}

        local Map = Workspace:FindFirstChild("Map")
        local Unloaded = ReplicatedStorage:FindFirstChild("Unloaded")
        local SmoothPlastic = Enum.Material.SmoothPlastic

        local function BatchOptimize(folder)
            if not folder then return end
            local start = os.clock()
            for _, obj in ipairs(folder:GetDescendants()) do
                pcall(function()
                    if obj:IsA("BasePart") then
                        _G.FastModeCache[obj] = obj.Material
                        obj.Material = SmoothPlastic
                    elseif obj:IsA("Texture") and not obj:GetAttribute("Offset") then
                        obj:Destroy()
                    end
                end)

                -- Tránh khựng game (timeout yield) khi quét quá nhiều vật thể
                if os.clock() - start > 0.008 then
                    task.wait()
                    start = os.clock()
                end
            end
        end

        BatchOptimize(Map)
        BatchOptimize(Unloaded)

        -- Kích hoạt Actor tối ưu hóa của game (nếu có)
        local Optimizer = LocalPlayer and LocalPlayer.PlayerScripts:FindFirstChild("OptimizerClientActor")
        if Optimizer and Optimizer:IsA("Actor") then
            pcall(function() Optimizer:SendMessage("Optimize", true) end)
        end

        warn("⚡ FastMode ENABLED")
    end)
end

-- ========= TẮT ALLY VFX =========
local function DisableVFX()
    pcall(function()
        if LocalPlayer then
            LocalPlayer:SetAttribute("DisableAllyEffects", true)
            warn("❌ Ally VFX DISABLED")
        end
    end)
end

-- ========= TẮT CAMERA SHAKE =========
local function DisableCameraShake()
    pcall(function()
        local Util = ReplicatedStorage:FindFirstChild("Util")
        if Util then
            if Util:FindFirstChild("CameraShake") then
                local cs1 = require(Util.CameraShake)
                if cs1 and type(cs1) == "table" and cs1.SetEnabled then cs1:SetEnabled(false) end
            end
            if Util:FindFirstChild("CameraShaker") then
                local cs2 = require(Util.CameraShaker)
                if cs2 and type(cs2) == "table" and cs2.SetEnabled then cs2:SetEnabled(false) end
            end
        end
    end)

    pcall(function()
        ReplicatedStorage.Remotes.ChangeSetting:FireServer("CameraShake", false)
    end)

    warn("❌ CameraShake DISABLED")
end

-- ========= TẮT NHẠC NỀN =========
local function DisableMusic()
    pcall(function()
        ReplicatedStorage.Events.ToggleMusic.Event:Fire(true)
    end)

    pcall(function()
        local WorldOrigin = Workspace:FindFirstChild("_WorldOrigin")
        if WorldOrigin and WorldOrigin:FindFirstChild("Sounds") then
            for _, s in ipairs(WorldOrigin.Sounds.Locations:GetChildren()) do
                if s:IsA("Sound") then
                    s:Pause()
                end
            end
        end
    end)

    warn("🔇 Background Music DISABLED")
end

-- ========= KÍCH HOẠT TOÀN BỘ =========
EnableFastMode()
DisableVFX()
DisableCameraShake()
DisableMusic()