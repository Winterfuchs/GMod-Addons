AddCSLuaFile()

resource.AddFile("vgui/ttt/icon_xmas_present.vmt")
resource.AddFile("vgui/ttt/icon_xmas_present.vtf")

SWEP.HoldType = "normal"


if CLIENT then
   SWEP.PrintName = "Present of Fate"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Make someone a Present! \nYou have chance of 50% to Heal 50HP.\nThere is also a Chance of 50% to explode!\nThis Item can be used twiced!."
   };

   SWEP.Icon = "vgui/ttt/icon_xmas_present"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/props/cs_office/microwave.mdl"

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment


SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only detectives can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_GIFT

SWEP.AllowDrop = true

SWEP.NoSights = true


function SWEP:PrimaryAttack()


	if not self:CanPrimaryAttack() then
	return end
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:CreateGift()

	
end
function SWEP:CreateGift()
if SERVER then

local ply = self.Owner
local gift = ents.Create("ttt_luckypresent")

	if IsValid(gift) and IsValid(ply) then
	
	spos = ply:GetShootPos()
	velo = ply:GetVelocity()
	aim = ply:GetAimVector()
	
	throw = velo + aim * 100
	
	gift:SetPos(spos + aim * 10)
	gift:Spawn()
	
	gift:PhysWake()
	
	
	phys = gift:GetPhysicsObject()
	
		if IsValid(phys) then
		phys:SetVelocity(throw)
		end
	end
	self:Remove()
	
	

end
end

function SWEP:DrawWorldModel()
return false
end

function SWEP:OnDrop()

self:Remove()
end