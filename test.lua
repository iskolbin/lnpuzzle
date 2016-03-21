local NPuzzle = require('NPuzzle')

print( 'Making minimal 2x2 board' )
local p3 = NPuzzle.new( 2, 2 )
print( NPuzzle.tostring(p3))
print( 'Checking moves (sanity check)' )
print( 'Move 1,1:', NPuzzle.iscorrectmove( p3, 1, 1 ))
print( 'Move 2,1:', NPuzzle.iscorrectmove( p3, 2, 1 ))
print( 'Move 1,2:', NPuzzle.iscorrectmove( p3, 1, 2 ))
print( 'Move 2,2:', NPuzzle.iscorrectmove( p3, 2, 2 ))
assert( NPuzzle.iscorrectmove(p3,1,2) and NPuzzle.iscorrectmove(p3,2,1))
assert( not( NPuzzle.iscorrectmove(p3,1,1) or NPuzzle.iscorrectmove(p3,2,2)))

print( 'List of available moves:' )
local moves = NPuzzle.moves( p3 )
for _, xy in ipairs(moves) do
	print( '', xy[1], xy[2] )
end

local p15 = NPuzzle.new( 4, 4 )
print( 'Making classic 15-puzzle' )
print( NPuzzle.tostring(p15))
print( 'By default puzzle is solved' )
assert( NPuzzle.issolved(p15))

local nperm = 200
print( 'Making ' .. nperm .. ' permutations' )
local p15A, path = NPuzzle.permute( p15, {}, nperm )

print( NPuzzle.tostring( p15A ))

print( 'Path length == number of permutations?', #path == nperm )
print( 'Optimized path length: ', #path )
print( 'Unwinding moves' )
print( 'Path:' )
for i = 1, #path do
	io.write( ('(%d,%d)'):format( path[i][1], path[i][2] ))
end
print()

local ok, p15B = true, p15A
while #path > 0 do
	local oldp15, oldpath = p15B, path
	ok, p15B, path = NPuzzle.undomove( p15B, path )
	
	if not ok then
		print( 'Error during unwind process on step', nperm - #oldpath  )
		print( 'Final configuration' )
		print( NPuzzle.tostring( oldp15 ))
		error()
	end
end
print( NPuzzle.tostring( p15B ))

print( 'After unwinding puzzle must be solved', NPuzzle.issolved( p15B ))


p15 = NPuzzle.new(4,4)
nperm = 100
print( 'Making permutations for ' .. nperm .. ' moves' )
p15A, path = NPuzzle.permutemoves( p15, {}, nperm )

print( NPuzzle.tostring( p15A ))

print( 'Path length == number of permutations?', #path == nperm )
print( 'Optimized path length: ', #path )
print( 'Unwinding moves' )
print( 'Path:' )
for i = 1, #path do
	io.write( ('(%d,%d)'):format( path[i][1], path[i][2] ))
end
print()

ok, p15B, path = true, p15A, path
while #path > 0 do
	local oldp15, oldpath = p15B, path
	ok, p15B, path = NPuzzle.undomove( p15B, path )
	
	if not ok then
		print( 'Error during unwind process on step', nperm - #oldpath  )
		print( 'Final configuration' )
		print( NPuzzle.tostring( oldp15 ))
		error()
	end
end
print( NPuzzle.tostring( p15B ))

print( 'After unwinding puzzle must be solved', NPuzzle.issolved( p15B ))
