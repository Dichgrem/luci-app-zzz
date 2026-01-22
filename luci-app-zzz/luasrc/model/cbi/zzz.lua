local m, s, o
local sys = require("luci.sys")
local util = require("luci.util")

m = Map("zzz", "ZZZ 802.1x 认证客户端", "配置使用 zzz 客户端进行网络访问的 802.1x 认证")

-- Authentication Settings
s = m:section(TypedSection, "auth", "认证设置")
s.anonymous = true
s.addremove = false

o = s:option(DummyValue, "_status", "当前状态")
o.rawhtml = true
o.cfgvalue = function()
	local running = sys.call("pgrep zzz >/dev/null") == 0
	if running then
		return "<span style='color:green;font-weight:bold'>✔ 正在运行中</span>"
	else
		return "<span style='color:red;font-weight:bold'>✘ 未运行</span>"
	end
end

-- control buttons
control_buttons = s:option(DummyValue, "_control", "服务控制")
control_buttons.rawhtml = true
control_buttons.cfgvalue = function()
	return [[
		<div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
			<button type="button" class="cbi-button cbi-button-apply" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=start'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">启动服务</button>
			<button type="button" class="cbi-button cbi-button-remove" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=stop'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">停止服务</button>
			<button type="button" class="cbi-button cbi-button-reload" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=restart'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">重启服务</button>
		</div>
	]]
end

-- Username
o = s:option(
	Value,
	"username",
	"用户名",
	[[802.1x 认证用户名
<span style="cursor: help; color: #007bff; font-weight: bold;" title="用户名为学号@运营商，例如212306666@cucc；移动为cmcc，联通为cucc，电信为ctcc">?</span>]]
)
o.rmempty = false
o.rawhtml = true
function o.validate(self, value)
	value = value:match("^%s*(.-)%s*$") or value
	if #value < 3 or #value > 64 then
		return nil, "用户名长度必须在3-64字符之间"
	end
	if not value:match("^[a-zA-Z0-9@._-]+$") then
		return nil, "用户名只能包含字母、数字、@、.、_和-"
	end
	return value
end

-- Password
o.password = true
o.rmempty = false
o = s:option(
	Value,
	"password",
	"密码",
	[[802.1x 认证密码
<span style="cursor: help; color: #007bff; font-weight: bold;" title="密码默认为身份证号后六位，可以在官方客户端inode中修改">?</span>]]
)
o.password = true
o.rmempty = false
o.rawhtml = true
function o.validate(self, value)
	if #value < 4 or #value > 128 then
		return nil, "密码长度必须在4-128字符之间"
	end
	return value
end

-- Network Device
o = s:option(
	Value,
	"device",
	"网络接口",
	[[用于认证的网络接口
<span style="cursor: help; color: #007bff; font-weight: bold;" title="可以用ip addr命令查看，有10.38开头ip的接口">?</span>]]
)
o.rmempty = false
o:value("eth0", "eth0")
o:value("eth1", "eth1")
o:value("wan", "WAN")

local interfaces = sys.net.devices()
for _, iface in ipairs(interfaces) do
	if iface ~= "lo" and iface:match("^[a-zA-Z0-9]+$") then
		o:value(iface, iface)
	end
end

function o.validate(self, value)
	if not value:match("^[a-zA-Z0-9]+$") then
		return nil, "网络接口只能包含字母和数字"
	end
	return value
end

-- Auto start
auto_start = s:option(Flag, "auto_start", "启用定时启动")
auto_start.description = "启用后将在每周一至周五自动启动服务"
auto_start.rmempty = false

-- Get Status
auto_start.cfgvalue = function(self, section)
	local has_cron = sys.call("crontab -l 2>/dev/null | grep 'S99zzz' >/dev/null") == 0
	return has_cron and "1" or "0"
end

-- Schedule Time
schedule_time = s:option(Value, "schedule_time", "启动时间")
schedule_time.description = "设置定时启动的时间 (格式: HH:MM，例如 07:30)"
schedule_time.placeholder = "07:00"
schedule_time.rmempty = false
schedule_time.default = "07:00"

schedule_time.cfgvalue = function(self, section)
	local value = self.map:get(section, "schedule_time")
	return value or "07:00"
end

function schedule_time.validate(self, value)
	if not value:match("^[0-9][0-9]:[0-9][0-9]$") then
		return nil, "时间格式必须为 HH:MM (例如 07:30)"
	end
	local hour = tonumber(value:sub(1, 2))
	local minute = tonumber(value:sub(4, 5))
	if hour < 0 or hour > 23 then
		return nil, "小时必须在 0-23 之间"
	end
	if minute < 0 or minute > 59 then
		return nil, "分钟必须在 0-59 之间"
	end
	return value
end

schedule_time:depends("auto_start", "1")

-- Crontab
auto_start.write = function(self, section, value)
	local schedule_time_val = self.map:get(section, "schedule_time") or "07:00"
	local hour, minute = schedule_time_val:match("^(%d+):(%d+)$")
	local temp_cron = "/tmp/.zzz_cron_tmp_" .. os.time()
	if value == "1" then
		sys.call("crontab -l 2>/dev/null > " .. temp_cron)
		sys.call("sed -i '/S99zzz/d' " .. temp_cron)
		sys.call("sed -i '/# zzz auto/d' " .. temp_cron)
		sys.call(string.format("echo '%s %s * * 1,2,3,4,5 /etc/rc.d/S99zzz start # zzz auto start' >> %s", minute, hour, temp_cron))
		sys.call("crontab " .. temp_cron .. " 2>/dev/null && rm -f " .. temp_cron)
		sys.call("/etc/init.d/cron enable && /etc/init.d/cron restart")
	else
		sys.call("crontab -l 2>/dev/null > " .. temp_cron)
		sys.call("sed -i '/S99zzz/d' " .. temp_cron)
		sys.call("sed -i '/# zzz auto/d' " .. temp_cron)
		sys.call("crontab " .. temp_cron .. " 2>/dev/null && rm -f " .. temp_cron)
		sys.call("/etc/init.d/cron restart")
	end
end

-- Crontab Status
timer_status_display = s:option(DummyValue, "_timer_status_display", "定时任务状态")
timer_status_display.rawhtml = true
timer_status_display.cfgvalue = function()
	local cron_output = sys.exec("crontab -l 2>/dev/null | grep 'S99zzz' || echo '未设置'")
	if cron_output:match("S99zzz") then
		local cron_line = cron_output:match("%d+%s+%d+%s+%*%s+%*%s+%d+,.*# zzz auto")
		if cron_line then
			local minute, hour = cron_line:match("^(%d+)%s+(%d+)%s+")
			if minute and hour then
				local time_str = string.format("%02d:%02d", tonumber(hour), tonumber(minute))
				return string.format("<span style='color:green;font-weight:bold'>✔ 已启用 (每周一至周五 %s 自动启动)</span>", time_str)
			end
		end
		return "<span style='color:green;font-weight:bold'>✔ 已启用</span>"
	else
		return "<span style='color:red;font-weight:bold'>✘ 未启用</span>"
	end
end

-- 保存后自动重启 zzz 服务
m.on_commit = function(self)
	local sys = require("luci.sys")
	sys.call("/etc/rc.d/S99zzz restart >/dev/null 2>&1 &")
end

return m
