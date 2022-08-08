
export type Tile = {hasMine: boolean, neighborMines: number, flag: Model}
export type VecXZ = {x: number, z: number}
local m = {}
m.TILE_SIZE = 8
m.GRID_SIZE = 10
local grid : {Part} = table.create(m.GRID_SIZE)
local gridData : {Tile} = table.create(m.GRID_SIZE)
m.grid = grid
m.gridData = gridData

local insertService = game:GetService("InsertService")
local PolicyService = game:GetService("PolicyService")

function getTile(part: Part) : Tile
    local vec: VecXZ = getXZ(part)
    return gridData[vec.x][vec.z]
end

function getXZ(part: Part) : VecXZ
    return {x = part:GetAttribute("x"), z = part:GetAttribute("z")}
end

local currentTouches = {};
local depth = 0

function m.setupTile(x : number, z : number)
    local part : Part = grid[x][z]
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
        part.Touched:Connect(
            function(otherPart)
                print("depth " .. tostring(depth))
                if otherPart.Parent ~= nil then
                    local player: Humanoid = otherPart.Parent:FindFirstChild("Humanoid")
                    if player ~= nil and player:GetState() ~= Enum.HumanoidStateType.Dead then
                        if currentTouches[player] == nil or currentTouches[player][part] == nil then
                            depth += 1
                            if currentTouches[player] == nil then
                                currentTouches[player] = {}
                            end
                            currentTouches[player][part] = true
                            playerOnTile(player, part)        
                            currentTouches[player][part] = nil  
                            depth -= 1
                        else
                            print("already executing")
                        end        
                    end
                end
            end
            )
        part.TouchEnded:Connect(
            function(otherPart)
                if otherPart.Parent ~= nil then
                    local player: Humanoid = otherPart.Parent:FindFirstChild("Humanoid")
                    if player ~= nil and player:GetState() ~= Enum.HumanoidStateType.Dead then
                        if currentTouches[player] ~= nil then
                            currentTouches[player][part] = nil
                        end     
                    end
                end
            end
        )
        local tile : Tile = gridData[x][z]
        if x ~= 1 and x ~= m.GRID_SIZE and math.random(1,5) == 1 then
            tile.hasMine = true;
            m.eachSurrounding(x, z, function(x: number, z: number, t: Tile)
                t.neighborMines = t.neighborMines + 1
            end)
        end
end

function playerOnTile(player: Humanoid, part: Part)
    print("Now on " .. tostring(part))
    local tile: Tile = getTile(part)
    if tile.flag ~= nil then
        tile.flag:Destroy()
        tile.flag = nil
    end
    if tile.hasMine then
        local cam = workspace.CurrentCamera
        local camCf = cam.CFrame
        cam.CFrame = camCf-camCf.LookVector*15
        player:TakeDamage(100)
        currentTouches[player] = {}
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
            local label: TextLabel = flag:FindFirstChild("label", true)
            label.Text = tostring(t.neighborMines)
            local label: TextLabel = flag:FindFirstChild("label-back", true)
            label.Text = tostring(t.neighborMines)
        end
    end)
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