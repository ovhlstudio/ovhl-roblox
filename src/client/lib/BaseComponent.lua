-- BaseComponent v5 - Simple Base
local BaseComponent = {}
BaseComponent.__index = BaseComponent

function BaseComponent:Init()
    self.state = self.state or {}
end

function BaseComponent:SetState(newState)
    if type(newState) == "function" then
        newState = newState(self.state)
    end
    
    self.state = newState
    
    if self._instance and self._uiEngine then
        self._uiEngine:Unmount(self)
        self._uiEngine:Mount(self, self._instance.Parent)
    end
end

return BaseComponent
