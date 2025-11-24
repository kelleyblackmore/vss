# Manual Scan - Testing Examples

This guide provides ready-to-use parameter examples for testing the manual scan workflow with various scenarios.

## How to Use

1. Go to **Actions** tab in your GitHub repository
2. Select **"Manual Vulnerability Scan"** workflow
3. Click **"Run workflow"**
4. Fill in the parameters using examples below
5. Click **"Run workflow"** button

---

## Example 1: Scan npm package-lock.json

Test scanning a local npm lockfile in your repository.

```
target: package-lock.json
url: (leave empty)
package-type: auto
format: json
fail-on-vuln: false
```

**Use Case:** Scan your project's npm dependencies

---

## Example 2: Scan Python requirements.txt

Test scanning Python dependencies.

```
target: requirements.txt
url: (leave empty)
package-type: python
format: json
fail-on-vuln: false
```

**Use Case:** Scan Python project dependencies

---

## Example 3: Scan Python uv.lock file

Test scanning Python uv lockfile.

```
target: uv.lock
url: (leave empty)
package-type: python
format: json
fail-on-vuln: false
```

**Use Case:** Scan modern Python uv-managed dependencies

---

## Example 4: Download and Scan npm Package (Lodash)

Test downloading and scanning a package from npm registry.

```
target: (leave empty)
url: https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz
package-type: npm
format: json
fail-on-vuln: false
```

**Use Case:** Audit third-party npm packages before installation

**Known Issue:** Lodash 4.17.20 has known vulnerabilities - good for testing!

---

## Example 5: Download and Scan npm Package (Express)

Test with another popular npm package.

```
target: (leave empty)
url: https://registry.npmjs.org/express/-/express-4.17.1.tgz
package-type: npm
format: json
fail-on-vuln: false
```

**Use Case:** Test scanning framework packages

---

## Example 6: Download and Scan npm Package (Newer Lodash)

Test with a package that should have fewer vulnerabilities.

```
target: (leave empty)
url: https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz
package-type: npm
format: json
fail-on-vuln: false
```

**Use Case:** Compare vulnerability results between versions

---

## Example 7: Scan with SARIF Output Format

Test SARIF format output (uploads to GitHub Security tab).

```
target: package-lock.json
url: (leave empty)
package-type: auto
format: sarif
fail-on-vuln: false
```

**Use Case:** Generate SARIF report for GitHub Security integration

**Note:** Requires `security-events: write` permission

---

## Example 8: Scan with Table Format

Test table format output (displayed in console).

```
target: package-lock.json
url: (leave empty)
package-type: auto
format: table
fail-on-vuln: false
```

**Use Case:** Quick vulnerability overview in workflow logs

---

## Example 9: Fail on Vulnerabilities

Test workflow failure when vulnerabilities are found.

```
target: (leave empty)
url: https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz
package-type: npm
format: json
fail-on-vuln: true
```

**Use Case:** CI/CD pipeline that blocks on vulnerabilities

**Note:** This will fail the workflow if vulnerabilities are found (expected with Lodash 4.17.20)

---

## Example 10: Scan Go Dependencies

Test scanning Go module files (if you have go.mod in your repo).

```
target: go.mod
url: (leave empty)
package-type: go
format: json
fail-on-vuln: false
```

**Use Case:** Scan Go project dependencies

---

## Example 11: Scan Ruby Gemfile.lock

Test scanning Ruby dependencies (if you have Gemfile.lock).

```
target: Gemfile.lock
url: (leave empty)
package-type: ruby
format: json
fail-on-vuln: false
```

**Use Case:** Scan Ruby/Rails project dependencies

---

## Example 12: Auto-detect Package Type

Let VSS automatically detect the package type.

```
target: package-lock.json
url: (leave empty)
package-type: auto
format: json
fail-on-vuln: false
```

**Use Case:** Test auto-detection capabilities

---

## Example 13: Scan Python Wheel from URL

Test downloading and scanning a Python wheel file.

```
target: (leave empty)
url: https://files.pythonhosted.org/packages/51/bd/23c926cd341ea6b7dd0b2415e8d508ab33d82a25cf98a64420fa6d0f2406/requests-2.25.1-py2.py3-none-any.whl
package-type: python
format: json
fail-on-vuln: false
```

**Use Case:** Audit Python packages from PyPI

---

## Example 14: Scan Multiple Formats with Matrix Strategy

If you want to test multiple packages at once, create a custom workflow using matrix strategy.

Example workflow (not manual scan):
```yaml
strategy:
  matrix:
    test:
      - target: 'package-lock.json'
        type: 'npm'
      - target: 'requirements.txt'
        type: 'python'

steps:
  - uses: kelleyblackmore/vss@v1
    with:
      target: ${{ matrix.test.target }}
      package-type: ${{ matrix.test.type }}
```

---

## Testing Checklist

Use this checklist to systematically test VSS functionality:

- [ ] Test npm lockfile scan (package-lock.json)
- [ ] Test Python requirements scan (requirements.txt)
- [ ] Test Python uv.lock scan
- [ ] Test URL download (npm package)
- [ ] Test URL download (Python package)
- [ ] Test JSON output format
- [ ] Test SARIF output format
- [ ] Test table output format
- [ ] Test auto-detect package type
- [ ] Test explicit package type
- [ ] Test fail-on-vuln = true
- [ ] Test fail-on-vuln = false
- [ ] Verify artifact upload works
- [ ] Verify checksums are generated
- [ ] Verify output values are accessible

---

## Quick Test Setup Files

If you don't have test files in your repo, create these:

### test-package-lock.json
```json
{
  "name": "test-app",
  "version": "1.0.0",
  "lockfileVersion": 2,
  "requires": true,
  "packages": {
    "": {
      "name": "test-app",
      "version": "1.0.0",
      "dependencies": {
        "lodash": "4.17.20"
      }
    },
    "node_modules/lodash": {
      "version": "4.17.20",
      "resolved": "https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz",
      "integrity": "sha512-PlhdFcillOINfeV7Ni6oF1TAEayyZBoZ8bcshTHqOYJYlrqzRK5hagpagky5o4HfCzzd1TRkXPMFq6cKk9rGmA=="
    }
  },
  "dependencies": {
    "lodash": {
      "version": "4.17.20",
      "resolved": "https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz",
      "integrity": "sha512-PlhdFcillOINfeV7Ni6oF1TAEayyZBoZ8bcshTHqOYJYlrqzRK5hagpagky5o4HfCzzd1TRkXPMFq6cKk9rGmA=="
    }
  }
}
```

### test-requirements.txt
```
requests==2.25.1
urllib3==1.26.5
certifi==2021.5.30
```

### test-uv.lock
```toml
version = 1

[[package]]
name = "requests"
version = "2.25.1"
source = { registry = "https://pypi.org/simple" }
```

---

## Expected Results

### Clean Scan (No Vulnerabilities)
- Vulnerabilities Found: 0
- Status: ✅ No vulnerabilities found
- Workflow: Success

### Vulnerable Package (Lodash 4.17.20)
- Vulnerabilities Found: > 0
- Status: ⚠️ Vulnerabilities detected
- Workflow: Success (unless fail-on-vuln = true)

### Failed Scan (Invalid Input)
- Error message displayed
- Workflow: Failed
- Check logs for details

---

## Troubleshooting Test Scenarios

### Test Fails - File Not Found
**Input:**
```
target: non-existent-file.json
```
**Expected:** Workflow should fail with "Target does not exist" error

### Test Fails - No Input Provided
**Input:**
```
target: (empty)
url: (empty)
```
**Expected:** Workflow should fail validation with "Either 'target' or 'url' must be provided"

### Test Fails - Invalid URL
**Input:**
```
url: https://invalid-url-that-does-not-exist.com/package.tgz
```
**Expected:** Download should fail with curl error

### Test Fails - Both Inputs Provided
**Input:**
```
target: package-lock.json
url: https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz
```
**Expected:** Should work, but URL takes precedence (see validation step output)

---

## Real-World Testing Scenarios

### Scenario 1: Security Audit Before Deployment
```
url: https://registry.npmjs.org/your-package/-/your-package-1.0.0.tgz
package-type: npm
format: sarif
fail-on-vuln: true
```

### Scenario 2: Weekly Security Scan
```
target: package-lock.json
format: json
fail-on-vuln: false
```
Save report as artifact for compliance records.

### Scenario 3: Compare Package Versions
Run twice with different URLs:
- Version 1: `https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz`
- Version 2: `https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz`

Compare vulnerability counts.

---

## Next Steps

After testing manually:
1. Review the artifacts downloaded after each run
2. Check the workflow summary for scan results
3. If using SARIF format, check the Security tab
4. Integrate into your CI/CD pipeline once validated
5. Set up scheduled scans for ongoing monitoring
