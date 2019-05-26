AddCSLuaFile()

ENT.Type = "anim"

AccessorFunc(ENT, "thrower", "Thrower")

ENT.NextUse = 0
ENT.AirTime = 0
ENT.RoundEnded = false
ENT.PlayersInSphere = {}
ENT.RandomPlayer = {}
ENT.DamageCooldown = CurTime() + 1.5
ENT.RemoveTimer = CurTime() + 1.5
ENT.NextUse = 0
ENT.Timer = CurTime()
ENT.TimeLeft = 100

function ENT:Initialize()
	self:SetModel( "models/maxofs2d/hover_basic.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetHealth(200)
	self:NextThink( CurTime() + 5 )
	self:SetMaterial("models/effects/comball_tape" )
	self:SetColor(Color(220,0,255,255))
	
	if SERVER then
		util.SpriteTrail(self, 0, Color(255,0,0), false, 25, 1, 4, 1/(15+1)*0.5, "trails/laser.vmt")
	end
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity( true ) -- This is required. Since we are creating our own gravity.	
	end
end

function ENT:Think() 
	self:SearchPlayer()
	self:NextThink( CurTime() + 2 )
	return true;
end

function ENT:SearchPlayer()
	if SERVER then
		local expos = self:GetPos();
		local sphere = ents.FindInSphere(expos, 500)
		
		local throwerRole = self:GetThrower():GetRole()
		
		local role_jackal = ROLE_JACKAL
		local role_sidekick = ROLE_SIDEKICK
		local role_dealer = ROLE_DEALER
		
		if ROLES then
			role_jackal = ROLES.JACKAL.index
			role_sidekick = ROLES.SIDEKICK.index
			role_dealer = ROLES.DEALER.index
		end
					
		for key, v in pairs(sphere) do
				if v:IsPlayer() && v:GetRole() != throwerRole and v:Alive() then
					if throwerRole == role_jackal && v:GetRole() == role_sidekick || throwerRole == role_sidekick && v:GetRole() == role_jackal then return end
					if throwerRole == ROLE_TRAITOR && v:GetRole() == role_dealer || throwerRole == role_dealer && v:GetRole() == ROLE_TRAITOR then return end
					table.insert(self.PlayersInSphere, v)
				end
		end
		
		TableCount = table.Count(self.PlayersInSphere)	
		self.RandomPlayer = self.PlayersInSphere[math.random(1, TableCount)]	

		if (self.RandomPlayer != nil) then
		
			local tracedata = {};
				tracedata.start = self.RandomPlayer:GetShootPos();
				tracedata.endpos = self:GetPos() + Vector(0, 0, 20);
				tracedata.filter = self.RandomPlayer;
				local tr = util.TraceLine(tracedata)
				if tr.HitPos == tracedata.endpos then				
					local phys = self:GetPhysicsObject()
					phys:SetVelocity(Vector(0,0,0))
					phys:ApplyForceCenter((self:GetPos() - self.RandomPlayer:GetShootPos())*-1220.80665 )
				end
		end
		
		table.Empty(self.PlayersInSphere)
	

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

function ENT:Draw() 
	if IsValid(self) then
	self:DrawModel()
	local pos = self:GetPos() + Vector(0, 0, 20)
	local ang = Angle(0, LocalPlayer():GetAngles().y - 90, 90)
	surface.SetFont("Default")
	local width = 200 / 1.5
	
	cam.Start3D2D(pos, ang, 0.3)
	
	draw.RoundedBox( 5, -width / 2, -5, 200 / 1.5, 15, Color(255, 0, 0, 20) )
	draw.RoundedBox( 5, -width / 2 , -5, self:Health() / 1.5, 15, Color(0, 255, 0, 120) )
	draw.SimpleText("Spirit", "ChatFont", 0, -5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
	cam.End3D2D()
	local pos, material, blue = self:GetPos(), Material( "sprites/light_glow02_add" ), Color(70, 180, 255, 255)
	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
		render.SetMaterial( material ) -- Tell render what material we want, in this case the flash from the gravgun
		render.DrawSprite( pos, 39, 39, blue )
	cam.End3D()
end
end

function SpiritHit( ent, attacker )
	if (attacker:GetDamageType() == DMG_CRUSH) then
		if IsValid(attacker:GetInflictor()) then
			if !attacker:GetAttacker():IsWorld() then
				if attacker:GetInflictor():GetClass() == "ttt_spirit_proj" then
					attacker:ScaleDamage( 0.27 )
				end
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "SpiritHit", SpiritHit )