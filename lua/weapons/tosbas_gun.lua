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
SWEP.Primary.Ammo = ""
SWEP.Primary.Delay = 0.5

SWEP.Secondary.ClipSize = 16
SWEP.Secondary.DefaultClip = 16
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.DefaultRagdollMass = 500 -- Masse du ragdoll par défaut
SWEP.DefaultRagdollVelocity = 10000 -- Vitesse du ragdoll par défaut
SWEP.DefaultRagdollTime = 10 -- Délai de disparation du ragdoll par défaut
SWEP.DefaultModeOwner = true
SWEP.DefaultModeBouncing = true

function SWEP:Initialize()
    self:SetHoldType("pistol") -- Animation de tenue de l'arme
    self.IsFiring = false -- Ajout d'une variable pour suivre l'état du tir
    
    self:SetRagdollMass(self.DefaultRagdollMass)
    self:SetRagdollVelocity(self.DefaultRagdollVelocity)
    self:SetRagdollTime(self.DefaultRagdollTime)
    self:SetModeOwner(self.DefaultModeOwner)
    self:SetModeBoucing(self.DefaultModeBouncing)
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


local function GetModeOwner(ply)

    return ply:GetNWString("modeOwner", "true")
end

local function GetModeBouncing(ply)

    return ply:GetNWString("modeBouncing", "true")
end


function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    self:ShootEffects() -- Effets visuels du tir, remplacez cette ligne si nécessaire

    if SERVER then
        local ply = self:GetOwner()
        local shootPos = ply:GetShootPos()
        local shootDir = ply:GetAimVector()

        local targetModel = self.TargetModel or "models/Humans/Group01/male_01.mdl"
        local entClass = self.TargetClass or "prop_ragdoll" -- Classe par défaut

        if IsValid(self.TargetEntity) and not self.TargetEntity:IsNPC() then
            -- Utiliser la classe de l'entité visée si ce n'est pas un NPC
            entClass = self.TargetEntity:GetClass()
           
        end

       

        local ent = ents.Create(entClass)
        if not IsValid(ent) then return end

        ent:SetModel(targetModel)
        ent:SetPos(shootPos + shootDir * 150)
        ent:SetAngles(shootDir:Angle())
        ent:Spawn()

        if tobool(GetModeOwner(ply)) then
            ent:SetOwner(ply)
        end

       

        local entPhys = ent:GetPhysicsObject() 
  
        if IsValid(entPhys) then
            local mass = GetRagdollMass(ply) -- Obtenir la masse personnalisée pour le joueur
            local velocity = GetRagdollVelocity(ply) -- Obtenir la vitesse personnalisée pour le joueur
            entPhys:SetMass(mass)
            entPhys:SetVelocity(velocity * shootDir)

            if tobool(GetModeBouncing(ply)) then
                entPhys:SetMaterial("gmod_bouncy")
            end

            timer.Simple(GetRagdollTime(ply), function()
                if IsValid(ent) then
                    ent:Remove()
                end
            end)
        end
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    if not self:CanSecondaryAttack() then return end

    local excludedEntities = {
        ["worldspawn"] = true,
        ["prop_vehicle_jeep"] = true
    }
    
    local ply = self:GetOwner()
    local trace = ply:GetEyeTrace()
    local entity = trace.Entity

    -- Vérifier si l'entité visée est valide et n'est pas la classe "worldspawn"
    if IsValid(entity) and not excludedEntities[entity:GetClass()] then
        local targetModel = entity:GetModel()
        local entClass = entity:GetClass()

   
        -- Vérifier si le modèle est valide pour l'entité visée
        if util.IsValidModel(targetModel) then
            -- Stocker le modèle dans une variable accessible par SWEP:PrimaryAttack()
            self.TargetModel = targetModel
            self.TargetClass = entClass

            print("Entity selected :", entClass)
        end
    else
        print("The entity cannot be copied.")
    end

    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
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

function SWEP:SetModeOwner(modeOwner)
    self.ModeOwner = modeOwner
end

function SWEP:GetRagdollTime()
    return self.RagdollTime or self.DefaultRagdollTime
end

function SWEP:GetModeOwner()
    return self.ModeOwner or self.DefaultModeOwner
end

function SWEP:SetModeBoucing(modeBouncing)
    self.modeBouncing = modeBouncing
end

function SWEP:GetModeBouncing()
    return self.ModeBouncing or self.DefaultModeBouncing
end


