require "ISUI/ISPanel"
require "ISToolTip"  -- Ensure the base tooltip class is loaded


ISToolTipCord = ISToolTip:derive("ISToolTipCord")


local ISWorldMap_render = ISWorldMap.render;
local ISWorldMap_instance = nil;




function ISWorldMap:render(...)
    ISWorldMap_instance = self;
    ISWorldMap_render(self, ...); 


    if not self.tooltip then
        self.tooltip = ISToolTipCord:new()
        self.tooltip:initialise()
        self.tooltip:addToUIManager()
        self.tooltip:setVisible(false)  -- Nasconde il tooltip inizialmente
    end

end


function ISWorldMap:updateTooltip(x, y)
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


function ISWorldMap:onMouseMove(dx, dy)
    if self.symbolsUI:onMouseMoveMap(dx, dy) then
        return true
    end
    if self.dragging then
        local mouseX = self:getMouseX()
        local mouseY = self:getMouseY()
        if not self.dragMoved and math.abs(mouseX - self.dragStartX) <= 4 and math.abs(mouseY - self.dragStartY) <= 4 then
            return
        end
        self.dragMoved = true
        local worldX = self.mapAPI:uiToWorldX(mouseX, mouseY, self.dragStartZoomF, self.dragStartCX, self.dragStartCY)
        local worldY = self.mapAPI:uiToWorldY(mouseX, mouseY, self.dragStartZoomF, self.dragStartCX, self.dragStartCY)
        self.mapAPI:centerOn(self.dragStartCX + self.dragStartWorldX - worldX, self.dragStartCY + self.dragStartWorldY - worldY)
    end

    -- Aggiungi il codice per aggiornare il tooltip
    local x, y = getMouseX(), getMouseY()
    self:updateTooltip(x, y)
    
    return true
end



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
