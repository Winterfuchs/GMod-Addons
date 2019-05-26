AddCSLuaFile()

if SERVER then
resource.AddWorkshop( "596033434" )
end

resource.AddFile("models/props/xmas_present/c_xmas_present.mdl")
resource.AddFile("materials/models/props/xmas_present/c_xmas_blue.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_blue.vtf")
resource.AddFile("materials/models/props/xmas_present/c_xmas_green.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_green.vtf")
resource.AddFile("materials/models/props/xmas_present/c_xmas_yellow.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_yellow.vtf")
resource.AddFile("materials/models/props/xmas_present/c_xmas_red.vmt")
resource.AddFile("materials/models/props/xmas_present/c_xmas_red.vtf")



ENT.Type = "anim"

ENT.NextUse = 0

ENT.Counter = 0

function ENT:Initialize()

	self:SetModel("models/props/xmas_present/c_xmas_present.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetSkin(math.random(0,3))

  	local phys = self:GetPhysicsObject()
    if IsValid(phys) then
       	phys:SetMass(50)
    end
	  
	var = self
	  
end

if CLIENT then
	
	function ENT:Draw()
	
		if IsValid(self) then
			self:DrawModel()
			local pos = self:GetPos() + Vector(0, 0, 20)
			local ang = Angle(0, LocalPlayer():GetAngles().y - 90, 90)
			surface.SetFont("Default")
			local width = surface.GetTextSize("What could be in here?") + 55
	
			cam.Start3D2D(pos, ang, 0.3)
	
			draw.RoundedBox( 5, -width / 2 , -30, width, 15, Color(10, 90, 140, 100) )
			draw.SimpleText("What could be in here?", "ChatFont", 0, -30, Color(255,255,255,255), TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end
end

function ENT:Use(activator)

	luck = math.random(1,4)
	
	if (self.NextUse < CurTime()) then
		if (luck > 1)then
			if (self.NextUse == 0) then
	
				activator:SetHealth(activator:Health() + 50)
				self.Counter = self.Counter + 1
	
				self:EmitSound("buttons/button9.wav",75, 150)
	
			if (activator:Health() >= 100) then
				activator:SetHealth(100)
			else end
	
			self.NextUse = CurTime() + 2
	
	
		elseif (self.NextUse > 0) then
	
			if (self.NextUse < CurTime()) then
	
				self:EmitSound("buttons/button9.wav",75, 150)
	
				activator:SetHealth(activator:Health() + 50)
				self.Counter = self.Counter + 1
	
				if (activator:Health() >= 100) then
					activator:SetHealth(100)
				else end
	
				self.NextUse = CurTime() + 2
				if (self.Counter == 2) then
	
					local effect = EffectData()
					effect:SetOrigin(self:GetPos() + Vector(0,0, 10))
					effect:SetStart(self:GetPos() + Vector(0,0, 10))
		
					util.Effect("cball_explode", effect, true, true )
					self:Remove() end
				else return end
			else return end
		
		elseif (luck == 1) then
			if SERVER then
				util.BlastDamage(self, self, self:GetPos(), 150, 200)
				local effect = EffectData()
				effect:SetOrigin(self:GetPos() + Vector(0,0, 10))
				effect:SetStart(self:GetPos() + Vector(0,0, 10))
		
				util.Effect("Explosion", effect, true, true )
				self:Remove()
			end
		end
	end
end