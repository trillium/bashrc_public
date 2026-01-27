#!/bin/bash
# test-get-story-details.sh
#
# Tests for get-story-details.sh

set -e

tmpdir=$(mktemp -d)
cd "$tmpdir"

cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": false, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": false, "dependencies": ["story-1"]},
    {"id": "story-3", "title": "Third story", "priority": 3, "passes": true, "dependencies": []}
  ]
}
EOF

cp /Users/trilliumsmith/bashrc_dir/ralph/bin/get-story-details.sh .
chmod +x get-story-details.sh

result=$(./get-story-details.sh story-2)

if echo "$result" | grep -q '"id": "story-2"'; then
  echo "get-story-details.sh test: PASS"
else
  echo "get-story-details.sh test: FAIL"
  echo "Expected to find story-2 in output."
  echo "Got: $result"
  exit 1
fi

cd - >/dev/null
rm -rf "$tmpdir"
