if SERVER then
    -- Variables de masse et de vitesse par défaut
    local defaultMass = 500
    local defaultVelocity = 10000
    local defaultTime = 10
    local defaultModeOwner = "true"
    local defaultModeBouncing = "true"

    -- Ajoutez une commande console pour définir la masse et la vitesse du ragdoll
    concommand.Add("ragdollmenu_setvalues", function(ply, _, args)
        local mass = tonumber(args[1]) or defaultMass
        local velocity = tonumber(args[2]) or defaultVelocity
        local time = tonumber(args[3]) or defaultTime
        local modeOwner = args[4] or defaultModeOwner
        local modeBouncing = args[5] or defaultModeBouncing

        ply:SetNWInt("RagdollMass", mass)
        ply:SetNWInt("RagdollVelocity", velocity)
        ply:SetNWInt("RagdollTime", time)
        ply:SetNWString("modeOwner", modeOwner)
        ply:SetNWString("modeBouncing", modeBouncing)
    end)

    
end

if CLIENT then
    -- Variables pour stocker les dernières valeurs attribuées
    local lastMass = 500
    local lastVelocity = 10000
    local lastTime = 10
    local lastModeOwner = true
    local lastModeBouncing = true
   
    -- Fonction pour afficher le menu de configuration de la masse et de la vitesse du ragdoll
    local function OpenRagdollMenu()
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 220)
        frame:SetTitle("Menu")
        frame:SetVisible(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:MakePopup()

        local massLabel = vgui.Create("DLabel", frame)
        massLabel:SetText("Mass:")
        massLabel:SetPos(100, 30)
        massLabel:SizeToContents()

        local massSlider = vgui.Create("DNumSlider", frame)
        massSlider:SetPos(100, 25)
        massSlider:SetSize(300, 20)
        massSlider:SetText("")
        massSlider:SetMin(1)
        massSlider:SetMax(5000)
        massSlider:SetDecimals(0)
        massSlider:SetValue(lastMass)

        local velocityLabel = vgui.Create("DLabel", frame)
        velocityLabel:SetText("Speed:")
        velocityLabel:SetPos(100, 60)
        velocityLabel:SizeToContents()

        local velocitySlider = vgui.Create("DNumSlider", frame)
        velocitySlider:SetPos(100, 55)
        velocitySlider:SetSize(300, 20) 
        velocitySlider:SetText("")
        velocitySlider:SetMin(0)
        velocitySlider:SetMax(5000)
        velocitySlider:SetDecimals(0)
        velocitySlider:SetValue(lastVelocity)

        local timeLabel = vgui.Create("DLabel", frame)
        timeLabel:SetText("Disappearance time of the entity:")
        timeLabel:SetPos(100, 90)
        timeLabel:SizeToContents()

        local timeSlider = vgui.Create("DNumSlider", frame)
        timeSlider:SetPos(200, 85)
        timeSlider:SetSize(200, 20) 
        timeSlider:SetText("")
        timeSlider:SetMin(0)
        timeSlider:SetMax(50)
        timeSlider:SetDecimals(0)
        timeSlider:SetValue(lastTime)

        local modeOwnerLabel = vgui.Create("DLabel", frame)
        modeOwnerLabel:SetText("Mode Owner")
        modeOwnerLabel:SetPos(100, 120)
        modeOwnerLabel:SizeToContents()

        local modeOwnerLabelDesc = vgui.Create("DLabel", frame)
        modeOwnerLabelDesc:SetText("(If not activated, the entity can kill you !)")
        modeOwnerLabelDesc:SetPos(100, 130)
        modeOwnerLabelDesc:SizeToContents()

        local modeOwnerChebox = vgui.Create("DCheckBox", frame)
        modeOwnerChebox:SetPos(290, 120)
        modeOwnerChebox:SetSize(10, 10)
        modeOwnerChebox:SetValue(lastModeOwner)

        local bouncingMode = vgui.Create("DLabel", frame)
        bouncingMode:SetText("Bouncing")
        bouncingMode:SetPos(100, 150)
        bouncingMode:SizeToContents()

        local bouncingCheckbox = vgui.Create("DCheckBox", frame)
        bouncingCheckbox:SetPos(290, 153)
        bouncingCheckbox:SetSize(10, 10)
        bouncingCheckbox:SetValue(lastModeBouncing)

        local applyButton = vgui.Create("DButton", frame)
        applyButton:SetText("Apply")
        applyButton:SetPos(100, 180)
        applyButton:SetSize(300, 25)

        applyButton.DoClick = function()
            local mass = math.floor(massSlider:GetValue())
            local velocity = math.floor(velocitySlider:GetValue())
            local time = math.floor(timeSlider:GetValue())
            local modeOwner = modeOwnerChebox:GetChecked()
            local modeBouncing = bouncingCheckbox:GetChecked()

            lastMass = mass -- Enregistrez la dernière valeur de masse attribuée
            lastVelocity = velocity -- Enregistrez la dernière valeur de vitesse attribuée
            lastTime = time -- Enregistrez la dernière valeur de délai attribuée
            lastModeOwner = modeOwner 
            lastModeBouncing = modeBouncing

            LocalPlayer():ConCommand("ragdollmenu_setvalues " .. tostring(mass) .. " " .. tostring(velocity) .. " " .. tostring(time) .. " " .. tostring(modeOwner) .. " " .. tostring(modeBouncing))


            frame:Close()
        end
    end
    -- Ajoutez une commande console pour ouvrir le menu de configuration du ragdoll
    concommand.Add("ragdollmenu", OpenRagdollMenu)

    hook.Add("OnContextMenuOpen", "ragdollMenu", function()
        if LocalPlayer():GetActiveWeapon():GetClass() == "tosbas_gun" then
            OpenRagdollMenu()
            return false
        end
    end)
end

-- Fonction pour obtenir la masse du ragdoll pour le joueur donné
function GetRagdollMass(ply)
    return ply:GetNWInt("RagdollMass", 500)
end

-- Fonction pour obtenir la vitesse du ragdoll pour le joueur donné
function GetRagdollVelocity(ply)
    return ply:GetNWInt("RagdollVelocity", 10000)
end

-- Fonction pour obtenir le délais du ragdoll pour le joueur donné
function GetRagdollTime(ply)
    return ply:GetNWInt("RagdollTime", 10)
end

function GetModeOwner(ply)
    return ply:GetNWInt("modeOwner", true)
end

function GetModeBouncing(ply)
    return ply:GetNWString("modeBouncing", true)
end


hook.Add("EntityTakeDamage", "RagdollDamageDetection", function(target, dmgInfo)
    local attacker = dmgInfo:GetAttacker()

    -- Vérifiez si l'attaquant est un ragdoll et la cible est un joueur
    if IsValid(attacker) and attacker:IsRagdoll() and target:IsPlayer() or target:IsNPC() then
        local ragdollOwner = attacker:GetOwner()

        if IsValid(ragdollOwner) and ragdollOwner:IsPlayer() then
            dmgInfo:SetAttacker(ragdollOwner) -- Définir le joueur tireur comme l'attaquant
        end
    end
end)