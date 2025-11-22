# Advanced Usage Guide

This guide covers advanced features of VSS including URL downloads, package type specifications, reusable workflows, and workflow dispatch.

## Table of Contents

- [Scanning Packages from URLs](#scanning-packages-from-urls)
- [Explicit Package Type Specification](#explicit-package-type-specification)
- [Reusable Workflows](#reusable-workflows)
- [Manual Workflow Dispatch](#manual-workflow-dispatch)
- [Variable Passing](#variable-passing)
- [Cross-Repository Usage](#cross-repository-usage)

## Scanning Packages from URLs

VSS can download and scan packages directly from URLs, useful for:
- Testing third-party packages before installation
- Scanning packages from private registries
- Auditing external dependencies
- CI/CD pipeline integration without local checkout

### Basic URL Scan

```yaml
- name: Scan npm package from URL
  uses: kelleyblackmore/vss@v1
  with:
    url: 'https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz'
    package-type: 'npm'
    output-file: 'lodash-scan.json'
```

### Python Package from PyPI

```yaml
- name: Scan Python package from PyPI
  uses: kelleyblackmore/vss@v1
  with:
    url: 'https://files.pythonhosted.org/packages/.../requests-2.25.1-py2.py3-none-any.whl'
    package-type: 'python'
```

### Scan Multiple URLs with Matrix

```yaml
strategy:
  matrix:
    package:
      - url: 'https://registry.npmjs.org/express/-/express-4.17.1.tgz'
        type: 'npm'
        name: 'express'
      - url: 'https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz'
        type: 'npm'
        name: 'lodash'

steps:
  - uses: kelleyblackmore/vss@v1
    with:
      url: ${{ matrix.package.url }}
      package-type: ${{ matrix.package.type }}
      output-file: '${{ matrix.package.name }}-report.json'
```

## Explicit Package Type Specification

When scanning files with ambiguous extensions or downloaded packages, explicitly specify the package type:

### Supported Package Types

- `npm` - Node.js/JavaScript packages
- `python` - Python packages
- `ruby` - Ruby gems
- `go` - Go modules
- `rust` - Rust crates
- `rpm` - RPM packages
- `deb` - Debian packages
- `auto` - Auto-detect (default)

### Example with Explicit Type

```yaml
- name: Scan tarball as Python package
  uses: kelleyblackmore/vss@v1
  with:
    target: 'my-package.tar.gz'
    package-type: 'python'
```

This is especially useful when:
- Filename doesn't indicate package type
- Downloaded packages have generic names
- Need to override auto-detection
- Working with renamed files

## Reusable Workflows

Call VSS from other repositories using the reusable workflow pattern.

### In Your Repository

Create `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  scan:
    uses: kelleyblackmore/vss/.github/workflows/reusable-scan.yml@v1
    with:
      target: 'package-lock.json'
      format: 'json'
      fail-on-vuln: false
      upload-artifact: true
      artifact-name: 'security-report'
```

### Available Inputs for Reusable Workflow

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `target` | string | - | Path to scan |
| `url` | string | - | URL to download |
| `package-type` | string | `auto` | Package type |
| `output-file` | string | `vss-report.json` | Output file |
| `format` | string | `json` | Output format |
| `fail-on-vuln` | boolean | `false` | Fail on vulnerabilities |
| `upload-artifact` | boolean | `true` | Upload report |
| `artifact-name` | string | `vss-scan-report` | Artifact name |

### Using Outputs from Reusable Workflow

```yaml
jobs:
  scan:
    uses: kelleyblackmore/vss/.github/workflows/reusable-scan.yml@v1
    with:
      target: 'package-lock.json'
  
  notify:
    needs: scan
    runs-on: ubuntu-latest
    steps:
      - name: Check results
        run: |
          echo "Found ${{ needs.scan.outputs.vulnerabilities-found }} vulnerabilities"
          echo "Checksum: ${{ needs.scan.outputs.checksum }}"
```

## Manual Workflow Dispatch

Create workflows that can be triggered manually with custom parameters.

### Basic Dispatch Workflow

```yaml
name: Manual Scan

on:
  workflow_dispatch:
    inputs:
      target_file:
        description: 'File to scan'
        required: false
      package_url:
        description: 'URL to download and scan'
        required: false
      package_type:
        description: 'Package type'
        required: false
        type: choice
        default: 'auto'
        options:
          - auto
          - npm
          - python
          - ruby
          - go

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        if: ${{ inputs.target_file != '' }}
      
      - name: Run scan
        uses: kelleyblackmore/vss@v1
        with:
          target: ${{ inputs.target_file }}
          url: ${{ inputs.package_url }}
          package-type: ${{ inputs.package_type }}
```

### With Results Summary

```yaml
- name: Create summary
  if: always()
  run: |
    echo "### Scan Results 🛡️" >> $GITHUB_STEP_SUMMARY
    echo "" >> $GITHUB_STEP_SUMMARY
    echo "- Vulnerabilities: ${{ steps.scan.outputs.vulnerabilities-found }}" >> $GITHUB_STEP_SUMMARY
    echo "- Checksum: \`${{ steps.scan.outputs.checksum }}\`" >> $GITHUB_STEP_SUMMARY
```

## Variable Passing

### Environment Variables

```yaml
env:
  PACKAGE_URL: 'https://registry.npmjs.org/lodash/-/lodash-4.17.20.tgz'
  PACKAGE_TYPE: 'npm'

steps:
  - uses: kelleyblackmore/vss@v1
    with:
      url: ${{ env.PACKAGE_URL }}
      package-type: ${{ env.PACKAGE_TYPE }}
```

### From Previous Steps

```yaml
- name: Determine package
  id: determine
  run: |
    echo "package_url=https://registry.npmjs.org/express/-/express-4.17.1.tgz" >> $GITHUB_OUTPUT
    echo "package_type=npm" >> $GITHUB_OUTPUT

- name: Scan
  uses: kelleyblackmore/vss@v1
  with:
    url: ${{ steps.determine.outputs.package_url }}
    package-type: ${{ steps.determine.outputs.package_type }}
```

### From Workflow Inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      scan_target:
        required: true

jobs:
  scan:
    steps:
      - uses: kelleyblackmore/vss@v1
        with:
          target: ${{ inputs.scan_target }}
```

## Cross-Repository Usage

### Method 1: Reusable Workflow (Recommended)

In repository A:
```yaml
jobs:
  scan:
    uses: kelleyblackmore/vss/.github/workflows/reusable-scan.yml@v1
    with:
      target: 'package-lock.json'
```

### Method 2: Direct Action Call

In repository B:
```yaml
- name: Checkout
  uses: actions/checkout@v4

- name: Scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'requirements.txt'
```

### Method 3: Download from Artifact

In repository A (produces artifact):
```yaml
- name: Scan and upload
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
    output-file: 'report.json'

- uses: actions/upload-artifact@v4
  with:
    name: scan-report
    path: report.json
```

In repository B (consumes artifact):
```yaml
- uses: actions/download-artifact@v4
  with:
    name: scan-report
    repository: owner/repo-a
    run-id: ${{ inputs.run_id }}
    github-token: ${{ secrets.PAT }}
```

## Best Practices

1. **Use reusable workflows** for consistency across repositories
2. **Specify package-type explicitly** when scanning from URLs
3. **Enable fail-on-vuln** for production deployments
4. **Upload artifacts** for audit trails
5. **Use workflow_dispatch** for ad-hoc security checks
6. **Set appropriate permissions** in workflows
7. **Cache scan results** to avoid redundant scans

## Examples in This Repository

- [Manual Scan Workflow](../.github/workflows/manual-scan.yml)
- [Reusable Scan Workflow](../.github/workflows/reusable-scan.yml)
- [URL Download Examples](../examples/url-download-scan.yml)
- [Reusable Caller Example](../examples/reusable-workflow-caller.yml)
