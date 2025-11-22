# Contributing to VSS

Thank you for considering contributing to the Vulnerability Scan Service (VSS)!

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion for improvement:

1. Check if the issue already exists in the [issue tracker](https://github.com/kelleyblackmore/vss/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment details (OS, runner, etc.)

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature/fix
3. Make your changes
4. Test your changes thoroughly
5. Update documentation as needed
6. Submit a pull request with:
   - Clear description of changes
   - Reference to any related issues
   - Example usage if applicable

### Testing Your Changes

Before submitting a PR, ensure:

1. The action runs successfully on both Ubuntu and macOS runners
2. All existing examples still work
3. Documentation is updated to reflect changes
4. No sensitive information is committed

### Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing patterns in the codebase
- Keep shell scripts portable (work on both Linux and macOS)

### Adding Support for New Package Types

To add support for a new package type:

1. Update the file type detection in `action.yml`
2. Add scan arguments for the new format
3. Add an example workflow in the `examples/` directory
4. Update README.md with the new format

## Questions?

Feel free to open an issue for questions or discussion about potential contributions.
