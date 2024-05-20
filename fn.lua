-- puts functions into tables to allow metatable magic
-- this allows:
-- - partial binds
-- - postfix calls

require("help")
require("tuple")

-- our metatable
Fn = {}

-- turns regular boring old function into magical function
-- ie a table {raw = f}
function fn(f)
	-- if f is already magical, do nothing
	if getmetatable(f) == Fn then
		return f
	end

	-- if f is not a function,
	-- make it a constant function
	if type(f) ~= "function" then
		local x = f
		f = function()
			return x
		end
	end

	-- otherwise, turn it into a table
	-- and set the appropriate metatable
	local f = {raw=f}
	setmetatable(f, Fn)
	return f
end

-- make postfix calls possible
-- ie x >> fn(f) is f(x)
function Fn.__shr(args, f)
	-- tupleize args if necessary
	local args = tuple(args)

	-- untupleize args
	-- tupleize result
	return tuple(f.raw(just(args)))
end

-- bind values to f
-- ie fn(f)(x) is the function y => f(x,y)
-- f will not be called, even if you bind enough arguments
-- use f(x)() to call f
function Fn.__call(f, ...)
	-- the arguments to be bound
	local args1 = table.pack(...)

	-- if no arguments were provided, evaluate f instead
	if args1.n == 0 then
		return just(f.raw())
	end

	-- return the partially bound function
	return function(...)
			-- the arguments to be inserted later
			local args2 = table.pack(...)

			-- the bound arguments go into the back
			local args = Help.concat_lists(args2, args1)

			-- flag arg as a tuple
			args.is_tuple = true

			-- call f at args using Fn.__shr
			return args >> f
	end >> fn(fn)
end

-- a few useful functions
-- projects a table onto some index
function pr(table, index)
	return table[index]
end

