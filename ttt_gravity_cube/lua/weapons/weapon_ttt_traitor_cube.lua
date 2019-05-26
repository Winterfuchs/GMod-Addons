if SERVER then
	AddCSLuaFile()
	resource.AddFile ("materials/vgui/ttt/icon_cube.vmt")
	resource.AddFile ("materials/vgui/ttt/icon_cube.vtf")
	util.AddNetworkString("ValuePanel")
end

local allowTraitor = CreateConVar( "ttt_gc_allow_traitor", 1 , {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow Traitor to buy this Item?" )

SWEP.HoldType = "normal"

if CLIENT then
   SWEP.PrintName = "Gravity Cube"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Set the gravity around the Cube!\nM1 to throw / M2 to set settings.\n\nGravity Cube needs to be placed first\nbefore set settings."
   };

   SWEP.Icon = "vgui/ttt/icon_cube"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = "models/hunter/blocks/cube025x025x025.mdl"

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
if allowTraitor:GetBool() then
	SWEP.CanBuy = { ROLE_TRAITOR }
end
SWEP.LimitedStock = true -- only buyable once
SWEP.WeaponID = AMMO_CUBE

SWEP.AllowDrop = true

SWEP.NoSights = true

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	 self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay ) 
	 self:CreateCube()
	 self:TakePrimaryAmmo ( 1 ) 
end

function SWEP:DrawWorldModel()
	return false
end

SWEP.ENT = nil


function SWEP:CreateCube()
	if SERVER then
		local ply = self.Owner
		local cube = ents.Create("ttt_cube_proj")
			if IsValid(cube) and IsValid(ply) then
				local vsrc = ply:GetShootPos()
				local vang = ply:GetAimVector()
				local vvel = ply:GetVelocity()
				local vthrow = vvel + vang * 100
				cube:SetPos(vsrc + vang * 10)
				cube:Spawn()
				cube:SetThrower(ply)	
				local phys = cube:GetPhysicsObject()
				
					if IsValid(phys) then
						phys:SetVelocity(vthrow)
						phys:SetMass(200)
					end 
					self.ENT = cube
					cube.Creator_WPN = self:GetClass()
					SetGlobalVar("Entity_" .. self.Owner:SteamID(), self.ENT)
			end
		
	end
end

function SWEP:CreateGUI()
	local Owner = self.Owner
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetSize( 500, 200 ) 
	DermaPanel:Center() 
	DermaPanel:MakePopup() 
	DermaPanel:IsActive()
	DermaPanel:SetTitle("Force Options")
	
	DermaPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 100, 100, 100, 200 ) )
	end

	local DermaNumSlider = vgui.Create( "DNumSlider", DermaPanel )

	DermaNumSlider:SetPos( 50, 50 )			
	DermaNumSlider:SetSize( 300, 100 )		
	DermaNumSlider:SetText( "Force" )	
	DermaNumSlider:SetMin( 0 )				
	DermaNumSlider:SetMax( 500 )				
	DermaNumSlider:SetDecimals( 1 )
	DermaNumSlider:SetValue(ValPanel)
	

	local DLabel2 = vgui.Create( "DLabel", DermaPanel )
	DLabel2:SetPos( 45, 40 )
	DLabel2:SetText( "Note: Cube needs to be placed before set settings!" )
	DLabel2:SetSize(300, 20)
	

	local button = vgui.Create("DButton",DermaPanel)
	button:SetText("Okay")
	button:SetPos( 400, 150 )
		
		function button:DoClick()
			
			ValPanel = DermaNumSlider:GetValue()	
			net.Start("ValuePanel")
				net.WriteFloat(ValPanel)
				net.WriteEntity(GetGlobalVar("Entity_" .. Owner:SteamID()))
			net.SendToServer()
			DermaPanel:Close()
		end
end


function SWEP:SecondaryAttack()

  if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay)
		if not IsFirstTimePredicted() then return end
	
			if CLIENT then
				self:CreateGUI()
			end
end


function SWEP:OnDrop()
	self:Remove()
end