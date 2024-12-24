local M = {}

--- @returns joined array into string
function M.join(arr, delimiter)
	delimiter = delimiter or " "
	local str = ""
	for i, _ in ipairs(arr) do
		str = str .. arr[i]
		if i < #arr then
			str = str .. delimiter
		end
	end
	return str
end

function M.cut(str, delimiter, field)
	delimiter = delimiter or " "
	local arr = vim.split(str, delimiter)
	if field ~= nil then
		if field > 0 then
			return arr[field]
		else
			return arr[#arr + field]
		end
	else
		return arr
	end
end

--- @return table
function M.count_lsp_res_changes(lsp_res)
	local count = { instances = 0, files = 0 }
	if lsp_res.documentChanges then
		for _, changed_file in pairs(lsp_res.documentChanges) do
			count.files = count.files + 1
			count.instances = count.instances + #changed_file.edits
		end
	elseif lsp_res.changes then
		for _, changed_file in pairs(lsp_res.changes) do
			count.instances = count.instances + #changed_file
			count.files = count.files + 1
		end
	end
	return count
end

--- @param group string
--- @param fallback string
--- @returns string
function M.get_hl_fallback(group, fallback)
	if vim.fn.hlexists(group) == 1 then
		return group
	else
		return fallback
	end
end

local str = "hello world"
local first = M.cut(str, " ")
local second = M.cut(str, "", 1)
-- vim.notify("original: " .. first)
vim.notify("first: " .. tostring(vim.inspect(first)))
-- vim.notify("second: " .. tostring(vim.inspect(second)))

local arr = { "a", "b", "c" }
local joined = M.join(arr, "\n")
-- vim.notify(joined)

local arr2 = vim.g.content
-- local joined2 = M.join(arr2, "\n")
-- vim.notify(arr2)
vim.system({ "ls" }, { text = true }, function(out)
	print(vim.inspect(out))
	-- local jj = M.join(out.stdout, "\n")
	-- vim.print(jj)
	local result = vim.inspect(out.stdout)
	vim.schedule(function()
		vim.notify(result)
	end)
end)

return M
