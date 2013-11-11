if myHero.charName ~= "Gragas" then return end
function OnLoad()
	require "Prodiction"
	require "Collision"
	require "AoE_Skillshot_Position"
	Menu()
	Vars()
    Spells()
	-- Create Table structure
	for i=1, heroManager.iCount do
		local champ = heroManager:GetHero(i)
		if champ.team ~= myHero.team then
		EnemysInTable = EnemysInTable + 1
		EnemyTable[EnemysInTable] = { hero = champ, Name = champ.charName, q = 0, e = 0, r = 0, IndicatorText = "", IndicatorPos, NotReady = false, Pct = 0, PeelMe = false }
		
		end
	end

end


function OnTick()
	Target = ts.target
	GlobalInfo()
	AutoSpells()
	Calculations()
	if GMenu.Combo then
		Combo()
	end
	if GMenu.Harass then
		if ValidTarget(Target) then
			if dashx ~= nil then
				CastSpell(_Q, dashx, dashz)
			else
				ProQ:EnableTarget(Target, true)
			end
		end
	end


	if GMenu.AutoPull then
		local PeelMe = nil
		for i=1, EnemysInTable do
			if EnemyTable[i].PeelMe == true then
				PeelMe = EnemyTable[i].hero
				if GetDistance(PeelMe) < 1000 and ValidTarget(PeelMe) then
					PullWithR(PeelMe)
				end
			end
		end
	end

	if GMenu.ManualPull then
		if not ChannelingW and GMenu.MoveToMousePull then
			moveToCursor()
		end
		for _, enemy in pairs(GetEnemyHeroes()) do
			if PeelTargetManual ~= nil and GetDistance(mousePos, PeelTargetManual) > 250 then
				PeelTargetManual = nil
			end
			
			if GetDistance(mousePos, enemy) < 250 then
				if PeelTargetManual == nil then
					PeelTargetManual = enemy
					 
				end
				if PeelTargetManual ~= nil then
					PullWithR(PeelTargetManual)
				end
				
			end
			
			
		end

		if dashx ~= nil then
			CastSpell(_Q, dashx, dashz)
			if EStart < GetGameTimer() then -- Start casting E at landing pos as soon as landing pos is known
				CastSpell(_E, dashx, dashz)
				return
			end
		return
		end	
	else
		PeelTargetManual = nil
		
	end
end


function Combo()
		
		
		

	if ValidTarget(Target) then
		if GMenu.OrbWalk then
			OrbWalk()
		elseif GMenu.MoveToMouse then
			moveToCursor()
		end
		CastE(Target)
		CastQ(Target)
		GlobalInfo() -- Fail safe to determine combo behaviour
		CastR(Target)
		
		
		
	elseif GMenu.MoveToMouse or GMenu.OrbWalk then
		if not ChannelingW then
			moveToCursor()
		end
	end

end

function CastE(unit)	
	if GMenu.DontETeamfight and AreaEnemyCount(unit, 700) >= 1 then return
	else
	
		if eReady and GMenu.UseE then

		
			if dashx ~= nil then
				if EStart < GetGameTimer() then -- Start casting E at landing pos as soon as landing pos is known
					CastSpell(_E, dashx, dashz)
					return
				end
				return
			end
			
			
				if GMenu.PullKillable and THealth < TotalDamage and AllReady and GotMana and not UltiThrown then return end
			
				if qReady and qDmg > THealth then
					return
				elseif rReady and rDmg > THealth then
					return
				elseif qReady and rReady and qDmg+rDmg > THealth then
					return
				else
					if not UltiThrown then
						ProE:EnableTarget(unit, true)
					end
				end
			
		end
	
	
	end

	


	
end

function CastQ(unit)

	if qReady then
	
		if dashx ~= nil then -- Start casting Q at landing pos as soon as landing pos is known
			CastSpell(_Q, dashx, dashz)
		end
		
		if not UltiThrown then
			if THealth < qDmg then
				ProQ:EnableTarget(unit, true)
			end
			if GMenu.PullKillable and THealth < TotalDamage and AllReady and GotMana then return end
		
		
		ProQ:EnableTarget(unit, true)
		
		end
	end	

end



function CastR(unit)



	
	if GMenu.DontUltiTeamfight and AreaEnemyCount(unit, 700) > 2 then return 
	
	elseif rReady and GMenu.MecKsR and MecPos and AreaEnemyCount(MecPos, 400, true) >= GMenu.MecAmmount then
		CastSpell(_R, MecPos.x, MecPos.z)
		
	elseif rReady and THealth < rDmg and GMenu.KsR then
		
		if THealth < qDmg or THealth < eDmg and GMenu.KsR then
			if not BarrelThrown then
				if not qReady and THealth < qDmg then
				ProR:EnableTarget(unit, true)
				end
			return end
			if BarrelThrown and Barrel ~= nil and GetDistance(Barrel, unit) > 350 then
				ProR:EnableTarget(unit, true)

			end
		end	
	elseif rReady then
		if TotalDamage > THealth and AllReady then
			PullWithR(unit)
		end
		if qDmg+eDmg+rDmg > THealth then
			if qReady or qCurrCd < 1.5 then
				PullWithR(unit)
			end
		end
	end	
	
		
		
				

end




function PullWithR(unit)
	
	local pos, time, hitchance =   ProR:GetPrediction(unit)	
	if pos then
		local x,y,z = (Vector(pos) - Vector(myHero)):normalized():unpack()
		posX = pos.x + (x * 300)
		posY = pos.y + (y * 300)
		posZ = pos.z + (z * 300)

		
		
		CastSpell(_R, posX, posZ)
		DashTarget = unit
	end
		
	
end

function AutoSpells()

	
	if GMenu.AutoW and wReady and AreaEnemyCount(myHero, 1000) == 0 and not Recalling and ManaPct <= GMenu.ManaPct and not BarrelThrown then
		CastSpell(_W)
	end
	if ChannelingW and AreaEnemyCount(myHero, 1000) >= 2 then
		moveToCursor()
	end
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			if Barrel ~= nil then
				if GetDistance(enemy, Barrel) < 300 then
					CastSpell(_Q)
				end
			
			
			end
			if GMenu.KsQ and qReady and enemy.health < getDmg("Q", enemy, myHero) and not UltiThrown and dashx == nil and GetDistance(enemy, myHero) < 1100 then
					ProQ:EnableTarget(enemy, true)
			end				
	
			if iReady then
				if getDmg("IGNITE", enemy, myHero) >= enemy.health and GetDistance(enemy, myHero) < 600 then
					CastSpell(iSlot, enemy)
				end
			end
		end
	end
end

function OrbWalk()
	if GetDistance(Target) <= trueRange() then
		if timeToShoot() and not ChannelingW then
			myHero:Attack(Target)
		elseif heroCanMove() and not ChannelingW then
			moveToCursor()
		end
	else
		if not ChannelingW then
			moveToCursor()
		end
	end
end

------------------
-- 	Helpers 	--
------------------


function GlobalInfo()
	MouseScreen = WorldToScreen(D3DXVECTOR3(mousePos.x, mousePos.y, mousePos.z))
	ts:update()
	qReady = myHero:CanUseSpell(_Q) == READY and not BarrelThrown
	wReady = myHero:CanUseSpell(_W) == READY
	eReady = myHero:CanUseSpell(_E) == READY
	rReady = myHero:CanUseSpell(_R) == READY
	qMana = myHero:GetSpellData(_Q).mana
	eMana = myHero:GetSpellData(_E).mana
	rMana = myHero:GetSpellData(_R).mana
	qCurrCd = myHero:GetSpellData(_Q).currentCd
	eCurrCd = myHero:GetSpellData(_E).currentCd
	rCurrCd = myHero:GetSpellData(_R).currentCd


	iSlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") and SUMMONER_2) or nil)
	iReady = (iSlot ~= nil and myHero:CanUseSpell(iSlot) == READY)
	dfgSlot = GetInventorySlotItem(3128)
	dfgReady = (dfgSlot ~= nil and GetInventoryItemIsCastable(3128,myHero))
	lichSlot = GetInventorySlotItem(3100)
	lichReady = (lichSlot ~= nil and myHero:CanUseSpell(lichSlot) == READY)
	sheenSlot = GetInventorySlotItem(3057)
	sheenReady = (sheenSlot ~= nil and myHero:CanUseSpell(sheenSlot) == READY)

	MyMana = myHero.mana
	ManaPct = math.round((myHero.mana / myHero.maxMana)*100)
	if qMana + eMana + rMana <= MyMana then
		GotMana = true
	else
		GotMana = false
	end
	if wTime ~= nil and GetGameTimer()-wTime > 1.4 then 
		ChannelingW = false
		wTime = nil
	end
	
	if ValidTarget(Target) then
		MecPos = GetAoESpellPosition(400, Target)

		qDmg = getDmg("Q", Target, myHero)
		eDmg = getDmg("E", Target, myHero)
		rDmg = getDmg("R", Target, myHero)
		iDmg = (iReady and getDmg("IGNITE", Target, myHero) or 0)
		THealth = Target.health
		sheendamage = (SHEENSlot and getDmg("SHEEN",enemy,myHero) or 0)
		lichdamage = (LICHSlot and getDmg("LICHBANE",enemy,myHero) or 0)
		TotalDamage = qDmg+eDmg+rDmg+sheendamage+lichdamage+iDmg
		if dfgReady then 
			TotalDamage = TotalDamage * 1.2
		end	
		if rReady then
			AllReady = true
			if qCurrCd > 1.5 then
				AllReady = false
			end
			if iSlot and not iReady then
				AllReady = false
			end
			if dfgSlot and not dfgReady then
				AllReady = false
			end
		else
			AllReady = false
		end
		
	end
	if myHero.dead then
	-- Fail safe shit
		UltiThrown = false
		BarrelThrown = false
		DashTarget = nil
		dashx = nil
		dashy = nil
		dashz = nil
		Recalling = false
		Barrel = nil
		GetDash = false
		DashEndTime = nil
		EStart = nil
		
	end
	
	if DashEndTime ~= nil then
		if DashEndTime < GetGameTimer() and not Reset then
			Reset = true
		end
	end
	
	if Reset == true then
		
	
			dashx = nil
			dashy = nil
			dashz = nil
			GetDash = false
			DashTarget = nil
			UltiThrown = false
			Reset = false
			DashEndTime = nil
			EStart = nil
		
	end

end


function AreaEnemyCount(Spot, Range, Killable)
	local count = 0
	if Killable == nil then Killable = false end
	
	if Killable == true then
	
		for _, enemy in pairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead and GetDistance(Spot, enemy) <= Range and getDmg("R", enemy, myHero) > enemy.health then
				count = count + 1
			end
		end   
	
	
	else
		for _, enemy in pairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead and GetDistance(Spot, enemy) <= Range then
				count = count + 1
			end
		end            
	end
	return count
end





------------------
-- Callbacks	--
------------------

function OnProcessSpell(object,spell)
--	gragasbarrelrolltoggle
	if object == myHero then
	
		if spell.name:find("GragasExplosive") then -- ULT casted
			UltiThrown = true
			GetDash = true
			UltTime = math.floor(GetGameTimer())
		
		end
		if spell.name:find("GragasBarrelRoll") then -- Q casted
			BarrelThrown = true
		end
		if spell.name:find("GragasDrunkenRage") then -- W casted
			ChannelingW = true
			wTime = GetGameTimer()
		end
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
		end
	end
end

-- gragas_barrelroll
-- gragas_barrelboom
function OnCreateObj(obj)

	if obj.name:find("gragas_barrelfoam") and BarrelThrown then
		Barrel = obj
	end

end

function OnDeleteObj(obj)

	if obj.name:find("gragas_caskboom") and UltiThrown then -- Ult Exploded
		UltiThrown = false
	end
	

end

function OnGainBuff(unit, buff) 
	if unit.isMe then
		
		if buff.name:find("Recall") then
		Recalling = true
		end
		if buff.name:find("drunkenrageself") then
			ChannelingW = false
		end
	end
end

function OnLoseBuff(unit, buff) 
	
	if unit.isMe then

		if buff.name:find("GragasBarrelRoll") then
			BarrelThrown = false
			Barrel = nil
		end
		if buff.name:find("Recall") then
		Recalling = false
		end
	end
end

function OnUpdateBuff(unit, buff) 
	
	if unit.isMe then
		
		if buff.name:find("drunkenrageself") then
			ChannelingW = false
		end
	end
end

function OnDash(unit, dash) 
	if DashTarget ~= nil and unit == DashTarget and GetDash then -- Get targets landing spot from ulti explosion
	
		dashend = dash.endPos
		dashstartx = unit.x
		dashstarty = unit.y
		dashx = dashend.x
		dashz = dashend.z
		dashy = dashend.y
		DashEndTime = dash.endT
		EStart = DashEndTime - 0.3
		
	end
	
end




------------------
-- Draw+Calcs	--
------------------
function OnDraw()


	if Barrel ~= nil then DrawCircle(Barrel.x, Barrel.y, Barrel.z, 300, ARGB(255,0,255,0)) end

	
	if not GMenu.DisableDraw then
	
	
	if GMenu.ScriptMenu then
		ScriptMenu()
	end
	if GMenu.DmgIndic then
	for i=1, EnemysInTable do
		local enemy = EnemyTable[i].hero
		if enemy.visible and not enemy.dead and GetDistance(enemy, cameraPos) < 3000 then
			enemy.barData = GetEnemyBarData()
			local barPos = GetUnitHPBarPos(enemy)
			local barPosOffset = GetUnitHPBarOffset(enemy)
			local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
			local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
			local BarPosOffsetX = 171
			local BarPosOffsetY = 46
			local CorrectionY =  14.5
			local StartHpPos = 31
			local IndicatorPos = EnemyTable[i].IndicatorPos
			local Text = EnemyTable[i].IndicatorText
			barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos 
			barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY 
			
			if EnemyTable[i].NotReady == true then
				DrawText(tostring(Text),13,barPos.x+IndicatorPos - 10 ,barPos.y-27 ,orange)		
				DrawText("|",13,barPos.x+IndicatorPos ,barPos.y ,orange)
				DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-9 ,orange)
				DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-18 ,orange)
			else
				DrawText(tostring(Text),13,barPos.x+IndicatorPos - 10 ,barPos.y-27 ,ARGB(255,0,255,0))	
				DrawText("|",13,barPos.x+IndicatorPos ,barPos.y ,ARGB(255,0,255,0))
				DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-9 ,ARGB(255,0,255,0))
				DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-18 ,ARGB(255,0,255,0))
			end
		end
	end
	end
	if PeelTargetManual ~= nil then
		DrawText("Pull target: " .. tostring(PeelTargetManual.charName),15, MouseScreen.x, MouseScreen.y-8 ,ARGB(255,0,255,0))
	end
	if GMenu.ShowQ then
		if qReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1200, ARGB(255,0,255,0))
		else
		DrawCircle(myHero.x, myHero.y, myHero.z, 1200, ARGB(255,255,0,0))
		end
	end
	if GMenu.ShowE then
		if eReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, 650, ARGB(255,0,255,0))
		else
		DrawCircle(myHero.x, myHero.y, myHero.z, 650, ARGB(255,255,0,0))
		end
	end
	if GMenu.ShowR then
		if rReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1100, ARGB(255,0,255,0))
		else
		DrawCircle(myHero.x, myHero.y, myHero.z, 1100, ARGB(255,255,0,0))
		end
	end
	end
end


function ScriptMenu()
	
	
	DrawRectangleOutline(MenuX+GMenu.HudPosX, MenuY+GMenu.HudPosY, 130, 300, green, 1)
	
	
-- Menu text

	DrawText("Zikkah's Gragas",15, MenuX+GMenu.HudPosX+17, MenuY+GMenu.HudPosY ,orange)
	DrawText("---Q Settings:", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+11 ,orange)
	DrawText("Auto KS", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+22 ,GetColor(GMenu.KsQ))
	
	DrawText("---W Settings:", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+44 ,orange)
	DrawText("Auto W < " .. tostring(GMenu.ManaPct) .. "%", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+55 ,GetColor(GMenu.AutoW))

	
	DrawText("---E Settings   ",15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+77 ,orange)	
	DrawText("Use in Combo", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+88 ,GetColor(GMenu.UseE))
--	DrawText("Ks R", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+99 ,GetColor(GMenu.KsR))

	
	DrawText("---R Settings",15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+110 ,orange)	
	DrawText("Pull Killable", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+121 ,GetColor(GMenu.PullKillable))
	DrawText("Auto KS", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+132 ,GetColor(GMenu.KsR))

	
	DrawText("---Teamfight",15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+154 ,orange)	
	DrawText("No E in combo", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+165 ,GetColor(GMenu.DontETeamfight))
	DrawText("No ulti in combo", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+176 ,GetColor(GMenu.DontUltiTeamfight))
	DrawText("Auto MEC ulti Ks(" .. tostring(GMenu.MecAmmount) .. ")", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+187 ,GetColor(GMenu.MecKsR))
	
	DrawText("Auto Pull:", 15, MenuX+GMenu.HudPosX+9, MenuY+GMenu.HudPosY+198 ,GetColor(GMenu.AutoPull))
	
	-- Enemy names	
	if EnemyTable[1] ~= nil then DrawText(EnemyTable[1].Name,15, MenuX+GMenu.HudPosX+50, MenuY+GMenu.HudPosY+209 ,GetColor(EnemyTable[1].PeelMe)) end
	if EnemyTable[2] ~= nil then DrawText(EnemyTable[2].Name,15, MenuX+GMenu.HudPosX+50, MenuY+GMenu.HudPosY+220 ,GetColor(EnemyTable[2].PeelMe)) end
	if EnemyTable[3] ~= nil then DrawText(EnemyTable[3].Name,15, MenuX+GMenu.HudPosX+50, MenuY+GMenu.HudPosY+231 ,GetColor(EnemyTable[3].PeelMe)) end
	if EnemyTable[4] ~= nil then DrawText(EnemyTable[4].Name,15, MenuX+GMenu.HudPosX+50, MenuY+GMenu.HudPosY+242 ,GetColor(EnemyTable[4].PeelMe)) end
	if EnemyTable[5] ~= nil then DrawText(EnemyTable[5].Name,15, MenuX+GMenu.HudPosX+50, MenuY+GMenu.HudPosY+253 ,GetColor(EnemyTable[5].PeelMe)) end

	-- Menu Controls
	if IsKeyDown(0x01) then
		if not Pressed then 
		
			-- Q Menu Controls
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 100 and MouseScreen.y > MenuY+GMenu.HudPosY+ 23 and MouseScreen.y < MenuY+GMenu.HudPosY+33  then
				GMenu.KsQ = not GMenu.KsQ
			end
			
			-- W menu controls

			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 100 and MouseScreen.y > MenuY+GMenu.HudPosY+ 56 and MouseScreen.y < MenuY+GMenu.HudPosY+66  then
				GMenu.AutoW = not GMenu.AutoW
			end	

	
			-- E menu controls
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 100 and MouseScreen.y > MenuY+GMenu.HudPosY+ 89 and MouseScreen.y < MenuY+GMenu.HudPosY+99  then
				GMenu.UseE = not GMenu.UseE
			end	
	--[[		if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 100 and MouseScreen.y < MenuY+GMenu.HudPosY+110  then
				GMenu.GapcloseK = not GMenu.GapcloseK
			end	
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 111 and MouseScreen.y < MenuY+GMenu.HudPosY+121  then
				GMenu.GapcloseP = not GMenu.GapcloseP
			end			]]

			-- r menu controls
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 122 and MouseScreen.y < MenuY+GMenu.HudPosY+132  then
				GMenu.PullKillable = not GMenu.PullKillable
			end						
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 133 and MouseScreen.y < MenuY+GMenu.HudPosY+143  then
				GMenu.KsR = not GMenu.KsR
			end			
			
			
			-- Teamfight menu controls
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 166 and MouseScreen.y < MenuY+GMenu.HudPosY+176  then
				GMenu.DontETeamfight = not GMenu.DontETeamfight
			end	
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 177 and MouseScreen.y < MenuY+GMenu.HudPosY+187  then
				GMenu.DontUltiTeamfight = not GMenu.DontUltiTeamfight
			end	
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 188 and MouseScreen.y < MenuY+GMenu.HudPosY+198  then
				GMenu.MecKsR = not GMenu.MecKsR
			end			
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 199 and MouseScreen.y < MenuY+GMenu.HudPosY+209  then
				GMenu.AutoPull = not GMenu.AutoPull
			end						
			
			
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 210 and MouseScreen.y < MenuY+GMenu.HudPosY+220  then
				
				EnemyTable[1].PeelMe = not EnemyTable[1].PeelMe
				
				
			end		
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 221 and MouseScreen.y < MenuY+GMenu.HudPosY+231  then
				EnemyTable[2].PeelMe = not EnemyTable[2].PeelMe
			end		
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 232 and MouseScreen.y < MenuY+GMenu.HudPosY+242  then
				EnemyTable[3].PeelMe = not EnemyTable[3].PeelMe
			end		
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 243 and MouseScreen.y < MenuY+GMenu.HudPosY+253  then
				EnemyTable[4].PeelMe = not EnemyTable[4].PeelMe
			end	
			if MouseScreen.x > MenuX+GMenu.HudPosX+9 and MouseScreen.x < MenuX+GMenu.HudPosX+ 110 and MouseScreen.y > MenuY+GMenu.HudPosY+ 254 and MouseScreen.y < MenuY+GMenu.HudPosY+264  then
				EnemyTable[5].PeelMe = not EnemyTable[5].PeelMe
			end				
		end
		Pressed = true
	end
	if not IsKeyDown(0x01) and Pressed then Pressed = false end

end

function GetColor(check)

if check == true then return green
else
	return red
end
end


function Calculations()
	
	 
	
	for i=1, EnemysInTable do
		
		local enemy = EnemyTable[i].hero
		if not enemy.dead and enemy.visible then
		cqDmg = getDmg("Q", enemy, myHero)
		ceDmg = getDmg("E", enemy, myHero)
		crDmg = getDmg("R", enemy, myHero)
		ciDmg = getDmg("IGNITE", enemy, myHero)
		csheendamage = (SHEENSlot and getDmg("SHEEN",enemy,myHero) or 0)
		clichdamage = (LICHSlot and getDmg("LICHBANE",enemy,myHero) or 0)
		cDfgDamage = 0
		cExtraDmg = 0
		cTotal = 0
	
	if iReady then
		cExtraDmg = cExtraDmg + iDmg
	end
	
	if sheenReady then
		cExtraDmg = cExtraDmg + csheenDamage
	end
	
	if lichReady then
		cExtraDmg = cExtraDmg + clichDamage
	end
	
		EnemyTable[i].q = cqDmg

	
	
	if rReady and not UltiThrown then
		EnemyTable[i].r = crDmg
	else
		EnemyTable[i].r = 0
	end
	
	
		
		EnemyTable[i].e = ceDmg
	
	
	
	if dfgReady then 
		DfgDamage = (EnemyTable[i].q + EnemyTable[i].e + EnemyTable[i].r) * 1.2
		cExtraDmg = cExtraDmg + DfgDamage
	end	
	
	-- Make combos
	if enemy.health < EnemyTable[i].q then
		EnemyTable[i].IndicatorText = "Q Kill"
		EnemyTable[i].IndicatorPos = 0
		if qMana > MyMana or not qReady then
			EnemyTable[i].NotReady = true
		else
			EnemyTable[i].NotReady = false
		end
	
	elseif enemy.health < EnemyTable[i].r then
		EnemyTable[i].IndicatorText =  "R Kill"
		EnemyTable[i].IndicatorPos = 0
		if rMana > MyMana or not qReady or not rReady then
			EnemyTable[i].NotReady = true
		else
			EnemyTable[i].NotReady = false
		end
		
	elseif enemy.health < EnemyTable[i].r then
		EnemyTable[i].IndicatorText =  "E+Q Kill"
		EnemyTable[i].IndicatorPos = 0
		if eMana+qMana > MyMana or not eReady or not qReady then
			EnemyTable[i].NotReady = true
		else
			EnemyTable[i].NotReady = false
		end	
		
	elseif enemy.health < EnemyTable[i].q + EnemyTable[i].r then
		EnemyTable[i].IndicatorText =  "Q+R Kill"
		EnemyTable[i].IndicatorPos = 0
		if qMana + rMana > MyMana or not qReady or not rReady then
			EnemyTable[i].NotReady = true
		else
			EnemyTable[i].NotReady = false
		end
	
	
	elseif enemy.health < EnemyTable[i].q + EnemyTable[i].e + EnemyTable[i].r + cExtraDmg then
		EnemyTable[i].IndicatorText = "Assasinate!"
		EnemyTable[i].IndicatorPos = 0
		if qMana + eMana + rMana > MyMana  then
			EnemyTable[i].NotReady =  true
		else
			EnemyTable[i].NotReady = false
		end
		if not qReady or not rReady or not eReady then
			EnemyTable[i].NotReady =  true
		else
			EnemyTable[i].NotReady = false
		end
		
	else
		
			cTotal = cTotal + EnemyTable[i].q
		
		
			cTotal = cTotal + EnemyTable[i].e
		
			cTotal = cTotal + EnemyTable[i].r
		
		
		HealthLeft = math.round(enemy.health - cTotal)
		PctLeft = math.round(HealthLeft / enemy.maxHealth * 100)
		BarPct = PctLeft / 103 * 100
		EnemyTable[i].Pct = PctLeft
		EnemyTable[i].IndicatorPos = BarPct
 		EnemyTable[i].IndicatorText = PctLeft .. "% Harass"
		if not qReady or not rReady or not eReady then
			EnemyTable[i].NotReady =  true
		else
			EnemyTable[i].NotReady = false
		end
				if qMana + eMana + rMana > MyMana  then
			EnemyTable[i].NotReady =  true
		else
			EnemyTable[i].NotReady = false
		end
		if not qReady or not rReady or not eReady then
			EnemyTable[i].NotReady =  true
		else
			EnemyTable[i].NotReady = false
		end
	end
	
	end

	end	

	
	
	

end






------------------
-- 	On Load		--
------------------

function Menu()
			GMenu = scriptConfig("Beasty Gragas!", "BeastyGragas")
			GMenu:addParam("sep", "----- [ General Settings ] -----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("Combo","Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			GMenu:addParam("Harass","Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
			GMenu:addParam("OrbWalk","Orbwalk in combo", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("MoveToMouse","Move to mouse in combo", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("MoveToMousePull","Move to mouse on manual pull", SCRIPT_PARAM_ONOFF, true)	

	
	
			GMenu:addParam("sep", "----- [ Q Settings ] -----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("KsQ","Auto KS", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("HarassQ","Harass in mixedmode", SCRIPT_PARAM_ONOFF, true)
	
			GMenu:addParam("sep", "----- [ W Settings ] -----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("AutoW","Auto W", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("ManaPct","Auto W when below(Mana %)", SCRIPT_PARAM_SLICE, 70, 1, 100, 0)		
			GMenu:addParam("sep", "----- [ E Settings ] -----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("UseE","Use in Combo", SCRIPT_PARAM_ONOFF, true)

			GMenu:addParam("sep", "----- [ R Settings ] -----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("PullKillable","Pull Killable", SCRIPT_PARAM_ONOFF, true)
            GMenu:addParam("ManualPull", "Manual Pull Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
			GMenu:addParam("KsR","Auto KS", SCRIPT_PARAM_ONOFF, true)
			
			GMenu:addParam("sep", "---- [ Teamfigt ] ----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("DontETeamfight","Dont use E", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("DontUltiTeamfight","Dont use Ulti", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("MecKsR","MEC:KS with ulti:", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("MecAmmount","MEC:Killable with ult:", SCRIPT_PARAM_SLICE, 2, 2, 5, 0)

			GMenu:addParam("AutoPull","Auto Pull", SCRIPT_PARAM_ONOFF, true)
			
			GMenu:addParam("sep", "---- [ Draw ] ----", SCRIPT_PARAM_INFO, "")
			GMenu:addParam("ScriptMenu","Show in-game menu", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("DmgIndic","Show hp-bar indicator", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("ShowQ","Draw Q range", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("ShowE","Draw E range", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("ShowR","Draw R range", SCRIPT_PARAM_ONOFF, true)
			GMenu:addParam("DisableDraw","Disable all visuals", SCRIPT_PARAM_ONOFF, false)
			GMenu:addParam("HudPosX","In-Game Hud X", SCRIPT_PARAM_SLICE, 75, 0, 2000, 0)
			GMenu:addParam("HudPosY","In-Game Hud Y", SCRIPT_PARAM_SLICE, 400, 0, 600, 0)

			GMenu.KsQ = true
			GMenu.HarassQ = true
			GMenu.AutoW = true
			GMenu.UseE = true
			GMenu.PullKillable = true
			GMenu.KsR = true
			GMenu.MecKsR = true
			GMenu.DontETeamfight = true
			GMenu.DontUltiTeamfight = true
			GMenu.AutoPull = false
			
end



function Vars()

ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1300, true)
ts.name = "Gragas"
GMenu:addTS(ts)
_G.DrawCircle = DrawCircle2

--Spells
qReady, wReady, eReady, rReady = false, false, false, false, false
AllReady = false
qText, eText, rText = "","",""
qCurrCd, eCurrCd, rCurrCd = 0,0,0
qDmg, eDmg, rDmg, iDmg, dfgDamage = 0,0,0,0,0
cqDmg, ceDmg, crDmg, ciDmg, cExtraDmg, cTotal, cMana = 0,0,0,0,0,0,0
MyMana = 0
GotMana = false
UltTime = 0
MecPos = nil

--Helpers
lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
BarrelThrown = false
Barrel = nil
UltiThrown = false
Recalling = false
dashx = nil
dashz = nil
dashy = nil
dashstart = nil
GetDash = false
THealth = 0
PeelTargetManual = nil
ChannelingW = false
Reset = false
DashEndTime = nil
EnemyTable = {}
EnemysInTable = 0
HealthLeft = 0
PctLeft = 0
BarPct = 0
EStart = nil
wTime = nil
orange = 0xFFFFE303
green = ARGB(255,0,255,0)
blue = ARGB(255,0,0,255)
red = ARGB(255,255,0,0)
MenuX = 0
MenuY = 0
--MenuX = 800
--MenuY = 200
MouseScreen = WorldToScreen(D3DXVECTOR3(mousePos.x, mousePos.y, mousePos.z))


end



function Spells()
	-- Q
	
	ProQ = ProdictManager.GetInstance():AddProdictionObject(_Q, 1200, 1500, 0.250, 50, myHero, 
        function(unit, pos, spell) 
			if pos and unit and not unit.dead then

           if GetDistance(pos) - getHitBoxRadius(unit)/2 < 1100 and myHero:CanUseSpell(spell.Name) == READY then 
                    CastSpell(spell.Name, pos.x, pos.z)
            end 
			end
        end)
		
	-- E
	eCol =  Collision(750, 1500, 240, 100)
	ProE = ProdictManager.GetInstance():AddProdictionObject(_E, 750, 1500, 0.250, 100, myHero, 
        function(unit, pos, spell) 
		local eCollides = eCol:GetMinionCollision(myHero, unit)
			if pos then
           if GetDistance(pos) - getHitBoxRadius(unit)/2 < 750 and myHero:CanUseSpell(spell.Name) == READY then 
                    if not eCollides then
					CastSpell(spell.Name, pos.x, pos.z)
					end
            end 
			end
        end)
		
	-- R
	ProR = ProdictManager.GetInstance():AddProdictionObject(_R, 1300, 1200, 0.250, 50, myHero, 
        function(unit, pos, spell) 
			if pos then
           if GetDistance(pos) - getHitBoxRadius(unit)/2 < 1300 and myHero:CanUseSpell(spell.Name) == READY then 
                    CastSpell(spell.Name, pos.x, pos.z)
                 
            end 
			end
        end)
	

		
	
		
end	


------------------
-- Orbwalkstuff --
------------------
function trueRange()
	return myHero.range + GetDistance(myHero.minBBox)
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function timeToShoot()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end	
end









-- Lag free circles (by barasia, vadash and viseversa)
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end

