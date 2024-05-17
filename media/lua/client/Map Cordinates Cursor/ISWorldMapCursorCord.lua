require "ISUI/ISPanel"
require "ISToolTip"  -- Ensure the base tooltip class is loaded


ISToolTipCord = ISToolTip:derive("ISToolTipCord")


-- local ISWorldMap_render = ISWorldMap.render;
local ISWorldMap_createChildren = ISWorldMap.createChildren;
local ISWorldMap_onMouseMove = ISWorldMap.onMouseMove;
local ISWorldMap_onRightMouseUp = ISWorldMap.onRightMouseUp
ISWorldMap.showCoordinates = true  
-- local ISWorldMap_instance = nil;


function ISWorldMap:createChildren(...)
    -- Chiama la funzione originale
    ISWorldMap_createChildren(self, ...)

    -- Crea e aggiungi il tooltip come child
        self.tooltip = ISToolTipCord:new()
        self.tooltip:initialise()
        self.tooltip:addToUIManager()
        self.tooltip:setVisible(false)
        self:addChild(self.tooltip)  -- Aggiungi il tooltip come child del pannello della mappa
    
end


function ISWorldMap:updateTooltip(x, y)
    if not self.showCoordinates then
        self.tooltip:setVisible(false)
        return
    end
    if self.symbolsUI:isMouseOver(x, y) then
        self.tooltip:setVisible(false)
        return
    end
    -- if self:isMouseOver() then
    --     self.tooltip:setVisible(false)
    --     return
    -- end

    if self.buttonPanel and self.buttonPanel:isMouseOver() then
        self.tooltip:setVisible(false)
        return
    end

    if self.optionBtn and self.optionBtn:isMouseOver() then
        self.tooltip:setVisible(false)
        return
    end

    local worldX = self.mapAPI:uiToWorldX(x, y)
    local worldY = self.mapAPI:uiToWorldY(x, y)
    if getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
        self.tooltip:updateCoordinates(worldX, worldY)
        self.tooltip:setVisible(true)
        self.tooltip:setX(x + 32)  -- Aggiusta la posizione del tooltip rispetto al cursore
        self.tooltip:setY(y + 10)
    else
        self.tooltip:setVisible(false)
    end
end


function ISWorldMap:onMouseMove(dx, dy, ...)
    -- Chiama la funzione originale
    ISWorldMap_onMouseMove(self, dx, dy, ...)
    
    -- Aggiungi il codice per aggiornare il tooltip
    local x, y = self:getMouseX(), self:getMouseY()
    self:updateTooltip(x, y)
    
    return true
end

-- Nuova funzione onRightMouseUpClient
function ISWorldMap:onRightMouseUpClient(x, y)
    if self.symbolsUI:onRightMouseUpMap(x, y) then
        return true
    end
    local playerNum = 0
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end -- Debug in main menu
    local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())

    -- Aggiungi l'opzione per mostrare/nascondere il tooltip delle coordinate
    local optionText = self.showCoordinates and "Hide Coordinates" or "Show Coordinates"
    local option = context:addOption(optionText, self, function(self) self.showCoordinates = not self.showCoordinates end)
    context:setOptionChecked(option, self.showCoordinates)

    -- Aggiungi l'opzione "Show Cell Grid"
    option = context:addOption("Show Cell Grid", self, function(self) self:setShowCellGrid(not self.showCellGrid) end)
    context:setOptionChecked(option, self.showCellGrid)

    return true
end


function ISWorldMap:onRightMouseUp(x, y, ...)
    if getDebug() or (isClient() and (getAccessLevel() == "admin")) then
        if self.symbolsUI:onRightMouseUpMap(x, y) then
            return true
        end
        local playerNum = 0
        local playerObj = getSpecificPlayer(0)
        if not playerObj then return end -- Debug in main menu

        -- Chiama la funzione originale per creare il context originale
        local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
        ISWorldMap_onRightMouseUp(self, x, y, ...)

        -- Aggiungi l'opzione per mostrare/nascondere il tooltip delle coordinate
        local optionText = self.showCoordinates and "Hide Coordinates" or "Show Coordinates"
        local option = context:addOption(optionText, self, function(self) self.showCoordinates = not self.showCoordinates end)
        context:setOptionChecked(option, self.showCoordinates)
        
    else
        -- Gestisci il comportamento personalizzato per i non-admin
        self:onRightMouseUpClient(x, y)
    end

    return true
end


-- Sovrascrivi la funzione originale
ISWorldMap.onRightMouseUp = ISWorldMap.onRightMouseUp





function ISToolTipCord:new()
    local o = ISToolTip.new(self)
    setmetatable(o, self)
    self.__index = self
    o:noBackground()
    o.name = "Coordinates"
    o.description = ""
    o.borderColor = {r = 0.4, g = 0.4, b = 0.4, a = 1}
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.5}
    o.width = 0
    o.height = 0
    o.anchorLeft = true
    o.anchorRight = false
    o.anchorTop = true
    o.anchorBottom = false
    o.descriptionPanel = ISRichTextPanel:new(0, 0, 0, 0)
    o.descriptionPanel.marginLeft = 0
    o.descriptionPanel.marginRight = 0
    o.descriptionPanel:initialise()
    o.descriptionPanel:instantiate()
    o.descriptionPanel:noBackground()
    o.descriptionPanel.backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
    o.descriptionPanel.borderColor = {r = 1, g = 1, b = 1, a = 0.1}
    o.owner = nil
    o.followMouse = true
    return o
end


function ISToolTipCord:updateCoordinates(worldX, worldY)
    self.description = "X: " .. math.floor(worldX) .. " Y: " .. math.floor(worldY)
end
