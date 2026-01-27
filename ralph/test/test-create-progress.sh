#!/bin/bash
# test-create-progress.sh
#
# Tests for create-progress.sh

set -e

tmpdir=$(mktemp -d)
cd "$tmpdir"

cat > prd.json <<EOF
{
  "stories": [
    {"id": "story-1", "title": "First story", "priority": 2, "passes": false, "dependencies": []},
    {"id": "story-2", "title": "Second story", "priority": 1, "passes": false, "dependencies": [], "attempts": ["progress/story-2_first.md"]}
  ]
}
EOF

cp /Users/trilliumsmith/bashrc_dir/ralph/bin/create-progress.sh .
chmod +x create-progress.sh

# Test 1: Create success entry
json_success='{
  "storyId": "story-1",
  "status": "success",
  "model": "claude-sonnet-4",
  "summary": "Implemented feature X",
  "filesChanged": "file1.sh, file2.sh",
  "learnings": "Learned about Y",
  "validationResults": "All tests passed"
}'

./create-progress.sh "$json_success" >/dev/null

if [ -f "progress.txt" ]; then
  echo "✓ Test 1 PASS: progress.txt created"
else
  echo "✗ Test 1 FAIL: progress.txt not created"
  exit 1
fi

if grep -q "story-1" progress.txt && grep -q "First story" progress.txt; then
  echo "✓ Test 2 PASS: Success entry contains story info"
else
  echo "✗ Test 2 FAIL: Missing story info in progress.txt"
  exit 1
fi

if grep -q "Implemented feature X" progress.txt; then
  echo "✓ Test 3 PASS: Summary included in progress.txt"
else
  echo "✗ Test 3 FAIL: Summary not found in progress.txt"
  exit 1
fi

# Test 2: Create failure entry
json_failure='{
  "storyId": "story-2",
  "status": "failure",
  "model": "claude-sonnet-3.5",
  "failureReason": "Build failed",
  "whatAttempted": "Tried to add feature",
  "errorsEncountered": "Error: undefined variable",
  "whatWasTried": "Checked syntax, reviewed logs",
  "learnings": "Need better error handling",
  "recommendations": "Add validation step"
}'

output=$(./create-progress.sh "$json_failure")
failure_file="$output"

if [ -f "$failure_file" ]; then
  echo "✓ Test 4 PASS: Failure context file created"
else
  echo "✗ Test 4 FAIL: Failure file not created at: $failure_file"
  exit 1
fi

if grep -q "Build failed" "$failure_file"; then
  echo "✓ Test 5 PASS: Failure reason in context file"
else
  echo "✗ Test 5 FAIL: Failure reason not found"
  exit 1
fi

if grep -q "\*\*Attempt Number:\*\* 2" "$failure_file"; then
  echo "✓ Test 6 PASS: Attempt number calculated correctly (existing attempt + 1)"
else
  echo "✗ Test 6 FAIL: Attempt number incorrect"
  grep "Attempt Number" "$failure_file" || true
  exit 1
fi

if echo "$failure_file" | grep -q "build-failed"; then
  echo "✓ Test 7 PASS: Filename slug generated from failure reason"
else
  echo "✗ Test 7 FAIL: Expected slug 'build-failed' in filename"
  exit 1
fi

echo "create-progress.sh: ALL TESTS PASSED"

cd - >/dev/null
rm -rf "$tmpdir"
