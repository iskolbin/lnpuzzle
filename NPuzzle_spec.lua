local function isfunction( v ) return type( v ) == 'function' end
local function isstring( v ) return type( v ) == 'string' end
local function istable( v ) return type( v ) == 'function' end
local function isinteger( v ) return type( v ) == 'number' and math.floor( v ) == v end
local function isgrid( v ) return type( v ) == 'table' and type( v[1] ) == 'table' and v[1][1] ~= nil end

local function optional( f )
	return function( v )
		return v == nil or f( v )
	end
end

return {
	new = { isinteger, isinteger },
	size = { isgrid },
	tostring = { isgrid },
	hash = { isgrid },
	copy = { isgrid, optional( istable ) },
	issolved = { isgrid },
	find = { isgrid, isstring },
	moves = { isgrid },
	permutewhile = { isgrid, istable, isfunction, optional( isfunction ) },
	permute = { isgrid, istable, isinteger, optional( isfunction ) },
	permutemoves = { isgrid, istable, isinteger, optional( isfunction ) },
	iscorrectmove = { isgrid, isinteger, isinteger },
	makemove = { isgrid, istable, isinteger, isinteger },
	undomove = { isgrid, istable },
}
