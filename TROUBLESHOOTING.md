# Troubleshooting VSS

Common issues and solutions for the Vulnerability Scan Service.

## Installation Issues

### OSV-Scanner fails to install

**Problem**: Error downloading or installing OSV-Scanner

**Solutions**:
1. Ensure your runner has internet access
2. Check if Go is available on the runner (recommended)
3. Verify the runner's architecture is supported (amd64, arm64)

**Example fix**:
```yaml
- name: Setup Go
  uses: actions/setup-go@v5
  with:
    go-version: '1.21'

- name: Run VSS
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
```

## Scanning Issues

### "No package sources found" error

**Problem**: OSV-Scanner cannot find packages to scan

**Possible causes**:
1. Target file is not a recognized lock file format
2. File path is incorrect
3. File is excluded by .gitignore

**Solutions**:
1. Use lock files (package-lock.json, not package.json)
2. Verify the file path is correct
3. Check file format is supported by OSV-Scanner

**Supported formats**:
- npm: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Python: `requirements.txt`, `Pipfile.lock`, `poetry.lock`, `uv.lock`
- Go: `go.mod`, `go.sum`
- Ruby: `Gemfile.lock`
- Rust: `Cargo.lock`

### Network timeout errors

**Problem**: API query failed or timeout

**Solution**: OSV-Scanner requires internet access to query the vulnerability database.

**Workaround**:
```yaml
- name: Scan with retry
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
  timeout-minutes: 10
  continue-on-error: true
```

### File not found errors

**Problem**: Target file doesn't exist

**Solution**: Ensure files are checked out and paths are correct

```yaml
- uses: actions/checkout@v4  # Must checkout first!

- name: Verify file exists
  run: |
    if [ ! -f "package-lock.json" ]; then
      echo "File not found!"
      exit 1
    fi

- name: Run scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
```

## Output Issues

### Report file not generated

**Problem**: Output file is missing

**Possible causes**:
1. Scan failed before completion
2. Permission issues
3. Invalid output path

**Solution**:
```yaml
- name: Run scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
    output-file: './reports/scan.json'  # Ensure directory exists
  continue-on-error: true

- name: Create directory if needed
  run: mkdir -p ./reports

- name: Check if report exists
  run: |
    if [ -f "./reports/scan.json" ]; then
      echo "Report found"
      cat ./reports/scan.json | jq '.summary'
    else
      echo "Report not generated"
    fi
```

### JSON parsing errors

**Problem**: Invalid JSON in report file

**Solution**: This usually indicates a scan error. Check the action logs for details.

## Platform-Specific Issues

### macOS: stat command differences

**Problem**: File size detection fails on macOS

**Solution**: The action handles this automatically with fallback commands.

### Windows: Unsupported

**Problem**: Action doesn't work on Windows runners

**Current status**: VSS is designed for Linux and macOS runners. Windows support is not currently available.

**Workaround**: Use `runs-on: ubuntu-latest` instead of Windows runners.

## Performance Issues

### Slow scans

**Problem**: Scans take too long

**Solutions**:
1. Use lock files instead of scanning entire directories
2. Increase timeout settings
3. Scan specific files instead of recursive directory scans

```yaml
- name: Fast scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'  # Specific file, faster
  timeout-minutes: 5
```

## Integration Issues

### SARIF upload fails

**Problem**: Cannot upload SARIF to GitHub Security tab

**Solution**: Ensure proper permissions are set

```yaml
jobs:
  scan:
    permissions:
      security-events: write  # Required!
      contents: read
    steps:
      # ... scan steps
```

### Artifact upload issues

**Problem**: Cannot upload scan reports

**Solution**: Verify file paths and ensure files exist

```yaml
- name: Upload report
  uses: actions/upload-artifact@v4
  if: always()  # Upload even if scan fails
  with:
    name: scan-report
    path: |
      vss-report.json
      results.sarif
    if-no-files-found: warn  # Don't fail if missing
```

## Getting Help

If you continue to experience issues:

1. Check the [GitHub Actions logs](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/using-workflow-run-logs) for detailed error messages
2. Review the [examples](./examples/) directory for working configurations
3. Open an issue on [GitHub](https://github.com/kelleyblackmore/vss/issues) with:
   - Your workflow file
   - Full error logs
   - Environment details (runner OS, etc.)
   - Steps to reproduce

## Debug Mode

Enable verbose logging for troubleshooting:

```yaml
- name: Debug scan
  uses: kelleyblackmore/vss@v1
  with:
    target: 'package-lock.json'
  env:
    ACTIONS_STEP_DEBUG: true
```
