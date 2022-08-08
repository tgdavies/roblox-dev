
export type Tile = {hasMine: boolean, neighborMines: number, flag: Model}
export type VecXZ = {x: number, z: number}
local m = {}
m.TILE_SIZE = 10
m.GRID_SIZE = 10
local grid : {Part} = table.create(m.GRID_SIZE)
local gridData : {Tile} = table.create(m.GRID_SIZE)
m.grid = grid
m.gridData = gridData

local insertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

function getTile(part: Part) : Tile
    local vec: VecXZ = getXZ(part)
    return gridData[vec.x][vec.z]
end

function getXZ(part: Part) : VecXZ
    return {x = part:GetAttribute("x"), z = part:GetAttribute("z")}
end

local currentTile = {};
local inHeartbeat = false;
RunService.Heartbeat:Connect(function()
    if not inHeartbeat then
        inHeartbeat = true
        local Players = game:GetService("Players")
        for i, player: Player in pairs(Players:GetPlayers()) do
            if player.Character ~= nil and player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                task.spawn(
                    function()
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {player.Character}
                        local r: RaycastResult = workspace:Raycast(
                            player.Character.HumanoidRootPart.Position, 
                            Vector3.new(0,-5,0),
                            raycastParams)
                        if r ~= nil and r.Instance.Name == "mstile" and not (currentTile[player] == r.Instance) then
                            currentTile[player] = r.Instance
                            playerOnTile(player.Character.Humanoid, r.Instance)
                        end
                    end
                )
            end
        end
        inHeartbeat = false
    end
end)

function m.setupTile(x : number, z : number)
    local part : Part = grid[x][z]
    part.Name = "mstile"
    part.Size = Vector3.new(m.TILE_SIZE,1,m.TILE_SIZE)
    part.Position = Vector3.new(x * m.TILE_SIZE, 0, z * m.TILE_SIZE)
    if (x == 1) then
        part.BrickColor = BrickColor.Yellow()
    elseif (x == m.GRID_SIZE) then
        part.BrickColor = BrickColor.Green()
    elseif (x + (z % 2)) % 2 == 0 then
        part.BrickColor = BrickColor.White()
    else
        part.BrickColor = BrickColor.Black()
    end
    part.Parent = workspace
    
    local tile : Tile = gridData[x][z]
    if x ~= 1 and x ~= m.GRID_SIZE and math.random(1,5) == 1 then
        tile.hasMine = true;
        m.eachSurrounding(x, z, function(x: number, z: number, t: Tile)
            t.neighborMines = t.neighborMines + 1
        end)
    end
end

function playerOnTile(player: Humanoid, part: Part)
    local tile: Tile = getTile(part)
    if tile.flag ~= nil and not (type(tile.flag) == "table") then
        print("destroy flag")
        tile.flag:Destroy()
        tile.flag = nil
    end
    if tile.hasMine then
        player:TakeDamage(100)
        return
    end
    part.BrickColor = BrickColor.Red()
    createSurroundingFlags(part)
end

function createSurroundingFlags(part : Part)
    local vec: VecXZ = getXZ(part)
    m.eachSurrounding(vec.x, vec.z, function(x: number, z:number, t: Tile)
        if t.flag == nil and x ~= 1 and x ~= m.GRID_SIZE then
            t.flag = {}
            local flag : Model = insertService:LoadAsset(10497015819)
            -- for i,p: Part in flag:GetDescendants() do
            --     p.CanTouch = false
            -- end
            t.flag = flag
            flag.Parent = workspace
            flag:MoveTo(Vector3.new(x * m.TILE_SIZE, 1, z * m.TILE_SIZE))
            setText(flag, "label", t.neighborMines)
            setText(flag, "label-back", t.neighborMines)
        end
    end)
end

function setText(flag: Flag, labelName: string, count: number) 
    flag:FindFirstChild(labelName, true).Text = tostring(count)
end

function m.renderTile(x: number, z: number)
    local tile : Tile = gridData[x][z]
    if tile.hasMine then
       -- grid[x][z].brickColor = BrickColor.Yellow()
    end
end

function m.eachCoordinate(f: (number, number) -> any)
    for x = 1, m.GRID_SIZE do
        for z = 1, m.GRID_SIZE do
            f(x, z)
        end
    end
end

function m.eachSurrounding(x: number, z: number, f: (number, number, Tile) -> any)
    for nx = x-1, x+1 do
        for nz = z-1, z+1 do
            if (nx ~= x or nz ~= z) and nx > 0 and nx <= m.GRID_SIZE and nz > 0 and nz <= m.GRID_SIZE then
                local t : Tile = gridData[nx][nz]
                f(nx,nz,t)
            end
        end
    end
end
return m