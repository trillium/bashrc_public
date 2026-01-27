#!/bin/bash
# test-is-complete.sh
#
# Tests for is-complete.sh

set -e

tmpdir=$(mktemp -d)
cd "$tmpdir"

cp /Users/trilliumsmith/bashrc_dir/ralph/bin/is-complete.sh .
chmod +x is-complete.sh

# Test 1: All stories complete
cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": true, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": true, "dependencies": []}
  ]
}
EOF

result=$(./is-complete.sh)
if [ "$result" = "COMPLETE" ]; then
  echo "✓ Test 1 PASS: Reports COMPLETE when all stories pass"
else
  echo "✗ Test 1 FAIL: Expected 'COMPLETE', got '$result'"
  exit 1
fi

# Test 2: Some stories incomplete
cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": true, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": false, "dependencies": []},
    {"id": "story-3", "title": "Third story", "priority": 3, "passes": false, "dependencies": []}
  ]
}
EOF

result=$(./is-complete.sh)
if echo "$result" | grep -q "INCOMPLETE: 2 remaining, 0 blocked"; then
  echo "✓ Test 2 PASS: Reports incomplete count correctly"
else
  echo "✗ Test 2 FAIL: Expected 'INCOMPLETE: 2 remaining, 0 blocked', got '$result'"
  exit 1
fi

# Test 3: Some stories blocked
cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": true, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": false, "dependencies": [], "blocked": true},
    {"id": "story-3", "title": "Third story", "priority": 3, "passes": false, "dependencies": []}
  ]
}
EOF

result=$(./is-complete.sh)
if echo "$result" | grep -q "INCOMPLETE: 1 remaining, 1 blocked"; then
  echo "✓ Test 3 PASS: Reports blocked count correctly"
else
  echo "✗ Test 3 FAIL: Expected 'INCOMPLETE: 1 remaining, 1 blocked', got '$result'"
  exit 1
fi

echo "is-complete.sh: ALL TESTS PASSED"

cd - >/dev/null
rm -rf "$tmpdir"
