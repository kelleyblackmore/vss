#!/bin/bash
set -e

echo "=== VSS Local Test Script ==="
echo ""

# Ensure osv-scanner is in PATH
export PATH=$PATH:$(go env GOPATH)/bin

# Test 1: Create a test package-lock.json
echo "Test 1: Creating test package-lock.json..."
cat > test-package-lock.json << 'EOF'
{
  "name": "test-vss",
  "version": "1.0.0",
  "lockfileVersion": 2,
  "requires": true,
  "packages": {
    "": {
      "name": "test-vss",
      "version": "1.0.0"
    },
    "node_modules/lodash": {
      "version": "4.17.20",
      "resolved": "https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz"
    }
  }
}
EOF

# Test 2: Generate checksum
echo ""
echo "Test 2: Generating checksum..."
CHECKSUM=$(sha256sum test-package-lock.json | cut -d' ' -f1)
echo "SHA256: $CHECKSUM"

# Test 3: Create Python requirements.txt
echo ""
echo "Test 3: Creating test requirements.txt..."
cat > test-requirements.txt << 'EOF'
requests==2.25.1
django==3.1.0
EOF

CHECKSUM_PY=$(sha256sum test-requirements.txt | cut -d' ' -f1)
echo "SHA256: $CHECKSUM_PY"

# Test 4: Detect file types
echo ""
echo "Test 4: File type detection..."
for file in test-package-lock.json test-requirements.txt; do
  TARGET_TYPE="unknown"
  case "$file" in
    *package-lock.json) TARGET_TYPE="npm-lock" ;;
    *requirements.txt) TARGET_TYPE="python-requirements" ;;
  esac
  echo "$file -> $TARGET_TYPE"
done

# Test 5: Create metadata report
echo ""
echo "Test 5: Creating metadata report..."
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > test-vss-report.json << EOF
{
  "vss_version": "1.0.0",
  "scan_metadata": {
    "timestamp": "$TIMESTAMP",
    "target": "test-package-lock.json",
    "target_type": "npm-lock",
    "checksum": "$CHECKSUM",
    "file_size": "$(stat -c%s test-package-lock.json 2>/dev/null || stat -f%z test-package-lock.json)",
    "scanner": "osv-scanner"
  },
  "summary": {
    "vulnerabilities_found": 0,
    "scan_status": "test"
  },
  "scan_results": {
    "results": []
  }
}
EOF

echo "Report created:"
cat test-vss-report.json | jq '.'

# Test 6: Validate JSON structure
echo ""
echo "Test 6: Validating JSON structure..."
if jq empty test-vss-report.json 2>/dev/null; then
  echo "✓ Valid JSON structure"
else
  echo "✗ Invalid JSON"
  exit 1
fi

# Test 7: Check required fields
echo ""
echo "Test 7: Checking required fields..."
REQUIRED_FIELDS=("vss_version" "scan_metadata" "summary" "scan_results")
for field in "${REQUIRED_FIELDS[@]}"; do
  if jq -e ".$field" test-vss-report.json > /dev/null 2>&1; then
    echo "✓ Found $field"
  else
    echo "✗ Missing $field"
    exit 1
  fi
done

echo ""
echo "=== All Tests Passed! ==="
echo ""
echo "Cleaning up test files..."
rm -f test-package-lock.json test-requirements.txt test-vss-report.json

echo "Done!"
