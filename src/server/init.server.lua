local Teams = game:GetService("Teams")
local tile = require(script.Tile)
local spawnLocation: SpawnLocation = Instance.new("SpawnLocation")
spawnLocation.Parent = workspace
spawnLocation.CFrame = CFrame.new(
    Vector3.new(0, 0, tile.TILE_SIZE * tile.GRID_SIZE/2.0),
    Vector3.new(tile.TILE_SIZE, 5, tile.TILE_SIZE * tile.GRID_SIZE/2.0)
)
spawnLocation.Duration = 0
tile.eachCoordinate(
function(x, z)
    if (z == 1) then
        tile.grid[x] = table.create(tile.GRID_SIZE)
        tile.gridData[x] = table.create(tile.GRID_SIZE)
    end
    local part = Instance.new("Part")
    tile.grid[x][z] = part
    local t : tile.Tile = {hasMine = false, neighborMines = 0, flag = nil}
    tile.gridData[x][z] = t
    part:SetAttribute("x", x)
    part:SetAttribute("z", z)
end
)

tile.eachCoordinate(tile.setupTile)
tile.eachCoordinate(tile.renderTile)
type TeamSlot = {colour: BrickColor, inUse: boolean, team: Team}
local teamService = game:GetService("Teams")
local availableTeams: {TeamSlot} = {
    {colour = BrickColor.new("Really red"), inUse = false},
    {colour = BrickColor.new("Dark blue"), inUse = false},
    {colour = BrickColor.new("Pink"), inUse = false},
    {colour = BrickColor.new("Neon orange"), inUse = false},
    {colour = BrickColor.new("Light blue"), inUse = false},
    {colour = BrickColor.new("Turquoise"), inUse = false}
}

for i,t in ipairs(availableTeams) do
    t.team = Instance.new("Team")
    t.team.TeamColor = t.colour
    t.team.Parent = Teams
end

local playersService = game:GetService("Players")
playersService.PlayerAdded:Connect(
    function(player: Player)
        print("connected")
        local teams = teamService:GetTeams()
        local newSlot = nil
        for i, slot in ipairs(availableTeams) do
            if not slot.inUse then
                newSlot = slot
                slot.inUse = true
                break
            end
        end
        if newSlot == nil then
            player:Kick("Too many players. Sorry!")
        else
            print("Player " .. player.Name .. " joined " .. newSlot.team.TeamColor.Name)
            player.Team = newSlot.team
            player.TeamColor = newSlot.colour
        end
    end
)

playersService.PlayerRemoving:Connect(
    function(player: Player)
        for i, slot in ipairs(availableTeams) do
            if slot.team == player.Team then
                slot.inUse = false
            end
        end
    end
)
