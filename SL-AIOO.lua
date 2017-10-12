local SLAIO,Stage = 0.02,"BETA"

local SLSChamps = {	
	["Vayne"] = true,
	["Soraka"] = true,
	["Blitzcrank"] = true,
	["Kalista"] = true,
	["Velkoz"] = true,
	["Nasus"] = true,
	["Jinx"] = true,
	["Aatrox"] = true,
	["Kindred"] = true,
	["Nocturne"] = true,
	["Sivir"] = true,
	["Vladimir"] = true,
	["Orianna"] = true,
	["Veigar"] = true,
	["KogMaw"] = true,
	["Ahri"] = true,
	["Khazix"] = true,
	["Zed"] = true,
	["Anivia"] = true,
	["Syndra"] = true,
	["Draven"] = true,
}

local SLPatchnew = nil
local spawn = nil
local Spell = {}
local str3 = {[0]="Q",[1]="W",[2]="E",[3]="R"}
local IPred= false
local OpenPredict = false
local SLM = {}
local SLM2 = {}
local lastcheck = 0
local structures = {}
local turrets = {}
local Wards = {}
local Wards2 = {}
local target = nil
local ts = nil
if GetGameVersion():sub(3,4) >= "10" then
		SLPatchnew = GetGameVersion():sub(1,4)
	else
		SLPatchnew = GetGameVersion():sub(1,3)
end
local AutoUpdater = true

require 'DamageLib'
if SLSChamps[myHero.charName] then
	require 'IPrediction'	
	IPred = true
end

local function PredMenu(m,sp)
	if not m["CP"] then m:DropDown("CP", "Choose Prediction", 1 ,{"OPred", "GPred", "IPred", "GoSPred","SLPred"}) end
	m:DropDown("h"..str3[sp], "Hitchance"..str3[sp], 2, {"Low", "Medium", "High"})
	if m.CP:Value() == 2 then
		require 'GPrediction'
	elseif m.CP:Value() == 1 then
		require 'OpenPredict'
		OpenPredict = true
	end
end

local function GetValue(m,sp)
	if not m["CP"] or not m["h"..str3[sp]] then return end
	if m.CP:Value() == 5 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 2
		end
	elseif m.CP:Value() == 4 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 2
		end
	elseif m.CP:Value() == 3 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 2
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 3
		end
	elseif m.CP:Value() == 2 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 2
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 3
		end
	elseif m.CP:Value() == 1 then
		if m["h"..str3[sp]]:Value() == 1 then
			return .2
		elseif m["h"..str3[sp]]:Value() == 2 then
			return .45
		elseif m["h"..str3[sp]]:Value() == 3 then
			return .7
		end
	end
end

local function GetCollision(m,sp,t)
	if not m["CP"] or not m["h"..str3[sp]] then return end
	if m.CP:Value() == 5 then
		return t.col or false
	elseif m.CP:Value() == 4 then
		return t.col or false
	elseif m.CP:Value() == 4 then
		return t.col or false
	elseif m.CP:Value() == 3 then
		return t.col or false
	elseif m.CP:Value() == 2 then
		if t.col then
			return {"minion","champion"}
		else
			return nil
		end
	elseif m.CP:Value() == 1 then
		return t.col or false
	end
end

local function GetType(m,sp,t)
	if not m["CP"] or not m["h"..str3[sp]] then return end
	if m.CP:Value() == 3 then
		if t.type == "line" then
			return "linear"
		else
			return "circular"
		end
	else
		return t.type or "circular"
	end
end

local function CastGenericSkillShot(s,u,t,sp,m)--source,unit,table,spell,menu	
	if not m["CP"] or not m["h"..str3[sp]] then return end
	t.width = t.width or t.radius
	t.radius = t.width or t.radius
	t.col = GetCollision(m,sp,t)
	t.name = t.name or GetCastName(s,sp)
	t.count = t.count or 1
	t.angle = t.angle or 45
	t.delay = t.delay or 0.250
	t.speed = t.speed or math.huge
	t.range = t.range or 1000
	t.type = GetType(m,sp,t)
	t.aoe = t.aoe or false
	if m.CP:Value() == 1 then	
		if t.col then
			if t.type:lower():find("lin") then
				local Pred = GetPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and not Pred:mCollision(t.count) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("cir") then
				local Pred = GetCircularAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and not Pred:mCollision(t.count) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("con") then
				local Pred = GetConicAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and not Pred:mCollision(t.count) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			end
		else
			if t.type:lower():find("lin") then
				local Pred = GetPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("cir") then
				local Pred = GetCircularAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("con") then
				local Pred = GetConicAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			end
		end
	elseif m.CP:Value() == 2 then
		local Pred = _G.gPred:GetPrediction(u,s,t,t.aoe,t.col)
		if Pred.HitChance >= GetValue(m,sp) then
			CastSkillShot(sp,Pred.CastPosition)
		end
	elseif m.CP:Value() == 3 then
		local Predicted = IPrediction.Prediction({name=t.name, range=t.range, speed=t.speed, delay=t.delay, width=t.width, type=t.type, collision=t.col, collisionM=t.col, collisionH=t.col})
		local hit, pos = Predicted:Predict(u,s)
			if hit >= GetValue(m,sp) then
				CastSkillShot(sp, pos)
          end
	elseif m.CP:Value() == 4 then
		local Pred = GetPredictionForPlayer(s.pos,u,u.ms, t.speed, t.delay*1000, t.range, t.width, t.col, true)
		if Pred.HitChance == GetValue(m,sp) and GetDistance(s,Pred.PredPos) < t.range then
			CastSkillShot(sp, Pred.PredPos)
		end
	elseif m.CP:Value() == 5 then
		local SLhc,SLpos = SLP:Predict({source=s,unit=u,speed=t.speed,range=t.range,delay=t.delay,width=t.width,type=t.type,collision=t.col})
		if SLhc and SLhc+.1 >= GetValue(m,sp) and SLpos then
			CastSkillShot(sp,SLpos)
		end
	end
end

local function dRectangleOutline(s, e, w, t, c, v)--start,end,width,thickness,color
	local z1 = s+Vector(Vector(e)-s):perpendicular():normalized()*w/2
	local z2 = s+Vector(Vector(e)-s):perpendicular2():normalized()*w/2
	local z3 = e+Vector(Vector(s)-e):perpendicular():normalized()*w/2
	local z4 = e+Vector(Vector(s)-e):perpendicular2():normalized()*w/2
	local z5 = s+Vector(Vector(e)-s):perpendicular():normalized()*w
	local z6 = s+Vector(Vector(e)-s):perpendicular2():normalized()*w
	local c1 = WorldToScreen(0,z1)
	local c2 = WorldToScreen(0,z2)
	local c3 = WorldToScreen(0,z3)
	local c4 = WorldToScreen(0,z4)
	local c5 = WorldToScreen(0,z5)
	local c6 = WorldToScreen(0,z6)
	if v then
		DrawLine(c5.x,c5.y,c6.x,c6.y,t+1,ARGB(200,250,192,0))
		DrawLine(c2.x,c2.y,c3.x,c3.y,t,c)
		DrawLine(c3.x,c3.y,c4.x,c4.y,t,c)
		DrawLine(c1.x,c1.y,c4.x,c4.y,t,c)
	else
		DrawLine(c5.x,c5.y,c6.x,c6.y,t+0.5,ARGB(255,255,0,0))
		DrawLine(c2.x,c2.y,c3.x,c3.y,t,ARGB(150,255,255,255))
		DrawLine(c3.x,c3.y,c4.x,c4.y,t,ARGB(150,255,255,255))
		DrawLine(c1.x,c1.y,c4.x,c4.y,t,ARGB(150,255,255,255))
	end
end

function DrawRectangle2(x, y, width, height, color, thickness)
    local thickness = thickness or 1
	if thickness == 0 then return end
    x = x - 1
    y = y - 1
    width = width + 2
    height = height + 2
    local halfThick = math.floor(thickness/2)
    DrawLine(x - halfThick, y, x + width + halfThick, y, thickness, color)
    DrawLine(x, y + halfThick, x, y + height - halfThick, thickness, color)
    DrawLine(x + width, y + halfThick, x + width, y + height - halfThick, thickness, color)
    DrawLine(x - halfThick, y + height, x + width + halfThick, y + height, thickness, color)
end

local function dRectangleOutline2(s, e, w, t, c, v)--start,end,radius,thickness,color
	local z1 = s+Vector(Vector(e)-s):perpendicular():normalized()*w
	local z2 = s+Vector(Vector(e)-s):perpendicular2():normalized()*w
	local z3 = e+Vector(Vector(s)-e):perpendicular():normalized()*w
	local z4 = e+Vector(Vector(s)-e):perpendicular2():normalized()*w
	local c1 = WorldToScreen(0,z1)
	local c2 = WorldToScreen(0,z2)
	local c3 = WorldToScreen(0,z3)
	local c4 = WorldToScreen(0,z4)
	if v then
		DrawLine(c1.x,c1.y,c2.x,c2.y,t+1,ARGB(200,250,192,0))
		DrawLine(c2.x,c2.y,c3.x,c3.y,t,c)
		DrawLine(c3.x,c3.y,c4.x,c4.y,t,c)
		DrawLine(c1.x,c1.y,c4.x,c4.y,t,c)
	else
		DrawLine(c1.x,c1.y,c2.x,c2.y,t+0.5,ARGB(255,255,0,0))
		DrawLine(c2.x,c2.y,c3.x,c3.y,t,ARGB(255,102,102,102))
		DrawLine(c3.x,c3.y,c4.x,c4.y,t,ARGB(255,102,102,102))
		DrawLine(c1.x,c1.y,c4.x,c4.y,t,ARGB(255,102,102,102))
	end
end


local function DrawRectangle(s,e,r,r2,t,c)
    local spos = Vector(e) - (Vector(e) - Vector(s)):normalized():perpendicular() * (r2 or 400)
    local epos = Vector(e) + (Vector(e) - Vector(s)):normalized():perpendicular() * (r2 or 400)
	local ePos = Vector(epos)
	local sPos = Vector(spos)
	local dVec = Vector(ePos - sPos)
	local sVec = dVec:normalized():perpendicular()*((r)*.5)
	local TopD1 = WorldToScreen(0,sPos-sVec)
	local TopD2 = WorldToScreen(0,sPos+sVec)
	local BotD1 = WorldToScreen(0,ePos-sVec)
	local BotD2 = WorldToScreen(0,ePos+sVec)
	DrawLine(TopD1.x,TopD1.y,TopD2.x,TopD2.y,t,c)
	DrawLine(TopD1.x,TopD1.y,BotD1.x,BotD1.y,t,c)
	DrawLine(TopD2.x,TopD2.y,BotD2.x,BotD2.y,t,c)
	DrawLine(BotD1.x,BotD1.y,BotD2.x,BotD2.y,t,c)
end

local function DrawCone(v1,v2,angle,width,color)
    angle = angle * math.pi / 180
    v1 = Vector(v1)
    v2 = Vector(v2)
    
    local a1 = Vector(Vector(v2)-Vector(v1)):rotated(0,-angle*.5,0)
    local a2 = nil
    DrawLine3D(v1.x,v1.y,v1.z,v1.x+a1.x,v1.y+a1.y,v1.z+a1.z,width,color)
    for i = -angle*.5,angle*.5,angle*.1 do
        a2 = Vector(v2-v1):rotated(0,i,0)
        DrawLine3D(v1.x+a2.x,v1.y+a2.y,v1.z+a2.z,v1.x+a1.x,v1.y+a1.y,v1.z+a1.z,width,color)
        a1 = a2
    end    
    DrawLine3D(v1.x,v1.y,v1.z,v1.x+a1.x,v1.y+a1.y,v1.z+a1.z,width,color)
end

local ta = {_G.HoldPosition, _G.AttackUnit}
local function DisableHoldPosition(boolean)
	if boolean then
		_G.HoldPosition, _G.AttackUnit = function() end, function() end
	else
		_G.HoldPosition, _G.AttackUnit = ta[1], ta[2]
	end
end

local tabl = {_G.AttackUnit}
local function DisableAttacks(boolean)
	if boolean then
		 _G.AttackUnit = function() end
	else
		_G.AttackUnit = tabl[1]
	end
end

local function AllyMinionsAround(pos, range)
	local c = 0
	if pos == nil then return 0 end
	for k,v in pairs(SLM2) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == myHero.team then
			c = c + 1
		end
	end
	return c
end

local function CircleSegment(x,y,radius,sAngle,eAngle,color)
    for a = sAngle,eAngle do
        DrawLine(x,y,x+radius*math.cos(a*math.pi/180),y+radius*math.sin(a*math.pi/180),5,color)
    end
end

local function CircleSegment2(x,y,sRadius,eRadius,sAngle,eAngle,color)
    for a = sAngle,eAngle do
        DrawLine(x+sRadius*math.cos(a*math.pi/180),y+sRadius*math.sin(a*math.pi/180),x+eRadius*math.cos(a*math.pi/180),y+eRadius*math.sin(a*math.pi/180),1,color)
    end
end

local function GetLowestUnit(i,range)
	if not range then range = myHero.range+myHero.boundingRadius*2 end
	local t, p = nil, math.huge
	if i.alive and i and i.team ~= myHero.team then
		if ValidTarget(i, range) and i.health < p then
			t = i
			p = i.health
		end
	end
	return t
end

local function GetHighestUnit(i,range)
	if not range then range = myHero.range+myHero.boundingRadius*2 end
	local t = nil
		if i and i.alive and i.team ~= myHero.team then
			if ValidTarget(i, range) and not t or GetMaxHP(i) > GetMaxHP(t) then
				t = i
			end
		end
  return t
end

local function EnemyMinionsAround(pos, range)
	local c = 0
	if pos == nil then return 0 end
	for k,v in pairs(SLM) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == MINION_ENEMY then
			c = c + 1
		end
	end
	return c
end

local function JungleMinionsAround(pos, range)
	local c = 0
	if pos == nil then return 0 end
	for k,v in pairs(SLM) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == MINION_JUNGLE then
			c = c + 1
		end
	end
	return c
end

local function AllyHeroesAround(pos, range)
	local c = 0
	if not pos or not range then return end
	for k,v in pairs(GetAllyHeroes()) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == myHero.team then
			c = c + 1
		end
	end
	return c
end

local function EnemyHeroesAround(pos, range)
	local c = 0
	if not pos or not range then return end
	for k,v in pairs(GetEnemyHeroes()) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == MINION_ENEMY then
			c = c + 1
		end
	end
	return c
end

local function Sample(obj)
    return {x=obj.pos.x, y=obj.pos.y, z=obj.pos.z, time=GetTickCount()/1000 }
end

OnObjectLoad(function(obj)
	if obj and obj.type == Obj_AI_SpawnPoint or obj.type == Obj_AI_Turret or obj.type == Obj_AI_Barracks and obj.alive and obj.team ~= myHero.team then
		structures[obj.networkID] = obj
	end
	if obj and obj.networkID then
		if obj.name:lower():find("visionward") then
			if  ((obj.team == myHero.team) or (obj.team ~= myHero.team ))  then
				table.insert(Wards,{o=obj})
			end
		end
		if obj.name:lower():find("sightward") then
			if  ((obj.team == myHero.team) or (obj.team ~= myHero.team ))  then
				table.insert(Wards2,{o=obj,s=GetTickCount()})
			end
		end
	end
	if obj.type == Obj_AI_SpawnPoint and obj.team ~= myHero.team then
		spawn = obj
    end
end)

OnDeleteObj(function(obj)
	if obj and obj.type == Obj_AI_SpawnPoint or obj.type == Obj_AI_Turret or obj.type == Obj_AI_Barracks and obj.team == MINION_ENEMY then
		structures[obj.networkID] = nil
	end
end)

local function DisableAll(b)
	if b then
		if _G.IOW then
			IOW.movementEnabled = false
			IOW.attacksEnabled = false
		elseif _G.PW then
			PW.movementEnabled = false
			PW.attacksEnabled = false
		elseif _G.GoSWalkLoaded then
			_G.GoSWalk:EnableMovement(false)
			_G.GoSWalk:EnableAttack(false)
		elseif _G.DAC_Loaded then
			DAC:MovementEnabled(false)
			DAC:AttacksEnabled(false)
		elseif _G.AutoCarry_Loaded then
			DACR.movementEnabled = false
			DACR.attacksEnabled = false
		elseif _G.SLW then
			SLW.movementEnabled = false
			SLW.attacksEnabled = false
		end
		BlockF7OrbWalk(true)
		BlockF7Dodge(true)
		BlockInput(true)
	else
		if _G.IOW then
			IOW.movementEnabled = true
			IOW.attacksEnabled = true
		elseif _G.PW then
			PW.movementEnabled = true
			PW.attacksEnabled = true
		elseif _G.GoSWalkLoaded then
			_G.GoSWalk:EnableMovement(true)
			_G.GoSWalk:EnableAttack(true)
		elseif _G.DAC_Loaded then
			DAC:MovementEnabled(true)
			DAC:AttacksEnabled(true)
		elseif _G.AutoCarry_Loaded then
			DACR.movementEnabled = true
			DACR.attacksEnabled = true
		elseif _G.SLW then
			SLW.movementEnabled = true
			SLW.attacksEnabled = true
		end
		BlockF7OrbWalk(false)
		BlockF7Dodge(false)
		BlockInput(false)
	end
end

local function dArrow(s, e, w, c)--startpos,endpos,width,color
	local s2 = e-((s-e):normalized()*75):perpendicular()+(s-e):normalized()*75
	local s3 = e-((s-e):normalized()*75):perpendicular2()+(s-e):normalized()*75
	DrawLine3D(s.x,s.y,s.z,e.x,e.y,e.z,w,c)
	DrawLine3D(s2.x,s2.y,s2.z,e.x,e.y,e.z,w,c)
	DrawLine3D(s3.x,s3.y,s3.z,e.x,e.y,e.z,w,c)	
end

if not FileExist(COMMON_PATH.. "Analytics.lua") then
  DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() end)
end

if SLSChamps[myHero.charName] then
	if FileExist(COMMON_PATH.. "Analytics.lua") then
		require("Analytics")

		Analytics("SL-AIO", "SL-Team", true)
	end
end

local Name = GetMyHero()
local ChampName = myHero.charName
local Dmg = {}
local Mode = nil
local SReady = {
	[0] = false,
	[1] = false,
	[2] = false,
	[3] = false,
}

local function GetADHP(unit)
	return GetCurrentHP(unit) + GetDmgShield(unit)
end

local function GetAPHP(unit)
	return GetCurrentHP(unit) + GetDmgShield(unit) + GetMagicShield(unit)
end

local function IsLaneCreep(unit)
	return unit.team ~= 300
end

local function GetReady()
	for s = 0,3 do 
		if CanUseSpell(myHero,s) == READY then
			SReady[s] = true
		else 
			SReady[s] = false
		end
	end
end 

local t = {_G.MoveToXYZ, _G.AttackUnit, _G.CastSkillShot, _G.CastSkillShot2, _G.CastSkillShot3, _G.HoldPosition, _G.CastSpell, _G.CastTargetSpell}
function Stop(state)
	if state then 
		_G.MoveToXYZ, _G.AttackUnit, _G.CastSkillShot, _G.CastSkillShot2, _G.CastSkillShot3, _G.HoldPosition, _G.CastSpell, _G.CastTargetSpell = function() end, function() end,function() end,function() end,function() end,function() end,function() end,function() end
		BlockF7OrbWalk(true)
		BlockF7Dodge(true)
	else
		_G.MoveToXYZ, _G.AttackUnit, _G.CastSkillShot, _G.CastSkillShot2, _G.CastSkillShot3, _G.HoldPosition, _G.CastSpell, _G.CastTargetSpell = t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8]
		BlockF7OrbWalk(false)
		BlockF7Dodge(false)
	end
end

Callback.Add("Tick", function()
	if lastcheck + 1000 < GetTickCount() then
		lastcheck = GetTickCount()
		for _,i in pairs(minionManager.objects) do
			if i.valid and i.distance < 2000 and i.alive and i.team ~= MINION_ALLY then
				SLM[i.networkID] = i
			end
		end
		for _,i in pairs(minionManager.objects) do
			if i.valid and i.distance < 2000 and i.alive and i.team == MINION_ALLY then
				SLM2[i.networkID] = i
			end
		end
		for _,i in pairs(structures) do
			if i.valid and i.alive then
				turrets[i.networkID] = i
			end
		end
	end
end)

Callback.Add("Load", function()	
	Update()
	Init()
	LoadSLP()
	if SLSChamps[ChampName] and L.LC:Value() then
		_G[ChampName]() 
		DmgDraw()
		if myHero.charName ~= "Orianna" and myHero.charName ~= "Ahri" and myHero.charName ~= "Anivia" then
			Drawings()
		end
	end
	if SLSChamps[ChampName] then
		PrintChat("<font color=\"#fd8b12\"><b>["..SLPatchnew.."] [SL-AIO] v.: "..SLAIO.." - <font color=\"#FFFFFF\">" ..ChampName.." <font color=\"#F2EE00\"> Loaded! </b></font>")
	else
		PrintChat("<font color=\"#fd8b12\"><b>["..SLPatchnew.."] [SL-AIO] v.: "..SLAIO.." - <font color=\"#FFFFFF\">" ..ChampName.." <font color=\"#F2EE00\"> is not Supported </b></font>")
	end
	if L.LU:Value() then
		if SLU.Load.LA:Value() then
			Activator()
		end
		if SLU.Load.LSK:Value() then
			SkinChanger()
		end
		if SLU.Load.LAL:Value() then
			AutoLevel()
		end
		if SLU.Load.LH:Value() then
			Humanizer()
		end
		if SLU.Load.LAW:Value() then 
			Awareness()
		end
		if SLU.Load.LRLI:Value() then 
			Reallifeinfo()
		end
		if (myHero.charName == "Katarina" or myHero.charName == "LeeSin" or myHero.charName == "Jax" and SLU.Load.LWJ:Value()) then
			WardJump()
		end
	end
	if L.LE:Value() then
		if not _G.MapPosition then
			require('MapPositionGoS')
		end
		LoadSLE()
	end
	if L.LWal:Value() then
		LoadSLW()
	end
	Recommend()
	SLOrb()
end)   
 
class 'Init'

function Init:__init()
	SxcS = MenuConfig("","----["..SLPatchnew.."][v.:"..SLAIO.."|"..Stage.."]----")
	L = MenuConfig("Loader", "|SL-AIO| Script-Loader")
	L:Info("R","")
	L:Boolean("LC", "Load Champion", true)
	L:Info("0.1", "")
	L:Boolean("LU", "Load Utility", true)
	L:Info("0.2", "")
	L:Boolean("LE", "Load Evade", false)
	L:Info("0.6xc", "")
	L:Boolean("LWal", "Load Orbwalker", false)
	L:Info("xxx", "")
	L:Info("0.7.", "You will have to press 2f6")
	L:Info("0.8.", "to apply the changes")
	xAntiGapCloser = {}
	xGapCloser = {}
	MapPositionGOS = {["Vayne"] = true, ["Poppy"] = true, ["Kalista"] = true, ["Kindred"] = true,}
	
	if L.LC:Value() and SLSChamps[ChampName] then
		BM = MenuConfig("Champions", "|SL-AIO| "..myHero.charName)
		if xAntiGapCloser[ChampName] == true then 
			BM.M:Menu("AGP", "AntiGapCloser") 
		end
		if xGapCloser[ChampName] == true then 
			BM.M:Menu("GC", "GapCloser")
		end
	end
	if L.LU:Value() then 
		SLU = MenuConfig("Utility", "|SL-AIO| Utility")
		SLU:Menu("Load", "Utility-Loader")
		SLU.Load:Boolean("LA", "Load Activator", true)
		SLU.Load:Info("as^dasc", "")
		SLU.Load:Boolean("LSK", "Load SkinChanger", true)
		SLU.Load:Info("0.3", "")
		SLU.Load:Boolean("LAL", "Load AutoLevel", true)
		SLU.Load:Info("0.4", "")
		SLU.Load:Boolean("LH", "Load Humanizer", true)
		SLU.Load:Info("0.5.", "")
		SLU.Load:Boolean("LAW", "Load Awareness", true)
		SLU.Load:Info("0.6.", "")
		SLU.Load:Boolean("LRLI", "Load Real life info", true)
		SLU.Load:Info("0.6yc", "")
		if myHero.charName == "Katarina" or myHero.charName == "LeeSin" or myHero.charName == "Jax" then
		SLU.Load:Boolean("LWJ", "Load Ward Jump", true)
		SLU.Load:Info("0.6^c", "")
		end
		SLU.Load:Info("0.7.", "You will have to press 2f6")
		SLU.Load:Info("0.8.", "to apply the changes")
		
		SLU:Menu("Activator", "Activator")
		M = SLU["Activator"]
	end
	if L.LE:Value() then
		EMenu = MenuConfig("Evade", "|SL-AIO| Evade")
	end
	if L.LWal:Value() then
		OMenu = MenuConfig("Orbwalk", "|SL-AIO| OrbWalk")
	end
	if MapPositionGOS[ChampName] == true and FileExist(COMMON_PATH .. "MapPositionGOS.lua") then
		if not _G.MapPosition then
			require('MapPositionGoS')
		end
	end
	if myHero.charName == "Vayne" or myHero.charName == "Veigar" then
		if not OpenPredict then
			require 'OpenPredict'
		end
	end
	Zwei = MenuConfig("Creators", "----[ by : SxcS & Zwei ]----")
	L:Info("Verison", "Current Version : "..SLAIO.." | "..Stage)
end

class 'Recommend'

function Recommend:__init()
	self.RecommendedUtility = {
	[1] = {Name = "Radar Hack", 	Link = "https://raw.githubusercontent.com/qqwer1/GoS-Lua/master/RadarHack.lua",		       		Author = "Noddy",	File = "RadarHack"},
	[2] = {Name = "Recall Tracker",	Link = "https://raw.githubusercontent.com/qqwer1/GoS-Lua/master/RecallTracker.lua",	       		Author = "Noddy",	File = "RecallTracker"},
	[3] = {Name = "GoSEvade",       Link = "https://raw.githubusercontent.com/KeVuong/GoS/master/Evade.lua",                   		Author = "MeoBeo",	File = "Evade"},
	[4] = {Name = "ChallengerEvade",Link = "https://raw.githubusercontent.com/D3ftsu/GoS/master/ChallengerEvade.lua",      			Author = "Deftsu",	File = "ChallengerEvade"},
	}
	L:Menu("Re","Recommended Scripts")
	L.Re:Info("xx.x", "Load : ")
	for n,i in pairs(self.RecommendedUtility) do
		L.Re:Boolean("S"..n,"- "..i.Name.." ["..i.Author.."]", false)
	end
	L.Re:Info("xxx","2x F6 after download")	
	for n,i in pairs(self.RecommendedUtility) do
		if L.Re["S"..n]:Value() and not pcall (require, i.File) then
			DownloadFileAsync(i.Link, SCRIPT_PATH .. i.File..".lua", function() 
				if pcall (require, i.File) then
					print("|SL| Downloaded "..i.Name.." from "..i.Author.." succesfully.") 
				else
					print("Error downloading, please install manually")
				end
			end)
		elseif L.Re["S"..n]:Value() and FileExist(SCRIPT_PATH .. i.File .. ".lua") then
			require(i.File)
			print("|SL| Loaded "..i.Name)
		end
	end
end

class 'SLOrb'

function SLOrb:__init()
	if _G.IOW or _G.PW or _G.DAC_Loaded or _G.AutoCarry_Loaded or _G.SLW then
		ModeTable = {
		["Combo"] = "Combo",
		["Harass"] = "Harass",
		["LastHit"] = "LastHit",
		["LaneClear"] = "LaneClear",
		}    
	elseif _G.GoSWalkLoaded then
		ModeTable = {
		[0] = "Combo",
		[1] = "Harass",
		[3] = "LastHit",
		[2] = "LaneClear",
		}
		else 
		ModeTable = {}
	end
	if _G.IOW then
		OrbMode = function() return IOW:Mode() end
	elseif _G.PW then
		OrbMode = function() return PW:Mode() end
	elseif _G.DAC_Loaded then
		OrbMode = function() return DAC:Mode() end
	elseif _G.GoSWalkLoaded then
		OrbMode = function() return _G.GoSWalk.CurrentMode end
	elseif _G.AutoCarry_Loaded  then
		OrbMode = function() return DACR:Mode() end
	elseif _G.SLW then
		OrbMode = function() return SLW:Mode() end
	else
		OrbMode = function() return nil end
	end
	
	Callback.Add("Tick",function() 
		Mode = ModeTable[OrbMode()]
	end)
end
	
---------------------------------------------------------------------------------------------
-------------------------------------CHAMPS--------------------------------------------------
---------------------------------------------------------------------------------------------


--[[
 __      __                    
 \ \    / /                    
  \ \  / /_ _ _   _ _ __   ___ 
   \ \/ / _` | | | | '_ \ / _ \
    \  / (_| | |_| | | | |  __/
     \/ \__,_|\__, |_| |_|\___|
               __/ |           
              |___/                       
--]]

class 'Vayne'

function Vayne:__init()

	Spell = {
	[0] = { range = 300 },
	[1] = { range = 0 },
	[2] = { delay = 0.25, speed = 2000, width = 1, range = 550 },
	[3] = { range = 0 }
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 5 * GetCastLevel(myHero,0) + 25 + ((GetBaseDamage(myHero) + GetBonusDmg(myHero)) * .5), 0) end,
	[1] = function (unit) return CalcDamage(myHero, unit, (1.5 * GetCastLevel(myHero,1) + 4.5) * (GetMaxHP(unit)/100) , 0) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 35 * GetCastLevel(myHero,2) + 15 + GetBonusDmg(myHero) * .5, 0) end,
	[3] = function (unit) return CalcDamage(myHero, unit, 20 * GetCastLevel(myHero,3) + 10, 0) end,
	}
	
	BM:Menu("Q", "[Tumble] Q Settings")
	BM.Q:DropDown("QM", "QMode", 1, {"AAReset", "W Proc"})
	BM.Q:Boolean('C', 'Use in Combo', true)
	BM.Q:Boolean('H', 'Use in Harass', true)
	BM.Q:Boolean('JC', 'Use in JungleClear', true)
	BM.Q:Boolean('LC', 'Use in LaneClear', false)
	BM.Q:Info("q",'')
	BM.Q:Boolean("TC", "Dont Tumble into turrets", true)
	BM.Q:Info("",'')
	BM.Q:Slider('MC', "Use in Combo if Mana > x", 0, 0, 100, 0)
	BM.Q:Slider('MH', "Use in Harass if Mana > x", 50, 0, 100, 0)
	BM.Q:Slider('MJC', "Use in JungleClear if Mana > x", 10, 0, 100, 0)
	BM.Q:Slider('MLC', "Use in LaneClear if Mana > x", 50, 0, 100, 0)
	
	BM:Menu("E", "[Condemn] E Settings")
	BM.E:Boolean('C', 'Use in Combo', true)
	BM.E:Boolean('H', 'Use in Harass', true)
	BM.E:Boolean('JC', 'Use in JungleClear', true)
	BM.E:Info("q",'')
	BM.E:Boolean("EAE", "Enable Auto E", true)
	BM.E:Slider("DTE", "Distance to Enemy for auto E", 50, 0, 100, 5)
	BM.E:Boolean("KS", "Enable KS", true)
	BM.E:Info("",'')
	BM.E:Slider("a", "accuracy", 30, 1, 50, 5)
	BM.E:Slider("pd", "Push distance", 480, 1, 550, 5)	
	BM.E:Slider('MC', "Use in Combo if Mana > x", 0, 0, 100, 0)
	BM.E:Slider('MH', "Use in Harass if Mana > x", 50, 0, 100, 0)
	BM.E:Slider('MJC', "Use in JungleClear if Mana > x", 10, 0, 100, 0)

	
	BM:Menu("R", "[Final Hour] R Settings")
	BM.R:Boolean('C', 'Use Final Hour in Combo', true)
	BM.R:Boolean('H', 'Use Final Hour in Harass', false)
	BM.R:Info("q",'')
	BM.R:Boolean("SI", "Stay Invisble", true)
	BM.R:Boolean("DIT", "Draw invisible timer", true)
	BM.R:Info("", "")
	BM.R:Slider("EAR", "EnemiesAround > x", 1, 1, 5, 1)
	BM.R:Slider("AAR", "AlliesAround > x", 0, 0, 5, 1)
	BM.R:Slider("MHP", "My Hero HP < x", 100, 0, 100, 5)
	BM.R:Slider("EHP", "Enemy HP < x", 100, 0, 100, 5)
	BM.R:Slider('MC', "Use in Combo if Mana > x", 0, 0, 100, 0)
	BM.R:Slider('MH', "Use in Harass if Mana > x", 50, 0, 100, 0)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	self.wstacks = {}
	self.invtime = 0
	self.R = false
	self.QPos = nil
	self.QPos2 = nil
	self.QPos3 = nil
	self.TumbleEndPos = nil
	self.TumbleStartPos = nil
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("ProcessSpellComplete", function(un, s) self:AAReset(un, s) end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdB(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemB(u,b) end)
	Callback.Add("Draw", function() self:Drawi() end)
	AntiChannel()
	AntiGapCloser()
	DelayAction( function ()
	if BM["AC"] then BM.AC:Info("ad", "Use Spell(s) : ") BM.AC:Boolean("E","Use E", true) end
	if BM["AGC"] then BM.AGC:Info("ad", "Use Spell(s) : ") BM.AGC:Boolean("E","Use E", true) end
	end,.001)
end

function Vayne:AntiChannel(unit,range)
	if BM.AC.E:Value() and range < Spell[2].range and SReady[2] then
		CastTargetSpell(unit,2)
	end
end

function Vayne:AntiGapCloser(unit,range)
	if BM.AGC.E:Value() and range < Spell[2].range and SReady[2] then
		CastTargetSpell(unit,2)
	end
end

function Vayne:UpdB(u,b)
	if u and b then 
		if b.Name == "VayneSilveredDebuff" then 
			self.wstacks[u.networkID] = b.Count 
		end 
		if u.isMe and b.Name == "vaynetumblefade" then
			self.invtime = GetTickCount() 
			self.R = true
		end
	end
end

function Vayne:RemB(u,b)
	if u and b then 
		if b.Name == "VayneSilveredDebuff" then 
			self.wstacks[u.networkID] = 0 
		end 
		if u.isMe and b.Name == "vaynetumblefade" then
			self.invtime = 0 
			self.R = false
		end
	end
end

function Vayne:GetRTimer()
	if self.invtime > 0 then
		return math.floor(2-(GetTickCount()-self.invtime)*.001)
	end
end

function Vayne:Has2WStacks(u)
	for _,i in pairs(self.wstacks) do
		if i and i == 2 and u.networkID == _ then
			return true
		end
	end
	return false
end

function Vayne:IsStealth()
	if self.invtime > 0 then
		return true
	end
	return false
end

function Vayne:IsUnderTurret(pos,range)
	if not pos or not range then return end
	for _,i in pairs(turrets) do
		if i.team ~= myHero.team and i.valid and GetDistance(i,pos) < range and AllyMinionsAround(i,950) < 2 then
			return true
		end
	end
	return false
end

function Vayne:GetBestTumblePos(u)	
	if (Mode == "Combo" and BM.Q.C:Value() and GetPercentMP(myHero) > BM.Q.MH:Value()) or (Mode == "Harass" and BM.Q.H:Value() and GetPercentMP(myHero) > BM.Q.MC:Value()) or (u and u.isMinion and u.team == MINION_JUNGLE and Mode == "LaneClear" and BM.Q.JC:Value() and GetPercentMP(myHero) > BM.Q.MJC:Value()) or (u and u.isMinion and u.team == MINION_ENEMY and Mode == "LaneClear" and BM.Q.LC:Value() and GetPercentMP(myHero) > BM.Q.MLC:Value()) then
		if BM.Q.TC:Value() then
			if u.type == myHero.type then
				if self.QPos and EnemyHeroesAround(self.QPos,150) == 0 and not self.QPos2 and GetDistance(u,self.QPos) < GetDistance(u,self.QPos2) and GetDistance(self.QPos) > GetDistance(self.QPos2) and GetDistance(GetMousePos(),self.QPos) > GetDistance(GetMousePos(),self.QPos2) and not self:IsUnderTurret(self.QPos,950) then
					self.QPos2 = nil
					return self.QPos
				else
					self.QPos = nil
					if not self:IsUnderTurret(self.QPos2,950) and not self.QPos and self.QPos2 then
						return self.QPos2
					end
				end
			else
				if u.team == MINION_ENEMY then
					if self.QPos and EnemyMinionsAround(self.QPos,150) == 0 and not self.QPos2 and GetDistance(u,self.QPos) < GetDistance(u,self.QPos2) and GetDistance(self.QPos) > GetDistance(self.QPos2) and GetDistance(GetMousePos(),self.QPos) > GetDistance(GetMousePos(),self.QPos2) and not self:IsUnderTurret(self.QPos,950) then
						self.QPos2 = nil
						return self.QPos
					else
						self.QPos = nil
						if not self:IsUnderTurret(self.QPos2,950) and not self.QPos and self.QPos2 then
							return self.QPos2
						end
					end
				elseif u.team == MINION_JUNGLE then
					if self.QPos and JungleMinionsAround(self.QPos,150) == 0 and not self.QPos2 and GetDistance(u,self.QPos) < GetDistance(u,self.QPos2) and GetDistance(self.QPos) > GetDistance(self.QPos2) and GetDistance(GetMousePos(),self.QPos) > GetDistance(GetMousePos(),self.QPos2) and not self:IsUnderTurret(self.QPos,950) then
						self.QPos2 = nil
						return self.QPos
					else
						self.QPos = nil
						if not self:IsUnderTurret(self.QPos2,950) and not self.QPos and self.QPos2 then
							return self.QPos2
						end
					end
				end
			end
		else
			if u.type == myHero.type then
				if self.QPos and EnemyHeroesAround(self.QPos,150) == 0 and not self.QPos2 and GetDistance(u,self.QPos) < GetDistance(u,self.QPos2) and GetDistance(self.QPos) > GetDistance(self.QPos2) and GetDistance(GetMousePos(),self.QPos) > GetDistance(GetMousePos(),self.QPos2) then
					self.QPos2 = nil
					return self.QPos
				else
					self.QPos = nil
					if not self.QPos and self.QPos2 then
						return self.QPos2
					end
				end
			else
				if u.team == MINION_ENEMY then
					if self.QPos and EnemyMinionsAround(self.QPos,150) == 0 and not self.QPos2 and GetDistance(u,self.QPos) < GetDistance(u,self.QPos2) and GetDistance(self.QPos) > GetDistance(self.QPos2) and GetDistance(GetMousePos(),self.QPos) > GetDistance(GetMousePos(),self.QPos2) then
						self.QPos2 = nil
						return self.QPos
					else
						self.QPos = nil
						if not self.QPos and self.QPos2 then
							return self.QPos2
						end
					end
				elseif u.team == MINION_JUNGLE then
					if self.QPos and JungleMinionsAround(self.QPos,150) == 0 and not self.QPos2 and GetDistance(u,self.QPos) < GetDistance(u,self.QPos2) and GetDistance(self.QPos) > GetDistance(self.QPos2) and GetDistance(GetMousePos(),self.QPos) > GetDistance(GetMousePos(),self.QPos2) then
						self.QPos2 = nil
						return self.QPos
					else
						self.QPos = nil
						if not self.QPos and self.QPos2 then
							return self.QPos2
						end
					end
				end
			end	
		end
	end
end

function Vayne:Checks()
	if SReady[0] then
		self.TumbleEndPos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero):normalized() * 300
		self.TumbleStartPos = Vector(myHero)
	else
		self.TumbleEndPos = nil
		self.TumbleStartPos = nil
	end
	if self.TumbleEndPos and self.TumbleStartPos then
		self.QPos = Vector(myHero)+Vector(Vector(GetMousePos())-myHero):normalized()*225+Vector(Vector(self.TumbleEndPos)-Vector(self.TumbleStartPos)):normalized():perpendicular()*225
		self.QPos2 = Vector(myHero)+Vector(Vector(GetMousePos())-myHero):normalized()*225+Vector(Vector(self.TumbleEndPos)-Vector(self.TumbleStartPos)):normalized():perpendicular2()*225
	else
		self.QPos = nil 
		self.QPos2 = nil
	end
	if self:IsStealth() then
		DisableAttacks(true) 
	else 
		DisableAttacks(false) 
	end 
end

function Vayne:CastE(u)
	if SReady[2] and (Mode == "Combo" and BM.E.C:Value() and GetPercentMP(myHero) > BM.E.MH:Value()) or (Mode == "Harass" and BM.E.H:Value() and GetPercentMP(myHero) > BM.E.MC:Value()) or (u and u.isMinion and u.team == MINION_JUNGLE and Mode == "LaneClear" and BM.E.JC:Value() and GetPercentMP(myHero) > BM.E.MJC:Value()) then
		if u.valid and u.distance < 800 then
			local e = GetPrediction(u, Spell[2])
			local ePos = Vector(e.castPos)
			local c = math.ceil(BM.E.a:Value())
			local cd = math.ceil(BM.E.pd:Value()/c)
			for step = 1, c, 5 do
				local PP = Vector(ePos) + Vector(Vector(ePos) - Vector(myHero)):normalized()*(cd*step)
					
				if MapPosition:inWall(PP) == true then
					CastTargetSpell(u, 2)
				end		
			end
		end
	end
end

function Vayne:CastR(u)
	if (Mode == "Combo" and BM.R.C:Value() and GetPercentMP(myHero) > BM.R.MH:Value()) or (Mode == "Harass" and BM.R.H:Value() and GetPercentMP(myHero) > BM.R.MC:Value()) then
		if SReady[3] and ValidTarget(u, 800)  and GetPercentHP(myHero) <= BM.R.MHP:Value() and GetPercentHP(u) <= BM.R.EHP:Value() and EnemyHeroesAround(myHero.pos,1000) >= BM.R.EAR:Value() and AllyHeroesAround(myHero.pos,1000) >= BM.R.AAR:Value() then
			CastSpell(3)
		end
	end
end

function Vayne:Tick()
	if myHero.dead then return end
	target = ts:GetTarget()
	
	GetReady()
	
	self:Checks()
	
	self:AutoE()
	
	self:KS()

	   if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:JungleClear()
		self:LaneClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Vayne:AutoE()
	for _,i in pairs(GetEnemyHeroes()) do
		if BM.E.EAE:Value() and SReady[2] and GetDistance(GetPrediction(i,{ delay = .3, speed = math.huge, width = 1, range = 1500}).castPos) < BM.E.DTE:Value() and i.valid then
			CastTargetSpell(i,2)
		end
	end
end

function Vayne:AAReset(un,s)
	if s and un.isMe and BM.Q.QM:Value() == 1 and s.name:lower():find("attack") then
		local u = s.target
		if u and self.TumbleEndPos and self.TumbleStartPos and self:GetBestTumblePos(u) then
			if GetDistance(self.TumbleEndPos, u) < 630 and GetDistance(self.TumbleEndPos, u) > 100 and SReady[0] then
				CastSkillShot(0, self:GetBestTumblePos(u))
			end
			if GetDistance(u) > 630 and GetDistance(self.TumbleEndPos, u) < 630 and SReady[0] then
				CastSkillShot(0, self:GetBestTumblePos(u))
			end
		end
	end
end

function Vayne:Combo(u)
	if u and BM.Q.QM:Value() == 2 and self:Has2WStacks(u) then
		if self.TumbleEndPos and self.TumbleStartPos and self:GetBestTumblePos(u) then
			if GetDistance(self.TumbleEndPos, u) < 630 and GetDistance(self.TumbleEndPos, u) > 100 and SReady[0] then
				CastSkillShot(0, self:GetBestTumblePos(u))
			end
			if GetDistance(u) > 630 and GetDistance(self.TumbleEndPos, u) < 630 and SReady[0] then
				CastSkillShot(0, self:GetBestTumblePos(u))
			end
		end
	end
	if u then
		self:CastE(u)
		self:CastR(u)
	end
end

function Vayne:Harass(u)
	if u and BM.Q.QM:Value() == 2 and self:Has2WStacks(u) then
		if self.TumbleEndPos and self.TumbleStartPos and self:GetBestTumblePos(u) then
			if GetDistance(self.TumbleEndPos, u) < 630 and GetDistance(self.TumbleEndPos, u) > 100 and SReady[0] then
				CastSkillShot(0, self:GetBestTumblePos(u))
			end
			if GetDistance(u) > 630 and GetDistance(self.TumbleEndPos, u) < 630 and SReady[0] then
				CastSkillShot(0, self:GetBestTumblePos(u))
			end
		end
	end
	if u then
		self:CastE(u)
		self:CastR(u)
	end
end

function Vayne:JungleClear()
	for _,u in pairs(SLM) do
		if u and BM.Q.QM:Value() == 2 and self:Has2WStacks(u) and u.team == MINION_JUNGLE then
			if self.TumbleEndPos and self.TumbleStartPos and self:GetBestTumblePos(u) then
				if GetDistance(self.TumbleEndPos, u) < 630 and GetDistance(self.TumbleEndPos, u) > 100 and SReady[0] then
					CastSkillShot(0, self:GetBestTumblePos(u))
				end
				if GetDistance(u) > 630 and GetDistance(self.TumbleEndPos, u) < 630 and SReady[0] then
					CastSkillShot(0, self:GetBestTumblePos(u))
				end
			end
		end
		if u then
			self:CastE(u)
		end
	end
end

function Vayne:LaneClear()
	for _,u in pairs(SLM) do
		if u and BM.Q.QM:Value() == 2 and self:Has2WStacks(u) and u.team == MINION_ENEMY then
			if self.TumbleEndPos and self.TumbleStartPos and self:GetBestTumblePos(u) then
				if GetDistance(self.TumbleEndPos, u) < 630 and GetDistance(self.TumbleEndPos, u) > 100 and SReady[0] then
					CastSkillShot(0, self:GetBestTumblePos(u))
				end
				if GetDistance(u) > 630 and GetDistance(self.TumbleEndPos, u) < 630 and SReady[0] then
					CastSkillShot(0, self:GetBestTumblePos(u))
				end
			end
		end
	end
end

function Vayne:Drawi()
	if BM.R.DIT:Value() then
		if self.invtime > 0 then
			DrawText("Invisble for : "..self:GetRTimer().." sek",20,myHero.pos2D.x-75,myHero.pos2D.y,GoS.White)
		end
	end		
end

function Vayne:KS()
	for _,i in pairs(GetEnemyHeroes()) do
		if i and i.alive and i.valid and i.distance < Spell[2].range and Dmg[2](i) > GetADHP(i) and BM.E.KS:Value() then
			CastTargetSpell(i,2)
		end
	end
end


--[[
  ____  _ _ _                           _    
 | __ )| (_) |_ _______ _ __ __ _ _ __ | | __
 |  _ \| | | __|_  / __| '__/ _` | '_ \| |/ /
 | |_) | | | |_ / / (__| | | (_| | | | |   < 
 |____/|_|_|\__/___\___|_|  \__,_|_| |_|_|\_\
                                             
--]]

class 'Blitzcrank'

function Blitzcrank:__init()

	Spell = {
	[0] = { delay = 0.25, speed = 1800, width = 70, range = 900, type = "line",col = true },
	[1] = { range = 0 },
	[2] = { range = 0 },
	[3] = { range = 650 }
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 0, 55 * GetCastLevel(myHero,0) + 25 + GetBonusAP(myHero)) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, (GetBaseDamage(myHero) + GetBonusDmg(myHero)) * 2, 0) end,
	[3] = function (unit) return CalcDamage(myHero, unit, 0, 125 * GetCastLevel(myHero,3) + 125 + GetBonusAP(myHero)) end,
	}
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Slider("EAR", "R hit enemies >= x ", 2, 1, 5, 1)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("E", "Use E", true)
	BM.LC:Boolean("R", "Use R", true)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("E", "Use E", true)
	BM.JC:Boolean("R", "Use R", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Enable","Enable KS", true)
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("R", "Use R", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	Callback.Add("Tick", function() self:Tick() end)
	AntiChannel()
	DelayAction( function ()
	if BM["AC"] then
	BM.AC:Info("ad", "Use Spell(s) : ")
	BM.AC:Boolean("Q","Use Q", true)
	BM.AC:Boolean("R","Use R", true)
	end
	end,.001)

	for i = 0,0 do
		PredMenu(BM.p, i)	
	end
end

function Blitzcrank:Tick()
	if myHero.dead then return end
		target = ts:GetTarget()
	   if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Blitzcrank:AntiChannel(unit,range)
	if BM.AC.Q:Value() and range < 600 and SReady[3] then
		CastSpell(3)
	elseif BM.AC.R:Value() and SReady[0] and range < Spell[0].range then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
end

function Blitzcrank:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range*1.1) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[1] and ValidTarget(target, 1000) and BM.C.W:Value() and GetDistance(myHero,target) <= 850 and SReady[0] then
		CastSpell(1)
	end
	if SReady[2] and ValidTarget(target, 250) and BM.C.E:Value() then
		CastSpell(2)
	end
	if SReady[3] and ValidTarget(target, GetCastRange(myHero,3)) and EnemiesAround(GetOrigin(myHero), GetCastRange(myHero,3)) >= BM.C.EAR:Value() and BM.C.R:Value() then
		CastSpell(3)
	end
end

function Blitzcrank:Harass(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.H.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[2] and ValidTarget(target, 300) and BM.H.E:Value() then
		CastSpell(2)
	end 
end

function Blitzcrank:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range) and BM.LC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[2] and ValidTarget(minion, 300) and BM.LC.E:Value() then
				CastSpell(2)
			end 
			if SReady[3] and ValidTarget(minion, 600) and BM.LC.R:Value() then
				CastSpell(3)
			end
		end
	end
end

function Blitzcrank:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_ENEMY then
			if SReady[0] and ValidTarget(mob, Spell[0].range) and BM.JC.Q:Value() then
				CastGenericSkillShot(myHero,mob,Spell[0],0,BM.p)
			end
			if SReady[2] and ValidTarget(mob, 300) and BM.JC.E:Value() then
				CastSpell(2)
			end 
			if SReady[3] and ValidTarget(mob, 600) and BM.JC.R:Value() then
				CastSpell(3)
			end
		end
	end
end

function Blitzcrank:KS()
	if not BM.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetAPHP(unit) < Dmg[0](unit) and SReady[0] and ValidTarget(unit, Spell[0].range) and BM.KS.Q:Value() then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		if GetADHP(unit) < Dmg[2](unit) and SReady[2] and ValidTarget(unit, 300) and BM.KS.E:Value() then
			CastSpell(2)
		end
		if GetAPHP(unit) < Dmg[3](unit) and SReady[3] and ValidTarget(unit, 600) and BM.KS.R:Value() then
			CastSpell(3)
		end
	end
end


--[[
   _____                 _         
  / ____|               | |        
 | (___   ___  _ __ __ _| | ____ _ 
  \___ \ / _ \| '__/ _` | |/ / _` |
  ____) | (_) | | | (_| |   < (_| |
 |_____/ \___/|_|  \__,_|_|\_\__,_|
                                   
--]]


class 'Soraka'

function Soraka:__init()

	Spell = {
	[0] = { delay = 0.250, speed = math.huge, width = 235, range = 800, type = "circular",col = false },
	[1] = { range = 550, ally = true },
	[2] = { delay = 1.75, speed = math.huge, width = 310, range = 900, type = "circular", col = false}
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 0, 40 * GetCastLevel(myHero,0) + 30 + GetBonusAP(myHero) * .35 ) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 40 * GetCastLevel(myHero,2) + 30 + GetBonusAP(myHero) * .4 ) end,
	}
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("E", "Use E", true)

	BM:Menu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("E", "Use E", true)

	BM:Menu("AW", "Auto W")
	BM.AW:Boolean("Enable", "Enable Auto W", true)
	BM.AW:Info("5620-", "(myHeroHP) To Heal ally")
	BM.AW:Slider("myHeroHP", "myHeroHP >= X", 5, 1, 100, 10)
	BM.AW:Slider("allyHP", "AllyHP <= X", 85, 1, 100, 10)
	BM.AW:Slider("ATRR", "Ally To Enemy Range", 1500, 500, 3000, 10)	
	
	DelayAction(function()
		for _,i in pairs(GetAllyHeroes()) do
			BM.AW:Boolean("h"..GetObjectName(i), "Heal "..GetObjectName(i))
		end
	end, .001)

	BM:Menu("AR", "Auto R")
	BM.AR:Boolean("Enable", "Enable Auto R", true)
	BM.AR:Info("HealInfo", "(myHeroHP) to Heal me with ult")
	BM.AR:Slider("myHeroHP", "myHeroHP <= X", 8, 1, 100, 10)
	BM.AR:Slider("allyHP", "AllyHP <= X", 8, 1, 100, 10)
    	BM.AR:Slider("ATRR", "Ally To Enemy Range", 1500, 500, 3000, 10)

	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Enable", "Enable Killsteal", true)
	BM.KS:Boolean("Q", "Use Q", false)
	BM.KS:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	BM.p:Slider("aE", "Adjust E Delay", 1.5, .5, 2, .1)
	
	Callback.Add("Tick", function() self:Tick() end)
	AntiChannel()
	DelayAction( function ()
	if BM["AC"] then BM.AC:Info("ad", "Use Spell(s) : ") BM.AC:Boolean("E","Use E", true) end
	end,.001)
	for i = 0,2,2 do
		PredMenu(BM.p, i)	
	end
end

function Soraka:AntiChannel(unit,range)
	if SReady[2] and BM.AC.E:Value() and ValidTarget(unit,Spell[2].range) then
		CastSkillShot(2,GetOrigin(unit))
	end
end

function Soraka:Tick()
	if myHero.dead then return end
	Spell[0].delay = BM.p.aE:Value()
	
	target = ts:GetTarget()
	
	GetReady()
		
	self:KS()
	
	self:AutoW()
		
	self:AutoR()

	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:JungleClear()
		self:LaneClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Soraka:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.C.Q:Value() then
		Spell[0].delay = .25 + (GetDistance(myHero,target) / Spell[0].range)*.75
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[2] and ValidTarget(target, Spell[2].range) and BM.C.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end
end

function Soraka:Harass(target)
	if SReady[0] and ValidTarget(target, Spell[0].range*1.1) and BM.H.Q:Value() then
		Spell[0].delay = .25 + (GetDistance(myHero,target) / Spell[0].range)*.55
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[2] and ValidTarget(target, Spell[2].range) and BM.H.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end
end

function Soraka:KS()
	if not BM.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetAPHP(unit) < Dmg[0](unit) and SReady[0] and ValidTarget(unit, Spell[0].range) and BM.KS.Q:Value() then
			Spell[0].delay = .25 + (GetDistance(myHero,unit) / Spell[0].range)*.55
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		if GetAPHP(unit) < Dmg[2](unit) and SReady[2] and ValidTarget(unit, Spell[2].range) and BM.KS.E:Value() then
			CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
		end
	end
end

function Soraka:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range*1.1) and BM.LC.Q:Value() then
				Spell[0].delay = .25 + (GetDistance(myHero,minion) / Spell[0].range)*.55
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
		end
	end
end

function Soraka:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_JUNGLE then
			if SReady[0] and ValidTarget(mob, Spell[0].range*1.1) and BM.JC.Q:Value() then
				Spell[0].delay = .25 + (GetDistance(myHero,mob) / Spell[0].range)*.55
				CastGenericSkillShot(myHero,mob,Spell[0],0,BM.p)
			end
		end
	end
end

function Soraka:AutoW()
    for _,ally in pairs(GetAllyHeroes()) do
	    if GetDistance(myHero,ally)<GetCastRange(myHero,1) and SReady[1] and GetPercentHP(myHero) >= BM.AW.myHeroHP:Value() and GetPercentHP(ally) <= BM.AW.allyHP:Value() and BM.AW.Enable:Value() and EnemiesAround(GetOrigin(ally), BM.AW.ATRR:Value()) >= 1 and BM.AW["h"..GetObjectName(ally)]:Value() then
		    CastTargetSpell(ally, 1)
		end
	end
end

function Soraka:AutoR()
    for _,ally in pairs(GetAllyHeroes()) do
	    if SReady[3] and not ally.dead and GetPercentHP(ally) <= BM.AR.allyHP:Value() and BM.AR.Enable:Value() and EnemiesAround(GetOrigin(ally), BM.AR.ATRR:Value()) >= 1 then
		    CastSpell(3)
	    elseif SReady[3] and not myHero.dead and GetPercentHP(myHero) <= BM.AR.myHeroHP:Value() and BM.AR.Enable:Value() and EnemiesAround(GetOrigin(myHero), BM.AR.ATRR:Value()) >= 1 then
		    CastSpell(3)
		end
	end
end


class 'Sivir'

function Sivir:__init()
	
	Spell = { 
	[0] = { delay = 0.250, speed = 1350, width = 85, range = 1075, type = "line", col = false},
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 20 * GetCastLevel(myHero,0) + 5 + (.1 * GetCastLevel(myHero,0) + .6) * (GetBonusDmg(myHero) + GetBaseDamage(myHero)), .5*GetBonusAP(myHero)) end,
	[1] = function (unit) return CalcDamage(myHero, unit, ((5 * GetCastLevel(myHero,2) + 45)/100) * GetBonusDmg(myHero), 0) end,
	}
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Slider("RE", "Use R if x enemies", 2, 1, 5, 1)
	BM.C:Slider("RHP", "myHeroHP ", 75, 1, 100, 5)
	BM.C:Slider("REHP", "EnemyHP ", 65, 1, 100, 5)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("W", "Use W", true)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("W", "Use W", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("ProcessSpellComplete", function(unit,spell) self:AAReset(unit,spell) end)
	HitMe()
	
	for i = 0,0 do
		PredMenu(BM.p, i)	
	end
end

function Sivir:Tick()
	if myHero.dead then return end
		
	target = ts:GetTarget()
		
	GetReady()
		
	self:KS()
	
	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:JungleClear()
		self:LaneClear()
	else
		return
	end
end

function Sivir:AAReset(unit, spell)
	local ta = spell.target
	if unit == myHero and ta ~= nil and spell.name:lower():find("attack") and SReady[1] then
		if Mode == "Combo" and BM.C.W:Value() then
			if ValidTarget(ta, GetRange(myHero)+GetHitBox(myHero)) then
				CastSpell(1)
			end
		elseif Mode == "LaneClear" and BM.LC.W:Value() and GetTeam(ta) == MINION_ENEMY then
			if ValidTarget(ta, GetRange(myHero)+GetHitBox(myHero)) then
				CastSpell(1)
			end
		elseif Mode == "LaneClear" and BM.JC.W:Value() and GetTeam(ta) == MINION_JUNGLE then
			if ValidTarget(ta, GetRange(myHero)+GetHitBox(myHero)) then
				CastSpell(1)
			end
		end
	end
end
				

function Sivir:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[3] and ValidTarget(target, 800) and BM.C.R:Value() and EnemiesAround(myHero,800) >= BM.C.RE:Value() and GetPercentHP(myHero) < BM.C.RHP:Value() and GetPercentHP(target) < BM.C.REHP:Value() then
		CastSpell(3)
	end
end

function Sivir:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range) and BM.LC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
		end
	end
end

function Sivir:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_JUNGLE then
			if SReady[0] and ValidTarget(mob, Spell[0].range) and BM.JC.Q:Value() then
				CastGenericSkillShot(myHero,mob,Spell[0],0,BM.p)
			end
		end
	end
end

function Sivir:KS()
	for _,target in pairs(GetEnemyHeroes()) do
		if SReady[0] and ValidTarget(target, Spell[0].range) and BM.KS.Q:Value() and GetAPHP(target) < Dmg[0](target) then
			CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
		end
	end
end

function Sivir:HitMe(k,pos,dt,ty)
 DelayAction( function() 
  CastSpell(2)
 end,dt)
end

class 'Nocturne'

function Nocturne:__init()
	Spell = {
	[0] = { delay = 0.250, speed = 1400, width = 120, range = 1125, type = "line", col = false },
	[2] = { range = 425},
	[3] = { range = function() return 1750 + GetCastLevel(myHero,3)*750 end},
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 45 * GetCastLevel(myHero,0) + 15 + GetBonusDmg(myHero)* .75, 0) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 45 * GetCastLevel(myHero,2) + 35 + myHero.ap) end,
	[3] = function (unit) return CalcDamage(myHero, unit, 0, 45 * GetCastLevel(myHero,2) + 35 + myHero.ap) end,
	}
	
	self.marker = nil
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("E", "Use E", true)
	BM.C:DropDown("RM", "R Mode", 2, {"Off","Keypress","Auto"})
	BM.C:KeyBinding("RK", "R Keypress", string.byte("T"))
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	
	HitMe()
	
	for i = 0,0 do
		PredMenu(BM.p, i)	
	end
end

function Nocturne:Tick()
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
		
	self:KS()
	
	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
	else
		return
	end
end

function Nocturne:KS()
	self.marker = false
	for _,target in pairs(GetEnemyHeroes()) do
		if SReady[0] and ValidTarget(target, Spell[0].range) and BM.KS.Q:Value() and GetADHP(target) < Dmg[0](target) then
			CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
		end
		if SReady[3] and ValidTarget(target, Spell[3].range()) and GetADHP(target) < Dmg[0](target) + Dmg[3](target) + Dmg[2](target) + myHero.totalDamage*2 then
			self.marker = target
			if BM.C.RM:Value() == 3 or (BM.C.RM:Value() == 2 and BM.C.RK:Value()) then
				CastSpell(3)
				DelayAction(function() CastTargetSpell(target,3) end, .2)			
			end
		end
	end
end

function Nocturne:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[2] and ValidTarget(target, Spell[2].range) and BM.C.E:Value() then
		CastTargetSpell(target,2)
	end
end

function Nocturne:LaneClear()
	for _,minion in pairs(SLM) do
		if SReady[0] and ValidTarget(minion, Spell[0].range) then
			if GetTeam(minion) == MINION_ENEMY and BM.LC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			elseif GetTeam(minion) == 300 and BM.JC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
		end
	end
end

function Nocturne:Draw()
	if self.marker and BM.C.RM:Value() == 2 then
		DrawText(self.marker.charName .. " killable press " .. string.char(BM.C.RK:Key()),40,50,50,GoS.Red)
	end
end

function Nocturne:HitMe(k,pos,dt,ty)
	DelayAction( function() 
		CastSpell(1)
	end,dt)
end

--[[
                _                 
     /\        | |                
    /  \   __ _| |_ _ __ _____  __
   / /\ \ / _` | __| '__/ _ \ \/ /
  / ____ \ (_| | |_| | | (_) >  < 
 /_/    \_\__,_|\__|_|  \___/_/\_\
                                  
--]]

class "Aatrox"

function Aatrox:__init()
	
	Spell = { 
	[0] = { delay = 0.2, range = 650, speed = 1500, width = 113, type = "circular", col = false },
	[1] = { range = 0 },
	[2] = { delay = 0.1, range = 1000, speed = 1000, width = 150, type = "line", col = false },
	[3] = { range = 550 }
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 35 + GetCastLevel(myHero,0)*45 + GetBonusDmg(myHero)*.6, 0) end,
	[1] = function (unit) return CalcDamage(myHero, unit, 25 + GetCastLevel(myHero,1)*35 + GetBonusDmg(myHero), 0) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 40 + GetCastLevel(myHero,2)*35 + GetBonusDmg(myHero)*.6 + GetBonusAP(myHero)*.6) end,
	[3] = function (unit) return CalcDamage(myHero, unit, 0, 100 + GetCastLevel(myHero,3)*100 + GetBonusAP(myHero)) end,
	}

	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("WE", "Only Toggle if enemy nearby", true)
	BM.C:Slider("WT", "Toggle W at % HP", 45, 5, 90, 5)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Slider("RE", "Use R if x enemies", 2, 1, 5, 1)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear", true)
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("E", "Use E", true)	
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("E", "Use E", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Enable", "Enable Killsteal", true)
	BM.KS:Boolean("Q", "Use Q", false)
	BM.KS:Boolean("E", "Use E", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(unit,buff) self:Stat(unit,buff) end)
	
	if GotBuff(myHero, "aatroxwpower") == 1 then
		self.W = "dmg"
	else
		self.W = "heal"
	end

	for i = 0,2,2 do
		PredMenu(BM.p, i)	
	end
end  

function Aatrox:Tick()
	if myHero.dead then return end
	
	GetReady()
		
	self:KS()
		
	self:Toggle(target)
	target = ts:GetTarget()
	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "LastHit" then
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Aatrox:Toggle(target)
	if SReady[1] and BM.C.W:Value() and (not BM.C.WE:Value() or ValidTarget(target,750)) then
		if GetPercentHP(myHero) < BM.C.WT:Value()+1 and self.W == "dmg" then
			CastSpell(1)
		elseif GetPercentHP(myHero) > BM.C.WT:Value() and self.W == "heal" then
			CastSpell(1)
		end
	end
end

function Aatrox:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range*1.1) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[2] and ValidTarget(target, Spell[2].range*1.1) and BM.C.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end
	if SReady[3] and ValidTarget(target, 550) and BM.C.R:Value() and EnemiesAround(myHero,550) >= BM.C.RE:Value() then
		CastSpell(3)
	end
end

function Aatrox:Harass(target)
	if SReady[2] and ValidTarget(target, Spell[2].range*1.1) and BM.H.E:Value() then
		local Pred = GetPrediction(target, Spell[2])
		if Pred.hitChance >= BM.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < Spell[2].range then
			CastSkillShot(2,Pred.castPos)
		end
	end
end

function Aatrox:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range*1.1) and BM.LC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[2] and ValidTarget(minion, Spell[2].range*1.1) and BM.LC.E:Value() then
				CastGenericSkillShot(myHero,minion,Spell[2],2,BM.p)
			end
		end
	end		
end

function Aatrox:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_JUNGLE then
			if SReady[0] and ValidTarget(mob, Spell[0].range) and BM.JC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[1] and BM.C.W:Value() and ValidTarget(mob,750) then
				if GetPercentHP(myHero) < BM.C.WT:Value()+1 and self.W == "dmg" then
					CastSpell(1)
				elseif GetPercentHP(myHero) > BM.C.WT:Value() and self.W == "heal" then
					CastSpell(1)
				end
			end
			if SReady[2] and ValidTarget(mob, Spell[2].range) and BM.JC.E:Value() then
				CastGenericSkillShot(myHero,minion,Spell[2],2,BM.p)
			end
		end
	end		
end

function Aatrox:KS()
	if not BM.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetADHP(unit) < Dmg[0](unit) and SReady[0] and ValidTarget(unit, Spell[0].range*1.1) and BM.KS.Q:Value() then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		if GetAPHP(unit) < Dmg[2](unit) and SReady[2] and ValidTarget(unit, Spell[2].range*1.1) and BM.KS.E:Value() then
			CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
		end
	end
end

function Aatrox:Stat(unit, buff)
	if unit == myHero and buff.Name:lower() == "aatroxwlife" then
		self.W = "heal"
	elseif unit == myHero and buff.Name:lower() == "aatroxwpower" then
		self.W = "dmg"
	end
end

--  _  __          _ __  __             
-- | |/ /___  __ _( )  \/  |__ ___ __ __
-- | ' </ _ \/ _` |/| |\/| / _` \ V  V /
-- |_|\_\___/\__, | |_|  |_\__,_|\_/\_/ 
 --          |___/                      
  
class 'KogMaw'

function KogMaw:__init()

	self.Dmg = {
	[-1] = function (unit) return 100 + 25 *myHero.level end,
	[0] = function (unit) return CalcDamage(myHero, unit, 0, 50 * GetCastLevel(myHero,0) + 30 + GetBonusAP(myHero)* .5) end, 
	[1] = function (unit) return CalcDamage(myHero, unit, myHero.totalDamage*.55, 4 * GetCastLevel(myHero,1) + (.02 + myHero.ap*.00075)*unit.maxHealth) end, 
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 50 * GetCastLevel(myHero,2) + 10 + myHero.ap* 7 ) end, 
	[3] = function (unit) return CalcDamage(myHero,unit,0,(30 + 40*GetCastLevel(myHero,3) + (myHero.totalDamage-myHero.damage) * .65 + .25 * myHero.ap)*(GetPercentHP(unit)>50 and 1 or (GetPercentHP(unit)<50 and 2 or 3))) end,
	}
	
	Spell = {
	[0] = { range = 1175, delay = .25, width = 75 , speed = 1650, type = "line",col=true},
	[1] = { range = 560 + 30 * myHero.level},
	[2] = { range = 1360, delay = .25, width = 120, speed = 1400, type = "line",col=false},
	[3] = { range = 1800, delay = 1.2, speed = math.huge , radius = 225, type = "circular",col=false},
	}

	BM:SubMenu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Boolean("P", "Use Passive", true)

	BM:SubMenu("L", "LaneClear")
	BM.L:Boolean("Q", "Use Q", false)
	BM.L:Boolean("W", "Use W", false)
	BM.L:Boolean("E", "Use E", false)
	
	BM:SubMenu("J", "JungleClear")
	BM.J:Boolean("Q", "Use Q", true)
	BM.J:Boolean("W", "Use W", true)
	BM.J:Boolean("E", "Use E", false)
	
	BM:SubMenu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", false)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:SubMenu("p", "Prediction")

	self.Passive = GotBuff(myHero,"KogMawIcathianSurprise") ~= 0
	self.dmgPred = {}
	self.soonHP = {}
	self.WOn = CanUseSpell(myHero,2) == 8
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("UpdateBuff", function(unit,buffProc) self:UpdateBuff(unit,buffProc) end)
	Callback.Add("RemoveBuff", function(unit,buffProc) self:RemoveBuff(unit,buffProc) end)
	Callback.Add("ProcessSpellComplete", function(unit,spellProc) self:ProcessSpellComplete(unit,spellProc) end)
	
	DelayAction(function()
		for _,i in pairs(GetEnemyHeroes()) do
			self.dmgPred[i.networkID] = {}
			self.soonHP[i.networkID] = {u = i, h = i.health}
		end
	end)
	
	for i = 2,3 do
		PredMenu(BM.p, i)	
	end
	PredMenu(BM.p, 0)
end

function KogMaw:Tick()
	target = ts:GetTarget()
	GetReady()
	self.WOn = CanUseSpell(myHero,2) == 8
	self:Pred()
	
	if Mode == "Combo" and target and target.valid then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
	elseif Mode == "Harass" and target and target.valid then
		self:Harass(target)
	else
		return
	end
end

function KogMaw:Draw()
	for _,i in pairs(GetEnemyHeroes()) do
		if i.valid then
			DrawDmgOverHpBar(i,i.health,0,self.Dmg[3](i),GoS.White)
		end
	end
end

function KogMaw:Pred()
	for _,i in pairs(self.dmgPred) do
		self.soonHP[_].h = self.soonHP[_].u.health
		for n,m in pairs(i) do
			if os.time()  - n > m.s / 1800 then
				m = nil
			else
				self.soonHP[_].h = self.soonHP[_].h - m.d
			end
		end
	end
end

function KogMaw:Combo(unit)
	if self.Passive and GetADHP(unit) < self.Dmg[-1](unit) then
		MoveToXYZ(unit.pos)
		return
	end
	if SReady[3] and ValidTarget(unit,Spell[3].range) and BM.C.R:Value() and (not SReady[1] or unit.distance > Spell[1].range) and self.soonHP[unit.networkID].h and self.soonHP[unit.networkID].h < self.Dmg[3](unit) then
		CastGenericSkillShot(myHero,target,Spell[3],3,BM.p)
	end
	if SReady[1] and ValidTarget(unit,560 + 30 * myHero.level) and BM.C.W:Value() then
		CastSpell(1)
	end
	if SReady[2] and ValidTarget(unit,Spell[2].range) and BM.C.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end
	if SReady[0] and ValidTarget(unit,Spell[0].range) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
end

function KogMaw:Harass(unit)
	if SReady[1] and ValidTarget(unit,560 + 30 * myHero.level) and BM.H.W:Value() then
		CastSpell(1)
	end
	if SReady[2] and ValidTarget(unit,Spell[2].range) and BM.H.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end
	if SReady[0] and ValidTarget(unit,Spell[0].range) and BM.H.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
end

function KogMaw:LaneClear()
	for _,unit in pairs(SLM) do
		if SReady[1] and ValidTarget(unit,560 + 30 * myHero.level) and ((IsLaneCreep(unit) and BM.L.W:Value()) or (not IsLaneCreep(unit) and BM.J.W:Value())) then
			CastSpell(1)
		end
		if SReady[2] and ValidTarget(unit,Spell[2].range) and ((IsLaneCreep(unit) and BM.L.E:Value()) or (not IsLaneCreep(unit) and BM.J.E:Value())) then
			CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
		end
		if SReady[0] and ValidTarget(unit,Spell[0].range) and ((IsLaneCreep(unit) and BM.L.Q:Value()) or (not IsLaneCreep(unit) and BM.J.Q:Value())) then
			CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
		end
	end
end


function KogMaw:ProcessSpellComplete(u,spellProc)
	if u.isMe and spellProc.target and spellProc.name:lower():find("attack") and spellProc.target.isHero and spellProc.target.valid then
		self.dmgPred[spellProc.target.networkID][os.time()] = {d = (self.Dmg[2](spellProc.target) and self.WOn or myHero.totalDamage), s = spellProc.target.distance}
	end
end

function KogMaw:UpdateBuff(u,buffProc)
	if u.isMe and buffProc.Name == "KogMawIcathianSurprise" then self.Passive = true end
end

function KogMaw:RemoveBuff(u,buffProc)
	if u.isMe and buffProc.Name == "KogMawIcathianSurprise" then self.Passive = false end
end

-- __     __   _ _   _            
-- \ \   / /__| ( ) | | _____ ____
--  \ \ / / _ \ |/  | |/ / _ \_  /
--   \ V /  __/ |   |   < (_) / / 
--    \_/ \___|_|   |_|\_\___/___|

class 'Velkoz'

function Velkoz:__init()

	self.Dmg = {
	[-1] = function (unit) return 25 + myHero.level*8 + GetBonusAP(myHero) * .5 end,
	[0] = function (unit) return CalcDamage(myHero, unit, 40 * GetCastLevel(myHero,0) + 40 + GetBonusAP(myHero), 0)*.6 end, 
	[1] = function (unit) return CalcDamage(myHero, unit, 20 * GetCastLevel(myHero,1) + 10 + GetBonusDmg(myHero), 1)*.15 end, 
	[2] = function (unit) return CalcDamage(myHero, unit, 30 * GetCastLevel(myHero,2) - 10 + GetBonusDmg(myHero), 2)*.3 end, 
	[3] = function (unit) return self:RDmg(unit) end,
	}
	
	Spell = {
	[-1]= { range = 1300, delay =.25, width = 75, speed = 813},
	[0] = { range = 1000, delay =.25, width = 75, speed = 1150},
	[1] = { delay = .1, speed = 1700, width = 100, range = 1050,type = "line",col=false},
	[2] =  { delay = 0.1, speed = 1700, range = 850, radius = 200 ,type = "circular",col=false },
	}

	BM:SubMenu("C", "Combo")
	BM.C:Boolean("Q", "Use Q",true)
	BM.C:DropDown("QM","Q Mode", 1, {"New","Old"})
	BM.C:DropDown("Z","Split Mode", 1, {"Percise","Performance"}, function() print("Reload to change QMode") end)
	BM.C:Boolean("W", "Use W",true)
	BM.C:Boolean("E", "Use E",true)
	BM.C:Boolean("R", "Use R",true)
	BM.C:Boolean("M", "Mouse follow",true)

	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:SubMenu("p", "Prediction")
	
	BM:SubMenu("A", "Advanced")
	BM.A:Slider("S", "SplitMod", .075, .05, .1, .005)
	BM.A:Slider("C", "QChecks", 20, 5, 50, 1)
	BM.A:Boolean("D","Developer Draws", false)

	self.cTable = {}
	self.Researched = {}
	self.Deconstructed = {}
	self.QBall = nil
	self.ult = not GotBuff(myHero,"VelkozR") == 0
	self.DegreeTable={22.5,-22.5,45,-45, 15, -15, 30, -30}
	self.QStart = nil
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add(BM.C.Z:Value() == 1 and "Draw" or "Tick", function() self:Split() end)
	Callback.Add("CreateObj", function(object) self:CreateObj(object) end)
	Callback.Add("DeleteObj", function(object) self:DeleteObj(object) end)
	Callback.Add("UpdateBuff", function(unit,buffProc) self:UpdateBuff(unit,buffProc) end)
	Callback.Add("RemoveBuff", function(unit,buffProc) self:RemoveBuff(unit,buffProc) end)
	Callback.Add("ProcessSpellComplete", function(unit,spellProc) self:ProcessSpellComplete(unit,spellProc) end)
	
	--[[AntiChannel()
	AntiGapCloser()
	DelayAction( function ()
	if BM["AC"] then BM.AC:Info("ad", "Use Spell(s) : ") BM.AC:Boolean("E","Use E", true) end
	if BM["AGC"] then BM.AGC:Info("ad", "Use Spell(s) : ") BM.AGC:Boolean("E","Use E", true) end
	end,.001)
	--]]
	for i = 1,2 do
		PredMenu(BM.p, i)	
	end
end
function Velkoz:ProcessSpellComplete(unit,spellProc)
	if unit == myHero and spellProc.name:lower() == "velkozq" then
		self.QStart= Vector(spellProc.startPos)+Vector(Vector(spellProc.endPos)-spellProc.startPos):normalized()*5
	end
end
--[[
function Velkoz:AntiChannel(unit,range)
	if BM.AC.E:Value() and range < Spell[2].range and SReady[2] then
		CastSkillShot(2,unit.pos)
	end
end

function Velkoz:AntiGapCloser(unit,range)
	if BM.AGC.E:Value() and range < Spell[2].range and SReady[2] then
		CastSkillShot(2,unit.pos)
	end
end--]]

function Velkoz:Tick()
	GetReady()
	target = ts:GetTarget()

	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
	--	self:LaneClear()
	--	self:JungleClear()
	elseif Mode == "LastHit" then
	--	self:LastHit()
	elseif Mode == "Harass" then
	--	self:Harass(target)
	else
		return
	end
end

function Velkoz:Combo(unit)
	if Mode == "Combo" and not self.ult then
		if SReady[1] and ValidTarget(unit,1050) and BM.C.W:Value() then
			CastGenericSkillShot(myHero,unit,Spell[1],1,BM.p)
		end
			
		if SReady[2] and ValidTarget(unit,850) and BM.C.E:Value() then
			CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
		end
		if SReady[3] and ValidTarget(unit,1500) and unit.distance > 350 and unit.health + unit.shieldAD + unit.shieldAP < self:RDmg(unit) and BM.C.R:Value() then
			--SetCursorPos(unit.pos2D.x,unit.pos2D.y)
			CastSkillShot(3,unit.pos)
		end
	elseif Mode == "Combo" and self.ult and unit.valid and WorldToScreen(1,unit.pos).flag and BM.C.M:Value() then
		SetCursorPos(unit.pos2D.x,unit.pos2D.y)
	end
end

function Velkoz:Split()
	local i = target or GetCurrentTarget()
	if self.QBall then
		if BM.C.QM:Value() == 1 then
			local iPredN2 = nil
			if BM.p.CP:Value() == 1 and OpenPredict then
				iPredN2 = GetPrediction(i,Spell[0],self.QBall.pos).castPos
			else
				iPredN2 = GetPredictionForPlayer(self.QBall.pos,i,i.ms, Spell[0].speed, Spell[0].delay*1000, Spell[0].range, Spell[0].width, false, true).PredPos
			end
			self.QBall:Draw(100)
			if iPredN2 and GetCastName(myHero,0) ~= "VelkozQ" and GetDistance(self.QBall,iPredN2) < 1500 and GetDistance(self.QBall,iPredN2) > 50 and math.abs(Vector(self.QBall.pos-GetObjectSpellStartPos(self.QBall)):normalized()*Vector(self.QBall.pos-iPredN2):normalized()) < .1 then
				CastSpell(0)
			end
		else
			if SReady[0] and GetCastName(myHero,0)~="VelkozQ" and self.QBall and self.QStart then
				local split=GetPrediction(i, Spell[-1], GetOrigin(self.QBall))
				local BVector = Vector((GetOrigin(self.QBall))-Vector(self.QStart))
				local HVector = Vector((GetOrigin(self.QBall))-Vector(split.castPos))
				if BM.A.D:Value() then 
					DrawLine(WorldToScreen(0, self.QStart).x, WorldToScreen(0, self.QStart).y, WorldToScreen(0, self.QBall).x, WorldToScreen(0, self.QBall).y, 3, GoS.White)
					DrawLine(WorldToScreen(0, self.QBall).x, WorldToScreen(0, self.QBall).y, WorldToScreen(0, split.castPos).x, WorldToScreen(0, split.castPos).y, 3, GoS.White)
					DrawText(Velkoz:ScalarProduct(BVector,HVector)^2,30,500,20,GoS.White)
				end
				if ValidTarget(i,1600) and Velkoz:ScalarProduct(BVector,HVector)^2 < BM.A.C:Value()*.001 then
					CastSpell(0)
				end
			end
		end
	elseif not self.ult then
		local iPred = nil
		if BM.p.CP:Value() == 1 and OpenPredict then
			iPred = GetPrediction(i,Spell[-1]).castPos
		else
			iPred = GetPredictionForPlayer(myHero.pos,i,i.ms, Spell[-1].speed, Spell[-1].delay*1000, Spell[-1].range, Spell[-1].width, true, true).PredPos
		end
		if iPred then
			local iPred2D = WorldToScreen(0,iPred)
			local lowest = 9999999
			local lowestV = nil
			if not i.valid or myHero.dead then return end
			local BVec = Vector(iPred) - Vector(myHero.pos)
			for l = -math.pi*.5, math.pi*.5, math.pi*.05 do
				local sideVec = Vector(BVec):rotated(0,l,0)
				local sideVec2 = Vector(sideVec):perpendicular()
				if not VectorIntersection(myHero.pos , myHero.pos+sideVec , iPred, iPred+sideVec2) then return end
				local JVector = Vector(VectorIntersection(myHero.pos , myHero.pos+sideVec , iPred, iPred+sideVec2 ).x , myHero.pos.y , VectorIntersection( myHero.pos, myHero.pos + sideVec, iPred, iPred + sideVec2).y)
				local JVector2D = WorldToScreen(0,JVector)
				if GetDistance(JVector) < 1050 and GetDistance(iPred,JVector) < 1050 and CountObjectsOnLineSegment(myHero, Vector(JVector), 125, self.cTable) == 0 and CountObjectsOnLineSegment(i, Vector(JVector), 100, self.cTable) == 0 then
					if BM.A.D:Value() then
						DrawCircle(JVector,50,1,3,GoS.White)
						DrawLine(myHero.pos2D.x,myHero.pos2D.y,JVector2D.x,JVector2D.y,1,GoS.White)
						DrawLine(iPred2D.x,iPred2D.y,JVector2D.x,JVector2D.y,1,GoS.White)
					end
					if JVector and GetDistance(iPred,JVector) < lowest then
						lowestV = JVector
						lowest = GetDistance(iPred,JVector)
					end
				end
			end
			if Mode == "Combo" and lowestV and GetCastName(myHero,0) == "VelkozQ" and BM.C.QM:Value() == 1 then
				if GetDistance(lowestV) > 150 then
					CastSkillShot(0,lowestV)
				else
					CastSkillShot(0,i.pos)
				end
			end
		end
		if Mode == "Combo" and BM.C.Q:Value() and GetCastName(myHero,0)=="VelkozQ" and ValidTarget(i,1400) and BM.C.QM:Value() == 2 then
			local direct=GetPrediction(i,Spell[0])
			if direct and direct.hitChance>=20/100 and not direct:mCollision(1) then
				self.QStart=GetOrigin(myHero)
				CastSkillShot(0,direct.castPos)
			end
			local BVec = Vector(GetOrigin(i)) - Vector(GetOrigin(myHero))
			local dist = math.sqrt(GetDistance(GetOrigin(myHero),GetOrigin(i))^2/2)
			for l=1,5 do
				local sideVec=Velkoz:getVec(BVec,self.DegreeTable[l]):normalized()*dist
				local circlespot = sideVec+GetOrigin(myHero)
				local QPred = GetPrediction(i, Spell[0], circlespot)
				local QPred2 = GetPrediction(myHero, Spell[0], circlespot)
				if not QPred:mCollision(1) and not QPred2:mCollision(1) then
					CastSkillShot(0,circlespot)
					self.QStart = GetOrigin(myHero)
				end
			end
		end
	end
end

function Velkoz:getVec(base, degr)
	local x,y,z=base:unpack()
	x=x*math.cos(Velkoz:degrad(degr))-z*math.sin(Velkoz:degrad(degr))
	z=z*math.cos(Velkoz:degrad(degr))+x*math.sin(Velkoz:degrad(degr))
	return Vector(x,y,z)
end

function Velkoz:ScalarProduct(v1,v2)
	return (v1.x*v2.x+v1.y*v2.y+v1.z*v2.z)/(v1:len()*v2:len())
end

function Velkoz:degrad(degr)
	degr=(degr/180)*math.pi
	return degr
end

function Velkoz:RDmg(unit)
	local hP = math.min(math.max(1550 - unit.distance,0)/(unit.ms*.8),2.5)/2.5
	local pT = (self.Deconstructed[unit.networkID] or 0) + math.floor(hP/0.28)
	local damage = hP * (275 + 175*GetCastLevel(myHero,3) + GetBonusAP(myHero) * 1.25)	
	return self.Researched[unit.networkID] and damage + (pT > 2 and self.Dmg[-1](unit) or 0) or CalcDamage(myHero,unit,0,damage) + (pT > 2 and self.Dmg[-1](unit) or 0)
end	

function Velkoz:CreateObj(obj)
	if obj.isSpell and obj.spellOwner.isMe and obj.spellName == "VelkozQMissile" then
		self.QBall = obj
		DelayAction(function() self.QBall = nil end ,2)
	end
end

function Velkoz:DeleteObj(obj)
	if obj.isSpell and obj.spellOwner.isMe and obj.spellName == "VelkozQMissile" then
		self.QBall = nil
	end
end

function Velkoz:UpdateBuff(u,buffProc)
	if u.isMe and buffProc.Name == "VelkozR" then 
		self.ult = true
		Stop(true)
	elseif u.team ~= myHero.team and u.isHero then
		if buffProc.Name == "velkozresearchedstack" then
			self.Researched[u.networkID] = true
		elseif buffProc.Name == "velkozresearchstack"  then
			self.Deconstructed[u.networkID] = buffProc.Count
		end
	end
end

function Velkoz:RemoveBuff(u,buffProc)
	if u.isMe and buffProc.Name == "VelkozR" then 
		self.ult = false
		Stop(false)
	elseif u.team ~= myHero.team and u.isHero then
		if buffProc.Name == "velkozresearchedstack" then
			self.Researched[u.networkID] = false
		elseif buffProc.Name == "velkozresearchstack" then
			self.Deconstructed[u.networkID] = nil
		end
	end
end

--      _ _            
--     | (_)_ __ __  __
--  _  | | | '_ \\ \/ /
-- | |_| | | | | |>  < 
--  \___/|_|_| |_/_/\_\
                     

class 'Jinx'

function Jinx:__init()


	Spell = {
	[0] = { range = 25 * GetCastLevel(myHero,0) + 600 },
	[1] = { delay = 0.6, speed = 3000, width = 85, range = 1500,type = "line",col=true},
	[2] = { delay = 1, speed = 887, width = 120, range = 900,type = "circular",col=false},
	[3] = { delay = 0.6, speed = 1700, width = 140, range = math.huge,type = "line",col=false},
	}
	
	
	Dmg = {
	[1] = function (unit) return CalcDamage(myHero, unit, 50 * GetCastLevel(myHero,0) - 40 + (GetBonusDmg(myHero)+GetBaseDamage(myHero)) * 1.4, 0) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 55 * GetCastLevel(myHero,2) + 25 + GetBonusAP(myHero)) end, 
	[3] = function (unit) 
	local dmg = 150 + GetCastLevel(myHero,3)*GetBonusDmg(myHero)+(GetMaxHP(unit)-GetCurrentHP(unit))*(.20+GetCastLevel(myHero,3)*.5)
	return CalcDamage(myHero,unit, math.min(math.max(dmg*.1,dmg*GetDistance(GetOrigin(myHero),GetOrigin(unit))/1650),dmg), 0) end
	}
	
	BM:Menu("C", "Combo")
	BM.C:Menu("Q", "Q")
	BM.C.Q:DropDown("QL", "Q-Logic", 1, {"Advanced", "Simple"})
	BM.C.Q:Boolean("enable", "Enable Q Combo", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	
	BM:Menu("H", "Harass")
	BM.H:Menu("Q", "Q")
	BM.H.Q:DropDown("QL", "Q-Logic", 1, {"Advanced", "Simple"})
	BM.H.Q:Boolean("enable", "Enable Q Harass", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Menu("Q", "Q")
	BM.LC.Q:DropDown("QL", "Q-Logic", 1, {"Only Minigun", "Only Rockets"})
	BM.LC.Q:Boolean("enable", "Enable Q Laneclear", true)
	BM.LC:Boolean("W", "Use W", false)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Menu("Q", "Q")
	BM.JC.Q:DropDown("QL", "Q-Logic", 1, {"Only Minigun", "Only Rockets"})
	BM.JC.Q:Boolean("enable", "Enable Q Jungleclear", true)
	BM.JC:Boolean("W", "Use W", false)
	
	BM:Menu("LH", "LastHit")
	BM.LH:Boolean("UMinig", "Use only Minigun", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Enable", "Enable Killsteal", true)
	BM.KS:Boolean("W", "Use W", true)
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Boolean("R", "Enable R KS", true)
	BM.KS:Slider("mDTT", "R - max Distance to target", 3000, 675, 20000, 10)
	BM.KS:Slider("DTT", "R - min Distance to target", 1000, 675, 20000, 10)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("ProcessSpellComplete", function(u,s) self:ProcessSpellComplete(u,s) end)
	Callback.Add("UpdateBuff", function(unit,buff) self:UpdateBuff(unit,buff) end)
	Callback.Add("RemoveBuff", function(unit,buff) self:RemoveBuff(unit,buff) end)

	for i = 1,3 do
		PredMenu(BM.p, i)	
	end
end

function Jinx:UpdateBuff(unit, buff)
	if unit == myHero and buff.Name == "jinxqicon" then
		minigun = true
	end
end

function Jinx:RemoveBuff(unit, buff)
	if unit == myHero and buff.Name == "jinxqicon" then
		minigun = false
	end
end

function Jinx:Tick()
	if myHero.dead then return end
	
	self.RocketRange = 25 * GetCastLevel(myHero,_Q) + 600
	target = ts:GetTarget()
	
	GetReady()
		
	self:KS()
		
	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "Harass" then
		self:Harass(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "LastHit" then
		self:LastHit()
	else
		return
	end
end

function Jinx:ProcessSpellComplete(u,s)
	if s and s.name:lower():find("attack") and u.isMe then
		local target = s.target
		if Mode == "Combo" and target then
			if BM.C.Q.QL:Value() == 1 and BM.C.Q.enable:Value() then
				if SReady[0] and ValidTarget(target, self.RocketRange) and minigun and GetDistance(target) > 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and minigun and GetDistance(target) > 550 and EnemiesAround(target, 150) > 2 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetDistance(target) < 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetPercentMP(myHero) < 10 then
					CastSpell(0)
				end
			elseif BM.C.Q.QL:Value() == 2 and BM.C.Q.enable:Value() then
				if SReady[0] and ValidTarget(target, self.RocketRange) and minigun and GetDistance(target) > 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetDistance(target) < 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetPercentMP(myHero) < 10 then
					CastSpell(0)
				end		
			end	
		elseif Mode == "Harass" and target then
			if BM.H.Q.QL:Value() == 1 and BM.H.Q.enable:Value() then
				if SReady[0] and ValidTarget(target, self.RocketRange) and minigun and GetDistance(target) > 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and minigun and GetDistance(target) > 550 and EnemiesAround(target, 150) > 2 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetDistance(target) < 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetPercentMP(myHero) < 10 then
					CastSpell(0)
				end		
			elseif BM.C.Q.QL:Value() == 2 and BM.H.Q.enable:Value() then	
				if SReady[0] and ValidTarget(target, self.RocketRange) and minigun and GetDistance(target) > 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetDistance(target) < 550 and GetPercentMP(myHero) > 10 then
					CastSpell(0)
				elseif SReady[0] and ValidTarget(target, self.RocketRange) and not minigun and GetPercentMP(myHero) < 10 then
					CastSpell(0)
				end		
			end		
		end
	end
end

function Jinx:Combo(target)
	if SReady[1] and ValidTarget(target, Spell[1].range) and BM.C.W:Value() and GetDistance(myHero,target)>100 then
		CastGenericSkillShot(myHero,target,Spell[1],1,BM.p)
	end	
	if SReady[2] and ValidTarget(target, Spell[2].range) and BM.C.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end	
end

function Jinx:Harass(target)
	if SReady[1] and ValidTarget(target, Spell[1].range) and BM.H.W:Value() and GetDistance(myHero,target)>100 then
		CastGenericSkillShot(myHero,target,Spell[1],1,BM.p)
	end	
	if SReady[2] and ValidTarget(target, Spell[2].range) and BM.H.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end	
end

function Jinx:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			
			if BM.LC.Q.QL:Value() == 1 and BM.LC.Q.enable:Value() then	
			
				if SReady[0] and ValidTarget(minion, self.RocketRange) and not minigun then
					CastSpell(0)
				end
		
			elseif BM.LC.Q.QL:Value() == 2 and BM.LC.Q.enable:Value() then
	
				if SReady[0] and ValidTarget(minion, self.RocketRange) and minigun then
					CastSpell(0)
				end	
			end
			
			if SReady[1] and ValidTarget(minion, Spell[1].range) and BM.LC.W:Value() then
				CastGenericSkillShot(myHero,unit,Spell[1],1,BM.p)
			end
		end
	end
end

function Jinx:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_JUNGLE then
			
			if BM.JC.Q.QL:Value() == 1 and BM.JC.Q.enable:Value() then	
			
				if SReady[0] and ValidTarget(mob, self.RocketRange) and not minigun then
					CastSpell(0)
				end
		
			elseif BM.JC.Q.QL:Value() == 2 and BM.JC.Q.enable:Value() then
	
				if SReady[0] and ValidTarget(mob, self.RocketRange) and minigun then
					CastSpell(0)
				end	
			end
			
			if SReady[1] and ValidTarget(mob, Spell[1].range) and BM.LC.W:Value() then
				CastGenericSkillShot(myHero,unit,Spell[1],1,BM.p)
			end
		end
	end
end

function Jinx:LastHit()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if BM.LH.UMinig:Value() and ValidTarget(minion, self.RocketRange) and not minigun and SReady[0] then
				CastSpell(0)
			end
		end
	end
end

function Jinx:KS()
	if not BM.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetADHP(unit) < Dmg[1](unit) and SReady[1] and ValidTarget(unit, Spell[1].range) and BM.KS.W:Value() then
			CastGenericSkillShot(myHero,unit,Spell[1],1,BM.p)
		end
		if GetAPHP(unit) < Dmg[2](unit) and SReady[2] and ValidTarget(unit, Spell[2].range) and BM.KS.E:Value() then
			CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
		end
		if GetADHP(unit) < Dmg[3](unit) and SReady[3] and ValidTarget(unit, BM.KS.mDTT:Value()) and BM.KS.R:Value() and GetDistance(unit) >= BM.KS.DTT:Value() then
			CastGenericSkillShot(myHero,unit,Spell[3],3,BM.p)
		end
	end
end

 -- _  __     _ _     _        
 --| |/ /__ _| (_)___| |_ __ _ 
 --| ' // _` | | / __| __/ _` |
 --| . \ (_| | | \__ \ || (_| |
 --|_|\_\__,_|_|_|___/\__\__,_|
                             

class 'Kalista'

function Kalista:__init()


	self.eTrack = {}
	self.soul = nil
	self.dragon = nil
	self.EpicJgl = nil
	self.BigJgl = nil
	for _,i in pairs(GetAllyHeroes()) do
		if GotBuff(i, "kalistacoopstrikeally") == 1 then
			soul = i
		end
	end

	
	Spell = {
	[-1] = { delay = .3, speed = math.huge, width = 1, range = 1500},
	[0] = { delay = 0.25, speed = 2000, width = 50, range = 1150,type = "line",col=true},
	[1] = { range = 5000 },
	[2] = { range = 1000 },
	[3] = { range = 1500 }
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 60 * GetCastLevel(myHero,0) - 50 + GetBonusDmg(myHero), 0) end, 
	[2] = function (unit) if not unit then return end return CalcDamage(myHero, unit, (10 * GetCastLevel(myHero,2) + 10 + (GetBonusDmg(myHero)+GetBaseDamage(myHero)) * .6) + ((self.eTrack[GetNetworkID(unit)] or 0)-1) * (({10,14,19,25,32})[GetCastLevel(myHero,2)] + (GetBaseDamage(myHero)+GetBaseDamage(myHero))*({0.2,0.225,0.25,0.275,0.3})[GetCastLevel(myHero,2)]), 0) end,
	}
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", false)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", false)
	
	BM:Menu("AE", "Auto E")
	BM.AE:Menu("MobOpt", "Mob Option")
	BM.AE.MobOpt:Boolean("UseB", "Use on Big Mobs", true)
	BM.AE.MobOpt:Boolean("UseE", "Use on Epic Mobs", true)
	BM.AE.MobOpt:Boolean("UseM", "Use on Minions", true)
	BM.AE.MobOpt:Boolean("UseMode", "Use only in Laneclear mode",false)
	BM.AE:Slider("xM", "Kill X Minions", 2, 1, 7, 1)	
	BM.AE:Boolean("UseC", "Use on Champs", true)
	BM.AE:Boolean("UseBD", "Use before death", true)
	BM.AE:Boolean("UseL", "Use if leaves range", false)
	BM.AE:Slider("OK", "Over kill", 10, 0, 50, 5)
	BM.AE:Slider("D", "Delay to use E", 10, 0, 50, 5)	
	
	BM:Menu("AR", "Auto R")
	BM.AR:Boolean("enable", "Enable Auto R")
	BM.AR:Slider("allyHP", "allyHP <= X", 5, 1, 100, 5)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	
	BM:Menu("WJ", "WallJump")
	BM.WJ:KeyBinding("J", "Wall Jump", string.byte("G"))
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	BM.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)

	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(unit, buff) self:UpdateBuff(unit, buff) end)
	Callback.Add("RemoveBuff", function(unit, buff) self:RemoveBuff(unit, buff) end)
	Callback.Add("ProcessSpellComplete", function(unit, spell) self:AAReset(unit, spell) end)

	for i = 0,0 do
		PredMenu(BM.p, i)	
	end
end

function Kalista:UpdateBuff(unit, buff) 
	if unit ~= myHero and buff.Name:lower() == "kalistaexpungemarker" and (unit.type==Obj_AI_Hero or unit.type==Obj_AI_Minion or unit.type==Obj_AI_Camp) then
		self.eTrack[GetNetworkID(unit)]=buff.Count 
	elseif buff.Name:lower() == "kalistacoopstrikeally" and GetTeam(unit) == MINION_ALLY then
		soul = unit
	end
end

function Kalista:RemoveBuff(unit, buff) 
	if unit ~= myHero and buff.Name:lower() == "kalistaexpungemarker" and (unit.type==Obj_AI_Hero or unit.type==Obj_AI_Minion or unit.type==Obj_AI_Camp) then
		self.eTrack[GetObjectName(unit)]=0 
	elseif buff.Name:lower() == "kalistacoopstrikeally" and GetTeam(unit) == MINION_ALLY then
		soul = nil
	end
end

function Kalista:Tick()
	for _,i in pairs(SLM) do
		if i.charName:lower():find("sru_dragon") then
			self.dragon = i.charName
		end
	end
	if not self.dragon then
		self.EpicJgl = {["SRU_Baron"]=true, ["TT_Spiderboss"]=true}
		self.BigJgl = {["SRU_Baron"]=true, ["SRU_Red"]=true, ["SRU_Blue"]=true, ["SRU_Krug"]=true, ["SRU_Murkwolf"]=true, ["SRU_Razorbeak"]=true, ["SRU_Gromp"]=true, ["Sru_Crab"]=true, ["TT_Spiderboss"]=true}
	else
		self.EpicJgl = {["SRU_Baron"]=true, [self.dragon]=true,["TT_Spiderboss"]=true}
		self.BigJgl = {["SRU_Baron"]=true, [self.dragon]=true, ["SRU_Red"]=true, ["SRU_Blue"]=true, ["SRU_Krug"]=true, ["SRU_Murkwolf"]=true, ["SRU_Razorbeak"]=true, ["SRU_Gromp"]=true, ["Sru_Crab"]=true, ["TT_Spiderboss"]=true}
	end
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	self:KS()
	self:AutoR()
	self:WallJump()
	
	if Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	else
		return
	end
end

function Kalista:AutoR()
	if soul and BM.AR.enable:Value() and GetPercentHP(soul) <= BM.AR.allyHP:Value() and EnemiesAround(GetOrigin(soul), 1000) >= 1 then
		CastSpell(3)
	end
end

function Kalista:AAReset(unit, spell)
	local ta = spell.target
	if unit == myHero and ta ~= nil and spell.name:lower():find("attack") and SReady[0] and ValidTarget(ta, Spell[0].range) then
		if ((Mode == "Combo" and BM.C.Q:Value()) or (Mode == "Harass" and BM.H.Q:Value()) and GetObjectType(ta) == Obj_AI_Hero) or (Mode == "LaneClear" and ((BM.JC.Q:Value() and (GetObjectType(ta)==Obj_AI_Camp or GetObjectType(ta)==Obj_AI_Minion)) or (BM.LC.Q:Value() and GetObjectType(ta)==Obj_AI_Minion))) then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
	end
end

function Kalista:JungleClear()

end

function Kalista:LaneClear()

end

function Kalista:KS()
	for _,target in pairs(GetEnemyHeroes()) do
		if SReady[0] and ValidTarget(target, Spell[0].range) and BM.KS.Q:Value() and GetADHP(target) < Dmg[0](target) then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		if SReady[2] and ValidTarget(target, 1000) and BM.AE.UseC:Value() and (GetADHP(target) + BM.AE.OK:Value()) < Dmg[2](target) and self.eTrack[GetNetworkID(target)] > 0 then
			DelayAction(function()
				CastSpell(2)
			end, BM.AE.D:Value()*.01)
		end
		if SReady[2] and ValidTarget(target, 1100) and BM.AE.UseL:Value() and self.eTrack[GetNetworkID(target)] then
			local Pred = GetPrediction(target,Spell[-1])
			if GetDistance(Pred.castPos,GetOrigin(myHero))>999 then
				CastSpell(2)
			end
		end
	end
	
	if not BM.AE.MobOpt.UseMode:Value() or Mode == "LaneClear" then
		for _,mob in pairs(SLM) do
			if GetTeam(mob) == MINION_JUNGLE then
				if SReady[2] and ValidTarget(mob, 750) and Dmg[2](mob) > GetCurrentHP(mob) then
					if BM.AE.MobOpt.UseE:Value() and self.EpicJgl[GetObjectName(mob)] then
						CastSpell(2)
					elseif BM.AE.MobOpt.UseB:Value() and self.BigJgl[GetObjectName(mob)] then
						CastSpell(2)
					end
				end
			end
		end
		
		self.km = 0
		for _,minion in pairs(SLM) do
			if GetTeam(minion) == MINION_ENEMY then
				if Dmg[2](minion) > GetCurrentHP(minion) and ValidTarget(minion, 1000) and BM.AE.MobOpt.UseM:Value() then
					self.km = self.km + 1
				end
			end
		end
		if self.km >= BM.AE.xM:Value() then
			CastSpell(2)
		end
	end
	if BM.AE.UseBD:Value() and GetPercentHP(myHero)<=2 and SReady[2] then
		CastSpell(2)
	end
end

function Kalista:WallJump()
	if SReady[0] and BM.WJ.J:Value() and GetDistance(GetMousePos(),GetOrigin(myHero))<1500 then
		local mou = GetMousePos()
		local wallEnd = nil
		local wallStart = nil
		if not MapPosition:inWall(mou) then
			--DrawLine(WorldToScreen(0, GetOrigin(myHero)).x, WorldToScreen(0, GetOrigin(myHero)).y, WorldToScreen(0, mou).x, WorldToScreen(0, mou).y, 3, GoS.White)
			local dV = Vector(GetOrigin(myHero))-Vector(mou)
			for i = 1, dV:len(), 5 do
				if MapPosition:inWall(mou+dV:normalized()*i) and not wallEnd then
					wallEnd = Vector(mou+dV:normalized()*i)
				elseif wallEnd and not MapPosition:inWall(Vector(mou+dV:normalized()*i)) then
					wallStart = Vector(mou+dV:normalized()*i)
					DrawCircle(wallStart,50,0,3,GoS.White)
					break
				end
			end
			if wallEnd and wallStart then
				local WS = WorldToScreen(0,wallStart)
				local WE = WorldToScreen(0,wallEnd)
				if Vector(wallEnd-wallStart):len() < 290 then
					DrawLine(WS.x,WS.y,WE.x,WE.y,3,GoS.Green)
					MoveToXYZ(wallStart)
				else
					DrawLine(WS.x,WS.y,WE.x,WE.y,3,GoS.Red)
					DrawCircle(wallEnd,50,0,3,GoS.White)
					DrawCircle(wallStart,50,0,3,GoS.White)
				end
				if GetDistance(GetOrigin(myHero),wallEnd) < 290 then
					CastSkillShot(0,wallEnd)
					DelayAction(function()
						MoveToXYZ(mou)
					end, .001)
				end
			end
		end
	end
end

--  _   _                     
-- | \ | | __ _ ___ _   _ ___ 
-- |  \| |/ _` / __| | | / __|
-- | |\  | (_| \__ \ |_| \__ \
-- |_| \_|\__,_|___/\__,_|___/
--                            


class 'Nasus'

function Nasus:__init()
	
	Dmg = {
		[0] = function (unit) return CalcDamage(myHero, unit, self.qDmg, 0) end,
		[2] = function (unit) return CalcDamage(myHero, unit, 0, 40 * GetCastLevel(myHero,2) + 15 + GetBonusAP(myHero) * .6) end,
		[3] = function (unit) return CalcDamage(myHero, unit, 0, math.min((.02 * GetCastLevel(myHero,3) + .01) * GetMaxHP(unit)),240) end,
	}


	Spell = {
		[0] = { delay = 0.3, range = 250},
		[1] = { delay = .2, range = 600 },
		[2] = { delay = .1, speed = math.huge, range = 650, radius = 395,type = "circular",col=false},
		[3] = { range = 200 }
	}
	
	BM:SubMenu("c", "Combo")
	BM.c:Boolean("Q", "Use Q", true)
	BM.c:Boolean("QP", "Use HP Pred for Q", true)
	BM.c:Slider("QDM", "Q DMG mod", 0, -10, 10, 1)
	BM.c:Boolean("W", "Use W", true)
	BM.c:Slider("WHP", "Use W at %HP", 20, 1, 100, 1)
	BM.c:Boolean("E", "Use E", true)
	BM.c:Boolean("R", "Use R", true)
	BM.c:Slider("RHP", "Use R at %HP", 20, 1, 100, 1)

	BM:SubMenu("f", "Farm")
	BM.f:DropDown("QM", "Auto Q in" ,1 , {"Always" , "Laneclear", "LastHit"})
	BM.f:Boolean("dQ", "Draw Q on creeps", true)
	
	BM:SubMenu("ks", "Killsteal")
	BM.ks:Boolean("KSQ","Killsteal with Q", true)
	BM.ks:Boolean("KSE","Killsteal with E", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:SubMenu("p","Prediction")


--Var
	self.qDmg = 0
	self.Stacks = GetBuffData(myHero, "NasusQStacks").Stacks
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)

	for i = 2,2 do
		PredMenu(BM.p, i)	
	end
end

-- Start
function Nasus:Tick()
	if myHero.dead then return end
	
	target = ts:GetTarget()
	GetReady()
	self.qDmg = self:getQdmg()
	self:KS()
	self:Farm()

    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
	--	self:LaneClear()
	--	self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Nasus:Draw()
	if myHero.dead or not BM.f.dQ:Value() then return end
	for _, creep in pairs(SLM) do
		--if Nasus:ValidCreep(creep,1000) then DrawText(math.floor(CalcDamage(myHero,creep,self.qDmg,0)),10,WorldToScreen(0,GetOrigin(creep)).x,WorldToScreen(0,GetOrigin(creep)).y,GoS.White) end
		if Nasus:ValidCreep(creep,1000) and GetCurrentHP(creep)<CalcDamage(myHero,creep,self.qDmg,0) then
			DrawCircle(GetOrigin(creep),50,0,3,GoS.Red)
		end
	end
end



function Nasus:Combo(unit)
	if BM.c.Q:Value() and SReady[0] and ValidTarget(unit, Spell[0].range) then
		CastSpell(0)
		AttackUnit(unit)
	end
	if SReady[1] and BM.c.W:Value() and ValidTarget(unit, Spell[1].range) and GetPercentHP(unit) < BM.c.WHP:Value() then
		CastTargetSpell(unit,1)
	end		
	if SReady[2] and BM.c.E:Value() and ValidTarget(unit, Spell[2].range) then
		CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
	end				
end

function Nasus:Farm()
	local mod = BM.f.QM:Value()
	if (SReady[0] or CanUseSpell(myHero,0) == 8) and ((mod == 2 and Mode == "LaneClear") or (mod == 3 and Mode == "LastHit") or (mod == 1 and Mode ~= "Combo")) then
		for _, creep in pairs(SLM) do
			if Nasus:ValidCreep(creep, Spell[0].range) and GetCurrentHP(creep)<self.qDmg*2 and ((GetHealthPrediction(creep, GetWindUp(myHero))<CalcDamage(myHero, creep, self.qDmg, 0) and BM.c.QP:Value()) or (GetCurrentHP(creep)<CalcDamage(myHero, creep, self.qDmg, 0) and not BM.c.QP:Value())) then
				CastSpell(0)
				AttackUnit(creep)
				break
			end
		end
	end
end

function Nasus:KS()
	if SReady[3] and BM.c.R:Value() and ValidTarget(unit, 1075) and GetPercentHP(myHero) < BM.c.RHP:Value() then
		CastSpell(3)
	end
	for i,unit in pairs(GetEnemyHeroes()) do
		if BM.ks.KSQ:Value() and Ready(0) and ValidTarget(unit, Spell[0].range) and GetCurrentHP(unit)+GetDmgShield(unit)+GetMagicShield(unit) < CalcDamage(myHero, unit, self.qDmg, 0) then
			CastSpell(0)
			AttackUnit(unit)
		end
		if BM.ks.KSE:Value() and Ready(_E) and ValidTarget(unit,Spell[2].range) and GetCurrentHP(unit)+GetDmgShield(unit)+GetMagicShield(unit) <  CalcDamage(myHero, unit, 0, 15+40*GetCastLevel(myHero,_E)+GetBonusAP(myHero)*6) then 
			CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
		end
	end
end

function Nasus:getQdmg()
	local base = 10 + 20*GetCastLevel(myHero,0) + GetBaseDamage(myHero) + GetBuffData(myHero, "NasusQStacks").Stacks + BM.c.QDM:Value()
	if 		(Ready(GetItemSlot(myHero,3078))) and GetItemSlot(myHero,3078)>0 then base = base + GetBaseDamage(myHero)*2 
	elseif 	(Ready(GetItemSlot(myHero,3057))) and GetItemSlot(myHero,3057)>0 then base = base + GetBaseDamage(myHero)
	elseif 	(Ready(GetItemSlot(myHero,3057))) and GetItemSlot(myHero,3025)>0 then base = base + GetBaseDamage(myHero)*1.25 
	end
	return base
end


function Nasus:ValidCreep(creep, range)
	if creep and not IsDead(creep) and GetTeam(creep) ~= MINION_ALLY and IsTargetable(creep) and GetDistance(GetOrigin(myHero), GetOrigin(creep)) < range then
		return true
	else 
		return false
	end
end



-- _  ___           _              _ 
--| |/ (_)_ __   __| |_ __ ___  __| |
--| ' /| | '_ \ / _` | '__/ _ \/ _` |
--| . \| | | | | (_| | | |  __/ (_| |
--|_|\_\_|_| |_|\__,_|_|  \___|\__,_|
--  

class "Kindred"

function Kindred:__init()
	Spell = {
	[0] = {range = 500, dash = 340, mana = 35},
	[1] = {range = 800, duration = 8, mana = 40},
	[2] = {range = 500, mana = 70, mana = 70},
	[3] = {range = 400, range2 = 500, mana = 100},
	}
	Dmg = 
	{
	[0] = function(Unit) return CalcDamage(myHero, Unit, 30+30*GetCastLevel(myHero, 0)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20) end,
	[1] = function(Unit) return CalcDamage(myHero, Unit, 20+5*GetCastLevel(myHero, 1)+0.40*(GetBaseDamage(myHero) + GetBonusDmg(myHero))+0.40*self:PassiveDmg(Unit)) end,
	[2] = function(Unit) 	if GetTeam(Unit) == MINION_JUNGLE then
					return CalcDamage(myHero, Unit, math.max(300,30+30*GetCastLevel(myHero, 2)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20+GetMaxHP(Unit)*0.05))
				else 
					return CalcDamage(myHero, Unit, 30+30*GetCastLevel(myHero, 2)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20+GetMaxHP(Unit)*0.05)
				end
		  end,
	}
	self.BaseAS = GetBaseAttackSpeed(myHero)
	self.AAPS = self.BaseAS*GetAttackSpeed(myHero)
	self.WolfAA = Spell[1].duration*self.AAPS
	basePos = Vector(0,0,0)
	if GetTeam(myHero) == 100 then
		basePos = Vector(415,182,415)
	else
		basePos = Vector(14302,172,14387.8)
	end
	self.Recalling = false
	self.Farsight = false
	self.Passive = 0
	OnTick(function(myHero) self:Tick() end)
	OnProcessSpellComplete(function(unit, spell) self:OnProcComplete(unit, spell) end)
	OnProcessSpell(function(unit, spell) self:OnProc(unit, spell) end)
	Flash = (GetCastName(myHero, SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(myHero, SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil)) -- Ty Platy

	BM:Menu("Combo", "Combo")
	BM.Combo:Boolean("Q", "Use Q", true)
	BM.Combo:Boolean("W", "Use W", true)
	BM.Combo:Boolean("E", "Use E", true)
	BM.Combo:Boolean("QE", "Gapcloser", true)

	BM:Menu("JunglerClear", "JunglerClear")
	BM.JunglerClear:Boolean("Q", "Use Q", true)
	BM.JunglerClear:Boolean("W", "Use W", true)
	BM.JunglerClear:Boolean("E", "Use E", true)
	BM.JunglerClear:Slider("MM", "Mana manager", 50, 1, 100)

	BM:Menu("LaneClear", "LaneClear")
	BM.LaneClear:Boolean("Q", "Use Q", true)
	BM.LaneClear:Boolean("W", "Use W", true)
	BM.LaneClear:Boolean("E", "Use E", true)
	BM.LaneClear:Slider("MM", "Mana manager", 50, 1, 100)

	BM:Menu("Misc", "Misc")
	BM.Misc:Boolean("B", "Buy Farsight", true)
	BM.Misc:KeyBinding("FQ", "Flash-Q", string.byte("T"))
	BM.Misc:Key("WP", "Jumps", string.byte("G"))

	BM:Menu("ROptions", "R Options")
	BM.ROptions:Boolean("R", "Use R?", true)
	BM.ROptions:Slider("EA", "Enemies around", 3, 1, 5)
	BM.ROptions:Boolean("RU", "Use R on urself", true)

	BM:Menu("QOptions", "Q Options")
	BM.QOptions:Boolean("QC", "AA reset Combo", true)
	BM.QOptions:Boolean("QL", "AA reset LaneClear", true)
	BM.QOptions:Boolean("QJ", "AA reset JunglerClear", true)
	BM.QOptions:Boolean("C", "Cancel animation?", false)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)

	DelayAction(function()
		for i, allies in pairs(GetAllyHeroes()) do
			BM.ROptions:Boolean("Pleb"..GetObjectName(allies), "Use R on "..GetObjectName(allies), true)
		end
	end, 0.001)
end

function Kindred:Tick()
	if not IsDead(myHero) then
	
		GetReady()
		target = ts:GetTarget()
		if Mode == "Combo" then
			self:Combo(target)
		elseif Mode == "LaneClear" then
			self:LaneClear()
		end

		self:AutoR()
		if BM.Misc.FQ:Value() then
			if SReady[0] and Ready(Flash) and BM.Combo.Q:Value() then  
				CastSkillShot(Flash, GetMousePos()) 
					DelayAction(function() CastSkillShot(0, GetMousePos()) end, 1)					  
			end
		end
		if BM.Misc.WP:Value() then
			if self:WallBetween(GetOrigin(myHero), GetMousePos(),  Spell[0].dash) and SReady[0] then
				CastSkillShot(0, GetMousePos())
			end
		end
		self.Passive = GetBuffData(myHero,"kindredmarkofthekindredstackcounter").Stacks
		if BM.Misc.B:Value() then
			if not self.Farsight and GetLevel(myHero) >= 9 and GetDistance(myHero,basePos) < 550 then
				BuyItem(3363)
				self.Farsight = true
			end
		end
	end
end

function Kindred:Combo(Unit)
local AfterQ = GetOrigin(myHero) +(Vector(GetMousePos()) - GetOrigin(myHero)):normalized()*Spell[0].dash

	if SReady[2] and SReady[0] and BM.Combo.QE:Value() and GetDistance(Unit) > Spell[0].range and GetDistance(AfterQ, Unit) <= 450 then
		CastSkillShot(0, GetMousePos())
			DelayAction(function() CastTargetSpell(Unit, 2) end, 1)
	end
	if SReady[0] and BM.Combo.Q:Value() and ValidTarget(Unit, Spell[0].range) and BM.QOptions.QC:Value() == false or (GetDistance(Unit) > Spell[0].range and GetDistance(AfterQ, Unit) <= 450)  then
    	CastSkillShot(0, GetMousePos()) 
	end
	if SReady[1] and BM.Combo.W:Value() and ValidTarget(Unit, Spell[1].range) then 
		CastSpell(1)
	end
	if SReady[2] and BM.Combo.E:Value() and ValidTarget(Unit, Spell[2].range) then 
		CastTargetSpell(Unit, 2)
	end
end

function Kindred:LaneClear()
	local QMana = (Spell[0].mana*100)/GetMaxMana(myHero)
	local WMana = (Spell[1].mana*100)/GetMaxMana(myHero)
	local EMana = (Spell[2].mana*100)/GetMaxMana(myHero)
	for _, mob in pairs(SLM) do	
		if GetTeam(mob) == MINION_JUNGLE then
			if BM.QOptions.QJ:Value() == false and SReady[0] and BM.JunglerClear.Q:Value() and ValidTarget(mob, Spell[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) --[[and (GetPercentMP(myHero)- QMana) >= BM.JunglerClear.MM:Value()]] then 
				CastSkillShot(0, GetMousePos())
			end
			if SReady[1] and ValidTarget(mob, Spell[1].range) and IsTargetable(mob) and BM.JunglerClear.W:Value() and (GetPercentMP(myHero)- WMana) >= BM.JunglerClear.MM:Value() and self:TotalHp(Spell[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then
   				CastSpell(1)
    		end
    		if SReady[2] and ValidTarget(mob, Spell[2].range) and BM.JunglerClear.E:Value() and (GetPercentMP(myHero)- EMana) >= BM.JunglerClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
   				CastTargetSpell(mob, 2)
   			end
  	 	end
		if GetTeam(mob) == MINION_ENEMY then
			if BM.QOptions.QL:Value() == false and SReady[0] and BM.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= BM.LaneClear.MM:Value() and ValidTarget(mob, Spell[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) then 
				CastSkillShot(0, GetMousePos())
			end
			if SReady[1] and ValidTarget(mob, Spell[1].range) and BM.LaneClear.W:Value() and (GetPercentMP(myHero)- WMana) >= BM.LaneClear.MM:Value() and self:TotalHp(Spell[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then 
				CastSpell(1)
			end
			if SReady[2] and ValidTarget(mob, Spell[2].range) and BM.LaneClear.E:Value() and (GetPercentMP(myHero)- EMana) >= BM.LaneClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
				CastTargetSpell(mob, 2)
			end
		end
	end
end

function Kindred:AutoR()
	if BM.ROptions.R:Value() and not self.Recalling and not IsDead(myHero) and SReady[3] then
		for i, allies in pairs(GetAllyHeroes()) do
			if GetPercentHP(allies) <= 20 and BM.ROptions["Pleb"..GetObjectName(allies)] and not IsDead(allies) and GetDistance(allies) <= Spell[3].range2 and EnemiesAround(allies, 1500) >= BM.ROptions.EA:Value() then
				CastTargetSpell(myHero, 3)
			end
		end
		if GetPercentHP(myHero) <= 20 and BM.ROptions.RU:Value() and EnemiesAround(myHero, 1500) >= BM.ROptions.EA:Value() then
			CastTargetSpell(myHero, 3)
		end
	end
end

function Kindred:OnProcComplete(unit, spell)
	local QMana = (Spell[0].mana*100)/GetMaxMana(myHero)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			if Mode == "LaneClear" then 
				for _, mob in pairs(SLM) do	
					if BM.QOptions.QL:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_ENEMY and BM.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= BM.LaneClear.MM:Value() and SReady[0] then
						CastSkillShot(0, GetMousePos())
					end
					if BM.QOptions.QJ:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_JUNGLE and BM.JunglerClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= BM.JunglerClear.MM:Value() and SReady[0] then
						CastSkillShot(0, GetMousePos()) 
					end
				end
			elseif Mode == "Combo" then
				if BM.QOptions.QC:Value() and SReady[0] and BM.Combo.Q:Value() and ValidTarget(target, 500) then
    				CastSkillShot(0, GetMousePos()) 
				end
			end
		end
	end
end

function Kindred:OnProc(unit, spell)
	if unit == myHero and spell.name == "KindredQ" and BM.QOptions.C:Value() then
		DelayAction(function() CastEmote(EMOTE_DANCE) end, .001)
	end
end

function Kindred:OnUpdate(unit, buff)
	if unit == myHero then
		if buff.Name == "recall" or buff.Name == "OdinRecall" then
			self.Recalling = true
		end
		--[[if buff.Name == "kindredmarkofthekindredstackcounter" then
			self.Passive = self.Passive + buff.Stacks
		end]]
	end
end

function Kindred:OnRemove(unit, buff)
	if unit == myHero and buff.Name == "recall" or buff.Name == "OdinRecall" then
		self.Recalling = false
	end
end

function Kindred:PassiveDmg(unit)
	if self.Passive ~= 0 then
		local PassiveDmg = self.Passive * 1.25
		if GetTeam(unit) == MINION_JUNGLE then
			return CalcDamage(myHero, unit, math.max(75+10*self.Passive, GetCurrentHP(unit)*(PassiveDmg/100)))
		else
			return CalcDamage(myHero, unit, GetCurrentHP(unit)*(PassiveDmg/100))
		end
	else return 0
	end
end

function Kindred:TotalHp(range, pos)
	local hp = 0
	for _, mob in pairs(SLM) do
		if not IsDead(mob) and IsTargetable(mob) and (GetTeam(mob) == MINION_JUNGLE or GetTeam(mob) == MINION_ENEMY) and GetDistance(mob, pos) <= range then
			hp = hp + GetCurrentHP(mob)
		end
	end
	return hp
end

function Kindred:WallBetween(p1, p2, distance) --p1 and p2 are Vectors3d

	local Check = p1 + (Vector(p2) - p1):normalized()*distance/2
	local Checkdistance = p1 +(Vector(p2) - p1):normalized()*distance
	
	if MapPosition:inWall(Check) and not MapPosition:inWall(Checkdistance) then
		return true
	end
end

class "Khazix"

function Khazix:__init()

	Spell = {
	[0] = { range = 325, evolved = false},
	[1] = { delay = 0.25, speed = 1700, width = 70, range = 1025,type = "line",col=true},
	[2] = { delay = 0.25, speed = 1500, width = 0, range = 750,type="circular",col=true},
	}
	
	Dmg = {
	[-1] = function (unit) return CalcDamage(myHero, unit, 0, ({15,20,25,35,45,55,65,75,85,95,110,125,140,150,160,170,180,190})[myHero.level] + myHero.ap *.5) end,
	[0] =  function (unit) return CalcDamage(myHero, unit, (55 + 15 * GetCastLevel(myHero,0) + GetBonusDmg(myHero) * 1.2)*(self.Isolated[unit.networkID] and 1.3 or 1) + (Spell[0].evolved and 10 * myHero.level + GetBonusDmg(myHero)*1.04 or 0),0) end,
	[1] =  function (unit) return CalcDamage(myHero, unit,  50 + 30 * GetCastLevel(myHero,1) + GetBonusDmg(myHero), 0) end,
	[2] =  function (unit) return CalcDamage(myHero, unit,  30 + 35 * GetCastLevel(myHero,2) + GetBonusDmg(myHero) * .2 ,0) end, 
	}

	self.Dashes = 
	{
		["Vayne"]	 	 = {Spellslot = 0, Range = 300, Name = "Q"},
		["Riven"]	 	 = {Spellslot = 2, Range = 325, Name = "E"},
		["Ezreal"]		 = {Spellslot = 2, Range = 450, Name = "E"},
		["Caitlyn"]		 = {Spellslot = 2, Range = 400, Name = "E"},
		["Kassadin"] 	 = {Spellslot = 3, Range = 700, Name = "R"},
		["Graves"]		 = {Spellslot = 2, Range = 425, Name = "E"},
		["Renekton"]  	 = {Spellslot = 2, Range = 450, Name = "E"},
		["Aatrox"]		 = {Spellslot = 0, Range = 650, Name = "Q"},
		["Gragas"]		 = {Spellslot = 2, Range = 600, Name = "E"},
		["Khazix"]		 = {Spellslot = 2, Range = 600, Name = "E"},
		["Lucian"]		 = {Spellslot = 2, Range = 425, Name = "E"},
		["Sejuani"]		 = {Spellslot = 0, Range = 650, Name = "Q"},
		["Shen"]		 = {Spellslot = 2, Range = 575, Name = "E"},
		["Tryndamere"] 	 = {Spellslot = 2, Range = 660, Name = "E"},
		["Tristana"]  	 = {Spellslot = 1, Range = 900, Name = "W"},
		["Corki"]	 	 = {Spellslot = 1, Range = 800, Name = "W"},
	}

	BM:Menu("C", "Combo")
		BM.C:Boolean("Q", "Use Q", true)
		BM.C:Boolean("W", "Use W", true)
		BM.C:Boolean("E", "Use E", true)
		BM.C:SubMenu("R", "R Options")
		BM.C.R:Boolean("R", "Use R", true)

	BM:Menu("H", "Harass")
		BM.H:Boolean("Q", "Use Q", true)
		BM.H:Boolean("W", "Use W", true)
		
	BM:Menu("L", "LaneClear")
		BM.L:Boolean("Q", "Use Q", true)
		BM.L:Boolean("W", "Use W", true)
		BM.L:Boolean("E", "Use E", false)
	
	BM:Menu("H", "LastHit")
		BM.H:Boolean("Q", "Use Q", true)
		
	BM:Menu("KS", "KillSteal")
		BM.KS:Boolean("Q", "Use Q", true)
		BM.KS:Boolean("W", "Use W", true)
	
	BM:Menu("J", "Jump Settings")	
		BM.J:Boolean("S","Save Jump", true)

	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
		
	BM:Menu("p", "HitChance")

	for i, k in pairs(GetEnemyHeroes()) do
		if self.Dashes[k.charName] then
			BM.J:Boolean(k.networkID, "Follow "..k.charName.." "..self.Dashes[k.charName].Name, true)
		end
	end

	self.Passive = GotBuff(myHero,"KhazixPDamage") ~= 0
	self.IsStealth = GotBuff(myHero,"KhazixR") ~= 0
	self.Isolated = {}
	self.Point = nil

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(unit, buff) self:OnUpdate(unit, buff) end)
	Callback.Add("RemoveBuff", function(unit, buff) self:OnRemove(unit, buff) end)
	Callback.Add("CreateObj", function(o) self:CreateObj(o) end)
	Callback.Add("DeleteObj", function(o) self:DeleteObj(o) end)
	
	for i = 1,2 do
		PredMenu(BM.p, i)	
	end
	
end

function Khazix:Tick()
	target = ts:GetTarget()
	GetReady()
	if GetCastName(myHero, 0) == "KhazixQLong" then
		Spell[0].range = 375
		Spell[0].evolved = true
	end
	if GetCastName(myHero, 2) == "KhazixELong" then
		Spell[2].range = 950
		Spell[2].evolved = true
	end
	
	self:KS()
	if Mode == "Combo" and target and target.valid then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
	elseif Mode == "LastHit" then
		self:LastHit()
	elseif Mode == "Harass" and target and target.valid then
		self:Harass(target)
	else
		return
	end
end

function Khazix:KS()
	for _,unit in pairs(GetEnemyHeroes()) do
		if BM.KS.Q:Value() and ValidTarget(unit, Spell[0].range) and SReady[0] and Dmg[0](unit) > GetADHP(unit) then
			CastTargetSpell(unit,0)
		elseif BM.KS.W:Value() and ValidTarget(unit, Spell[1].range) and SReady[1] and Dmg[1](unit) > GetADHP(unit) then
			self:UseW(unit)
		end
	end
end

function Khazix:Combo(unit)
	self:UseQ(unit)
	if BM.C.W:Value() and GetDistance(unit) > GetHitBox(myHero) + Spell[0].range + GetHitBox(unit) and (not (self.Dashes[unit.charName] and CanUseSpell(unit, self.Dashes[unit.charName].Spellslot) == READY) or unit.distance > Spell.E.range*.75 or unit.health < Dmg[0](unit)*2 or not BM.J.S:Value()) then
		self:UseE(unit)
	end
	if not SReady[2] or GetDistance(unit) < GetHitBox(myHero)+ Spell[0].range + GetHitBox(unit) then
		self:UseW(unit)
	end
	self:UseR(unit)
end

function Khazix:Harass(unit)
	if ValidTarget(unit, myHero.boundingRadius + Spell[0].range + unit.boundingRadius) and SReady[0] and BM.H.Q:Value() then
		CastTargetSpell(unit,0)
	elseif SReady[1] and ValidTarget(creep,Spell[1].range) and BM.H.W:Value() then
		self:UseW(unit)
	end
end

function Khazix:LastHit()
	for _,creep in pairs(SLM) do
		if SReady[0] and ValidTarget(creep,Spell[0].range) and BM.H.Q:Value() and Dmg[0](creep) > creep.health then
			CastTargetSpell(creep,0)
		end
	end
end

function Khazix:LaneClear()
	for _,creep in pairs(SLM) do
		if SReady[0] and ValidTarget(creep,Spell[0].range) and BM.L.Q:Value() then
			CastTargetSpell(creep,0)
		elseif SReady[1] and ValidTarget(creep,Spell[1].range) and BM.L.W:Value() then
			CastGenericSkillShot(myHero,creep,Spell[1],1,BM.p)
		elseif SReady[2] and ValidTarget(creep,Spell[2].range) and BM.L.E:Value() then
			CastGenericSkillShot(myHero,creep,Spell[2],2,BM.p)
		end
	end
end

function Khazix:UseQ(Unit)
	if ValidTarget(Unit, myHero.boundingRadius + Spell[0].range + Unit.boundingRadius) and SReady[0] and BM.C.Q:Value() then
		CastTargetSpell(Unit, 0)
	end
end

function Khazix:UseW(Unit)
	if ValidTarget(Unit, Spell[1].range) and SReady[1] then
		CastGenericSkillShot(myHero,Unit,Spell[1],1,BM.p)
	end
end

function Khazix:UseE(Unit)
	if ValidTarget(Unit, Spell[2].range) and SReady[2] and BM.C.E:Value() then
		CastSkillShot(2, GetOrigin(Unit))
	end
end

function Khazix:UseR(Unit)
	if BM.C.R.R:Value() and ValidTarget(Unit, Spell[2].range) and SReady[3] and not self.Passive and not SReady[2] or self.IsStealth then
		CastSpell(3)
	end
end

function Khazix:Proc(unit, spellProc)
	if self.Dashes[unit.charName] and Mode == "Combo" and SReady[2] and spellProc.name == GetCastName(unit, self.Dashes[unit.charName].Spellslot) and unit == target and GetDistance(spellProc.endPos) > myHero.boundingRadius +Spell[0].range + unit.boundingRadius and GetDistance(spellProc.endPos) < Spell[2].range and BM.J[unit.networkID]:Value() and GetDistance(spellProc.startPos) < GetDistance(spellProc.endPos) then
		CastSkillShot(2, spellProc.endPos)
	end
end

function Khazix:OnUpdate(unit, buffproc)
	if unit.isMe and buffproc then
		if buffproc.Name == "KhazixPDamage" then
			self.Passive = true
		elseif buffproc.Name == "KhazixR" then
			self.IsStealth = true
		end
	end
end

function Khazix:OnRemove(unit, buffproc)
	if unit.isMe and buffproc then
		if buffproc.Name == "KhazixPDamage" then
			self.Passive = false
		elseif buffproc.Name == "KhazixR" then
			self.IsStealth = false
		end
	end
end

function Khazix:CreateObj(o)
	if o.name:lower():find("indicator") and o.name:lower():find("singleenemy") then
		for _,i in pairs(GetEnemyHeroes()) do
			if GetDistance(i,o) < 20 then
				self.Isolated[i.networkID] = true
			end
		end
	end
end

function Khazix:DeleteObj(o)
	if o.name:lower():find("indicator") and o.name:lower():find("singleenemy") then
		for _,i in pairs(GetEnemyHeroes()) do
			if GetDistance(i,o) < 20 then
				self.Isolated[i.networkID] = false
			end
		end
	end
end

class 'Vladimir'

function Vladimir:__init()
	
	Spell = {
	[0] = { range = 600 },
	[1] = { range = 150 },
	[2] = { range = 600 },
	[3] = { delay = 0.25, speed = math.huge, range = 700, radius = 175,type = "circular",col=false},
	}
	
	Dmg = {
	[0] = function(unit) return CalcDamage(myHero, unit, 0, 15 * GetCastLevel(myHero,0) + 60 + GetBonusAP(myHero) * .55)*(GetCurrentMana(myHero)<2 and 1 or 2) end,
	[2] = function(unit) return CalcDamage(myHero, unit, 0, 15 * GetCastLevel(myHero,2) + 15 + GetBonusAP(myHero) * 0.35 + GetMaxHP(myHero)*.025) end,
	[3] = function(unit) return CalcDamage(myHero, unit, 0, 100 * GetCastLevel(myHero,3) + 50 + GetBonusAP(myHero) * .7) end,
	}
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Boolean("REA", "Use if R will hit > x enemies", 2, 1, 5, 1)
	BM.C:Boolean("DP", "Draw exact Passive", true)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("E", "Use E", true)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("E", "Use E", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Boolean("R", "Use R", false)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("UpdateBuff", function(unit,buff) self:UpdateBuff(unit,buff) end)
	Callback.Add("RemoveBuff", function(unit,buff) self:RemoveBuff(unit,buff) end)
	HitMe()
	
	self.ECharge = nil
	self.AA = AttackUnit

	for i = 3,3 do
		PredMenu(BM.p, i)	
	end
end

function Vladimir:HitMe(k,pos,dt,ty)
 DelayAction( function() 
  CastSpell(1)
 end,dt)
end

function Vladimir:Draw()
	if not myHero.dead and BM.C.DP:Value() then 
		DrawText(math.round(GetCurrentMana(myHero),2),20,myHero.pos2D.x,myHero.pos2D.y,GoS.White)
	end
end

function Vladimir:Tick()
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	
	self:KS()

	if self.ECharge and GetGameTimer() - self.ECharge > 1 then
		CastSkillShot2(2,myHero.pos)
	end

    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Vladimir:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.C.Q:Value() then
		CastTargetSpell(target,0)
	end
	if SReady[2] or self.ECharge and ValidTarget(target, Spell[2].range) and BM.C.E:Value() then
		CastSkillShot(2,myHero.pos)
	end
	if SReady[3] and ValidTarget(target, Spell[3].range) and BM.C.R:Value() and EnemiesAround(GetOrigin(target), Spell[3].radius) >= BM.C.REA:Value() then
		CastGenericSkillShot(myHero,unit,Spell[3],3,BM.p)
	end
end

function Vladimir:Harass(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.H.Q:Value() then
		CastTargetSpell(target,0)
	end
	if (SReady[2] or (self.ECharge and GetGameTimer() - self.ECharge < 1)) and ValidTarget(target, Spell[2].range) and BM.H.E:Value() then
		CastSkillShot(2,myHero.pos)
	end
end

function Vladimir:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range) and BM.LC.Q:Value() then
				CastTargetSpell(minion,0)
			end
			if (SReady[2] or (self.ECharge and GetGameTimer() - self.ECharge < 1)) and ValidTarget(minion, Spell[2].range) and BM.LC.E:Value() then
				CastSkillShot(2,myHero.pos)
			end
		end
	end
end

function Vladimir:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_JUNGLE then
			if SReady[0] and ValidTarget(mob, Spell[0].range) and BM.JC.Q:Value() then
				CastTargetSpell(mob,0)
			end
			if (SReady[2] or (self.ECharge and GetGameTimer() - self.ECharge < 1)) and ValidTarget(mob, Spell[2].range) and BM.JC.E:Value() then
				CastSkillShot(2,myHero.pos)
			end
		end
	end
end

function Vladimir:KS()
	for _,target in pairs(GetEnemyHeroes()) do
		if SReady[0] and ValidTarget(target, Spell[0].range) and BM.KS.Q:Value() and GetAPHP(target) < Dmg[0](target) then
			CastTargetSpell(target,0)
		end
		if (SReady[2] or (self.ECharge and GetGameTimer() - self.ECharge < 1)) and ValidTarget(target, Spell[2].range) and BM.KS.E:Value() and GetAPHP(target) < Dmg[2](target) then
			CastSkillShot(2,myHero.pos)
		end
		if SReady[3] and ValidTarget(target, Spell[3].range) and BM.KS.R:Value() and GetAPHP(target) < Dmg[3](target) then
			local Pred = GetCircularAOEPrediction(target, Spell[3])
			if Pred.hitChance >= BM.p.hR:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < Spell[3].range then
				CastSkillShot(3,Pred.castPos)
			end
		end
	end
end

function Vladimir:UpdateBuff(unit,buff)
	if unit.isMe and buff.Name == "VladimirE" then 
		self.ECharge = GetGameTimer()
		AttackUnit = function () end
	elseif unit.isMe and buff.Name == "VladimirSanguinePool" then
		AttackUnit = function () end
	end
end

function Vladimir:RemoveBuff(unit,buff)
	if unit.isMe and buff.Name == "VladimirE" then 
		self.ECharge = nil
		AttackUnit = self.AA
	elseif unit.isMe and buff.Name == "VladimirSanguinePool" then
		AttackUnit = self.AA
	end
end

class 'Orianna'

function Orianna:__init()

	Spell = {
	[0] = { range = 815, delay = 0, radius = 80, speed = 1200,type = "line",col=false },
	[1] = { radius = 255, range = 815 },
	[2] = { range = 1095, radius = 80 },
	[3] = { radius = 410, range = 815 },
	}
	
	Dmg = {
	[0] = function(unit) return CalcDamage(myHero, unit, 0, 30+30*GetCastLevel(myHero,0) + 0.5 * myHero.ap) end,
	[1] = function(unit) return CalcDamage(myHero, unit, 0, 25+45*GetCastLevel(myHero,1) + 0.7 * myHero.ap) end,
	[2] = function(unit) return CalcDamage(myHero, unit, 0, 30+30*GetCastLevel(myHero,2) + 0.3 * myHero.ap) end,
	[3] = function(unit) return CalcDamage(myHero, unit, 0, 75+75*GetCastLevel(myHero,3) + 0.7 * myHero.ap) end,
	}
	
	self.o = {}
	self.Ball = myHero
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Slider("Wm", "Use W if hit x unit(s)", 2, 1, 5, 1)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Slider("Rm", "Use R if hit x unit(s)", 2, 1, 5, 1)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Slider("Wm", "Use W if hit x unit(s)", 1, 1, 5, 1)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("W", "Use W", true)
	BM.LC:Slider("Wm", "Use W if hit x unit(s)", 3, 1, 15, 1)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("W", "Use W", true)
	BM.JC:Slider("Wm", "Use W if hit x unit(s)", 1, 1, 4, 1)
	BM.JC:Boolean("E", "Use E", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("W", "Use W", true)
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Boolean("R", "Use R", false)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	BM:Menu("Dr", "Drawings")
	BM.Dr:Boolean("UD", "Use Drawings", false)
	BM.Dr:ColorPick("Cc", "Circle color", {255,102,102,102})
	BM.Dr:DropDown("DQ", "Draw Quality", 3, {"High", "Medium", "Low"})
	BM.Dr:Slider("CW", "Circle width", 1, 1, 5, 1)
	BM.Dr:Boolean("B", "Draw Ball", true)
	BM.Dr:Boolean("Q", "Draw Q", true)
	BM.Dr:Boolean("W", "Draw W", true)
	BM.Dr:Boolean("E", "Draw E", true)
	BM.Dr:Boolean("R", "Draw R", true)
	
	
	Callback.Add("CreateObj", function(obj) self:CO(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DO(obj) end)
	Callback.Add("Draw", function() self:D() end)
	Callback.Add("Tick", function() self:T() end)
	Callback.Add("UpdateBuff", function(unit,buffProc) self:UB(unit,buffProc) end)
	
	for i = 0,0 do
		PredMenu(BM.p, i)	
	end
end

function Orianna:CO(obj)
	if obj.name == "missile" then
		if not self.o[obj.networkID] then self.o[obj.networkID] = {} end
		self.o[obj.networkID].o = obj
	end
	if obj.name == "Orianna_Base_Q_yomu_ring_green.troy" then
		self.Ball = obj
	end
end

function Orianna:DO(obj)
	if obj.name == "missile" then
		self.o[obj.networkID] = nil
	end
end

function Orianna:UB(unit,buffProc)
	if unit.isMe and buffProc.Name == "orianaghostself" then
		self.Ball = myHero
	end
end 

function Orianna:T()
	if myHero.dead then return end
	
	for _,i in pairs(self.o) do
		if i.o.spellOwner.isMe and i.o.spellName == "OrianaIzuna" then
			self.Ball = i.o
		end
	end
	target = ts:GetTarget()
	GetReady()
	
    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
	
end

function Orianna:D()
	if BM.Dr.UD:Value() then
		if BM.Dr.B:Value() then
			for _,i in pairs(self.o) do
				DrawCircle(self.Ball.pos,100,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
			end
		end
		if BM.Dr.Q:Value() and SReady[0] then
			DrawCircle(myHero.pos,Spell[0].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.W:Value() and SReady[1] then
			DrawCircle(self.Ball.pos,Spell[1].radius,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.E:Value() and SReady[2] then
			DrawCircle(myHero.pos,Spell[2].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.R:Value() and SReady[3] then
			DrawCircle(self.Ball.pos,Spell[3].radius,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
	end
end

function Orianna:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[1] and BM.C.W:Value() and EnemiesAround(self.Ball.pos, Spell[1].radius) >= BM.C.Wm:Value() then
		CastSpell(1)
	end
	if SReady[2] and ValidTarget(target, Spell[2].range) and BM.C.E:Value() then
		local VP = VectorPointProjectionOnLineSegment(Vector(myHero), Vector(self.Ball), Vector(target))
		if GetDistance(VP, target) < Spell[2].radius then
			CastSpell(2)
		end
	end
	if SReady[3] and BM.C.R:Value() and EnemiesAround(self.Ball.pos, Spell[3].radius) >= BM.C.Rm:Value() then
		CastSpell(3)
	end
end

function Orianna:Harass(target)
	if SReady[0] and ValidTarget(target, Spell[0].range) and BM.H.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[1] and BM.H.W:Value() and EnemiesAround(self.Ball.pos, Spell[1].radius) >= BM.H.Wm:Value() then
		CastSpell(1)
	end
end

function Orianna:LaneClear()
	for _,minion in pairs(SLM) do
		if minion.team == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range) and BM.LC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[1] and BM.LC.W:Value() and EnemyMinionsAround(self.Ball.pos, Spell[1].radius) >= BM.LC.Wm:Value() then
				CastSpell(1)
			end		
		end
	end
end

function Orianna:JungleClear()
	for _,minion in pairs(SLM) do
		if minion.team == MINION_JUNGLE then
			if SReady[0] and ValidTarget(minion, Spell[0].range) and BM.JC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[1] and BM.JC.W:Value() and JungleMinionsAround(self.Ball.pos, Spell[1].radius) >= BM.JC.Wm:Value() then
				CastSpell(1)
			end	
			if SReady[2] and ValidTarget(minion, Spell[2].range) and BM.JC.E:Value() then
				local VP = VectorPointProjectionOnLineSegment(Vector(myHero), Vector(self.Ball), Vector(minion))
				if GetDistance(VP, minion) < Spell[2].radius then
					CastSpell(2)
				end
			end			
		end
	end
end

function Orianna:KS()
	for _,target in pairs(GetEnemyHeroes()) do
		if SReady[0] and ValidTarget(target, Spell[0].range) and BM.C.Q:Value() and GetAPHP(target) < Dmg[0](target) then
			CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
		end
		if SReady[1] and BM.C.W:Value() and EnemiesAround(self.Ball.pos, Spell[1].radius) >= BM.C.Wm:Value() and GetAPHP(target) < Dmg[1](target) then
			CastSpell(1)
		end
		if SReady[2] and ValidTarget(target, Spell[2].range) and BM.C.E:Value() and GetAPHP(target) < Dmg[2](target) then
			local VP = VectorPointProjectionOnLineSegment(Vector(myHero), Vector(self.Ball), Vector(target))
			if GetDistance(VP, target) < Spell[2].radius then
				CastSpell(2)
			end
		end
		if SReady[3] and BM.C.R:Value() and EnemiesAround(self.Ball.pos, Spell[3].radius) >= BM.C.Rm:Value() and GetAPHP(target) < Dmg[3](target) then
			CastSpell(3)
		end
	end
end


class 'Veigar'

function Veigar:__init()

	self.CCType = { 
	[5] = "Stun", 
	[8] = "Taunt", 
	[11] = "Snare", 
	[21] = "Fear", 
	[22] = "Charm", 
	[24] = "Suppression",
	}
	
	Spell = {
	[-1] = { delay = 0.1, speed = math.huge, width = 50, range = math.huge},
	[0] = { delay = 0.1, speed = 2000, width = 100, range = 950},
	[1] = { delay = 0.1, speed = math.huge, range = 900 , radius = 225},
	[2] = { delay = 0.6, speed = math.huge, range = 725 , radius = 400},
	[3] = { range = 650 },
	}

	Dmg = {
	[0] = function(u) return CalcDamage(myHero, u, 0, 30+40*GetCastLevel(myHero,0) + 0.6 * myHero.ap) end,
	[1] = function(u) return CalcDamage(myHero, u, 0, 50+50*GetCastLevel(myHero,1) + myHero.ap) end,
	[3] = function(u) return CalcDamage(myHero, u, 0, (75*GetCastLevel(myHero,3) + 100)*math.max((100-GetPercentHP(u))*1.5,200)*.01) end,
	}
	
	BM:SubMenu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	
	BM:SubMenu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", true)	

	BM:SubMenu("LC", "LaneClear")
	BM.LC:Boolean("W", "Use W", true)
	
	BM:SubMenu("JC", "JungleClear")
	BM.JC:Boolean("W", "Use W", true)

	BM:SubMenu("p", "Prediction")
	BM.p:Slider("hQ", "HitChance Q", 20, 0, 100, 1)
	BM.p:Slider("hW", "Hitchance W", 20, 0, 100, 1)
	BM.p:Slider("hE", "HitChance E", 20, 0, 100, 1)

	BM:SubMenu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("W", "Use W", true)
	BM.KS:Boolean("R", "Use R", true)
	
	BM:SubMenu("f", "Farm")
	BM.f:Boolean("AQ", "Auto Q farm", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:Boolean("AW", "Auto W on immobile", true)
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveBuff(u,b) end)
	
	self.CC = false
	
end

function Veigar:UpdateBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = true
		end
	end
end

function Veigar:RemoveBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = false
		end
	end
end

function Veigar:Tick()
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	
	self:KS()

	self:FarmQ()
	
	self:AutoW(target)

    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Veigar:Combo(u)	
	if u then
		if BM.C.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range+10) then
			local QPred = GetPrediction(u,Spell[0])
			if QPred.hitChance >= (BM.p.hQ:Value()/100) then				
				CastSkillShot(0,QPred.castPos)
			end
		end		
		if BM.C.W:Value() and SReady[1] and ValidTarget(u, Spell[1].range) then
			local WPred = GetCircularAOEPrediction(u, Spell[1])
			if WPred.hitChance >= (BM.p.hW:Value()/100) then				
				CastSkillShot(1,WPred.castPos)
			end
		end	
		if BM.C.E:Value() then
			self:castE(u)
		end
	end
end

function Veigar:Harass(u)	
	if u then
		if BM.H.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range+10) then
			local QPred = GetPrediction(u,Spell[0])
			if QPred.hitChance >= (BM.p.hQ:Value()/100) and (not QPred:mCollision() or #QPred:mCollision() < 2) then				
				CastSkillShot(0,QPred.castPos)
			end
		end		
		if BM.H.W:Value() and SReady[1] and ValidTarget(u, Spell[1].range) then
			local WPred = GetCircularAOEPrediction(u, Spell[1])
			if WPred.hitChance >= (BM.p.hW:Value()/100) then				
				CastSkillShot(1,WPred.castPos)
			end
		end	
		if BM.H.E:Value() then
			self:castE(u)
		end
	end
end

function Veigar:LaneClear()	
	for _,i in pairs(SLM) do
		if i.team == MINION_ENEMY and BM.LC.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) then
			local WPred = GetCircularAOEPrediction(i, Spell[1])
			if WPred.hitChance >= (BM.p.hW:Value()/100) then				
				CastSkillShot(1,WPred.castPos)
			end
		end	
	end
end

function Veigar:JungleClear()
	for _,i in pairs(SLM) do
		if i.team == MINION_JUNGLE and BM.JC.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) then
			local WPred = GetCircularAOEPrediction(i, Spell[1])
			if WPred.hitChance >= (BM.p.hW:Value()/100) then				
				CastSkillShot(1,WPred.castPos)
			end
		end	
	end
end

function Veigar:KS()
	for _,i in pairs(GetEnemyHeroes()) do
		if BM.KS.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) and GetAPHP(i) < Dmg[0](i) then
			local QPred = GetPrediction(i,Spell[0])
			if QPred.hitChance >= (BM.p.hQ:Value()/100) and (not QPred:mCollision() or #QPred:mCollision() < 2) then				
				CastSkillShot(0,QPred.castPos)
			end
		end
		if BM.KS.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) and GetAPHP(i) < Dmg[1](i) then
			local WPred = GetCircularAOEPrediction(i, Spell[1])
			if WPred.hitChance >= (BM.p.hW:Value()/100) then				
				CastSkillShot(1,WPred.castPos)
			end
		end	
		if BM.KS.R:Value() and SReady[3] and ValidTarget(i, Spell[3].range) and GetAPHP(i) < Dmg[3](i) then 
			CastTargetSpell(i,3)
		end	
	end
end

function Veigar:AutoW(u)
	if u and BM.AW:Value() and SReady[1] and ValidTarget(u,Spell[1].range) and self.CC then
	local WPred = GetCircularAOEPrediction(u, Spell[1])
		if WPred.hitChance >= (BM.p.hW:Value()/100) then			
			CastSkillShot(1,WPred.castPos)
		end
	end
end

function Veigar:castE(u)
	if u and SReady[2] and ValidTarget(u, 725) then
		local EPred = GetCircularAOEPrediction(u, Spell[2])
		local EMove = GetPrediction(u, Spell[-1])
		if GetDistance(EMove.castPos , myHero.pos) < GetDistance(u.pos,myHero.pos) then
			EPred.castPos = Vector(EPred.castPos)+((Vector(EPred.castPos)-myHero.pos):normalized()*325)
		else
			EPred.castPos = Vector(EPred.castPos)+((myHero.pos-Vector(EPred.castPos)):normalized()*325)
		end
		CastSkillShot(2,EPred.castPos)
	end
end

function Veigar:FarmQ()
	if BM.f.AQ:Value() and SReady[0] and Mode ~= "Combo" then
		for _,i in pairs(SLM) do
			if i.team ~= MINION_ALLY and ValidTarget(i,Spell[0].range) and GetAPHP(i) < Dmg[0](i) then
				local QPred = GetPrediction(i,Spell[0])			
				if not QPred:mCollision() or #QPred:mCollision() < 2 then
					CastSkillShot(0,QPred.castPos)
				end
			end
		end
	end
end


class 'Ahri'

function Ahri:__init()

	self.CCType = { 
	[5] = "Stun", 
	[8] = "Taunt", 
	[11] = "Snare", 
	[21] = "Fear", 
	[22] = "Charm", 
	[24] = "Suppression",
	}

	Spell = {
	[0] = { delay = 0.25, speed = 1700, width = 100, range = 1000,type = "line",col=false},
	[2] = { delay = 0.25, speed = 1600, width = 60 , range = 1000,type = "line",col=true},
	[3] = { range = 450},
	}

	Dmg = {
	[0] = function(u) return CalcDamage(myHero, u, 0, 15+25*GetCastLevel(myHero,0) + 0.35 * myHero.ap) end,
	[1] = function(u) return CalcDamage(myHero, u, 0, 15+25*GetCastLevel(myHero,1) + 0.4 * myHero.ap) end,
	[2] = function(u) return CalcDamage(myHero, u, 0, 25+35*GetCastLevel(myHero,2) + 0.5 * myHero.ap) end,
	[3] = function(u) return CalcDamage(myHero, u, 0, (30+40*GetCastLevel(myHero,3) + 0.3 * myHero.ap)*(self.R[myHero.networkID] or 1)) end,
	}
	
	BM:SubMenu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Menu("R", "R")
	BM.C.R:Boolean("E", "Enabled", true)
	BM.C.R:Slider("EAR", "EnemiesAround > x", 2, 1, 5, 1)
	BM.C.R:Slider("AAR", "AlliesAround > x", 0, 0, 5, 1)
	BM.C.R:Slider("MHP", "My Hero HP < x", 100, 0, 100, 5)
	BM.C.R:Slider("EHP", "Enemy HP < x", 30, 0, 100, 5)
	BM.C.R:DropDown("RM", "Ulti Mode", 1, {"Sideways", "MousePos"})
	
	BM:SubMenu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", true)	

	BM:SubMenu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("W", "Use W", true)
	BM.LC:Boolean("E", "Use E", true)	
	
	BM:SubMenu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("W", "Use W", true)
	BM.JC:Boolean("E", "Use E", true)	

	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:SubMenu("p", "Prediction")

	BM:SubMenu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("W", "Use W", true)
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Menu("R", "R")
	BM.KS.R:Boolean("E", "Enabled", false)
	BM.KS.R:DropDown("RM", "Ulti Mode", 1, {"Sideways", "MousePos"})

	BM:SubMenu("Dr", "Drawings")
	BM.Dr:Boolean("UD", "Use Drawings", true)
	BM.Dr:ColorPick("Cc", "Circle color", {255,102,102,102})
	BM.Dr:DropDown("DQ", "Draw Quality", 3, {"High", "Medium", "Low"})
	BM.Dr:Slider("CW", "Circle width", 1, 1, 5, 1)
	BM.Dr:Boolean("DQL", "Draw Q Line", true)
	BM.Dr:Boolean("Q", "Draw Q", true)
	BM.Dr:Boolean("E", "Draw E", true)
	BM.Dr:Boolean("R", "Draw R", true)
	
	BM:Boolean("AQ", "Auto Q on immobile", true)
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveBuff(u,b) end)
	Callback.Add("Draw", function() self:D() end)
	Callback.Add("CreateObj", function(o) self:CreateObj(o) end)
	Callback.Add("DeleteObj", function(o) self:DeleteObj(o) end)
	AntiChannel()
	AntiGapCloser()
	DelayAction( function ()
	if BM["AC"] then BM.AC:Info("ad", "Use Spell(s) : ") BM.AC:Boolean("E","Use E", true) end
	if BM["AGC"] then BM.AGC:Info("ad", "Use Spell(s) : ") BM.AGC:Boolean("E","Use E", true) end
	end,.001)
	
	self.CC = false
	self.o = {}
	self.R = {} 
	self.sp = {
	["AhriOrbMissile"]={type="Line"},
	["AhriOrbReturn"]={type="return"},	
	}
	
	for i = 0,2,2 do
		PredMenu(BM.p,i)
	end
end

function Ahri:AntiChannel(unit,range)
	if BM.AC.E:Value() and range < Spell[2].range and SReady[2] then
		CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
	end
end

function Ahri:AntiGapCloser(unit,range)
	if BM.AGC.E:Value() and range < Spell[2].range and SReady[2] then
		CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
	end
end

function Ahri:CreateObj(o)
	if o.spellOwner.isMe and o and o.isSpell then
		if (o.spellName == "AhriOrbMissile") or (o.spellName == "AhriOrbReturn") then
			if not self.o[o.spellName] then self.o[o.spellName] = {} end
			self.o[o.spellName].o = o
			self.o[o.spellName].s = self.sp[o.spellName]
		end
	end
end

function Ahri:DeleteObj(o)
	if o.spellOwner.isMe and o and o.isSpell then
		if (o.spellName == "AhriOrbMissile") or (o.spellName == "AhriOrbReturn") then
			self.o[o.spellName] = nil
		end
	end
end

function Ahri:UpdateBuff(u,b)
	if u and u.isMe and b then
		if b.Name == "AhriTumble" then
			self.R[u.networkID] = b.Count 
		end
	end
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = true
		end
	end
end

function Ahri:RemoveBuff(u,b)
	if u and u.isMe and b then
		if b.Name == "AhriTumble" then
			self.R[u.networkID] = 0
		end
	end
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = false
		end
	end
end

function Ahri:D()
	if BM.Dr.UD:Value() then
		for _,i in pairs(self.o) do
			if i.o and i.o.valid and BM.Dr.DQL:Value() then
				if i.s.type == "Line" then
					dRectangleOutline(Vector(i.o.pos), Vector(i.o.endPos), 100+myHero.boundingRadius, BM.Dr.CW:Value(), BM.Dr.Cc:Value(), true)
				else
					dRectangleOutline(Vector(i.o.pos), Vector(myHero.pos), 100+myHero.boundingRadius, BM.Dr.CW:Value(), BM.Dr.Cc:Value(), true)
				end
			end
		end
		if BM.Dr.Q:Value() and SReady[0] then
			DrawCircle(myHero.pos,Spell[0].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.E:Value() and SReady[2] then
			DrawCircle(myHero.pos,Spell[2].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.R:Value() and SReady[3] then
			DrawCircle(myHero.pos,Spell[3].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
	end
end

function Ahri:Tick()
	for _,i in pairs(self.o) do
		self:CleanObj(_,i)
	end
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	
	self:KS()
	
	self:AutoQ()

    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Ahri:Combo(u)	
	if u then
		if BM.C.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
		end		
		if BM.C.W:Value() and SReady[1] and ValidTarget(u, myHero.range+myHero.boundingRadius) then
			CastSpell(1)
		end	
		if BM.C.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
			CastGenericSkillShot(myHero,u,Spell[2],2,BM.p)
		end	
		if BM.C.R.E:Value() and SReady[3] and ValidTarget(u, 1000) and GetPercentHP(myHero) <= BM.C.R.MHP:Value() and GetPercentHP(u) <= BM.C.R.EHP:Value() and EnemyHeroesAround(myHero.pos,1000) >= BM.C.R.EAR:Value() and AllyHeroesAround(myHero.pos,1000) >= BM.C.R.AAR:Value() then
			if BM.C.R.RM:Value() == 1 then
				local RPos = Vector(u) - (Vector(u) - Vector(myHero)):perpendicular():normalized() * GetDistance(myHero,u)			
				CastSkillShot(3,RPos)
			elseif BM.C.R.RM:Value() == 2 then
				CastSkillShot(3,GetMousePos())
			end
		end
	end
end

function Ahri:Harass(u)	
	if u then
		if BM.H.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
		end		
		if BM.H.W:Value() and SReady[1] and ValidTarget(u, myHero.range+myHero.boundingRadius) then
			CastSpell(1)
		end	
		if BM.H.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
			CastGenericSkillShot(myHero,u,Spell[2],2,BM.p)
		end	
	end
end

function Ahri:LaneClear()	
	for _,i in pairs(SLM) do
		if i.team == MINION_ENEMY then
			if BM.LC.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
			end		
			if BM.LC.W:Value() and SReady[1] and ValidTarget(i, myHero.range+myHero.boundingRadius) then
				CastSpell(1)
			end	
			if BM.LC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
			end	
		end
	end
end

function Ahri:JungleClear()
	for _,i in pairs(SLM) do
		if i.team == MINION_JUNGLE then
			if BM.JC.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
			end		
			if BM.JC.W:Value() and SReady[1] and ValidTarget(i, myHero.range+myHero.boundingRadius) then			
				CastSpell(1)
			end	
			if BM.JC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
			end	
		end
	end
end

function Ahri:KS()
	for _,i in pairs(GetEnemyHeroes()) do
		if BM.KS.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) and GetAPHP(i) < Dmg[0](i) then
			CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
		end
		if BM.KS.W:Value() and SReady[1] and ValidTarget(i, myHero.range+myHero.boundingRadius) and GetAPHP(i) < Dmg[1](i) then
			CastSpell(1)
		end	
		if BM.KS.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) and GetAPHP(i) < Dmg[2](i) then
			CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
		end	
		if BM.KS.R.E:Value() and SReady[3] and ValidTarget(i, 1000) and GetAPHP(i) < Dmg[3](i) then
			if BM.KS.R.RM:Value() == 1 then
				local RPos = Vector(i) - (Vector(i) - Vector(myHero)):perpendicular():normalized() * GetDistance(myHero,i)			
				CastSkillShot(3,RPos)
			elseif BM.KS.R.RM:Value() == 2 then
				CastSkillShot(3,GetMousePos())
			end
		end			
	end
end

function Ahri:AutoQ()
	for _,i in pairs(GetEnemyHeroes()) do
		if i and BM.AQ:Value() and SReady[0] and ValidTarget(i,Spell[0].range) and self.CC then
			CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
		end
	end
end

function Ahri:CleanObj(_,i)
	if i.o and not i.o.valid then
		self.o[_] = nil
	end
end

class 'Zed'

function Zed:__init()
	
	self.CCType = { 
	[5] = "Stun", 
	[8] = "Taunt", 
	[11] = "Snare", 
	[21] = "Fear", 
	[22] = "Charm", 
	[24] = "Suppression",
	}

	Spell = {
	[0] = { delay = 0.25, speed = 2000, width = 60, range = 900,type = "line",col=false},
	[1] = {range = 700},
	[2] = { range = 284},
	[3] = { range = 625},
	}
	Dmg = {
	[0] = function(u) return CalcDamage(myHero, u, 35+40*GetCastLevel(myHero,0)+(myHero.totalDamage+5*GetCastLevel(myHero,1)),0) end,
	[2] = function(u) return CalcDamage(myHero, u,30+30*GetCastLevel(myHero,2) + 0.8 * (myHero.totalDamage+5*GetCastLevel(myHero,1)),0) end,
	[3] = function(u) return CalcDamage(myHero, u, 30+30*GetCastLevel(myHero,2) + 0.8 * (myHero.totalDamage+5*GetCastLevel(myHero,1))+35+40*GetCastLevel(myHero,0)+(myHero.totalDamage+5*GetCastLevel(myHero,1))+((0.15*GetCastLevel(myHero,3) + 0.05) * (math.sqrt(math.pow((100/(100+GetArmor(u))),2))) * (u.health-u.maxHealth)/100) + (myHero.totalDamage+5*GetCastLevel(myHero,1)), 0) end,
	}
	self.duration = {5,7.5}
	
	BM:SubMenu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("W2", "Use W2", true)
	BM.C:Slider("W2D", "W2 Delay", 30, 0, 100, 5)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Menu("R", "R")
	BM.C.R:Boolean("E", "Enable R", true)
	BM.C.R:Boolean("E2", "Enable R2", true)
	BM.C.R:Boolean("UOIK", "Use Only if killable", true)
	BM.C.R:Slider("EAR", "EnemiesAround > x", 1, 1, 5, 1)
	BM.C.R:Slider("AAR", "AlliesAround > x", 0, 0, 5, 1)
	BM.C.R:Slider("MHP", "My Hero HP < x", 100, 0, 100, 5)
	BM.C.R:Slider("EHP", "Enemy HP < x", 75, 0, 100, 5)
	
	
	BM:SubMenu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", true)	

	BM:SubMenu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("W", "Use W", true)
	BM.LC:Boolean("E", "Use E", true)	
	
	BM:SubMenu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("W", "Use W", true)
	BM.JC:Boolean("E", "Use E", true)	

	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:SubMenu("p", "Prediction")

	BM:SubMenu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("E", "Use E", true)
	
	BM:Boolean("AQ", "Auto Q on immobile", true)
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveBuff(u,b) end)
	Callback.Add("ProcessSpell", function(u,s) self:ProcessSpell(u,s) end)
	
	self.CC = false
	self.W = {}
	self.R = {} 
	self.WPos = false
	self.W2Pos = false
	self.RPos = false
	self.R2Pos = false
	
	for i = 0,0 do
		PredMenu(BM.p,i)
	end
end

function Zed:CleanTable()
	for _,i in pairs(self.W) do
		DelayAction(function() table.remove(self.W,_) self.WPos = false self.W2Pos = false end,self.duration[1])
	end
	for _,i in pairs(self.R) do
		DelayAction(function() table.remove(self.R,_) self.RPos = false self.R2Pos = false end,self.duration[2])
	end
end

function Zed:UpdateBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = true
		end
	end
end

function Zed:RemoveBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = false
		end
	end
end

function Zed:ProcessSpell(u,s)
	if u and u.isMe and s then
		if s.name:lower():find("zedw") then
			table.insert(self.W, {pos=Vector(s.endPos)}) 
		elseif s.name:lower():find("zedw2") then
			table.insert(self.W, {pos=Vector(s.startPos)}) 
		end  
		if s.name:lower():find("zedr") then
			table.insert(self.R, {pos=Vector(s.startPos)}) 
		elseif s.name:lower():find("zedr2") then
			table.insert(self.R,{pos=myHero.pos}) 
		end
	end
end

function Zed:Tick()
	self:CleanTable()
	
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	
	self:KS()
	
	self:AutoQ()

    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Zed:Combo(target)
	if target and not target.dead then
		for _,i in pairs(self.W) do
			if i.pos then
				if SReady[0] and BM.LC.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
					CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.LC.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
					CastSpell(2)
				end
				self.WPos = true
			else
				self.WPos = false
			end
		end
		for _,i in pairs(self.R) do
			if i.pos then
				if SReady[0] and BM.LC.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
					CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.LC.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
					CastSpell(2)
				end
				self.RPos = true
			else
				self.RPos = false
			end
		end
		if not self.WPos and not self.RPos then
			if SReady[0] and BM.JC.Q:Value() and target.distance < Spell[0].range then
				CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
			end
			if SReady[2] and BM.JC.E:Value() and target.distance < Spell[2].range then
				CastSpell(2)
			end
		end
		if GotBuff(myHero,"ZedWHandler") == 0 and not self.WPos and SReady[1] and target.distance < Spell[1].range then
			local pos = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * target.distance*.5
			CastSkillShot(1,pos)
			self.WPos = true
			self.W2Pos = false
		end
		if GotBuff(myHero,"ZedWHandler") == 1 and not self.W2Pos and SReady[1] and target.distance < Spell[1].range+500 then
			DelayAction(function()
			CastSpell(1)
			self.WPos = false
			self.W2Pos = true
			end,BM.C.W2D:Value()*.001)
		end
		if GotBuff(target,"zedrtargetmark") == 0 and BM.C.R.E:Value() and SReady[3] and ValidTarget(target, Spell[3].range) and GetPercentHP(myHero) <= BM.C.R.MHP:Value() and GetPercentHP(target) <= BM.C.R.EHP:Value() and EnemyHeroesAround(myHero.pos,1000) >= BM.C.R.EAR:Value() and AllyHeroesAround(myHero.pos,1000) >= BM.C.R.AAR:Value() then
			if BM.C.R.UOIK:Value() and Dmg[3](target)> target.health then
				CastTargetSpell(target,3)
				self.RPos = true
				self.R2Pos = false
			elseif not BM.C.R.UOIK:Value()  then
				CastTargetSpell(target,3)
				self.RPos = true
				self.R2Pos = false
			end
		end
		if BM.C.R.E2:Value() and SReady[3] and target.health < 100 and GotBuff(target,"zedrtargetmark") == 1 then
			CastSpell(3)
			self.RPos = false
			self.R2Pos = true
		end
	end
end

function Zed:Harass(target)
	if target and not target.dead then
		for _,i in pairs(self.W) do
			if i.pos then
				if SReady[0] and BM.H.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
					CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.H.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
					CastSpell(2)
				end
				self.WPos = true
			else
				self.WPos = false
			end
		end
		for _,i in pairs(self.R) do
			if i.pos then
				if SReady[0] and BM.H.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
					CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.H.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
					CastSpell(2)
				end
				self.RPos = true
			else
				self.RPos = false
			end
		end
		if not self.WPos and not self.RPos then
			if SReady[0] and BM.H.Q:Value() and target.distance < Spell[0].range then
				CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
			end
			if SReady[2] and BM.H.E:Value() and target.distance < Spell[2].range then
				CastSpell(2)
			end
		end
		if not self.WPos and SReady[1] and target.distance < Spell[1].range then
			local pos = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * target.distance*.5
			CastSkillShot(1,pos)
			self.WPos = true
		end
	end
end

function Zed:LaneClear()
	for t,target in pairs(SLM) do
		if target.team == MINION_ENEMY and not target.dead then
			for _,i in pairs(self.W) do
				if i.pos then
					if SReady[0] and BM.LC.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
						CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
					end
					if SReady[2] and BM.LC.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
						CastSpell(2)
					end
					self.WPos = true
				else
					self.WPos = false
				end
			end
			for _,i in pairs(self.R) do
				if i.pos then
					if SReady[0] and BM.LC.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
						CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
					end
					if SReady[2] and BM.LC.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
						CastSpell(2)
					end
					self.RPos = true
				else
					self.RPos = false
				end
			end
			if not self.WPos and not self.RPos then
				if SReady[0] and BM.LC.Q:Value() and target.distance < Spell[0].range then
					CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.LC.E:Value() and target.distance < Spell[2].range then
					CastSpell(2)
				end
			end
			if not self.WPos and SReady[1] and target.distance < Spell[1].range then
				local pos = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * target.distance*.5
				CastSkillShot(1,pos)
				self.WPos = true
			end
		end
	end
end

function Zed:JungleClear()
	for t,target in pairs(SLM) do
		if target.team == MINION_JUNGLE and not target.dead then
			for _,i in pairs(self.W) do
				if i.pos then
					if SReady[0] and BM.JC.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
						CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
					end
					if SReady[2] and BM.JC.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
						CastSpell(2)
					end
					self.WPos = true
				else
					self.WPos = false
				end
			end
			for _,i in pairs(self.R) do
				if i.pos then
					if SReady[0] and BM.JC.Q:Value() and GetDistance(i.pos,target) < Spell[0].range then
						CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
					end
					if SReady[2] and BM.JC.E:Value() and GetDistance(i.pos,target) < Spell[2].range then
						CastSpell(2)
					end
					self.RPos = true
				else
					self.RPos = false
				end
			end
			if not self.WPos and not self.RPos then
				if SReady[0] and BM.JC.Q:Value() and target.distance < Spell[0].range then
					CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.JC.E:Value() and target.distance < Spell[2].range then
					CastSpell(2)
				end
			end
			if not self.WPos and SReady[1] and target.distance < Spell[1].range then
				local pos = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * target.distance*.5
				CastSkillShot(1,pos)
				self.WPos = true
			end
		end
	end
end

function Zed:AutoQ()
	for k,e in pairs(GetEnemyHeroes()) do
		if self.CC and BM.AQ:Value() then
			for _,i in pairs(self.W) do
				if i.pos then
					if SReady[0] and GetDistance(i.pos,e) < Spell[0].range then
						CastGenericSkillShot(i.pos,e,Spell[0],0,BM.p)
					end
					if SReady[2] and GetDistance(i.pos,e) < Spell[2].range then
						CastSpell(2)
					end
					self.WPos = true
				else
					self.WPos = false
				end
			end
			for _,i in pairs(self.R) do
				if i.pos then
					if SReady[0] and GetDistance(i.pos,e) < Spell[0].range then
						CastGenericSkillShot(i.pos,e,Spell[0],0,BM.p)
					end
					if SReady[2] and GetDistance(i.pos,e) < Spell[2].range then
						CastSpell(2)
					end
					self.RPos = true
				else
					self.RPos = false
				end
			end
			if not self.WPos and not self.RPos then
				if SReady[0] and e.distance < Spell[0].range then
					CastGenericSkillShot(myHero,e,Spell[0],0,BM.p)
				end
			end
		end
	end
end

function Zed:KS()
	for k,target in pairs(GetEnemyHeroes()) do
		if target and not target.dead then
			for _,i in pairs(self.W) do
				if i.pos then
					if SReady[0] and BM.KS.Q:Value() and GetDistance(i.pos,target) < Spell[0].range and Dmg[0](target) > target.health then
						CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
					end
					if SReady[2] and BM.KS.E:Value() and GetDistance(i.pos,target) < Spell[2].range and Dmg[2](target) > target.health then
						CastSpell(2)
					end
					self.WPos = true
				else
					self.WPos = false
				end
			end
			for _,i in pairs(self.R) do
				if i.pos then
					if SReady[0] and BM.KS.Q:Value() and GetDistance(i.pos,target) < Spell[0].range and Dmg[0](target) > target.health then
						CastGenericSkillShot(i.pos,target,Spell[0],0,BM.p)
					end
					if SReady[2] and BM.KS.E:Value() and GetDistance(i.pos,target) < Spell[2].range and Dmg[2](target) > target.health then
						CastSpell(2)
					end
					self.RPos = true
				else
					self.RPos = false
				end
			end
			if not self.WPos and not self.RPos then
				if SReady[0] and BM.KS.Q:Value() and target.distance < Spell[0].range and Dmg[0](target) > target.health then
					CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
				end
				if SReady[2] and BM.KS.E:Value() and target.distance < Spell[2].range and Dmg[2](target) > target.health then
					CastSpell(2)
				end
			end
		end
	end
end

class 'Anivia'

function Anivia:__init()

	self.CCType = { 
	[5] = "Stun", 
	[8] = "Taunt", 
	[11] = "Snare", 
	[21] = "Fear", 
	[22] = "Charm", 
	[24] = "Suppression",
	}
	
	self.CCType2 = { 
	[5] = "Stun", 
	[10] = "Slow",
	}

	Spell = {
	[0] = { delay=0.25,range=1075,radius=110,speed=850,type = "line",col=false},
	[1] = { range = 1000},
	[2] = { range = 650},
	[3] = { range = 750, width = 200,width2 = 200},
	}
	
	Dmg = {
    [0] = function(unit) return (30+30*GetCastLevel(myHero,0)*2+myHero.ap)+(35+25*GetCastLevel(myHero,0)+0.4*myHero.ap) end,
    [2] = function(unit) return (25+30*GetCastLevel(myHero,2)+0.5*myHero.ap)*(self.AniviaStun2[unit.networkID] and self.AniviaStun2[unit.networkID]+1 or 1) end,
    [3] = function(unit) return 40+40*GetCastLevel(myHero,3)+0.25*myHero.ap end,
	}
	
	BM:SubMenu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Menu("R", "R")
	BM.C.R:Boolean("E", "Enabled", true)
	BM.C.R:Slider("EAR", "EnemiesAround > x", 1, 1, 5, 1)
	BM.C.R:Slider("AAR", "AlliesAround > x", 0, 0, 5, 1)
	BM.C.R:Slider("MHP", "My Hero HP < x", 100, 0, 100, 5)
	BM.C.R:Slider("EHP", "Enemy HP < x", 100, 0, 100, 5)
	BM.C.R:Slider("MM", "Mana > x", 10, 0, 100, 5)
	
	BM:SubMenu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("E", "Use E", true)	
	BM.H:Menu("R", "R")
	BM.H.R:Boolean("E", "Enabled", true)
	BM.H.R:Slider("EAR", "EnemiesAround > x", 1, 1, 5, 1)
	BM.H.R:Slider("AAR", "AlliesAround > x", 0, 0, 5, 1)
	BM.H.R:Slider("MHP", "My Hero HP < x", 100, 0, 100, 5)
	BM.H.R:Slider("EHP", "Enemy HP < x", 100, 0, 100, 5)
	BM.H.R:Slider("MM", "Mana > x", 10, 0, 100, 5)

	BM:SubMenu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("E", "Use E", true)
	BM.LC:Boolean("R", "Use R", true)	
	
	BM:SubMenu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("E", "Use E", true)
	BM.JC:Boolean("R", "Use R", true)	

	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:SubMenu("p", "Prediction")

	BM:SubMenu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Boolean("R", "Use R", true)

	BM:SubMenu("Dr", "Drawings")
	BM.Dr:Boolean("UD", "Use Drawings", true)
	BM.Dr:ColorPick("Cc", "Circle color", {255,102,102,102})
	BM.Dr:DropDown("DQ", "Draw Quality", 3, {"High", "Medium", "Low"})
	BM.Dr:Slider("CW", "Circle width", 1, 1, 5, 1)
	BM.Dr:Boolean("DQC", "Draw Q Circle", true)
	BM.Dr:Boolean("Q", "Draw Q", true)
	BM.Dr:Boolean("W", "Draw W", true)
	BM.Dr:Boolean("E", "Draw E", true)
	BM.Dr:Boolean("R", "Draw R", true)
	
	BM:Boolean("AQ", "Auto Q on immobile", true)
	BM:Boolean("AE", "Auto E on Slowed,Stuned", true)
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveBuff(u,b) end)
	Callback.Add("Draw", function() self:D() end)
	Callback.Add("CreateObj", function(o) self:CreateObj(o) end)
	Callback.Add("DeleteObj", function(o) self:DeleteObj(o) end)
	Callback.Add("ProcessSpell", function(u,s) self:ProcSp(u,s) end)
	AntiChannel()
	AntiGapCloser()
	DelayAction( function ()
	if BM["AC"] then BM.AC:Info("ad", "Use Spell(s) : ") BM.AC:Boolean("Q","Use Q", true) BM.AC:Boolean("W","Use W", true) end
	if BM["AGC"] then BM.AGC:Info("ad", "Use Spell(s) : ") BM.AGC:Boolean("Q","Use Q", true) BM.AGC:Boolean("W","Use W", true)end
	end,.001)
	
	self.CC = false
	self.AniviaStun = false
	self.AniviaStun2 = {}
	self.o = {}
	self.R = {}
	self.R2Casted = false
	self.Q2Casted = false
	
	for i = 0,0 do
		PredMenu(BM.p,i)
	end
end

function Anivia:CleanObj(_,i)
	if i.o and not i.o.valid then
		self.o[_] = nil
		self.Q2Casted = false
	end
end

function Anivia:AntiChannel(unit,range)
	if BM.AC.Q:Value() and range < Spell[0].range then
		if not self.Q2Casted then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		for _,i in pairs(self.o) do
			if self.Q2Casted and EnemyHeroesAround(i.o.pos,120+myHero.boundingRadius) > 0 then
				CastSpell(0)
			end
		end
	end
	if BM.AC.W:Value() and range < Spell[1].range then
		CastSkillShot(1,unit.pos)
	end
end

function Anivia:AntiGapCloser(unit,range)
	if BM.AGC.Q:Value() and range < Spell[0].range then
		if not self.Q2Casted then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		for _,i in pairs(self.o) do
			if self.Q2Casted and EnemyHeroesAround(i.o.pos,120+myHero.boundingRadius) > 0 then
				CastSpell(0)
			end
		end
	end
	if BM.AGC.W:Value() and range < Spell[1].range then
		CastSkillShot(1,unit.pos)
	end
end

function Anivia:CreateObj(o)
	if o.spellOwner.isMe and o and o.isSpell then
		if o.spellName == "FlashFrostSpell" then
			if not self.o[o.spellName] then self.o[o.spellName] = {} end
			self.o[o.spellName].o = o
			self.Q2Casted = true
		end
	end
end

function Anivia:DeleteObj(o)
	if o.spellOwner.isMe and o and o.isSpell then
		if o.spellName == "FlashFrostSpell" then
			self.o[o.spellName] = nil
			self.Q2Casted = false
		end
	end
end

function Anivia:UpdateBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = true
		end
	end
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType2[b.Type] then
			self.AniviaStun = true
		end
	end
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType2[b.Type] then
			self.AniviaStun2[u.networkID] = b.Count
		end
	end
	if u and u.isMe and b and u.isHero then
		if b.Name == "GlacialStorm" then
			self.R2Casted = true
		end
	end
end

function Anivia:RemoveBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = false
		end
	end
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType2[b.Type] then
			self.AniviaStun = false
		end
	end
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType2[b.Type] then
			self.AniviaStun2[u.networkID] = 0
		end
	end
	if u and u.isMe and b and u.isHero then
		if b.Name == "GlacialStorm" then
			for _,i in pairs(self.R) do
				self.R[_] = nil
			end
			self.R2Casted = false
		end
	end
end

function Anivia:ProcSp(u,s)
	if u.isMe and u and s then
		if s.name == "GlacialStorm" then
			if not self.R[s.name] then self.R[s.name] = {} end
			self.R[s.name].s = s
			self.R[s.name].st = GetGameTimer()
		end
	end
end

function Anivia:D()
	if BM.Dr.UD:Value() then
		for _,i in pairs(self.o) do
			if i.o and i.o.valid and BM.Dr.DQC:Value() then
				DrawCircle(i.o.pos,120+myHero.boundingRadius,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,GoS.White)
			end
		end
		if BM.Dr.Q:Value() and SReady[0] then
			DrawCircle(myHero.pos,Spell[0].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.W:Value() and SReady[1] then
			DrawCircle(myHero.pos,Spell[1].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.E:Value() and SReady[2] then
			DrawCircle(myHero.pos,Spell[2].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
		if BM.Dr.R:Value() and SReady[3] then
			DrawCircle(myHero.pos,Spell[3].range,BM.Dr.CW:Value(),BM.Dr.DQ:Value()*20,BM.Dr.Cc:Value())
		end
	end
end

function Anivia:Tick()
	for _,i in pairs(self.o) do
		self:CleanObj(_,i)
	end
	for _,i in pairs(self.R) do
		 if i and i.st and i.st + 3 > GetGameTimer() then
			Spell[3].width = Spell[3].width2 + (GetGameTimer()  - i.st)* 67
		elseif i and i.st and i.st + 3 == GetGameTimer() then
			Spell[3].width = Spell[3].width
		 end
	end
	if not self.R2Casted then
		Spell[3].width = Spell[3].width2
	end
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	
	self:KS()
	
	self:AutoQ()
	self:AutoE()

    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Anivia:Combo(u)	
	if u then
		if BM.C.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			if not self.Q2Casted then
				CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
			end
			for _,i in pairs(self.o) do
				if self.Q2Casted and EnemyHeroesAround(i.o.pos,120+myHero.boundingRadius) > 0 then
					CastSpell(0)
				end
			end	
		end
		if BM.C.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) and self.AniviaStun then
			CastTargetSpell(u,2)
		end	
		if not self.R2Casted and BM.C.R.E:Value() and SReady[3] and ValidTarget(u, 1000) and GetPercentMP(myHero) >= BM.C.R.MM:Value() and GetPercentHP(myHero) <= BM.C.R.MHP:Value() and GetPercentHP(u) <= BM.C.R.EHP:Value() and EnemyHeroesAround(myHero.pos,1000) >= BM.C.R.EAR:Value() and AllyHeroesAround(myHero.pos,1000) >= BM.C.R.AAR:Value() then
			CastSkillShot(3,u.pos)
		end
		for _,i in pairs(self.R) do
			if self.R2Casted and i.p and BM.C.R.E:Value() and SReady[3] or EnemyHeroesAround(i.s.endPos,Spell[3].width) == 0 then
				CastSpell(3)
			end
		end
	end
end

function Anivia:Harass(u)	
	if u then
		if BM.H.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			if not self.Q2Casted then
				CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
			end
			for _,i in pairs(self.o) do
				if self.Q2Casted and EnemyHeroesAround(i.o.pos,120+myHero.boundingRadius) > 0 then
					CastSpell(0)
				end
			end
		end		
		if BM.H.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) and self.AniviaStun then
			CastTargetSpell(u,2)
		end	
		if not self.R2Casted and BM.H.R.E:Value() and SReady[3] and ValidTarget(u, 1000) and GetPercentMP(myHero) >= BM.H.R.MM:Value() and GetPercentHP(myHero) <= BM.H.R.MHP:Value() and GetPercentHP(u) <= BM.H.R.EHP:Value() and EnemyHeroesAround(myHero.pos,1000) >= BM.H.R.EAR:Value() and AllyHeroesAround(myHero.pos,1000) >= BM.H.R.AAR:Value() then
			CastSkillShot(3,u.pos)
		end
		for _,i in pairs(self.R) do
			if self.R2Casted and i.p and BM.H.R.E:Value() and SReady[3] or EnemyHeroesAround(i.s.endPos,Spell[3].width) == 0 then
				CastSpell(3)
			end
		end
	end
end

function Anivia:LaneClear()	
	for k,unit in pairs(SLM) do
		if unit.team == MINION_ENEMY then
			if BM.LC.Q:Value() and SReady[0] and ValidTarget(unit, Spell[0].range) then
				if not self.Q2Casted then
					CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
				end
				for _,i in pairs(self.o) do
					if self.Q2Casted and EnemyMinionsAround(i.o.pos,120+myHero.boundingRadius) > 0 then
						CastSpell(0)
					end
				end
			end		
			if BM.LC.E:Value() and SReady[2] and ValidTarget(unit, Spell[2].range) and self.AniviaStun then
				CastTargetSpell(unit,2)
			end
			if not self.R2Casted and BM.LC.R:Value() and SReady[3] and ValidTarget(unit, 1000) then
				CastSkillShot(3,unit.pos)
			end
			for _,i in pairs(self.R) do
				if self.R2Casted and i.p and BM.LC.R:Value() and SReady[3] or EnemyMinionsAround(i.s.endPos,Spell[3].width) == 0 then
					CastSpell(3)
				end
			end			
		end
	end
end

function Anivia:JungleClear()
	for k,unit in pairs(SLM) do
		if unit.team == MINION_JUNGLE then
			if BM.JC.Q:Value() and SReady[0] and ValidTarget(unit, Spell[0].range) then
				if not self.Q2Casted then
					CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
				end
				for _,i in pairs(self.o) do
					if self.Q2Casted and EnemyMinionsAround(i.o.pos,120+myHero.boundingRadius) > 0 then
						CastSpell(0)
					end
				end
			end		
			if BM.JC.E:Value() and SReady[2] and ValidTarget(unit, Spell[2].range) and self.AniviaStun then
				CastTargetSpell(unit,2)
			end	
			if not self.R2Casted and BM.JC.R:Value() and SReady[3] and ValidTarget(unit, 1000) then
				CastSkillShot(3,unit.pos)
			end
			for _,i in pairs(self.R) do
				if self.R2Casted and i.p and BM.JC.R:Value() and SReady[3] or JungleMinionsAround(i.s.endPos,Spell[3].width) == 0 then
					CastSpell(3)
				end
			end	
		end
	end
end

function Anivia:KS()
	for k,unit in pairs(GetEnemyHeroes()) do
		if BM.KS.Q:Value() and SReady[0] and ValidTarget(unit, Spell[0].range) and GetAPHP(unit) < Dmg[0](unit) then
			if not self.Q2Casted then
				CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
			end
			for _,i in pairs(self.o) do
				if self.Q2Casted and EnemyHeroesAround(i.o.pos,120+myHero.boundingRadius) > 0 then
					CastSpell(0)
				end
			end
		end
		if BM.KS.E:Value() and SReady[2] and ValidTarget(unit, Spell[2].range) and GetAPHP(unit) < Dmg[2](unit) then
			CastTargetSpell(unit,2)
		end	
		if not self.R2Casted and GetAPHP(unit) < Dmg[3](unit) and BM.KS.E:Value() and SReady[3] and ValidTarget(u, 1000) then
			CastSkillShot(3,unit.pos)
		end
		for _,i in pairs(self.R) do
			if self.R2Casted and i.p and BM.C.R.E:Value() and SReady[3] or EnemyHeroesAround(i.s.endPos,Spell[3].width) == 0 then
				CastSpell(3)
			end
		end			
	end
end

function Anivia:AutoQ()
	for m,unit in pairs(GetEnemyHeroes()) do
		if unit and BM.AQ:Value() and SReady[0] and ValidTarget(unit,Spell[0].range) and (self.CC or self.AniviaStun) then
			if not self.Q2Casted then
				CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
			end
			for _,i in pairs(self.o) do
				if self.Q2Casted and EnemyHeroesAround(i.o.pos,120+myHero.boundingRadius) > 0 then
					CastSpell(0)
				end
			end
		end
	end
end

function Anivia:AutoE()
	for m,unit in pairs(GetEnemyHeroes()) do
		if unit and BM.AE:Value() and SReady[2] and ValidTarget(unit,Spell[2].range) and self.AniviaStun then
			CastTargetSpell(unit,2)
		end
	end
end

class 'Syndra'

function Syndra:__init()

	self.CCType = { 
	[5] = "Stun", 
	[8] = "Taunt", 
	[11] = "Snare", 
	[21] = "Fear", 
	[22] = "Charm", 
	[24] = "Suppression",
	}

	Spell = {
	[-1] = {delay=0,range=950,width=50,speed=2500},
	[0] = {delay=0.6,range=800,width=150,speed=math.huge,type="circular",col=false},
	[1] = {delay=0.25,range=925,width=210,speed=1450,type="circular",col=false},
	[2] = {delay=0,range=650,width=100,speed=2000,type="line",col=false},
	[3] = { range = 750},
	}

	Dmg = {
    [0] = function(unit) return 5+45*GetCastLevel(myHero,0)+.75*myHero.ap end,
	[1] = function(unit) return 40+40*GetCastLevel(myHero,1)+.7*myHero.ap end,
    [2] = function(unit) return 25+45*GetCastLevel(myHero,2)+.4*myHero.ap end,
    [3] = function(unit) return (45+45*GetCastLevel(myHero,3)+.2*myHero.ap)*(self.count+3 or 3) end,
	}

	self.EpicJgl = {["SRU_Baron"]="Baron", ["SRU_Dragon"]="Dragon", ["SRU_RiftHerald"]="Herald", ["TT_Spiderboss"]="Vilemaw"}
	self.BigJgl = {["SRU_Red"]="Red Buff", ["SRU_Blue"]="Blue Buff", ["SRU_Krug"]="Krugs", ["SRU_Murkwolf"]="Wolves", ["SRU_Razorbeak"]="Razor", ["SRU_Gromp"]="Gromp", ["Sru_Crab"]="Scuttles"}

	BM:SubMenu("C", "Combo")
	BM.C:DropDown("CM", "Combo Mode", 1, {"Q-E-W", "W-Q-E"})
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	
	BM:SubMenu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", true)

	BM:SubMenu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("W", "Use W", false)
	BM.LC:Boolean("E", "Use E", false)	
	
	BM:SubMenu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("W", "Use W", true)
	BM.JC:Boolean("E", "Use E", true)	

	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AP",BM.TS,false)
	
	BM:SubMenu("p", "Prediction")

	BM:SubMenu("KS", "Killsteal")
	BM.KS:Boolean("Q", "Use Q", true)
	BM.KS:Boolean("W", "Use W", true)
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Boolean("R", "Use R", true)
	
	BM:SubMenu("Es", "Escape")
	BM.Es:Boolean("E", "Enable", true)
	BM.Es:Key("K", "Key", string.byte("G"))
	BM.Es:Boolean("Q", "Use Q", true)
	BM.Es:Boolean("W", "Use W", true)
	BM.Es:Boolean("E", "Use E", true)
	
	BM:Menu("JS","JungleSteal")
	BM.JS:Boolean("Q", "Use Q", true)
	BM.JS:Boolean("W", "Use W", true)
	BM.JS:Boolean("E", "Use E", true)
	DelayAction(function()
	BM.JS:Menu("S", "Enable for : ")
		for _,i in pairs(self.EpicJgl) do
			BM.JS.S:Boolean(_,i,true)
		end
		for _,i in pairs(self.BigJgl) do
			BM.JS.S:Boolean(_,i,false)
		end
	end,.001)
	
	BM:Boolean("DS", "Draw Spheres", true)
	BM:Boolean("AQ", "Auto Q on immobile", true)
	BM:Boolean("AW", "Auto W on immobile", true)
	
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveBuff(u,b) end)
	Callback.Add("CreateObj", function(o) self:CreateObj(o) end)
	Callback.Add("DeleteObj", function(o) self:DeleteObj(o) end)
	AntiChannel()
	AntiGapCloser()
	DelayAction( function ()
		if BM["AC"] then BM.AC:Info("ad", "Use Spell(s) : ") BM.AC:Boolean("E","Use E", true)  end
		if BM["AGC"] then BM.AGC:Info("ad", "Use Spell(s) : ") BM.AGC:Boolean("E","Use E", true) end
	end,.001)
	
	self.CC = false
	self.o = {}
	self.count = 0
	self.WCast = 0
	
	for i = 0,2 do
		PredMenu(BM.p,i)
	end
end

function Syndra:AntiChannel(unit,range)
	if BM.AC.E:Value() and range < Spell[2].range then
		CastSkillShot(2,unit.pos)
	end
end

function Syndra:AntiGapCloser(unit,range)
	if BM.AGC.E:Value() and range < Spell[2].range then
		CastSkillShot(2,unit.pos)
	end
end

function Syndra:CreateObj(o)
	if o.name == "Seed" and o.charName == "SyndraSphere" then
		self.count = self.count+1
		if not self.o[o.networkID] then self.o[o.networkID] = {} end
		self.o[o.networkID].o = o
	end
end

function Syndra:DeleteObj(o)
	if o.name == "Seed" then
		self.count = self.count-1
		self.o[o.networkID] = nil
	end
end

function Syndra:UpdateBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = true
		end
	end
end

function Syndra:RemoveBuff(u,b)
	if u and u.team == MINION_ENEMY and b and u.isHero then
		if self.CCType[b.Type] then
			self.CC = false
		end
	end
end

function Syndra:Draw()
	if BM.DS:Value() then
		for _,i in pairs(self.o) do
			if self:QCheck() and i and i.o.alive and i.o and i.o.valid and SReady[2] and i.o.distance < Spell[-1].range+Spell[2].range then
			local Vec = Vector(myHero) + Vector((Vector(i.o)-myHero)):normalized()*(Spell[-1].range+Spell[2].range/2)
				DrawLine3D(i.o.pos.x,i.o.pos.y,i.o.pos.z,Vec.x,Vec.y,Vec.z,1,GoS.White)
				DrawCircle(i.o.pos,i.o.boundingRadius*1.5,1,20,GoS.White)
				DrawCircle(Vec,i.o.boundingRadius*1.5,1,20,GoS.White)
			end
		end
	end
end

function Syndra:Tick()
	if self.count < 0 then self.count = 0 end
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	
	self:KS()
	
	self:AutoQ()
	self:AutoW()
	self:Escape()
	self:JungleSteal()
	
    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Syndra:QCheck()
	for _,v in pairs(self.o) do
		if v and v.o and v.o.valid and v.o.distance < Spell[1].range then
			return true
		end
	end
	return false
end 

function Syndra:CastW(u)
	for _,i in pairs(SLM) do
		if not self:QCheck() then 
			if SReady[1] and i.distance < Spell[1].range and i.valid and u and ValidTarget(u,Spell[1].range) and u.valid and u.visible and IsTargetable(u) then
				if self.WCast+1000 < GetTickCount() and GetCastName(myHero,1) == "SyndraW" then
					self.WCast = GetTickCount()
					CastSkillShot(1,i.pos)
				end
				if GetCastName(myHero,1) ~= "SyndraW" then
					 CastGenericSkillShot(myHero,u,Spell[1],1,BM.p)
				end
			end
		else
			for _,v in pairs(self.o) do
				if v then
					if SReady[1] and v.o.distance < Spell[1].range and v.o.valid and u and ValidTarget(u,Spell[1].range) and u.valid and u.visible and IsTargetable(u) then
						if self.WCast+1000 < GetTickCount() and GetCastName(myHero,1) == "SyndraW" then
							self.WCast = GetTickCount()
							CastSkillShot(1,v.o.pos)
						end
						if GetCastName(myHero,1) ~= "SyndraW" then
							 CastGenericSkillShot(myHero,u,Spell[1],1,BM.p)
						end
					end
				end
			end
		end
	end
end

function Syndra:CastE(u)
	for _,i in pairs(self.o) do
		if self:QCheck() and i and i.o and u.distance < Spell[-1].range+Spell[2].range and u.valid and SReady[2] then
		local Vec = Vector(myHero) + Vector((Vector(i.o)-myHero)):normalized()*(Spell[-1].range+Spell[2].range/2)
		local vp = VectorPointProjectionOnLineSegment(Vector(myHero.pos),Vector(Vec),Vector(u.pos))
			if vp and GetDistance(u,vp) < Spell[-1].width and i.o.distance < Spell[2].range then
				CastSkillShot(2,i.o.pos)
			end
		end
	end
	if not self:QCheck() and u.valid and u.distance < Spell[2].range and SReady[2] then
		CastGenericSkillShot(myHero,u,Spell[2],2,BM.p)
	end
end

function Syndra:Combo(u)	
	if u then
		if BM.C.CM:Value() == 1 then
			if BM.C.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
				CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
			end	
			if BM.C.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
				self:CastE(u)
			end				
			if BM.C.W:Value() and SReady[1] and ValidTarget(u, Spell[1].range) then
				self:CastW(u)
			end	
		else
			if BM.C.W:Value() and SReady[1] and ValidTarget(u, Spell[1].range) then
				self:CastW(u)
			end	
			if BM.C.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
				CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
			end	
			if BM.C.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
				self:CastE(u)
			end					
		end
	end
end

function Syndra:Harass(u)	
	if u then
		if BM.H.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			CastGenericSkillShot(myHero,u,Spell[0],0,BM.p)
		end		
		if BM.H.W:Value() and SReady[1] and ValidTarget(u, Spell[1].range) then
			self:CastW(u)
		end	
		if BM.H.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
			self:CastE(u)
		end	
	end
end

function Syndra:LaneClear()	
	for _,i in pairs(SLM) do
		if i.team == MINION_ENEMY then
			if BM.LC.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
			end		
			if BM.LC.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) then
				self:CastW(i)
			end	
			if BM.LC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				self:CastE(i)
			end	
		end
	end
end

function Syndra:JungleClear()
	for _,i in pairs(SLM) do
		if i.team == MINION_JUNGLE then
			if BM.JC.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
			end		
			if BM.JC.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) then			
				self:CastW(i)
			end	
			if BM.JC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				self:CastE(i)
			end
		end
	end
end

function Syndra:JungleSteal()
	for _,i in pairs(SLM) do
		if i.team == MINION_JUNGLE then
			if i.valid and i.distance < 1000 and ((BM.JS.S[i.charName] and BM.JS.S[i.charName]:Value()) or (i.charName:find("Dragon") and BM.JS.S["SRU_Dragon"]:Value())) then
				if BM.JS.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) and Dmg[0](i) > GetAPHP(i) then
					CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
				end		
				if BM.JS.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) and Dmg[1](i) > GetAPHP(i) then			
					self:CastW(i)
				end
				if BM.JC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) and Dmg[2](i) > GetAPHP(i) then
					self:CastE(i)
				end
			end
		end
	end
end

function Syndra:Escape()
	if BM.Es.K:Value() and BM.Es.E:Value() then	
		MoveToXYZ(GetMousePos())
		for _,i in pairs(GetEnemyHeroes()) do
			if BM.Es.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
			end		
			if BM.Es.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) then			
				self:CastW(i)
			end	
			if BM.Es.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				self:CastE(i)
			end	
		end
	end
end

function Syndra:AutoQ()
	for _,i in pairs(GetEnemyHeroes()) do
		if i and BM.AQ:Value() and SReady[0] and ValidTarget(i,Spell[0].range) and self.CC then
			CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
		end
	end
end

function Syndra:AutoW()
	for _,i in pairs(GetEnemyHeroes()) do
		if i and BM.AW:Value() and SReady[1] and ValidTarget(i,Spell[1].range) and self.CC then
			self:CastW(i)
		end
	end
end

function Syndra:KS()
	for _,i in pairs(GetEnemyHeroes()) do
		if BM.KS.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) and GetAPHP(i) < Dmg[0](i) then
			CastGenericSkillShot(myHero,i,Spell[0],0,BM.p)
		end
		if BM.KS.W:Value() and SReady[1] and ValidTarget(i, Spell[1].range) and GetAPHP(i) < Dmg[1](i) then
			self:CastW(i)
		end
		if BM.KS.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) and GetAPHP(i) < Dmg[2](i) then
			self:CastE(i)
		end	
		if BM.KS.R:Value() and SReady[3] and ValidTarget(i, Spell[3].range) and GetAPHP(i) < Dmg[3](i) then
			CastTargetSpell(i,3)
		end			
	end
end

class 'Draven'

function Draven:__init()

	self.EpicJgl = {["SRU_Baron"]="Baron", ["SRU_Dragon"]="Dragon", ["SRU_RiftHerald"]="Herald", ["TT_Spiderboss"]="Vilemaw"}
	self.BigJgl = {["SRU_Red"]="Red Buff", ["SRU_Blue"]="Blue Buff", ["SRU_Krug"]="Krugs", ["SRU_Murkwolf"]="Wolves", ["SRU_Razorbeak"]="Razor", ["SRU_Gromp"]="Gromp", ["Sru_Crab"]="Scuttles"}

	Spell = {
	[0] = { range = myHero.range+myHero.boundingRadius*2},
	[1] = { range = 800 },
	[2] = { range = 1050,delay = 0.25, radius = 130, speed = 1400},
	[3] = { range = 25000,delay = 0.5, radius = 160, speed = 2000},
	}
	
	Dmg = {
	[0] = function(unit) return CalcDamage(myHero, unit, myHero.totalDamage+myHero.totalDamage*(.35+.1*GetCastLevel(myHero,0)), 0) end,
	[2] = function(unit) return CalcDamage(myHero, unit, 25+45*GetCastLevel(myHero,2)+.5*myHero.totalDamage, 0) end,
	[3] = function(unit) return CalcDamage(myHero, unit, 75+100*GetCastLevel(myHero,3)+1.1*myHero.totalDamage, 0) end,
	}
	
	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("E", "Use E", true)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("Q", "Use Q", true)
	BM.H:Boolean("W", "Use W", true)
	BM.H:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear")
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("W", "Use W", false)
	BM.LC:Boolean("E", "Use E", false)
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("W", "Use W", true)
	BM.JC:Boolean("E", "Use E", false)
	
	BM:Menu("JS","JungleSteal")
	BM.JS:Boolean("E", "Use E", true)
	BM.JS:Boolean("R", "Use R", false)
	DelayAction(function()
	BM.JS:Menu("S", "Enable for : ")
		for _,i in pairs(self.EpicJgl) do
			BM.JS.S:Boolean(_,i,true)
		end
		for _,i in pairs(self.BigJgl) do
			BM.JS.S:Boolean(_,i,false)
		end
	end,.001)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("E", "Use E", true)
	BM.KS:Boolean("R", "Use R", true)
	BM.KS:Slider("MaR", "Max Range To KS with R", 10000, 0, 25000, 100)
	BM.KS:Slider("MiR", "Min Range To KS with R", 2500, 0, 25000, 100)
	
	BM:Menu("DS", "Catch Settings")
	BM.DS:Boolean("E", "Enable Catch", true)
	BM.DS:Slider("CR", "Catch Radius", 500,100,1000,5)
	BM.DS:Boolean("UW", "Use W if not catchable", true)
	BM.DS:Boolean("ED", "Enable Draw", true)
	BM.DS:Boolean("DCR", "Draw Catch Radius", true)
	
	BM:Boolean("AW", "Use W on Slow", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")
	
	
	Callback.Add("CreateObj", function(o) self:CO(o) end)
	Callback.Add("DeleteObj", function(o) self:DO(o) end)
	Callback.Add("Draw", function() self:D() end)
	Callback.Add("Tick", function() self:T() end)
	Callback.Add("UpdateBuff", function(u,b) self:UB(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RB(u,b) end)
	
	self.o = {}
	self.CC = false
	self.pos = nil
	self.R = false
	_G.DravenLoaded = true
	
	for i = 2,3 do
		PredMenu(BM.p, i)	
	end
end

function Draven:CO(o)
	if o and o.name:lower():find("reticle_self") then
		if not self.o[o.name] then self.o[o.name] = {} end
		self.o[o.name].o = o
	end
end

function Draven:DO(o)
	if o and o.name:lower():find("reticle_self") then
		self.o[o.name] = nil
	end
end

function Draven:UB(u,b)
	if u and u.isMe and b then
		if b.Type == 10 then
			self.CC = true
		end
		if b.Name == "DravenRDoublecast" then
			self.R = true
		end
	end
end

function Draven:RB(u,b)
	if u and u.isMe and b then
		if b.Type == 10 then
			self.CC = false
		end
		if b.Name == "DravenRDoublecast" then
			self.R = false
		end
	end
end

function Draven:D()
	for _, i in pairs(self.o) do
		if BM.DS.ED:Value() then
			if i.o then
				DrawCircle(i.o.pos,75,1.5,20,ARGB(255,0,180,100))
			end
		end
	end
	if BM.DS.DCR:Value() and BM.DS.ED:Value() then
		DrawCircle(GetMousePos(),BM.DS.CR:Value(),1.5,20,ARGB(255,0,180,100))
	end
end
	
function Draven:T()
	if myHero.dead then return end
	target = ts:GetTarget()
	GetReady()
	self:KS()
	self:Catch()
	self:AutoW()
	self:JungleSteal()
	
    if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Draven:Combo(u)	
	if u then
		if BM.C.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			CastSpell(0)
		end		
		if BM.C.W:Value() and SReady[1] and ValidTarget(u, Spell[0].range) then
			CastSpell(1)
		end	
		if BM.C.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
			CastGenericSkillShot(myHero,u,Spell[2],2,BM.p)
		end	
	end
end

function Draven:Harass(u)	
	if u then
		if BM.H.Q:Value() and SReady[0] and ValidTarget(u, Spell[0].range) then
			CastSpell(0)
		end		
		if BM.H.W:Value() and SReady[1] and ValidTarget(u, Spell[0].range) then
			CastSpell(1)
		end	
		if BM.H.E:Value() and SReady[2] and ValidTarget(u, Spell[2].range) then
			CastGenericSkillShot(myHero,u,Spell[2],2,BM.p)
		end	
	end
end

function Draven:LaneClear()	
	for _,i in pairs(SLM) do
		if i.team == MINION_ENEMY then
			if BM.LC.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastSpell(0)
			end		
			if BM.LC.W:Value() and SReady[1] and ValidTarget(i, Spell[0].range) then
				CastSpell(1)
			end	
			if BM.LC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
			end
		end
	end
end

function Draven:JungleClear()
	for _,i in pairs(SLM) do
		if i.team == MINION_JUNGLE then
			if BM.JC.Q:Value() and SReady[0] and ValidTarget(i, Spell[0].range) then
				CastSpell(0)
			end		
			if BM.JC.W:Value() and SReady[1] and ValidTarget(i, Spell[0].range) then
				CastSpell(1)
			end	
			if BM.JC.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) then
				CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
			end
		end
	end
end

function Draven:KS()
	for _,i in pairs(GetEnemyHeroes()) do
		if BM.KS.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) and GetADHP(i) < Dmg[2](i) then
			CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
		end	
		if BM.KS.R:Value() and SReady[3] and ValidTarget(i, Spell[3].range) and GetADHP(i) < Dmg[3](i) and i.distance > BM.KS.MiR:Value() and i.distance < BM.KS.MaR:Value() and not self.R then
			CastGenericSkillShot(myHero,i,Spell[3],3,BM.p)
		end			
	end
end

function Draven:JungleSteal()
	for _,i in pairs(SLM) do
		if i.team == MINION_JUNGLE then
			if i.valid and ((BM.JS.S[i.charName] and BM.JS.S[i.charName]:Value()) or (i.charName:find("Dragon") and BM.JS.S["SRU_Dragon"]:Value())) then	
				if BM.JS.E:Value() and SReady[2] and ValidTarget(i, Spell[2].range) and GetADHP(i) < Dmg[2](i) then
					CastGenericSkillShot(myHero,i,Spell[2],2,BM.p)
				end
				if BM.JS.R:Value() and SReady[3] and ValidTarget(i, Spell[3].range) and GetADHP(i) < Dmg[3](i) and not self.R then
					CastGenericSkillShot(myHero,i,Spell[3],3,BM.p)
				end	
			end
		end
	end
end

function Draven:AutoW()
	if SReady[1] and self.CC and BM.AW:Value() then 
		CastSpell(1)
	end
	for _,i in pairs(self.o) do
		if SReady[1] and BM.DS.UW:Value() and i.o and self.pos and BM.DS.E:Value() and GetDistance(i.o.pos,GetMousePos()) < BM.DS.CR:Value() and i.o.distance/2000+GetWindUp(myHero)*1000 < i.o.distance/myHero.ms then
			CastSpell(1)
		end
	end
end

function Draven:Catch()
	for _, i in pairs(self.o) do
		if i.o and BM.DS.E:Value() then
			self.pos = Vector(i.o.pos) + Vector(Vector(myHero.pos)-i.o.pos):normalized():perpendicular()*75
			if GetDistance(i.o.pos,GetMousePos()) < BM.DS.CR:Value() and self.pos then
				MoveToXYZ(self.pos)
			end
		end
	end
end

function Draven:CleanObj()
	for _, i in pairs(self.o) do
		if i.o and not i.o.valid then
			self.o[_] = nil
		end
	end
end

---------------------------------------------------------------------------------------------
-------------------------------------UTILITY-------------------------------------------------
---------------------------------------------------------------------------------------------

--DamageDraw (Paint.lua)
class 'DmgDraw'

function DmgDraw:__init()

	self.dmgSpell = {}
	self.spellName= {"Q","W","E","R"} 
	self.dC = { {200,255,255,0}, {200,0,255,0}, {200,255,0,0}, {200,0,0,255} }
	self.aa = {}
	self.dCheck = {}
	self.dX = {}
	self.Own = nil

	BM:SubMenu("D","Damage Draw")
	BM.D:Boolean("dAA","Count AA to kill", true)
	BM.D:Boolean("dAAc","Consider Crit", true)
	BM.D:Slider("dR","Draw Range", 1500, 500, 3000, 100)
	
	if SLSChamps[ChampName] then
		self.Own = true
		for i=1,4,1 do
			if Dmg[i-1] then
				BM.D:Boolean(self.spellName[i], "Draw "..self.spellName[i], true)
				BM.D:ColorPick(self.spellName[i].."c", "Color for "..self.spellName[i], self.dC[i])
			end
		end
	else
		self.Own = false
		for i=1,4,1 do
			if getdmg(self.spellName[i],myHero,myHero,1,3)~=0 then
				BM.D:Boolean(self.spellName[i], "Draw "..self.spellName[i], true)
				BM.D:ColorPick(self.spellName[i].."c", "Color for "..self.spellName[i], self.dC[i])
			end
		end
	end

	DelayAction( function()
		for _,champ in pairs(GetEnemyHeroes()) do
			self.dmgSpell[GetObjectName(champ)]={0, 0, 0, 0}
			self.dX[GetObjectName(champ)] = {{0,0}, {0,0}, {0,0}, {0,0}}
		end
		Callback.Add("Tick", function() self:Set() end)
		Callback.Add("Draw", function() self:Draw() end)
	end, .001)
end

function DmgDraw:Set()
	for _,champ in pairs(GetEnemyHeroes()) do
		self.dCheck[GetObjectName(champ)]={false,false,false,false}
		local last = GetPercentHP(champ)*1.04
		local lock = false
			GetReady()
		for i=1,4,1 do
			if BM.D[self.spellName[i]] and BM.D[self.spellName[i]]:Value() and (SReady[i-1] or CanUseSpell(myHero,i-1) == 8) and GetDistance(GetOrigin(myHero),GetOrigin(champ)) < BM.D.dR:Value() then
				if self.Own then
					self.dmgSpell[GetObjectName(champ)][i] = Dmg[i-1](champ)
				else
					self.dmgSpell[GetObjectName(champ)][i] = getdmg(self.spellName[i],champ,myHero,GetCastLevel(myHero,i-1))
				end
				self.dCheck[GetObjectName(champ)][i]=true
			else 
				self.dmgSpell[GetObjectName(champ)][i] = 0
				self.dCheck[GetObjectName(champ)][i]=false
			end
			self.dX[GetObjectName(champ)][i][2] = self.dmgSpell[GetObjectName(champ)][i]/(GetMaxHP(champ)+GetDmgShield(champ))*104
			self.dX[GetObjectName(champ)][i][1] = last - self.dX[GetObjectName(champ)][i][2]
			last = last - self.dX[GetObjectName(champ)][i][2]
			if lock then
				self.dX[GetObjectName(champ)][i][1] = 0 
				self.dX[GetObjectName(champ)][i][2] = 0
			end
			if self.dX[GetObjectName(champ)][i][1]<=0 and not lock then
				self.dX[GetObjectName(champ)][i][1] = 0 
				self.dX[GetObjectName(champ)][i][2] = last + self.dX[GetObjectName(champ)][i][2]
				lock = true
			end
		end
		if BM.D.dAA:Value() and BM.D.dAAc:Value() then 
			self.aa[GetObjectName(champ)] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)*(GetCritChance(myHero)+1)))
		elseif BM.D.dAA:Value() and not BM.D.dAAc:Value() then 
			self.aa[GetObjectName(champ)] = math.ceil(GetCurrentHP(champ)/(CalcDamage(myHero, champ, GetBaseDamage(myHero)+GetBonusDmg(myHero),0)))
		end
	end
end

function DmgDraw:Draw()
	for _,champ in pairs(GetEnemyHeroes()) do
		
		local bar = GetHPBarPos(champ)
		if bar.x ~= 0 and bar.y ~= 0 then
			for i=4,1,-1 do
				if self.dCheck[GetObjectName(champ)] and self.dCheck[GetObjectName(champ)][i] then
					FillRect(bar.x+self.dX[GetObjectName(champ)][i][1],bar.y,self.dX[GetObjectName(champ)][i][2],9,BM.D[self.spellName[i].."c"]:Value())
					FillRect(bar.x+self.dX[GetObjectName(champ)][i][1],bar.y-1,2,11,GoS.Black)
				end
			end
			if BM.D.dAA:Value() and bar.x ~= 0 and bar.y ~= 0 and self.aa[GetObjectName(champ)] then 
				DrawText(self.aa[GetObjectName(champ)].." AA", 15, bar.x + 75, bar.y + 25, GoS.White)
			end
		end
	end
end

class 'Drawings'

function Drawings:__init()
	if not SLSChamps[ChampName] then return end
	self.SNames={[0]="Q",[1]="W",[2]="E",[3]="R"}
	BM:SubMenu("Dr", "Drawings")
	BM.Dr:Boolean("UD", "Use Drawings", true)
	BM.Dr:ColorPick("CP", "Circle color", {255,102,102,102})
	BM.Dr:DropDown("DQM", "Draw Quality", 3, {"High", "Medium", "Low"})
	BM.Dr:Slider("DWi", "Circle width", 1, 1, 5, 1)
	for i=0,3 do
		if Spell and Spell[i] and Spell[i].range and Spell[i].range > 200 then
			BM.Dr:Boolean("D"..self.SNames[i], "Draw "..self.SNames[i], true)
		end
	end
	Callback.Add("Draw", function() self:Draw() end)
end

function Drawings:Draw()
	for l=0,3 do
		if Spell and Spell[l] and Spell[l].range and Spell[l].range > 200 then
			if BM.Dr.UD:Value() and SReady[l] and BM.Dr["D"..self.SNames[l]]:Value() then
				DrawCircle(myHero.pos, Spell[l].range, BM.Dr.DWi:Value(), BM.Dr.DQM:Value()*20, BM.Dr.CP:Value())
			end
		end
	end
end

class 'HitMe'

function HitMe:__init()
 
     self.str = {[-4] = "R2", [-3] = "P", [-2] = "Q3", [-1] = "Q2", [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
 
    BM:SubMenu("SB","Spellblock")
  
	
self.s = {
	["AatroxQ"]={charName="Aatrox",slot=0,type="Circle",delay=0.6,range=650,radius=250,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0.225,displayname="Dark Flight",mcollision=false},
	["AatroxE"]={charName="Aatrox",slot=2,type="Line",delay=0.25,range=1075,radius=35,speed=1250,addHitbox=true,danger=3,dangerous=false,proj="AatroxEConeMissile",killTime=0,displayname="Blade of Torment",mcollision=false},
	["AhriOrbofDeception"]={charName="Ahri",slot=0,type="Line",delay=0.25,range=1000,radius=100,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="AhriOrbMissile",killTime=0,displayname="Orb of Deception",mcollision=false},
	["AhriOrbReturn"]={charName="Ahri",slot=0,type="Return",delay=0,range=1000,radius=100,speed=915,addHitbox=true,danger=2,dangerous=false,proj="AhriOrbReturn",killTime=0,displayname="Orb of Deception2",mcollision=false},
	["AhriSeduce"]={charName="Ahri",slot=2,type="Line",delay=0.25,range=1000,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="AhriSeduceMissile",killTime=0,displayname="Charm",mcollision=true},
	["Pulverize"]={charName="Alistar",slot=0,type="Circle",delay=0.25,range=1000,radius=200,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0.25,displayname="Pulverize",mcollision=false},
	["BandageToss"]={charName="Amumu",slot=0,type="Line",delay=0.25,range=1000,radius=90,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="SadMummyBandageToss",killTime=0,displayname="Bandage Toss",mcollision=true},
	["CurseoftheSadMummy"]={charName="Amumu",slot=3,type="Circle",delay=0.25,range=0,radius=550,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=1.25,displayname="Curse of the Sad Mummy",mcollision=false},
	["FlashFrost"]={charName="Anivia",slot=0,type="Line",delay=0.25,range=1200,radius=110,speed=850,addHitbox=true,danger=3,dangerous=true,proj="FlashFrostSpell",killTime=0,displayname="Flash Frost",mcollision=false},
	["Incinerate"]={charName="Annie",slot=1,type="Cone",delay=0.25,range=825,radius=80,speed=math.huge,angle=50,addHitbox=false,danger=2,dangerous=false,proj="nil",killTime=0,displayname="",mcollision=false},
	["InfernalGuardian"]={charName="Annie",slot=3,type="Circle",delay=0.25,range=600,radius=251,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0.3,displayname="",mcollision=false},
	-- ["Volley"]={charName="Ashe",slot=1,type="Line",delay=0.25,range=1200,radius=60,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VolleyAttack",killTime=0,displayname="",mcollision=false},
	["EnchantedCrystalArrow"]={charName="Ashe",slot=3,type="Line",delay=0.2,range=20000,radius=130,speed=1600,addHitbox=true,danger=5,dangerous=true,proj="EnchantedCrystalArrow",killTime=0,displayname="Enchanted Arrow",mcollision=false},
	["AurelionSolQ"]={charName="AurelionSol",slot=0,type="Line",delay=0.25,range=1500,radius=180,speed=850,addHitbox=true,danger=2,dangerous=false,proj="AurelionSolQMissile",killTime=0,displayname="AurelionSolQ",mcollision=false},
	["AurelionSolR"]={charName="AurelionSol",slot=3,type="Line",delay=0.3,range=1420,radius=120,speed=4500,addHitbox=true,danger=3,dangerous=true,proj="AurelionSolRBeamMissile",killTime=0,displayname="AurelionSolR",mcollision=false},
	["BardQ"]={charName="Bard",slot=0,type="Line",delay=0.25,range=850,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="BardQMissile",killTime=0,displayname="BardQ",mcollision=true},
	["BardR"]={charName="Bard",slot=3,type="Circle",delay=0.5,range=3400,radius=350,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="BardR",killTime=1,displayname="BardR",mcollision=false},
	["RocketGrab"]={charName="Blitzcrank",slot=0,type="Line",delay=0.2,range=1050,radius=70,speed=1800,addHitbox=true,danger=4,dangerous=true,proj="RocketGrabMissile",killTime=0,displayname="Rocket Grab",mcollision=true},
	["StaticField"]={charName="Blitzcrank",slot=3,type="Circle",delay=0.25,range=0,radius=600,speed=math.huge,addHitbox=false,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Static Field",mcollision=false},
	["BrandQ"]={charName="Brand",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="BrandQMissile",killTime=0,displayname="Sear",mcollision=true},
	["BrandW"]={charName="Brand",slot=1,type="Circle",delay=0.85,range=900,radius=240,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.275,displayname="Pillar of Flame"}, -- doesnt work
	["BraumQ"]={charName="Braum",slot=0,type="Line",delay=0.25,range=1000,radius=60,speed=1700,addHitbox=true,danger=3,dangerous=true,proj="BraumQMissile",killTime=0,displayname="Winter's Bite",mcollision=true},
	["BraumRWrapper"]={charName="Braum",slot=3,type="Line",delay=0.5,range=1250,radius=115,speed=1400,addHitbox=true,danger=4,dangerous=true,proj="braumrmissile",killTime=0,displayname="Glacial Fissure",mcollision=false},
	["CaitlynPiltoverPeacemaker"]={charName="Caitlyn",slot=0,type="Line",delay=0.6,range=1300,radius=90,speed=1800,addHitbox=true,danger=2,dangerous=false,proj="CaitlynPiltoverPeacemaker",killTime=0,displayname="Piltover Peacemaker",mcollision=false},
	["CaitlynEntrapment"]={charName="Caitlyn",slot=2,type="Line",delay=0.4,range=1000,radius=70,speed=1600,addHitbox=true,danger=1,dangerous=false,proj="CaitlynEntrapmentMissile",killTime=0,displayname="90 Caliber Net",mcollision=true},
	["CassiopeiaQ"]={charName="Cassiopeia",slot=0,type="Circle",delay=0.75,range=850,radius=150,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="CassiopeiaNoxiousBlast",killTime=0.2,displayname="Noxious Blast",mcollision=false},
	["CassiopeiaR"]={charName="Cassiopeia",slot=3,type="Cone",delay=0.6,range=825,radius=80,speed=math.huge,angle=80,addHitbox=false,danger=5,dangerous=true,proj="CassiopeiaPetrifyingGaze",killTime=0,displayname="Petrifying Gaze",mcollision=false},
	["Rupture"]={charName="Chogath",slot=0,type="Circle",delay=.25,range=950,radius=250,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="Rupture",killTime=1.75,displayname="Rupture",mcollision=false},
	["PhosphorusBomb"]={charName="Corki",slot=0,type="Circle",delay=0.3,range=825,radius=250,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="PhosphorusBombMissile",killTime=0.35,displayname="Phosphorus Bomb",mcollision=false},
	["CarpetBombMega"]={charName="Corki",slot=2,type="Line",delay=0.2,range=1900,radius=140,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="CarpetBombMega",killTime=0,displayname="Special Delivery",mcollision=false},
	["MissileBarrage"]={charName="Corki",slot=3,type="Line",delay=0.2,range=1300,radius=40,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="MissileBarrageMissile",killTime=0,displayname="Missile Barrage",mcollision=true},
	["MissileBarrage2"]={charName="Corki",slot=3,type="Line",delay=0.2,range=1500,radius=40,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="MissileBarrageMissile2",killTime=0,displayname="Missile Barrage big",mcollision=true},
	["DariusCleave"]={charName="Darius",slot=0,type="Circle",delay=0.75,range=0,radius=425 - 50,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="DariusCleave",killTime=0,displayname="Cleave",mcollision=false},
	["DariusAxeGrabCone"]={charName="Darius",slot=2,type="Cone",delay=0.25,range=550,radius=80,speed=math.huge,angle=30,addHitbox=false,danger=3,dangerous=true,proj="DariusAxeGrabCone",killTime=0,displayname="Apprehend",mcollision=false},
	["DianaArc"]={charName="Diana",slot=0,type="Circle",delay=0.25,range=835,radius=195,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DianaArcArc",killTime=0,displayname="",mcollision=false},
	["DianaArcArc"]={charName="Diana",slot=0,type="Arc",delay=0.25,range=835,radius=195,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DianaArcArc",killTime=0,displayname="",mcollision=false},
	["InfectedCleaverMissileCast"]={charName="DrMundo",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=2000,addHitbox=true,danger=3,dangerous=false,proj="InfectedCleaverMissile",killTime=0,displayname="Infected Cleaver",mcollision=true},
	["DravenDoubleShot"]={charName="Draven",slot=2,type="Line",delay=0.25,range=1100,radius=130,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DravenDoubleShotMissile",killTime=0,displayname="Stand Aside",mcollision=false},
	["DravenRCast"]={charName="Draven",slot=3,type="Line",delay=0.5,range=25000,radius=160,speed=2000,addHitbox=true,danger=5,dangerous=true,proj="DravenR",killTime=0,displayname="Whirling Death",mcollision=false},
	["EkkoQ"]={charName="Ekko",slot=0,type="Line",delay=0.25,range=925,radius=60,speed=1650,addHitbox=true,danger=4,dangerous=true,proj="ekkoqmis",killTime=0,displayname="Timewinder",mcollision=false},
	["EkkoW"]={charName="Ekko",slot=1,type="Circle",delay=3.75,range=1600,radius=375,speed=1650,addHitbox=false,danger=3,dangerous=false,proj="EkkoW",killTime=1.2,displayname="Parallel Convergence",mcollision=false},
	["EkkoR"]={charName="Ekko",slot=3,type="Circle",delay=0.25,range=1600,radius=375,speed=1650,addHitbox=true,danger=3,dangerous=false,proj="EkkoR",killTime=0.2,displayname="Chronobreak",mcollision=false},
	["EliseHumanE"]={charName="Elise",slot=2,type="Line",delay=0.25,range=925,radius=55,speed=1600,addHitbox=true,danger=4,dangerous=true,proj="EliseHumanE",killTime=0,displayname="Cocoon",mcollision=true},
	["EvelynnR"]={charName="Evelynn",slot=3,type="Circle",delay=0.25,range=650,radius=350,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="EvelynnR",killTime=0.2,displayname="Agony's Embrace"},
	["EzrealMysticShot"]={charName="Ezreal",slot=0,type="Line",delay=0.25,range=1300,radius=50,speed=1975,addHitbox=true,danger=2,dangerous=false,proj="EzrealMysticShotMissile",killTime=0,displayname="Mystic Shot",mcollision=true},
	["EzrealEssenceFlux"]={charName="Ezreal",slot=1,type="Line",delay=0.25,range=1000,radius=80,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="EzrealEssenceFluxMissile",killTime=0,displayname="Essence Flux",mcollision=false},
	["EzrealTrueshotBarrage"]={charName="Ezreal",slot=3,type="Line",delay=1,range=20000,radius=150,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="EzrealTrueshotBarrage",killTime=0,displayname="Trueshot Barrage",mcollision=false},
	["FioraW"]={charName="Fiora",slot=1,type="Line",delay=0.5,range=800,radius=70,speed=3200,addHitbox=true,danger=2,dangerous=false,proj="FioraWMissile",killTime=0,displayname="Riposte",mcollision=false},
	["FizzMarinerDoom"]={charName="Fizz",slot=3,type="Line",delay=0.25,range=1150,radius=120,speed=1350,addHitbox=true,danger=5,dangerous=true,proj="FizzMarinerDoomMissile",killTime=0,displayname="Chum the Waters",mcollision=false},
	["FizzMarinerDoomMissile"]={charName="Fizz",slot=3,type="Circle",delay=0.25,range=800,radius=300,speed=1350,addHitbox=true,danger=5,dangerous=true,proj="FizzMarinerDoomMissile",killTime=0,displayname="Chum the Waters End",mcollision=false},
	["GalioResoluteSmite"]={charName="Galio",slot=0,type="Circle",delay=0.25,range=900,radius=200,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="GalioResoluteSmite",killTime=0.2,displayname="Resolute Smite",mcollision=false},
	["GalioRighteousGust"]={charName="Galio",slot=2,type="Line",delay=0.25,range=1100,radius=120,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="GalioRighteousGust",killTime=0,displayname="Righteous Ghost",mcollision=false},
	["GalioIdolOfDurand"]={charName="Galio",slot=3,type="Circle",delay=0.25,range=0,radius=550,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=1,displayname="Idol of Durand",mcollision=false},
	["GnarQ"]={charName="Gnar",slot=0,type="Line",delay=0.25,range=1200,radius=60,speed=1225,addHitbox=true,danger=2,dangerous=false,proj="gnarqmissile",killTime=0,displayname="Boomerang Throw",mcollision=false},
	["GnarQReturn"]={charName="Gnar",slot=0,type="Line",delay=0,range=1200,radius=75,speed=1225,addHitbox=true,danger=2,dangerous=false,proj="GnarQMissileReturn",killTime=0,displayname="Boomerang Throw2",mcollision=false},
	["GnarBigQ"]={charName="Gnar",slot=0,type="Line",delay=0.5,range=1150,radius=90,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="GnarBigQMissile",killTime=0,displayname="Boulder Toss",mcollision=true},
	["GnarBigW"]={charName="Gnar",slot=1,type="Line",delay=0.6,range=600,radius=80,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GnarBigW",killTime=0,displayname="Wallop",mcollision=false},
	["GnarE"]={charName="Gnar",slot=2,type="Circle",delay=0,range=473,radius=150,speed=903,addHitbox=true,danger=2,dangerous=false,proj="GnarE",killTime=0.2,displayname="GnarE",mcollision=false},
	["GnarBigE"]={charName="Gnar",slot=2,type="Circle",delay=0.25,range=475,radius=200,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="GnarBigE",killTime=0.2,displayname="GnarBigE",mcollision=false},
	["GnarR"]={charName="Gnar",slot=3,type="Circle",delay=0.25,range=0,radius=500,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=0.3,displayname="GnarUlt",mcollision=false},
	["GragasQ"]={charName="Gragas",slot=0,type="Circle",delay=0.25,range=1100,radius=275,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="GragasQMissile",killTime=4.25,displayname="Barrel Roll",mcollision=false,killName="GragasQToggle"},
	["GragasE"]={charName="Gragas",slot=2,type="Line",delay=0,range=800,radius=200,speed=800,addHitbox=true,danger=2,dangerous=false,proj="GragasE",killTime=0.5,displayname="Body Slam",mcollision=true},
	["GragasR"]={charName="Gragas",slot=3,type="Circle",delay=0.25,range=1050,radius=375,speed=1800,addHitbox=true,danger=5,dangerous=true,proj="GragasRBoom",killTime=0.3,displayname="Explosive Cask",mcollision=false},
	["GravesBasicAttack"]={charName="Graves",slot=-2,type="Cone",delay=0.2,range=750,radius=140,speed=math.huge,angle=45,addHitbox=true,danger=1,dangerous=false,proj="GravesBasicAttackSpread",killTime=1,displayname="Auto Attack",mcollision=false},
	["GravesQLineMis"]={charName="Graves",slot=0,type="Rectangle",delay=0.2,range=750,radius=140,radius2=300,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GravesQLineMis",killTime=1,displayname="Buckshot Rectangle",mcollision=false},
	["GravesClusterShotSoundMissile"]={charName="Graves",slot=0,type="Line",delay=0.2,range=750,radius=60,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0,displayname="Buckshot",mcollision=false},
	["GravesQReturn"]={charName="Graves",slot=0,type="Line",delay=0,range=750,radius=60,speed=1150,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0,displayname="Buckshot return",mcollision=false},
	["GravesSmokeGrenade"]={charName="Graves",slot=1,type="Circle",delay=0.25,range=925,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GravesSmokeGrenadeBoom",killTime=4.5,displayname="SmokeScreen",mcollision=false},
	["GravesChargeShot"]={charName="Graves",slot=3,type="Line",delay=0.2,range=1000,radius=100,speed=2100,addHitbox=true,danger=5,dangerous=true,proj="GravesChargeShotShot",killTime=0,displayname="CollateralDmg",mcollision=false},
	["GravesChargeShotFxMissile"]={charName="Graves",slot=3,type="Cone",delay=0,range=1000,radius=100,speed=2100,angle=60,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0,displayname="CollateralDmg end",mcollision=false},
	["HecarimUlt"]={charName="Hecarim",slot=3,type="Line",delay=0.2,range=1100,radius=300,speed=1200,addHitbox=true,danger=5,dangerous=true,proj="HecarimUltMissile",killTime=0.55,displayname="HecarimR",mcollision=false},
	["HeimerdingerTurretEnergyBlast"]={charName="Heimerdinger",slot=0,type="Line",delay=0.4,range=1000,radius=70,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="HeimerdingerTurretEnergyBlast",killTime=0,displayname="Turret",mcollision=false},
	["HeimerdingerW"]={charName="Heimerdinger",slot=1,type="Cone",delay=0.25,range=800,radius=70,speed=1800,angle=10,addHitbox=true,danger=2,dangerous=false,proj="HeimerdingerWAttack2",killTime=0,displayname="HeimerUltW",mcollision=true},
	["HeimerdingerE"]={charName="Heimerdinger",slot=2,type="Circle",delay=0.25,range=925,radius=100,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="heimerdingerespell",killTime=0.3,displayname="HeimerdingerE",mcollision=false},
	["IllaoiQ"]={charName="Illaoi",slot=0,type="Line",delay=0.75,range=750,radius=160,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="illaoiemis",killTime=0,displayname="",mcollision=false},
	["IllaoiE"]={charName="Illaoi",slot=2,type="Line",delay=0.25,range=1100,radius=50,speed=1900,addHitbox=true,danger=3,dangerous=true,proj="illaoiemis",killTime=0,displayname="",mcollision=true},
	["IllaoiR"]={charName="Illaoi",slot=3,type="Circle",delay=0.5,range=0,radius=450,speed=math.huge,addHitbox=false,danger=3,dangerous=true,proj="nil",killTime=0.2,displayname="",mcollision=false},
	["IreliaTranscendentBlades"]={charName="Irelia",slot=3,type="Line",delay=0,range=1200,radius=65,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="IreliaTranscendentBlades",killTime=0,displayname="Transcendent Blades",mcollision=false},
	["IvernQ"]={charName="Ivern",slot=0,type="Line",delay=0.25,range=1100,radius=65,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="IvernQ",killTime=0,displayname="",mcollision=true},
	["HowlingGaleSpell"]={charName="Janna",slot=0,type="Line",delay=0.25,range=1700,radius=120,speed=800,addHitbox=true,danger=2,dangerous=false,proj="HowlingGaleSpell",killTime=0,displayname="HowlingGale",mcollision=false},
	["JarvanIVDragonStrike"]={charName="JarvanIV",slot=0,type="Line",delay=0.6,range=770,radius=70,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="nil",killTime=0,displayname="DragonStrike",mcollision=false},
	["JarvanIVEQ"]={charName="JarvanIV",slot=0,type="Line",delay=0.25,range=880,radius=70,speed=1450,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="DragonStrike2",mcollision=false},
	["JarvanIVDemacianStandard"]={charName="JarvanIV",slot=2,type="Circle",delay=0.5,range=860,radius=175,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="JarvanIVDemacianStandard",killTime=1.5,displayname="Demacian Standard",mcollision=false},
	["JayceShockBlast"]={charName="Jayce",slot=0,type="Line",delay=0.25,range=1300,radius=70,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="JayceShockBlastMis",killTime=0,displayname="ShockBlast",mcollision=true},
	["JayceShockBlastWallMis"]={charName="Jayce",slot=0,type="Line",delay=0.25,range=1300,radius=70,speed=2350,addHitbox=true,danger=2,dangerous=false,proj="JayceShockBlastWallMis",killTime=0,displayname="ShockBlastCharged",mcollision=true},
	["JhinW"]={charName="Jhin",slot=1,type="Line",delay=0.75,range=2550,radius=40,speed=5000,addHitbox=true,danger=3,dangerous=true,proj="JhinWMissile",killTime=0,displayname="",mcollision=false},
	["JhinRShot"]={charName="Jhin",slot=3,type="Line",delay=0.25,range=3500,radius=80,speed=5000,addHitbox=true,danger=3,dangerous=true,proj="JhinRShotMis",killTime=0,displayname="JhinR",mcollision=false},
	["JinxW"]={charName="Jinx",slot=1,type="Line",delay=0.3,range=1600,radius=60,speed=2500,addHitbox=true,danger=3,dangerous=true,proj="JinxWMissile",killTime=.6,displayname="Zap",mcollision=true},
	["JinxE"]={charName="Jinx",slot=2,type="Rectangle",delay=0.25,range=1600,radius=100,radius2=275,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="JinxEHit",killTime=5,displayname="Zap",mcollision=true},
	["JinxR"]={charName="Jinx",slot=3,type="Line",delay=0.6,range=20000,radius=140,speed=1700,addHitbox=true,danger=5,dangerous=true,proj="JinxR",killTime=0,displayname="Death Rocket",mcollision=false},
	["KalistaMysticShot"]={charName="Kalista",slot=0,type="Line",delay=0.25,range=1200,radius=40,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="kalistamysticshotmis",killTime=0,displayname="MysticShot",mcollision=true},
	["KarmaQ"]={charName="Karma",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KarmaQMissile",killTime=0,displayname="",mcollision=true},
	["KarmaQMantra"]={charName="Karma",slot=0,type="Line",delay=0.25,range=950,radius=80,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KarmaQMissileMantra",killTime=0,displayname="",mcollision=true},
	["KarthusLayWasteA1"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 1",mcollision=false},
	["KarthusLayWasteA2"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 2",mcollision=false},
	["KarthusLayWasteA3"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 3",mcollision=false},
	["KarthusWallOfPain"]={charName="Karthus",slot=2,type="Rectangle",delay=0.25,range=600,radius=160,radius2=500,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=5,displayname="Wall of Pain",mcollision=false},
	["RiftWalk"]={charName="Kassadin",slot=3,type="Circle",delay=0.25,range=450,radius=270,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="RiftWalk",killTime=0.3,displayname="",mcollision=false},
	["KennenShurikenHurlMissile1"]={charName="Kennen",slot=0,type="Line",delay=0.18,range=1050,radius=50,speed=1650,addHitbox=true,danger=2,dangerous=false,proj="KennenShurikenHurlMissile1",killTime=0,displayname="Thundering Shuriken",mcollision=true},
	["KhazixW"]={charName="Khazix",slot=1,type="Line",delay=0.25,range=1025,radius=70,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KhazixWMissile",killTime=0,displayname="",mcollision=true},
	["KledE"]={charName="Kled",slot=0,type="Line",delay=0.25,range=1025,radius=70,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KhazixWMissile",killTime=0,displayname="",mcollision=true},
	["KledQ"]={charName="Kled",slot=2,type="Line",delay=0,range=750,radius=125,speed=945,addHitbox=true,danger=3,dangerous=true,proj="KledE",killTime=0,displayname="",mcollision=true},
	["KhazixE"]={charName="Khazix",slot=2,type="Circle",delay=0.25,range=600,radius=300,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="KhazixE",killTime=0.2,displayname="",mcollision=false},
	["KogMawQ"]={charName="KogMaw",slot=0,type="Line",delay=0.25,range=975,radius=70,speed=1650,addHitbox=true,danger=2,dangerous=false,proj="KogMawQ",killTime=0,displayname="",mcollision=true},
	["KogMawVoidOoze"]={charName="KogMaw",slot=2,type="Line",delay=0.25,range=1200,radius=120,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="KogMawVoidOozeMissile",killTime=0,displayname="Void Ooze",mcollision=false},
	["KogMawLivingArtillery"]={charName="KogMaw",slot=3,type="Circle",delay=0.25,range=1800,radius=225,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="KogMawLivingArtillery",killTime=1,displayname="LivingArtillery",mcollision=false},
	["LeblancSlide"]={charName="Leblanc",slot=1,type="Circle",delay=0,range=600,radius=220,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LeblancSlide",killTime=0.2,displayname="Slide",mcollision=false},
	["LeblancSlideM"]={charName="Leblanc",slot=3,type="Circle",delay=0,range=600,radius=220,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LeblancSlideM",killTime=0.2,displayname="Slide R",mcollision=false},
	["LeblancSoulShackle"]={charName="Leblanc",slot=2,type="Line",delay=0,range=950,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeblancSoulShackle",killTime=0,displayname="Ethereal Chains R",mcollision=true},
	["LeblancSoulShackleM"]={charName="Leblanc",slot=3,type="Line",delay=0,range=950,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeblancSoulShackleM",killTime=0,displayname="Ethereal Chains",mcollision=true},
	["BlindMonkQOne"]={charName="LeeSin",slot=0,type="Line",delay=0.25,range=1000,radius=80,speed=1800,addHitbox=true,danger=3,dangerous=true,proj="BlindMonkQOne",killTime=0,displayname="Sonic Wave",mcollision=true},
	["LeonaZenithBlade"]={charName="Leona",slot=2,type="Line",delay=0.25,range=875,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeonaZenithBladeMissile",killTime=0,displayname="Zenith Blade",mcollision=false},
	["LeonaSolarFlare"]={charName="Leona",slot=3,type="Circle",delay=1,range=1200,radius=300,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="LeonaSolarFlare",killTime=0.5,displayname="Solar Flare",mcollision=false},
	["LissandraQ"]={charName="Lissandra",slot=0,type="Line",delay=0.25,range=700,radius=75,speed=2200,addHitbox=true,danger=2,dangerous=false,proj="LissandraQMissile",killTime=0,displayname="Ice Shard",mcollision=false},
	["LissandraQShards"]={charName="Lissandra",slot=0,type="Line",delay=0.25,range=700,radius=90,speed=2200,addHitbox=true,danger=2,dangerous=false,proj="lissandraqshards",killTime=0,displayname="Ice Shard2",mcollision=false},
	["LissandraE"]={charName="Lissandra",slot=2,type="Line",delay=0.25,range=1025,radius=125,speed=850,addHitbox=true,danger=2,dangerous=false,proj="LissandraEMissile",killTime=0,displayname="",mcollision=false},
	["LucianQ"]={charName="Lucian",slot=0,type="Line",delay=0.5,range=800,radius=65,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="LucianQ",killTime=0,displayname="",mcollision=false},
	["LucianW"]={charName="Lucian",slot=1,type="Line",delay=0.2,range=1000,radius=55,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="lucianwmissile",killTime=0,displayname="",mcollision=true},
	["LucianRMis"]={charName="Lucian",slot=3,type="Line",delay=0.5,range=1400,radius=110,speed=2800,addHitbox=true,danger=2,dangerous=false,proj="lucianrmissileoffhand",killTime=0,displayname="LucianR",mcollision=true},
	["LuluQ"]={charName="Lulu",slot=0,type="Line",delay=0.25,range=950,radius=60,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LuluQMissile",killTime=0,displayname="",mcollision=false},
	["LuluQPix"]={charName="Lulu",slot=0,type="Line",delay=0.25,range=950,radius=60,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LuluQMissileTwo",killTime=0,displayname="",mcollision=false},
	["LuxLightBinding"]={charName="Lux",slot=0,type="Line",delay=0.3,range=1300,radius=70,speed=1200,addHitbox=true,danger=3,dangerous=true,proj="LuxLightBindingMis",killTime=0,displayname="Light Binding",mcollision=true},
	["LuxLightStrikeKugel"]={charName="Lux",slot=2,type="Circle",delay=0.25,range=1100,radius=350,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="LuxLightStrikeKugel",killTime=5.25,displayname="LightStrikeKugel",mcollision=false,killName="LuxLightstrikeToggle"},
	["LuxMaliceCannon"]={charName="Lux",slot=3,type="Line",delay=1.5,range=3500,radius=190,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="LuxMaliceCannon",killTime=2,displayname="Malice Cannon",mcollision=false},
	["UFSlash"]={charName="Malphite",slot=3,type="Circle",delay=0,range=1000,radius=270,speed=1500,addHitbox=true,danger=5,dangerous=true,proj="UFSlash",killTime=0.4,displayname="",mcollision=false},
	["MalzaharQ"]={charName="Malzahar",slot=0,type="Rectangle",delay=0.75,range=900,radius2=475,radius=130,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="MalzaharQMissile",killTime=0.5,displayname="",mcollision=false},
	["DarkBindingMissile"]={charName="Morgana",slot=0,type="Line",delay=0.2,range=1300,radius=80,speed=1200,addHitbox=true,danger=3,dangerous=true,proj="DarkBindingMissile",killTime=0,displayname="Dark Binding",mcollision=true},
	["NamiQ"]={charName="Nami",slot=0,type="Circle",delay=0.95,range=1625,radius=200,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="NamiQMissile",killTime=0.35,displayname="",mcollision=false},
	["NamiR"]={charName="Nami",slot=3,type="Line",delay=0.8,range=2750,radius=260,speed=850,addHitbox=true,danger=2,dangerous=false,proj="NamiRMissile",killTime=0,displayname="",mcollision=false},
	["NautilusAnchorDrag"]={charName="Nautilus",slot=0,type="Line",delay=0.25,range=1080,radius=90,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="NautilusAnchorDragMissile",killTime=0,displayname="Anchor Drag",mcollision=true},
	["AbsoluteZero"]={charName="Nunu",slot=3,type="Circle",delay=0.25,range=0,radius=750,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=4,displayname="",mcollision=false},
	["NocturneDuskbringer"]={charName="Nocturne",slot=0,type="Line",delay=0.25,range=1125,radius=60,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="NocturneDuskbringer",killTime=0,displayname="Duskbringer",mcollision=false},
	["JavelinToss"]={charName="Nidalee",slot=0,type="Line",delay=0.25,range=1500,radius=40,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="JavelinToss",killTime=0,displayname="JavelinToss",mcollision=true},
	["OlafAxeThrowCast"]={charName="Olaf",slot=0,type="Line",delay=0.25,range=1000,radius=105,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="olafaxethrow",killTime=0,displayname="Axe Throw",mcollision=false},
	["OriannaIzunaCommand"]={charName="Orianna",slot=0,type="Line",delay=0,range=1500,radius=80,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="orianaizuna",killTime=0,displayname="",mcollision=false},
	["OrianaDissonanceCommand-"]={charName="Orianna",slot=1,type="Circle",delay=0.25,range=0,radius=255,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="OrianaDissonanceCommand-",killTime=0.3,displayname="",mcollision=false},
	["OriannasE"]={charName="Orianna",slot=2,type="Line",delay=0,range=1500,radius=85,speed=1850,addHitbox=true,danger=2,dangerous=false,proj="orianaredact",killTime=0,displayname="",mcollision=false},
	["OrianaDetonateCommand-"]={charName="Orianna",slot=3,type="Circle",delay=0.7,range=0,radius=410,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="OrianaDetonateCommand-",killTime=0.5,displayname="",mcollision=false},
	["QuinnQ"]={charName="Quinn",slot=0,type="Line",delay=0,range=1050,radius=60,speed=1550,addHitbox=true,danger=2,dangerous=false,proj="QuinnQ",killTime=0,displayname="",mcollision=true},
	["PoppyQ"]={charName="Poppy",slot=0,type="Line",delay=0.5,range=430,radius=120,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="PoppyQ",killTime=1,displayname="",mcollision=false},
	["PoppyRSpell"]={charName="Poppy",slot=3,type="Line",delay=0.3,range=1200,radius=100,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="PoppyRMissile",killTime=0,displayname="PoppyR",mcollision=false},
	["RengarE"]={charName="Rengar",slot=2,type="Line",delay=0.25,range=1000,radius=70,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="RengarEFinal",killTime=0,displayname="",mcollision=true},
	["reksaiqburrowed"]={charName="RekSai",slot=0,type="Line",delay=0.5,range=1050,radius=60,speed=1550,addHitbox=true,danger=3,dangerous=false,proj="RekSaiQBurrowedMis",killTime=0,displayname="RekSaiQ",mcollision=true},
	["RivenWindslashMissileRight"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Right",mcollision=false},
	["RivenWindslashMissileCenter"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Center",mcollision=false},
	["RivenWindslashMissileLeft"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Left",mcollision=false},
	-- ["RivenMartyr"]={charName="Riven",slot=1,type="Circle",delay=0.25,range=0,radius=300,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=0.2,displayname="RivenW",mcollision=false},
	["RumbleGrenade"]={charName="Rumble",slot=2,type="Line",delay=0.25,range=850,radius=60,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="RumbleGrenade",killTime=0,displayname="Grenade",mcollision=true},
	["RumbleCarpetBombM"]={charName="Rumble",slot=3,type="Line",delay=0.4,range=1700,radius=200,speed=1600,addHitbox=true,danger=4,dangerous=false,proj="RumbleCarpetBombMissile",killTime=0,displayname="Carpet Bomb",mcollision=false}, --doesnt work
	["RyzeQ"]={charName="Ryze",slot=0,type="Line",delay=0,range=900,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="RyzeQ",killTime=0,displayname="",mcollision=true},
	["ryzerq"]={charName="Ryze",slot=0,type="Line",delay=0,range=900,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ryzerq",killTime=0,displayname="RyzeQ R",mcollision=true},
	["SejuaniArcticAssault"]={charName="Sejuani",slot=0,type="Line",delay=0,range=900,radius=70,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="ArcticAssault",mcollision=true},
	["SejuaniGlacialPrisonStart"]={charName="Sejuani",slot=3,type="Line",delay=0.25,range=1200,radius=110,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="sejuaniglacialprison",killTime=0,displayname="GlacialPrisonStart",mcollision=false},
	["SionE"]={charName="Sion",slot=2,type="Line",delay=0.25,range=800,radius=80,speed=1800,addHitbox=true,danger=3,dangerous=true,proj="SionEMissile",killTime=0,displayname="",mcollision=false},
	["SionR"]={charName="Sion",slot=3,type="Line",delay=0.5,range=20000,radius=120,speed=1000,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="",mcollision=false},
	["SorakaQ"]={charName="Soraka",slot=0,type="Circle",delay=0,range=950,radius=300,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.75,displayname="",mcollision=false},
	["SorakaE"]={charName="Soraka",slot=2,type="Circle",delay=0,range=925,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=2,displayname="",mcollision=false},
	["ShenE"]={charName="Shen",slot=2,type="Line",delay=0,range=650,radius=50,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="ShenE",killTime=0,displayname="Shadow Dash",mcollision=false},
	["ShyvanaFireball"]={charName="Shyvana",slot=2,type="Line",delay=0.25,range=925,radius=60,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ShyvanaFireballMissile",killTime=0,displayname="Fireball",mcollision=false},
	["ShyvanaTransformCast"]={charName="Shyvana",slot=3,type="Line",delay=0.25,range=750,radius=150,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="ShyvanaTransformCast",killTime=0,displayname="Transform Cast",mcollision=false},
	["shyvanafireballdragon2"]={charName="Shyvana",slot=3,type="Line",delay=0.25,range=925,radius=70,speed=2000,addHitbox=true,danger=3,dangerous=false,proj="ShyvanaFireballDragonFxMissile",killTime=0,displayname="Fireball Dragon",mcollision=false},
	["SivirQMissileReturn"]={charName="Sivir",slot=0,type="Return",delay=0,range=1075,radius=100,speed=1350,addHitbox=true,danger=2,dangerous=false,proj="SivirQMissileReturn",killTime=0,displayname="SivirQ2",mcollision=false},
	["SivirQ"]={charName="Sivir",slot=0,type="Line",delay=0.25,range=1075,radius=90,speed=1350,addHitbox=true,danger=2,dangerous=false,proj="SivirQMissile",killTime=0,displayname="SivirQ",mcollision=false},
	["SkarnerFracture"]={charName="Skarner",slot=2,type="Line",delay=0.35,range=350,radius=70,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="SkarnerFractureMissile",killTime=0,displayname="Fracture",mcollision=false},
	["SonaR"]={charName="Sona",slot=3,type="Line",delay=0.25,range=900,radius=140,speed=2400,addHitbox=true,danger=5,dangerous=true,proj="SonaR",killTime=0,displayname="Crescendo",mcollision=false},
	["SwainShadowGrasp"]={charName="Swain",slot=1,type="Circle",delay=0.25,range=900,radius=180,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="SwainShadowGrasp",killTime=1.5,displayname="Shadow Grasp",mcollision=false},
	["SyndraQ"]={charName="Syndra",slot=0,type="Circle",delay=0.6,range=800,radius=150,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="SyndraQSpell",killTime=0.2,displayname="",mcollision=false},
	["SyndraWCast"]={charName="Syndra",slot=1,type="Circle",delay=0.25,range=950,radius=210,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="syndrawcast",killTime=0.2,displayname="SyndraW",mcollision=false},
	["SyndraE"]={charName="Syndra",slot=2,type="Cone",delay=0,range=950,radius=100,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="SyndraE",killTime=0,displayname="SyndraE",mcollision=false},
	["syndrae5"]={charName="Syndra",slot=2,type="Line",delay=0,range=950,radius=100,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="syndrae5",killTime=0,displayname="SyndraE2",mcollision=false},
	["TalonRake"]={charName="Talon",slot=1,type="Cone",delay=0.25,range=800,radius=80,speed=2300,angle=45,addHitbox=true,danger=2,dangerous=true,proj="talonrakemissileone",killTime=0,displayname="Rake",mcollision=false},
	["TalonRakeMissileTwo"]={charName="Talon",slot=1,type="Cone",delay=0.25,range=800,radius=80,speed=1850,angle=45,addHitbox=true,danger=2,dangerous=true,proj="talonrakemissiletwo",killTime=0,displayname="Rake2",mcollision=false},
	["TahmKenchQ"]={charName="TahmKench",slot=0,type="Line",delay=0.25,range=951,radius=90,speed=2800,addHitbox=true,danger=3,dangerous=true,proj="tahmkenchqmissile",killTime=0,displayname="Tongue Slash",mcollision=true},
	["TaricE"]={charName="Taric",slot=2,type="follow",delay=0.25,range=750,radius=100,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="TaricE",killTime=1.25,displayname="",mcollision=false},
	["ThreshQ"]={charName="Thresh",slot=0,type="Line",delay=0.5,range=1050,radius=70,speed=1900,addHitbox=true,danger=3,dangerous=true,proj="ThreshQMissile",killTime=0,displayname="",mcollision=true},
	["ThreshEFlay"]={charName="Thresh",slot=2,type="Line",delay=0.125,range=500,radius=110,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="ThreshEMissile1",killTime=0,displayname="Flay",mcollision=false},
	["RocketJump"]={charName="Tristana",slot=1,type="Circle",delay=0.5,range=900,radius=270,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="RocketJump",killTime=0.3,displayname="",mcollision=false},
	["TryndamereE"]={charName="Tryndamere",slot=2,type="Line",delay=0,range=700,radius=93,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="Slash",killTime=0.5,displayname="",mcollision=false},
	["WildCards"]={charName="TwistedFate",slot=0,type="Line",delay=0.25,range=1450,radius=40,speed=1000,angle=28,addHitbox=true,danger=2,dangerous=false,proj="SealFateMissile",killTime=0,displayname="",mcollision=false},
	["TwitchVenomCask"]={charName="Twitch",slot=1,type="Circle",delay=0.25,range=900,radius=275,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="TwitchVenomCaskMissile",killTime=0.3,displayname="Venom Cask",mcollision=false},
	["TwitchSprayAndPrayAttack"]={charName="Twitch",slot=3,type="Line",delay=0.1,range=1200,radius=100,speed=1800,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.5,displayname="Venom Cask",mcollision=false},
	["UrgotHeatseekingLineMissile"]={charName="Urgot",slot=0,type="Line",delay=0.125,range=1000,radius=60,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="UrgotHeatseekingLineMissile",killTime=0,displayname="Heatseeking Line",mcollision=true},
	["UrgotPlasmaGrenade"]={charName="Urgot",slot=2,type="Circle",delay=0.25,range=1100,radius=210,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="UrgotPlasmaGrenadeBoom",killTime=0.3,displayname="PlasmaGrenade",mcollision=false},
	["VarusQMissile"]={charName="Varus",slot=0,type="Line",delay=0.25,range=1475,radius=70,speed=1900,addHitbox=true,danger=2,dangerous=false,proj="VarusQMissile",killTime=0,displayname="VarusQ",mcollision=false},
	["VarusE"]={charName="Varus",slot=2,type="Circle",delay=0.25,range=925,radius=235,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VarusE",killTime=2.25,displayname="",mcollision=false},
	["VarusR"]={charName="Varus",slot=3,type="Line",delay=0.25,range=800,radius=120,speed=1950,addHitbox=true,danger=3,dangerous=true,proj="VarusRMissile",killTime=0,displayname="",mcollision=false},
	["VeigarBalefulStrike"]={charName="Veigar",slot=0,type="Line",delay=0.1,range=900,radius=70,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VeigarBalefulStrikeMis",killTime=0,displayname="BalefulStrike",mcollision=false},
	["VeigarDarkMatter"]={charName="Veigar",slot=1,type="Circle",delay=1.35,range=900,radius=225,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.5,displayname="DarkMatter",mcollision=false},
	["VeigarEventHorizon"]={charName="Veigar",slot=2,type="Ring",delay=0.5,range=700,radius=400,speed=math.huge,addHitbox=false,danger=3,dangerous=true,proj="nil",killTime=3.5,displayname="EventHorizon",mcollision=false},
	["VelkozQ"]={charName="Velkoz",slot=0,type="Line",delay=0.25,range=1100,radius=50,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="VelkozQMissile",killTime=0,displayname="",mcollision=true},
	["VelkozQMissileSplit"]={charName="Velkoz",slot=0,type="Line",delay=0.25,range=1100,radius=55,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="VelkozQMissileSplit",killTime=0,displayname="",mcollision=true},
	["VelkozW"]={charName="Velkoz",slot=1,type="Line",delay=0.25,range=1050,radius=88,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="VelkozWMissile",killTime=0,displayname="",mcollision=false},
	["VelkozE"]={charName="Velkoz",slot=2,type="Circle",delay=0.5,range=800,radius=225,speed=1500,addHitbox=false,danger=2,dangerous=false,proj="VelkozEMissile",killTime=0.5,displayname="",mcollision=false},
	["Vi-q"]={charName="Vi",slot=0,type="Line",delay=0.25,range=715,radius=90,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="ViQMissile",killTime=0,displayname="Vi-Q",mcollision=false},
	["VladimirR"] = {charName = "Vladimir",slot=3,type="Circle",delay=0.25,range=700,radius=175,speed=math.huge,addHitbox=true,danger=4,dangerous=true,proj="nil",killTime=0,displayname = "Hemoplague",mcollision=false},
	["Laser"]={charName="Viktor",slot=2,type="Line",delay=0.25,range=1200,radius=80,speed=1050,addHitbox=true,danger=2,dangerous=false,proj="ViktorDeathRayMissile",killTime=0,displayname="",mcollision=false},
	["XerathArcanopulse2"]={charName="Xerath",slot=0,type="Line",delay=0.6,range=1600,radius=95,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="xeratharcanopulse2",killTime=0.5,displayname="Arcanopulse",mcollision=false},
	["XerathArcaneBarrage2"]={charName="Xerath",slot=1,type="Circle",delay=0.7,range=1000,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="XerathArcaneBarrage2",killTime=0.3,displayname="ArcaneBarrage",mcollision=false},
	["XerathMageSpear"]={charName="Xerath",slot=2,type="Line",delay=0.2,range=1300,radius=60,speed=1400,addHitbox=true,danger=2,dangerous=true,proj="XerathMageSpearMissile",killTime=0,displayname="MageSpear",mcollision=true},
	["XerathLocusPulse"]={charName="Xerath",slot=3,type="Circle",delay=0.7,range=5600,radius=225,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="XerathRMissileWrapper",killTime=0.4,displayname="",mcollision=false},
	["YasuoQ3W"]={charName="Yasuo",slot=0,type="Line",delay=0.4,range=1200,radius=90,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="YasuoQ3",killTime=0,displayname="Steel Tempest ",mcollision=false},
	["ZacQ"]={charName="Zac",slot=0,type="Line",delay=0.5,range=550,radius=120,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZacQ",killTime=0,displayname="",mcollision=false},
	["ZedQ"]={charName="Zed",slot=0,type="Line",delay=0.25,range=925,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ZedQMissile",killTime=0,displayname="",mcollision=false},
	["ZiggsQSpell"]={charName="Ziggs",slot=0,type="Circle",delay=0.5,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell",killTime=0.2,displayname="",mcollision=false},
	["ZiggsQSpell2"]={charName="Ziggs",slot=0,type="Circle",delay=0.47,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell2",killTime=-0.23,displayname="",mcollision=true},
	["ZiggsQSpell3"]={charName="Ziggs",slot=0,type="Circle",delay=0.44,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell3",killTime=-0.26,displayname="",mcollision=true},
	["ZiggsW"]={charName="Ziggs",slot=1,type="Circle",delay=0.25,range=1000,radius=275,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsW",killTime=4.1,displayname="",mcollision=false,killName="ZiggsWToggle"},
	["ZiggsE"]={charName="Ziggs",slot=2,type="Circle",delay=0.5,range=900,radius=250,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsE",killTime=10,displayname="",mcollision=false},
	["ZiggsR"]={charName="Ziggs",slot=3,type="Circle",delay=0,range=5300,radius=500,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZiggsR",killTime=1.25,displayname="",mcollision=false},
	["ZileanQ"]={charName="Zilean",slot=0,type="Circle",delay=0.3,range=900,radius=210,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="ZileanQMissile",killTime=1.5,displayname="",mcollision=false},
	["ZyraQ"]={charName="Zyra",slot=0,type="Rectangle",delay=0.4,range=800,radius2=400,radius=140,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZyraQ",killTime=0.35,displayname="",mcollision=false},
	["ZyraE"]={charName="Zyra",slot=2,type="Line",delay=0.25,range=1100,radius=70,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="ZyraE",killTime=0,displayname="Grasping Roots",mcollision=false},
	--["ZyraRSplash"]={charName="Zyra",slot=3,type="Circle",delay=0.7,range=700,radius=550,speed=math.huge,addHitbox=true,danger=4,dangerous=false,proj="ZyraRSplash",killTime=1,displayname="Splash",mcollision=false},--bugged spell
}
	
	BM.SB:Menu("Spells", "Spells")
	BM.SB:Boolean("uS","Enable",true)
	BM.SB:Slider("dV","Danger Value",2,1,5,1)
	BM.SB:Slider("hV","Humanize Value",50,0,100,1)
	BM.SB:Boolean("EC","Enable Collision", true)
	BM.SB:KeyBinding("DoD", "DodgeOnlyDangerous", string.byte(" "))
	BM.SB:KeyBinding("DoD2", "DodgeOnlyDangerous2", string.byte("V"))
	self.object = {}
	self.DoD = false
	self.fT = .75
	self.dt = nil
    DelayAction(function()
		for l,k in pairs(GetEnemyHeroes()) do
			for _,i in pairs(self.s) do
				if not self.s[_] then return end
				if i.charName == k.charName then
					if i.displayname == "" then i.displayname = _ end
					if i.danger == 0 then i.danger = 1 end
					if not BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname] then BM.SB.Spells:Menu(i.charName..""..self.str[i.slot]..""..i.displayname,""..k.charName.." | "..(self.str[i.slot] or "?").." - "..i.displayname) end
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("Dodge"..i.charName..""..self.str[i.slot]..""..i.displayname, "Enable Dodge", true)
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("IsD"..i.charName..""..self.str[i.slot]..""..i.displayname,"Dangerous", i.dangerous or false)		
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Info("Empty12"..i.charName..""..self.str[i.slot]..""..i.displayname, "")
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("radius"..i.charName..""..self.str[i.slot]..""..i.displayname,"Radius",(i.radius or 150), ((i.radius-50) or 50),((i.radius+100) or 250), 5)
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("d"..i.charName..""..self.str[i.slot]..""..i.displayname,"Danger",(i.danger or 1), 1, 5, 1)	
				end
			end
		end
    end, .001)
	Callback.Add("Tick", function() self:Ti() end)
	Callback.Add("ProcessSpell", function(unit, spellProc) self:Detect(unit,spellProc) end)
	Callback.Add("CreateObj", function(obj) self:CreateObj(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteObj(obj) end)
end

function HitMe:Ti()
	if BM.SB.uS:Value() then
		heroes[myHero.networkID] = nil
		for _,i in pairs(self.object) do
			if i.o and i.spell.type == "linear" and GetDistance(myHero,i.o) >= 3000 then return end
			if i and i.spell.type == "circular" and GetDistance(myHero,i.endPos) >= 3000 then return end
			i.spell.speed = i.spell.speed or math.huge
			i.spell.range = i.spell.range or math.huge
			i.spell.proj = i.spell.proj or _
			i.spell.delay = i.spell.delay or 0
			i.spell.radius = i.spell.radius or 100	
			i.spell.mcollision = i.spell.mcollision or false
			i.spell.danger = i.spell.danger or 2
			i.spell.type = i.spell.type or nil
			self.fT = BM.SB.hV:Value()
			self.YasuoWall = {}
			self:MinionCollision(_,i)
			self:HeroCollsion(_,i)
			self:WallCollision(_,i)
			if BM.SB.DoD:Value() or BM.SB.DoD2:Value() then
					self.DoD = true
				else
					self.DoD = false
			end
			for kk,k in pairs(GetEnemyHeroes()) do
				if i.o and not i.o.valid then
					self.object[_] = nil
				end
				if i then
					self.dT = i.spell.delay + GetDistance(myHero,i.startPos) / i.spell.speed
				end
				if ((not self.DoD and BM.SB.dV:Value() <= BM.SB.Spells[i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]["d"..i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]:Value()) or (self.DoD and BM.SB.Spells[i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]["IsD"..i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]:Value())) and BM.SB.Spells[i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]["Dodge"..i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]:Value() then
					if (i.spell.type == "Line" or i.spell.type == "Cone") and i then
							i.startPos = Vector(i.startPos)
							i.endPos = Vector(i.endPos)
						if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero.pos)
							local v4 = Vector(i.startPos-i.endPos):perpendicular()
							local jp = Vector(VectorIntersection(i.startPos,i.endPos,v3,v4).x,myHero.pos.y,VectorIntersection(i.startPos,i.endPos,v3,v4).y)
							i.jp = jp
							if i.coll then return end
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					elseif i.spell.type == "Circle" then
						if GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
						end
					elseif i.spell.type == "Rectangle" then
						local startp = Vector(i.endPos) - (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
						local endp = Vector(i.endPos) + (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
						if GetDistance(startp) < i.spell.range + myHero.boundingRadius and GetDistance(endp) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero.pos)
							local v4 = Vector(startp-endp):normalized():perpendicular()
							local jp = Vector(VectorIntersection(startp,endp,v3,v4).x,myHero.pos.y,VectorIntersection(startp,endp,v3,v4).y)
							i.jp = jp
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					elseif i.spell.type == "Return" then
							i.startPos = Vector(i.p.startPos)
							i.endPos = Vector(i.caster.pos)
						if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero)
							local jp = VectorPointProjectionOnLineSegment(Vector(i.o.pos),i.endPos,v3)
							i.jp = jp	
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					elseif i.spell.type == "follow" then
							i.startPos = Vector(i.caster.pos)
							i.endPos = Vector(i.endPos)
						if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero)
							local v4 = Vector(i.caster.pos) + i.TarE
							local jp = VectorPointProjectionOnLineSegment(i.startPos,v4,v3)
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					end
				end
			end
		end
	end
end

function HitMe:MinionCollision(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i.p and BM.SB.EC:Value() and not i.hcoll and not i.wcoll then
		for m,p in pairs(SLM2) do
			if p and p.alive and GetDistance(p.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.pos))
				if i.vP and GetDistance(i.vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,self.vP)
					i.mcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function HitMe:HeroCollsion(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i.p and BM.SB.EC:Value() and not i.mcoll and not i.wcoll then
		for m,p in pairs(heroes) do
			if p and p.alive and p.team == MINION_ALLY and GetDistance(p.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.pos))
				if i.vP and GetDistance(i.vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,i.vP)
					i.hcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function HitMe:WallCollision(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i.p and BM.SB.EC:Value()  and not i.mcoll and not i.hcoll then
		for m,p in pairs(self.YasuoWall) do
			if p.obj and p.obj.valid and p.obj.spellOwner.team == MINION_ALLY and GetDistance(p.obj.pos,i.p.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,Vector(p.obj.pos))
				if i.vP and GetDistance(i.vP,p.obj.pos) < (i.spell.radius+p.obj.boundingRadius) then
					i.spell.range = GetDistance(i.p.startPos,i.vP)
					i.wcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function HitMe:CreateObj(obj)
	if obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == MINION_ENEMY then
		for _,l in pairs(self.s) do
			if obj.spellName:lower():find("attack") then return end
			if not self.object[l.charName..""..self.str[l.slot]..""..l.displayname] and self.s[_] and BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname] and BM.SB.dV:Value() <= BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname]["d"..l.charName..""..self.str[l.slot]..""..l.displayname]:Value() and (l.proj == obj.spellName or _ == obj.spellName or obj.spellName:lower():find(_:lower()) or obj.spellName:lower():find(l.proj:lower())) then
				if l.type == ("Line" or "Cone") then 
					endPos = Vector(obj.startPos)+Vector(Vector(obj.endPos)-obj.startPos):normalized()*l.range
				else
					endPos = Vector(obj.endPos)
				end			
				self.object[l.charName..""..self.str[l.slot]..""..l.displayname] = {
				o = obj,
				startPos = Vector(obj.startPos),
				endPos = endPos,
				caster = obj.spellOwner.charName,
				startTime = os.clock(),
				spell = l,
				coll = false,
				range = l.range,
				}
			end
		end
	end
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		if not self.YasuoWall[obj.spellName] then self.YasuoWall[obj.spellName] = {} end
		self.YasuoWall[obj.spellName].obj = obj
	end
end

function HitMe:Detect(unit,spellProc)
	if unit and unit.isHero and unit.team == MINION_ENEMY then
		for _,l in pairs(self.s) do
			if not self.object[l.charName..""..self.str[l.slot]..""..l.displayname] and self.s[_] and BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname] and BM.SB.dV:Value() <= BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname]["d"..l.charName..""..self.str[l.slot]..""..l.displayname]:Value() and (l.proj == spellProc.name or _ == spellProc.name or spellProc.name:lower():find(_:lower()) or spellProc.name:lower():find(l.proj:lower())) then
				if l.type == ("Line" or "Cone") then 
					endPos = Vector(spellProc.startPos)+Vector(Vector(spellProc.endPos)-spellProc.startPos):normalized()*l.range
				else
					endPos = Vector(spellProc.endPos)
				end
				self.object[spellProc.name] = {
				startPos = Vector(spellProc.startPos),
				endPos = endPos,
				spell = l,
				caster = unit,
				startTime = os.clock(),
				coll = false,
				TarE = (Vector(spellProc.endPos) - Vector(unit.pos)):normalized()*l.range,
				range = l.range,
				}
				DelayAction(function() self.object[spellProc.name] = nil end, l.delay*.001 + 1.3*GetDistance(myHero.pos,spellProc.startPos)/l.speed)				
			end
		end
		for _,l in pairs(self.s) do
			if spellProc.target and spellProc.target == myHero and not spellProc.name:lower():find("attack") and BM.SB.uS:Value() then
				_G[ChampName]:HitMe(unit,spellProc,((l.delay or 0) + GetDistance(myHero,spellProc.startPos) / (l.speed or math.huge))*BM.SB.hV:Value()*.001,l.type)
			end
		end
	end
end

function HitMe:DeleteObj(obj)
	if obj and obj.isSpell and self.object[obj.spellName] then
			self.object[obj.spellName] = nil
	end	
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		self.YasuoWall[obj.spellName] = nil
	end
end

class 'Humanizer'

function Humanizer:__init()

self.bCount = 0
self.bCount1 = 0
self.lastCommand = 0
self.lastspell = 0

	SLU:SubMenu("Hum", "Humanizer")
	SLU.Hum:Boolean("Draw", "Draw blocked movements", true)
	SLU.Hum:Boolean("Draw1", "Draw blocked spells", true)
	SLU.Hum:Boolean("enable", "Use Movement Limiter", true)
	SLU.Hum:Boolean("enable1", "Use SpellCast Limiter", true)
	SLU.Hum:Slider("Horizontal", "Horizontal (Drawings)", 0, 0, GetResolution().x, 10)
	SLU.Hum:Slider("Vertical", "Vertical (Drawings)", 0, 0, GetResolution().y, 10)
	SLU.Hum:Menu("ML", "Movement Limiter")
	SLU.Hum.ML:Slider("lhit", "Max. Movements in Last Hit", 6, 1, 20, 1)
	SLU.Hum.ML:Slider("lclear", "Max. Movements in Lane Clear", 6, 1, 20, 1)
	SLU.Hum.ML:Slider("harass", "Max. Movements in Harass", 7, 1, 20, 1)
	SLU.Hum.ML:Slider("combo", "Max. Movements in Combo", 8, 1, 20, 1)
	SLU.Hum.ML:Slider("perm", "Persistant Max. Movements", 7, 1, 20, 1)
	SLU.Hum:Menu("SPC", "SpellCast Limiter")
	SLU.Hum.SPC:Slider("blhit", "Max. Spells in LastHit", 1, 1, 8, 1)
	SLU.Hum.SPC:Slider("blclear", "Max. Spells in LaneClear", 1, 1, 8, 1)
	SLU.Hum.SPC:Slider("bharass", "Max. Spells in Harass", 2, 1, 8, 1)
	SLU.Hum.SPC:Slider("bcombo", "Max. Spells in Combo", 3, 1, 8, 1)
	SLU.Hum.SPC:Slider("bperm", "Persistant Max. Spells", 2, 1, 8, 1)
	
 Callback.Add("IssueOrder", function(order) self:IssueOrder(order) end)
 Callback.Add("SpellCast", function(spell) self:SpellCast(spell) end)
 Callback.Add("Draw", function() self:Draw() end)
end

function Humanizer:moveEvery()
	if Mode == "Combo" then
		return 1 / SLU.Hum.ML.combo:Value()
	elseif Mode == "LastHit" then
		return 1 / SLU.Hum.ML.lhit:Value()
	elseif Mode == "Harass" then
		return 1 / SLU.Hum.ML.harass:Value()
	elseif Mode == "LaneClear" then
		return 1 / SLU.Hum.ML.lclear:Value()
	else
		return 1 / SLU.Hum.ML.perm:Value()
	end
end

function Humanizer:Spells()
	if Mode == "Combo" then
		return 1 / SLU.Hum.SPC.bcombo:Value()
	elseif Mode == "LastHit" then
		return 1 / SLU.Hum.SPC.blhit:Value()
	elseif Mode == "Harass" then
		return 1 / SLU.Hum.SPC.bharass:Value()
	elseif Mode == "LaneClear" then
		return 1 / SLU.Hum.SPC.blclear:Value()
	else
		return 1 / SLU.Hum.SPC.bperm:Value()
	end
end

function Humanizer:IssueOrder(order)
	if order.flag == 2 and SLU.Hum.enable:Value() and not _G.SLW then
		if os.clock() - self.lastCommand < self:moveEvery() then
		  BlockOrder()
		  self.bCount = self.bCount + 1
		else
		  self.lastCommand = os.clock()
		end
	end
end

function Humanizer:SpellCast(spell)
	if SLU.Hum.enable1:Value() then
		if os.clock() - self.lastspell < self:Spells() then
		  BlockCast()
		  self.bCount1 = self.bCount1 + 1
		else
		  self.lastspell = os.clock()
		end
	end
end

function Humanizer:Draw()
	if SLU.Hum.Draw:Value() and not _G.SLW then
  		DrawText("Blocked Movements : "..tostring(self.bCount),25,SLU.Hum.Horizontal:Value(),SLU.Hum.Vertical:Value(),ARGB(255,159,242,12))
	end
	if SLU.Hum.Draw1:Value() then
  		DrawText("Blocked Spells : "..tostring(self.bCount1),25,SLU.Hum.Horizontal:Value(),SLU.Hum.Vertical:Value()+20,ARGB(255,159,242,12))
	end
end


class 'Awareness'

function Awareness:__init()
	
    if not DirExists(SPRITE_PATH.."Champions\\") then CreateDir(SPRITE_PATH.."Champions\\") end
    if not DirExists(SPRITE_PATH.."Champions\\Circle50\\") then CreateDir(SPRITE_PATH.."Champions\\Circle50\\") end
    if not DirExists(SPRITE_PATH.."Champions\\Circle25\\") then CreateDir(SPRITE_PATH.."Champions\\Circle25\\") end
	self.Wards = {}
	self.Wards2 = {}
	self.R = {}
	self.t = 0
	self.monsters = {}
	self.mobs = {["SRU_Baron"]={s=1200,d=420}, ["SRU_Dragon"]={s=150,d=360}, ["SRU_Red"]={s=105,d=300}, ["SRU_Blue"]={s=105,d=300}, ["SRU_Krug"]={s=50,d=100}, ["SRU_Murkwolf"]={s=105,d=103}, ["SRU_Razorbeak"]={s=105,d=90}, ["SRU_Gromp"]={s=105,d=145}, ["Sru_Crab"]={s=150,d=120}}
	self.j = nil
	self.d = {}
	self.d2 = {}
	self.wp = {}
	self.cd = {}
	self.str = {["SummonerDot"]="Ig",["SummonerFlash"]="Fl",["SummonerExhaust"]="Ex",["SummonerGhost"]="Gh",["SummonerTeleport"]="Tp",["SummonerBarrier"]="Ba",["SummonerSmite"]="Sm",["SummonerHeal"]="He",["SummonerSnowball"]="Sn"}
	self.spells = {
	["Ashe"] = {d = 0.25, s = 1450,w=120,sp=3,c=true,dmg=function(unit) return 75+175*GetCastLevel(myHero,3)*myHero.ap end,},
	["Draven"] = {d = 0.4,s = 2000,w=120,sp=3,c=false,dmg=function(unit) return 75+100*GetCastLevel(myHero,3)+1.1*myHero.totalDamage end,},
	["Ezreal"] = {d = 1, s = 2000,w=140,sp=3,c=false,dmg=function(unit) return 200+150*GetCastLevel(myHero,3)+0.9*myHero.ap+myHero.totalDamage end,}, 
	["Jinx"] = {d = 0.6, s = 1650,w=130,sp=3,c=true,dmg=function(unit) return math.min(math.max((150 + GetCastLevel(myHero,3)*GetBonusDmg(myHero)+(unit.maxHealth-unit.health)*(.20+GetCastLevel(myHero,3)*.5))*.1,(150 + GetCastLevel(myHero,3)*GetBonusDmg(myHero)+(unit.maxHealth-unit.health)*(.20+GetCastLevel(myHero,3)*.5))*GetDistance(GetOrigin(myHero),GetOrigin(unit))/1650),(150 + GetCastLevel(myHero,3)*GetBonusDmg(myHero)+(unit.maxHealth-unit.health)*(.20+GetCastLevel(myHero,3)*.5))) end,}
	}
	self.E = {}
	self.offy = 60
	
	SLU:Menu("A", "Awareness")
	
	SLU.A:Menu("HUD", "HUD")
		SLU.A.HUD:Boolean("E", "Enabled",true)
		SLU.A.HUD:Boolean("DE","Draw Enemies",true)
		-- SLU.A.HUD:Boolean("R","Draw Ult CD", true)
		
	SLU.A:Menu("CDT", "Cooldown Tracker")
		SLU.A.CDT:Boolean("E", "Enabled",true)
		SLU.A.CDT:Boolean("TE", "Track Enemies", true)
		SLU.A.CDT:Boolean("TA", "Track Allies", true)
		
	SLU.A:Menu("WT", "Ward Tracker")
		SLU.A.WT:Boolean("E", "Enabled",true)
		SLU.A.WT:Boolean("DS", "Draw on Screen", true)
		SLU.A.WT:Boolean("DM", "Draw on Minimap", true)
		SLU.A.WT:Boolean("TEW", "Track Enemy Wards", true)
		SLU.A.WT:Boolean("TAW", "Track Ally Wards", false)
		SLU.A.WT:DropDown("Cq", "Circle Quality", 3, {"High", "Medium", "Low"})
		SLU.A.WT:Slider("Cw", "Circle Width", 1.5,0,3,0.5)
		
	SLU.A:Menu("ME", "Missing Enemies")
		SLU.A.ME:Boolean("E", "Enabled", true)
		SLU.A.ME:Boolean("DT", "Draw Timer", true)
		SLU.A.ME:Boolean("DI", "Draw Icon", true)
		SLU.A.ME:Boolean("DC", "Draw Circle", true)
		
		SLU.A.ME:Menu("DE", "Enable Draw for :")
		DelayAction(function() 
			for _, i in pairs(GetEnemyHeroes()) do
				SLU.A.ME.DE:Boolean("D"..i.charName, "Draw "..i.charName, true)
			end
		end,.001)
	SLU.A:Menu("RT", "Recall Tracker")
	SLU.A.RT:Boolean("E", "Enabled", true)
	SLU.A.RT:Boolean("P", "Print", true)
	SLU.A.RT:Boolean("DT", "Draw Timer", true)
	SLU.A.RT:Boolean("DU", "Draw Unit pos", true)
	if self.spells[myHero.charName] then
		SLU.A.RT:Menu("U", "Base Ult : ")
		SLU.A.RT:Boolean("ER", "Enable Base Ult", true)
		DelayAction(function() 
			for _, i in pairs(GetEnemyHeroes()) do
				SLU.A.RT.U:Boolean(i.charName, i.charName, true)
			end
		end,.001)	
	else
		SLU.A.RT:Info("Rec", "Base Ult isnt supported for "..myHero.charName)
	end
	SLU.A:Menu("JT", "Jungle Tracker")
	SLU.A.JT:Boolean("E", "Enabled", true)
	SLU.A.JT:Boolean("TJ", "Track Enemy Jungler", true)
	SLU.A.JT:Menu("ET", "Enable Timer for : ")
	DelayAction(function()
		for m,p in pairs(self.mobs) do
			SLU.A.JT.ET:Boolean(m, m, true)
		end
	end,.001)
	SLU.A:Menu("WPT", "WayPoint Tracker")
	SLU.A.WPT:Boolean("E", "Enabled", true)
	SLU.A.WPT:Boolean("TE", "Track Enemy Team", true)
	SLU.A.WPT:Boolean("TA", "Track Ally Team ", true)
	SLU.A.WPT:Boolean("TT", "Draw Timer", true)
	SLU.A.WPT:Menu("T", "Enable Track for : ", true)
	DelayAction(function()
		for _,i in pairs(heroes) do
			if not SLU.A.WPT.T[i.charName] then 
				SLU.A.WPT.T:Boolean(i.charName, i.charName, true)
			end
		end
		if not SLU.A.WPT.T[myHero.charName] then 
				SLU.A.WPT.T:Boolean(myHero.charName, myHero.charName, true)
		end
	end,.001)
	
	for _,i in pairs(GetEnemyHeroes()) do 
		self.E[i.networkID] = {u = i, l = 0, p = nil, p2 = nil, ms = 0, h = GetPercentHP(i), m = GetPercentMP(i)} 
	end
	
	Callback.Add("Tick", function() self:Tk() end)
	Callback.Add("CreateObj", function(o) self:CreO(o) end)
	Callback.Add("DeleteObj", function(o) self:DelO(o) end)
	Callback.Add("Draw", function() self:DrawScreen() end)
	Callback.Add("DrawMinimap", function() self:draMin() end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemBuff(u,b) end)
	Callback.Add("ProcessRecall", function(u,r) self:PrRe(u,r) end)
	Callback.Add("ProcessWaypoint", function(u,wp) self:PrWp(u,wp) end)
	DelayAction(function()
		self:LoadSprites()
	end,1)
	
	self.DravenR = false
end

function Awareness:PrWp(u,wp)
	if u and u.isHero and wp and wp.index == 1 and SLU.A.WPT.E:Value() and ((u.team == myHero.team and SLU.A.WPT.TA:Value()) or (u.team ~= myHero.team and SLU.A.WPT.TE:Value())) and SLU.A.WPT.T[u.charName] and SLU.A.WPT.T[u.charName]:Value() then
		if not self.wp[u.networkID] then self.wp[u.networkID] = {} end
		self.wp[u.networkID] = {u=u,wp=wp,pos=wp.position,s=GetTickCount(),d=(GetDistance(u,wp.position)/u.ms)}
		for _,i in pairs(self.wp) do
			if i.pos ~= wp.position and u == i.u then
				self.wp[u.networkID] = nil
			end
		end
	end
end

function Awareness:LoadSprites()
	if not FileExist(SPRITE_PATH.."Champions\\Circle50\\Unknown.png") then
		DownloadFileAsync("https://raw.githubusercontent.com/qqwer1/GoS-Lua/master/Sprites/RadarHack/miss.png", SPRITE_PATH.."Champions\\Circle50\\Unknown.png", function() end)
	end
	if not FileExist(SPRITE_PATH.."Champions\\Circle25\\Unknown.png") then
		DownloadFileAsync("https://raw.githubusercontent.com/qqwer1/GoS-Lua/master/Sprites/RadarHack/miss.png", SPRITE_PATH.."Champions\\Circle25\\Unknown.png", function() end)
	end
	for _,i in pairs(self.E) do
		if not FileExist(SPRITE_PATH.."Champions\\Circle50\\"..i.u.charName..".png") then
			GetWebResultAsync("https://raw.githubusercontent.com/LoggeL/ChampSprites/master/Circle50/"..i.u.charName..".png", function (b)
				DelayAction(function()
					if b ~= "404: Not Found" then 
						DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/ChampSprites/master/Circle50/"..i.u.charName..".png", SPRITE_PATH.."Champions\\Circle50\\"..i.u.charName..".png", 
						function() 	
							DelayAction(function()
								self.d[i.u.networkID] = Sprite("Champions\\Circle50\\"..i.u.charName..".png", 50, 50, 0, 0) 
							end,.1)
						end)
					else
						self.d[i.u.networkID] = Sprite("Champions\\Circle50\\Unknown.png", 50, 50, 0, 0)
					end
				end,.1)
			end)
		else
			self.d[i.u.networkID] = Sprite("Champions\\Circle50\\"..i.u.charName..".png", 50, 50, 0, 0)
		end
		if not FileExist(SPRITE_PATH.."Champions\\Circle25\\"..i.u.charName..".png") then
			GetWebResultAsync("https://raw.githubusercontent.com/LoggeL/ChampSprites/master/Circle25/"..i.u.charName..".png", function (b)
				DelayAction(function()
					if b ~= "404: Not Found" then 
						DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/ChampSprites/master/Circle25/"..i.u.charName..".png", SPRITE_PATH.."Champions\\Circle25\\"..i.u.charName..".png", 
						function() 	
							DelayAction(function()
								self.d2[i.u.networkID] = Sprite("Champions\\Circle25\\"..i.u.charName..".png", 25, 25, 0, 0) 
							end,.1)
						end)
					else
						self.d2[i.u.networkID] = Sprite("Champions\\Circle25\\Unknown.png", 25, 25, 0, 0)
					end
				end,.1)
			end)
		else
			self.d2[i.u.networkID] = Sprite("Champions\\Circle25\\"..i.u.charName..".png", 25, 25, 0, 0)
		end
	end
end

function Awareness:PrRe(u,r)
	if u.team ~= myHero.team and r.isStart then
		table.insert(self.R, {u = u, s = GetGameTimer(), d = (r.totalTime/1000),at=GetGameTimer() + (r.totalTime - r.passedTime)*.001})
		self.offy = self.offy + 30
	else
		table.remove(self.R, 1)
	end
	if r.isFinish and u.team ~= myHero.team and u and r then
		for _,i in pairs(self.E) do
			if i.u and u.networkID == i.u.networkID and spawn then
				i.p = WorldToMinimap(spawn.pos)
				i.p2 = spawn.pos
				i.l = GetGameTimer()
			end
		end
	end
	if u.team ~= myHero.team and u and r and SLU.A.RT.P:Value() and SLU.A.RT.E:Value() then
		if r.isStart then
			print(u.charName.."("..math.ceil(GetPercentHP(u)).."%) Started Recalling")
		else
			if r.isFinish then
				print(u.charName.."("..math.ceil(GetPercentHP(u)).."%) Finished Recall")
			else
				print(u.charName.."("..math.ceil(GetPercentHP(u)).."%) Cancelled Recall")
			end
		end
	end
end

function Awareness:UpdBuff(u,b)
	if u and b then
		if b.Name == "sightwardstealth" then
			self.t = math.ceil((b.ExpireTime-b.StartTime)/10)
		end
		if u.isMe and b.Name == "DravenRDoublecast" then
			self.DravenR = true
		end
	end
end

function Awareness:RemBuff(u,b)
	if u and b then
		if b.Name == "sightwardstealth" then
			self.t = 0
		end
		if u.isMe and b.Name == "DravenRDoublecast" then
			self.DravenR = false
		end
	end
end

function Awareness:GetDuration(t,i)
	return math.ceil(t-(GetTickCount()-i.s)*.001)
end

function Awareness:CreO(o)
	if o and o.networkID then
		if o.name:lower():find("visionward") then
			if ((o.team == myHero.team and SLU.A.WT.TAW:Value()) or (o.team ~= myHero.team and SLU.A.WT.TEW:Value())) then
				table.insert(Wards,{o=o})
			end
		end
		if o.name:lower():find("sightward") then
			if ((o.team == myHero.team and SLU.A.WT.TAW:Value()) or (o.team ~= myHero.team and SLU.A.WT.TEW:Value())) then
				table.insert(Wards2,{o=o,s=GetTickCount()})
			end
		end
	end
end

function Awareness:DelO(o)
	if o and o.networkID then
		if o.name:lower():find("visionward") then
			if ((o.team == myHero.team and SLU.A.WT.TAW:Value()) or (o.team ~= myHero.team and SLU.A.WT.TEW:Value())) then
				for _,i in pairs(Wards) do
					table.remove(Wards,_)
				end
			end
		end
		if o.name:lower():find("sightward") then
			if ((o.team == myHero.team and SLU.A.WT.TAW:Value()) or (o.team ~= myHero.team and SLU.A.WT.TEW:Value())) then
				for _,i in pairs(Wards2) do
					table.remove(Wards2,_)
				end
			end
		end
	end
end

function Awareness:DrawScreen()
	heroes[myHero.networkID] = nil
	if SLU.A.HUD.E:Value() and SLU.A.HUD.DE:Value() then
		local yOff = 0
		for _,i in pairs(self.d) do
			local h = math.floor(GetPercentHP(self.E[_].u))
			local m = math.floor(GetPercentMP(self.E[_].u))
			CircleSegment2(WINDOW_W * .9 + 25 ,WINDOW_H * .3 + 25 + yOff,20,34,315,423 ,GoS.Black)
			if self.E[_].u.alive then 
			CircleSegment2(WINDOW_W * .9 + 25 ,WINDOW_H * .3 + 25 + yOff,22,27,320,320 + m,GoS.Blue)
			CircleSegment2(WINDOW_W * .9 + 25 ,WINDOW_H * .3 + 25 + yOff,27,32,320,320 + h,ARGB(255,255-2.55*h,2.55*h,0))
			end
			i:Draw(WINDOW_W * .9 ,WINDOW_H * .3 + yOff, 50 ,50)
			if self.E[_].u.dead then
				CircleSegment2(WINDOW_W * .9 + 25 ,WINDOW_H * .3 + 25 + yOff,0,20,0,360,ARGB(50,0,0,0))
			end
			DrawText(h.."%",30,WINDOW_W * .9 + 75 ,WINDOW_H * .3 + 12.5 + yOff,ARGB(255,255-2.55*h,2.55*h,0))
			yOff = yOff + 60
		end
	end
	if SLU.A.WT.E:Value() and SLU.A.WT.DS:Value() then
		for _,i in pairs(Wards) do
			if i.o and i.o.valid then
				if i.o.team ~= myHero.team and SLU.A.WT.TEW:Value() then
					DrawCircle(i.o.pos,75,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,242,2,222))
				elseif i.o.team == myHero.team and SLU.A.WT.TAW:Value() then
					DrawCircle(i.o.pos,75,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,0,0,255))
				end
			end
		end
		for _,i in pairs(Wards2) do
			if i.o and i.o.valid then
				if i.o.team == myHero.team and SLU.A.WT.TAW:Value() then
					DrawCircle(i.o.pos,75,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,0,255,0))
				elseif i.o.team ~= myHero.team and SLU.A.WT.TEW:Value() then
					DrawCircle(i.o.pos,75,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,255,0,0))
				end
				DrawTextSmall(self:GetDuration(self.t,i), WorldToScreen(0,i.o.pos).x, WorldToScreen(0,i.o.pos).y, GoS.White)
			end
		end
	end
	for _,i in pairs(self.R) do
		if SLU.A.RT.E:Value() then
			if i.s and i.u and i.d then
				if SLU.A.RT.DT:Value() then
					DrawText(i.u.charName.." - Recalled in : "..math.ceil(i.d - (GetGameTimer() - i.s)), 30,WorldToScreen(0,i.u.pos).x,WorldToScreen(0,i.u.pos).y,GoS.Yellow)
					DrawText(i.u.charName.." - Recalled in : "..math.ceil(i.d - (GetGameTimer() - i.s)),20,20,self.offy-30,GoS.Yellow)
				end
				if SLU.A.RT.DU:Value() then
					DrawCircle(i.u.pos, i.u.boundingRadius*1.5,1,20,GoS.Yellow)
				end
			end
		end
	end
	if self.j and self.j.visible and self.j.alive and SLU.A.JT.E:Value() and SLU.A.JT.TJ:Value() then
		if self.j.distance < 4000 and self.j.distance > 2000 then
			DrawLine3D(myHero.pos.x, myHero.pos.y,myHero.pos.z, self.j.pos.x, self.j.pos.y,self.j.pos.z, 2, GoS.White)
		elseif self.j.distance < 2000 then			
			DrawLine3D(myHero.pos.x, myHero.pos.y,myHero.pos.z, self.j.pos.x, self.j.pos.y,self.j.pos.z, 2, GoS.Red)
		end
	end
	for _,i in pairs(self.wp) do
		if self:GetDuration(i.d,i) ~= -0 and SLU.A.WPT.E:Value() and ((i.u.team == myHero.team and SLU.A.WPT.TA:Value()) or (i.u.team ~= myHero.team and SLU.A.WPT.TE:Value())) and SLU.A.WPT.T[i.u.charName] and SLU.A.WPT.T[i.u.charName]:Value()  then
			if i.u.team == myHero.team then
				DrawLine(WorldToScreen(0,i.u.pos).x,WorldToScreen(0,i.u.pos).y,WorldToScreen(0,i.pos).x,WorldToScreen(0,i.pos).y,1,GoS.Blue)
			else
				DrawLine(WorldToScreen(0,i.u.pos).x,WorldToScreen(0,i.u.pos).y,WorldToScreen(0,i.pos).x,WorldToScreen(0,i.pos).y,1,GoS.Red)
			end
			if SLU.A.WPT.TT:Value() then
				DrawText(self:GetDuration(i.d,i), 20,WorldToScreen(0,i.pos).x, WorldToScreen(0,i.pos).y, GoS.White)
			end
		else
			self.wp[_] = nil 
		end
	end
	if SLU.A.CDT.E:Value() then
		for _,i in pairs(heroes) do
			if i.visible and i.alive and ((i.team == myHero.team and SLU.A.CDT.TA:Value()) or (i.team ~= myHero.team and SLU.A.CDT.TE:Value())) then
				self:DrawCdTracker(i)
			end
		end
	end
end

function Awareness:draMin()
	if SLU.A.WT.E:Value() and SLU.A.WT.DM:Value() then 
		for _,i in pairs(Wards) do
			if i.o and i.o.valid then
				if i.o.team ~= myHero.team and SLU.A.WT.TEW:Value() then
					DrawCircleMinimap(i.o.pos,350,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,242,2,222))
				elseif i.o.team == myHero.team and SLU.A.WT.TAW:Value() then
					DrawCircleMinimap(i.o.pos,350,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,0,0,255))
				end
			end
		end
		for _,i in pairs(Wards2) do
			if i.o and i.o.valid then
				if i.o.team == myHero.team and SLU.A.WT.TAW:Value() then
					DrawCircleMinimap(i.o.pos,350,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,0,255,0))
				elseif i.o.team ~= myHero.team and SLU.A.WT.TEW:Value() then
					DrawCircleMinimap(i.o.pos,350,SLU.A.WT.Cw:Value(),SLU.A.WT.Cq:Value()*20,ARGB(255,255,0,0))
				end
			end
		end
	end
    for _,i in pairs(self.E) do
        if SLU.A.ME.E:Value() and i.u and SLU.A.ME.DE["D"..i.u.charName]:Value() then
            if i.u.visible and i.u.alive then
                i.p = WorldToMinimap(i.u.pos)
                i.p2 = i.u.pos
                i.ms = i.u.ms
                i.l = GetGameTimer()
            elseif i.u.alive and i.l and i.ms and i.p2 and i.p and i.l and i.p2.x and i.p2.y and GetGameTimer()-i.l < 30 and (GetGameTimer()-i.l)*i.ms < 5000 then
                if SLU.A.ME.DC:Value()  then
                    if not i.u.visible and i.u.alive and SLU.A.ME.DI:Value() and self.d2[i.u.networkID] then
                        self.d2[i.u.networkID]:Draw(i.p.x-12,i.p.y-12,25,25)
                    end
                    DrawCircleMinimap(i.p2, (GetGameTimer()-i.l)*i.ms, 0, 0, ARGB(1.25*(20-GetGameTimer()-i.l),255,255,255))
                end
                if SLU.A.ME.DT:Value() then
                    DrawText(math.floor(GetGameTimer()-i.l),12,i.p.x,i.p.y, ARGB(255,255,255,255))
                end
            end
        end
    end
	if self.j and self.j.alive and self.j.visible and SLU.A.JT.E:Value() and SLU.A.JT.TJ:Value() then
		DrawCircleMinimap(self.j.pos, 350, 1, 20, GoS.Red)
		DrawText("Jungler",12,WorldToMinimap(self.j.pos).x,WorldToMinimap(self.j.pos).y, ARGB(255,255,255,255))
	end
	for _, i in pairs(self.monsters) do
		if i and i.s and not i.alive then
			if i.pos then
				if GetGameTimer()>i.st then
					DrawText(self:GetDuration(i.d,i),12,WorldToMinimap(i.pos).x,WorldToMinimap(i.pos).y, ARGB(255,255,255,255))
				end
			end
		end
	end
end

function Awareness:Tk()
	for _,i in pairs(self.wp) do
		if GetDistance(i.pos) < 1 then
			table.remove(self.wp,_)
		end
	end
	for _, i in pairs(GetEnemyHeroes()) do
		if GetCastName(i,SUMMONER_1):lower():find("summonersmite") then
			self.j = i
		elseif GetCastName(i,SUMMONER_2):lower():find("summonersmite") then
			self.j = i
		else
			self.j = nil
		end
	end
	for _,i in pairs(SLM) do
		for k,p in pairs(self.mobs) do
			if i.team == MINION_JUNGLE and k == i.charName and SLU.A.JT.ET[k]:Value() and SLU.A.JT.E:Value() then
				if not self.monsters[i.networkID] then self.monsters[i.networkID] = {} end
				self.monsters[i.networkID].pos = i.pos
				if not i.alive then
					self.monsters[i.networkID].i = i
					self.monsters[i.networkID].s = GetTickCount()
					self.monsters[i.networkID].d = p.d
					self.monsters[i.networkID].st = p.s
				end
			end
		end	
	end
	for _,i in pairs(self.monsters) do
		DelayAction(function() self.monsters[_] = nil end,i.d) 
	end
	for _, i in pairs(self.spells) do
		for k,p in pairs(self.R) do
			if self.spells[myHero.charName] and p.u then
				if p.at-(GetDistance(p.u.pos,spawn.pos)/i.s+i.d)-GetGameTimer()+GetLatency()*.001 < 0 and IsReady(i.sp) and SLU.A.RT.ER:Value() and SLU.A.RT.E:Value() and SLU.A.RT.U[p.u.charName]:Value() and not self.DravenR then
					if p.u.health < self.spells[myHero.charName].dmg(p.u) and not self:Coll() then
						CastSkillShot(i.sp,spawn.pos)
					end	
				end
			end
		end
	end
	for _,i in pairs(heroes) do
		if i and i.valid then
			if not self.cd[i.charName] then self.cd[i.charName] = {} end
				self.cd[i.charName] = {
					[0] = i:GetSpellData(0),
					[1] = i:GetSpellData(1),
					[2] = i:GetSpellData(2),
					[3] = i:GetSpellData(3),
					[4] = i:GetSpellData(4),
					[5] = i:GetSpellData(5),
				}
		end
	end
end

function Awareness:DrawCdTracker(unit)
	for i = 0,3 do	
		if unit then
			local p = Vector(GetHPBarPos(unit).x,GetHPBarPos(unit).y+22.5,0):perpendicular()
			local pos = p:perpendicular2()
			DrawRectangle2(GetHPBarPos(unit).x, GetHPBarPos(unit).y+15 - 1, 110,6, 0xFF000000)
			DrawLine(GetHPBarPos(unit).x+i*26,GetHPBarPos(unit).y+12.5,pos.x+i*26,pos.y,4,0xFF000000)
			if self.cd[unit.charName] and self.cd[unit.charName][i] then
				local k = self.cd[unit.charName][i]
				if k and k.level > 0 then
					if  k.currentCd > 0 then
						DrawLine(GetHPBarPos(unit).x+i*26,GetHPBarPos(unit).y+15,GetHPBarPos(unit).x+i*26+(GetCastCooldown(unit,i,GetCastLevel(unit,i)) - k.currentCd) / GetCastCooldown(unit,i,GetCastLevel(unit,i)) * 25,GetHPBarPos(unit).y+15,5, ARGB(255,255,0,0))
					else
						DrawLine(GetHPBarPos(unit).x+i*26,GetHPBarPos(unit).y+15,GetHPBarPos(unit).x+i*26+(GetCastCooldown(unit,i,GetCastLevel(unit,i)) - k.currentCd) / GetCastCooldown(unit,i,GetCastLevel(unit,i)) * 25,GetHPBarPos(unit).y+15,5, ARGB(255,0,255,0))
					end
				end
			end
		end
	end
	for i = 4,4 do
		if unit then
			if self.cd[unit.charName] and self.cd[unit.charName][i] then
				local k = self.cd[unit.charName][i]
				if k and k.level > 0 then
					if k.currentCd > 0 then
						DrawLine(GetHPBarPos(unit).x-26,GetHPBarPos(unit).y+i*2,GetHPBarPos(unit).x-26+(GetCastCooldown(unit,i,GetCastLevel(unit,i)) - k.currentCd) / GetCastCooldown(unit,i,GetCastLevel(unit,i)) * 25,GetHPBarPos(unit).y+i*2,5, ARGB(255,255,0,0))
					else
						DrawLine(GetHPBarPos(unit).x-26,GetHPBarPos(unit).y+i*2,GetHPBarPos(unit).x-26+(GetCastCooldown(unit,i,GetCastLevel(unit,i)) - k.currentCd) / GetCastCooldown(unit,i,GetCastLevel(unit,i)) * 25,GetHPBarPos(unit).y+i*2,5, ARGB(255,0,255,0))
					end
					if self.str[self.cd[unit.charName][i].name] then
						DrawTextSmall(self.str[self.cd[unit.charName][i].name] ,GetHPBarPos(unit).x-48,GetHPBarPos(unit).y+i*3,GoS.White)
					end
				end
			end
		end
	end
	for i = 5,5 do
		if unit then
			if self.cd[unit.charName] and self.cd[unit.charName][i] then
				local k = self.cd[unit.charName][i]
				if k and k.level > 0 then
					if k.currentCd > 0 then
						DrawLine(GetHPBarPos(unit).x-26,GetHPBarPos(unit).y+i/2,GetHPBarPos(unit).x-26+(GetCastCooldown(unit,i,GetCastLevel(unit,i)) - k.currentCd) / GetCastCooldown(unit,i,GetCastLevel(unit,i)) * 25,GetHPBarPos(unit).y+i/2,5, ARGB(255,255,0,0))
					else
						DrawLine(GetHPBarPos(unit).x-26,GetHPBarPos(unit).y+i/2,GetHPBarPos(unit).x-26+(GetCastCooldown(unit,i,GetCastLevel(unit,i)) - k.currentCd) / GetCastCooldown(unit,i,GetCastLevel(unit,i)) * 25,GetHPBarPos(unit).y+i/2,5, ARGB(255,0,255,0))
					end
					if self.str[self.cd[unit.charName][i].name]  then
						DrawTextSmall(self.str[self.cd[unit.charName][i].name]  ,GetHPBarPos(unit).x-48,GetHPBarPos(unit).y+i/3,GoS.White)
					end
				end
			end
		end
	end
end

function Awareness:Coll()
	for m,p in pairs(GetEnemyHeroes()) do
		if p and p.alive and self.spells[myHero.charName].c and self.spells[myHero.charName].w and myHero.alive and spawn then
			local vP = VectorPointProjectionOnLineSegment(Vector(myHero.pos),Vector(spawn.pos),Vector(p.pos))
			if vP and GetDistance(vP,p.pos) < (self.spells[myHero.charName].w+p.boundingRadius) then
				return true
			end
		end
	end
	return false
end

class 'Reallifeinfo'

function Reallifeinfo:__init()
	SLU:Menu("Date", "Real life info")
	SLU.Date:Menu("DDA", "Draw Date")
	SLU.Date.DDA:Boolean("DrawDate", "Draw Current Date", true)
	SLU.Date.DDA:Slider("Horizontal", "Horizontal (Drawings)", GetResolution().x*.9, 0, GetResolution().x, 10)
	SLU.Date.DDA:Slider("Vertical", "Vertical (Drawings)", 60, 0, GetResolution().y, 10)
	SLU.Date.DDA:ColorPick("ColorPick", "Color Pick - Date", {255,226,255,18})
	SLU.Date:Menu("DD", "Draw Day")
	SLU.Date.DD:Boolean("DrawDay", "Draw Current Day", false)
	SLU.Date.DD:Slider("Horizontal", "Horizontal (Drawings)", GetResolution().x*.9, 0, GetResolution().x, 10)
	SLU.Date.DD:Slider("Vertical", "Vertical (Drawings)", 140, 0, GetResolution().y, 10)
	SLU.Date.DD:ColorPick("ColorPick", "Color Pick - Day", {255,226,255,18})
	SLU.Date:Menu("DM", "Draw Month")
	SLU.Date.DM:Boolean("DrawMonth", "Draw Current Month", false)
	SLU.Date.DM:Slider("Horizontal", "Horizontal (Drawings)", GetResolution().x*.9, 0, GetResolution().x, 10)
	SLU.Date.DM:Slider("Vertical", "Vertical (Drawings)", 100, 0, GetResolution().y, 10)
	SLU.Date.DM:ColorPick("ColorPick", "Color Pick - Month", {255,226,255,18})
	SLU.Date:Menu("DY", "Draw Year")
	SLU.Date.DY:Boolean("DrawYear", "Draw Current Year", false)
	SLU.Date.DY:Slider("Horizontal", "Horizontal (Drawings)", GetResolution().x*.9, 0, GetResolution().x, 10)
	SLU.Date.DY:Slider("Vertical", "Vertical (Drawings)", 120, 0, GetResolution().y, 10)
	SLU.Date.DY:ColorPick("ColorPick", "Color Pick - Year", {255,226,255,18})
	SLU.Date:Menu("DT", "Draw Time")
	SLU.Date.DT:Boolean("DrawTime", "Draw Current Time", true)
	SLU.Date.DT:Slider("Horizontal", "Horizontal (Drawings)", GetResolution().x*.9, 0, GetResolution().x, 10)
	SLU.Date.DT:Slider("Vertical", "Vertical (Drawings)", 80, 0, GetResolution().y, 10)
	SLU.Date.DT:ColorPick("ColorPick", "Color Pick - Time", {255,226,255,18})
	
	Callback.Add("Draw", function() self:EnableDraw() end)
end

function Reallifeinfo:EnableDraw()
	if SLU.Date.DD.DrawDay:Value() then
		DrawText("Current Day     : "..os.date("%A"), 15, SLU.Date.DD.Horizontal:Value(), SLU.Date.DD.Vertical:Value(), SLU.Date.DD.ColorPick:Value())
	end
	if SLU.Date.DDA.DrawDate:Value() then
		DrawText("Current Date    : "..os.date("%x", os.time()), 15, SLU.Date.DDA.Horizontal:Value(), SLU.Date.DDA.Vertical:Value(), SLU.Date.DDA.ColorPick:Value())
	end
	if SLU.Date.DM.DrawMonth:Value() then				
		DrawText("Current Month : "..os.date("%B"), 15, SLU.Date.DM.Horizontal:Value(), SLU.Date.DM.Vertical:Value(), SLU.Date.DM.ColorPick:Value())
	end
	if SLU.Date.DY.DrawYear:Value() then
		DrawText("Current Year   : "..os.date("%Y"), 15, SLU.Date.DY.Horizontal:Value(), SLU.Date.DY.Vertical:Value(), SLU.Date.DY.ColorPick:Value())
	end
	if SLU.Date.DT.DrawTime:Value() then
		DrawText("Current Time   : "..os.date("*t").hour.." : "..os.date("*t").min.." : "..os.date("*t").sec, 15, SLU.Date.DT.Horizontal:Value(), SLU.Date.DT.Vertical:Value(), SLU.Date.DT.ColorPick:Value())
	end
end

class 'WardJump'
function WardJump:__init()

	self.items = {
		{id = 2045,stack = true},
		{id = 2049,stack = true},
		{id = 2044,stack = true},
		{id = 3340,stack = true},
	}
	
	SLU:SubMenu("WJ","Ward Jump")
	SLU.WJ:Key("k", "Ward Jump Key", string.byte("T"))
	
	self.champtable = {["Katarina"] = 2, ["Jax"] = 0 }
	self.slot = nil
	self.casted = false
	self.wardpos = nil
	self.wardpos2 = nil
	self.stack = false
	self.wards = {}
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("CreateObj", function(o) self:CretO(o) end)
end

function WardJump:GetBestWardPos()	
	if GetDistance(GetMousePos()) < 600 then
		self.wardpos = Vector(myHero)+Vector(Vector(GetMousePos())-myHero):normalized()*GetDistance(GetMousePos())
		self.wardpos2 = Vector(myHero)+Vector(Vector(GetMousePos())-myHero):normalized():perpendicular()*GetDistance(GetMousePos())
	else
		self.wardpos = Vector(myHero)+Vector(Vector(GetMousePos())-myHero):normalized()*600
		self.wardpos2 = Vector(myHero)+Vector(Vector(GetMousePos())-myHero):normalized():perpendicular()*600
	end
	if MapPosition:inWall(self.wardpos) then 
		return self.wardpos2
	else
		return self.wardpos
	end
end

function WardJump:GetJumpSlot()
	if myHero.charName ~= "LeeSin" then
		return self.champtable[myHero.charName]
	else
		if GetCastName(myHero,1) ~= "blindmonkwtwo" then
			return 1
		end
	end
	return nil
end

function WardJump:Tick()
	if self:GetJumpSlot() then
		for _,i in pairs(self.items) do
			if GetItemSlot(myHero,i.id) > 0 and IsReady(GetItemSlot(myHero,i.id)) then 
				self.slot = GetItemSlot(myHero,i.id)
				self.stack = i.stack
			end
		end	
		if self.slot and SLU.WJ.k:Value() and (not self.stack or GetItemAmmo(myHero,GetItemSlot(myHero,self.slot))>=1) and not self.casted and IsReady(self:GetJumpSlot()) then
			self.casted = true
			CastSkillShot(self.slot,self:GetBestWardPos())
			DelayAction(function()
				self.casted = false
			end,1)
		end
		for _,i in pairs(self.wards) do
			if i and GetDistance(i.o,GetMousePos()) < 500 and self.casted then
				DelayAction(function()
					CastTargetSpell(i.o,self:GetJumpSlot())
				end,.001)
			end
		end
		if SLU.WJ.k:Value() then
			MoveToXYZ(GetMousePos()) 
		end
	end
end

function WardJump:CretO(o)
	if o and o.networkID then
		if o.name:lower():find("visionward") then
			if o.team == myHero.team then
				if not self.wards[o.networkID] then self.wards[o.networkID] = {} end
				self.wards[o.networkID] = {o=o}
				DelayAction(function()
					self.wards[o.networkID] = nil
				end,1)
			end
		end
		if o.name:lower():find("sightward") then
			if o.team == myHero.team then				
				if not self.wards[o.networkID] then self.wards[o.networkID] = {} end
				self.wards[o.networkID] = {o=o}
				DelayAction(function()
					self.wards[o.networkID] = nil
				end,1)
			end
		end
	end
end

class 'AutoLevel'

function AutoLevel:__init()
	SLU:SubMenu(myHero.charName.."AL", "Auto Level")
	SLU[myHero.charName.."AL"]:Boolean("aL", "Use AutoLvl", false)
	SLU[myHero.charName.."AL"]:DropDown("aLS", "AutoLvL", 1, {"Q-W-E","Q-E-W","W-Q-E","W-E-Q","E-Q-W","E-W-Q"})
	SLU[myHero.charName.."AL"]:Slider("sL", "Start AutoLvl with LvL x", 4, 1, 18, 1)
	SLU[myHero.charName.."AL"]:Boolean("hL", "Humanize LvLUP", true)
	SLU[myHero.charName.."AL"]:Slider("hT", "Humanize min delay", .5, 0, 1, .1)
	SLU[myHero.charName.."AL"]:Slider("hF", "Humanize time frame", .2, 0, .5, .1)
	
	--AutoLvl
	self.lTable={
	[1] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E}, 
	[2] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
	[3] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
	[4] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
	[5] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
	[6] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q}, 
	}
	
	Callback.Add("Tick", function() self:Do() end)
end

function AutoLevel:Do()
	if SLU[myHero.charName.."AL"].aL:Value() and GetLevelPoints(myHero) >= 1 and GetLevel(myHero) >= SLU[myHero.charName.."AL"].sL:Value() then
		if SLU[myHero.charName.."AL"].hL:Value() then
			DelayAction(function() LevelSpell(self.lTable[SLU[myHero.charName.."AL"].aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]or nil) end, math.random(SLU[myHero.charName.."AL"].hT:Value(),SLU[myHero.charName.."AL"].hT:Value()+SLU[myHero.charName.."AL"].hF:Value()))
		else
			LevelSpell(self.lTable[SLU[myHero.charName.."AL"].aLS:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]or nil)
		end
	end
end


class 'SkinChanger'

function SkinChanger:__init()

	SLU:SubMenu("S", "SkinChanger")
	SLU.S:Boolean("uS", "Use Skin", true)
	SLU.S:Slider("sV", "Skin Number", 0, 0, 15, 1)
	
	local cSkin = 0
	
	Callback.Add("Tick", function() self:Change() end)
end

function SkinChanger:Change()
	if SLU.S.uS:Value() and SLU.S.sV:Value() ~= cSkin then
		HeroSkinChanger(myHero,SLU.S.sV:Value()) 
		cSkin = SLU.S.sV:Value()
	elseif not SLU.S.uS:Value() and cSkin ~= 0 then
		HeroSkinChanger(myHero,0)
		cSkin = 0 
	end
end

--Activator
class 'Activator'

function Activator:__init()

	self.ShopPos = nil
	self.badPot = false
	self.cc = {}
	Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))
	Heal = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerheal") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerheal") and SUMMONER_2 or nil))
	Snowball = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonersnowball") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonersnowball") and SUMMONER_2 or nil))
	Barrier = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerbarrier") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerbarrier") and SUMMONER_2 or nil))
	Smite = (GetCastName(myHero,4):lower():find("smite") and 4) or (GetCastName(myHero,5):lower():find("smite") and 5) or nil

	self.smiteD = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}
	self.s1 = {}
	self.s2 = {}
	self.EpicJgl = {["SRU_Baron"]="Baron", ["SRU_Dragon"]="Dragon", ["TT_Spiderboss"]="Vilemaw"}
	self.BigJgl = {["SRU_Red"]="Red Buff", ["SRU_Blue"]="Blue Buff", ["SRU_Krug"]="Krugs", ["SRU_Murkwolf"]="Wolves", ["SRU_Razorbeak"]="Razor", ["SRU_Gromp"]="Gromp", ["Sru_Crab"]="Scuttles"}

	Snowballd = { delay = 0.25, range = 1600, speed = 1200, width = 50 }
	
	self.CCType = { 
	[5] = "Stun", 
	[8] = "Taunt", 
	[11] = "Snare", 
	[21] = "Fear", 
	[22] = "Charm", 
	[24] = "Suppression",
	}
	
	
	self.PAC = {	--PointAndClick
	[3144] = {Name = "Cutlass", Range = 550},
	[3153] = {Name = "BotrK", Range = 550},
	[3146] = {Name = "Gunblade", Range = 700},	
	}
	
	self.RS = {		--RangeSelfcast
	[3142] = {Name = "Ghostblade", Range = 700},
	[3800] = {Name = "Righteous Glory", Range = 700},
	[3092] = {Name = "Frost Queen", Range = 700},
	[3143] = {Name = "Randuins", Range = 500},
	[3069] = {Name = "Talisman", Range = 700},
	}
	
	self.AA = {		--AAReset
	[3077] = {Name = "Tiamat"},
	[3074] = {Name = "Ravenous Hydra"},
	[3748] = {Name = "Titanic Hydra"},
	}
	
	self.CC = {		--QSS
	[3140] = {Name = "QSS"},
	[3137] = {Name = "Dervish Blade"},
	[3139] = {Name = "Mercurial Scimitar"},
	[3222] = {Name = "Crucible", Allies = true},
	}
	
	self.Da = { --dash
	[3152] = {Name = "Protobelt"}
	}
	
	self.Sks = { --skillshot
	[3030] = {Name = "Hextech GLP 800"}
	}
	
	self.SU = {		--Shield Units
	[3190] = {Name = "Locket", Range = 600},
	[3401] = {Name = "Face of the Mountain", Range = 600},
	}
	
	self.HP = {		--HealthPots
	[2003] = {Name = "Health Potion", Stack = false},
	[2031] = {Name = "Refillable Potion", Stack = true},
	[2032] = {Name = "Hunters Potion", Stack = true},
	[2033] = {Name = "Corruption Potion", Stack = true},
	}
	
	--self.CP 
	
	self.SI = {		--Stasis
	--[3157] = {Name = "Hourglass"},
	--[3090] = {Name = "Wooglets"},
	}
	
	M:Info("xxx","Items appear here as you buy")
	
	M:SubMenu("Sum", "Summoners")
	if Ignite then
	M.Sum:Menu("ign", "Ignite")
	M.Sum.ign:Boolean("enable","Enable Ignite", true)
	end
	if Heal then 
	M.Sum:Menu("Heal", "Heal")
	M.Sum.Heal:Boolean("healme","Heal myself", true)
	M.Sum.Heal:Boolean("healally", "Heal ally", true)
	M.Sum.Heal:Slider("allyHP", "Ally HP to heal him", 8, 1, 100, 2)
	M.Sum.Heal:Slider("myHP", "my HP to heal myself", 8, 1, 100, 2)
	end
	if Snowball then
	M.Sum:Menu("SB", "Snowball")
	M.Sum.SB:Boolean("enable", "Enable Snowball", false)
	end
	if Barrier then
	M.Sum:Menu("Barrier", "Barrier")
	M.Sum.Barrier:Boolean("enable","Use Barrier", true)
	M.Sum.Barrier:Slider("myHP", "my HP to use Barrier", 8, 1, 100, 2)
	end
	if Smite then
		M.Sum:Menu("Smite", "Smite")
		M.Sum.Smite:Boolean("E","Enable", true)
		M.Sum.Smite:SubMenu("M","Epic Mobs")
		M.Sum.Smite:SubMenu("B","Big Mobs")
		M.Sum.Smite:Boolean("K", "Killsteal", true)
		M.Sum.Smite:Boolean("F", "Fast Smite", true)
		for _,i in pairs(self.EpicJgl) do
			M.Sum.Smite.M:Boolean(_,i,true)
		end
		for _,i in pairs(self.BigJgl) do
			M.Sum.Smite.B:Boolean(_,i,false)
		end
	end
	
	
	Callback.Add("Tick", function() self:Tickpx() end)
	Callback.Add("UpdateBuff", function(unit, buff) self:UBuff(unit, buff) end)
	Callback.Add("RemoveBuff", function(unit, buff) self:RBuff(unit, buff) end)
	Callback.Add("CreateObj", function (Object) self:Shop(Object) end)
	Callback.Add("ProcessSpellComplete", function (unit, spellProc) self:SpellsComplete(unit, spellProc) end)
	Callback.Add("Draw", function() if Smite then self:Draw() end end)
end

function Activator:Tickpx()
	self:Check()
	if myHero.dead then return end
	self:Use(GetCurrentTarget())
	if Ignite then 
		self:Ignite() 
	end
	if Heal then 
		self:Heal() 
	end
	if Snowball then 
		self:Snowball() 
	end
	if Barrier then 
		self:Barrier() 
	end
	if Smite then
		self:Smite()
	end
end	

function Activator:Shop(obj)
	if GetObjectBaseName(obj):lower():find("shop") and GetDistance(obj,myHero)<2000 then
		self.ShopPos = GetOrigin(obj)
	end
end

function Activator:Check()
	--print(self.badPot)
	if (not self.ShopPos or GetDistance(myHero,self.ShopPos) <= 1500) or myHero.dead then
		for i,c in pairs(self.PAC) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					M[c.Name]:Slider("hp","%EnemyHp to use", 100, 10, 100, 5)
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.RS) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					M[c.Name]:Slider("r","Range to use", c.Range, 200, 1500, 50)
					M[c.Name]:Slider("hp","%EnemyHp to use", 100, 10, 100, 5)
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.CC) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					for n,m in pairs(self.CCType) do
						M[c.Name]:Boolean("i"..n,"Cleanse "..m, true)
					end
					if c.Allies then
						for _,l in pairs(GetAllyHeroes()) do
							M[c.Name]:Boolean(GetObjectName(l),"Cleanse for "..GetObjectName(l), true)
						end
					end
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.AA) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					M[c.Name]:Slider("hp","%EnemyHp to use", 100, 10, 100, 5)
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.Da) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					M[c.Name]:Slider("hp","%EnemyHp to use", 100, 10, 100, 5)
					M[c.Name]:DropDown("m", "Mode", 2, {"Mousepos","Sideways","Target"})
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.Sks) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					M[c.Name]:Slider("hp","%EnemyHp to use", 100, 10, 100, 5)
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.SU) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u","Use "..c.Name,true)
					M[c.Name]:Slider("hp","Use at % HP", 10, 2, 80, 2)
					M[c.Name]:Boolean("self","Shield self" ,true)
					DelayAction(function()
						for _,l in pairs(GetAllyHeroes()) do
							M[c.Name]:Boolean(GetObjectName(l),"Shield "..GetObjectName(l), true)
						end
					end,.001)
				end
				c.State = true
			else
				c.State = false
			end
		end
		
		for i,c in pairs(self.HP) do
			if GetItemSlot(myHero,i)>0 then
				if not c.State and not M[c.Name] then
					M:Menu(c.Name,c.Name)
					M[c.Name]:Boolean("u", "Use "..c.Name,true)
					M[c.Name]:Slider("hp","Use at % HP", 10, 2, 80, 2)
				end
				c.State = true
			else
				c.State = false
			end
		end
	end
end

function Activator:Use(target)
	if Mode == "Combo" then
		for i,c in pairs(self.PAC) do
			if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and ValidTarget(target,c.Range) and GetPercentHP(target) <= M[c.Name].hp:Value() then
				CastTargetSpell(target,GetItemSlot(myHero,i))
			end
		end
		for i,c in pairs(self.RS) do
			if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and ValidTarget(target,M[c.Name].r:Value()) and GetPercentHP(target) <= M[c.Name].hp:Value() then
				CastSpell(GetItemSlot(myHero,i))
			end
		end
	end
	for i,c in pairs(self.SU) do
		if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() then
			if M[c.Name].self:Value() and GetPercentHP(myHero) <= M[c.Name].hp:Value() and EnemiesAround(myHero,700)>=1 then
				CastSpell(GetItemSlot(myHero,i))
			else
				for _,n in pairs(GetAllyHeroes()) do
					if M[c.Name][GetObjectName(n)] and M[c.Name][GetObjectName(n)]:Value() and GetPercentHP(n) <= M[c.Name].hp:Value() and EnemiesAround(n,700)>=1 and GetDistance(myHero,n)<600 then
						CastTargetSpell(n,(GetItemSlot(myHero,i)))
					end
				end
			end
		end
	end
	for i,c in pairs(self.Sks) do
		if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and ValidTarget(target,c.Range) and GetPercentHP(target) <= M[c.Name].hp:Value() then
			CastSkillShot(GetItemSlot(myHero,i),GetOrigin(target))
		end
	end
	for i,c in pairs(self.Da) do
		if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and ValidTarget(target,c.Range) and GetPercentHP(target) <= M[c.Name].hp:Value() and M[c.Name].m:Value() == 1 then
			CastSkillShot(GetItemSlot(myHero,i),GetMousePos())
		elseif c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and ValidTarget(target,c.Range) and GetPercentHP(target) <= M[c.Name].hp:Value() and M[c.Name].m:Value() == 2 then
			local position = Vector(target) - (Vector(target) - Vector(myHero)):perpendicular():normalized() * ( GetDistance(myHero,target) * 1.2 )
			CastSkillShot(GetItemSlot(myHero,i),position)
		elseif c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and ValidTarget(target,c.Range) and GetPercentHP(target) <= M[c.Name].hp:Value() and M[c.Name].m:Value() == 3 then
			CastSkillShot(GetItemSlot(myHero,i),GetOrigin(target))
		end
	end
	for i,c in pairs(self.HP) do
		if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and GetPercentHP(myHero) <= M[c.Name].hp:Value() and (not c.Stack or GetItemAmmo(myHero,GetItemSlot(myHero,i))>=1) and not self.badPot then
			CastSpell(GetItemSlot(myHero,i))
		end
	end
	for i,c in pairs(self.CC) do
		if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() then
			if c.Allies then 
				for _,n in pairs(GetAllyHeroes()) do
					if self.cc[GetObjectName(n)] and GetDistance(myHero,n)<600 and M[c.Name][GetObjectName(n)]:Value() then
						CastTargetSpell(n,GetItemSlot(myHero,i))
					end
				end
			elseif self.cc[GetObjectName(myHero)] then
				CastSpell(GetItemSlot(myHero,i))
			end				
		end
	end
end

function Activator:Ignite()
  for _,k in pairs(GetEnemyHeroes()) do
	if M.Sum.ign.enable:Value() and IsReady(Ignite) and not k.dead then
  		if 20*GetLevel(myHero)+50 > GetCurrentHP(k)+GetHPRegen(k)*3 and ValidTarget(k, 600) then
			CastTargetSpell(k, Ignite)
		end
	end
  end
end

function Activator:Heal()
		if IsReady(Heal) and M.Sum.Heal.healme:Value() and GetPercentHP(myHero) <= M.Sum.Heal.myHP:Value() and EnemiesAround(GetOrigin(myHero), 675) >= 1 and not myHero.dead then
			CastSpell(Heal)
		end
	for _,a in pairs(GetAllyHeroes()) do
		if a and IsReady(Heal) and M.Sum.Heal.healally:Value() and GetPercentHP(a) <= M.Sum.Heal.allyHP:Value() and EnemiesAround(GetOrigin(myHero), 675) >= 1 and GetDistance(myHero,a) < 675 and not a.dead then
			CastSpell(Heal)
		end
	end
end

function Activator:Snowball()
	for _,unit in pairs(GetEnemyHeroes()) do
		local Pred = GetPredictionForPlayer(myHero.pos,unit,unit.ms, Snowballd.speed, Snowballd.delay*1000, Snowballd.range, Snowballd.width, true, true)
		if IsReady(Snowball) and M.Sum.SB.enable:Value() and Pred and Pred.HitChance == 1 and GetDistance(Pred.PredPos,GetOrigin(myHero)) < Snowballd.range and not unit.dead then
			CastSkillShot(Snowball,Pred.PredPos)
		end
	end
end

function Activator:Barrier()
	if IsReady(Barrier) and M.Sum.Barrier.enable:Value() and GetPercentHP(myHero) <= M.Sum.Barrier.myHP:Value() and EnemiesAround(GetOrigin(myHero), 675) >= 1 and not myHero.dead then
		CastSpell(Barrier)
	end
end

function Activator:Smite()
	if M.Sum.Smite.E:Value() then 
		for _,i in pairs(SLM) do
			if (self.EpicJgl[i.charName] and M.Sum.Smite.M[i.charName]) or (self.BigJgl[i.charName] and M.Sum.Smite.B[i.charName]) or (i.charName:lower():find("dragon") and M.Sum.Smite.M["SRU_Dragon"]:Value()) then
				self.s1[i.charName] = i
			end
		end
		if M.Sum.Smite.K:Value() and GetCastName(myHero,Smite) == "S5_SummonerSmitePlayerGanker" then
			for _,i in pairs(GetEnemyHeroes()) do
				if i.valid and i.distance < 675 and i.health-GetDamagePrediction(i,(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero))-i.distance/math.huge) < 20 + 8*myHero.level then
					CastTargetSpell(i,Smite)
				end
			end
		end
		for _,i in pairs(self.s1) do
			if i.valid and i.distance < 1000 and ((M.Sum.Smite.B[_] and M.Sum.Smite.B[_]:Value()) or (M.Sum.Smite.M[_] and M.Sum.Smite.M[_]:Value()) or (_:find("Dragon") and M.Sum.Smite.M["SRU_Dragon"])) then
				self.s2[_] = i
			else
				self.s2[_] = nil
			end
		end
		if IsReady(Smite) and not M.Sum.Smite.F:Value() then
			for _,i in pairs(self.s2) do
				if i.health-GetDamagePrediction(i,(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero))-i.distance/math.huge) < self.smiteD[myHero.level] and i.distance <= 675 then	
					DelayAction(function()
						CastTargetSpell(i,Smite)
					end,GetLatency()/100)
				end
			end
		end
	end
end

function Activator:Draw()
	if M.Sum.Smite.F:Value() and IsReady(Smite) then
		for _,i in pairs(self.s2) do
			if i.health-GetDamagePrediction(i,(GetAttackSpeed(myHero)*GetBaseAttackSpeed(myHero))-i.distance/math.huge) < self.smiteD[myHero.level] and i.distance < 675 then
				CastTargetSpell(i,Smite)
			end	
		end
	end
end

function Activator:SpellsComplete(unit, spellProc)
	if unit == myHero and spellProc.name:lower():find("attack") and (Mode == "Combo" or Mode == "LaneClear") then
		for i,c in pairs(self.AA) do 
			if c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and GetPercentHP(spellProc.target) <= M[c.Name].hp:Value() then
				CastSpell(GetItemSlot(myHero,i))
				AttackUnit(spellProc.target)
			end
		end
	elseif unit == myHero and spellProc.name:lower():find("recall") then
		self.badPot = true
		DelayAction(function () self.badPot = false end, 15)
	end
end

function Activator:UBuff(unit,buffProc)
	if unit == myHero and buffProc.Name:lower():find("recall") then 
		self.badPot = true
	elseif GetTeam(unit) == MINION_ALLY then
		for i,c in pairs(self.CC) do
			if M[c.Name] and c.State and CanUseSpell(myHero,GetItemSlot(myHero,i)) and M[c.Name].u:Value() and M[c.Name]["i"..buffProc.Type] and M[c.Name]["i"..buffProc.Type]:Value() then
				self.cc[GetObjectName(unit)] = true
			end
		end
	end
	if unit == myHero and buffProc.Name:lower():find("potion") or buffProc.Name:lower():find("crystalflask") then
		self.badPot = true 
		DelayAction(function() self.badPot = false end,
		buffProc.ExpireTime-GetGameTimer())
	end
end

function Activator:RBuff(unit,buffProc)
	if unit == myHero and buffProc.Name:lower():find("recall") and GetDistance(GetOrigin(myHero),self.ShopPos)>1000 then 
		self.badPot = false
	elseif GetTeam(unit) == MINION_ALLY then
		for i,c in pairs(self.CC) do
			if M[c.Name] and M[c.Name].u:Value() and M[c.Name]["i"..buffProc.Type] and M[c.Name]["i"..buffProc.Type]:Value() then
				self.cc[GetObjectName(unit)] = false
			end
		end
	end
end

class 'SLWalker'

function SLWalker:__init()
	self.aarange = 0
	self.attacksEnabled = true
	self.movementEnabled = true
	self.forcePos = nil
	self.forceTarget = nil
	self.rangebuffer = {["KogMaw"]={r=0,b="KogMawBioArcaneBarrage"}}
	self.str = {[0]="Q",[1]="W",[2]="E",[3]="R"}
	self.LastAttack = 0
	self.windUpTime = 0
	self.animationTime = 0
	self.AttackDoneAt = 0
	self.BaseWindUp = 1
	self.BaseAttackSpeed = 1
	self.LastMoveOrder = 0
	self.AA = {}
	self.projectilespeeds = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000, ["SRU_OrderMinionRanged"] = 650, ["SRU_ChaosMinionRanged"] = 650, ["SRU_OrderMinionSiege"] = 1200, ["SRU_ChaosMinionSiege"] = 1200, ["SRUAP_Turret_Chaos1"]  = 1200, ["SRUAP_Turret_Chaos2"]  = 1200, ["SRUAP_Turret_Chaos3"] = 1200, ["SRUAP_Turret_Order1"]  = 1200, ["SRUAP_Turret_Order2"]  = 1200, ["SRUAP_Turret_Order3"] = 1200, ["SRUAP_Turret_Chaos4"] = 1200, ["SRUAP_Turret_Chaos5"] = 500, ["SRUAP_Turret_Order4"] = 1200, ["SRUAP_Turret_Order5"] = 500 }
	self.altAANames = {"caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3"}
	self.aaresets = {"dariusnoxiantacticsonh", "fiorae", "garenq", "hecarimrapidslash", "jaxempowertwo", "jaycehypercharge", "leonashieldofdaybreak", "luciane", "monkeykingdoubleattack", "mordekaisermaceofspades", "nasusq", "nautiluspiercinggaze", "netherblade", "parley", "poppydevastatingblow", "powerfist", "renektonpreexecute", "rengarq", "shyvanadoubleattack", "sivirw", "takedown", "talonnoxiandiplomacy", "trundletrollsmash", "vaynetumble", "vie", "volibearq", "xenzhaocombotarget", "yorickspectral", "reksaiq", "riventricleave", "kalistaexpunge", "itemtitanichydracleave", "itemtiamatcleave", "gravesmove", "masochism" }
 self.bonusDamageTable = {--IOW
    ["Aatrox"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg+(GotBuff(source, "aatroxwpower")>0 and 35*GetCastLevel(source, _W)+25 or 0), APDmg, TRUEDmg
    end,
    ["Ashe"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg*(GotBuff(source, "asheqattack")>0 and 5*(0.01*GetCastLevel(source, _Q)+0.22) or GotBuff(target, "ashepassiveslow")>0 and (1.1+GetCritChance(source)*(1)) or 1), APDmg, TRUEDmg
    end,
    ["Bard"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg+(GotBuff(source, "bardpspiritammocount")>0 and 30+GetLevel(source)*15+0.3*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Blitzcrank"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg*(GotBuff(source, "powerfist")+1), APDmg, TRUEDmg
    end,
    ["Caitlyn"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "caitlynheadshot") > 0 and 1.5*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Chogath"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "vorpalspikes") > 0 and 15*GetCastLevel(source, _E)+5+.3*GetBonusAP(source) or 0), APDmg, TRUEDmg
    end,
    ["Corki"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, 0, TRUEDmg + (GotBuff(source, "rapidreload") > 0 and .1*(ADDmg) or 0)
    end,
    ["Darius"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "dariusnoxiantacticsonh") > 0 and .4*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Diana"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "dianaarcready") > 0 and math.max(5*GetLevel(source)+15,10*GetLevel(source)-10,15*GetLevel(source)-60,20*GetLevel(source)-125,25*GetLevel(source)-200)+.8*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Draven"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "DravenSpinning") > 0 and 35+10*GetCastLevel(myHero,_Q) / 100*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Ekko"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "ekkoeattackbuff") > 0 and 30*GetCastLevel(source, _E)+20+.2*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Fizz"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "fizzseastonepassive") > 0 and 5*GetCastLevel(source, _W)+5+.3*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Garen"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "garenq") > 0 and 25*GetCastLevel(source, _Q)+5+.4*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Gragas"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "gragaswattackbuff") > 0 and 30*GetCastLevel(source, _W)-10+.3*GetBonusAP(source)+(.01*GetCastLevel(source, _W)+.07)*GetMaxHP(minion) or 0), TRUEDmg
    end,
    ["Irelia"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, 0, TRUEDmg + (GotBuff(source, "ireliahitenstylecharged") > 0 and 25*GetCastLevel(source, _Q)+5+.4*(ADDmg) or 0)
    end,
    ["Jax"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "jaxempowertwo") > 0 and 35*GetCastLevel(source, _W)+5+.6*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Jayce"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "jaycepassivemeleeatack") > 0 and 40*GetCastLevel(source, _R)-20+.4*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Jinx"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "jinxq") > 0 and .1*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Kalista"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg * 0.9, APDmg, TRUEDmg
    end,
    ["Kassadin"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "netherbladebuff") > 0 and 20+.1*GetBonusAP(source) or (GotBuff(source, "netherblade") > 0 and 25*GetCastLevel(source, _W)+15+.6*GetBonusAP(source) or 0)), TRUEDmg
    end,
    ["Kayle"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "kaylerighteousfurybuff") > 0 and 5*GetCastLevel(source, _E)+5+.15*GetBonusAP(source) or 0) + (GotBuff(source, "judicatorrighteousfury") > 0 and 5*GetCastLevel(source, _E)+5+.15*GetBonusAP(source) or 0), TRUEDmg
    end,
	["KogMaw"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, (GotBuff(source, "KogMawBioArcaneBarrage") > 0 and (4 * GetCastLevel(source,_W) + (.02 + APDmg*.00075)*target.maxHealth) or 0), TRUEDmg
	end,
    ["Leona"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "leonashieldofdaybreak") > 0 and 30*GetCastLevel(source, _Q)+10+.3*GetBonusAP(source) or 0), TRUEDmg
    end,
    ["Lux"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "luxilluminatingfraulein") > 0 and 10+(GetLevel(source)*8)+(GetBonusAP(source)*0.2) or 0), TRUEDmg
    end,
    ["MasterYi"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "doublestrike") > 0 and .5*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Nocturne"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "nocturneumrablades") > 0 and .2*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Orianna"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + 2 + 8 * math.ceil(GetLevel(source)/3) + 0.15*GetBonusAP(source), TRUEDmg
    end,
    ["RekSai"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "reksaiq") > 0 and 10*GetCastLevel(source, _Q)+5+.2*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Rengar"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "rengarqbase") > 0 and math.max(30*GetCastLevel(source, _Q)+(.05*GetCastLevel(source, _Q)-.05)*(ADDmg)) or 0) + (GotBuff(source, "rengarqemp") > 0 and math.min(15*GetLevel(source)+15,10*GetLevel(source)+60)+.5*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Shyvana"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "shyvanadoubleattack") > 0 and (.05*GetCastLevel(source, _Q)+.75)*(ADDmg) or 0), APDmg, TRUEDmg
    end,
    ["Talon"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "talonnoxiandiplomacybuff") > 0 and 30*GetCastLevel(source, _Q)+.3*(GetBonusDmg(source)) or 0), APDmg, TRUEDmg
    end,
    ["Teemo"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + 10*GetCastLevel(source, _E)+0.3*GetBonusAP(source), TRUEDmg
    end,
    ["Trundle"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "trundletrollsmash") > 0 and 20*GetCastLevel(source, _Q)+((0.05*GetCastLevel(source, _Q)+0.095)*(ADDmg)) or 0), APDmg, TRUEDmg
    end,
    ["Varus"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg, APDmg + (GotBuff(source, "varusw") > 0 and (4*GetCastLevel(source, _W)+6+.25*GetBonusAP(source)) or 0) , TRUEDmg
    end,
    ["Vayne"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "vaynetumblebonus") > 0 and (.2+.1*GetCastLevel(source,_Q))*(ADDmg) or 0), 0, TRUEDmg + (GotBuff(target, "VayneSilveredDebuff") > 1 and math.max(20+20*GetCastLevel(source,_W), 4+1.5*GetCastLevel(source,_W) / 100 * target.maxHealth) or 0)
    end,
    ["Vi"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "vie") > 0 and 15*GetCastLevel(source, _E)-10+.15*(ADDmg)+.7*GetBonusAP(source) or 0) , APDmg, TRUEDmg
    end,
    ["Volibear"] = function(source, target, ADDmg, APDmg, TRUEDmg)
		return ADDmg + (GotBuff(source, "volibearq") > 0 and 30*GetCastLevel(source, _Q) or 0), APDmg, TRUEDmg
	end
  }	
  
  self.Channel = {
	{name = "katarinar", duration = 1},
	{name = "drain", duration = 5},
	{name = "crowstorm", duration = 1.5},
	{name = "consume", duration = 1.5},
	{name = "absolutezero", duration = 1},
	{name = "ezrealtrueshotbarrage", duration = 1},
	{name = "galioidolofdurand", duration = 1},
	{name = "reapthewhirlwind", duration = 1},
	{name = "missfortunebullettime", duration = 1},
	{name = "shenstandunited", duration = 1},
	{name = "meditate", duration = 1},
	{name = "gate", duration = 1.5},
  }
  
	OMenu:Menu("FS", "Farm Settings")
	OMenu.FS:Boolean("AJ", "Attack Jungle", true)
	OMenu.FS:Boolean("AS", "Attack Structures", true)
	OMenu.FS:Boolean("EL", "Enable Kite Limiter", true)
	OMenu.FS:Slider("DK", "Dont Kite if Attackspeed > x",2.5,0.5,2.6,0.1)
	OMenu.FS:Slider("FD", "Farm Delay", 0,-20,20,1)
	
	OMenu:Menu("D", "Drawings")
	OMenu.D:Boolean("LHM", "Lasthit Marker", false)
	OMenu.D:Boolean("DMAR", "Draw My Attack Range", true)
	OMenu.D:Boolean("DEAR", "Draw Enemy Attack Range", false)
	OMenu.D:Boolean("DAAR", "Draw Ally Attack Range", false)
	OMenu.D:Boolean("DHR", "Draw Holposition radius", false)
	
	OMenu:Menu("K", "Keys")
	OMenu.K:KeyBinding("C", "Combo Key", string.byte(" "))
	OMenu.K:KeyBinding("H", "Harass Key", string.byte("C"))
	OMenu.K:KeyBinding("LC", "LaneClear Key", string.byte("V"))
	OMenu.K:KeyBinding("LH", "LastHit Key", string.byte("X"))
	
	self.ts = TargetSelector(self.aarange, TARGET_LESS_CAST, DAMAGE_PHYSICAL)
	OMenu:TargetSelector("TS", "TargetSelector", self.ts)
	
	OMenu:Menu("Hum", "Humanizer")
	OMenu.Hum:Boolean("Enable", "Enable Humanizer", true)
	OMenu.Hum:Slider("lhit", "Max. Movements in Last Hit", 6, 1, 20, 1)
	OMenu.Hum:Slider("lclear", "Max. Movements in Lane Clear", 6, 1, 20, 1)
	OMenu.Hum:Slider("harass", "Max. Movements in Harass", 7, 1, 20, 1)
	OMenu.Hum:Slider("combo", "Max. Movements in Combo", 8, 1, 20, 1)
	
	OMenu:Menu("Adv", "Advanced")
	OMenu.Adv:Menu("Combo", "Combo")
	OMenu.Adv.Combo:Boolean("em", "Enable Movement", true)
	OMenu.Adv.Combo:Boolean("ea", "Enable Attacks", true)
	OMenu.Adv:Menu("Harass", "Harass")
	OMenu.Adv.Harass:Boolean("em", "Enable Movement", true)
	OMenu.Adv.Harass:Boolean("ea", "Enable Attacks", true)
	OMenu.Adv:Menu("LaneClear", "LaneClear")
	OMenu.Adv.LaneClear:Boolean("em", "Enable Movement", true)
	OMenu.Adv.LaneClear:Boolean("ea", "Enable Attacks", true)
	OMenu.Adv:Menu("LastHit", "LastHit")
	OMenu.Adv.LastHit:Boolean("em", "Enable Movement", true)
	OMenu.Adv.LastHit:Boolean("ea", "Enable Attacks", true)
	OMenu.Adv:Slider("AAD", "Auto Attack Delay", -50,-50,50,5)
	OMenu.Adv:Slider("MD", "Move Delay", 20,-50,50,5)
	
	if myHero.charName == "Draven" and not _G.DravenLoaded then
		OMenu:Menu("DS", "Draven Settings")
		OMenu.DS:Boolean("E", "Enable Catch", true)
		OMenu.DS:Slider("CR", "Catch Radius", 500,100,1000,5)
		OMenu.DS:Boolean("ED", "Enable Draw", true)
		OMenu.DS:Boolean("DCR", "Draw Catch Radius", true)
	end

	self.da = {}
	self.pos = nil
	self.c = {}
	_G.Before_AA, _G.After_AA = 1, 2
	self.cb = {[1] = {}, [2] = {}}
	
	Callback.Add("ProcessSpellAttack", function(unit,spellProc) self:PrAtt(unit,spellProc) end)
	Callback.Add("UpdateBuff", function(u,b) self:UB(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RB(u,b) end)
	Callback.Add("ProcessSpell", function(unit,spellProc) self:PrSp(unit,spellProc) end)
	Callback.Add("Tick", function(unit,spellProc) self:T(unit,spellProc) end)
	Callback.Add("Draw", function(unit,spellProc) self:D(unit,spellProc) end)
	Callback.Add("IssueOrder", function(order) self:IssOrd(order) end)
	Callback.Add("CreateObj", function(obj) self:CreateO(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteO(obj) end)
	Callback.Add("Animation", function(u,a) self:An(u,a) end)
	Callback.Add("ProcessSpellComplete", function(u,s) self:PrSpC(u,s) end)
end

function SLWalker:UB(u,b)
	if b and u and self.rangebuffer[myHero.charName] then
		if b.Name == self.rangebuffer[myHero.charName].b and u.isMe then
			self.rangebuffer[myHero.charName].r = 110+20*GetCastLevel(myHero,1)-myHero.boundingRadius*2
		end
	end
end

function SLWalker:RB(u,b)
	if b and u and self.rangebuffer[myHero.charName] then
		if b.Name == self.rangebuffer[myHero.charName].b and u.isMe then
			self.rangebuffer[myHero.charName].r = 0
		end
	end
end

function SLWalker:An(u,a)
	for _, i in pairs(self.c) do 
		if u.isMe and a == "Run" then
			self.c[_] = nil
		end
	end
end

function SLWalker:T()
if not SLW then return end
if OMenu.FS.EL:Value() and self:Mode() ~= "LastHit" then
	 if self:GetTarget() and ValidTarget(self:GetTarget(),self.aarange) then
		if GetBaseAttackSpeed(myHero)*GetAttackSpeed(myHero) > OMenu.FS.DK:Value() then
			self.movementEnabled = false
		else
			self.movementEnabled = true
		end
	end
end
self.aarange = myHero.range+myHero.boundingRadius*2+(self.rangebuffer[myHero.charName] and self.rangebuffer[myHero.charName].r or 0)
self.ts.range = self.aarange
self:Orb()
	for _, i in pairs(self.da) do
		if not _G.DravenLoaded and i.o and myHero.charName == "Draven" and OMenu.DS.E:Value() then
			self.pos = Vector(i.o.pos) + Vector(Vector(myHero.pos)-i.o.pos):normalized():perpendicular()*75
			if GetDistance(i.o.pos,GetMousePos()) < OMenu.DS.CR:Value() and self.pos then
				MoveToXYZ(self.pos)
			end
		end
	end
	for _,i in pairs(self.c) do
		if i.s.target.dead then
			self.c[_] = nil
		end
	end
end

function SLWalker:D()
if not SLW then return end
	if OMenu.D.DMAR:Value() then
		DrawCircle(myHero.pos,self.aarange,2,20,ARGB(255,155,155,155))
	end
	for _,k in pairs(GetEnemyHeroes()) do
		if OMenu.D.DEAR:Value() and k.visible and k.alive then
			DrawCircle(k.pos,k.range+k.boundingRadius*2,1.5,20,ARGB(255,255,100,50))
		end		
	end
	for _,k in pairs(GetAllyHeroes()) do
		if OMenu.D.DAAR:Value() and k.visible and k.alive then
			DrawCircle(k.pos,k.range+k.boundingRadius*2,1.5,20,ARGB(255,0,0,255))
		end		
	end
	if OMenu.D.DHR:Value() then
		DrawCircle(myHero.pos,myHero.boundingRadius,2,20,ARGB(255,0,150,150))
	end
	for _,i in pairs(SLM) do
		if OMenu.D.LHM:Value() then
			if (self:Mode() == "LaneClear" or self:Mode() == "LastHit" or self:Mode() == "Harass") and i.visible and ValidTarget(i,self.aarange) and i.alive and self:PredictHP(i,1000*(self.windUpTime+i.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, i, self:Dmg(myHero,i,{name = "Basic"})) then
				DrawCircle(i.pos,i.boundingRadius*1.5,1.5,20,ARGB(168,255,255,255))
			elseif self:Mode() == "LaneClear" and i.visible and ValidTarget(i,self.aarange) and i.alive and self:PredictHP(i,1000*(self.windUpTime+i.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, i, self:Dmg(myHero,i,{name = "Basic"}))+self:PredictHP(i,1000*(self.windUpTime+i.distance/self:aaprojectilespeed()))/2 then
				DrawCircle(i.pos,i.boundingRadius*1.5,1.5,20,ARGB(168,242,156,17))
			end
		end
	end	
	for _, i in pairs(self.da) do
		if not _G.DravenLoaded and myHero.charName == "Draven" and OMenu.DS.ED:Value() then
			if i.o then
				DrawCircle(i.o.pos,75,1.5,20,ARGB(255,0,180,100))
			end
		end
	end
	if not _G.DravenLoaded and myHero.charName == "Draven" and OMenu.DS.DCR:Value() and OMenu.DS.ED:Value() then
		DrawCircle(GetMousePos(),OMenu.DS.CR:Value(),1.5,20,ARGB(255,0,180,100))
	end
end

function SLWalker:PredictHP(unit,time)
	return self:GetPredictedHealth(unit,time,0)
end

function SLWalker:Dmg(source,unit,spell)
local dmg = 0
local ADDmg = 0
local TotalDmg = source.totalDamage
local APDmg = 0
local TRUEDmg = 0
local armorPenPercent = source.armorPenPercent
local armorPen = source.armorPen
local damageMultiplier = spell.name:find("CritAttack") and 2 or 1
    if source.type == "obj_AI_Minion" then
        armorPenPercent = 1
    elseif source.type == "obj_AI_Turret" then
        armorPenPercent = 0.7
    end
    if unit.type == "obj_AI_Turret" then
        armorPenPercent = 1
        armorPen = 0
        damageMultiplier = 1
    end
    local targetArmor = (unit.armor * armorPenPercent) - armorPen
    if targetArmor < 0 then
        damageMultiplier = 1 * damageMultiplier
    else
        damageMultiplier = 100 / (100 + targetArmor) * damageMultiplier
    end
    if source.type == source.type and unit.type == "obj_AI_Turret" then
        TotalDmg = math.max(source.totalDamage, source.damage + 0.4 * source.ap)
    end
    if source.type == "obj_AI_Minion" and unit.type == source.type and source.team ~= MINION_JUNGLE then
        damageMultiplier = 0.60 * damageMultiplier
    end
    if source.type == source.type and unit.type == "obj_AI_Turret" then
        damageMultiplier = 0.95 * damageMultiplier
    end
    if source.type == "obj_AI_Minion" and unit.type == "obj_AI_Turret" then
        damageMultiplier = 0.475 * damageMultiplier
    end
    if source.type == "obj_AI_Turret" and (unit.charName == "Red_Minion_MechCannon" or unit.charName == "Blue_Minion_MechCannon") then
        damageMultiplier = 0.8 * damageMultiplier
    end
    if source.type == "obj_AI_Turret" and (unit.charName == "Red_Minion_Wizard" or unit.charName == "Blue_Minion_Wizard" or unit.charName == "Red_Minion_Basic" or unit.charName == "Blue_Minion_Basic") then
        damageMultiplier = (1 / 0.875) * damageMultiplier
    end
    if source.type == "obj_AI_Turret" then
        damageMultiplier = 1.05 * damageMultiplier
    end
	ADDmg = TotalDmg
	if targetType ~= Obj_AI_Turret then
		if GetMaladySlot(source) then
			APDmg = 15 + 0.15*source.ap
		end
		if GotBuff(source, "itemstatikshankcharge") == 100 then
			APDmg = APDmg + 100
		end
		if source == source and not freeze then
			if self.bonusDamageTable[source.charName] then
				ADDmg, APDmg, TRUEDmg = self.bonusDamageTable[source.charName](source, unit, ADDmg, APDmg, TRUEDmg)
			end
			if GotBuff(source, "sheen") > 0 then
				ADDmg = ADDmg + TotalDmg
			end
			if GotBuff(source, "lichbane") > 0 then
				ADDmg = ADDmg + TotalDmg*0.75
				APDmg = APDmg + 0.5*myHero.ap
			end
			if GotBuff(source, "itemfrozenfist") > 0 then
				ADDmg = ADDmg + TotalDmg*1.25
			end
		end
	end
	dmg = math.floor(ADDmg)+math.floor(APDmg)
	dmg = math.floor(dmg*damageMultiplier)+TRUEDmg
return dmg
end

function SLWalker:moveEvery()
	if self:Mode() == "Combo" then
		return 1 / OMenu.Hum.combo:Value()
	elseif self:Mode() == "LastHit" then
		return 1 / OMenu.Hum.lhit:Value()
	elseif self:Mode() == "Harass" then
		return 1 / OMenu.Hum.harass:Value()
	elseif self:Mode() == "LaneClear" then
		return 1 / OMenu.Hum.lclear:Value()
	else
		return 0
	end
end

function SLWalker:DontOrb()
	for _,i in pairs(self.c) do
		if i and i.et and i.et > os.clock() then
			return true
		end
	end
	return false
end

function SLWalker:IssOrd(order)
if not SLW then return end
	if order.flag == 2 and OMenu.Hum.Enable:Value() then
		if os.clock() - self.LastMoveOrder < self:moveEvery() then
		  BlockOrder()
		else
		  self.LastMoveOrder = os.clock()
		end
	end
end

function SLWalker:PrAtt(unit, spellProc)
if not SLW then return end
	if unit.isMe and spellProc then
		if self.altAANames[spellProc.name:lower()] or spellProc.name:lower():find("attack") then
			self.LastAttack = self:Time()-GetLatency()/2
			self.windUpTime = spellProc.windUpTime * 1000
			self.animationTime = spellProc.animationTime * 1000
			self.AttackDoneAt = self.windUpTime + self.LastAttack

			self.BaseWindUp = 1 / (spellProc.windUpTime * GetAttackSpeed(myHero))
			self.BaseAttackSpeed = 1 / (spellProc.animationTime * GetAttackSpeed(myHero))
			
		elseif self.aaresets[spellProc.name:lower()] then
			self:ResetAA()
		end
	end
end

function SLWalker:PrSp(unit,spellProc)
if not SLW then return end
	for _,i in pairs(self.Channel) do
		if spellProc.name:lower() == i.name and unit and unit.isMe and spellProc then
			self.c[unit.networkID] = {et = os.clock() + i.duration + spellProc.windUpTime,s = spellProc}
			DelayAction(function() self.c[unit.networkID] = nil end,i.duration)
		end
	end
	if spellProc and spellProc.target and (self.altAANames[spellProc.name:lower()] or spellProc.name:lower():find("attack")) then
		self:Ex(1, spellProc.target)
	end
end

function SLWalker:PrSpC(u,s)
if not SLW then return end
	if self.projectilespeeds[u.charName] and u.team == myHero.team and s.name:lower():find("attack") and not u.isMe then
		for i = 1, #self.AA do
			if self.AA[i].a == u then
				table.remove(self.AA, i)
				break
			end
		end
		table.insert(self.AA,{a=u,t=s.target,ht=self:GetTime()+1000*(s.windUpTime+GetDistance(s.target,u)/(self.projectilespeeds[u.charName] or math.huge))-GetLatency()/2000})
	end
	if s and s.target and (self.altAANames[s.name:lower()] or s.name:lower():find("attack")) then
		self:Ex(2, s.target)
	end
end

function SLWalker:ResetAA()
	self.LastAttack = 0
end

function SLWalker:Time()
	return GetTickCount()
end

function SLWalker:CanMove()
	if not self.movementEnabled then 
		return 
	end
	return self:Time() - OMenu.Adv.MD:Value() + GetLatency()*.5 - self.LastAttack >= (1000/(GetAttackSpeed(myHero)*self.BaseWindUp))
end

function SLWalker:CanAttack()
	if not self.attacksEnabled then 
		return 
	end
	return self:Time() - OMenu.Adv.AAD:Value() + GetLatency()*.5 - self.LastAttack >= (1000/(GetAttackSpeed(myHero)*self.BaseAttackSpeed))
end

function SLWalker:IsOrbwalking()
	if (OMenu.K.C:Value() or OMenu.K.H:Value() or OMenu.K.LH:Value() or OMenu.K.LC:Value()) then 
		return true 
	end
end

function SLWalker:CanOrb(t)
	if not t and not t.visible and not t.targetable and not t.alive then
		return false
	end
	return true 
end

function SLWalker:Mode()
	if OMenu.K.C:Value() then 
		return "Combo" 
	end
	if OMenu.K.H:Value() then 
		return "Harass" 
	end
	if OMenu.K.LH:Value() then 
		return "LastHit" 
	end
	if OMenu.K.LC:Value() then 
		return "LaneClear" 
	end
end

function SLWalker:JungleClear()
	for _,o in pairs(SLM) do
		if OMenu.FS.AJ:Value() and o.team == MINION_JUNGLE and ValidTarget(o,self.aarange) and self:CanOrb(o) then
			if self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, o, self:Dmg(myHero,o,{name = "Basic"})) then
				return nil
			else
				return GetHighestUnit(o,self.aarange)
			end
		end
	end
end

function SLWalker:LaneClear()
	for _,o in pairs(SLM) do
		for t,turret in pairs(structures) do
			if OMenu.FS.AS:Value() then
				if turret.distance > self.aarange then
					if o.team == MINION_ENEMY and ValidTarget(o,self.aarange) and self:CanOrb(o) then
						if self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, o, self:Dmg(myHero,o,{name = "Basic"}))+self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed()))/2 then
							return nil
						else
							return GetLowestUnit(o,self.aarange)
						end
					end
				else
					if turret.team ~= myHero.team and not turret.dead then
						return turret
					end
				end
			else
				if o.team == MINION_ENEMY and ValidTarget(o,self.aarange) and self:CanOrb(o) then
					if self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, o, self:Dmg(myHero,o,{name = "Basic"}))+self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed()))/2 then
						return nil
					else
						return GetLowestUnit(o,self.aarange)
					end
				end
			end
		end
	end
end

function SLWalker:LastHit()
	for _,o in pairs(SLM) do
		if ValidTarget(o,self.aarange) and self:CanOrb(o) then
			if self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, o, self:Dmg(myHero,o,{name = "Basic"})) then
				 return o
			end
		end
	end
end

function SLWalker:Combo()
	if self.ts:GetTarget() and not self.forceTarget then
		if self:CanOrb(self.ts:GetTarget()) and ValidTarget(self.ts:GetTarget(),self.aarange) then
			return self.ts:GetTarget() 
		end
	elseif self.forceTarget then
		if self:CanOrb(self.forceTarget) and ValidTarget(self.forceTarget,self.aarange) then
			return self.forceTarget
		end
	end
end

function SLWalker:Harass()
	for _,o in pairs(SLM) do
		if self.ts:GetTarget() and not self.forceTarget then
			if self:CanOrb(self.ts:GetTarget()) and ValidTarget(self.ts:GetTarget(),self.aarange)then		
				return self.ts:GetTarget()
			end
		elseif self.forceTarget then
			if self:CanOrb(self.forceTarget) and ValidTarget(self.forceTarget,self.aarange) then
				return self.forceTarget
			end
		end
		if o and o.team == MINION_ENEMY then
			if self:CanOrb(o) and ValidTarget(o,self.aarange)then
				if self:PredictHP(o,1000*(self.windUpTime+o.distance/self:aaprojectilespeed())) < CalcPhysicalDamage(myHero, o, self:Dmg(myHero,o,{name = "Basic"})) then
					return GetLowestUnit(o,self.aarange)
				end
			end
		end
	end
end

function SLWalker:GetTarget()
	if self:Mode() == "Combo" then
	  return self:Combo()
	elseif self:Mode() == "Harass" then
	  return self:LastHit() or self:Harass() 
	elseif self:Mode() == "LastHit" then
	  return self:LastHit()
	elseif self:Mode() == "LaneClear" then
	  return self:LastHit() or self:LaneClear() or self:JungleClear()
	else
	  return nil
	end
end

function SLWalker:Orb()
	if not self:IsOrbwalking() or self:DontOrb() then return end
	if (self:CanMove() or self:CanAttack()) then
		if self:CanAttack() then
			if self:GetTarget() and OMenu.Adv[self:Mode()]["ea"]:Value() then
				AttackUnit(self:GetTarget())
			elseif self:CanMove() and GetDistance(myHero, GetMousePos()) > myHero.boundingRadius and OMenu.Adv[self:Mode()]["em"]:Value() then
					MoveToXYZ(self.forcePos or GetMousePos())
			end
		elseif self:CanMove() and GetDistance(myHero, GetMousePos()) > myHero.boundingRadius and OMenu.Adv[self:Mode()]["em"]:Value() then
				MoveToXYZ(self.forcePos or GetMousePos())
		end
		if GetDistance(myHero, GetMousePos()) < 80 then
			self.movementEnabled = false
		else
			self.movementEnabled = true
		end
	end
end

function SLWalker:aaprojectilespeed()
	return (self.projectilespeeds[myHero.charName] and self.projectilespeeds[myHero.charName] or math.huge) or math.huge
end

function SLWalker:GetTime()
	return os.clock()
end

function SLWalker:CreateO(obj)
	if obj and obj.name:lower():find("reticle_self") then
		if not self.da[obj.name] then self.da[obj.name] = {} end
		self.da[obj.name].o = obj
	end
end

function SLWalker:DeleteO(obj)
	if obj and obj.name:lower():find("reticle_self") then
		self.da[obj.name] = nil
	end
end

function SLWalker:round(num,idp)
  return math.floor(num*(10^(idp or 0))+0.5)/(10^(idp or 0))
end

function SLWalker:GetPredictedHealth(u,t,d)
    IC=0
	d=(d and d+OMenu.FS.FD:Value()) or OMenu.FS.FD:Value()
    for _,i in pairs(self.AA) do
		if i.a.alive and i.t.networkID==u.networkID then
			h=math.floor(i.ht-d*.001)
			if h-.0002<self:round(self:GetTime()+t+GetLatency()/2000) then
				IC=IC+self:Dmg(i.a,u,{name="Basic"})
			end
			if self:Dmg(myHero,u,{name="Basic"})>u.health-IC then
				break
			end
		end	
	end
	return u.health-IC
end

function SLWalker:AddCb(t, f)
	table.insert(self.cb[t], f)
end

function SLWalker:Ex(k, u)
	for i=1,#self.cb[k],1 do
		if self.cb[k][i] then
			self.cb[k][i](u, self:Mode())
		end
	end
end

function LoadSLW()
if not _G.SLW then _G.SLW = SLWalker() end
return SLW
end

class 'SLEvade'

function SLEvade:__init()

	self.supportedtypes = {["Line"]={supported=true},["Circle"]={supported=true},["Cone"]={supported=true},["Rectangle"]={supported=true},["Arc"]={supported=false},["Ring"]={supported=true},["Threeway"]={supported=false},["follow"]={supported=true},["Return"]={supported=true}}
	self.globalults = {["EzrealTrueshotBarrage"]={s=true},["EnchantedCrystalArrow"]={s=true},["DravenRCast"]={s=true},["JinxR"]={s=true}}
	self.obj = {}
	self.str = {[-2]="AA",[-1]="P",[0]="Q",[1]="W",[2]="E",[3]="R"}
	self.Flash = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil))
	self.DodgeOnlyDangerous = false -- Dodge Only Dangerous
	self.patha = nil -- wallcheck line
	self.patha2 = nil -- wallcheck line2
	self.pathb = nil -- wallcheck circ
	self.pathb2 = nil -- wallcheck circ2
	self.asd = false -- blockinput
	self.mposs = nil -- self.mousepos circ
	self.ues = false -- self.usingevadespells
	self.ut = false -- self.usingitems
	self.usp = false -- self.usingsummonerspells
	self.mposs2 = nil -- self.mousepos line
	self.opos = nil -- simulated obj pos
	self.cpos = nil --c pos
	self.mV = nil -- wp
	self.YasuoWall = {} --yasuowall
	self.pathc = nil-- rectangle wall check
	self.pathc2 = nil-- rectangle wall check2
	self.mposs3 = nil --mpos rect
	self.mposs4 = nil --mpos cone
	self.pathd = nil --cone wall check
	self.pathd2 = nil --cone wall check2
	
	self.D = { --Dash items
	[3152] = {Name = "Hextech Protobelt", State = false}
	}
	
	self.SI = {	--Stasis
	[3157] = {Name = "Hourglass", State = false},
	[3090] = {Name = "Wooglets", State = false},
	}
	EMenu:Slider("d","Danger",2,1,5,1)
	EMenu:SubMenu("Spells", "Spell Settings")
	EMenu:SubMenu("EvadeSpells", "EvadeSpell Settings")
	EMenu:SubMenu("invulnerable", "Invulnerable Settings")
	EMenu:SubMenu("Draws", "Drawing Settings")
	EMenu:SubMenu("Advanced", "Advanced Settings")
	EMenu.Advanced:Boolean("LDR", "Limit detection range", true)
	EMenu.Advanced:Boolean("EMC", "Enable Minion Collision", true)
	EMenu.Advanced:Boolean("EHC", "Enable Hero Collision", true)
	EMenu.Advanced:Boolean("EWC", "Enable Wall Collision", true)
	EMenu.Advanced:Slider("ew", "Extra Evade Range", 125, 0, 250, 5)
	EMenu.Draws:Boolean("DSPath", "Draw SkillShot Path", true)
	EMenu.Draws:Boolean("DSEW", "Draw SkillShot Extra Width", true)
	EMenu.Draws:Boolean("DEPos", "Draw Evade Position", false)
	EMenu.Draws:Boolean("DES", "Draw Evade Status", true)
	EMenu.Draws:Boolean("DevOpt", "Draw for Devs", false)
	EMenu:SubMenu("Keys", "Key Settings")
	EMenu.Keys:KeyBinding("DD", "Disable Dodging", string.byte("K"), true)
	EMenu.Keys:KeyBinding("DDraws", "Disable Drawings", string.byte("J"), true)
	EMenu.Keys:KeyBinding("DoD", "Dodge only Dangerous", string.byte(" "))
	EMenu.Keys:KeyBinding("DoD2", "Dodge only Dangerous 2", string.byte("V"))
	EMenu:Boolean("D","DEBUG (Y)",false)
	
	DelayAction(function()
		for _,i in pairs(Spells) do
			for l,k in pairs(GetEnemyHeroes()) do
			-- k = myHero
				if not Spells[_] then return end
				if i.charName == k.charName and self.supportedtypes[i.type].supported then
					if i.displayname == "" then i.displayname = _ end
					if i.danger == 0 then i.danger = 1 end
					if not EMenu.Spells[_] then EMenu.Spells:Menu(i.charName..""..self.str[i.slot]..""..i.displayname,""..i.charName.." | "..(self.str[i.slot] or "?").." - "..i.displayname) end
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("Dodge"..i.charName..""..self.str[i.slot]..""..i.displayname, "Enable Dodge", true)
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("Draw"..i.charName..""..self.str[i.slot]..""..i.displayname, "Enable Draw", true)
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("Dashes"..i.charName..""..self.str[i.slot]..""..i.displayname, "Enable Evade Spells", true)
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Info("Empty12"..i.charName..""..self.str[i.slot]..""..i.displayname, "")			
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("radius"..i.charName..""..self.str[i.slot]..""..i.displayname,"Radius",(i.radius or 150), ((i.radius-50) or 50),((i.radius+100) or 250), 5)
						if i.dangerous then EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("hp"..i.charName..""..self.str[i.slot]..""..i.displayname, "HP to Dodge", 100, 1, 100, 5)
						else EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("hp"..i.charName..""..self.str[i.slot]..""..i.displayname, "HP to Dodge", 85, 1, 100, 5)
						end
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("d"..i.charName..""..self.str[i.slot]..""..i.displayname,"Danger",(i.danger or 1), 1, 5, 1)
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Info("Empty123"..i.charName..""..self.str[i.slot]..""..i.displayname, "")
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("IsD"..i.charName..""..self.str[i.slot]..""..i.displayname,"Dangerous", i.dangerous or false)
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("ffe"..i.charName..""..self.str[i.slot]..""..i.displayname,"Fast Evade", i.ffe or false)
						EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("H"..i.charName..""..self.str[i.slot]..""..i.displayname, "Humanizer", false)
						if i.mcollision then
							EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("Coll"..i.charName..""..self.str[i.slot]..""..i.displayname, "Collision", true)
						else
							EMenu.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Info("nohColl"..i.charName..""..self.str[i.slot]..""..i.displayname, "No Collision available")
						end	
				end
			end
		end
		if self.EvadeSpells[GetObjectName(myHero)] then
			for i = 0,3 do
				if self.EvadeSpells[GetObjectName(myHero)][i] and self.EvadeSpells[GetObjectName(myHero)][i].name and self.EvadeSpells[GetObjectName(myHero)][i].spellKey then
				if not EMenu.EvadeSpells[self.EvadeSpells[GetObjectName(myHero)][i].name] then EMenu.EvadeSpells:Menu(self.EvadeSpells[GetObjectName(myHero)][i].name,""..myHero.charName.." | "..(self.str[i] or "?").." - "..self.EvadeSpells[GetObjectName(myHero)][i].name) end
					EMenu.EvadeSpells[self.EvadeSpells[GetObjectName(myHero)][i].name]:Boolean("Dodge"..self.EvadeSpells[GetObjectName(myHero)][i].name, "Enable Dodge", true)
					EMenu.EvadeSpells[self.EvadeSpells[GetObjectName(myHero)][i].name]:Slider("d"..self.EvadeSpells[GetObjectName(myHero)][i].name,"Danger",(self.EvadeSpells[GetObjectName(myHero)][i].dl or 1), 1, 5, 1)						
				end	
			end 
		end
		if self.Flash then
			EMenu.EvadeSpells:Menu("Flash",""..myHero.charName.." | Summoner - Flash")
			EMenu.EvadeSpells.Flash:Boolean("DodgeFlash", "Enable Dodge", true)
			EMenu.EvadeSpells.Flash:Slider("dFlash","Danger", 5, 1, 5, 1)
		end
	end,.001)
	
	Callback.Add("Tick", function() self:Tickp() end)
	Callback.Add("ProcessSpell", function(unit, spellProc) self:Detection(unit,spellProc) end)
	Callback.Add("CreateObj", function(obj) self:CreateObject(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteObject(obj) end)
	Callback.Add("Draw", function() self:Drawp() end)
	Callback.Add("ProcessWaypoint", function(unit,wp) self:prwp(unit,wp) end)
	Callback.Add("WndMsg", function(s1,s2) self:WndMsg(s1,s2) end)
	Callback.Add("IssueOrder", function(order) self:BlockMov(order) end)

Spells = {
	["AatroxQ"]={charName="Aatrox",slot=0,type="Circle",delay=0.6,range=650,radius=250,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0.225,displayname="Dark Flight",mcollision=false},
	["AatroxE"]={charName="Aatrox",slot=2,type="Line",delay=0.25,range=1075,radius=35,speed=1250,addHitbox=true,danger=3,dangerous=false,proj="AatroxEConeMissile",killTime=0,displayname="Blade of Torment",mcollision=false},
	["AhriOrbofDeception"]={charName="Ahri",slot=0,type="Line",delay=0.25,range=1000,radius=100,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="AhriOrbMissile",killTime=0,displayname="Orb of Deception",mcollision=false},
	["AhriOrbReturn"]={charName="Ahri",slot=0,type="Return",delay=0,range=1000,radius=100,speed=915,addHitbox=true,danger=2,dangerous=false,proj="AhriOrbReturn",killTime=0,displayname="Orb of Deception2",mcollision=false},
	["AhriSeduce"]={charName="Ahri",slot=2,type="Line",delay=0.25,range=1000,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="AhriSeduceMissile",killTime=0,displayname="Charm",mcollision=true},
	["Pulverize"]={charName="Alistar",slot=0,type="Circle",delay=0.25,range=1000,radius=200,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0.25,displayname="Pulverize",mcollision=false},
	["BandageToss"]={charName="Amumu",slot=0,type="Line",delay=0.25,range=1000,radius=90,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="SadMummyBandageToss",killTime=0,displayname="Bandage Toss",mcollision=true},
	["CurseoftheSadMummy"]={charName="Amumu",slot=3,type="Circle",delay=0.25,range=0,radius=550,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=1.25,displayname="Curse of the Sad Mummy",mcollision=false},
	["FlashFrost"]={charName="Anivia",slot=0,type="Line",delay=0.25,range=1200,radius=110,speed=850,addHitbox=true,danger=3,dangerous=true,proj="FlashFrostSpell",killTime=0,displayname="Flash Frost",mcollision=false},
	["Incinerate"]={charName="Annie",slot=1,type="Cone",delay=0.25,range=825,radius=80,speed=math.huge,angle=50,addHitbox=false,danger=2,dangerous=false,proj="nil",killTime=0,displayname="",mcollision=false},
	["InfernalGuardian"]={charName="Annie",slot=3,type="Circle",delay=0.25,range=600,radius=251,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0.3,displayname="",mcollision=false},
	-- ["Volley"]={charName="Ashe",slot=1,type="Line",delay=0.25,range=1200,radius=60,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VolleyAttack",killTime=0,displayname="",mcollision=false},
	["EnchantedCrystalArrow"]={charName="Ashe",slot=3,type="Line",delay=0.2,range=20000,radius=130,speed=1600,addHitbox=true,danger=5,dangerous=true,proj="EnchantedCrystalArrow",killTime=0,displayname="Enchanted Arrow",mcollision=false},
	["AurelionSolQ"]={charName="AurelionSol",slot=0,type="Line",delay=0.25,range=1500,radius=180,speed=850,addHitbox=true,danger=2,dangerous=false,proj="AurelionSolQMissile",killTime=0,displayname="AurelionSolQ",mcollision=false},
	["AurelionSolR"]={charName="AurelionSol",slot=3,type="Line",delay=0.3,range=1420,radius=120,speed=4500,addHitbox=true,danger=3,dangerous=true,proj="AurelionSolRBeamMissile",killTime=0,displayname="AurelionSolR",mcollision=false},
	["BardQ"]={charName="Bard",slot=0,type="Line",delay=0.25,range=850,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="BardQMissile",killTime=0,displayname="BardQ",mcollision=true},
	["BardR"]={charName="Bard",slot=3,type="Circle",delay=0.5,range=3400,radius=350,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="BardR",killTime=1,displayname="BardR",mcollision=false},
	["RocketGrab"]={charName="Blitzcrank",slot=0,type="Line",delay=0.2,range=1050,radius=70,speed=1800,addHitbox=true,danger=4,dangerous=true,proj="RocketGrabMissile",killTime=0,displayname="Rocket Grab",mcollision=true},
	["StaticField"]={charName="Blitzcrank",slot=3,type="Circle",delay=0.25,range=0,radius=600,speed=math.huge,addHitbox=false,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Static Field",mcollision=false},
	["BrandQ"]={charName="Brand",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="BrandQMissile",killTime=0,displayname="Sear",mcollision=true},
	["BrandW"]={charName="Brand",slot=1,type="Circle",delay=0.85,range=900,radius=240,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.275,displayname="Pillar of Flame"}, -- doesnt work
	["BraumQ"]={charName="Braum",slot=0,type="Line",delay=0.25,range=1000,radius=60,speed=1700,addHitbox=true,danger=3,dangerous=true,proj="BraumQMissile",killTime=0,displayname="Winter's Bite",mcollision=true},
	["BraumRWrapper"]={charName="Braum",slot=3,type="Line",delay=0.5,range=1250,radius=115,speed=1400,addHitbox=true,danger=4,dangerous=true,proj="braumrmissile",killTime=0,displayname="Glacial Fissure",mcollision=false},
	["CaitlynPiltoverPeacemaker"]={charName="Caitlyn",slot=0,type="Line",delay=0.6,range=1300,radius=90,speed=1800,addHitbox=true,danger=2,dangerous=false,proj="CaitlynPiltoverPeacemaker",killTime=2,displayname="Piltover Peacemaker",mcollision=false},
	["CaitlynEntrapment"]={charName="Caitlyn",slot=2,type="Line",delay=0.4,range=1000,radius=70,speed=1600,addHitbox=true,danger=1,dangerous=false,proj="CaitlynEntrapmentMissile",killTime=0,displayname="90 Caliber Net",mcollision=true},
	["CassiopeiaQ"]={charName="Cassiopeia",slot=0,type="Circle",delay=0.75,range=850,radius=150,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="CassiopeiaNoxiousBlast",killTime=0.2,displayname="Noxious Blast",mcollision=false},
	["CassiopeiaR"]={charName="Cassiopeia",slot=3,type="Cone",delay=0.6,range=825,radius=80,speed=math.huge,angle=80,addHitbox=false,danger=5,dangerous=true,proj="CassiopeiaPetrifyingGaze",killTime=0,displayname="Petrifying Gaze",mcollision=false},
	["Rupture"]={charName="Chogath",slot=0,type="Circle",delay=.25,range=950,radius=250,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="Rupture",killTime=1.75,displayname="Rupture",mcollision=false},
	["PhosphorusBomb"]={charName="Corki",slot=0,type="Circle",delay=0.3,range=825,radius=250,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="PhosphorusBombMissile",killTime=0.35,displayname="Phosphorus Bomb",mcollision=false},
	["CarpetBombMega"]={charName="Corki",slot=2,type="Line",delay=0.2,range=1900,radius=140,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="CarpetBombMega",killTime=0,displayname="Special Delivery",mcollision=false},
	["MissileBarrage"]={charName="Corki",slot=3,type="Line",delay=0.2,range=1300,radius=40,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="MissileBarrageMissile",killTime=0,displayname="Missile Barrage",mcollision=true},
	["MissileBarrage2"]={charName="Corki",slot=3,type="Line",delay=0.2,range=1500,radius=40,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="MissileBarrageMissile2",killTime=0,displayname="Missile Barrage big",mcollision=true},
	["DariusCleave"]={charName="Darius",slot=0,type="Circle",delay=0.75,range=0,radius=425 - 50,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="DariusCleave",killTime=0,displayname="Cleave",mcollision=false},
	["DariusAxeGrabCone"]={charName="Darius",slot=2,type="Cone",delay=0.25,range=550,radius=80,speed=math.huge,angle=30,addHitbox=false,danger=3,dangerous=true,proj="DariusAxeGrabCone",killTime=0,displayname="Apprehend",mcollision=false},
	["DianaArc"]={charName="Diana",slot=0,type="Circle",delay=0.25,range=835,radius=195,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DianaArcArc",killTime=0,displayname="",mcollision=false},
	["DianaArcArc"]={charName="Diana",slot=0,type="Arc",delay=0.25,range=835,radius=195,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DianaArcArc",killTime=0,displayname="",mcollision=false},
	["InfectedCleaverMissileCast"]={charName="DrMundo",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=2000,addHitbox=true,danger=3,dangerous=false,proj="InfectedCleaverMissile",killTime=0,displayname="Infected Cleaver",mcollision=true},
	["DravenDoubleShot"]={charName="Draven",slot=2,type="Line",delay=0.25,range=1100,radius=130,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DravenDoubleShotMissile",killTime=0,displayname="Stand Aside",mcollision=false},
	["DravenRCast"]={charName="Draven",slot=3,type="Line",delay=0.5,range=25000,radius=160,speed=2000,addHitbox=true,danger=5,dangerous=true,proj="DravenR",killTime=0,displayname="Whirling Death",mcollision=false},
	["EkkoQ"]={charName="Ekko",slot=0,type="Line",delay=0.25,range=925,radius=60,speed=1650,addHitbox=true,danger=4,dangerous=true,proj="ekkoqmis",killTime=0,displayname="Timewinder",mcollision=false},
	["EkkoW"]={charName="Ekko",slot=1,type="Circle",delay=3.75,range=1600,radius=375,speed=1650,addHitbox=false,danger=3,dangerous=false,proj="EkkoW",killTime=1.2,displayname="Parallel Convergence",mcollision=false},
	["EkkoR"]={charName="Ekko",slot=3,type="Circle",delay=0.25,range=1600,radius=375,speed=1650,addHitbox=true,danger=3,dangerous=false,proj="EkkoR",killTime=0.2,displayname="Chronobreak",mcollision=false},
	["EliseHumanE"]={charName="Elise",slot=2,type="Line",delay=0.25,range=925,radius=55,speed=1600,addHitbox=true,danger=4,dangerous=true,proj="EliseHumanE",killTime=0,displayname="Cocoon",mcollision=true},
	["EvelynnR"]={charName="Evelynn",slot=3,type="Circle",delay=0.25,range=650,radius=350,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="EvelynnR",killTime=0.2,displayname="Agony's Embrace"},
	["EzrealMysticShot"]={charName="Ezreal",slot=0,type="Line",delay=0.25,range=1300,radius=50,speed=1975,addHitbox=true,danger=2,dangerous=false,proj="EzrealMysticShotMissile",killTime=0,displayname="Mystic Shot",mcollision=true},
	["EzrealEssenceFlux"]={charName="Ezreal",slot=1,type="Line",delay=0.25,range=1000,radius=80,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="EzrealEssenceFluxMissile",killTime=0,displayname="Essence Flux",mcollision=false},
	["EzrealTrueshotBarrage"]={charName="Ezreal",slot=3,type="Line",delay=1,range=20000,radius=150,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="EzrealTrueshotBarrage",killTime=0,displayname="Trueshot Barrage",mcollision=false},
	["FioraW"]={charName="Fiora",slot=1,type="Line",delay=0.5,range=800,radius=70,speed=3200,addHitbox=true,danger=2,dangerous=false,proj="FioraWMissile",killTime=0,displayname="Riposte",mcollision=false},
	["FizzMarinerDoom"]={charName="Fizz",slot=3,type="Line",delay=0.25,range=1150,radius=120,speed=1350,addHitbox=true,danger=5,dangerous=true,proj="FizzMarinerDoomMissile",killTime=0,displayname="Chum the Waters",mcollision=false},
	["FizzMarinerDoomMissile"]={charName="Fizz",slot=3,type="Circle",delay=0.25,range=800,radius=300,speed=1350,addHitbox=true,danger=5,dangerous=true,proj="FizzMarinerDoomMissile",killTime=0,displayname="Chum the Waters End",mcollision=false},
	["GalioResoluteSmite"]={charName="Galio",slot=0,type="Circle",delay=0.25,range=900,radius=200,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="GalioResoluteSmite",killTime=0.2,displayname="Resolute Smite",mcollision=false},
	["GalioRighteousGust"]={charName="Galio",slot=2,type="Line",delay=0.25,range=1100,radius=120,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="GalioRighteousGust",killTime=0,displayname="Righteous Ghost",mcollision=false},
	["GalioIdolOfDurand"]={charName="Galio",slot=3,type="Circle",delay=0.25,range=0,radius=550,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=1,displayname="Idol of Durand",mcollision=false},
	["GnarQ"]={charName="Gnar",slot=0,type="Line",delay=0.25,range=1200,radius=60,speed=1225,addHitbox=true,danger=2,dangerous=false,proj="gnarqmissile",killTime=0,displayname="Boomerang Throw",mcollision=false},
	["GnarQReturn"]={charName="Gnar",slot=0,type="Line",delay=0,range=1200,radius=75,speed=1225,addHitbox=true,danger=2,dangerous=false,proj="GnarQMissileReturn",killTime=0,displayname="Boomerang Throw2",mcollision=false},
	["GnarBigQ"]={charName="Gnar",slot=0,type="Line",delay=0.5,range=1150,radius=90,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="GnarBigQMissile",killTime=0,displayname="Boulder Toss",mcollision=true},
	["GnarBigW"]={charName="Gnar",slot=1,type="Line",delay=0.6,range=600,radius=80,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GnarBigW",killTime=0,displayname="Wallop",mcollision=false},
	["GnarE"]={charName="Gnar",slot=2,type="Circle",delay=0,range=473,radius=150,speed=903,addHitbox=true,danger=2,dangerous=false,proj="GnarE",killTime=0.2,displayname="GnarE",mcollision=false},
	["GnarBigE"]={charName="Gnar",slot=2,type="Circle",delay=0.25,range=475,radius=200,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="GnarBigE",killTime=0.2,displayname="GnarBigE",mcollision=false},
	["GnarR"]={charName="Gnar",slot=3,type="Circle",delay=0.25,range=0,radius=500,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=0.3,displayname="GnarUlt",mcollision=false},
	["GragasQ"]={charName="Gragas",slot=0,type="Circle",delay=0.25,range=1100,radius=275,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="GragasQMissile",killTime=4.25,displayname="Barrel Roll",mcollision=false,killName="GragasQToggle"},
	["GragasE"]={charName="Gragas",slot=2,type="Line",delay=0,range=800,radius=200,speed=800,addHitbox=true,danger=2,dangerous=false,proj="GragasE",killTime=0.5,displayname="Body Slam",mcollision=true},
	["GragasR"]={charName="Gragas",slot=3,type="Circle",delay=0.25,range=1050,radius=375,speed=1800,addHitbox=true,danger=5,dangerous=true,proj="GragasRBoom",killTime=0.3,displayname="Explosive Cask",mcollision=false},
	["GravesBasicAttack"]={charName="Graves",slot=-2,type="Cone",delay=0.2,range=750,radius=140,speed=math.huge,angle=45,addHitbox=true,danger=1,dangerous=false,proj="GravesBasicAttackSpread",killTime=1,displayname="Auto Attack",mcollision=false},
	["GravesQLineMis"]={charName="Graves",slot=0,type="Rectangle",delay=0.2,range=750,radius=140,radius2=300,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GravesQLineMis",killTime=1,displayname="Buckshot Rectangle",mcollision=false},
	["GravesClusterShotSoundMissile"]={charName="Graves",slot=0,type="Line",delay=0.2,range=750,radius=60,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0,displayname="Buckshot",mcollision=false},
	["GravesQReturn"]={charName="Graves",slot=0,type="Line",delay=0,range=750,radius=60,speed=1150,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0,displayname="Buckshot return",mcollision=false},
	["GravesSmokeGrenade"]={charName="Graves",slot=1,type="Circle",delay=0.25,range=925,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GravesSmokeGrenadeBoom",killTime=4.5,displayname="SmokeScreen",mcollision=false},
	["GravesChargeShot"]={charName="Graves",slot=3,type="Line",delay=0.2,range=1000,radius=100,speed=2100,addHitbox=true,danger=5,dangerous=true,proj="GravesChargeShotShot",killTime=0,displayname="CollateralDmg",mcollision=false},
	["GravesChargeShotFxMissile"]={charName="Graves",slot=3,type="Cone",delay=0,range=1000,radius=100,speed=2100,angle=60,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0,displayname="CollateralDmg end",mcollision=false},
	["HecarimUlt"]={charName="Hecarim",slot=3,type="Line",delay=0.2,range=1100,radius=300,speed=1200,addHitbox=true,danger=5,dangerous=true,proj="HecarimUltMissile",killTime=0.55,displayname="HecarimR",mcollision=false},
	["HeimerdingerTurretEnergyBlast"]={charName="Heimerdinger",slot=0,type="Line",delay=0.4,range=1000,radius=70,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="HeimerdingerTurretEnergyBlast",killTime=0,displayname="Turret",mcollision=false},
	["HeimerdingerW"]={charName="Heimerdinger",slot=1,type="Cone",delay=0.25,range=800,radius=70,speed=1800,angle=10,addHitbox=true,danger=2,dangerous=false,proj="HeimerdingerWAttack2",killTime=0,displayname="HeimerUltW",mcollision=true},
	["HeimerdingerE"]={charName="Heimerdinger",slot=2,type="Circle",delay=0.25,range=925,radius=100,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="heimerdingerespell",killTime=0.3,displayname="HeimerdingerE",mcollision=false},
	["IllaoiQ"]={charName="Illaoi",slot=0,type="Line",delay=0.75,range=750,radius=160,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="illaoiemis",killTime=0,displayname="",mcollision=false},
	["IllaoiE"]={charName="Illaoi",slot=2,type="Line",delay=0.25,range=1100,radius=50,speed=1900,addHitbox=true,danger=3,dangerous=true,proj="illaoiemis",killTime=0,displayname="",mcollision=true},
	["IllaoiR"]={charName="Illaoi",slot=3,type="Circle",delay=0.5,range=0,radius=450,speed=math.huge,addHitbox=false,danger=3,dangerous=true,proj="nil",killTime=0.2,displayname="",mcollision=false},
	["IreliaTranscendentBlades"]={charName="Irelia",slot=3,type="Line",delay=0,range=1200,radius=65,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="IreliaTranscendentBlades",killTime=0,displayname="Transcendent Blades",mcollision=false},
	["IvernQ"]={charName="Ivern",slot=0,type="Line",delay=0.25,range=1100,radius=65,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="IvernQ",killTime=0,displayname="",mcollision=true},
	["HowlingGaleSpell"]={charName="Janna",slot=0,type="Line",delay=0.25,range=1700,radius=120,speed=800,addHitbox=true,danger=2,dangerous=false,proj="HowlingGaleSpell",killTime=0,displayname="HowlingGale",mcollision=false},
	["JarvanIVDragonStrike"]={charName="JarvanIV",slot=0,type="Line",delay=0.6,range=770,radius=70,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="nil",killTime=0,displayname="DragonStrike",mcollision=false},
	["JarvanIVEQ"]={charName="JarvanIV",slot=0,type="Line",delay=0.25,range=880,radius=70,speed=1450,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="DragonStrike2",mcollision=false},
	["JarvanIVDemacianStandard"]={charName="JarvanIV",slot=2,type="Circle",delay=0.5,range=860,radius=175,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="JarvanIVDemacianStandard",killTime=1.5,displayname="Demacian Standard",mcollision=false},
	["JayceShockBlast"]={charName="Jayce",slot=0,type="Line",delay=0.25,range=1300,radius=70,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="JayceShockBlastMis",killTime=0,displayname="ShockBlast",mcollision=true},
	["JayceShockBlastWallMis"]={charName="Jayce",slot=0,type="Line",delay=0.25,range=1300,radius=70,speed=2350,addHitbox=true,danger=2,dangerous=false,proj="JayceShockBlastWallMis",killTime=0,displayname="ShockBlastCharged",mcollision=true},
	["JhinW"]={charName="Jhin",slot=1,type="Line",delay=0.75,range=2550,radius=40,speed=5000,addHitbox=true,danger=3,dangerous=true,proj="JhinWMissile",killTime=0,displayname="",mcollision=false},
	["JhinRShot"]={charName="Jhin",slot=3,type="Line",delay=0.25,range=3500,radius=80,speed=5000,addHitbox=true,danger=3,dangerous=true,proj="JhinRShotMis",killTime=0,displayname="JhinR",mcollision=false},
	["JinxW"]={charName="Jinx",slot=1,type="Line",delay=0.3,range=1600,radius=60,speed=2500,addHitbox=true,danger=3,dangerous=true,proj="JinxWMissile",killTime=.6,displayname="Zap",mcollision=true},
	["JinxE"]={charName="Jinx",slot=2,type="Rectangle",delay=0.25,range=1600,radius=100,radius2=275,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="JinxEHit",killTime=5,displayname="Zap",mcollision=true},
	["JinxR"]={charName="Jinx",slot=3,type="Line",delay=0.6,range=20000,radius=140,speed=1700,addHitbox=true,danger=5,dangerous=true,proj="JinxR",killTime=0,displayname="Death Rocket",mcollision=false},
	["KalistaMysticShot"]={charName="Kalista",slot=0,type="Line",delay=0.25,range=1200,radius=40,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="kalistamysticshotmis",killTime=0,displayname="MysticShot",mcollision=true},
	["KarmaQ"]={charName="Karma",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KarmaQMissile",killTime=0,displayname="",mcollision=true},
	["KarmaQMantra"]={charName="Karma",slot=0,type="Line",delay=0.25,range=950,radius=80,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KarmaQMissileMantra",killTime=0,displayname="",mcollision=true},
	["KarthusLayWasteA1"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 1",mcollision=false},
	["KarthusLayWasteA2"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 2",mcollision=false},
	["KarthusLayWasteA3"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 3",mcollision=false},
	["KarthusWallOfPain"]={charName="Karthus",slot=2,type="Rectangle",delay=0.25,range=600,radius=160,radius2=500,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=5,displayname="Wall of Pain",mcollision=false},
	["RiftWalk"]={charName="Kassadin",slot=3,type="Circle",delay=0.25,range=450,radius=270,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="RiftWalk",killTime=0.3,displayname="",mcollision=false},
	["KennenShurikenHurlMissile1"]={charName="Kennen",slot=0,type="Line",delay=0.18,range=1050,radius=50,speed=1650,addHitbox=true,danger=2,dangerous=false,proj="KennenShurikenHurlMissile1",killTime=0,displayname="Thundering Shuriken",mcollision=true},
	["KhazixW"]={charName="Khazix",slot=1,type="Line",delay=0.25,range=1025,radius=70,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KhazixWMissile",killTime=0,displayname="",mcollision=true},
	["KledE"]={charName="Kled",slot=0,type="Line",delay=0.25,range=1025,radius=70,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KhazixWMissile",killTime=0,displayname="",mcollision=true},
	["KledQ"]={charName="Kled",slot=2,type="Line",delay=0,range=750,radius=125,speed=945,addHitbox=true,danger=3,dangerous=true,proj="KledE",killTime=0,displayname="",mcollision=true},
	["KhazixE"]={charName="Khazix",slot=2,type="Circle",delay=0.25,range=600,radius=300,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="KhazixE",killTime=0.2,displayname="",mcollision=false},
	["KogMawQ"]={charName="KogMaw",slot=0,type="Line",delay=0.25,range=975,radius=70,speed=1650,addHitbox=true,danger=2,dangerous=false,proj="KogMawQ",killTime=0,displayname="",mcollision=true},
	["KogMawVoidOoze"]={charName="KogMaw",slot=2,type="Line",delay=0.25,range=1200,radius=120,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="KogMawVoidOozeMissile",killTime=0,displayname="Void Ooze",mcollision=false},
	["KogMawLivingArtillery"]={charName="KogMaw",slot=3,type="Circle",delay=0.25,range=1800,radius=225,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="KogMawLivingArtillery",killTime=1,displayname="LivingArtillery",mcollision=false},
	["LeblancSlide"]={charName="Leblanc",slot=1,type="Circle",delay=0,range=600,radius=220,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LeblancSlide",killTime=0.2,displayname="Slide",mcollision=false},
	["LeblancSlideM"]={charName="Leblanc",slot=3,type="Circle",delay=0,range=600,radius=220,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LeblancSlideM",killTime=0.2,displayname="Slide R",mcollision=false},
	["LeblancSoulShackle"]={charName="Leblanc",slot=2,type="Line",delay=0,range=950,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeblancSoulShackle",killTime=0,displayname="Ethereal Chains R",mcollision=true},
	["LeblancSoulShackleM"]={charName="Leblanc",slot=3,type="Line",delay=0,range=950,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeblancSoulShackleM",killTime=0,displayname="Ethereal Chains",mcollision=true},
	["BlindMonkQOne"]={charName="LeeSin",slot=0,type="Line",delay=0.25,range=1000,radius=80,speed=1800,addHitbox=true,danger=3,dangerous=true,proj="BlindMonkQOne",killTime=0,displayname="Sonic Wave",mcollision=true},
	["LeonaZenithBlade"]={charName="Leona",slot=2,type="Line",delay=0.25,range=875,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeonaZenithBladeMissile",killTime=0,displayname="Zenith Blade",mcollision=false},
	["LeonaSolarFlare"]={charName="Leona",slot=3,type="Circle",delay=1,range=1200,radius=300,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="LeonaSolarFlare",killTime=0.5,displayname="Solar Flare",mcollision=false},
	["LissandraQ"]={charName="Lissandra",slot=0,type="Line",delay=0.25,range=700,radius=75,speed=2200,addHitbox=true,danger=2,dangerous=false,proj="LissandraQMissile",killTime=0,displayname="Ice Shard",mcollision=false},
	["LissandraQShards"]={charName="Lissandra",slot=0,type="Line",delay=0.25,range=700,radius=90,speed=2200,addHitbox=true,danger=2,dangerous=false,proj="lissandraqshards",killTime=0,displayname="Ice Shard2",mcollision=false},
	["LissandraE"]={charName="Lissandra",slot=2,type="Line",delay=0.25,range=1025,radius=125,speed=850,addHitbox=true,danger=2,dangerous=false,proj="LissandraEMissile",killTime=0,displayname="",mcollision=false},
	["LucianQ"]={charName="Lucian",slot=0,type="Line",delay=0.5,range=800,radius=65,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="LucianQ",killTime=0,displayname="",mcollision=false},
	["LucianW"]={charName="Lucian",slot=1,type="Line",delay=0.2,range=1000,radius=55,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="lucianwmissile",killTime=0,displayname="",mcollision=true},
	["LucianRMis"]={charName="Lucian",slot=3,type="Line",delay=0.5,range=1400,radius=110,speed=2800,addHitbox=true,danger=2,dangerous=false,proj="lucianrmissileoffhand",killTime=0,displayname="LucianR",mcollision=true},
	["LuluQ"]={charName="Lulu",slot=0,type="Line",delay=0.25,range=950,radius=60,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LuluQMissile",killTime=0,displayname="",mcollision=false},
	["LuluQPix"]={charName="Lulu",slot=0,type="Line",delay=0.25,range=950,radius=60,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LuluQMissileTwo",killTime=0,displayname="",mcollision=false},
	["LuxLightBinding"]={charName="Lux",slot=0,type="Line",delay=0.3,range=1300,radius=70,speed=1200,addHitbox=true,danger=3,dangerous=true,proj="LuxLightBindingMis",killTime=0,displayname="Light Binding",mcollision=true},
	["LuxLightStrikeKugel"]={charName="Lux",slot=2,type="Circle",delay=0.25,range=1100,radius=350,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="LuxLightStrikeKugel",killTime=5.25,displayname="LightStrikeKugel",mcollision=false,killName="LuxLightstrikeToggle"},
	["LuxMaliceCannon"]={charName="Lux",slot=3,type="Line",delay=1.5,range=3500,radius=190,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="LuxMaliceCannon",killTime=2,displayname="Malice Cannon",mcollision=false},
	["UFSlash"]={charName="Malphite",slot=3,type="Circle",delay=0,range=1000,radius=270,speed=1500,addHitbox=true,danger=5,dangerous=true,proj="UFSlash",killTime=0.4,displayname="",mcollision=false},
	["MalzaharQ"]={charName="Malzahar",slot=0,type="Rectangle",delay=0.75,range=900,radius2=475,radius=130,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="MalzaharQMissile",killTime=0.5,displayname="",mcollision=false},
	["DarkBindingMissile"]={charName="Morgana",slot=0,type="Line",delay=0.2,range=1300,radius=80,speed=1200,addHitbox=true,danger=3,dangerous=true,proj="DarkBindingMissile",killTime=0,displayname="Dark Binding",mcollision=true},
	["NamiQ"]={charName="Nami",slot=0,type="Circle",delay=0.95,range=1625,radius=200,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="NamiQMissile",killTime=0.35,displayname="",mcollision=false},
	["NamiR"]={charName="Nami",slot=3,type="Line",delay=0.8,range=2750,radius=260,speed=850,addHitbox=true,danger=2,dangerous=false,proj="NamiRMissile",killTime=0,displayname="",mcollision=false},
	["NautilusAnchorDrag"]={charName="Nautilus",slot=0,type="Line",delay=0.25,range=1080,radius=90,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="NautilusAnchorDragMissile",killTime=0,displayname="Anchor Drag",mcollision=true},
	["AbsoluteZero"]={charName="Nunu",slot=3,type="Circle",delay=0.25,range=0,radius=750,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=4,displayname="",mcollision=false},
	["NocturneDuskbringer"]={charName="Nocturne",slot=0,type="Line",delay=0.25,range=1125,radius=60,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="NocturneDuskbringer",killTime=0,displayname="Duskbringer",mcollision=false},
	["JavelinToss"]={charName="Nidalee",slot=0,type="Line",delay=0.25,range=1500,radius=40,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="JavelinToss",killTime=0,displayname="JavelinToss",mcollision=true},
	["OlafAxeThrowCast"]={charName="Olaf",slot=0,type="Line",delay=0.25,range=1000,radius=105,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="olafaxethrow",killTime=0,displayname="Axe Throw",mcollision=false},
	["OriannaIzunaCommand"]={charName="Orianna",slot=0,type="Line",delay=0,range=1500,radius=80,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="orianaizuna",killTime=0,displayname="",mcollision=false},
	["OrianaDissonanceCommand-"]={charName="Orianna",slot=1,type="Circle",delay=0.25,range=0,radius=255,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="OrianaDissonanceCommand-",killTime=0.3,displayname="",mcollision=false},
	["OriannasE"]={charName="Orianna",slot=2,type="Line",delay=0,range=1500,radius=85,speed=1850,addHitbox=true,danger=2,dangerous=false,proj="orianaredact",killTime=0,displayname="",mcollision=false},
	["OrianaDetonateCommand-"]={charName="Orianna",slot=3,type="Circle",delay=0.7,range=0,radius=410,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="OrianaDetonateCommand-",killTime=0.5,displayname="",mcollision=false},
	["QuinnQ"]={charName="Quinn",slot=0,type="Line",delay=0,range=1050,radius=60,speed=1550,addHitbox=true,danger=2,dangerous=false,proj="QuinnQ",killTime=0,displayname="",mcollision=true},
	["PoppyQ"]={charName="Poppy",slot=0,type="Line",delay=0.5,range=430,radius=120,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="PoppyQ",killTime=1,displayname="",mcollision=false},
	["PoppyRSpell"]={charName="Poppy",slot=3,type="Line",delay=0.3,range=1200,radius=100,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="PoppyRMissile",killTime=0,displayname="PoppyR",mcollision=false},
	["RengarE"]={charName="Rengar",slot=2,type="Line",delay=0.25,range=1000,radius=70,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="RengarEFinal",killTime=0,displayname="",mcollision=true},
	["reksaiqburrowed"]={charName="RekSai",slot=0,type="Line",delay=0.5,range=1050,radius=60,speed=1550,addHitbox=true,danger=3,dangerous=false,proj="RekSaiQBurrowedMis",killTime=0,displayname="RekSaiQ",mcollision=true},
	["RivenWindslashMissileRight"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Right",mcollision=false},
	["RivenWindslashMissileCenter"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Center",mcollision=false},
	["RivenWindslashMissileLeft"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Left",mcollision=false},
	-- ["RivenMartyr"]={charName="Riven",slot=1,type="Circle",delay=0.25,range=0,radius=300,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=0.2,displayname="RivenW",mcollision=false},
	["RumbleGrenade"]={charName="Rumble",slot=2,type="Line",delay=0.25,range=850,radius=60,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="RumbleGrenade",killTime=0,displayname="Grenade",mcollision=true},
	["RumbleCarpetBombM"]={charName="Rumble",slot=3,type="Line",delay=0.4,range=1700,radius=200,speed=1600,addHitbox=true,danger=4,dangerous=false,proj="RumbleCarpetBombMissile",killTime=0,displayname="Carpet Bomb",mcollision=false}, --doesnt work
	["RyzeQ"]={charName="Ryze",slot=0,type="Line",delay=0,range=900,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="RyzeQ",killTime=0,displayname="",mcollision=true},
	["ryzerq"]={charName="Ryze",slot=0,type="Line",delay=0,range=900,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ryzerq",killTime=0,displayname="RyzeQ R",mcollision=true},
	["SejuaniArcticAssault"]={charName="Sejuani",slot=0,type="Line",delay=0,range=900,radius=70,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="ArcticAssault",mcollision=true},
	["SejuaniGlacialPrisonStart"]={charName="Sejuani",slot=3,type="Line",delay=0.25,range=1200,radius=110,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="sejuaniglacialprison",killTime=0,displayname="GlacialPrisonStart",mcollision=false},
	["SionE"]={charName="Sion",slot=2,type="Line",delay=0.25,range=800,radius=80,speed=1800,addHitbox=true,danger=3,dangerous=true,proj="SionEMissile",killTime=0,displayname="",mcollision=false},
	["SionR"]={charName="Sion",slot=3,type="Line",delay=0.5,range=20000,radius=120,speed=1000,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="",mcollision=false},
	["SorakaQ"]={charName="Soraka",slot=0,type="Circle",delay=0,range=950,radius=300,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.75,displayname="",mcollision=false},
	["SorakaE"]={charName="Soraka",slot=2,type="Circle",delay=0,range=925,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=2,displayname="",mcollision=false},
	["ShenE"]={charName="Shen",slot=2,type="Line",delay=0,range=650,radius=50,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="ShenE",killTime=0,displayname="Shadow Dash",mcollision=false},
	["ShyvanaFireball"]={charName="Shyvana",slot=2,type="Line",delay=0.25,range=925,radius=60,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ShyvanaFireballMissile",killTime=0,displayname="Fireball",mcollision=false},
	["ShyvanaTransformCast"]={charName="Shyvana",slot=3,type="Line",delay=0.25,range=750,radius=150,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="ShyvanaTransformCast",killTime=0,displayname="Transform Cast",mcollision=false},
	["shyvanafireballdragon2"]={charName="Shyvana",slot=3,type="Line",delay=0.25,range=925,radius=70,speed=2000,addHitbox=true,danger=3,dangerous=false,proj="ShyvanaFireballDragonFxMissile",killTime=0,displayname="Fireball Dragon",mcollision=false},
	["SivirQMissileReturn"]={charName="Sivir",slot=0,type="Return",delay=0,range=1075,radius=100,speed=1350,addHitbox=true,danger=2,dangerous=false,proj="SivirQMissileReturn",killTime=0,displayname="SivirQ2",mcollision=false},
	["SivirQ"]={charName="Sivir",slot=0,type="Line",delay=0.25,range=1075,radius=90,speed=1350,addHitbox=true,danger=2,dangerous=false,proj="SivirQMissile",killTime=0,displayname="SivirQ",mcollision=false},
	["SkarnerFracture"]={charName="Skarner",slot=2,type="Line",delay=0.35,range=350,radius=70,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="SkarnerFractureMissile",killTime=0,displayname="Fracture",mcollision=false},
	["SonaR"]={charName="Sona",slot=3,type="Line",delay=0.25,range=900,radius=140,speed=2400,addHitbox=true,danger=5,dangerous=true,proj="SonaR",killTime=0,displayname="Crescendo",mcollision=false},
	["SwainShadowGrasp"]={charName="Swain",slot=1,type="Circle",delay=0.25,range=900,radius=180,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="SwainShadowGrasp",killTime=1.5,displayname="Shadow Grasp",mcollision=false},
	["SyndraQ"]={charName="Syndra",slot=0,type="Circle",delay=0.6,range=800,radius=150,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="SyndraQSpell",killTime=0.2,displayname="",mcollision=false},
	["SyndraWCast"]={charName="Syndra",slot=1,type="Circle",delay=0.25,range=950,radius=210,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="syndrawcast",killTime=0.2,displayname="SyndraW",mcollision=false},
	["SyndraE"]={charName="Syndra",slot=2,type="Cone",delay=0,range=950,radius=100,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="SyndraEMissile",killTime=0,displayname="SyndraE",mcollision=false},
	["syndrae5"]={charName="Syndra",slot=2,type="Line",delay=0,range=950,radius=100,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="syndrae5",killTime=0,displayname="SyndraE2",mcollision=false},
	["TalonRake"]={charName="Talon",slot=1,type="Cone",delay=0.25,range=800,radius=80,speed=2300,angle=45,addHitbox=true,danger=2,dangerous=true,proj="talonrakemissileone",killTime=0,displayname="Rake",mcollision=false},
	["TalonRakeMissileTwo"]={charName="Talon",slot=1,type="Cone",delay=0.25,range=800,radius=80,speed=1850,angle=45,addHitbox=true,danger=2,dangerous=true,proj="talonrakemissiletwo",killTime=0,displayname="Rake2",mcollision=false},
	["TahmKenchQ"]={charName="TahmKench",slot=0,type="Line",delay=0.25,range=951,radius=90,speed=2800,addHitbox=true,danger=3,dangerous=true,proj="tahmkenchqmissile",killTime=0,displayname="Tongue Slash",mcollision=true},
	["TaricE"]={charName="Taric",slot=2,type="follow",delay=0.25,range=750,radius=100,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="TaricE",killTime=1.25,displayname="",mcollision=false},
	["ThreshQ"]={charName="Thresh",slot=0,type="Line",delay=0.5,range=1050,radius=70,speed=1900,addHitbox=true,danger=3,dangerous=true,proj="ThreshQMissile",killTime=0,displayname="",mcollision=true},
	["ThreshEFlay"]={charName="Thresh",slot=2,type="Line",delay=0.125,range=500,radius=110,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="ThreshEMissile1",killTime=0,displayname="Flay",mcollision=false},
	["RocketJump"]={charName="Tristana",slot=1,type="Circle",delay=0.5,range=900,radius=270,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="RocketJump",killTime=0.3,displayname="",mcollision=false},
	["TryndamereE"]={charName="Tryndamere",slot=2,type="Line",delay=0,range=700,radius=93,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="Slash",killTime=0.5,displayname="",mcollision=false},
	["WildCards"]={charName="TwistedFate",slot=0,type="Line",delay=0.25,range=1450,radius=40,speed=1000,angle=28,addHitbox=true,danger=2,dangerous=false,proj="SealFateMissile",killTime=0,displayname="",mcollision=false},
	["TwitchVenomCask"]={charName="Twitch",slot=1,type="Circle",delay=0.25,range=900,radius=275,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="TwitchVenomCaskMissile",killTime=0.3,displayname="Venom Cask",mcollision=false},
	["TwitchSprayAndPrayAttack"]={charName="Twitch",slot=3,type="Line",delay=0.1,range=1200,radius=100,speed=1800,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.5,displayname="Venom Cask",mcollision=false},
	["UrgotHeatseekingLineMissile"]={charName="Urgot",slot=0,type="Line",delay=0.125,range=1000,radius=60,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="UrgotHeatseekingLineMissile",killTime=0,displayname="Heatseeking Line",mcollision=true},
	["UrgotPlasmaGrenade"]={charName="Urgot",slot=2,type="Circle",delay=0.25,range=1100,radius=210,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="UrgotPlasmaGrenadeBoom",killTime=0.3,displayname="PlasmaGrenade",mcollision=false},
	["VarusQMissile"]={charName="Varus",slot=0,type="Line",delay=0.25,range=1475,radius=70,speed=1900,addHitbox=true,danger=2,dangerous=false,proj="VarusQMissile",killTime=0,displayname="VarusQ",mcollision=false},
	["VarusE"]={charName="Varus",slot=2,type="Circle",delay=0.25,range=925,radius=235,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VarusE",killTime=2.25,displayname="",mcollision=false},
	["VarusR"]={charName="Varus",slot=3,type="Line",delay=0.25,range=800,radius=120,speed=1950,addHitbox=true,danger=3,dangerous=true,proj="VarusRMissile",killTime=0,displayname="",mcollision=false},
	["VeigarBalefulStrike"]={charName="Veigar",slot=0,type="Line",delay=0.1,range=900,radius=70,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VeigarBalefulStrikeMis",killTime=0,displayname="BalefulStrike",mcollision=false},
	["VeigarDarkMatter"]={charName="Veigar",slot=1,type="Circle",delay=1.35,range=900,radius=225,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.5,displayname="DarkMatter",mcollision=false},
	["VeigarEventHorizon"]={charName="Veigar",slot=2,type="Ring",delay=0.5,range=700,radius=400,speed=math.huge,addHitbox=false,danger=3,dangerous=true,proj="nil",killTime=3.5,displayname="EventHorizon",mcollision=false},
	["VelkozQ"]={charName="Velkoz",slot=0,type="Line",delay=0.25,range=1100,radius=50,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="VelkozQMissile",killTime=0,displayname="",mcollision=true},
	["VelkozQMissileSplit"]={charName="Velkoz",slot=0,type="Line",delay=0.25,range=1100,radius=55,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="VelkozQMissileSplit",killTime=0,displayname="",mcollision=true},
	["VelkozW"]={charName="Velkoz",slot=1,type="Line",delay=0.25,range=1050,radius=88,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="VelkozWMissile",killTime=0,displayname="",mcollision=false},
	["VelkozE"]={charName="Velkoz",slot=2,type="Circle",delay=0.5,range=800,radius=225,speed=1500,addHitbox=false,danger=2,dangerous=false,proj="VelkozEMissile",killTime=0.5,displayname="",mcollision=false},
	["Vi-q"]={charName="Vi",slot=0,type="Line",delay=0.25,range=715,radius=90,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="ViQMissile",killTime=0,displayname="Vi-Q",mcollision=false},
	["VladimirR"] = {charName = "Vladimir",slot=3,type="Circle",delay=0.25,range=700,radius=175,speed=math.huge,addHitbox=true,danger=4,dangerous=true,proj="nil",killTime=0,displayname = "Hemoplague",mcollision=false},
	["Laser"]={charName="Viktor",slot=2,type="Line",delay=0.25,range=1200,radius=80,speed=1050,addHitbox=true,danger=2,dangerous=false,proj="ViktorDeathRayMissile",killTime=0,displayname="",mcollision=false},
	["XerathArcanopulse2"]={charName="Xerath",slot=0,type="Line",delay=0.6,range=1600,radius=95,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="xeratharcanopulse2",killTime=0.5,displayname="Arcanopulse",mcollision=false},
	["XerathArcaneBarrage2"]={charName="Xerath",slot=1,type="Circle",delay=0.7,range=1000,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="XerathArcaneBarrage2",killTime=0.3,displayname="ArcaneBarrage",mcollision=false},
	["XerathMageSpear"]={charName="Xerath",slot=2,type="Line",delay=0.2,range=1300,radius=60,speed=1400,addHitbox=true,danger=2,dangerous=true,proj="XerathMageSpearMissile",killTime=0,displayname="MageSpear",mcollision=true},
	["XerathLocusPulse"]={charName="Xerath",slot=3,type="Circle",delay=0.7,range=5600,radius=225,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="XerathRMissileWrapper",killTime=0.4,displayname="",mcollision=false},
	["YasuoQ3W"]={charName="Yasuo",slot=0,type="Line",delay=0.4,range=1200,radius=90,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="YasuoQ3",killTime=0,displayname="Steel Tempest ",mcollision=false},
	["ZacQ"]={charName="Zac",slot=0,type="Line",delay=0.5,range=550,radius=120,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZacQ",killTime=0,displayname="",mcollision=false},
	["ZedQ"]={charName="Zed",slot=0,type="Line",delay=0.25,range=925,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ZedQMissile",killTime=0,displayname="",mcollision=false},
	["ZiggsQSpell"]={charName="Ziggs",slot=0,type="Circle",delay=0.5,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell",killTime=0.2,displayname="",mcollision=false},
	["ZiggsQSpell2"]={charName="Ziggs",slot=0,type="Circle",delay=0.47,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell2",killTime=-0.23,displayname="",mcollision=true},
	["ZiggsQSpell3"]={charName="Ziggs",slot=0,type="Circle",delay=0.44,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell3",killTime=-0.26,displayname="",mcollision=true},
	["ZiggsW"]={charName="Ziggs",slot=1,type="Circle",delay=0.25,range=1000,radius=275,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsW",killTime=4.1,displayname="",mcollision=false,killName="ZiggsWToggle"},
	["ZiggsE"]={charName="Ziggs",slot=2,type="Circle",delay=0.5,range=900,radius=250,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsE",killTime=10,displayname="",mcollision=false},
	["ZiggsR"]={charName="Ziggs",slot=3,type="Circle",delay=0,range=5300,radius=500,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZiggsR",killTime=1.25,displayname="",mcollision=false},
	["ZileanQ"]={charName="Zilean",slot=0,type="Circle",delay=0.3,range=900,radius=210,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="ZileanQMissile",killTime=1.5,displayname="",mcollision=false},
	["ZyraQ"]={charName="Zyra",slot=0,type="Rectangle",delay=0.4,range=800,radius2=400,radius=140,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZyraQ",killTime=0.35,displayname="",mcollision=false},
	["ZyraE"]={charName="Zyra",slot=2,type="Line",delay=0.25,range=1100,radius=70,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="ZyraE",killTime=0,displayname="Grasping Roots",mcollision=false},
	--["ZyraRSplash"]={charName="Zyra",slot=3,type="Circle",delay=0.7,range=700,radius=550,speed=math.huge,addHitbox=true,danger=4,dangerous=false,proj="ZyraRSplash",killTime=1,displayname="Splash",mcollision=false},--bugged spell
}

self.EvadeSpells = {
	["Ahri"] = {
		[3] = {dl = 4,name = "AhriTumble",range = 500,spellDelay = 50,speed = 1575,spellKey = 3,evadeType = "DashP",castType = "Position",},
	},
	["Caitlyn"] = {
		[2] = {dl = 3,name = "CaitlynEntrapment",range = 490,spellDelay = 50,speed = 1000,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},	
	["Corki"] = {
		[1] = {dl = 3,name = "CarpetBomb",range = 790,spellDelay = 50,speed = 975,spellKey = 1,evadeType = "DashP",castType = "Position",},
	},	
	["Ekko"] = {
		[2] = {dl = 3,name = "PhaseDive",range = 350,spellDelay = 50,speed = 1150,spellKey = 2,evadeType = "DashP",castType = "Position",},
		[3] = {dl = 4,name = "Chronobreak",range = 20000,spellDelay = 50,spellKey = 3,evadeType = "DashS",castType = "Self",},
	},
	["Ezreal"] = {
		[2] = {dl = 2,name = "ArcaneShift",speed = math.huge,range = 450,spellDelay = 250,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},	
	["Gragas"] = {
		[2] = {dl = 2,name = "BodySlam",range = 600,spellDelay = 50,speed = 900,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},	
	["Gnar"] = {
		[2] = {dl = 3,name = "GnarE",range = 475,spellDelay = 50,speed = 900,spellKey = 2,evadeType = "DashP",castType = "Position",},
		[2] = {dl = 4,name = "GnarBigE",range = 475,spellDelay = 50,speed = 800,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},
	["Graves"] = { 
		[2] = {dl = 2,name = "QuickDraw",range = 425,spellDelay = 50,speed = 1250,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},	
	["Heimerdinger"] = {
		[0] = {dl = 3,name = "Turret",range = 425,spellDelay = 50,speed = 1250,spellKey = 0,evadeType = "WindWallP",castType = "Position",}
	},
	["Kassadin"] = { 
		[3] = {dl = 1,name = "RiftWalk",speed = math.huge,range = 450,spellDelay = 250,spellKey = 3,evadeType = "DashP",castType = "Position",},
	},	
	-- ["Kayle"] = { 
		-- [3] = {dl = 4,name = "Intervention",speed = math.huge,range = 0,spellDelay = 250,spellKey = 3,evadeType = "SpellShieldT",castType = "Target",},
	-- },	
	["LeBlanc"] = { 
		[1] = {dl = 2,name = "Distortion",range = 600,spellDelay = 50,speed = 1600,spellKey = 1,evadeType = "DashP",castType = "Position",},
	},	
	-- ["LeeSin"] = { 
		-- [1] = {dl = 3,name = "Safeguard",range = 700,speed = 1400,spellDelay = 50,spellKey = 1,evadeType = "DashT",castType = "Target",},
	-- },
	["Lucian"] = { 
		[2] = {dl = 1,name = "RelentlessPursuit",range = 425,spellDelay = 50,speed = 1350,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},	
	["Morgana"] = {
		[2] = {dl = 3,name = "BlackShield",speed = math.huge,range = 650,spellDelay = 50,spellKey = 2,evadeType = "SpellShieldT",castType = "Target",},
	},	
	["Nocturne"] = { 
		[1] = {dl = 3,name = "ShroudofDarkness",speed = math.huge,range = 0,spellDelay = 50,spellKey = 1,evadeType = "SpellShieldS",castType = "Self",},
	},	
	["Nidalee"] = { 
		[1] = {dl = 3,name = "Pounce",range = 375,spellDelay = 150,speed = 1750,spellKey = 1,evadeType = "DashP",castType = "Position",},
	},	
	["Fiora"] = {
		[0] = {dl = 3,name = "FioraQ",range = 340,speed = 1100,spellDelay = 50,spellKey = 0,evadeType = "DashP",castType = "Position",},
		--[1] = {dl = 3,name = "FioraW",range = 750,spellDelay = 100,spellKey = 1,evadeType = "WindWallP",castType = "Position",},
	},
	["Fizz"] = { 
		[2] = {dl = 3,name = "FizzJump",range = 400,speed = 1400,spellDelay = 50,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},	
	["Riven"] = {
		[0] = {dl = 1,name = "BrokenWings",range = 260,spellDelay = 50,speed = 560,spellKey = 0,evadeType = "DashP",castType = "Position",},
		[2] = {dl = 2,name = "Valor",range = 325,spellDelay = 50,speed = 1200,spellKey = 2,evadeType = "DashP",castType = "Position",},
	},
	["Sivir"] = { 
		[2] = {dl = 2,name = "SivirE",spellDelay = 50,spellKey = 2,evadeType = "SpellShieldS",castType = "Self",BuffName = "SivirE"},
	},	
	["Shaco"] = {
		[0] = {dl = 3,name = "Deceive",range = 400,spellDelay = 250,spellKey = 0,evadeType = "DashP",castType = "Position",},
		[1] = {dl = 3,name = "JackInTheBox",range = 425,spellDelay = 250,spellKey = 1,evadeType = "WindWallP",castType = "Position",},
	},
	["Shen"] = { 
		[2] = {dl = 4,name = "Shadow Dash",spellDelay = 0,spellKey = 2,evadeType = "DashP",castType = "Position"},
	},
	["Tristana"] = { 
		[1] = {dl = 3,name = "RocketJump",range = 900,spellDelay = 500,speed = 1100,spellKey = 1,evadeType = "DashP",castType = "Position",},       
	},
	["Tryndamere"] = { 
		[2] = {dl = 3,name = "SpinningSlash",range = 660,spellDelay = 50,speed = 900,spellKey = 2,evadeType = "DashP",castType = "Position",},   
	},	
	["Vayne"] = { 
		[0] = {dl = 2,name = "Tumble",range = 300,speed = 900,spellDelay = 50,spellKey = 0,evadeType = "DashP",castType = "Position",},
	},	
	["Yasuo"] = {
		[1] = {dl = 3,name = "WindWall",range = 400,spellDelay = 250,spellKey = 1,evadeType = "WindWallP",castType = "Position",},
		--[2] = {dl = 2,name = "SweepingBlade",range = 475,speed = 1000,spellDelay = 50,spellKey = 2,evadeType = "DashT",castType = "Target",},
	},
	["Vladimir"] = { 
		[1] = {dl = 4,name = "Sanguine Pool",range = 350,spellDelay = 50,spellKey = 1,evadeType = "SpellShieldS",castType = "Self",	},
	},	
	-- ["MasterYi"] = { 
		-- [0] = {dl = 3,name = "AlphaStrike",range = 600,speed = math.huge,spellDelay = 100,spellKey = 0,evadeType = "DashT",castType = "Target",},
	-- },	
	-- ["Katarina"] = { 
		-- [2] = {dl = 3,name = "KatarinaE",range = 700,speed = math.huge,spellKey = 2,evadeType = "DashT",castType = "Target",	},
	-- },	
	["Kindred"] = { 
		[0] = {dl = 1,name = "KindredQ",range = 300,speed = 733,spellDelay = 50,spellKey = 0,evadeType = "DashP",castType = "Position",},
	},	
	-- ["Talon"] = { 
		-- [2] = {dl = 3,name = "Cutthroat",range = 700,speed = math.huge,spellDelay = 50,spellKey = 2,evadeType = "DashT",castType = "Target",},
	-- },
}
DelayAction(function()
	for _,i in pairs(Spells) do
		for kk,k in pairs(GetEnemyHeroes()) do
			if i.displayname == "" then i.displayname = _ end
			if i.charName == k.charName then
				if self.supportedtypes[i.type].supported == false then
					print("<font color=\"#FFFFF\"><b>"..i.charName.." - spell : "..self.str[i.slot].." | "..i.displayname.. "<font color=\"#FFFFFF\"> is not supported </b></font>")
				end
			end
		end
	end
end,001.25)

self.offer = 0
self.count = 0

end

function SLEvade:WndMsg(s1,s2)
	if s2 == string.byte("Y") and s1 == 257 and EMenu.D:Value() then
		self:Skillshot()
		self.offer = self.offer+1
	end
	if s2 == 0 and s1 == 516 then
		self.count = self.count+1
	end
	DelayAction(function() self.count = 0 end,.001)
end

function SLEvade:Skillshot()
		local s = {}
		s.spell = {}
		s.startPos = Vector(2874,myHero.pos.y,2842)--GetMousePos()
		s.spell.name = "DarkBindingMissile"..self.offer
		s.spell.charName = myHero.charName
		s.spell.proj = nil
		s.spell.danger = 2
		s.spell.slot = 0
		s.spell.displayname = "DarkBinding"..self.offer
        s.spell.killTime = 1.5
        s.spell.mcollision = true
        s.spell.dangerous = false
        s.spell.radius = 130
        s.spell.speed = 400
        s.spell.delay = 1
		s.spell.range = 1300
        s.endp = Vector(2104,myHero.pos.y,3196)--Vector(GetMousePos()) + Vector(Vector(myHero) - GetMousePos()):normalized() * (s.spell.range + myHero.boundingRadius)	
		s.endPos = Vector(s.startPos)+Vector(Vector(s.endp)-s.startPos):normalized()*s.spell.range
        s.spell.type = "Line"
        s.uDodge = false 
        s.caster = myHero
		s.range = 1200
        s.mpos = nil
		s.debug = true
		s.humanizer= true
		s.check = GetDistance(myHero,s.startPos)/s.spell.speed+s.spell.delay
		s.check2 = GetDistance(myHero,s.endPos)/s.spell.speed+s.spell.delay+s.spell.killTime
		s.dist = GetDistance(myHero,s.endPos)
        s.startTime = os.clock()
        self.obj[s.spell.charName..""..self.str[s.spell.slot]..""..s.spell.displayname] = s
		DelayAction(function() self.obj[s.spell.charName..""..self.str[s.spell.slot]..""..s.spell.displayname] = nil end,s.spell.killTime+s.spell.delay)
end

function SLEvade:Tickp()
if not SLE then return end
	heroes[myHero.networkID] = nil
	for _,i in pairs(self.obj) do
		if i.o and EMenu.Advanced.LDR:Value() and i.spell.type == "Line" and GetDistance(myHero,i.o) >= 3000 and not self.globalults[_] then return end
		if i.o and EMenu.Advanced.LDR:Value() and i.spell.type == "Return" and GetDistance(myHero,i.o) >= 3000 and not self.globalults[_] then return end
		if i and EMenu.Advanced.LDR:Value() and (i.spell.type == "Circle" or i.spell.type =="follow") and GetDistance(myHero,i.endPos) >= 3000 and not self.globalults[_] then return end
		if i and EMenu.Advanced.LDR:Value() and i.spell.type == "Rectangle" and GetDistance(myHero,i.endPos) >= 3000 and not self.globalults[_] then return end
		if i and EMenu.Advanced.LDR:Value() and i.spell.type == "Cone" and GetDistance(myHero,i.endPos) >= 3000 and not self.globalults[_] then return end
		if not i.jp or not i.safe then
			self.asd = false
			DisableHoldPosition(false)
			DisableAll(false)
		end
		if i then
			self:CleanObj(_,i) 
			self:Dodge(_,i) 
			self:Pathfinding(_,i)
			self:UDodge(_,i)
			self:Mpos(_,i)
		end
		if not i.safe then
			_G.IsEvading = false
		end
		if i.jp and (GetDistance(myHero,i.jp) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "Line" then
			i.safe = nil
		elseif i and (GetDistance(myHero,i.endPos) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "Circle" then
			i.safe = nil
		elseif i.jp and (GetDistance(myHero,i.jp) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "Rectangle" then
			i.safe = nil
		elseif i.jp and (GetDistance(myHero,i.jp) > i.spell.radius + myHero.boundingRadius) and i.safe and i.spell.type == "Cone" then
			i.safe = nil
		end
	end
	self:ItemMenu()
end

function SLEvade:Drawp()
if not SLE then return end
	for _,i in pairs(self.obj) do
		if i.o and EMenu.Advanced.LDR:Value() and i.spell.type == "Line" and GetDistance(myHero,i.o) >= 3000 and not self.globalults[_] then return end
		if i.o and EMenu.Advanced.LDR:Value() and i.spell.type == "Return" and GetDistance(myHero,i.o) >= 3000 and not self.globalults[_] then return end
		if i and EMenu.Advanced.LDR:Value() and (i.spell.type == "Circle" or i.spell.type =="follow") and GetDistance(myHero,i.endPos) >= 3000 and not self.globalults[_] then return end
		if i and EMenu.Advanced.LDR:Value() and i.spell.type == "Rectangle" and GetDistance(myHero,i.endPos) >= 3000 and not self.globalults[_] then return end
		if i and EMenu.Advanced.LDR:Value() and i.spell.type == "Cone" and GetDistance(myHero,i.endPos) >= 3000 and not self.globalults[_] then return end
		if i then
			self.opos = self:sObjpos(_,i)
			self.cpos = self:sCircPos(_,i)
			self:Drawings(_,i)
			self:Drawings2(_,i)
		end
	self:HeroCollsion(_,i)
	self:MinionCollision(_,i)
	self:WallCollision(_,i)
	end
	if EMenu.Draws.DevOpt:Value() then
		DrawText(myHero.pos,20,20,20,GoS.Green)
	end
	if EMenu.Draws.DES:Value() then
		self:Status()
	end
end

function SLEvade:MinionCollision(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i and EMenu.Advanced.EMC:Value() and (i.debug or EMenu.Spells[_]["Coll".._]:Value()) and not i.hcoll and not i.wcoll then
		for m,p in pairs(SLM2) do
			if p and p.alive and GetDistance(p.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.pos))
				if i.vP and GetDistance(i.vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,i.vP)
					i.mcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function SLEvade:HeroCollsion(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i and EMenu.Advanced.EMC:Value() and (i.debug or EMenu.Spells[_]["Coll".._]:Value()) and not i.mcoll and not i.wcoll then
		for m,p in pairs(heroes) do
			if p and p.alive and p.team == MINION_ALLY and GetDistance(p.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.pos))
				if i.vP and GetDistance(i.vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,i.vP)
					i.hcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function SLEvade:WallCollision(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i and EMenu.Advanced.EMC:Value() and (i.debug or EMenu.Spells[_]["Coll".._]:Value()) and not i.mcoll and not i.hcoll then
		for m,p in pairs(self.YasuoWall) do
			if p.obj and p.obj.valid and p.obj.spellOwner.team == MINION_ALLY and GetDistance(p.obj.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.obj.pos))
				if i.vP and GetDistance(i.vP,p.obj.pos) < (i.spell.radius+p.obj.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,i.vP)
					i.wcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function SLEvade:sObjpos(_,i)
	if i.spell.speed ~= math.huge and i and os.clock() > i.startTime then
		return i.startPos+Vector(Vector(i.endPos)-i.startPos):normalized()*math.floor((i.spell.speed*(os.clock()-i.startTime) + (i.spell.radius+myHero.boundingRadius)/2))
	else
		return Vector(i.startPos)
	end
end

function SLEvade:sCircPos(_,i)
	if i then
		return math.floor((i.spell.radius/(i.spell.killTime+i.dist/i.spell.speed+i.spell.delay))*(os.clock()-i.startTime+i.spell.delay))
	end
end

function SLEvade:Status()
	if not EMenu.Keys.DD:Value() and not (EMenu.Keys.DoD:Value() or EMenu.Keys.DoD2:Value()) then
		DrawText("Evade : ON", 400, myHero.pos2D.x-50,  myHero.pos2D.y, ARGB(255,255,255,255))
	end
	if EMenu.Keys.DD:Value() then
		DrawText("Evade : OFF", 400, myHero.pos2D.x-50,  myHero.pos2D.y, ARGB(255,255,255,255))
	end
	if (EMenu.Keys.DoD:Value() or EMenu.Keys.DoD2:Value()) and not EMenu.Keys.DD:Value() then 
		DrawText("Evade : ON", 400, myHero.pos2D.x-50,  myHero.pos2D.y, GoS.Yellow)
	end
end

function SLEvade:Humanizer(_,i)
	if not i.status then
		if (i.debug and not i.debug or EMenu.Spells[_] and EMenu.Spells[_]["H".._]:Value() or i.humanizer and i.humanizer or false) and i.caster and i.caster.visible then
			return (i.spell.delay + GetDistance(myHero,i.startPos) / i.spell.speed)/(myHero.ms/100)
		else
			return 0 
		end
		i.status = true
	end
end

function SLEvade:Position()
return Vector(myHero) + Vector(Vector(self.mV) - myHero.pos):normalized() * myHero.ms/2
end

function SLEvade:prwp(unit, wp)
if not SLE then return end
  if wp and unit == myHero and wp.index == 1 then
	self.mV = wp.position
  end
end

function SLEvade:CleanObj(_,i)
	if i.o and not i.o.valid and i.spell.type ~= "Circle" then
		self.obj[_] = nil
	elseif i.spell.type == "Circle" and i.spell.killTime then
		DelayAction(function() self.obj[_] = nil end, i.spell.killTime + GetDistance(i.caster,i.endPos))
	end
end

function SLEvade:ItemMenu()
	for item,c in pairs(self.SI) do
		if GetItemSlot(myHero,item)>0 then
			if not c.State and not EMenu.invulnerable[c.Name] then
				EMenu.invulnerable:Menu(c.Name,""..myHero.charName.." | Item - "..c.Name)
				EMenu.invulnerable[c.Name]:Boolean("Dodge"..c.Name, "Enable Dodge", true)
				EMenu.invulnerable[c.Name]:Slider("d"..c.Name,"Danger", 5, 1, 5, 1)
				EMenu.invulnerable[c.Name]:Slider("hp"..c.Name,"HP", 100, 1, 100, 5)
			end
			c.State = true
		else
			c.State = false
		end
	end
	for item,c in pairs(self.D) do
		if GetItemSlot(myHero,item)>0 then
			if not c.State and not EMenu.EvadeSpells[c.Name] then
				EMenu.EvadeSpells:Menu(c.Name,""..myHero.charName.." | Item - "..c.Name)
				EMenu.EvadeSpells[c.Name]:Boolean("Dodge"..c.Name, "Enable Dodge", true)
				EMenu.EvadeSpells[c.Name]:Slider("d"..c.Name,"Danger", 3, 1, 5, 1)
				EMenu.EvadeSpells[c.Name]:Slider("hp"..c.Name,"HP", 100, 1, 100, 5)
			end
			c.State = true
		else
			c.State = false
		end
	end
end

function SLEvade:Mpos(_,i)
	if i.spell.type == "Circle" then 
		if i and GetDistance(myHero,i.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * i.spell.radius
				self.mposs = GetMousePos()
			end
		else
			self.mposs = nil
			i.mpos = nil
		end
	elseif i.spell.type == "Line" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs2 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs2 = GetMousePos()
			end	
		else
			self.mposs2 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "Rectangle" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs3 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs3 = GetMousePos()
			end	
		else
			self.mposs3 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "Cone" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs4 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs4 = GetMousePos()
			end	
		else
			self.mposs4 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "Return" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs2 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs2 = GetMousePos()
			end	
		else
			self.mposs2 = nil
			i.mpos = nil
		end
	elseif i.spell.type == "follow" then
		if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
			if not i.mpos and not self.mposs2 then
				i.mpos = Vector(myHero) + Vector(Vector(GetMousePos()) - myHero.pos):normalized() * (i.spell.radius+myHero.boundingRadius)
				self.mposs2 = GetMousePos()
			end	
		else
			self.mposs2 = nil
			i.mpos = nil
		end
	end
end

function SLEvade:UDodge(_,i)
	if EMenu.Keys.DoD:Value() or EMenu.Keys.DoD2:Value() then
			self.DodgeOnlyDangerous = true
		else
			self.DodgeOnlyDangerous = false
	end
	if not i.uDodge then
		if i.safe and i.spell.type == "Line" then
			if i.check < (GetDistance(i.safe)/2)/myHero.ms then 
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "Circle" and i then
			if i.check2 < GetDistance(i.safe)/myHero.ms then
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "Rectangle" and i then
			if i.check2 < (GetDistance(i.safe)/2)/myHero.ms then
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "Cone" and i then
			if GetDistance(i.endPos)/i.spell.speed + i.spell.delay < GetDistance(i.safe)/myHero.ms then
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "Return" and i.o then
			if i.check < (GetDistance(i.safe)/2)/myHero.ms then 
				i.uDodge = true 
			end
		elseif i.safe and i.spell.type == "follow" then
			if i.check < GetDistance(i.safe)/myHero.ms then 
				i.uDodge = true 
			end
		end
	end
end

function SLEvade:Pathfinding(_,i)
	if (i.debug and not i.debug) or (EMenu.Spells[_] and EMenu.Spells[_]["ffe".._]:Value() or false) then
		DelayAction(function()
			if i.spell.type == "Line" and i then
					i.startPos = Vector(i.startPos)
					i.endPos = Vector(i.endPos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,v3)
					local jp2 = Vector(VectorIntersection(i.startPos,i.endPos,myHero.pos+(Vector(i.startPos)-Vector(i.endPos)):perpendicular(),myHero.pos).x,i.endPos.y,VectorIntersection(i.startPos,i.endPos,myHero.pos+(Vector(i.startPos)-Vector(i.endPos)):perpendicular(),myHero.pos).y)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
						if GetDistance(GetOrigin(myHero) + Vector(i.startPos-i.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.startPos-i.endPos):perpendicular2(),jp2) then
							self.asd = true
							self.patha = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							if not MapPosition:inWall(self.patha) then
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
								else 
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							end
							i.isEvading = true
						else
							self.asd = true
							self.patha = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							if not MapPosition:inWall(self.patha) then
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
								else 
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							end
							i.isEvading = true
						end
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end
			elseif i.spell.type == "Circle" then
				if _ == "AbsoluteZero" then
					i.endPos = Vector(i.caster.pos)
				else
					i.endPos = Vector(i.endPos)
				end
				if GetDistance(myHero,i.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe then
					self.asd = true
					self.pathb = Vector(i.endPos) + (GetOrigin(myHero) - Vector(i.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					if not MapPosition:inWall(self.pathb) then
							i.safe = Vector(i.endPos) + (GetOrigin(myHero) - Vector(i.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						else
							i.safe = i.endPos + Vector(self.pathb-i.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
					end
					i.isEvading = true
				else
					self.asd = false
					self.pathb = nil
					self.pathb2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			elseif i.spell.type == "Rectangle" then
				local startp = Vector(i.endPos) - (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
				local endp = Vector(i.endPos) + (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
				if GetDistance(startp) < i.spell.range + myHero.boundingRadius and GetDistance(endp) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(startp,endp,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos then
						self.asd = true
						self.pathc = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.pathc) then
								i.safe = Vector(myHero)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else
								i.safe =  Vector(myHero)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					end
				else
					self.asd = false
					self.pathc = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			elseif i.spell.type == "Cone" then
					i.startPos = Vector(i.startPos)
					i.endPos = Vector(i.endPos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(Vector(i.startPos),i.endPos,v3)
					local jp2 = Vector(VectorIntersection(i.startPos,i.endPos,myHero.pos+(Vector(i.startPos)-Vector(i.endPos)):perpendicular(),myHero.pos).x,i.endPos.y,VectorIntersection(i.startPos,i.endPos,myHero.pos+(Vector(i.startPos)-Vector(i.endPos)):perpendicular(),myHero.pos).y)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
						if GetDistance(GetOrigin(myHero) + Vector(i.startPos-i.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.startPos-i.endPos):perpendicular2(),jp2) then
							self.asd = true
							self.patha = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							if not MapPosition:inWall(self.patha) then
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
								else 
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							end
							i.isEvading = true
						else
							self.asd = true
							self.patha = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							if not MapPosition:inWall(self.patha) then
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
								else 
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							end
							i.isEvading = true
						end
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end
			elseif i.spell.type == "Return" and i.o then
					i.startPos = Vector(i.startPos)
					i.endPos = Vector(i.caster.pos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(Vector(i.o.pos),i.endPos,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe then
						self.asd = true
						self.patha = Vector(myHero)+Vector(Vector(myHero)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						if not MapPosition:inWall(self.patha) then
								i.safe = Vector(myHero)+Vector(Vector(myHero)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = Vector(myHero)+Vector(Vector(myHero)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1)
						end
						i.isEvading = true
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end
			elseif i.spell.type == "follow" then
					i.startPos = Vector(i.caster.pos)
					i.endPos = Vector(i.endPos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local v4 = Vector(i.caster.pos) + i.TarE
					local jp = VectorPointProjectionOnLineSegment(i.startPos,v4,v3)
					local jp2 = Vector(VectorIntersection(i.startPos,v4,myHero.pos+(Vector(i.startPos)-Vector(v4)):perpendicular(),myHero.pos).x,v4.y,VectorIntersection(i.startPos,v4,myHero.pos+(Vector(i.startPos)-Vector(v4)):perpendicular(),myHero.pos).y)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll and jp2 then
						if GetDistance(GetOrigin(myHero) + Vector(i.startPos-i.endPos):perpendicular(),jp2) >= GetDistance(GetOrigin(myHero) + Vector(i.startPos-i.endPos):perpendicular2(),jp2) then
						self.asd = true
						self.patha = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							if not MapPosition:inWall(self.patha) then
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
								else 
									i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							end
						else
							self.asd = true
							self.patha = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							if not MapPosition:inWall(self.patha) then
								i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular2():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							else 
								i.safe = jp2 + Vector(i.startPos - i.endPos):perpendicular():normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1)
							end
						end
						i.isEvading = true
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end	
			end
		end,self:Humanizer(_,i))
	else
		DelayAction(function()
			if i.spell.type == "Line" and i then
					i.startPos = Vector(i.startPos)
					i.endPos = Vector(i.endPos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
						self.asd = true
						self.patha = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						self.patha2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular(),i.jp) then
							if not MapPosition:inWall(self.patha2) then
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
								else 
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						else
							if not MapPosition:inWall(self.patha) then
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						end
						i.isEvading = true
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end
			elseif i.spell.type == "Circle" then
				if _ == "AbsoluteZero" then
					i.endPos = Vector(i.caster.pos)
				else
					i.endPos = Vector(i.endPos)
				end
				if GetDistance(myHero,i.endPos) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos then
					self.asd = true
					self.pathb = Vector(i.endPos) + (GetOrigin(myHero) - Vector(i.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
					self.pathb2 = Vector(i.endPos) + (Vector(i.mpos) - Vector(i.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
					if self.mposs and GetDistance(self.mposs,self.pathb) > GetDistance(self.mposs,self.pathb2) then
						if not MapPosition:inWall(self.pathb2) then
								i.safe = Vector(i.endPos) + (Vector(i.mpos) - Vector(i.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							else
								i.safe = i.endPos + Vector(self.pathb2-i.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						end
					else
						if not MapPosition:inWall(self.pathb) then
								i.safe = Vector(i.endPos) + (GetOrigin(myHero) - Vector(i.endPos)):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							else
								i.safe = i.endPos + Vector(self.pathb-i.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						end
					end
					i.isEvading = true
				else
					self.asd = false
					self.pathb = nil
					self.pathb2 = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			elseif i.spell.type == "Rectangle" then
				local startp = Vector(i.endPos) - (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
				local endp = Vector(i.endPos) + (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
				if GetDistance(startp) < i.spell.range + myHero.boundingRadius and GetDistance(endp) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(startp,endp,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos then
						self.asd = true
						self.pathc = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						self.pathc2 = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						if GetDistance(Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular(),i.jp) then
							if not MapPosition:inWall(self.pathc2) then
									i.safe = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
								else
									i.safe = i.endPos + Vector(self.pathc-i.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						else
							if not MapPosition:inWall(self.pathc) then
									i.safe = Vector(i.mpos)+Vector(startp-endp):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
								else
									i.safe = i.endPos + Vector(self.pathc-i.endPos):normalized() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end					
						end
						i.isEvading = true
					end
				else
					self.asd = false
					self.pathc = nil
					i.isEvading = false
					DisableHoldPosition(false)
					DisableAll(false)
				end
			elseif i.spell.type == "Cone" then
					i.startPos = Vector(i.startPos)
					i.endPos = Vector(i.endPos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(i.startPos,i.endPos,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
						self.asd = true
						self.patha = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						self.patha2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular(),i.jp) then
							if not MapPosition:inWall(self.patha2) then
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
								else 
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						else
							if not MapPosition:inWall(self.patha) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						end
						i.isEvading = true
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end
			elseif i.spell.type == "Return" and i.o then
					i.startPos = Vector(i.startPos)
					i.endPos = Vector(i.caster.pos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local jp = VectorPointProjectionOnLineSegment(Vector(i.o.pos),i.endPos,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
						self.asd = true
						self.patha = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						self.patha2 = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular(),i.jp) then
							if not MapPosition:inWall(self.patha2) then
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
								else 
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						else
							if not MapPosition:inWall(self.patha) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-i.endPos):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						end
						i.isEvading = true
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end
			elseif i.spell.type == "follow" then
					i.startPos = Vector(i.caster.pos)
					i.endPos = Vector(i.endPos)
				if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
					local v3 = Vector(myHero)
					local v4 = Vector(i.caster.pos) + i.TarE
					local jp = VectorPointProjectionOnLineSegment(i.startPos,v4,v3)
					i.jp = jp
					if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius and not i.safe and i.mpos and not i.coll then
						self.asd = true
						self.patha = Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						self.patha2 = Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
						if GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular2(),i.jp) > GetDistance(Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular(),i.jp) then
							if not MapPosition:inWall(self.patha2) then
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
								else 
									i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						else
							if not MapPosition:inWall(self.patha) then
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							else 
								i.safe = Vector(i.mpos)+Vector(Vector(i.mpos)-v4):normalized():perpendicular2() * ((i.spell.radius + myHero.boundingRadius)*1.1+EMenu.Advanced.ew:Value())
							end
						end
						i.isEvading = true
					else
						self.asd = false
						self.patha = nil
						self.patha2 = nil
						i.isEvading = false
						DisableHoldPosition(false)
						DisableAll(false)
					end
				end	
			end
		end,self:Humanizer(_,i))
	end
end

function SLEvade:Drawings(_,i)
	if i.debug or EMenu.Spells[_]["Draw".._]:Value() then
		if i.spell.type == "Line" and not EMenu.Keys.DDraws:Value() then
			if EMenu.Draws.DSPath:Value() then
				dRectangleOutline(Vector(self.opos), Vector(i.endPos), i.spell.radius+myHero.boundingRadius, 1.75, ARGB(215,210,210,210), i.debug or EMenu.Spells[_]["Dodge".._]:Value())
				if EMenu.Draws.DSEW:Value() then
					dRectangleOutline2(Vector(self.opos), Vector(i.endPos), i.spell.radius+myHero.boundingRadius, 2.5, ARGB(215,255,255,255), i.debug or EMenu.Spells[_]["Dodge".._]:Value())
				end
			end		
		end
		if i.spell.type == "Circle" and not EMenu.Keys.DDraws:Value() then
			if _ == "AbsoluteZero" then
				i.endPos = Vector(i.caster.pos)
			else
				i.endPos = Vector(i.endPos)
			end
			if EMenu.Draws.DSPath:Value() then
				DrawCircle(i.endPos,i.spell.radius,1.75,25,ARGB(215,255,255,255))	
				DrawCircle(i.endPos,self.cpos,2.5,25,ARGB(200,250,192,0))
			end
		end
		if i.spell.type == "Rectangle" and not EMenu.Keys.DDraws:Value() then
			DrawRectangle(i.startPos,i.endPos,i.spell.radius+myHero.boundingRadius,i.spell.radius2,2.5,ARGB(215,255,255,255))
		end
		if i.spell.type == "Cone" and not EMenu.Keys.DDraws:Value() then
			DrawCone(i.startPos,Vector(i.endPos),i.spell.angle or 40,2.5,ARGB(215,255,255,255))
		end
		if i.spell.type == "Return" and not EMenu.Keys.DDraws:Value() and i.o then
			if EMenu.Draws.DSPath:Value() then
				dRectangleOutline(Vector(i.o.pos), Vector(i.caster.pos), i.spell.radius+myHero.boundingRadius, 1.75, ARGB(215,210,210,210), i.debug or EMenu.Spells[_]["Dodge".._]:Value())
				if EMenu.Draws.DSEW:Value() then
					dRectangleOutline2(Vector(i.o.pos), Vector(i.caster.pos), i.spell.radius+myHero.boundingRadius, 2.5, ARGB(215,255,255,255), i.debug or EMenu.Spells[_]["Dodge".._]:Value())
				end
			end
		end
		if i.spell.type == "follow" and not EMenu.Keys.DDraws:Value() then
			if EMenu.Draws.DSPath:Value() then
				dRectangleOutline(Vector(i.caster.pos), Vector(i.caster.pos) + i.TarE, i.spell.radius+myHero.boundingRadius, 1.75, ARGB(215,210,210,210), i.debug or EMenu.Spells[_]["Dodge".._]:Value())
				if EMenu.Draws.DSEW:Value() then
					dRectangleOutline2(Vector(i.caster.pos), Vector(i.caster.pos) + i.TarE, i.spell.radius+myHero.boundingRadius, 2.5, ARGB(215,255,255,255), i.debug or EMenu.Spells[_]["Dodge".._]:Value())
				end
			end
		end
	end
end

function SLEvade:Drawings2(_,i)
		if EMenu.Draws.DevOpt:Value() then 
			if i.jp then 
				DrawCircle(i.jp,50,1,20,GoS.Red) 
			end 
		end
		if EMenu.Draws.DEPos:Value() and i.safe and (i.debug or ((not self.DodgeOnlyDangerous and EMenu.d:Value() <= EMenu.Spells[_]["d".._]:Value()) or (self.DodgeOnlyDangerous and EMenu.Spells[_]["IsD".._]:Value())) and EMenu.Spells[_]["Dodge".._]:Value() and EMenu.Spells[_]["Draw".._]:Value()) then			
				dArrow(myHero.pos,i.safe,3,ARGB(255,0,255,0))
		end
		if EMenu.Draws.DevOpt:Value() then
			DrawCircle(self:Position(),50,1,20,GoS.Blue)
		end
end

function SLEvade:Dodge(_,i)
				--DashP = Dash - Position, DashS = Dash - Self, DashT = Dash - Targeted, SpellShieldS = SpellShield - Self, SpellShieldT = SpellShield - Targeted, WindWallP = WindWall - Position, 
	if EMenu.Keys.DD:Value() then return end
	if myHero.isSpellShielded then return end
	if (i.safe and ((not self.DodgeOnlyDangerous and (i.debug or EMenu.d:Value() <= EMenu.Spells[_]["d".._]:Value())) or (self.DodgeOnlyDangerous and (i.debug or EMenu.Spells[_]["IsD".._]:Value()))) and (i.debug or EMenu.Spells[_]["Dodge".._]:Value()) and (i.debug or GetPercentHP(myHero) <= EMenu.Spells[_]["hp".._]:Value())) then
		_G.IsEvading = true
		if self.asd == true then 
			DisableHoldPosition(true)
			DisableAll(true) 
		else 
			DisableHoldPosition(false)
			DisableAll(false) 
		end
		MoveToXYZ(i.safe)
			if (i.debug or EMenu.Spells[_]["Dashes".._]:Value()) then
				for op = 0,3 do
					if self.EvadeSpells[GetObjectName(myHero)] and self.EvadeSpells[GetObjectName(myHero)][op] and EMenu.EvadeSpells[self.EvadeSpells[GetObjectName(myHero)][op].name]["Dodge"..self.EvadeSpells[GetObjectName(myHero)][op].name]:Value() and self.EvadeSpells[GetObjectName(myHero)][op].evadeType and self.EvadeSpells[GetObjectName(myHero)][op].spellKey and (i.debug or EMenu.Spells[_]["d".._]:Value() >= EMenu.EvadeSpells[self.EvadeSpells[GetObjectName(myHero)][op].name]["d"..self.EvadeSpells[GetObjectName(myHero)][op].name]:Value()) then 
						if i.uDodge == true and self.usp == false and self.ut == false then
							if self.EvadeSpells[GetObjectName(myHero)][op].evadeType == "DashP" and CanUseSpell(myHero, self.EvadeSpells[GetObjectName(myHero)][op].spellKey) == READY then
									self.ues = true
									CastSkillShot(self.EvadeSpells[GetObjectName(myHero)][op].spellKey, i.safe)
								else
									self.ues = false
							end	
							-- if self.EvadeSpells[GetObjectName(myHero)][op].evadeType == "DashT" then--logic needed
							-- end
							if self.EvadeSpells[GetObjectName(myHero)][op].evadeType == "WindWallP" and CanUseSpell(myHero, self.EvadeSpells[GetObjectName(myHero)][op].spellKey) == READY then
									self.ues = true
									CastSkillShot(self.EvadeSpells[GetObjectName(myHero)][op].spellKey, myHero.pos + (i.startPos - myHero.pos)*50)
								else
									self.ues = false
							end		
							if self.EvadeSpells[GetObjectName(myHero)][op].evadeType == "SpellShieldS" and CanUseSpell(myHero, self.EvadeSpells[GetObjectName(myHero)][op].spellKey) == READY then
									self.ues = true
									DelayAction(function()
										CastSpell(self.EvadeSpells[GetObjectName(myHero)][op].spellKey)
									end,i.spell.delay + GetDistance(myHero,i.startPos) / i.spell.speed*.75*.001)
								else
									self.ues = false
							end
							if self.EvadeSpells[GetObjectName(myHero)][op].evadeType == "SpellShieldT" and CanUseSpell(myHero, self.EvadeSpells[GetObjectName(myHero)][op].spellKey) == READY then --logic needed
									self.ues = true
									DelayAction(function()
										CastTargetSpell(myHero,self.EvadeSpells[GetObjectName(myHero)][op].spellKey)
									end,i.spell.delay + GetDistance(myHero,i.startPos) / i.spell.speed*.75*.001)
								else
										self.ues = false
							end
							if self.EvadeSpells[GetObjectName(myHero)][op].evadeType == "DashS" and CanUseSpell(myHero, self.EvadeSpells[GetObjectName(myHero)][op].spellKey) == READY then
									self.ues = true
									CastSpell(self.EvadeSpells[GetObjectName(myHero)][op].spellKey)
								else
									self.ues = false
							end
						end
					end
				if self.Flash and Ready(self.Flash) and i.uDodge == true and EMenu.EvadeSpells.Flash.DodgeFlash:Value() and (i.debug or EMenu.Spells[_]["d".._]:Value() >= EMenu.EvadeSpells.Flash.dFlash:Value()) and self.ues == false and self.ut == false then
					self.usp = true
					CastSkillShot(self.Flash, i.safe)
				else
					self.usp = false
				end		
				for item,c in pairs(self.SI) do
					if c.State and Ready(GetItemSlot(myHero,item)) and EMenu.invulnerable[c.Name]["Dodge"..c.Name]:Value() and i.uDodge == false and GetPercentHP(myHero) <= EMenu.invulnerable[c.Name]["hp"..c.Name]:Value() and (i.debug or EMenu.Spells[_]["d".._]:Value() >= EMenu.invulnerable[c.Name]["d"..c.Name]:Value()) and self.ues == false and self.usp == false then
						self.ut = true
						DelayAction(function()
							CastSpell(GetItemSlot(myHero,item))
						end,i.spell.delay + GetDistance(myHero,i.startPos) / i.spell.speed*.75*.001)
					else
						self.ut = false
					end
				end
				for item,c in pairs(self.D) do
					if c.State and Ready(GetItemSlot(myHero,item)) and EMenu.EvadeSpells[c.Name]["Dodge"..c.Name]:Value() and i.uDodge == true and GetPercentHP(myHero) <= EMenu.EvadeSpells[c.Name]["hp"..c.Name]:Value() and (i.debug or EMenu.Spells[_]["d".._]:Value() >= EMenu.EvadeSpells[c.Name]["d"..c.Name]:Value()) and self.ues == false and self.usp == false then
						self.ut = true
						CastSkillShot(GetItemSlot(myHero,item), i.safe)
					else
						self.ut = false
					end
				end
			end
		end
	else
		DisableHoldPosition(false)
		DisableAll(false)
	end
end

function SLEvade:BlockMov(order)
if not SLE then return end
	for _,i in pairs(self.obj) do
		if order.flag ~= 3 and order.position then
			if i.jp and i.spell.type == "Line" then
				local jp3 = VectorPointProjectionOnLineSegment(Vector(myHero.pos),Vector(order.position),Vector(VectorPointProjectionOnLineSegment(Vector(self.opos),Vector(i.endPos),myHero.pos).x,i.endPos.y,VectorPointProjectionOnLineSegment(Vector(self.opos),Vector(i.endPos),myHero.pos).y))
				if GetDistance(jp3,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1) and not i.safe then	
					BlockOrder()
				end
			elseif i and i.spell.type == "Circle" then
				if (GetDistance(order.position,i.endPos) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.jp and i.spell.type == "Rectangle" then
				local startp = Vector(i.endPos) - (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
				local endp = Vector(i.endPos) + (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
				local jp3 = VectorPointProjectionOnLineSegment(Vector(myHero.pos),Vector(order.position),Vector(VectorPointProjectionOnLineSegment(Vector(startp),Vector(endp),myHero.pos).x,endp.y,VectorPointProjectionOnLineSegment(Vector(startp),Vector(endp),myHero.pos).y))
				if (GetDistance(jp3,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.jp and i.spell.type == "Cone" then
				local jp3 = VectorPointProjectionOnLineSegment(Vector(myHero.pos),Vector(order.position),Vector(VectorPointProjectionOnLineSegment(Vector(self.opos),Vector(i.endPos),myHero.pos).x,i.endPos.y,VectorPointProjectionOnLineSegment(Vector(self.opos),Vector(i.endPos),myHero.pos).y))
				if (GetDistance(jp3,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.jp and i.spell.type == "Return" then
				if (GetDistance(order.position,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			elseif i.jp and i.spell.type == "follow" then
				if (GetDistance(order.position,i.jp) < ((i.spell.radius + myHero.boundingRadius)*1.1)) and not i.safe then
					BlockOrder()
				end
			end
		end
		if i.safe and order.flag ~= 3 and self.count > 0 then
			BlockOrder()
			self.count = self.count-1
		end
	end
end

function SLEvade:CreateObject(obj)
if not SLE then return end
	-- if obj and obj.isSpell and obj.spellOwner.isMe and obj.spellOwner.team == MINION_ALLY then
	if obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == MINION_ENEMY then
		if EMenu.Draws.DevOpt:Value() and obj.spellOwner.isMe then
			print(obj.spellName)
		end
		for _,l in pairs(Spells) do
			if not self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] and Spells[_] and EMenu.Spells[l.charName..""..self.str[l.slot]..""..l.displayname] and EMenu.d:Value() <= EMenu.Spells[l.charName..""..self.str[l.slot]..""..l.displayname]["d"..l.charName..""..self.str[l.slot]..""..l.displayname]:Value() and (l.proj == obj.spellName or _ == obj.spellName or obj.spellName:lower():find(_:lower()) or obj.spellName:lower():find(l.proj:lower())) then
				if l.type == ("Line" or "Cone") then 
					endPos = Vector(obj.startPos)+Vector(Vector(obj.endPos)-obj.startPos):normalized()*l.range
				else
					endPos = Vector(obj.endPos)
				end
				self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = {
				o = obj,
				startPos = Vector(obj.startPos),
				endPos = endPos,
				caster = obj.spellOwner,
				mpos = nil,
				uDodge = nil,
				startTime = os.clock(),
				spell = l,
				range = l.range,
				check = GetDistance(myHero,obj.startPos)/l.speed,
				check2 = GetDistance(myHero,obj.endPos)/l.speed+l.killTime,
				dist = GetDistance(obj.spellOwner,obj.endPos),
				}
			end
		end
	end
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		if not self.YasuoWall[obj.spellName] then self.YasuoWall[obj.spellName] = {} end
		self.YasuoWall[obj.spellName].obj = obj
	end
end

function SLEvade:Detection(unit,spellProc)
if not SLE then return end
	-- if unit and spellProc and spellProc.name and unit.team == myHero.team then
	if unit and spellProc and spellProc.name and unit.team ~= myHero.team then
		if EMenu.Draws.DevOpt:Value() and unit.isMe then
			print(spellProc.name)
		end
		for _,l in pairs(Spells) do
			if not self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] and Spells[_] and EMenu.Spells[l.charName..""..self.str[l.slot]..""..l.displayname] and EMenu.d:Value() <= EMenu.Spells[l.charName..""..self.str[l.slot]..""..l.displayname]["d"..l.charName..""..self.str[l.slot]..""..l.displayname]:Value() and spellProc.name:find(_) then
				if l.type == ("Line" or "Cone") then 
					endPos = Vector(spellProc.startPos)+Vector(Vector(spellProc.endPos)-spellProc.startPos):normalized()*l.range
				else
					endPos = Vector(spellProc.endPos)
				end
				self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = {
				startPos = Vector(spellProc.startPos),
				endPos = endPos,
				spell = l,
				caster = unit,
				mpos = nil,
				uDodge = nil,
				startTime = os.clock()+l.delay,
				TarE = (Vector(spellProc.endPos) - Vector(unit.pos)):normalized()*l.range,
				range = l.range,
				check = GetDistance(myHero,spellProc.startPos)/l.speed+l.delay,
				check2 = GetDistance(myHero,spellProc.endPos)/l.speed+l.delay+l.killTime,
				dist = GetDistance(unit,spellProc.endPos),
				}
				if l.killTime and l.type == "Circle" then
					DelayAction(function() self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = nil end, l.killTime + GetDistance(unit,spellProc.endPos)/l.speed + l.delay)
				elseif l.killTime > 0 and l.type ~= "Circle" then
					DelayAction(function() self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = nil end, l.killTime + 1.3*GetDistance(myHero.pos,spellProc.startPos)/l.speed+l.delay)
				else
					DelayAction(function() self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = nil end, l.range/l.speed + l.delay/2)
				end
			elseif l.killName == spellProc.name then
				self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = nil				
			end
		end
	end
end

function SLEvade:DeleteObject(obj)
if not SLE then return end
	for _,l in pairs(Spells) do
		if obj and obj.isSpell and self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] and l.type ~= "Circle" and (l.proj == obj.spellName or _ == obj.spellName or obj.spellName:lower():find(_:lower()) or obj.spellName:lower():find(l.proj:lower())) then
			self.obj[l.charName..""..self.str[l.slot]..""..l.displayname] = nil
		end	
	end
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		self.YasuoWall[obj.spellName] = nil
	end
end

function LoadSLE()
	if not _G.SLE then _G.SLE = SLEvade() end
	return SLE
end

class 'SLTS'--Updated version of Inspired TS (credits:Inspired)

function SLTS:__init(type, m, s)
	self.dtype = type
	self.range = {}
	self.str= {[0]="Q",[1]="W",[2]="E",[3]="R"} 
	self.focusselected = true
	self.m = m or nil
	self.morganashield = false
	self.sivirshield = false
	self.nocturneshield = false
	self.item1 = false
	self.item2 = false
	self.pt1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "ChoGath", "DrMundo", "Garen", "Gnar", "Hecarim", "JarvanIV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac"}
	self.pt2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax","LeeSin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain","Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"}
	self.pt3 = {"Akali", "Diana", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Janna", "Jayce", "Kassadin","Kayle", "KhaZix", "Lissandra", "Mordekaiser", "Nami", "Nidalee", "Riven", "Shaco", "Sona", "Soraka", "TahmKench", "Vladimir", "Yasuo", "Zilean", "Zyra"}
	self.pt4 = {"Ahri", "Anivia", "Annie", "Brand",  "Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",  "Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",  "TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs" }
	self.pt5 = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne"}

	self.m:Boolean("sel", "Focus selected", self.focusselected or false)
	self.m:Boolean("dsel", "Draw current target", true)
	self.m:Boolean("sh", "Include Shields", true)
	self.m:DropDown("mode", "TargetSelector Mode:", 1, {"Normal","Less Cast", "Less Cast Priority", "Priority", "Most AP", "Most AD", "Closest", "Near Mouse", "Lowest Health", "Lowest Health Priority"})
	for i=0,3 do
		if Spell[i] and not Spell[i].ally then
			if myHero.charName ~= "Syndra" then
				self.m:Slider("range"..self.str[i], "Range to check for enemies for : "..self.str[i], Spell[i].range,0,Spell[i].range+2000,50)
			else
				if Spell[i] and Spell[2] and Spell[i].range ~= Spell[2].range then
					self.m:Slider("range"..self.str[i], "Range to check for enemies for : "..self.str[i], Spell[i].range,0,Spell[i].range+2000,50)
				elseif Spell[2] and Spell[2].range then
					self.m:Slider("range"..self.str[2], "Range to check for enemies for : "..self.str[2], Spell[2].range+Spell[-1].range,0,Spell[2].range+Spell[-1].range+2000,50)
				end
			end
		end
	end
	DelayAction(function()
		for k,m in pairs(GetEnemyHeroes()) do
			if m.type == myHero.type then 
				self.m:Slider(m.charName,"Priority for : "..m.charName,self:GetPrioritym(m), 1, 5, 1)
			end
		end
	end,.001)
	self.m:Info("1", "5 = Highest Priority")
	Callback.Add("WndMsg", function(m,k) self:FocusSelected(m,k) end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateB(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveB(u,b) end)
	Callback.Add("Draw", function() self:Draw() for i=0,3 do if Spell[i] and not Spell[i].ally then self.range[i] = {range = self.m["range"..self.str[i]]:Value()} end end end)
end

function SLTS:UpdateB(u,b)
	if u and b and u.team ~= myHero.team and u.isHero then
		if b.Name == "BlackShield" then
			self.morganashield = true
		elseif b.Name == "SivirShield" then
			self.sivirshield = true
		elseif b.Name == "ShroudofDarkness" then
			self.item1 = true
		elseif b.Name == "BansheesVeil" then
			self.item2 = true
		end
	end
end

function SLTS:RemoveB(u,b)
	if u and b and u.team ~= myHero.team and u.isHero then
		if b.Name == "BlackShield" then
			self.morganashield = false
		elseif b.Name == "SivirShield" then
			self.sivirshield = false
		elseif b.Name == "ShroudofDarkness" then
			self.item1 = false
		elseif b.Name == "BansheesVeil" then
			self.item2 = false
		end
	end
end

function SLTS:IsShielded(i)
	if self.dtype == "AP" and self.m.sh:Value() then
		if self.morganashield or self.sivirshield or self.item1 or self.item2 then
			return true
		end
	end
	return false
end

function SLTS:GetPrioritym(i)
	if table.contains(self.pt5,i.charName) then
		return 5
	elseif table.contains(self.pt4,i.charName)  then
		return 4
	elseif table.contains(self.pt3,i.charName) then
		return 3
	elseif table.contains(self.pt2,i.charName)  then
		return 2
	elseif table.contains(self.pt1,i.charName)  then
		return 1
	else
		return 1
	end
end

function SLTS:GetPriority(i)
	return self.m[i.charName]:Value()
end

function SLTS:IsValid(t)
	if t and t.alive and t.visible and t.valid and not self:IsShielded(t) then
		return true
	else
		return false
	end
end

function SLTS:GetTarget()
	 if self.m.sel:Value() then
		if self:IsValid(self.selected) then
			return self.selected
		else
			self.selected = nil
		end
	end
	if not self.selected then
		for _,i in pairs(GetEnemyHeroes()) do
			for l = 0,3 do 
				if self.range[l] and i.distance < self.range[l].range and not i.dead and Ready(l) then
					if self.m.mode:Value() == 1 then
						local t = nil
						if self:IsValid(GetCurrentTarget()) then
							t = GetCurrentTarget()
						end
						return t 
					end
					if self.m.mode:Value() == 2 then
						local t, p = nil, math.huge
						if self:IsValid(i) and CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0) < p then
							t = i
							p = CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0)
						end
						return t
					end
					if self.m.mode:Value() == 3 then
						local t,p = nil, math.huge
						if self:IsValid(i) and CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0)*self:GetPriority(i) < p then
							t = i
							p = CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0)*self:GetPriority(i)
						end
						return t
					end
					if self.m.mode:Value() == 4 then
						local t, p = nil, math.huge
						if self:IsValid(i) and self:GetPriority(i) < p then
							t = i
							p = self:GetPriority(i)
						end
						return t
					end
					if self.m.mode:Value() == 5 then
						local t, p = nil, -1
						if self:IsValid(i) and i.ap > p then
							t = i
							p = prio
						end
						return t
					end
					if self.m.mode:Value() == 6 then
						local t, p = nil, -1
						if self:IsValid(i) and i.totalDamage > p then
							t = i
							p = i.totalDamage
						end
						return t
					end
					if self.m.mode:Value() == 7 then
						local t, p = nil, math.huge
						if self:IsValid(i) and i.distance < p then
						  t = i
						  p = i.distance
						end
						return t
					end
				end
				if self.m.mode:Value() == 8 then
					local t, p = nil, math.huge
					if self:IsValid(i) and GetDistance(i.pos,GetMousePos()) < p then
						t = i
						p = GetDistance(i.pos,GetMousePos())
					end
					return t
				end
				if self.m.mode:Value() == 9 then
					local t, p = nil, math.huge
					if self:IsValid(i) and i.health < p then
						t = i
						p = i.health
					end
					return t
				end
				if self.m.mode:Value() == 10 then
					local t, p = nil, math.huge
					if self:IsValid(i) and i.health*self:GetPriority(i) < p then
						t = i
						p = i.health*self:GetPriority(i)
					end
					return t
				end
			end
		end
	end
end

function SLTS:FocusSelected(m,k)
	if m == 513 then
		for _,i in pairs(GetEnemyHeroes()) do 
			if GetDistance(i.pos,GetMousePos()) < i.boundingRadius*1.5 and i.alive then
				self.selected = i
			else
				self.selected = nil
			end
		end
	end
end

function SLTS:Draw()
	if self:GetTarget() and self.m.dsel:Value() and self:GetTarget().pos and self:GetTarget().boundingRadius then
		DrawCircle(self:GetTarget().pos,self:GetTarget().boundingRadius*1.35,1,20,GoS.White)
	end
end

class 'AntiChannel'

function AntiChannel:__init()
	self.CSpell = {
    ["CaitlynAceintheHole"]         = {charName = "Caitlyn"		,slot="R"},
    ["Crowstorm"]                   = {charName = "FiddleSticks",slot="R"},
    ["Drain"]                       = {charName = "FiddleSticks",slot="W"},
    ["GalioIdolOfDurand"]           = {charName = "Galio"		,slot="R"},
    ["ReapTheWhirlwind"]            = {charName = "Janna"		,slot="R"},
	["JhinR"]						= {charName = "Jhin"		,slot="R"},
    ["KarthusFallenOne"]            = {charName = "Karthus"     ,slot="R"},
    ["KatarinaR"]                   = {charName = "Katarina"    ,slot="R"},
    ["LucianR"]                     = {charName = "Lucian"		,slot="R"},
    ["AlZaharNetherGrasp"]          = {charName = "Malzahar"	,slot="R"},
    ["MissFortuneBulletTime"]       = {charName = "MissFortune"	,slot="R"},
    ["AbsoluteZero"]                = {charName = "Nunu"		,slot="R"},                       
    ["PantheonRJump"]               = {charName = "Pantheon"	,slot="R"},
    ["ShenStandUnited"]             = {charName = "Shen"		,slot="R"},
    ["Destiny"]                     = {charName = "TwistedFate"	,slot="R"},
    ["UrgotSwap2"]                  = {charName = "Urgot"		,slot="R"},
    ["VarusQ"]                      = {charName = "Varus"		,slot="Q"},
    ["VelkozR"]                     = {charName = "Velkoz"		,slot="R"},
    ["InfiniteDuress"]              = {charName = "Warwick"		,slot="R"},
    ["XerathLocusOfPower2"]         = {charName = "Xerath"		,slot="R"},
	}
	
	DelayAction(function ()
		for k,i in pairs(GetEnemyHeroes()) do
			for _,n in pairs(self.CSpell) do
				if i.charName == n.charName then
					if not BM["AC"] then
						BM:Menu("AC","AntiChannel")
						BM.AC:Info("as", "Stop Channels for : ")
						Callback.Add("ProcessSpell", function(unit,spellProc) self:CheckAC(unit,spellProc) end)
					end
					if not BM.AC[_] then
						BM.AC:Boolean(_,n.charName.." | "..n.slot, true)
					end
				end
			end
		end
	end, .001)
end

function AntiChannel:CheckAC(unit,spellProc)
	if GetTeam(unit) == MINION_ENEMY and self.CSpell[spellProc.name] and BM.AC[spellProc.name]:Value() then
		_G[ChampName]:AntiChannel(unit,GetDistance(myHero,unit))
	end
end

class 'AntiGapCloser'

function AntiGapCloser:__init()
	self.GSpells = {
    ["AkaliShadowDance"]            = {charName = "Akali",		slot="R"		},
    ["Headbutt"]                    = {charName = "Alistar",	slot="Q"		},
    ["DianaTeleport"]               = {charName = "Diana",		slot="R"		},
    ["FizzPiercingStrike"]          = {charName = "Fizz",		slot="Q"		},
    ["IreliaGatotsu"]               = {charName = "Irelia",		slot="Q"		},
    ["JaxLeapStrike"]               = {charName = "Jax",		slot="Q"		},
    ["JayceToTheSkies"]             = {charName = "Jayce",		slot="Q"		},
    ["blindmonkqtwo"]               = {charName = "LeeSin",		slot="Q"		},
    ["MonkeyKingNimbus"]            = {charName = "MonkeyKing",	slot="E"		},
    ["Pantheon_LeapBash"]           = {charName = "Pantheon",	slot="W"		},
    ["PoppyHeroicCharge"]           = {charName = "Poppy",		slot="E"		},
    ["QuinnE"]                      = {charName = "Quinn",		slot="E"		},
    ["RengarLeap"]                  = {charName = "Rengar",		slot="Passive"	},
    ["XenZhaoSweep"]                = {charName = "XinZhao",	slot="E"		},
    ["AatroxQ"]                     = {charName = "Aatrox",		slot="Q"		},
    ["GragasE"]                     = {charName = "Gragas",		slot="E"		},
    ["GravesMove"]                  = {charName = "Graves",		slot="E"		},
    ["JarvanIVDragonStrike"]        = {charName = "JarvanIV",	slot="Q"		},
    ["JarvanIVCataclysm"]           = {charName = "JarvanIV",	slot="R"		},
    ["KhazixE"]                     = {charName = "Khazix",		slot="E"		},
    ["khazixelong"]                 = {charName = "Khazix",		slot="E"		},
    ["LeblancSlide"]                = {charName = "Leblanc",	slot="W"		},
    ["LeblancSlideM"]               = {charName = "Leblanc",	slot="W"		},
    ["LeonaZenithBlade"]            = {charName = "Leona",		slot="E"		},
    ["RenektonSliceAndDice"]        = {charName = "Renekton",	slot="E"		},
    ["SejuaniArcticAssault"]        = {charName = "Sejuani",	slot="E"		},
    ["ShenShadowDash"]              = {charName = "Shen",		slot="E"		},
    ["RocketJump"]                  = {charName = "Tristana",	slot="W"		},
    ["slashCast"]                   = {charName = "Tryndamere",	slot="E"		},
	}
	
	DelayAction(function ()
		for k,i in pairs(GetEnemyHeroes()) do
			for _,n in pairs(self.GSpells) do
				if i.charName == n.charName then
					if not BM["AGC"] then
						BM:Menu("AGC","AntiGapCloser")
						BM.AGC:Info("as", "AntiGapCloser for : ")
						Callback.Add("ProcessSpell", function(unit,spellProc) self:CheckAGC(unit,spellProc) end)
					end
					if not BM.AGC[_] then
						BM.AGC:Boolean(_,n.charName.." | "..n.slot, true)
					end
				end
			end
		end
	end, .001)
end

function AntiGapCloser:CheckAGC(unit,spellProc)
	if unit.team == MINION_ENEMY and self.GSpells[spellProc.name] and BM.AGC[spellProc.name]:Value() then
		_G[ChampName]:AntiGapCloser(unit,GetDistance(myHero,unit))
	end
end

class 'SLPrediction'

function SLPrediction:__init()
	self.CCType = { 
		[5] = "Stun", 
		[24] = "Suppression",
	}
	self.Channel = {
		{name = "katarinar", duration = 1},
		{name = "drain", duration = 5},
		{name = "crowstorm", duration = 1.5},
		{name = "consume", duration = 1.5},
		{name = "absolutezero", duration = 1},
		{name = "ezrealtrueshotbarrage", duration = 1},
		{name = "galioidolofdurand", duration = 1},
		{name = "reapthewhirlwind", duration = 1},
		{name = "missfortunebullettime", duration = 1},
		{name = "shenstandunited", duration = 1},
		{name = "meditate", duration = 1},
		{name = "gate", duration = 1.5},
	}
	self.c = {}
	self.um = {}
	self.a = {}
	self.s = {}
	self.AA = {}
	self.predictedpos = nil
	self.hitchance = nil
	self.p = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000, ["SRU_OrderMinionRanged"] = 650, ["SRU_ChaosMinionRanged"] = 650, ["SRU_OrderMinionSiege"] = 1200, ["SRU_ChaosMinionSiege"] = 1200, ["SRUAP_Turret_Chaos1"]  = 1200, ["SRUAP_Turret_Chaos2"]  = 1200, ["SRUAP_Turret_Chaos3"] = 1200, ["SRUAP_Turret_Order1"]  = 1200, ["SRUAP_Turret_Order2"]  = 1200, ["SRUAP_Turret_Order3"] = 1200, ["SRUAP_Turret_Chaos4"] = 1200, ["SRUAP_Turret_Chaos5"] = 500, ["SRUAP_Turret_Order4"] = 1200, ["SRUAP_Turret_Order5"] = 500 }

	Callback.Add("ProcessWaypoint", function(u,w) self:ProcessWaypoint(u,w) end)
	Callback.Add("ProcessSpell", function(u,s) self:ProcessSpell(u,s) end)
	Callback.Add("ProcessSpellComplete", function(u,s) self:ProcessSpellComplete(u,s) end)
	Callback.Add("Animation", function(u,a) self:Animation(u,a) end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateBuff(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveBuff(u,b) end)
	-- Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("Tick", function() self:Tick() end)
end

function SLPrediction:UpdateBuff(u,b)
if not SLP then return end
	if u and b and u.team ~= myHero.team then
		if self.CCType[b.Type] then
			self.s[u.networkID] = true
		end
	end
end

function SLPrediction:RemoveBuff(u,b)
if not SLP then return end
	if u and b and u.team ~= myHero.team then
		if self.CCType[b.Type] then
			self.s[u.networkID] = false
		end
	end
end

function SLPrediction:Animation(u,a)
if not SLP then return end
	for _,__ in pairs(self.c) do 
		if u and a and u.networkID == _ and a == "Run" then
			self.c[_] = nil
		end
	end
end

function SLPrediction:ProcessWaypoint(u,w)
if not SLP then return end
	if u and u.isHero and w and w.index == 1 and u.team ~= myHero.team then
		if not self.um[u.networkID] then self.um[u.networkID] = {} end
		self.um[u.networkID] = {ep=w.position,sp=u.pos,u=u,st=os.clock(),a=false}
		for _,__ in pairs(self.um) do
			if __.pos ~= w.position and u == __.u and u.networkID == __ then
				self.um[_] = {ep=nil,sp=nil,u=nil,st=nil,ds=nil,a=false}
			end
		end
	end
	if u and u.isHero and w and w.dashspeed > 0 and u.team ~= myHero.team then
		self.um[u.networkID] = {ep=w.position,sp=u.pos,u=u,st=os.clock(),d=GetDistance(u,w.position)/w.dashspeed,a=false,ds=w.dashspeed}
		DelayAction(function() self.um[u.networkID] = nil end,.25+GetDistance(u,w.position)/w.dashspeed)
	end
end

function SLPrediction:Tick()
if not SLP then return end
	for _,__ in pairs(self.um) do
		if self.a[_] and __.ep then
			self.a[_] = false
		end
	end
end

function SLPrediction:Draw()
if not SLP then return end
	if SLSChamps[myHero.charName] and BM.p and BM.p.CP:Value() == 5 then
		if self.predictedpos then
			DrawCircle(self.predictedpos,50,1,20,GoS.Red)
		end
	end
	for _,i in pairs(GetEnemyHeroes()) do
		if not self:MinionCollision(myHero,i,self:pos(0.25,80),80) then
			DrawLine3D(myHero.pos.x,myHero.pos.y,myHero.pos.z,i.pos.x,i.pos.y,i.pos.z,1,GoS.White)
		else
			print("collision")
		end
	end
end

function SLPrediction:ProcessSpell(u,s)
if not SLP then return end
	for _,__ in pairs(self.Channel) do
		if s.name:lower() == __.name and u and s then
			self.c[u.networkID] = {et = os.clock() + __.duration + s.windUpTime,s = s}
			DelayAction(function() self.c[u.networkID] = nil end,__.duration+s.windUpTime)
		end
	end
	if u and u.team ~= myHero.team and s and s.name and s.name:lower():find("attack") and not self.a[u.networkID] then
		self.a[u.networkID] = true
	end
end

function SLPrediction:ProcessSpellComplete(u,s)
if not SLP then return end
	if u and u.team ~= myHero.team and s and s.name and s.name:lower():find("attack") and self.a[u.networkID] then
		DelayAction(function()
			self.a[u.networkID] = false
		end,(os.clock() + GetDistance(s.target,u) / (self.p[u.charName] or math.huge) - GetLatency()/2000)*.001)
	end
	if u.team == myHero.team and s.name:lower():find("attack") and not u.isMe then
		for i = 1, #self.AA do
			if self.AA[i].a == u then
				table.remove(self.AA, i)
				break
			end
		end
		table.insert(self.AA,{a=u,t=s.target,ht=os.clock()+1000*(s.windUpTime+GetDistance(s.target,u)/(self.p[u.charName] or math.huge))-GetLatency()/2000})
	end
end

function SLPrediction:MinionCollision(s,u,pos,width)
	for m,p in pairs(minionManager.objects) do
		if p and p.alive and u.networkID ~= p.networkID and p.team ~= myHero.team then
			local vPPOLS = VectorPointProjectionOnLineSegment(Vector(s.pos),Vector(pos),Vector(p.pos))
			if vPPOLS and GetDistance(vPPOLS,p.pos) < p.boundingRadius+width+10 then
				return true
			end
		end
	end
	return false
end

function SLPrediction:HeroCollision(s,u,pos,width)
	for m,p in pairs(GetEnemyHeroes()) do
		if p and p.alive and u.networkID ~= p.networkID then
			local vPPOLS = VectorPointProjectionOnLineSegment(Vector(s.pos),Vector(pos),Vector(p.pos))
			if vPPOLS and GetDistance(vPPOLS,p.pos) < p.boundingRadius+width+10 then
				return true
			end
		end
	end
	return false
end

function SLPrediction:IsMoving(u)
	for _,__ in pairs(self.um) do
		if __.u.networkID == u.networkID then
			if not self.a[_] and not self.c[_] and not self.s[_] and __.ep and GetDistance(__.u,__.ep) > 5 then
				return true
			end
		end
	end
	return false
end

function SLPrediction:pos(d,w)
	for _,__ in pairs(self.um) do
		if __ and self:IsMoving(__.u) then
			if not __.u.visible then
				return Vector(__.sp)+Vector(Vector(__.ep)-__.sp):normalized()*((__.ds or __.u.ms)*(os.clock()-__.st) + w+__.u.boundingRadius+d*100)
			else
				if not __.ds then
					return Vector(__.u)+Vector(__.u.direction):normalized()*d*(__.u.ms+(w+__.u.boundingRadius)/2)
				else
					return Vector(__.ep)
				end
			end
		end
	end
end

function SLPrediction:round(num,idp)
  return math.floor(num*(10^(idp or 0))+0.5)/(10^(idp or 0))
end

function SLPrediction:GetPredictedHealth(u,t,d)
    IC=0
	d=(d and d) or 0
    for _,i in pairs(self.AA) do
		if i.a.alive and i.t.networkID==u.networkID then
			h=math.floor(i.ht-d*.001)
			if h-.0002<self:round(os.clock()+t+GetLatency()/2000) then
				IC=IC+self:Dmg(i.a,u,{name="Basic"})
			end
			if self:Dmg(myHero,u,{name="Basic"})>u.health-IC then
				break
			end
		end	
	end
	return u.health-IC
end

function SLPrediction:Predict(table)--{source=source,unit=unit,speed=speed,range=range,delay=delay,width=width,type="",collision=collision}
	if not table.unit then print("not a valid unit") return end
	table.source = table.source or myHero
	table.speed = table.speed or math.huge
	table.range = table.range or 1200
	table.delay = table.delay or 0
	table.width = table.width or (table.source.boundingRadius or myHero.boundingRadius)
	table.collision = table.collision or false
	table.type = table.type or ""
	if table.unit.type == myHero.type then
		for _,__ in pairs(self.um) do
			if _ == table.unit.networkID and __ then
				if self:pos(table.delay,table.width) and table.collision and not self:HeroCollision(table.source,table.unit,self:pos(table.delay,table.width),table.width) and not self:MinionCollision(table.source,table.unit,self:pos(table.delay,table.width),table.width) then
					self.predictedpos = self:pos(table.delay,table.width)
				elseif self:pos(table.delay,table.width) and not table.collision then
					self.predictedpos = self:pos(table.delay,table.width)
				end
			end
		end
		if not self:IsMoving(table.unit) and table.unit.visible then
			self.hitchance = 2
			self.predictedpos = table.unit.pos
		else
			self.hitchance = math.min(2,math.ceil((table.unit.ms/table.width)/GetLatency()/2000+table.delay+GetDistance(table.source,self.predictedpos)/table.speed))
		end
	else
		self.predictedpos = table.unit.pos
		self.hitchance = math.min(2,math.ceil((table.unit.ms/table.width)/GetLatency()/2000+table.delay+GetDistance(table.source,self.predictedpos)/table.speed))
	end
	return self.hitchance and self.hitchance,self.predictedpos and self.predictedpos
end

function LoadSLP()
if not _G.SLP then _G.SLP = SLPrediction() end
return SLP
end

class 'Update'

function Update:__init()
	if not AutoUpdater then return end
	self.Data = nil
	self.CallDraw = nil
	self.CallWnd = nil
	self.Do = nil
	self.lockCL = false
	self.Sprites = {}
	GetWebResultAsync("https://raw.githubusercontent.com/xSxcSx/SL-Series/master/SL.changelog", 
	function(page) 
		if page == "404: Not Found" then return end
		assert(load("change = "..page))()
		if change and type(change) == "table" and change.version and change.version > SLAIO then
			local y = 0
			for _,i in pairs(change) do
				y = y + 30 * (type(i) == "table" and #i or 1) + 75
			end
			change.height = y
			self.Data = change
			change = nil
			
			for _,i in pairs(self.Data) do
				if FileExist(SPRITE_PATH.."Champions\\Circle50\\".._..".png") then
					self.Sprites[_] = Sprite("Champions\\Circle50\\".._..".png", 50, 50, 0, 0) 
				else
					GetWebResultAsync("https://raw.githubusercontent.com/LoggeL/ChampSprites/master/Circle50/".. _ ..".png", function (b)
					DelayAction(function()
						if b ~= "404: Not Found" then 
							DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/ChampSprites/master/Circle50/".. _ ..".png", SPRITE_PATH.."Champions\\Circle50\\".. _ ..".png", 
							function() 	
							DelayAction(function()
								self.Sprites[_] = Sprite("Champions\\Circle50\\".. _ ..".png", 50, 50, 0, 0) 
							end,.1)
						end)
					elseif FileExist(SPRITE_PATH.."Champions\\Circle50\\Unknown.png") then
						self.Sprites[_] = Sprite("Champions\\Circle50\\Unknown.png", 50, 50, 0, 0)
					end
				end,.1)
			end)
				end
			end
			
			self.CallDraw = Callback.Add("Draw", function() self:Draw() end)
			self.CallWnd  = Callback.Add("WndMsg", function(k,m) self:Click(k,m) end)
		end
	end)
end

function Update:Draw()
	FillRect(172,WINDOW_H*.2-50,232,93,GoS.Black)
	FillRect(175,WINDOW_H*.2-47,195,85,GoS.Yellow)
	local cp = GetCursorPos()
	if cp.x > 375 and cp.x < 400 and cp.y > WINDOW_H*.2-47 and cp.y < WINDOW_H*.2+38 or self.lockCL then
		FillRect(375,WINDOW_H*.2-47,25,85,GoS.White)
		
		FillRect(398,WINDOW_H*.2-48,WINDOW_W*.5+5,self.Data.height+5,GoS.Black)
		FillRect(400,WINDOW_H*.2-47,WINDOW_W*.5,self.Data.height,ARGB(255,128,123,110))
		
		local y = 75
		
		DrawText("SL-AIO Changelog to version ".. self.Data.version,50,500,WINDOW_H*.2-30,ARGB(255,255,188,0))
		for _,i in pairs(self.Data) do
			if _ ~= "version" and _ ~= "height" then
			
				DrawText(_,30,420,WINDOW_H*.2+y-50,ARGB(255,255,188,0))
				
				if self.Sprites[_] then
					self.Sprites[_]:Draw(425,WINDOW_H*.2+y)
				else
				--	FillRect(425,WINDOW_H*.2+y,50,50,ARGB(255,255,188,0))
					DrawText("Placeholder",20,425,WINDOW_H*.2+y,ARGB(255,255,188,0))
				end
				
				for n,m in pairs(i) do
					FillRect(525,WINDOW_H*.2+y,WINDOW_W*.5-150,20,ARGB(255,255,188,0))
					DrawText(m,20,530,WINDOW_H*.2+y,GoS.Black)
					y = y + 30
				end
				y = y + 75
			end
		end
	else
		FillRect(375,WINDOW_H*.2-47,25,85,GoS.Yellow)
	end
	
	DrawText("Changelog",30,240,WINDOW_H*.2-20,GoS.Black)
	
	DrawLine(380,WINDOW_H*.2-40,395,WINDOW_H*.2-3,3,GoS.Black)
	DrawLine(395,WINDOW_H*.2-3,380,WINDOW_H*.2+35,3,GoS.Black)
	
	CircleSegment(150,WINDOW_H*.2,85,0,360,GoS.Red)
	
	if not self.Do then --Changelog info
		if math.sqrt((cp.x-150)^2+(cp.y-WINDOW_H*.2)^2) < 80 then
			CircleSegment(150,WINDOW_H*.2,75,0,360,ARGB(255,128,123,110))
		else
			CircleSegment(150,WINDOW_H*.2,75,0,360,GoS.Black)
		end
		local t = GetTextArea("Update to",25)
		DrawText("Update to",25,150-t.x+5,WINDOW_H*.2-t.y,GoS.Green)
		local t = GetTextArea("v "..self.Data.version,30)
		DrawText("v "..self.Data.version,30,150-t.x,WINDOW_H*.2+t.y*.5,GoS.Green)
	elseif GetTickCount() - self.Do < 3700 then
		CircleSegment(150,WINDOW_H*.2,75,0,360,ARGB(255,128,123,110))
		CircleSegment(150,WINDOW_H*.2,75,0,math.min((GetTickCount() - self.Do)*.1,360),GoS.Green)
		DrawText("Updating...",35,75,WINDOW_H*.2-15,GoS.Black)
	else 
		CircleSegment(150,WINDOW_H*.2,75,0,360,ARGB(255,128,123,110))
		DrawText("Updated!",35,85,WINDOW_H*.2-15,GoS.Green)
	end
		
end

function Update:Click(key,msg)
	local cp = GetCursorPos()
	if key == 513 then
		if cp.x > 375 and cp.x < 400 and cp.y > WINDOW_H*.2-47 and cp.y < WINDOW_H*.2+38 then
			self.lockCL = not self.lockCL
		elseif math.sqrt((cp.x-150)^2+(cp.y-WINDOW_H*.2)^2) < 80 and not self.Do then
			self.Do = GetTickCount()
	        if GetUser() == "Zwei" or GetUser() == "Ein" or GetUser() == "SxcS" then print("Dev detected! Update manually!") return end
			DownloadFileAsync("https://raw.githubusercontent.com/xSxcSx/SL-Series/master/SL-AIO.lua", SCRIPT_PATH .. "SL-AIO.lua", function() print("Reload after download is finished!") return end)
		end
	end
end

--[[

SLWalker API

_G.SLW 																- Checks if its loaded

SLW.movementEnabled = true/false
SLW.attacksEnabled = true/false		
SLW.forcePos = Vector3D									- SLW.forcePos = unit.pos
SLW.forceTarget = unit
SLW.rangebuffer[unit.charName] 						- table, returns extra range, ex: KogMaw W
SLW.projectilespeeds[unit.charName]				    - table, returns projectile speed of an unit/object
SLW.aarange														- returns aa range of myHero
SLW:Dmg(source,unit,spell)								- SLW:Dmg(myHero,unit,{name="Basic"})
SLW:ResetAA()
SLW:IsOrbwalking()											- returns true/false
SLW:Mode() == "Combo/Harass/LaneClear/LastHit"
SLW:PredictHP(unit,time)
SLW:DontOrb() 													-returns true if antichannel spells are casted
SLW:AddCB(callbackType, function) 					- callbacktype = Before_AA, After_AA


SLEvade API

_G.SLE 															- Checks if its loaded
_G.IsEvading  													- returns true/false

]]
