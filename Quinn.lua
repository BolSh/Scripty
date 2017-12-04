if myHero.charName ~= "Quinn" then return end

function SexyPrint(message)
   local sexyName = "<font color=\"#E41B17\">[<b>Quinn</b>]:</font>"
   local fontColor = "FFFFFF"
   print(sexyName .. " <font color=\"#" .. fontColor .. "\">" .. message .. "</font>")
end

local version = "0.01"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/BolSh/Scripty/master/Quinn.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST,"/BolSh/Scripty/master/Quinn.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				SexyPrint("New version available "..ServerVersion)
				SexyPrint("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () SexyPrint("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 2)
				return
			else
				DelayAction(function() SexyPrint("You have got the latest version ("..ServerVersion..")") end, 4)
			end
		end
	else
		SexyPrint("Error downloading version info")
	end
end

function LoadUPL()
	if not _G.UPLloaded then
        if FileExist(LIB_PATH .. "/UPL.lua") then
            require("UPL")
            _G.UPL = UPL()
        else 
            print("Downloading UPL, please don't press F9")
            DelayAction(function() DownloadFile("https://raw.github.com/nebelwolfi/BoL/master/Common/UPL.lua".."?rand="..math.random(1,10000), LIB_PATH.."UPL.lua", function () print("Successfully downloaded UPL. Press F9 twice.") end) end, 3) 
            return
        end
    end
end

function LoadUOL()
	if FileExist(LIB_PATH .. "/UOL.lua") then
        require("UOL")
    else 
        print("Downloading UOL, please don't press F9")
        DownloadFile("https://raw.github.com/nebelwolfi/BoL/master/Common/UOL.lua".."?rand="..math.random(1,10000), LIB_PATH.."UOL.lua", function () print("Successfully downloaded UOL. Press F9 twice.") return end) 
        return
    end
end

function OnLoad()
	LoadUPL()
	LoadUOL()
 	Quinn()
end

class "Quinn"

function Quinn:__init()
    self:Variables()
    self:LoadMenu()

    AddTickCallback(function() self:Tick() end)
    AddApplyBuffCallback(function(unit, target, buff) self:ApplyBuff(unit, target, buff) end)
    AddRemoveBuffCallback(function(unit, buff) self:RemoveBuff(unit, buff) end)
    AddProcessSpellCallback(function(unit, spell) self:ProcessSpell(unit, spell) end)
    AddDrawCallback(function() self:Draw() end)

    DelayAction(function() SexyPrint("Sucessfully Loaded!") end, 2)
end

function Quinn:LoadMenu()
	self.Config = scriptConfig("[Shulepin] Quinn", "Quinn")

	self.Config:addSubMenu("[Quinn] OrbWalker Settings", "OrbWalkerSettings")
	UOL:AddToMenu(self.Config.OrbWalkerSettings)
	UPL:AddToMenu(self.Config, "[Quinn] Prediction Settings")
	UPL:AddSpell(_Q, self.Q)

	self.Config:addSubMenu("[Quinn] Target Selector", "TargetSelectorSettings")
	self.Config.TargetSelectorSettings:addTS(self.TS)

	self.Config:addSubMenu("[Quinn] Combo Settings", "ComboSettings")
	self.Config.ComboSettings:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
	self.Config.ComboSettings:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
	self.Config.ComboSettings:addParam("Passive", "Check Passive", SCRIPT_PARAM_ONOFF, true)

	self.Config:addSubMenu("[Quinn] Harass Settings", "HarassSettings")
	self.Config.HarassSettings:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
	self.Config.HarassSettings:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)
	self.Config.HarassSettings:addParam("Mana", "Min. Mana(%) to Harass:", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)
	self.Config.HarassSettings:addParam("Passive", "Check Passive", SCRIPT_PARAM_ONOFF, true)

	self.Config:addSubMenu("[Quinn] LastHit Settings", "LastHitSettings")
	self.Config.LastHitSettings:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
	self.Config.LastHitSettings:addParam("Mana", "Min. Mana(%) to LastHit:", SCRIPT_PARAM_SLICE, 75, 0, 100, 0)

	self.Config:addSubMenu("[Quinn] LaneClear Settings", "LaneClearSettings")
	self.Config.LaneClearSettings:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
	self.Config.LaneClearSettings:addParam("QHit", "Min. Hit Count:", SCRIPT_PARAM_SLICE, 3, 1, 6, 0)
	self.Config.LaneClearSettings:addParam("Mana", "Min. Mana(%) to LaneClear:", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)

	self.Config:addSubMenu("[Quinn] JungleClear Settings", "JungleClearSettings")
	self.Config.JungleClearSettings:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
	self.Config.JungleClearSettings:addParam("Mana", "Min. Mana(%) to JungleClear:", SCRIPT_PARAM_SLICE, 45, 0, 100, 0)

	self.Config:addSubMenu("[Quinn] KillSteal Settings", "KillStealSettings")
	self.Config.KillStealSettings:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
	self.Config.KillStealSettings:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)

	self.Config:addSubMenu("[Quinn] Draw Settings", "DrawSettings")
	self.Config.DrawSettings:addParam("Q", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	self.Config.DrawSettings:addParam("W", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
	self.Config.DrawSettings:addParam("E", "Draw E Range", SCRIPT_PARAM_ONOFF, true)

	self.Config:addSubMenu("[Quinn] Misc Settings", "MiscSettings")
	self.Config.MiscSettings:addParam("AutoR", "Auto R on Fountain", SCRIPT_PARAM_ONOFF, true)
	self.Config.MiscSettings:addParam("SetSkin", "SkinShanger: Select Skin", SCRIPT_PARAM_LIST, 1, {"Classic", "Phoenix", "Woad Scout", "Corsair"})
	self.Config.MiscSettings:setCallback("SetSkin", function () SetSkin(myHero, self.Config.MiscSettings.SetSkin - 1) end)

	self.Config:addParam("Space","", 5, "")
	self.Config:addParam("Author","[Quinn] Author: Shulepin", 5, "")
	self.Config:addParam("Version","[Quinn] Version: "..version, 5, "")
end

function Quinn:Variables()
	self.Q  = { speed = 1550, delay = 0.25, range = 1025, width = 90, collision = true, aoe = false, type = "linear" }
	self.W  = { range = 2100 }
	self.E  = { range =  675 }
	self.R  = { range =  700 }

	self.TS = TargetSelector(TARGET_LESS_CAST, 1500, DAMAGE_PHYSICAL, true)
	self.TS.name = "Target Selector"

	self.Minions  = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MINHEALTH_ASC)
    self.JMinions = minionManager(MINION_JUNGLE, 1000, myHero, MINION_SORT_MINHEALTH_ASC)

    self.QTick = 0
    self._RedB =  { x = 	400, z = 450 }
    self._BlueB = { x = 14300, z = 1350 }
	
	self.Passive = {}
	for _, enemy in pairs(GetEnemyHeroes()) do
		self.Passive[enemy.charName] = false
	end
end

function Quinn:CD()
	self.Q.Ready = myHero:CanUseSpell(_Q) == READY
	self.W.Ready = myHero:CanUseSpell(_W) == READY
	self.E.Ready = myHero:CanUseSpell(_E) == READY
	self.R.Ready = myHero:CanUseSpell(_R) == READY 
end

function Quinn:Tick()
	self.TS:update()
	self.Minions:update()
	self.JMinions:update()
	self:CD()
	self:DamageUpdate()

	if not myHero.dead then
		local target = self.TS.target
		self:Combo(target)
		self:Harass(target)
		self:LastHit()
		self:LaneClear()
		self:JungleClear()
		self:KillSteal()
		self:AutoCastR()
	end
end

function Quinn:Combo(target)
	if UOL:GetOrbWalkMode() == "Combo" then
		if self.Config.ComboSettings.Passive then
			if target and self.Passive[target.charName] == false then
				if self.Config.ComboSettings.Q then self:CastQ(target) end
		        if self.Config.ComboSettings.E then self:CastE(target) end
			end
		else
			if self.Config.ComboSettings.Q then self:CastQ(target) end
		    if self.Config.ComboSettings.E then self:CastE(target) end
		end
	end
end

function Quinn:Harass(target)
	if UOL:GetOrbWalkMode() == "Harass" and myHero.mana >= (myHero.maxMana*(self.Config.HarassSettings.Mana*0.01)) then
		if self.Config.HarassSettings.Passive then
			if target and self.Passive[target.charName] == false then
				if self.Config.HarassSettings.Q then self:CastQ(target) end
		        if self.Config.HarassSettings.E then self:CastE(target) end
			end
		else
			if self.Config.HarassSettings.Q then self:CastQ(target) end
		    if self.Config.HarassSettings.E then self:CastE(target) end
		end
	end
end

function Quinn:LastHit()
	if UOL:GetOrbWalkMode() == "LastHit" and myHero.mana >= (myHero.maxMana*(self.Config.LastHitSettings.Mana*0.01)) then
		for _, Minion in pairs(self.Minions.objects) do
		    if self.Q.Ready and ValidTarget(Minion, self.Q.range) then
			    if Minion.health < self:QDamage() then
				    if self.Config.LastHitSettings.Q then self:CastQ(Minion) end
			    end
		    end
	    end
	end
end

function Quinn:LaneClear()
	if UOL:GetOrbWalkMode() == "LaneClear" and myHero.mana >= (myHero.maxMana*(self.Config.LaneClearSettings.Mana*0.01)) then
		for _, Minion in pairs(self.Minions.objects) do
		    if self.Q.Ready and ValidTarget(Minion, self.Q.range) then
			    if self:MinAround(Minion, 210) >= self.Config.LaneClearSettings.QHit then
			    	if self.Config.LaneClearSettings.Q then self:CastQ(Minion) end
			    end
		    end
	    end
	end
end

function Quinn:JungleClear()
	if UOL:GetOrbWalkMode() == "LaneClear" and myHero.mana >= (myHero.maxMana*(self.Config.JungleClearSettings.Mana*0.01)) then
		for _, Minion in pairs(self.JMinions.objects) do
		    if self.Q.Ready and ValidTarget(Minion, self.Q.range) then
			    if self.Config.JungleClearSettings.Q then self:CastQ(Minion) end
		    end
	    end
	end
end

function Quinn:KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if self.Q.Ready and ValidTarget(enemy, self.Q.range) then
			if enemy.health < myHero:CalcDamage(enemy, self:QDamage()) then
				if self.Config.KillStealSettings.Q then self:CastQ(enemy) end
			end
		end
		if self.E.Ready and ValidTarget(enemy, self.E.range) then
			if enemy.health < myHero:CalcDamage(enemy, self:EDamage() + self:PassiveDamage()) then
				if self.Config.KillStealSettings.E then self:CastE(enemy) end
			end
		end
	end
end

function Quinn:CastQ(target)
	if self.Q.Ready and ValidTarget(target, self.Q.range) then
		local CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, target)
        if CastPosition and HitChance > 0 then
            CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
	end
end

function Quinn:CastE(target)
	local timeDelta = (self.Q.delay + GetDistance(myHero, target)/self.Q.speed) * 1000
	if self.E.Ready and ValidTarget(target, self.E.range) and self.QTick+timeDelta+500<GetTickCount() then
		CastSpell(_E, target)
	end
end

function Quinn:AutoCastR()
	if self.R.Ready and myHero:GetSpellData(_R).name == "QuinnR" and self:Fountain() and CountEnemyHeroInRange(1000, myHero) < 1 then
		if self.Config.MiscSettings.AutoR then CastSpell(_R) end
	end
end

function Quinn:PassiveDamage()
	local AD_Scale = 14 + 2 * myHero.level
	local PassiveDamage = 10 + 5 * myHero.level + myHero.totalDamage * (AD_Scale/100)
	local TotalDamage = myHero.totalDamage + PassiveDamage
	return TotalDamage
end

function Quinn:QDamage()
	local AD_Scale = 70 + 10 * myHero:GetSpellData(_Q).level
	local Q = -5 + 25 * myHero:GetSpellData(_Q).level + myHero.totalDamage * (AD_Scale/100) + myHero.ap * 0.5
	return Q
end

function Quinn:EDamage()
	local E = 10 + 30 * myHero:GetSpellData(_E).level + myHero.totalDamage * 0.2
	return E
end

function Quinn:DamageUpdate()
	self:PassiveDamage()
	self:QDamage()
	self:EDamage()
end

function Quinn:Fountain()
	if not GetGame().map.index == 15 then return end
	local _ = false
	if myHero.team == 200 then
		local Distance = math.sqrt((myHero.x-self._BlueB.x)*(myHero.x-self._BlueB.x) + (myHero.z-self._BlueB.z)*(myHero.z-self._BlueB.z))
		if Distance < 1000 then
			_ = true
		else
			_ = false
		end
	elseif myHero.team == 100 then
		local Distance = math.sqrt((myHero.x-self._RedB.x)*(myHero.x-self._RedB.x) + (myHero.z-self._RedB.z)*(myHero.z-self._RedB.z))
		if Distance < 1000 then
			_ = true
		else
			_ = false
		end
	end
	return _
end

function Quinn:MinAround(pos, range)
	local C = 0
	if pos == nil then return 0 end
	for _, Minion in pairs(self.Minions.objects) do
		if pos and range then
			if ValidTarget(Minion) and GetDistance(Minion, pos) then
			    C = C + 1
		    end
		end
	end
	return C
end

function Quinn:ProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower() == "quinnq" then
		self.QTick = GetTickCount()
	end
end

function Quinn:ApplyBuff(unit, target, buff)
	for _, enemy in pairs(GetEnemyHeroes()) do
		if target == enemy and buff.name:lower() == "quinnw" then
			self.Passive[enemy.charName] = true
		end
	end
end

function Quinn:RemoveBuff(unit, buff)
	for _, enemy in pairs(GetEnemyHeroes()) do
		if unit == enemy and buff.name:lower() == "quinnw" then
			self.Passive[enemy.charName] = false
		end
	end
end

function Quinn:Draw()
	if self.Q.Ready and self.Config.DrawSettings.Q then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, self.Q.range, 2, RGB(0, 119, 255), 75)
	end
	if self.E.Ready and self.Config.DrawSettings.E then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, self.E.range, 2, RGB(255, 255, 0), 75)
	end
	if self.W.Ready and self.Config.DrawSettings.W then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, self.W.range, 2, RGB(255, 85, 0), 75)
	end
end