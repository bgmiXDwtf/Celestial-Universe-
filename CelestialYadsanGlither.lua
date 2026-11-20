
local textChatService = game:GetService("TextChatService")

local v1 = game
local v2 = {
"CELESTIAL GLITCHER MADE BY YADSAN //USER: "
.. (v1.GetService(v1, "Players")).LocalPlayer.Name,
"FE SCRIPT FOR R6 ONLY USE IT AND FARM AURA ", "CELESTIAL SYNDICATE ON TOP",
"//WORKS IN DELTA ONLY \\", "Yadsan_Godverse",
}
local function f1(p1)
    local v3 = p1
    local v4 = textChatService
    local v5, v6
    local replicatedStorage, defaultChatSystemChatEvents
    if textChatService and textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local rbxGeneral
        rbxGeneral = textChatService.TextChannels:FindFirstChild("RBXGeneral")
        if rbxGeneral then
            rbxGeneral:SendAsync(p1)
            return
        else
            ::L12371649::
            replicatedStorage = game:GetService("ReplicatedStorage")
            defaultChatSystemChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if defaultChatSystemChatEvents then
                local sayMessageRequest
                sayMessageRequest = defaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                local v7
                v7 = sayMessageRequest
                if sayMessageRequest and sayMessageRequest:IsA("RemoteEvent") then
                    sayMessageRequest:FireServer(p1, "All")
                end
            end
            return
        end
    else
        goto L12371649
    end
end
task.spawn(function()
    for index, value in ipairs(v2) do
        f1(value)
        task.wait(1.25)
    end
    local v8 = {
    pcall(function()
        ;(loadstring(game:HttpGet("https://raw.githubusercontent.com/yadsanpapa/Celestial-Universe-/refs/heads/main/CelestialLast%E2%98%85Star.lua")))()
        return
    end),
    }
    local v9 = v8[2]
    if not v8[1] then
        warn("Failed to execute external script: " .. (tostring(v9)))
    end
    return
end)
return
