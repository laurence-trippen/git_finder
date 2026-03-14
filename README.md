# 🔍 Git Finder

A fast, cross-platform console application that finds Git repositories and analyzes their status for uncommitted changes and unpushed commits.

## ✨ Features

- 🚀 **Parallel Search** - Scans multiple directories simultaneously
- 🎯 **Smart Path Resolution** - Automatically removes redundant subdirectory paths
- 🔍 **Status Detection** - Identifies uncommitted changes and unpushed commits
- 🎨 **Color-Coded Output** - Visual status indicators for quick scanning
- 💻 **Cross-Platform** - Works on macOS, Linux, and Windows
- ⚡ **Fast Performance** - Parallel execution for maximum speed

## 📋 Requirements

- Dart SDK ^3.8.1
- Git installed on your system

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/laurence-trippen/git_finder.git
cd git_finder
```

2. Install dependencies:
```bash
dart pub get
```

3. (Optional) Compile to executable:
```bash
dart compile exe bin/git_finder.dart -o git_finder
```

## 📖 Usage

### Basic Usage

Scan one or more directories for Git repositories:

```bash
dart run bin/git_finder.dart /path/to/search
```

### Multiple Paths

Search multiple directories at once:

```bash
dart run bin/git_finder.dart ~/projects ~/work ~/personal
```

### Using Compiled Executable

```bash
./git_finder ~/projects ~/work
```

## 📊 Example Output

```
 Git Finder

found git binary!

Searching in 3 path(s)...

Optimized to 2 path(s) after removing subdirectories

Scanning: /Users/laurence/projects
  ✓ Found 5 repository/repositories
Scanning: /Users/laurence/work
  ✓ Found 3 repository/repositories

==================================================
Summary:
  Paths searched: 2
  Successful: 2
  Failed: 0
  Total repositories found: 8
==================================================

Analyzing repositories...

Repository Status:

  ⚠ /Users/laurence/projects/my-app
    unpushed commits
  ○ /Users/laurence/projects/website
    uncommitted changes
  ✓ /Users/laurence/projects/api
    clean
  ✓ /Users/laurence/projects/cli-tool
    clean
  ○ /Users/laurence/projects/library
    uncommitted changes
  ⚠ /Users/laurence/work/client-project
    unpushed commits
  ✓ /Users/laurence/work/internal-tool
    clean
  ✓ /Users/laurence/work/docs
    clean

Status Summary:
  ✓ Clean: 4
  ○ Uncommitted changes: 2
  ⚠ Unpushed commits: 2

done!
```

## 🎨 Status Indicators

| Icon | Color | Status | Description |
|------|-------|--------|-------------|
| ✓ | 🟢 Green | Clean | No uncommitted changes or unpushed commits |
| ○ | 🟡 Yellow | Uncommitted | Has uncommitted changes |
| ⚠ | 🔴 Red | Unpushed | Has unpushed commits |

**Priority:** Red (unpushed) > Yellow (uncommitted) > Green (clean)

## 🛠️ Development

### Run Tests

```bash
dart test                          # Run all tests
dart test test/path_test.dart      # Run specific test file
```

### Linting

```bash
dart analyze
```

### Run in Development

```bash
dart run bin/git_finder.dart <path1> [path2] ...
```

## 🏗️ Architecture

```
git_finder/
├── bin/
│   ├── git_finder.dart      # Entry point
│   └── sys_exit.dart        # Exit codes
├── lib/
│   ├── git.dart             # Git operations
│   ├── git_repo_finder.dart # Repository discovery
│   ├── logger.dart          # Logging utilities
│   └── path.dart            # Path resolution
└── test/
    ├── git_finder_test.dart
    └── path_test.dart
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Links

- Repository: [github.com/laurence-trippen/git_finder](https://github.com/laurence-trippen/git_finder)
- Issues: [github.com/laurence-trippen/git_finder/issues](https://github.com/laurence-trippen/git_finder/issues)

---

Made with ❤️ by Laurence Trippen
