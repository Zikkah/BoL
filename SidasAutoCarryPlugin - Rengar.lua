
local target


local qReady
local qCooldown

local wReady
local wCooldown
local wRange = 475

local eReady
local eCooldown
local eRange = 525

local rReady
local rCooldown


local DoingTripleQ = false
local qTime = 0





function PluginOnLoad()
  	AutoCarry.SkillsCrosshair.range = 525
	AutoCarry.PluginMenu:addParam("Combo", "Use Main Combo With Auto Carry", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("EmpPriority", "Empowered priority:1=Q 2=W 3=E", SCRIPT_PARAM_SLICE, 1, 1, 3, 0)
	AutoCarry.PluginMenu:addParam("TrowE", "Range to throw E in main combo", SCRIPT_PARAM_SLICE, 250, 1, 525, 0)
	AutoCarry.PluginMenu:addParam("ForceE", "Force E at 4 fury when cooldowns", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("TripleQ", "Use TrippleQ with Auto Carry", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	AutoCarry.PluginMenu:addParam("Harass", "Use Harass With Mixed Mode", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("eHarass", "Use E in harass", SCRIPT_PARAM_ONOFF, true)	
	AutoCarry.PluginMenu:addParam("wHarass", "Use W in harass", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("KillSteal", "Killsteal with E or W", SCRIPT_PARAM_ONOFF, true)



end

function PluginOnTick()

	target = AutoCarry.GetAttackTarget()
	
	qReady = myHero:CanUseSpell(_Q) == READY
    	wReady = myHero:CanUseSpell(_W) == READY
   	eReady = myHero:CanUseSpell(_E)	== READY
   	rReady = myHero:CanUseSpell(_R) == READY
	qCooldown = myHero:CanUseSpell(_Q) ~= READY
    	wCooldown = myHero:CanUseSpell(_W) ~= READY
    	eCooldown = myHero:CanUseSpell(_E)	~= READY
    	rCooldown = myHero:CanUseSpell(_R) ~= READY	
	
	if AutoCarry.PluginMenu.TripleQ and myHero.mana < 4 and DoingTripleQ == false then
		PrintChat("Not enough Fury, Triple Q DISABLED")
		AutoCarry.PluginMenu.TripleQ = false
	end
	
	if AutoCarry.PluginMenu.TripleQ and rCooldown and DoingTripleQ == false then
		PrintChat("Your ult is on cooldown. Triple Q DISABLED")
		AutoCarry.PluginMenu.TripleQ = false
	end	
	
	if AutoCarry.PluginMenu.TripleQ and qCooldown and DoingTripleQ == false then
		PrintChat("Your Q is on cooldown. Triple Q DISABLED")
		AutoCarry.PluginMenu.TripleQ = false
	end	
		
	
	if AutoCarry.PluginMenu.Combo and AutoCarry.MainMenu.AutoCarry and AutoCarry.PluginMenu.TripleQ == false then
		Combo()
	end
	
	if AutoCarry.PluginMenu.TripleQ and AutoCarry.PluginMenu.Combo and AutoCarry.MainMenu.AutoCarry then 
		TripleQ()
	end	

	if AutoCarry.PluginMenu.Harass and AutoCarry.MainMenu.MixedMode then 
		Harass()
	end	
	if AutoCarry.PluginMenu.KillSteal then 
		KillStealEW()
	end	
end

function Combo()

	if target ~= nil then
	
		
	
		if myHero.mana <= 4 then
			if qReady and pActive and GetDistance(target) <= 250 then 
				CastSpell(_Q)
			end
			if qReady and not pActive and GetDistance(target) <= 250 then
				CastSpell(_Q)
			end
		
			if wReady and qCooldown and GetDistance(target) <= wRange then
				CastSpell(_W)
			end
			if wReady and GetDistance(target) >= 150 and GetDistance(target) <= wRange then
				CastSpell(_W)
			end
			
			if eReady and GetDistance(target) <= eRange and GetDistance(target) >= AutoCarry.PluginMenu.TrowE then
				CastSpell(_E, target)
			end
			if myHero.mana == 4 and eReady and qCooldown and wCooldown and AutoCarry.PluginMenu.ForceE then
				CastSpell(_E, target)
			end	
			
		end	
			

		if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 1 and GetDistance(target) <= 300 then
			CastSpell(_Q)
		end
		if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 2 and GetDistance(target) <= wRange then
			CastSpell(_W)
		end
		if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 3 and GetDistance(target) <= eRange then
			CastSpell(_E, target)
		end
		
	end		

end


function TripleQ()

	
		if myHero.mana == 4 and rReady then
			
			if qReady and rReady then
				
				AutoCarry.CanAttack = false
				CastSpell(_Q)
				CastSpell(_R)
				
				qTime = os.clock()
								
				DoingTripleQ = true
								
			end	
		end
	
	
		if myHero.mana == 5 and rReady then
			
			
			if qReady and rReady then
				
				AutoCarry.CanAttack = false
				CastSpell(_Q)
				CastSpell(_R)
				
				qTime = os.clock()
								
				DoingTripleQ = true
								
			end	
		end
	
		
		if rReady == false and os.clock() - qTime > 3.75 and DoingTripleQ == true then
			
			AutoCarry.CanAttack = true
				if qReady and os.clock() - qTime > 4.25 then
					CastSpell(_Q)
				end
		end 
		
		
		
		if os.clock() - qTime > 5.6 then
			
			DoingTripleQ = false
			AutoCarry.PluginMenu.TripleQ = false
			
			Combo()
		end
		
			
			
	
end

function Harass()
	
	if target ~= nil then
		if myHero.mana <= 4 then
			if eReady and GetDistance(target) <= eRange and AutoCarry.PluginMenu.eHarass then
				CastSpell(_E, target)
			end
			if wReady and myHero.mana <= 4 and GetDistance(target) <= wRange and AutoCarry.PluginMenu.wHarass then
				CastSpell(_W, target)
			end
			
		end
		
		if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 2 and GetDistance(target) <= wRange and AutoCarry.PluginMenu.wHarass then
			CastSpell(_W, target)
		end
		if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 3 and GetDistance(target) <= eRange then
			CastSpell(_E, target)
		end
	end		
end




function KillStealEW()



    for _, enemy in pairs(AutoCarry.EnemyTable) do
     
        if ValidTarget(enemy, eRange) and enemy.health < getDmg("E", enemy, myHero)and eReady then
     
             CastSpell(_E, enemy)
     
        end
		if ValidTarget(enemy, wRange) and enemy.health < getDmg("W", enemy, myHero) and wReady then
			
             CastSpell(_W, enemy)
     
		end
     
		if ValidTarget(enemy, wRange) and enemy.health < getDmg("E", enemy, myHero) + getDmg("W", enemy, myHero) and eReady and wReady then
			CastSpell(_E, enemy)
			CastSpell(_W, enemy)

		end
     end	
	 
end
	


function PluginOnDraw()

	if AutoCarry.PluginMenu.TripleQ == true and DoingTripleQ == false then
		PrintFloatText(myHero, 0, "Triple Q Active")
	end
	
		
	if DoingTripleQ == true then
		PrintFloatText(myHero, 0, "Performing Tripple Q")
	end


	
end	
	
	
	
	
	
	
	
