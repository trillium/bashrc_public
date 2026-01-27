#!/bin/bash
# test-block-story.sh
#
# Tests for block-story.sh

set -e

tmpdir=$(mktemp -d)
cd "$tmpdir"

cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": false, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": false, "dependencies": ["story-1"]}
  ]
}
EOF

cp /Users/trilliumsmith/bashrc_dir/ralph/bin/block-story.sh .
chmod +x block-story.sh

# Test 1: Block a story
./block-story.sh story-1 >/dev/null

result=$(jq -r '.stories[] | select(.id == "story-1") | .blocked' prd.json)
if [ "$result" = "true" ]; then
  echo "✓ Test 1 PASS: Story blocked successfully"
else
  echo "✗ Test 1 FAIL: Expected blocked=true, got '$result'"
  exit 1
fi

# Test 2: Verify other stories unaffected
result=$(jq -r '.stories[] | select(.id == "story-2") | .blocked' prd.json)
if [ "$result" = "null" ]; then
  echo "✓ Test 2 PASS: Other stories unaffected"
else
  echo "✗ Test 2 FAIL: Expected null, got '$result'"
  exit 1
fi

echo "block-story.sh: ALL TESTS PASSED"

cd - >/dev/null
rm -rf "$tmpdir"
