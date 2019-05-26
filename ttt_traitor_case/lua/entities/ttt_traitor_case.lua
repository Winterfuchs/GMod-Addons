AddCSLuaFile()

ENT.Type = "anim"

ENT.NextUse = 0
function ENT:Initialize()
	self:SetModel("models/props_c17/suitcase_passenger_physics.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	if SERVER then
		self.Entity:NextThink(CurTime() + 1.5)
	end	
end


function ENT:Draw() 
	if IsValid(self) then
		self:DrawModel()
		local pos = self:GetPos() + Vector(0, 0, 20)
		local ang = Angle(0, LocalPlayer():GetAngles().y - 90, 90)
		surface.SetFont("Default")
		local width = surface.GetTextSize("What could be in here?") + 120
	
		cam.Start3D2D(pos, ang, 0.3)
	
		draw.RoundedBox( 5, -width / 2 , -5, width, 15, Color(10, 90, 140, 100) )
		draw.SimpleText("Press [E] to receive your Item!", "ChatFont", 0, -5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end
	


function ENT:Use(ply)

	if (self.NextUse < CurTime()) then
		local t_weapons = {}
		local value = 0

		for _, v in pairs( weapons.GetList() ) do
  
			if table.HasValue( v.CanBuy, ROLE_TRAITOR ) then
				table.insert( t_weapons, v.ClassName )
				value = value + 1
			end
		end
		weapon = math.random(1,value)

		if not IsFirstTimePredicted() then return end
		self.NextUse = CurTime() + 2

		local effect = EffectData()
		effect:SetOrigin(self:GetPos() + Vector(0,0, 10))
		effect:SetStart(self:GetPos() + Vector(0,0, 10))
		
		util.Effect("cball_explode", effect, true, true )


		self:SpawnWeapon(t_weapons[weapon])
		sound.Play( "ambient/levels/labs/electric_explosion3.wav", self:GetPos())

		self:Remove()
	end
end

function ENT:SpawnWeapon(wp)
	if SERVER then
		local ply = self.Owner
		local suitcase = ents.Create(wp)
			suitcase:SetPos(self:GetPos())
			suitcase:Spawn()
				
			local phys = suitcase:GetPhysicsObject()
				
			if IsValid(phys) then
				phys:SetMass(200)
			end 
			self.ENT = suitcase	
	end
		
end