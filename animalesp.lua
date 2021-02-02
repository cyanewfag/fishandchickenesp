local localPlayerClient;
local localPclayer;

local enabled = menu.Switch("Neverlose", "Enabled", true, "Turn on Fish and Chicken ESP");
local fishBoxEnabled = menu.SwitchColor("Neverlose", "Fish Box ESP", false, Color.new(1.0, 1.0, 1.0, 1.0), "Turn on Fish Box ESP");
local fishNameEnabled = menu.SwitchColor("Neverlose", "Fish Name ESP", false, Color.new(1.0, 1.0, 1.0, 1.0), "Turn on Fish Name ESP");
local fishFlagEnabled = menu.SwitchColor("Neverlose", "Fish Flag ESP", false, Color.new(1.0, 1.0, 1.0, 1.0), "Turn on Fish Flag ESP");
local chickenBoxEnabled = menu.SwitchColor("Neverlose", "Chicken Box ESP", false, Color.new(1.0, 1.0, 1.0, 1.0), "Turn on Chicken Box ESP");
local chickenNameEnabled = menu.SwitchColor("Neverlose", "Chicken Name ESP", false, Color.new(1.0, 1.0, 1.0, 1.0), "Turn on Chicken Name ESP");
local drawDistance = menu.SliderInt("Neverlose", "Draw Distance", 0, 0, 2000, "0 (Unlimited) - 2,000 Meter Draw Distance")

local function renderEntityBox(entity, name, nameControl, boxControl, sideHUD, flagControl)
    if (entity ~= nil) then
        local origin = entity:GetRenderOrigin();
        local min, max = Vector.new(), Vector.new();
        local renderBounds = entity:GetRenderBounds(min, max);
        local pos1, pos2 = g_Render:ScreenPosition(Vector.new(origin.x + min.x, origin.y + min.y, origin.z + min.z)), g_Render:ScreenPosition(Vector.new(origin.x + max.x, origin.y + max.y, origin.z + max.z));

        if (boxControl ~= nil) then
            if (boxControl:GetBool()) then
                g_Render:Box(Vector2.new(pos1.x, pos1.y), Vector2.new(pos2.x, pos2.y), boxControl:GetColor());
            end
        end

        if (name ~= nil and nameControl ~= nil) then
            if (nameControl:GetBool()) then
                local textSize = g_Render:CalcTextSize(name, 16)
                local w = pos2.x - pos1.x;
                g_Render:Text(name, Vector2.new(pos1.x + (w / 2) - (textSize.x / 2), math.min(pos2.y, pos1.y) - (textSize.y + 5)), nameControl:GetColor(), 16)
            end
        end

        if (sideHUD ~= nil) then
            local color = Color.new(255, 255, 255, 255);
            if (flagControl ~= nil) then if (not flagControl:GetBool()) then return end color = flagControl:GetColor(); end
            local heightUsed = 0;
            for i = 1, #sideHUD do
                local text = tostring(sideHUD[i])
                local textSize = g_Render:CalcTextSize(text, 12)
                g_Render:Text(text, Vector2.new(math.max(pos1.x, pos2.x) + 5, math.min(pos2.y, pos1.y) + heightUsed), color, 12)
                heightUsed = heightUsed + textSize.y + 2;
            end
        end
    end
end

local function isInDistance(entity, lp, distanceControl)
    if (distanceControl ~= nil) then
        if (distanceControl:GetInt() ~= 0) then
            local entityOrigin = entity:GetRenderOrigin();
            local localOrigin = lp:GetRenderOrigin();

            if (entityOrigin:DistTo(localOrigin) <= distanceControl:GetInt()) then return true; else return false; end
        else return true; end
    end

    return false;
end

cheat.RegisterCallback("draw", function()
    if (enabled:GetBool()) then
        localPlayerClient = g_EngineClient:GetLocalPlayer();
        localPlayer = g_EntityList:GetClientEntity(localPlayerClient);
        local lp = localPlayer:GetPlayer();

        if (localPlayer and lp) then
            local fishEnts = cheat.GetEntitiesByName("CFish")
            local chickenEnts = cheat.GetEntitiesByName("CChicken")

            for i = 1, #fishEnts do if (isInDistance(fishEnts[i], localPlayer, drawDistance)) then local lifeState = "Alive"; if (math.floor(fishEnts[i]:GetProp("DT_CFish", "m_lifeState")) == 2) then lifeState = "Dead"; end local table; if (fishFlagEnabled:GetBool()) then table = {math.floor(fishEnts[i]:GetProp("DT_CFish", "m_waterLevel")) .. "m", lifeState, math.floor(fishEnts[i]:GetProp("DT_CFish", "m_angle")) .. "°"}; end renderEntityBox(fishEnts[i], "Fish", fishNameEnabled, fishBoxEnabled, table, fishFlagEnabled); end end
            for i = 1, #chickenEnts do if (isInDistance(chickenEnts[i], localPlayer, drawDistance)) then renderEntityBox(chickenEnts[i], "Chicken", chickenNameEnabled, chickenBoxEnabled); end end
        end
    end
end);
