-- parses while parser passes
-- nodes are saved in elems
function loop(file, i, parser)
	local j = i
	elems = {}
	while true do
		-- defn parser just in case
		node = fn(parser)(file, j)()
		if node == nil then
			return {i = i, j = j, elems = elems}
		end
		
		table.insert(elems, node)
		j = node.j
	end
end