local NPuzzle = {}

function NPuzzle.new( w, h )
	assert( type(w) == 'number' and type(h) == 'number' and w >= 2 and h >= 2, 'Width and height must be numbers >= 2' )
	local grid = {}
	for x = 1, w do
		grid[x] = {}
		for y = 1, h do
			grid[x][y] = tostring(x + (y-1)*w)
		end
	end
	grid[w][h] = ''
	return grid
end

function NPuzzle.size( grid )
	return #grid, #grid[1]
end

function NPuzzle.tostring( grid )
	local w, h = NPuzzle.size( grid )
	local t = {}
	for y = 1, h do
		t[y] = {}
	end

	local max = #tostring(w*h-1)

	for x = 1, w do
		for y = 1, h do
			local v = tonumber( grid[x][y] )
			if v then
				t[y][#t[y]+1] = ('%0' .. max .. 'd'):format( v )
			else
				t[y][#t[y]+1] = (' '):rep( max )
			end
		end
	end
	
	local result = {}
	for y = 1, h do
		result[y] = table.concat( t[y], ' ' )
	end

	return table.concat( result, '\n' )
end

function NPuzzle.hash( grid )
	local t = {}
	for x = 1, #grid do
		t[#t+1] = table.concat(grid[x],',')
	end
	return table.concat(t,';')
end

function NPuzzle.copy( grid, path )
	local w, h = NPuzzle.size( grid )
	local gridcopy = {}
	for x = 1, w do
		gridcopy[x] = {}
		for y = 1, h do
			gridcopy[x][y] = grid[x][y]
		end
	end

	local pathcopy = {}
	if path then
		for i = 1, #path do
			pathcopy[i] = path[i]
		end
	end

	return gridcopy, pathcopy
end

function NPuzzle.issolved( grid )
	local w, h = NPuzzle.size( grid )
	for x = 1, w do
		for y = 1, h do
			if not ((x==w and y==h and grid[x][y]=='') or grid[x][y] == tostring(x + (y-1)*w)) then
				return false
			end
		end
	end
	return true
end

function NPuzzle.find( grid, symbol )
	local w, h = NPuzzle.size( grid )
	for x = 1, w do
		for y = 1, h do
			if grid[x][y] == symbol then
				return x, y
			end
		end
	end
end

function NPuzzle.moves( grid )
	local x0, y0 = NPuzzle.find( grid, '' )
	local w, h = NPuzzle.size( grid )
	local moves = {}
	if x0 < w then moves[#moves+1] = {x0+1,y0} end
	if x0 > 1 then moves[#moves+1] = {x0-1,y0} end
	if y0 < h then moves[#moves+1] = {x0,y0+1} end
	if y0 > 1 then moves[#moves+1] = {x0,y0-1} end
	return moves
end

function NPuzzle.permutewhile( grid, path, predicate, random )
	grid, path = NPuzzle.copy( grid, path )
	random = random or math.random

	local nmoves = 0
	local hashes = {[NPuzzle.hash(grid)] = nmoves}
	local index = 1

	while predicate( index, grid, path, hashes ) do
		local moves = NPuzzle.moves( grid )
		local move = moves[random(#moves)]
		local x0, y0 = NPuzzle.find( grid, '' )
		local x1, y1 = move[1], move[2]
		path[#path+1] = {x0,y0}
		grid[x0][y0], grid[x1][y1] = grid[x1][y1], grid[x0][y0]		
		
		local hash = NPuzzle.hash(grid)
		local ihash = hashes[hash]
		if ihash then
			for _ = ihash, nmoves do
				table.remove( path )
			end
			nmoves = ihash
		else
			nmoves = nmoves + 1
			hashes[hash] = nmoves
		end

		index = index + 1
	end
	return grid, path
end

function NPuzzle.permute( grid, path, nperm, random )
	local function forpred( i, _, _, _ )
		return i <= nperm
	end

	assert( type(nperm) == 'number' and nperm >= 1, 'Number of permutations must be >= 1' )
	
	return NPuzzle.permutewhile( grid, path, forpred, random )
end

function NPuzzle.permutemoves( grid, path, nmoves, random )
	local function stoppred( _, _, path_, _ )
		return #path_ < nmoves
	end
	
	assert( type(nmoves) == 'number' and nmoves >= 1, 'Number of moves must be >= 1' )

	return NPuzzle.permutewhile( grid, path, stoppred, random )
end

function NPuzzle.iscorrectmove( grid, x1, y1 )
	local x0, y0 = NPuzzle.find( grid, '' )
	local w, h = NPuzzle.size( grid )
	return (x1 >= 1 and y1 >= 1 and x1 <= w and y1 <= h) and  
		(((x1 == x0+1 or x1 == x0-1) and y1 == y0) or
		(x1 == x0 and (y1 == y0-1 or y1 == y0+1)))
end

function NPuzzle.makemove( grid, path, x1, y1 )
	if NPuzzle.iscorrectmove( grid, x1, y1 ) then
		grid, path = NPuzzle.copy( grid, path )
		local x0, y0 = NPuzzle.find( grid, '' )
		grid[x0][y0],grid[x1][y1] = grid[x1][y1],grid[x0][y0]
		path[#path+1] = {x0,y0}
		return true, grid, path
	else
		return false
	end
end

function NPuzzle.undomove( grid, path )
	if #path > 0 then
		local xy = path[#path]
		local ok, grid1, path1 = NPuzzle.makemove( grid, path, xy[1], xy[2] )
		if ok then
			table.remove( path1 )
			table.remove( path1 )
			return ok, grid1, path1
		else
			return ok
		end
	else
		return false
	end
end

return NPuzzle
