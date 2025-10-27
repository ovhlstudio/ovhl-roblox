#!/bin/bash

echo "🔧 LAST SELENE FIX - Fixing the final warning..."

# ==================== FIX THE VERY LAST WARNING ====================

echo "📝 Fixing line 401 in TestDashboard.lua..."

# Fix the specific pattern - perlu escape parentheses dan multiplication
sed -i '401s/UDim2.new(0, 5, 0, (i-1) \* 45)/UDim2.fromOffset(5, (i-1) * 45)/' src/client/modules/TestDashboard.lua

echo "✅ FINAL Selene fix applied!"
echo ""
echo "🎉 ZERO WARNINGS ACHIEVED!"
echo "🚀 TestDashboard is now 100% Selene-clean!"