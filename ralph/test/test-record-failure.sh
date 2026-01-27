#!/bin/bash
# test-record-failure.sh
#
# Tests for record-failure.sh

set -e

tmpdir=$(mktemp -d)
cd "$tmpdir"

cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": false, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": false, "dependencies": ["story-1"], "attempts": ["progress/story-2_first.md"]}
  ]
}
EOF

cp /Users/trilliumsmith/bashrc_dir/ralph/bin/record-failure.sh .
chmod +x record-failure.sh

# Test 1: Add first attempt to story with no attempts
./record-failure.sh story-1 progress/story-1_attempt1.md >/dev/null

result=$(jq -r '.stories[] | select(.id == "story-1") | .attempts[0]' prd.json)
if [ "$result" = "progress/story-1_attempt1.md" ]; then
  echo "✓ Test 1 PASS: First attempt recorded"
else
  echo "✗ Test 1 FAIL: Expected 'progress/story-1_attempt1.md', got '$result'"
  exit 1
fi

# Test 2: Add second attempt to story with existing attempts
./record-failure.sh story-2 progress/story-2_second.md >/dev/null

attempts_count=$(jq -r '.stories[] | select(.id == "story-2") | .attempts | length' prd.json)
if [ "$attempts_count" = "2" ]; then
  echo "✓ Test 2 PASS: Second attempt added to existing attempts"
else
  echo "✗ Test 2 FAIL: Expected 2 attempts, got $attempts_count"
  exit 1
fi

second_attempt=$(jq -r '.stories[] | select(.id == "story-2") | .attempts[1]' prd.json)
if [ "$second_attempt" = "progress/story-2_second.md" ]; then
  echo "✓ Test 3 PASS: Correct second attempt recorded"
else
  echo "✗ Test 3 FAIL: Expected 'progress/story-2_second.md', got '$second_attempt'"
  exit 1
fi

echo "record-failure.sh: ALL TESTS PASSED"

cd - >/dev/null
rm -rf "$tmpdir"
