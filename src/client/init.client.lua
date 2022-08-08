local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent: RemoteEvent = replicatedStorage:WaitForChild("GameOverEvent")
local playerGui: PlayerGui = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')

remoteEvent.OnClientEvent:Connect(
    function(code: string, player:Player)
        print("event fired")
        local label:TextLabel = playerGui:FindFirstChild("gameOverLabel", true)
        label.Text = "Game Over! " .. player.Name .. " was the winner!"
        label.Visible = true
    end
)
print("event connected to client")