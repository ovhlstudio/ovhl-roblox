#!/bin/bash
# ============================================
# OVHL CORE - STRUCTURE SNAPSHOT GENERATOR
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_FILE="./archive/current-structure-${TIMESTAMP}.md"
SNAPSHOT_DIR="./archive"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 OVHL CORE - STRUCTURE SNAPSHOT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================
# CREATE ARCHIVE DIRECTORY
# ============================================

echo -e "${YELLOW}📁 Creating archive directory...${NC}"
mkdir -p "$SNAPSHOT_DIR"
echo -e "${GREEN}✅ Archive directory: $SNAPSHOT_DIR${NC}"

# ============================================
# GENERATE SNAPSHOT HEADER
# ============================================

echo -e "${YELLOW}📝 Generating structure snapshot...${NC}"

cat > "$SNAPSHOT_FILE" << EOF
# 🏗️ OVHL CORE - STRUCTURE SNAPSHOT

## 📋 SNAPSHOT INFORMATION

| Property          | Value                  |
| ----------------- | ---------------------- |
| **Timestamp**     | \`$(date)\`            |
| **Snapshot File** | \`${SNAPSHOT_FILE}\`   |
| **OVHL Version**  | \`1.2.0\`              |
| **Status**        | \`Client-Side WIP\`    |

## 🎯 CURRENT STATUS

### ✅ WORKING:
- Server-side auto-discovery (6 services)
- Client-side auto-discovery (6 controllers + 3 modules)  
- OVHL Global Accessor APIs
- Basic State Management (Set/Get)
- Network Communication (Fire/Invoke/Listen)
- UI Component Foundation

### ❌ KNOWN ISSUES:
- HUD mounting timing issues
- State subscriptions not triggering
- UI reactivity not working
- UIController module discovery race condition

---

## 📁 COMPLETE STRUCTURE & SOURCE CODE

EOF

# ============================================
# GENERATE TREE STRUCTURE
# ============================================

echo -e "${YELLOW}🌳 Generating file tree structure...${NC}"

{
    echo "## 🌲 FILE TREE STRUCTURE"
    echo ""
    echo "\`\`\`"
    find src -type f -name "*.lua" | sort | sed 's/^/│   /'
    echo "\`\`\`"
    echo ""
} >> "$SNAPSHOT_FILE"

# ============================================
# GENERATE SOURCE CODE FOR EACH FILE
# ============================================

echo -e "${YELLOW}📄 Including source code for all files...${NC}"

# Find all Lua files and process them
find src -name "*.lua" | sort | while read -r file; do
    echo -e "${CYAN}📝 Processing: $file${NC}"
    
    {
        echo "## 📄 \`$file\`"
        echo ""
        echo "\`\`\`lua"
        cat "$file"
        echo "\`\`\`"
        echo ""
        echo "---"
        echo ""
    } >> "$SNAPSHOT_FILE"
done

# ============================================
# ADD CRITICAL CONFIG FILES
# ============================================

echo -e "${YELLOW}⚙️ Including configuration files...${NC}"

CONFIG_FILES=("default.project.json" "selene.toml")

for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        echo -e "${CYAN}📝 Processing: $config_file${NC}"
        {
            echo "## ⚙️ \`$config_file\`"
            echo ""
            echo "\`\`\`json"
            cat "$config_file"
            echo "\`\`\`"
            echo ""
            echo "---"
            echo ""
        } >> "$SNAPSHOT_FILE"
    fi
done

# ============================================
# ADD DEPENDENCY ANALYSIS
# ============================================

echo -e "${YELLOW}🔍 Analyzing dependencies...${NC}"

{
    echo "## 🔗 DEPENDENCY ANALYSIS"
    echo ""
    echo "### Server Services Dependencies:"
    echo ""
} >> "$SNAPSHOT_FILE"

# Analyze server services dependencies
find src/server/services -name "*.lua" | sort | while read -r file; do
    service_name=$(basename "$file" .lua)
    {
        echo "#### \`$service_name\`"
        echo "- **File:** \`$file\`"
        echo -n "- **Dependencies:** "
        if grep -q "dependencies" "$file"; then
            grep -A5 "dependencies" "$file" | grep -E "[\"']" | sed "s/.*\[\(.*\)\].*/\1/" | tr -d '",' | xargs | sed 's/ /, /g'
        else
            echo "None"
        fi
        echo ""
    } >> "$SNAPSHOT_FILE"
done

{
    echo "### Client Controllers Dependencies:"
    echo ""
} >> "$SNAPSHOT_FILE"

# Analyze client controllers dependencies  
find src/client/controllers -name "*.lua" | sort | while read -r file; do
    controller_name=$(basename "$file" .lua)
    {
        echo "#### \`$controller_name\`"
        echo "- **File:** \`$file\`"
        echo -n "- **Dependencies:** "
        if grep -q "dependencies" "$file"; then
            grep -A5 "dependencies" "$file" | grep -E "[\"']" | sed "s/.*\[\(.*\)\].*/\1/" | tr -d '",' | xargs | sed 's/ /, /g'
        else
            echo "None"
        fi
        echo ""
    } >> "$SNAPSHOT_FILE"
done

# ============================================
# ADD ISSUE SUMMARY
# ============================================

echo -e "${YELLOW}📋 Generating issue summary...${NC}"

{
    echo "## 🚨 CURRENT ISSUES SUMMARY"
    echo ""
    echo "### Critical Issues:"
    echo ""
    echo "1. **HUD Module Timing**"
    echo "   - UIController tries to mount HUD before module discovery"
    echo "   - \`OVHL:GetModule(\"HUD\")\` returns nil during UIController:Start()"
    echo ""
    echo "2. **State Subscriptions**"
    echo "   - Subscriptions registered but not triggering callbacks"
    echo "   - StateManager shows \"No subscribers\" despite HUD subscriptions"
    echo ""
    echo "3. **UI Reactivity**"
    echo "   - State changes don't automatically update UI"
    echo "   - Manual refresh required for UI updates"
    echo ""
    echo "### Root Causes Identified:"
    echo ""
    echo "- **Race Condition:** UIController Start() vs Module Discovery"
    echo "- **Subscription Mechanism:** StateManager callback execution failing"
    echo "- **Component Lifecycle:** HUD DidMount vs State subscription timing"
    echo ""
    echo "### Files Requiring Attention:"
    echo ""
    echo "- \`src/client/controllers/UIController.lua\` - Timing issues"
    echo "- \`src/client/controllers/StateManager.lua\` - Subscription bugs"
    echo "- \`src/client/modules/HUD.lua\` - Reactivity implementation"
    echo "- \`src/client/controllers/ClientController.lua\` - Load order"
    echo ""
} >> "$SNAPSHOT_FILE"

# ============================================
# FINAL SUMMARY
# ============================================

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 STRUCTURE SNAPSHOT COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📊 SNAPSHOT CONTENTS:${NC}"
echo -e "  ${GREEN}✅${NC} Complete file tree structure"
echo -e "  ${GREEN}✅${NC} Full source code of all Lua files"
echo -e "  ${GREEN}✅${NC} Configuration files"
echo -e "  ${GREEN}✅${NC} Dependency analysis"
echo -e "  ${GREEN}✅${NC} Current issues summary"
echo ""
echo -e "${YELLOW}📁 OUTPUT LOCATION:${NC}"
echo -e "  ${SNAPSHOT_FILE}"
echo ""
echo -e "${GREEN}🚀 READY FOR NEXT AI ANALYSIS!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Display file size
FILE_SIZE=$(du -h "$SNAPSHOT_FILE" | cut -f1)
echo -e "${CYAN}📦 Snapshot Size: ${FILE_SIZE}${NC}"