local function set_timeout(timeout, callback)
	local timer = vim.loop.new_timer()
	assert(timer, "timer not created")
	timer:start(timeout, 0, function()
		-- timer:stop()
		callback()
	end)
end

coroutine.wrap(function()
	local function async_func()
		print("async_func")
		local timer = vim.loop.new_timer()
		timer:start(1000, 0, function()
			print("timer callback")
			timer:stop()
		end
	end
end)

print("1")
set_timeout(2000, function()
	print("2")
end)

print("3")
