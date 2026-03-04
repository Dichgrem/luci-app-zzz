local zzz = {}

function zzz.index()
	if not nixio.fs.access("/etc/config/zzz") then
		return
	end

	entry({ "admin", "network", "zzz" }, form("zzz"), "ZZZ", 60).dependent = false
	entry({ "admin", "network", "zzz", "service_control" }, call("service_control")).leaf = true
	entry({ "admin", "network", "zzz", "get_status" }, call("act_status")).leaf = true
end

function zzz.service_control()
	local sys = require("luci.sys")
	local util = require("luci.util")
	local action = luci.http.formvalue("action")
	local result = { success = false, message = "" }

	local valid_actions = { start = true, stop = true, restart = true }

	if action and valid_actions[action] then
		local cmd = ""
		if action == "start" then
			cmd = "service zzz start"
		elseif action == "stop" then
			cmd = "service zzz stop"
		elseif action == "restart" then
			cmd = "service zzz restart"
		end

		if cmd ~= "" then
			local ret = sys.call(cmd)
			if ret == 0 then
				result.success = true
				result.message = util.pcdata(action .. " 成功")
			else
				result.success = false
				result.message = util.pcdata(action .. " 失败")
			end
		end
	else
		result.message = "无效的操作"
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(result)
end

function zzz.act_status()
	local sys = require("luci.sys")
	local util = require("luci.util")
	local status = {}

	status.running = (sys.call("service zzz status >/dev/null 2>&1 && pgrep -f zzz >/dev/null") == 0)

	if status.running then
		status.process_info = util.trim(sys.exec("ps | grep -v grep | grep zzz"))
	end

	local log_file = "/tmp/zzz.log"
	if nixio.fs.access(log_file) then
		status.log = util.trim(sys.exec("tail -20 " .. log_file))
	else
		status.log = util.trim(sys.exec("logread | grep zzz | tail -10"))
	end

	if status.log then
		status.log = util.pcdata(status.log)
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

return zzz
