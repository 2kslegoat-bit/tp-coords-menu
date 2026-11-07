--[[
    ============================================================================
    Lapsus NUI - Module de Téléportation (TP)
    Conforme à l'API Lapsus (lapsus-api.json)
    ============================================================================
--]]

-- Nom de la surface NUI
local NUI_WINDOW_NAME = "fodo_tp"

-- Fonction de téléportation via injection de ressource Lapsus
local function TeleportPlayer(rawX, rawY, rawZ)
    local x = tonumber(rawX)
    local y = tonumber(rawY)
    local z = tonumber(rawZ)

    -- Validation stricte des coordonnées
    if not x or not y or not z then
        local errMsg = string.format("[Lapsus TP] Erreur: Coordonnées invalides (X=%s, Y=%s, Z=%s)", tostring(rawX), tostring(rawY), tostring(rawZ))
        Lapsus.print(errMsg)
        return false, errMsg
    end

    -- Construction dynamique du code Lua avec les coordonnées saisies
    local injectedCode = string.format([[
    local x, y, z = %f, %f, %f

    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z, false, false, false, false)

    Lapsus.print("TP effectué :", x, y, z)
]], x, y, z)

    -- nil = Lapsus sélectionne automatiquement une ressource Lua disponible
    local ok, err = Lapsus.InjectResource(nil, injectedCode)

    -- Gestion des erreurs retournées par Lapsus.InjectResource
    if not ok then
        Lapsus.print("[Lapsus TP] Erreur lors de l'injection :", err)
        return false, err
    end

    Lapsus.print(string.format("[Lapsus TP] TP réussi vers X: %.2f, Y: %.2f, Z: %.2f", x, y, z))
    return true, nil
end

-- ============================================================================
-- Callbacks NUI (Communication JavaScript -> Lua)
-- ============================================================================

-- Callback principal déclenché lors de la validation du formulaire TP
RegisterNUICallback("tp", function(data, cb)
    if not data or not data.x or not data.y or not data.z then
        Lapsus.print("[Lapsus TP] Erreur: Données de coordonnées manquantes.")
        if cb then cb({ ok = false, error = "Coordonnées manquantes" }) end
        return
    end

    local success, err = TeleportPlayer(data.x, data.y, data.z)
    if cb then
        cb({ ok = success, error = err })
    end
end)

-- Callback alternatif "teleport" pour assurer la compatibilité
RegisterNUICallback("teleport", function(data, cb)
    if not data or not data.x or not data.y or not data.z then
        if cb then cb({ ok = false, error = "Coordonnées manquantes" }) end
        return
    end

    local success, err = TeleportPlayer(data.x, data.y, data.z)
    if cb then
        cb({ ok = success, error = err })
    end
end)

-- Callback de fermeture du NUI
RegisterNUICallback("close", function(data, cb)
    Lapsus.SetNuiFocus(NUI_WINDOW_NAME, false)
    if cb then cb({ ok = true }) end
end)

-- ============================================================================
-- Fonctions de contrôle de l'interface NUI via Lapsus API
-- ============================================================================

-- Afficher l'interface NUI
function OpenNui()
    Lapsus.SetNuiFocus(NUI_WINDOW_NAME, true)
    Lapsus.SendNuiMessage(NUI_WINDOW_NAME, json.encode({
        action = "showUI",
        visible = true,
        elements = {
            { type = "button", label = "TP" }
        }
    }))
end

-- Masquer l'interface NUI
function CloseNui()
    Lapsus.SetNuiFocus(NUI_WINDOW_NAME, false)
    Lapsus.SendNuiMessage(NUI_WINDOW_NAME, json.encode({
        action = "showUI",
        visible = false
    }))
end

-- Basculer la visibilité du NUI
function ToggleNui()
    Lapsus.ToggleLocalNui(NUI_WINDOW_NAME)
end

-- Exportation de la fonction de TP pour utilisation externe si besoin
return {
    TeleportPlayer = TeleportPlayer,
    OpenNui = OpenNui,
    CloseNui = CloseNui,
    ToggleNui = ToggleNui
}
