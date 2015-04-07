local M = {}

M.firstFunction = function()

print("this is the first function")

	local function secondFunction()

		print("this is the second function")

	end
	return secondFunction
end

return M