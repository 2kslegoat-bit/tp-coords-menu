--[[
    ============================================================================
    NEBULA TP - LOADER LAPSUS (GitHub / Local)
    Conforme aux spécifications Lapsus API (lapsus-api.json)
    ============================================================================
--]]

-- Configuration du Loader
local CONFIG = {
    -- Nom de la surface NUI
    nuiName = "nebula_tp",

    -- URL de votre message.html :
    -- Option A : URL GitHub Pages (recommandé pour le web) : "https://<pseudo>.github.io/<repo>/message.html"
    -- Option B : URL Raw GitHub : "https://raw.githubusercontent.com/<pseudo>/<repo>/main/message.html"
    -- Option C : En local via ressource FiveM : "nui://nebula-tp/message.html"
    nuiUrl = "https://raw.githubusercontent.com/2kslegoat-bit/tp-coords-menu/main/message.html",

    -- Touche du clavier pour ouvrir / fermer le menu (ex: "F5", "INSERT", "F11")
    toggleKey = "F5",
}

local isMenuOpen = false

-- 1. Initialisation de la surface NUI avec Lapsus API
Lapsus.print("[Nebula TP] Initialisation du NUI...")
local nuiAccepted = Lapsus.CreateNui(CONFIG.nuiName, CONFIG.nuiUrl)

if nuiAccepted then
    Lapsus.print("[Nebula TP] NUI créé avec succès sur :", CONFIG.nuiUrl)
else
    Lapsus.print("[Nebula TP] Avertissement : Impossible d'initialiser le NUI.")
end

-- 2. Fonction de téléportation universelle via Lapsus.InjectResource
local function ExecuteTeleport(rawX, rawY, rawZ)
    local x = tonumber(rawX)
    local y = tonumber(rawY)
    local z = tonumber(rawZ)

    if not x or not y or not z then
        Lapsus.print(string.format("[Nebula TP] Erreur : Coordonnées invalides reçues (X=%s, Y=%s, Z=%s)", tostring(rawX), tostring(rawY), tostring(rawZ)))
        return false
    end

    -- Code Lua dynamique injecté dans une ressource client disponible
    local code = string.format([[
        local x, y, z = %f, %f, %f

        local ped = PlayerPedId()
        SetEntityCoords(ped, x, y, z, false, false, false, false)

        Lapsus.print("TP effectué :", x, y, z)
    ]], x, y, z)

    -- nil = sélection automatique d'une ressource Lua disponible par Lapsus
    local ok, err = Lapsus.InjectResource(nil, code)
    if not ok then
        Lapsus.print("[Nebula TP] Erreur d'injection :", err)
        return false
    end

    Lapsus.print(string.format("[Nebula TP] Téléportation réussie vers X: %.2f, Y: %.2f, Z: %.2f", x, y, z))
    return true
end

-- 3. Enregistrement des callbacks NUI (FiveM / CEF)
if type(RegisterNUICallback) == "function" then
    RegisterNUICallback("tp", function(data, cb)
        if data and data.x and data.y and data.z then
            local ok = ExecuteTeleport(data.x, data.y, data.z)
            if cb then cb({ ok = ok }) end
        else
            if cb then cb({ ok = false }) end
        end
    end)

    RegisterNUICallback("teleport", function(data, cb)
        if data and data.x and data.y and data.z then
            local ok = ExecuteTeleport(data.x, data.y, data.z)
            if cb then cb({ ok = ok }) end
        else
            if cb then cb({ ok = false }) end
        end
    end)

    RegisterNUICallback("close", function(data, cb)
        isMenuOpen = false
        Lapsus.SetNuiFocus(CONFIG.nuiName, false)
        if cb then cb({ ok = true }) end
    end)
end

-- 4. Fonctions d'ouverture / fermeture du NUI
local function ToggleMenu()
    isMenuOpen = not isMenuOpen
    Lapsus.SetNuiFocus(CONFIG.nuiName, isMenuOpen)
    Lapsus.SendNuiMessage(CONFIG.nuiName, json.encode({
        action = "showUI",
        visible = isMenuOpen
    }))
    Lapsus.print(string.format("[Nebula TP] Menu %s (Focus: %s)", isMenuOpen and "OUVERT" or "FERMÉ", tostring(isMenuOpen)))
end

-- 5. Thread d'écoute de la touche clavier (boucle tick avec Lapsus.Wait)
Lapsus.CreateThread(function()
    Lapsus.print(string.format("[Nebula TP] Loader actif ! Appuyez sur [%s] pour ouvrir/fermer.", CONFIG.toggleKey))
    while true do
        Lapsus.Wait(0)
        if Lapsus.IsKeyPressed(CONFIG.toggleKey) then
            ToggleMenu()
            Lapsus.Wait(300) -- Délai anti-rebond
        end
    end
end)
