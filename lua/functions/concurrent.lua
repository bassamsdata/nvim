-- -- vim.print(output)
--
-- local on_exit = function(obj)
-- 	-- print(obj.code)
-- 	-- print(obj.signal)
-- 	print(obj.stdout)
-- 	-- print(obj.stderr)
-- end
--
-- local output = vim.system(
-- 	{ "git", "status", ".", "--short" },
-- 	{ text = true },
-- 	on_exit
-- )
-- -- Runs asynchronously:
-- -- vim.system({ "echo", "hello" }, { text = true }, on_exit)
--
-- -- Runs synchronously:
-- local obj = vim.system({ "echo", "hello" }, { text = true }):wait()
-- -- { code = 0, signal = 0, stdout = 'hello', stderr = '' }

-- Execute the git status command
local function concurrent(fns, callback)
	local number_of_results = 0
	local results = {}

	for i, fn in ipairs(fns) do
		fn(function(args, ...)
			number_of_results = number_of_results + 1
			results[i] = args

			if number_of_results == #fns then
				callback(results, ...)
			end
		end)
	end
end
concurrent({
	function(cb)
		vim.system(

			{ "git", "-c", "status.relativePaths=true", "status", ".", "--short" },
			{ text = true },
			cb
		)
	end,
	function(cb)
		vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }, cb)
	end,
}, function(results)
	-- This is the final callback that will be called once all functions have completed.
	-- `results` is a table containing the results of all functions.
	print(results[1].stdout) -- Assuming you want to print the stdout of the first (and only) function.
	print(results[2].stdout) -- Assuming you want to print the stdout of the second (and only) function.
end)
