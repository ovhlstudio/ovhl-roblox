# 💬 OVHL CORE - AI PROMPT TEMPLATES (v1.1)

## 📋 DOCUMENT INFORMATION

| Property             | Value                                       |
| -------------------- | ------------------------------------------- |
| **Document ID**      | `AI-002`                                    |
| **Document Version** | `1.1.0`                                     |
| **Status**           | `Active (Revised)`                          |
| **Location Path**    | `./docs/00_AI_CONTEXT/PROMPT_TEMPLATES.md`  |
| **Repository**       | `https://github.com/ovhlstudio/ovhl-roblox` |
| **License**          | `MIT`                                       |
| **Relations**        | `OVHL_AI_CONTEXT.md (AI-001)`               |
| **Author**           | `OVHL Core Team`                            |
| **Last Updated**     | `2025-10-28`                                |

---

## 🎯 1. CORE PROMPT STRUCTURE (GENERAL)

Use this structure for any new feature, fix, or refactor.

```markdown
CONTEXT: OVHL Core Project v1.1
AI CONTEXT FILE: /docs/ai_context/OVHL_AI_CONTEXT.md
TARGET FILES: [List file paths, e.g., /src/server/services/MyService.lua]

OBJECTIVE: [Clear description of what to build, fix, or refactor]

OVHL v1.1 ARCHITECTURE CONSTRAINTS (MANDATORY):

- MUST use the `OVHL` Global Accessor for all core interactions.
- MUST use `__manifest` (and `__config` if applicable) for all new modules/services.
- MUST follow "No Crash" philosophy (use `pcall()` for all risky operations).
- MUST use `OVHL:GetService("Logger")` for all errors and warnings.
- MUST follow Communication Patterns (Internal `EventBus` vs. External `RemoteManager`).
- MUST follow Naming Conventions from `DEVELOPMENT_STANDARDS.md`.

SPECIFIC REQUIREMENTS:

1. [Requirement 1 with detailed acceptance criteria]
2. [Requirement 2 with detailed acceptance criteria]
3. [Integration points with existing services/modules]

OUTPUT FORMAT:

- Complete, copy-paste-ready Luau code.
- Full file path for each code block.
- Include `__manifest` and `__config` tables.
- Include documentation comments.
```

---

## 🔧 2. SPECIFIC TASK TEMPLATES

### Template 2.1: New Service Creation

```markdown
CONTEXT: OVHL Core Project v1.1 - New Service
AI CONTEXT FILE: /docs/ai_context/OVHL_AI_CONTEXT.md
TARGET FILES: /src/server/services/MyNewService.lua

OBJECTIVE: Create a new Core Service called `MyNewService`.

SERVICE SPECIFICATION:

- SERVICE NAME: `MyNewService`
- PURPOSE: [Clear one-sentence purpose]
- DOMAIN: [e.g., 'gameplay', 'system', 'data']
- PRIORITY: [e.g., 80]
- DEPENDENCIES: ["Logger", "EventBus"]

METHODS REQUIRED:

- `MyMethod(param1)`: [Purpose and parameters]
- `HandleEvent(data)`: [Purpose and parameters]

OVHL v1.1 ARCHITECTURE CONSTRAINTS (MANDATORY):

- MUST generate a complete `__manifest` table with all specification details.
- MUST generate a `__config` table for default settings.
- MUST use `OVHL` accessor to get Logger, EventBus, etc. in `Init()` or `Start()`.
- MUST use `pcall()` and `OVHL:GetService("Logger")` for `MyMethod`.

OUTPUT FORMAT:

- Complete Luau code for `src/server/services/MyNewService.lua`.
- Include `__manifest`, `__config`, `Init()`, `Start()`, and all required methods.
```

### Template 2.2: New UI Component Creation

```markdown
CONTEXT: OVHL Core Project v1.1 - New UI Component
AI CONTEXT FILE: /docs/ai_context/OVHL_AI_CONTEXT.md
TARGET FILES: /src/client/modules/ui/MyComponent.lua

OBJECTIVE: Create a new UI Component called `MyComponent`.

COMPONENT SPECIFICATION:

- COMPONENT NAME: `MyComponent`
- PURPOSE: [Clear one-sentence purpose, e.g., "Display player's health"]
- DOMAIN: `ui`
- DEPENDENCIES: ["StateManager"]

STATE & LIFECYCLE:

- MUST subscribe to `OVHL:GetState("health")`.
- MUST store `health` in its internal `self.state`.
- MUST use `self:SetState()` to update.
- MUST clean up all connections in `WillUnmount`.
- MUST extend `BaseComponent`.

OVHL v1.1 ARCHITECTURE CONSTRAINTS (MANDATORY):

- MUST generate a complete `__manifest` table.
- MUST use `OVHL` accessor for `GetState`, `Subscribe`, and `GetService("StyleManager")`.
- MUST correctly implement `Init()`, `Render()`, `DidMount()`, and `WillUnmount()`.

OUTPUT FORMAT:

- Complete Luau code for `src/client/modules/ui/MyComponent.lua`.
```

### Template 2.3: Bug Fixing

```markdown
CONTEXT: OVHL Core Project v1.1 - Bug Fix
AI CONTEXT FILE: /docs/ai_context/OVHL_AI_CONTEXT.md
TARGET FILES: [File path of the broken code]

ISSUE: [Describe the bug in detail]
CURRENT BEHAVIOR: [What happens now - include error messages]
EXPECTED BEHAVIOR: [What should happen]

ERROR MESSAGE:
\`\`\`
[Paste exact error text here]
\`\`\`

OVHL v1.1 FIX REQUIREMENTS:

- Adhere to the "No Crash" philosophy.
- Wrap the failing operation in `pcall()`.
- Add detailed error logging using `OVHL:GetService("Logger"):Error()`.
- Maintain all existing functionality and `OVHL` patterns.

OUTPUT FORMAT:

- Brief explanation of the root cause.
- The complete, corrected function or file, ready to copy-paste.
```

---

## 📈 3. PROMPT ENHANCEMENT (EXAMPLE)

How to turn a "bad" prompt into a "good" OVHL v1.1 prompt.

### ❌ Bad Prompt (Vague, No Context)

> "Create an AuthenticationService"

**Result:** AI generates generic code that doesn't fit the architecture.

### ✅ Good Prompt (Specific, OVHL v1.1 Context)

```markdown
CONTEXT: OVHL Core Project v1.1 - New Service
AI CONTEXT FILE: /docs/ai_context/OVHL_AI_CONTEXT.md
TARGET FILES: /src/server/services/AuthenticationService.lua

OBJECTIVE: Create a new Core Service called `AuthenticationService` to manage player login state and session validation.

SERVICE SPECIFICATION:

- SERVICE NAME: `AuthenticationService`
- PURPOSE: Handle player login state and validate sessions.
- DOMAIN: `system`
- PRIORITY: 90
- DEPENDENCIES: ["Logger", "DataService"]

METHODS REQUIRED:

- `Login(player)`: Called on "PlayerJoined" event. Loads session data.
- `Logout(player)`: Called on "PlayerRemoving" event. Saves session data.
- `IsValidSession(player)`: Returns boolean if the player's session is active.

OVHL v1.1 ARCHITECTURE CONSTRAINTS (MANDATORY):

- MUST generate a `__manifest` table.
- MUST generate a `__config` table (e.g., `sessionLength = 3600`).
- MUST use `OVHL` accessor.
- MUST subscribe to "PlayerJoined" and "PlayerRemoving" in `Start()`.
- MUST use `pcall()` and `OVHL:GetService("Logger")` when calling `DataService`.

OUTPUT FORMAT:

- Complete Luau code for `src/server/services/AuthenticationService.lua`.
```

---

## 🔄 Change History (Changelog)

| Version   | Date           | Author             | Changes                                                                                                                                                                                                                                                                                                                                                                                              |
| --------- | -------------- | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1.1.0** | **2025-10-28** | **OVHL Core Team** | **(MAJOR REVISION)** <br/> - Converted document to English for AI-native consumption. <br/> - Updated all templates (Poin 1, 2) to enforce `OVHL` Global Accessor. <br/> - Added `__manifest` and `__config` requirements to all templates. <br/> - Added "No Crash" / `pcall` philosophy as a mandatory constraint. <br/> - Upgraded the "Prompt Enhancement" example (Poin 3) to v1.1.0 standards. |
| 1.0.0     | 2025-10-27     | OVHL Core Team     | Initial release of prompt templates document.                                                                                                                                                                                                                                                                                                                                                        |

---

<p align="center">
  <small>Copyright © 2025 OVHL Studio. All Rights Reserved.</small>
</p>
