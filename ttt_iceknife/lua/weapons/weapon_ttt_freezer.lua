
AddCSLuaFile()


resource.AddFile("models/weapons/ice_knife/c_ice_knife.mdl")
resource.AddFile("models/weapons/ice_knife/w_ice_knife.mdl")
resource.AddFile("materials/models/weapons/w_models/w_knife_t/blade_ice.vmt")
resource.AddFile("materials/models/weapons/w_models/w_knife_t/knife_t.vmt")
resource.AddFile("materials/vgui/ttt/icon_iceknife.vmt")
resource.AddFile("materials/vgui/ttt/icon_iceknife.vtf")
resource.AddFile("materials/vgui/ttt/hud_icon_iceknife.png")

if SERVER then
	resource.AddWorkshop( "477143906" )
end


SWEP.HoldType = "knife"

if CLIENT then

	SWEP.PrintName = "Ice Knife"
	SWEP.Slot = 6

	SWEP.ViewModelFOV  = 54
	SWEP.ViewModelFlip = false

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "Freeze your Victim.\nIt also deals 15 DMG over time."
	};


	SWEP.Icon = "vgui/ttt/icon_iceknife"

	-- set up sidebar icon
	if TTT2 then
		hook.Add("Initialize", "ttt_iceknife_sidebar_icon_init", function() 
			STATUS:RegisterStatus("ttt_iceknife_sidebar_icon", {
				hud = Material("vgui/ttt/hud_icon_iceknife.png"),
				type = "bad"
			})
		end)
	end
end

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil	= 4
SWEP.Primary.Damage = 7
SWEP.Primary.Delay = 1.0
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 2
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 2
SWEP.Primary.ClipMax = 4

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_FREEZE

-- if I run out of ammo types, this weapon is one I could move to a custom ammo
-- handling strategy, because you never need to pick up ammo for it
SWEP.Primary.Ammo = "AR2AltFire"

SWEP.UseHands	= true
SWEP.ViewModel	= Model("models/weapons/ice_knife/c_ice_knife.mdl")
SWEP.WorldModel	= Model("models/weapons/ice_knife/w_ice_knife.mdl")

SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot" )

SWEP.Tracer = "AR2Tracer"


function SWEP:PrimaryAttack()
    if ( not self:CanPrimaryAttack() ) then
        return
	end
	
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*87)
		tracedata.filter = self.Owner
			
		if ( self.Owner:IsPlayer() ) then
			self.Owner:LagCompensation( true )
		end
			
		local trace = util.TraceLine(tracedata)
			
		if ( self.Owner:IsPlayer() ) then
			self.Owner:LagCompensation( false )
		end

		if trace.HitNonWorld then
			target = trace.Entity
					
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
					
			local inflictor = ents.Create("weapon_ttt_freezer")
			local Owner = self.Owner
	
			timer.Create("SomeSimpleIDNameAgain" .. tostring(self.Owner:SteamID()), 0.2, 15, function()
				if IsValid(inflictor) then
					if target:IsPlayer() and not target:IsSpec() then
					
						local dmg = DamageInfo()
						dmg:SetDamageType(DMG_RADIATION)
						dmg:SetAttacker(Owner)
						dmg:SetDamage(1)
						dmg:SetInflictor(inflictor)
						target:TakeDamageInfo(dmg)
						
					else end
				else end
			end)
	
			timer.Create ("ThisIDNameIsFancy" .. tostring(self.Owner:SteamID()), 5,1 , function()
				if target:IsPlayer() then 
					target:Freeze(false)
					if TTT2 then STATUS:RemoveStatus(target, "ttt_iceknife_sidebar_icon") end
				end 
			end)
			   
			if target:IsPlayer() and not target:IsSpec() then 
				target:Freeze(true)
				if TTT2 then STATUS:AddStatus(target, "ttt_iceknife_sidebar_icon") end

				target:RemoveFlags(32768)
					
				self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
						
				self:TakePrimaryAmmo( 1 )
					
				if (self:Clip1() == 0) then self:Remove() RunConsoleCommand("lastinv") end
			end
		end
	end
end
	
	
if CLIENT then
	function SWEP:DrawHUD()
     
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector()
			local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*87)
		tracedata.filter = self.Owner
		local trace = util.TraceLine(tracedata)

      	if trace.HitNonWorld and IsValid(trace.Entity) and trace.Entity:IsPlayer() then

			local x = ScrW() / 2.0
        	local y = ScrH() / 1.5

         	surface.SetDrawColor(255, 0, 0, 255)

        	draw.SimpleText("(FREEZE THIS PLAYER)", "TabLarge", x, y - 30, Color(0,100,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    	end
      return self.BaseClass.DrawHUD(self)
   end
end
	
function DieTimer()
	timer.Destroy("SomeSimpleIDNameAgain")
end
hook.Add("TTTPrepareRound", "KillThisTimer", DieTimer)

function SWEP:SecondaryAttack()
end