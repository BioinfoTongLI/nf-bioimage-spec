#!/usr/bin/env bash
set -euo pipefail

# Run this after changing schemas/ to update the entire website.
# Usage: ./scripts/update_website.sh

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Updating website from schemas..."

# 1. Regenerate templates
echo "  → Generating templates..."
python3 scripts/generate_templates.py

# 2. Update categories page (inlined data)
echo "  → Rebuilding categories page..."
python3 scripts/rebuild_categories_page.py

# 3. Update templates page data files
echo "  → Copying schema data for templates page..."
cp schemas/categories.json docs/categories_data.json
cp schemas/variants.json docs/variants_data.json

# Escape ${ for JavaScript safety in variants
python3 -c "
from pathlib import Path
v = Path('docs/variants_data.json').read_text()
Path('docs/variants_data.json').write_text(v.replace('\${', '\\\${'))
"

echo ""
echo "✓ Website updated. Review changes with:"
echo "    cd docs/ && python3 -m http.server 8000"
echo "  Then open http://localhost:8000"
echo ""
echo "  When satisfied:"
echo "    git add ."
echo "    git commit -m 'docs: update website with latest schema changes'"
echo "    git push origin main"
