local m, s, o
local sys = require("luci.sys")
local util = require("luci.util")

m = Map("zzz", translate("ZZZ 802.1x Authentication Client"), translate("Configure 802.1x authentication for network access using zzz client"))

-- Authentication Settings
s = m:section(TypedSection, "auth", translate("Authentication Settings"))
s.anonymous = true
s.addremove = false

o = s:option(DummyValue, "_status", translate("Current Status"))
o.rawhtml = true
o.cfgvalue = function()
	local running = sys.call("pgrep zzz >/dev/null") == 0
	if running then
		return "<span style='color:green;font-weight:bold'>✔ " .. translate("Running") .. "</span>"
	else
		return "<span style='color:red;font-weight:bold'>✘ " .. translate("Not Running") .. "</span>"
	end
end

-- control buttons
control_buttons = s:option(DummyValue, "_control", translate("Service Control"))
control_buttons.rawhtml = true
control_buttons.cfgvalue = function()
	return [[
		<div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
			<button type="button" class="cbi-button cbi-button-apply" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=start'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">]] .. translate("Start Service") .. [[</button>
			<button type="button" class="cbi-button cbi-button-remove" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=stop'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">]] .. translate("Stop Service") .. [[</button>
			<button type="button" class="cbi-button cbi-button-reload" onclick="fetch('/cgi-bin/luci/admin/network/zzz/service_control',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=restart'}).then(r=>r.json()).then(d=>{alert(d.message);if(d.success)location.reload();});return false;">]] .. translate("Restart Service") .. [[</button>
		</div>
	]]
end

-- Username
o = s:option(
	Value,
	"username",
	translate("Username"),
	translate("802.1x authentication username") .. [[
<span style="cursor: help; color: #007bff; font-weight: bold;" title="]] .. translate("Format: studentID@carrier, e.g. 212306666@cucc; Mobile=cmcc, Unicom=cucc, Telecom=ctcc") .. [[">?</span>]]
)
o.rmempty = false
o.rawhtml = true
function o.validate(self, value)
	value = value:match("^%s*(.-)%s*$") or value
	if #value < 3 or #value > 64 then
		return nil, translate("Username must be 3-64 characters")
	end
	if not value:match("^[a-zA-Z0-9@._-]+$") then
		return nil, translate("Username can only contain letters, numbers, @, ., _ and -")
	end
	return value
end

-- Password
o.password = true
o.rmempty = false
o = s:option(
	Value,
	"password",
	translate("Password"),
	translate("802.1x authentication password") .. [[
<span style="cursor: help; color: #007bff; font-weight: bold;" title="]] .. translate("Default is last 6 digits of ID card, can be changed in official iNode client") .. [[">?</span>]]
)
o.password = true
o.rmempty = false
o.rawhtml = true
function o.validate(self, value)
	if #value < 4 or #value > 128 then
		return nil, translate("Password must be 4-128 characters")
	end
	return value
end

-- Network Device
o = s:option(
	Value,
	"device",
	translate("Network Interface"),
	translate("Network interface for authentication") .. [[
<span style="cursor: help; color: #007bff; font-weight: bold;" title="]] .. translate("Use 'ip addr' to check, look for interface with 10.38.x.x IP") .. [[">?</span>]]
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
		return nil, translate("Network interface can only contain letters and numbers")
	end
	return value
end

-- Auto start
auto_start = s:option(Flag, "auto_start", translate("Enable Scheduled Start"))
auto_start.description = translate("When enabled, service will auto-start at 7:00 AM on weekdays (Mon-Fri)")
auto_start.rmempty = false

-- Get Status
auto_start.cfgvalue = function(self, section)
	local has_cron = sys.call("crontab -l 2>/dev/null | grep 'S99zzz' >/dev/null") == 0
	return has_cron and "1" or "0"
end

-- Crontab
auto_start.write = function(self, section, value)
	local temp_cron = "/tmp/.zzz_cron_tmp_" .. os.time()
	if value == "1" then
		sys.call("crontab -l 2>/dev/null > " .. temp_cron)
		sys.call("sed -i '/S99zzz/d' " .. temp_cron)
		sys.call("sed -i '/# zzz auto/d' " .. temp_cron)
		sys.call("echo '0 7 * * 1,2,3,4,5 /etc/rc.d/S99zzz start # zzz auto start' >> " .. temp_cron)
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
timer_status_display = s:option(DummyValue, "_timer_status_display", translate("Scheduled Task Status"))
timer_status_display.rawhtml = true
timer_status_display.cfgvalue = function()
	local cron_output = sys.exec("crontab -l 2>/dev/null | grep 'S99zzz' || echo 'not set'")
	if cron_output:match("S99zzz") then
		return "<span style='color:green;font-weight:bold'>✔ " .. translate("Enabled (Auto-start at 7:00 AM on weekdays)") .. "</span>"
	else
		return "<span style='color:red;font-weight:bold'>✘ " .. translate("Disabled") .. "</span>"
	end
end

-- 保存后自动重启 zzz 服务
m.on_commit = function(self)
	local sys = require("luci.sys")
	sys.call("/etc/rc.d/S99zzz restart >/dev/null 2>&1 &")
end

return m
