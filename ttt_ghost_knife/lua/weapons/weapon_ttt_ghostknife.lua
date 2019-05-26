
AddCSLuaFile()


resource.AddFile( "models/weapons/ice_knife/c_ice_knife.mdl" )
resource.AddFile( "models/weapons/ice_knife/w_ice_knife.mdl" )
resource.AddFile( "materials/models/weapons/w_models/w_knife_t/blade_ice.vmt" )
resource.AddFile( "materials/models/weapons/w_models/w_knife_t/knife_t.vmt" )
resource.AddFile ("materials/vgui/ttt/icon_ghostknife.vmt")
resource.AddFile ("materials/vgui/ttt/icon_ghostknife.vtf")

if SERVER then
resource.AddWorkshop( "1326662749" )
end


SWEP.HoldType = "knife"

if CLIENT then

   SWEP.PrintName = "Ghost Knife"
   SWEP.Slot = 6

   SWEP.ViewModelFOV  = 54
   SWEP.ViewModelFlip = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "You can switch places with your target when you hit it\nwith a thrown Ghost Knife.\n\nPress M2 to throw your Knife."
   };


   SWEP.Icon = "vgui/ttt/icon_ghostknife"
end

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil	= 4
SWEP.Primary.Damage = 7
SWEP.Primary.Delay = 1.0
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = -1
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipMax = -1

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_GHOSTKNIFE

-- if I run out of ammo types, this weapon is one I could move to a custom ammo
-- handling strategy, because you never need to pick up ammo for it
SWEP.Primary.Ammo = "AR2AltFire"

SWEP.UseHands			= true
SWEP.ViewModel	= Model("models/weapons/ice_knife/c_ice_knife.mdl")
SWEP.WorldModel	= Model("models/weapons/ice_knife/w_ice_knife.mdl")

SWEP.Tracer = "AR2Tracer"


function SWEP:PrimaryAttack()
  return true
end

function SWEP:PreDrawViewModel( vm, wep, ply )
		vm:SetMaterial("Models/effects/splodearc_sheet")
		self:SetMaterial("Models/effects/splodearc_sheet")
end

function SWEP:ViewModelDrawn( vm )
	if wep == self then
		vm:SetMaterial("Models/effects/splodearc_sheet")
	else
		vm:SetMaterial('')
	end
end
	
function SWEP:SecondaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   


   self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )

   if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      ply:SetAnimation( PLAYER_ATTACK1 )

      local ang = ply:EyeAngles()

      if ang.p < 90 then
         ang.p = -10 + ang.p * ((90 + 10) / 90)
      else
         ang.p = 360 - ang.p
         ang.p = -10 + ang.p * -((90 + 10) / 90)
      end

      local vel = math.Clamp((90 - ang.p) * 5.5, 550, 800)

      local vfw = ang:Forward()
      local vrt = ang:Right()

      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())

      src = src + (vfw * 1) + (vrt * 3)

      local thr = vfw * vel + ply:GetVelocity()

      local knife_ang = Angle(-28,0,0) + ang
      knife_ang:RotateAroundAxis(knife_ang:Right(), -90)

      local knife = ents.Create("ttt_ghostknife_proj")
      if not IsValid(knife) then return end
      knife:SetPos(src)
      knife:SetAngles(knife_ang)

      knife:Spawn()

      knife.Damage = self.Primary.Damage

      knife:SetOwner(ply)

      local phys = knife:GetPhysicsObject()
      if IsValid(phys) then
         phys:SetVelocity(thr)
         phys:AddAngleVelocity(Vector(0, 1500, 0))
         phys:Wake()
      end

      self:Remove()
   end
end