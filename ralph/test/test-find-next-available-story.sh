#!/bin/bash
# test-find-next-available-story.sh
#
# Tests for find-next-available-story.sh

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

cp /Users/trilliumsmith/bashrc_dir/ralph/bin/find-next-available-story.sh .
chmod +x find-next-available-story.sh

result=$(./find-next-available-story.sh)
expected="2 story-1 First story"

if [ "$result" = "$expected" ]; then
  echo "find-next-available-story.sh test: PASS"
else
  echo "find-next-available-story.sh test: FAIL"
  echo "Expected: $expected"
  echo "Got:      $result"
  exit 1
fi

cd - >/dev/null
rm -rf "$tmpdir"
