# Changelog

All notable changes to the **LabRunner** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Process creation and execution engine using `fork()` and `execvp()`.
- Process synchronization and state monitoring using `waitpid()`.
- Built-in command dispatcher (e.g., `cd`, `help`, `status`, `history`).
- Standard I/O redirection (`<`, `>`, `>>`) via `dup2()`.
- Inter-process communication pipelines (`|`) using `pipe()`.
- Signal handling for `SIGINT` (Ctrl+C) and background process tracking.

---

## [3.0.0] - 2026-09-09

### Added
- Modular command parser in `src/parser.c` with header `include/parser.h`.
- String tokenization utilizing POSIX standard delimiters (`" \t\r\n\a"`) via `strtok()`.
- Dynamic null-terminated argument array (`argv[]`) construction with initial capacity of 64 tokens.
- Automatic reallocation (`realloc()`) with doubling capacity when token count exceeds current buffer size.
- Memory deallocation routine `free_tokens()` for dynamic token vector cleanup.
- Iterative argument inspection display in `src/main.c`.
- Updated `VERSION` macro to `3.0` in `include/labrunner.h`.

---

## [2.0.0] - 2026-08-20

### Added
- Dynamic line input module in `src/input.c` with header `include/input.h`.
- Resizable input buffer starting at 64 bytes using dynamic memory allocation (`malloc()`).
- Dynamic buffer scaling (`realloc()`) on demand to handle arbitrary length user commands safely without buffer overflow vulnerabilities.
- Character-by-character input acquisition handling `\n` and `EOF` delimiters.
- Memory cleanup (`free()`) for input buffers in the REPL cycle.

---

## [1.0.0] - 2026-08-20

### Added
- Initial project scaffolding for LabRunner Linux-based laboratory runner.
- Core Read-Eval-Print Loop (REPL) interactive shell in `src/main.c`.
- Interactive command prompt (`labrunner> `).
- Graceful termination mechanism when receiving the `exit` command.
- Build automation with standard POSIX `Makefile` supporting `all`, `run`, and `clean` targets.
- Project documentation outlining LabRunner architecture and OS systems programming objectives in `README.md`.
