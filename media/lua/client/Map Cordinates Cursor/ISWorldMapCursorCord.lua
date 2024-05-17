require "ISUI/ISPanel"
require "ISToolTip"  -- Ensure the base tooltip class is loaded


ISToolTipCord = ISToolTip:derive("ISToolTipCord")


local ISWorldMap_render = ISWorldMap.render;
local ISWorldMap_createChildren = ISWorldMap.createChildren;
local ISWorldMap_onMouseMove = ISWorldMap.onMouseMove;
ISWorldMap.showCoordinates = true  
local ISWorldMap_instance = nil;


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

-- function ISWorldMap:render(...)
--     -- ISWorldMap_instance = self;
--     ISWorldMap_render(self, ...); 

--     self.tooltip = ISToolTipCord:new()
--     self.tooltip:initialise()
--     self.tooltip:setVisible(false)  -- Nasconde il tooltip inizialmente

--     self.tooltip:addToUIManager()


-- end


function ISWorldMap:updateTooltip(x, y)
    if not self.showCoordinates then
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

function ISWorldMap:onRightMouseUpClient(x, y)
	if self.symbolsUI:onRightMouseUpMap(x, y) then
		return true
	end
	local playerNum = 0
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end -- Debug in main menu
	local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())

	local option = context:addOption("Show Cell Grid", self, function(self) self:setShowCellGrid(not self.showCellGrid) end)
	context:setOptionChecked(option, self.showCellGrid)

    option = context:addOption("Show Coordinates", self, function(self) self.showCoordinates = not self.showCoordinates end)
    context:setOptionChecked(option, self.showCoordinates)

    return true
end

function ISWorldMap:onRightMouseUp(x, y, ...)
    -- Se il giocatore non è admin, chiama la nuova funzione per i client
    if not (getDebug() or (isClient() and (getAccessLevel() == "admin"))) then
        return self:onRightMouseUpClient(x, y)
    end
    
    -- Altrimenti, chiama la funzione originale per gli admin
    return ISWorldMap_onRightMouseUp(self, x, y, ...)
end

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
