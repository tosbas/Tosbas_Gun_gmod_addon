SWEP.PrintName = "Tosbas gun"
SWEP.Author = "Tosbas"
SWEP.Category = "Tosbas Gun"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.UseHands = true
SWEP.Primary.ClipSize = 16
SWEP.Primary.DefaultClip = 16
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DefaultRagdollMass = 500 -- Masse du ragdoll par défaut
SWEP.DefaultRagdollVelocity = 10000 -- Vitesse du ragdoll par défaut
SWEP.DefaultRagdollTime = 10 -- Délai de disparation du ragdoll par défaut

function SWEP:Initialize()
    self:SetHoldType("pistol") -- Animation de tenue de l'arme
    self.IsFiring = false -- Ajout d'une variable pour suivre l'état du tir
    
    self:SetRagdollMass(self.DefaultRagdollMass)
    self:SetRagdollVelocity(self.DefaultRagdollVelocity)
    self:SetRagdollTime(self.DefaultRagdollTime)
end

-- Fonction pour obtenir la masse personnalisée du ragdoll pour le joueur donné
local function GetRagdollMass(ply)
    -- Code pour obtenir la valeur personnalisée de la masse du ragdoll pour le joueur
    return ply:GetNWInt("RagdollMass", 500)
end

-- Fonction pour obtenir la vitesse personnalisée du ragdoll pour le joueur donné
local function GetRagdollVelocity(ply)
    -- Code pour obtenir la valeur personnalisée de la vitesse du ragdoll pour le joueur
    return ply:GetNWInt("RagdollVelocity", 10000)
end

-- Fonction pour obtenir le délai personnalisée du ragdoll pour le joueur donné
local function GetRagdollTime(ply)
    -- Code pour obtenir la valeur personnalisée du délai du ragdoll pour le joueur
    return ply:GetNWInt("RagdollTime", 10)
end


function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    
    if self.IsFiring then return end -- Vérification si le tir est déjà en cours

    self.IsFiring = true -- Marquer le tir en cours

    self:ShootEffects() -- Effets visuels du tir, remplacez cette ligne si nécessaire

    if SERVER then
        local ply = self:GetOwner()
        local shootPos = ply:GetShootPos()
        local shootDir = ply:GetAimVector()

        local ragdoll = ents.Create("prop_ragdoll")
        if not IsValid(ragdoll) then return end

        ragdoll:SetModel("models/Humans/Group01/male_01.mdl")
        ragdoll:SetPos(shootPos + shootDir)
        ragdoll:SetAngles(shootDir:Angle())
        ragdoll:Spawn()

        ragdoll:SetOwner(ply)

        local ragdollPhys = ragdoll:GetPhysicsObject()
        if IsValid(ragdollPhys) then
            local mass = GetRagdollMass(ply) -- Obtenir la masse personnalisée pour le joueur
            local velocity = GetRagdollVelocity(ply) -- Obtenir la vitesse personnalisée pour le joueur
            
            ragdollPhys:SetMass(mass)
            ragdollPhys:SetVelocity(velocity * shootDir)
            ragdollPhys:SetMaterial("gmod_bouncy")
            
            timer.Simple(GetRagdollTime(ply), function()
                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end
            end)
        end
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:Think()
    if not self.IsFiring then return end

    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:KeyDown(IN_ATTACK) then
        self.IsFiring = false -- Réinitialiser l'état du tir si le joueur arrête de tirer
    end
end

function SWEP:SetRagdollMass(mass)
    self.RagdollMass = mass
end

function SWEP:GetRagdollMass()
    return self.RagdollMass or self.DefaultRagdollMass
end

function SWEP:SetRagdollVelocity(velocity)
    self.RagdollVelocity = velocity
end

function SWEP:GetRagdollVelocity()
    return self.RagdollVelocity or self.DefaultRagdollVelocity
end

function SWEP:SetRagdollTime(time)
    self.RagdollTime = time
end

function SWEP:GetRagdollTime()
    return self.RagdollTime or self.DefaultRagdollTime
end


