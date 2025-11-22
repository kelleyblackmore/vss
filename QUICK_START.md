# VSS Quick Start Guide

Get started with the Vulnerability Scan Service in under 5 minutes!

## 1. Basic Setup

Add this to your workflow:

```yaml
- uses: actions/checkout@v4

- name: Scan for vulnerabilities
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
```

## 2. Common Use Cases

### Scan npm packages
```yaml
- uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
```

### Scan Python dependencies
```yaml
- uses: kelleyblackmore/vss@v1
  with:
    target: 'requirements.txt'
```

### Scan Python uv.lock
```yaml
- uses: kelleyblackmore/vss@v1
  with:
    target: 'uv.lock'
```

### Scan from URL
```yaml
- uses: kelleyblackmore/vss@v1
  with:
    url: 'https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz'
    package-type: 'npm'
```

### Call from another repository
```yaml
jobs:
  scan:
    uses: kelleyblackmore/vss/.github/workflows/reusable-scan.yml@v1
    with:
      target: 'package-lock.json'
      upload-artifact: true
```

### Fail on vulnerabilities
```yaml
- uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
    fail-on-vuln: 'true'
```

## 3. Save Results

```yaml
- name: Scan
  id: scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
    output-file: 'scan-report.json'

- name: Upload report
  uses: actions/upload-artifact@v4
  with:
    name: vulnerability-report
    path: 'scan-report.json'
```

## 4. Use Outputs

```yaml
- name: Scan
  id: scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'

- name: Check results
  run: |
    echo "Vulnerabilities: ${{ steps.scan.outputs.vulnerabilities-found }}"
    echo "Checksum: ${{ steps.scan.outputs.checksum }}"
```

## 5. GitHub Security Integration

```yaml
- name: Scan (SARIF)
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
    format: 'sarif'
    output-file: 'results.sarif'

- name: Upload to Security tab
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: 'results.sarif'
```

Don't forget to set permissions:
```yaml
permissions:
  security-events: write
  contents: read
```

## Need More Help?

- 📖 [Full Documentation](./README.md)
- 🔧 [Troubleshooting](./TROUBLESHOOTING.md)
- 💡 [Examples](./examples/)
