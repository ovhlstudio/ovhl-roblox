# 🧠 OVHL CORE - AI CONTEXT & TRAINING GUIDE (v1.1)

## 📋 DOCUMENT INFORMATION

| Property             | Value                                                             |
| -------------------- | ----------------------------------------------------------------- |
| **Document ID**      | `AI-001`                                                          |
| **Document Version** | `1.1.0`                                                           |
| **Status**           | `Active (Revised)`                                                |
| **Location Path**    | `./docs/00_AI_CONTEXT/OVHL_AI_CONTEXT.md`                         |
| **Repository**       | `https://github.com/ovhlstudio/ovhl-roblox`                       |
| **License**          | `MIT`                                                             |
| **Relations**        | `ARCHITECTURE.md`, `API_REFERENCE.md`, `DEVELOPMENT_STANDARDS.md` |
| **Author**           | `OVHL Core Team`                                                  |
| **Last Updated**     | `2025-10-28`                                                      |

---

## 🎯 1. DOCUMENT PURPOSE

This document is the **primary source of context** for AI Assistants (e.g., Gemini, Claude) working on the OVHL Core project. Its purpose is to train the AI to understand the **v1.1.x architecture** and generate code consistent with project standards.

**COMMAND FOR AI:** ALWAYS prioritize the patterns and examples in this document when creating or revising code.

---

## 🏛️ 2. CORE ARCHITECTURE PATTERNS (v1.1)

### Pattern 1: The `OVHL` Global Accessor (MANDATORY)

**DO NOT** `require` core services (like `ServiceManager`, `StateManager`, `RemoteClient`) manually. **ALWAYS** use the `OVHL` global accessor module.

- **Assumed Path:** `require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)`
- **Purpose:** A single, simplified entry point for all core systems.

```lua
-- ✅ CORRECT (Use OVHL)
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
local Logger = OVHL:GetService("Logger")
OVHL:Emit("MyEvent")

-- ❌ INCORRECT (DO NOT REQUIRE MANUALLY)
local ServiceManager = require(script.Parent.ServiceManager)
local Logger = ServiceManager:GetService("Logger")
local EventBus = ServiceManager:GetService("EventBus")
EventBus:Emit("MyEvent")
```

### Pattern 2: Auto-Discovery (MANDATORY)

All services, controllers, and modules are loaded automatically. **DO NOT** write manual registration code.

- **`__manifest` (Required):** Every file must have this "ID card" to be recognized.
- **`__config` (Optional):** For "No-Hardcode" default settings.

### Pattern 3: "No Crash" Philosophy (MANDATORY)

Use `pcall()` for **ALL** risky operations (Network, Data, Event Handlers). **ALWAYS** log errors using `OVHL:GetService("Logger")`.

### Pattern 4: Communication Channels (MANDATORY)

- **Internal (Server-Only):** Use `OVHL:Emit` and `OVHL:Subscribe` (shortcuts for `EventBus`).
- **External (Client-Server):** Use `OVHL:Fire` and `OVHL:Invoke` (shortcuts for `RemoteClient`).

---

## 🗂️ 3. CODE FILE STRUCTURE (`src/`)

The AI must place new files in the correct location according to `DEVELOPMENT_STANDARDS.md`.

```text
src/
├── server/
│   ├── services/       (Core Services: Logger, EventBus, etc.)
│   ├── modules/        (Game Features: Inventory, Quests, etc.)
│   └── init.server.lua (Server Bootstrap)
│
├── client/
│   ├── controllers/    (Core Controllers: StateManager, RemoteClient, etc.)
│   ├── modules/        (UI Features: HUD, ShopUI, etc.)
│   ├── lib/            (UI Library, BaseComponent, etc.)
│   └── init.client.lua (Client Bootstrap)
│
└── shared/
    ├── utils/          (Core Utils: Manifest, Resolver)
    ├── OVHL_Global.lua   (The 'OVHL' Global Accessor)
    └── constants/      (Shared Constants)
```

---

## 🎓 4. TRAINING CODE EXAMPLES (NEW v1.1 PATTERNS)

Use these examples as the primary reference when generating new code.

### Example 1: Creating a New Server Service

**TASK:** Create a new `InventoryService`.

```lua
-- File: src/server/services/InventoryService.lua

-- Always require OVHL if needed
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local InventoryService = {}
InventoryService.__index = InventoryService

-- 🔥 PATTERN 1: MANIFEST IS REQUIRED
InventoryService.__manifest = {
    name = "InventoryService",
    version = "1.0.0",
    type = "service",
    coreDependency = ">=1.1.0",
    dependencies = {"Logger", "DataService"},
    priority = 70,
    domain = "gameplay"
}

-- ⚙️ PATTERN 2: CONFIG IS OPTIONAL
InventoryService.__config = {
    defaultSlots = 20,
    maxStackSize = 99
}

-- 1. Initialization
function InventoryService:Init()
    -- PATTERN 3: Get other services via OVHL
    self.logger = OVHL:GetService("Logger")
    self.dataService = OVHL:GetService("DataService")
    self.config = OVHL:GetConfig("InventoryService")

    self.playerInventories = {}
    self.logger:Info("InventoryService Initialized")
    return true
end

-- 2. Startup
function InventoryService:Start()
    -- PATTERN 4: Subscribe to internal events via OVHL
    OVHL:Subscribe("PlayerJoined", function(player)
        self:LoadPlayerInventory(player)
    end)
    return true
end

-- 3. Public Methods
function InventoryService:LoadPlayerInventory(player)
    local userId = player.UserId

    -- PATTERN 5: MANDATORY pcall + logging
    local success, data = pcall(function()
        return self.dataService:GetPlayerData(player, "Inventory")
    end)

    if not success then
        self.logger:Error("Failed to load inventory for " .. player.Name, {error = data})
        self.playerInventories[userId] = { slots = self.config.defaultSlots, items = {} }
    else
        self.playerInventories[userId] = data
        self.logger:Info("Inventory loaded for " .. player.Name)
    end
end

return InventoryService
```

### Example 2: Client-Server Communication

**TASK:** The Client (UI) requests to buy an item.

```lua
-- ===================================================
-- CLIENT SIDE (e.g., src/client/modules/ShopUI.lua)
-- ===================================================
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

function ShopUI:OnBuyButtonPressed(itemId)
    -- PATTERN 1: Call server via OVHL:Invoke
    local result = OVHL:Invoke("Shop:BuyItem", itemId)

    if result.success then
        -- PATTERN 2: Update local state via OVHL:SetState
        OVHL:SetState("coins", result.newCoins)
        OVHL:SetState("inventory", result.newInventory)
    else
        -- Show error to user
        OVHL:GetService("Logger"):Warn("Purchase Failed", {error = result.error})
    end
end
```

```lua
-- ===================================================
-- SERVER SIDE (e.g., src/server/modules/ShopModule.lua)
-- ===================================================
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local ShopModule = {}
ShopModule.__index = ShopModule

ShopModule.__manifest = { ... } -- Manifest is still required

function ShopModule:Start()
    self.logger = OVHL:GetService("Logger")

    -- PATTERN 3: Register handler with RemoteManager
    -- (This is one of the few manual registrations to a service)
    local RemoteManager = OVHL:GetService("RemoteManager")
    RemoteManager:RegisterHandler("Shop:BuyItem", function(player, itemId)
        return self:AttemptPurchase(player, itemId)
    end)
end

function ShopModule:AttemptPurchase(player, itemId)
    -- PATTERN 4: Always validate client input & wrap in pcall
    local success, result = pcall(function()
        local EconomyService = OVHL:GetService("EconomyService")
        local InventoryService = OVHL:GetService("InventoryService")

        -- ... (Logic to validate price, player money, inventory slots) ...

        return { newCoins = 900, newInventory = { ... } } -- Example response
    end)

    if not success then
        self.logger:Error("AttemptPurchase Failed", {error = result})
        return { success = false, error = "Internal server error" }
    else
        -- PATTERN 5: Emit internal event for other services
        OVHL:Emit("ItemPurchased", player, itemId)
        return { success = true, newCoins = result.newCoins, newInventory = result.newInventory }
    end
end

return ShopModule
```

### Example 3: UI Component (Client) with State

**TASK:** Create a `CoinDisplay` UI component.

```lua
-- File: src/client/modules/ui/CoinDisplay.lua
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
local BaseComponent = require(script.Parent.Parent.Parent.lib.BaseComponent) --

local CoinDisplay = setmetatable({}, BaseComponent)
CoinDisplay.__index = CoinDisplay

-- 🔥 PATTERN 1: MANIFEST IS REQUIRED
CoinDisplay.__manifest = {
    name = "CoinDisplay",
    version = "1.0.0",
    type = "module",
    domain = "ui",
    dependencies = {"StateManager"} -- Depends on StateManager
}

-- 1. Initialization
function CoinDisplay:Init()
    BaseComponent.Init(self)

    -- PATTERN 2: Get initial state via OVHL:GetState
    self.state = {
        coins = OVHL:GetState("coins", 0)
    }
    self.connections = {}
end

-- 2. Lifecycle: DidMount (After UI appears)
function CoinDisplay:DidMount()
    -- PATTERN 3: Subscribe to state via OVHL:Subscribe
    local unsub = OVHL:Subscribe("coins", function(newCoins)
        -- PATTERN 4: Update component's local state
        self:SetState({ coins = newCoins })
    end)

    -- PATTERN 5: Store connection for cleanup
    table.insert(self.connections, unsub)
end

-- 3. Lifecycle: WillUnmount (Before UI is destroyed)
function CoinDisplay:WillUnmount()
    -- PATTERN 6: MANDATORY Cleanup
    for _, unsub in ipairs(self.connections) do
        unsub()
    end
end

-- 4. Lifecycle: Render
function CoinDisplay:Render()
    -- Get style controller via OVHL:GetService
    local StyleManager = OVHL:GetService("StyleManager")

    local frame = Instance.new("Frame")
    -- ... (Setup Frame) ...

    local label = Instance.new("TextLabel")
    label.Text = "💰 " .. self.state.coins
    label.TextColor3 = StyleManager:GetColor("text") --
    label.Parent = frame

    return frame
end

return CoinDisplay
```

---

## 🚨 5. COMMON PITFALLS & SOLUTIONS

| Pitfall                   | ❌ Incorrect Code (Old Pattern)                                                               | ✅ Correct Solution (OVHL Pattern)                                                        |
| ------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **Manual `require`**      | `local Logger = require(script.Parent.Parent.services.Logger)`                                | `local Logger = OVHL:GetService("Logger")`                                                |
| **Direct Service Calls**  | `InventoryService:AddItem(player, "Sword")`                                                   | `OVHL:Emit("RequestAddItem", player, "Sword")` (Use EventBus)                             |
| **No `pcall` on Network** | `local data = OVHL:Invoke("LoadData")` <br/> `print(data.coins)` (Can error if `data` is nil) | `local s, data = pcall(OVHL.Invoke, OVHL, "LoadData")` <br/> `if s and data then ... end` |
| **Connection Leaks**      | `function HUD:DidMount()` <br/> `OVHL:Subscribe("coins", ...)` <br/> _(No WillUnmount)_       | `function HUD:WillUnmount()` <br/> `for _, c in ipairs(self.connections) do c() end`      |

---

## 📈 6. GUIDELINES FOR AI

- **ALWAYS** use the Global Accessor `OVHL`.
- **ALWAYS** include a `__manifest` when creating a new service, controller, or module file.
- **ALWAYS** include a `__config` if the module has default settings.
- **ALWAYS** use `pcall` and `OVHL:GetService("Logger"):Error` for error handling.
- **ALWAYS** respect the Communication Patterns (Internal EventBus, External Remotes).
- **ALWAYS** clean up connections in `WillUnmount` for UI components.

---

## 📚 7. KNOWLEDGE UPDATE (v1.1)

- **v1.0 System (Old):** Used manual registration and manual `require` calls. **(DEPRECATED)**
- **v1.1 System (New):** Uses **Auto-Discovery** based on `__manifest`, and the **`OVHL` Global Accessor** for all interactions.

---

## 🔄 Change History (Changelog)

| Version   | Date           | Author             | Changes                                                                                                                                                                                                                                                                                                                                                                                          |
| --------- | -------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **1.1.0** | **2025-10-28** | **OVHL Core Team** | **(MAJOR REVISION)** <br/> - Converted document to English for AI-native consumption. <br/> - Replaced all code examples to use the `Global Accessor OVHL`. <br/> - Added `__manifest` and `__config` standards to all examples (Point 4). <br/> - Updated "Core Architecture Patterns" (Point 2) to match `ARCHITECTURE.md` v1.1.x. <br/> - Updated "Pitfalls" (Point 5) with `OVHL` solutions. |
| 1.0.0     | 2025-10-27     | OVHL Core Team     | Initial release of AI Context document.                                                                                                                                                                                                                                                                                                                                                          |

---

<p align="center">
  <small>Copyright © 2025 OVHL Studio. All Rights Reserved.</small>
</p>
