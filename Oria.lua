function SexyPrint(message)
   local sexyName = "<font color=\"#E41B17\">[<b>Oria</b>]:</font>"
   local fontColor = "FFFFFF"
   print(sexyName .. " <font color=\"#" .. fontColor .. "\">" .. message .. "</font>")
end

local ScriptName = "Oria"
local Author = "Shany"
local Version = "0.01"
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "~~".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local AUTOUPDATE = true

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST,"~~.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(Version) < ServerVersion then
				SexyPrint("New Version Please Wait."..ServerVersion)
				SexyPrint("Updating, Please wait.")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () SexyPrint("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 2)
				return
			else
				SexyPrint("Latest Version installed ("..ServerVersion..")")
				end
			end
		else
		SexyPrint("Was not able to get version info"
		end
	end
