if SERVER then
    -- Variables de masse et de vitesse par défaut
    local defaultMass = 500
    local defaultVelocity = 10000
    local defaultTime = 10

    -- Ajoutez une commande console pour définir la masse et la vitesse du ragdoll
    concommand.Add("ragdollmenu_setvalues", function(ply, _, args)
        local mass = tonumber(args[1]) or defaultMass
        local velocity = tonumber(args[2]) or defaultVelocity
        local time = tonumber(args[3]) or defaultTime

        ply:SetNWInt("RagdollMass", mass)
        ply:SetNWInt("RagdollVelocity", velocity)
        ply:SetNWInt("RagdollTime", time)
    end)
end

if CLIENT then
    -- Variables pour stocker les dernières valeurs attribuées
    local lastMass = 500
    local lastVelocity = 10000
    local lastTime = 10

    -- Fonction pour afficher le menu de configuration de la masse et de la vitesse du ragdoll
    local function OpenRagdollMenu()
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 150)
        frame:SetTitle("Ragdoll Menu")
        frame:SetVisible(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        frame:MakePopup()

        local massLabel = vgui.Create("DLabel", frame)
        massLabel:SetText("Masse:")
        massLabel:SetPos(125, 30)
        massLabel:SizeToContents()

        local massSlider = vgui.Create("DNumSlider", frame)
        massSlider:SetPos(100, 30)
        massSlider:SetSize(300, 20)
        massSlider:SetText("")
        massSlider:SetMin(0)
        massSlider:SetMax(50000)
        massSlider:SetDecimals(0)
        massSlider:SetValue(lastMass)

        local velocityLabel = vgui.Create("DLabel", frame)
        velocityLabel:SetText("Vitesse:")
        velocityLabel:SetPos(125, 60)
        velocityLabel:SizeToContents()

        local velocitySlider = vgui.Create("DNumSlider", frame)
        velocitySlider:SetPos(100, 60)
        velocitySlider:SetSize(300, 20) 
        velocitySlider:SetText("")
        velocitySlider:SetMin(0)
        velocitySlider:SetMax(10000)
        velocitySlider:SetDecimals(0)
        velocitySlider:SetValue(lastVelocity)

        local timeLabel = vgui.Create("DLabel", frame)
        timeLabel:SetText("Délai de disparition du ragdoll:")
        timeLabel:SetPos(100, 90)
        timeLabel:SizeToContents()

        local timeSlider = vgui.Create("DNumSlider", frame)
        timeSlider:SetPos(200, 90)
        timeSlider:SetSize(200, 20) 
        timeSlider:SetText("")
        timeSlider:SetMin(0)
        timeSlider:SetMax(50)
        timeSlider:SetDecimals(0)
        timeSlider:SetValue(lastTime)

        local applyButton = vgui.Create("DButton", frame)
        applyButton:SetText("Appliquer")
        applyButton:SetPos(125, 120)
        applyButton:SetSize(280, 25)

        applyButton.DoClick = function()
            local mass = math.floor(massSlider:GetValue())
            local velocity = math.floor(velocitySlider:GetValue())
            local time = math.floor(timeSlider:GetValue())

            lastMass = mass -- Enregistrez la dernière valeur de masse attribuée
            lastVelocity = velocity -- Enregistrez la dernière valeur de vitesse attribuée
            lastTime = time -- Enregistrez la dernière valeur de délai attribuée

            LocalPlayer():ConCommand("ragdollmenu_setvalues " .. tostring(mass) .. " " .. tostring(velocity) .. " " .. tostring(time))
            frame:Close()
        end
    end
    -- Ajoutez une commande console pour ouvrir le menu de configuration du ragdoll
    concommand.Add("ragdollmenu", OpenRagdollMenu)
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