-- thanks to https://git.sr.ht/~eanyanwu/plugin-free-neovim/tree/main/item/lua/commands.lua
-- Custom User Commands

local core = require("core")
local uscope = require("uscope")

local M = {}

-- LSP Powered commands
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		local cmd = vim.api.nvim_buf_create_user_command
		cmd(0, "Format", function(cmd_args)
			if cmd_args.range == 2 then
				vim.lsp.buf.format({
					range = {
						["start"] = { cmd_args.line1, 0 },
						["end"] = { cmd_args.line2, 0 },
					},
				})
			else
				vim.lsp.buf.format()
			end
		end, {
			range = "%",
			desc = "Format the text in the current buffer",
		})

		cmd(0, "RenameSymbol", function()
			vim.lsp.buf.rename()
		end, {
			desc = "Rename the symbol under the cursor",
		})
	end,
})

local cmd = vim.api.nvim_create_user_command

-- Search with ripgrep and display the results in the quickfix list
cmd("Search", function(search_args)
	if not core.present("rg", "Pattern search") then
		return
	end

	-- Using the explicit "regexp" argument is the only way to search for
	-- patterns that begin with dashes
	local cmdline =
		{ "rg", "--vimgrep", "--smart-case", "--regexp", search_args.args }
	local rg_result = vim.fn.system(cmdline)

	if vim.v.shell_error == 1 and rg_result == "" then
		vim.notify("No matches found", vim.log.levels.WARN)
		return
	end

	if vim.v.shell_error ~= 0 then
		error(
			"Command failed with error code: "
				.. vim.v.shell_error
				.. "\n"
				.. rg_result
		)
	end

	local cwd = vim.fn.getcwd()
	local lines = vim.fn.map(
		vim.split(rg_result, "\n", { trimempty = true }),
		function(_, item)
			local next = string.gmatch(item, "([^:]+):(%d+):(%d+):(.*)")
			local filename, line, col, text = next()
			return {
				path = cwd .. "/" .. filename,
				filename = filename,
				line = tonumber(line),
				col = tonumber(col),
				text = text,
			}
		end
	)
	uscope.open({
		title = table.concat(cmdline, " "),
		items = lines,
		columns = { "filename", "text" },
		search_column = 2,
		get_preview_config = function(i)
			return {
				type = "file",
				path = i.path,
				line = i.line,
			}
		end,
		on_select = function(i)
			vim.cmd("edit +" .. tostring(i.line) .. " " .. i.path)
		end,
	})
end, {
	desc = "Recursively search for a pattern within the files in the current directory",
	nargs = 1,
})

cmd("Help", function()
	local tag_files = vim.api.nvim_get_runtime_file("doc/tags", true)

	local tags = {}
	for _, file in pairs(tag_files) do
		local parent = vim.fs.dirname(file) .. "/"
		for line in io.lines(file) do
			local parts = vim.split(line, "\t", { trimempty = true })
			table.insert(tags, {
				tag = parts[1],
				filename = parent .. parts[2],
				searchterm = parts[3],
			})
		end
	end

	uscope.open({
		title = "Help tags",
		items = tags,
		columns = { "tag", "filename" },
		get_preview_config = function(i)
			return {
				type = "help",
				path = i.filename,
				search = i.searchterm,
			}
		end,
		on_select = function(i)
			vim.cmd("help " .. i.tag)
		end,
	})
end, {
	desc = "Search help topics",
})

cmd("Files", function(cmd_args)
	local path = vim.fs.normalize(cmd_args.args)

	if path == "" then
		path = vim.fn.getcwd()
	end

	local fd_result =
		vim.fn.system({ "fd", "--type", "file", "--hidden", ".", path })

	if vim.v.shell_error ~= 0 then
		error(
			"Command failed with error code: "
				.. vim.v.shell_error
				.. "\n"
				.. fd_result
		)
	end

	local items = vim.tbl_map(function(i)
		local relative = string.gsub(i, "^" .. path, "")
		return { filename = i, relative = relative }
	end, vim.split(fd_result, "\n", { trimempty = true }))

	uscope.open({
		title = path,
		items = items,
		columns = { "relative" },
		get_preview_config = function(i)
			return {
				type = "file",
				path = i.filename,
			}
		end,
		on_select = function(i)
			vim.cmd("edit " .. i.filename)
		end,
	})
end, {
	desc = "Open a file from the current directory",
	nargs = "?",
	complete = "dir",
})

cmd("References", function()
	vim.lsp.buf.references({}, {
		on_list = function(on_list_args)
			local entries = on_list_args.items
			uscope.open({
				title = "References",
				items = entries,
				columns = { "filename", "text" },
				search_column = 1,
				get_preview_config = function(i)
					return {
						type = "file",
						path = i.filename,
						line = i.lnum,
					}
				end,
				on_select = function(i)
					vim.cmd("edit +" .. i.lnum .. " " .. i.filename)
				end,
			})
		end,
	})
end, {})

cmd("Symbols", function()
	vim.lsp.buf.document_symbol({
		on_list = function(on_list_args)
			local entries = vim.fn.map(on_list_args.items, function(_, entry)
				local symbol_name = string.gsub(entry.text, "^%[.+%]%s", "", 1)
				return {
					symbol = symbol_name,
					kind = entry.kind,
					filename = entry.filename,
					col = entry.col,
					row = entry.lnum,
				}
			end)

			local filename = ""
			if #entries > 0 then
				filename = entries[1].filename
			end

			uscope.open({
				title = "Symbols @ " .. filename,
				items = entries,
				columns = { "kind", "symbol" },
				search_column = 2,
				get_preview_config = function(i)
					return {
						type = "file",
						path = i.filename,
						line = i.row,
					}
				end,
				on_select = function(i)
					vim.cmd(tostring(i.row))
				end,
			})
		end,
	})
end, {})

cmd("Jumplist", function()
	local list = vim.fn.getjumplist()[1]
	local sanitized = {}
	-- Reverse the list and sanitize it as we do so
	for i = #list, 1, -1 do
		local cur = list[i]
		-- Ignore invalid buffers
		if vim.api.nvim_buf_is_valid(cur.bufnr) then
			local filename = vim.fn.bufname(cur.bufnr)
			-- Ignore buffers that correspond to non-readable files
			if vim.fn.filereadable(filename) == 1 then
				table.insert(sanitized, {
					filename = filename,
					line = cur.lnum,
				})
			end
		end
	end

	uscope.open({
		title = "Jumplist",
		items = sanitized,
		columns = { "filename", "line" },
		disable_search = true,
		get_preview_config = function(i)
			return {
				type = "file",
				path = i.filename,
				line = i.line,
			}
		end,
		on_select = function(i)
			vim.cmd("edit +" .. i.line .. " " .. i.filename)
		end,
	})
end, {})

return M
