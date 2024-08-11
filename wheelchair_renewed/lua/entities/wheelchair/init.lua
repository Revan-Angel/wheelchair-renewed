include('shared.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

function ENT:Initialize()
    self:SetModel('models/props_unique/wheelchair01.mdl')
    self:SetUseType(SIMPLE_USE)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:StartMotionController()
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(500)  -- Réduit la masse pour diminuer l'impact
        phys:SetDragCoefficient(150)  -- Ajuste le coefficient de traînée pour réduire le patinage
    end
    self.ply = nil
    self.isMoving = false 
    self.rotationSpeed = 30  -- Réduit la vitesse de rotation
    self.forwardSpeed = 200  -- Réduit la vitesse de déplacement
end

function ENT:Use(ply)
    if self.cooldown and self.cooldown > CurTime() then
        return
    end

    self.cooldown = CurTime() + 1

    if IsValid(self.ply) then
        return
    end

    local ang = self:GetAngles()
    ang:RotateAroundAxis(self:GetUp(), -90)

    ply:Sit(self:GetPos() - self:GetUp(), ang, self, nil, nil, function()
        self.ply = nil
    end)

    self.ply = ply
end

function ENT:Think()
    self:PhysWake()
    self:NextThink(CurTime() + 2)

    local ang = self:GetAngles()
    local toAng = Angle(0, ang.y, ang.z / 50)
    self:SetAngles(LerpAngle(0.675, ang, toAng))

    if IsValid(self.ply) and self.ply:KeyDown(IN_FORWARD) then
        self.isMoving = true
    else
        self.isMoving = false
    end

    return true
end

function ENT:PhysicsUpdate(phys)
    if not IsValid(self.ply) then
        return
    end
    local fwd = self:GetForward()
    local up = self:GetUp()

    fwd.z = 0

    if not self.ply:KeyDown(IN_MOVELEFT) and not self.ply:KeyDown(IN_MOVERIGHT) and self.ply:KeyDown(IN_FORWARD) and (not self.fwd_cool or self.fwd_cool < CurTime()) then
        phys:SetVelocityInstantaneous(fwd * self.forwardSpeed)
        self:EmitSound('buttons/lever1.wav', 50, 85)
        self.fwd_cool = CurTime() + 1
    end


    if not self.isMoving then
        if phys:GetAngleVelocity():WithinAABox(Vector(-100, -100, -100), Vector(100, 100, 100)) then
            local speed = self.rotationSpeed
            if self.ply:KeyDown(IN_MOVELEFT) then
                phys:AddAngleVelocity(up * -speed)
            end

            if self.ply:KeyDown(IN_MOVERIGHT) then
                phys:AddAngleVelocity(up * speed)
            end
        end
    end
end

hook.Add('EntityTakeDamage', 'WheelchairNoDamage', function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:GetClass() == 'wheelchair' then
        if attacker:GetPos():Distance(target:GetPos()) < 100 then
            dmginfo:SetDamage(0)
        end
    end
end)


hook.Add('OnEntityHit', 'WheelchairCollisionNoDamage', function(ent, hitpos, hitnormal, entity)
    if IsValid(entity) and entity:GetClass() == 'wheelchair' then
        if ent:IsPlayer() or ent:IsNPC() then
            ent:SetHealth(math.min(ent:Health(), ent:Health() + 1))
        end
    end
end)

hook.Add('OnPlayerSit', 'wheelchair', function(ply, pos, ang, parent)
    if IsValid(parent) and parent:GetClass() == 'wheelchair' and IsValid(parent.ply) then return false end
end)

hook.Add('EntityEmitSound', 'wheelchair', function(data)
    if not IsValid(data.Entity) then
        return
    end

    if data.Entity:GetClass() == 'wheelchair' and data.OriginalSoundName ~= 'buttons/lever1.wav' then
        return false
    end
end)
