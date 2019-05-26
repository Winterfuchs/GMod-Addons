AddCSLuaFile()

ENT.Type = "anim"

AccessorFunc(ENT, "thrower", "Thrower")

function ENT:Initialize()
	self:SetHealth(100)
	self.canexplode = true
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetMaterial("models/wireframe" )
	self:SetColor(Color(220,255,255,255))
end


net.Receive("ValuePanel", function()
	local Var1 = net.ReadFloat()
	local ent = net.ReadEntity()
	ent.Var2 = Var1
end)

function ENT:Think()

	local pos = self:GetPos()
	local sphere = ents.FindInSphere(pos, 150)
	local index = self:EntIndex()
 
	if (self:EntIndex() == index) then
		for k, v in pairs(sphere) do
			v:SetVelocity(Vector(0,0,self.Var2))
		end
	end	
end


function ENT:Draw()
	self:DrawModel()
	render.SetColorMaterial()
	render.DrawSphere( self:GetPos(), 20, 30, 30, Color( 255, 255, 255, 20 ), true)
	
	local pos, material, blue = self:GetPos(), Material( "sprites/light_glow02_add" ), Color(70, 180, 255, 255)
	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
		render.SetMaterial( material ) -- Tell render what material we want, in this case the flash from the gravgun
		render.DrawSprite( pos, 39, 39, blue ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
end

function ENT:Use(ply)
	local weapon = ply:GetWeapon(self.Creator_WPN)
		if ply:HasWeapon(self.Creator_WPN) and (ply == self:GetThrower()) then
			weapon:SetClip1(1)
			self:Remove()
		end
end

function ENT:OnTakeDamage(damage)
	local dmg = self:Health() - damage:GetDamage()
	self:SetHealth(dmg)

		if (self:Health() <= 0) then

		local pos = self:GetPos()

		local effect = EffectData()

		effect:SetStart(pos)
		effect:SetOrigin(pos)
		util.Effect("cball_explode", effect, true, true) 

		self:Remove()
	end
end