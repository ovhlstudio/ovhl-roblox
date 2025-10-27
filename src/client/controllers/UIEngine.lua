-- UIEngine v5 - Simple UI
local UIEngine = {}
UIEngine.__index = UIEngine

function UIEngine:Init()
    self.components = {}
    print("🔧 UIEngine initialized")
    return true
end

function UIEngine:Start()
    print("🎨 UIEngine started")
    return true
end

function UIEngine:CreateComponent(ComponentClass, props)
    local component = setmetatable({}, ComponentClass)
    component.props = props or {}
    component.state = {}
    component._uiEngine = self
    
    if component.Init then
        pcall(component.Init, component)
    end
    
    return component
end

function UIEngine:Mount(component, parent)
    if not component.Render then
        error("Component must have Render method")
    end
    
    local instance = component:Render()
    if not instance then
        error("Render must return Instance")
    end
    
    instance.Parent = parent
    component._instance = instance
    
    if component.DidMount then
        pcall(component.DidMount, component)
    end
    
    return instance
end

function UIEngine:Unmount(component)
    if component.WillUnmount then
        pcall(component.WillUnmount, component)
    end
    
    if component._instance then
        component._instance:Destroy()
    end
end

return UIEngine
