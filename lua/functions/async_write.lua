local function callback(ok, msg)
	vim.schedule(function()
		if ok then
			vim.cmd.checktime()
		elseif msg and msg ~= "" then
			vim.api.nvim_err_writeln(msg)
		else
			vim.api.nvim_err_writeln(
				"Something in the async write failed, not sure what"
			)
		end
	end)
end

local function async_write(filename, data)
	local status = true
	local msg = ""
	local fd, omsg, _ = vim.uv.fs_open(filename, "w", 438)
	if not fd then
		status, msg = false, ("Failed to open: %s\n%s"):format(filename, omsg)
	else
		local ok, wmsg, _ = vim.uv.fs_write(fd, data, 0)
		if not ok then
			status, msg = false, ("Failed to write: %s\n%s"):format(filename, wmsg)
		end
	end
	assert(vim.uv.fs_close(fd))
	return status, msg
end

vim.api.nvim_create_user_command("AsyncWrite", function()
	local work = vim.uv.new_work(async_write, callback)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	work:queue(vim.api.nvim_buf_get_name(0), table.concat(lines, "\n"))
end, {})
