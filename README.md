# VSS - Vulnerability Scan Service 🛡️

A self-service GitHub Action for vulnerability scanning of open source binaries and packages. VSS can scan various package types including npm, Python (pip, uv), RPM, DEB, and more, providing detailed vulnerability reports with checksum verification.

## Features

- 🔍 **Multi-format Support**: Scans npm packages, Python packages (including uv.lock), RPM, DEB, tarballs, and more
- 🔐 **Checksum Generation**: Automatically generates SHA256 checksums for all scanned artifacts
- 📊 **Flexible Output**: Supports JSON, SARIF, and table formats
- 🎯 **Detailed Metadata**: Captures scan timestamp, file size, target type, and comprehensive scan results
- ⚡ **Pipeline Integration**: Easy integration with GitHub Actions workflows
- 🛡️ **OSV-Scanner Powered**: Uses Google's OSV-Scanner for industry-standard vulnerability detection

## Usage

### Basic Example

```yaml
name: Vulnerability Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Scan package-lock.json for vulnerabilities
        uses: kelleyblackmore/vss@v1
        with:
          target: 'package-lock.json'
          output-file: 'vulnerability-report.json'
```

### Scan Python Requirements

```yaml
- name: Scan Python dependencies
  uses: kelleyblackmore/vss@v1
  with:
    target: 'requirements.txt'
    output-file: 'python-vuln-report.json'
    format: 'json'
```

### Scan Python uv.lock file

```yaml
- name: Scan Python uv.lock
  uses: kelleyblackmore/vss@v1
  with:
    target: 'uv.lock'
    output-file: 'uv-scan-report.json'
```

### Scan RPM Package

```yaml
- name: Scan RPM package
  uses: kelleyblackmore/vss@v1
  with:
    target: 'mypackage.rpm'
    output-file: 'rpm-scan-report.json'
```

### Fail on Vulnerabilities

```yaml
- name: Scan and fail if vulnerabilities found
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
    fail-on-vuln: 'true'
```

### SARIF Output for GitHub Security Tab

```yaml
- name: Scan with SARIF output
  uses: kelleyblackmore/vss@v1
  with:
    target: 'requirements.txt'
    output-file: 'results.sarif'
    format: 'sarif'
    
- name: Upload SARIF to GitHub Security
  uses: github/codeql-action/upload-sarif@v3
  if: always()
  with:
    sarif_file: 'results.sarif'
```

### Complete Workflow with Artifact Upload

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:

jobs:
  vulnerability-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run VSS scan
        id: vss
        uses: kelleyblackmore/vss@v1
        with:
          target: 'package-lock.json'
          output-file: 'vss-report.json'
          format: 'json'
      
      - name: Display scan results
        run: |
          echo "Vulnerabilities found: ${{ steps.vss.outputs.vulnerabilities-found }}"
          echo "Checksum: ${{ steps.vss.outputs.checksum }}"
          echo "Report: ${{ steps.vss.outputs.report-file }}"
      
      - name: Upload scan report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: vulnerability-report
          path: vss-report.json
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `target` | Path to the binary, package, or directory to scan | Yes | - |
| `output-file` | Output file path for scan results and metadata | No | `vss-report.json` |
| `format` | Output format: `json`, `sarif`, or `table` | No | `json` |
| `fail-on-vuln` | Fail the action if vulnerabilities are found | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `report-file` | Path to the generated vulnerability report file |
| `vulnerabilities-found` | Number of vulnerabilities found |
| `checksum` | SHA256 checksum of the scanned target |

## Supported Package Types

VSS automatically detects and scans various package formats. **Note**: For best results, use lockfiles (not manifest files like package.json):

- **JavaScript/Node.js**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` (recommended over `package.json`)
- **Python**: `requirements.txt`, `Pipfile.lock`, `poetry.lock`, `uv.lock`, `pyproject.toml`
- **Ruby**: `Gemfile.lock`
- **Go**: `go.mod`, `go.sum`
- **Rust**: `Cargo.lock`
- **PHP**: `composer.lock`
- **Directories**: Scans all supported package files in a directory

## Output Format

### JSON Report Structure

```json
{
  "vss_version": "1.0.0",
  "scan_metadata": {
    "timestamp": "2025-11-22T09:45:00Z",
    "target": "package-lock.json",
    "target_type": "npm-lock",
    "checksum": "abc123...",
    "file_size": "1234",
    "scanner": "osv-scanner",
    "scanner_exit_code": 0
  },
  "summary": {
    "vulnerabilities_found": 0,
    "scan_status": "clean"
  },
  "scan_results": {
    "results": []
  }
}
```

## More Examples

For more comprehensive examples, see the [examples](./examples/) directory:
- [NPM Package Scanning](./examples/npm-scan.yml)
- [Python Package Scanning](./examples/python-scan.yml)
- [Multi-Language Scanning](./examples/multi-language-scan.yml)
- [SARIF Upload for GitHub Security](./examples/sarif-upload.yml)

### Scanning Multiple Targets

```yaml
strategy:
  matrix:
    target:
      - package.json
      - requirements.txt
      - go.mod

steps:
  - uses: actions/checkout@v4
  
  - name: Scan ${{ matrix.target }}
    uses: kelleyblackmore/vss@v1
    with:
      target: ${{ matrix.target }}
      output-file: scan-${{ matrix.target }}.json
```

### Integration with Slack Notifications

```yaml
- name: Run vulnerability scan
  id: scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package.json'
  continue-on-error: true

- name: Notify Slack on vulnerabilities
  if: steps.scan.outputs.vulnerabilities-found > 0
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "⚠️ Found ${{ steps.scan.outputs.vulnerabilities-found }} vulnerabilities in package.json"
      }
```

## How It Works

1. **Detection**: VSS automatically detects the type of package or binary being scanned
2. **Checksum**: Generates SHA256 checksums for verification and tracking
3. **Scanning**: Uses OSV-Scanner to check against the Open Source Vulnerabilities database
4. **Reporting**: Generates comprehensive reports with metadata, checksums, and vulnerability details
5. **Output**: Saves results in your specified format (JSON/SARIF/Table)

## Security

VSS uses [OSV-Scanner](https://github.com/google/osv-scanner) by Google, which queries the [OSV.dev](https://osv.dev) database containing vulnerability information from multiple sources including:

- GitHub Security Advisories
- npm Security Advisories
- Python Package Index (PyPI) Advisories
- RustSec Advisory Database
- And many more...

## Troubleshooting

Having issues? Check out the [Troubleshooting Guide](./TROUBLESHOOTING.md) for common problems and solutions.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](./CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## License

MIT License - see [LICENSE](./LICENSE) file for details.

## Support

- 📖 [Documentation](./README.md)
- 🐛 [Report Issues](https://github.com/kelleyblackmore/vss/issues)
- 💡 [Request Features](https://github.com/kelleyblackmore/vss/issues/new)
- 🔧 [Troubleshooting](./TROUBLESHOOTING.md)
- 🤝 [Contributing](./CONTRIBUTING.md)