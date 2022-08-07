local tile = require(script.Tile)
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
