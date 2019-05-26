if SERVER then
	AddCSLuaFile()
	resource.AddFile ("materials/vgui/ttt/icon_micriwave.vmt")
	resource.AddFile ("materials/vgui/ttt/icon_suitcasewave.vtf")
	resource.AddWorkshop( "896084374" )
end



SWEP.HoldType = "normal"


if CLIENT then
   SWEP.PrintName = "The T-Suitcase"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Receive a random Traitor Item!"
   };

   SWEP.Icon = "vgui/ttt/suitcase"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/props_c17/suitcase_passenger_physics.mdl"

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "9mmRound"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment


SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_DETECTIVE} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_CUBE

SWEP.AllowDrop = true

SWEP.NoSights = true

function SWEP:PrimaryAttack()
print(self:GetMaxClip1())
	if not self:CanPrimaryAttack() then
	return end
	
	 self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	 
	 self:CreateSuitcase()
	 self:TakePrimaryAmmo ( 1 )
	 if SERVER then
	 self:Remove()
	 end
	 
end

function SWEP:DrawWorldModel()

return false
end

SWEP.ENT = nil


function SWEP:CreateSuitcase()
	if SERVER then
		local ply = self.Owner
		local suitcase = ents.Create("ttt_traitor_case")
			if IsValid(suitcase) and IsValid(ply) then
				local vsrc = ply:GetShootPos()
				local vang = ply:GetAimVector()
				local vvel = ply:GetVelocity()
				local vthrow = vvel + vang * 100
				suitcase:SetPos(vsrc + vang * 10)
				suitcase:Spawn()
				
				local phys = suitcase:GetPhysicsObject()
				
					if IsValid(phys) then
						phys:SetVelocity(vthrow)
						phys:SetMass(200)
					end 
					self.ENT = suitcase
				
			end
		
	end
end


function SWEP:SecondaryAttack()

  if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay)
		if not IsFirstTimePredicted() then return end
	
end


function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end