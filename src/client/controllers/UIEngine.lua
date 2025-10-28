-- UIEngine v1.1.0 - Component Support
local UIEngine = {}
UIEngine.__index = UIEngine

UIEngine.__manifest = {
    name = "UIEngine",
    version = "1.1.0",
    type = "controller",
    domain = "ui"
}

function UIEngine:Init()
    self._components = {}
    print("✅ UIEngine Initialized")
    return true
end

function UIEngine:Start()
    print("🎨 UIEngine Started")
    return true
end

function UIEngine:CreateComponent(ComponentClass, props)
    local component = setmetatable({}, ComponentClass)
    component.props = props or {}
    
    if component.Init then
        component:Init()
    end
    
    return component
end

function UIEngine:Mount(component, parent)
    if not component.Render then
        error("Component must have Render method")
    end
    
    local instance = component:Render()
    if not instance then
        error("Render must return an Instance")
    end
    
    instance.Parent = parent
    
    if component.DidMount then
        component:DidMount()
    end
    
    return instance
end

function UIEngine:Unmount(component)
    if component.WillUnmount then
        component:WillUnmount()
    end
    
    -- Note: Parent cleanup should be handled by the caller
    return true
end

return UIEngine
