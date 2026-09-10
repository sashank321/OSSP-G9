# LabRunner Architecture & Design Specification

## Overview

**LabRunner** is a POSIX-compliant modular execution and monitoring environment built in C. It serves as an educational and practical systems programming shell designed to demonstrate core operating system concepts including memory management, process lifecycle, tokenization, file descriptor manipulation, and IPC.

---

## Component Architecture

```
                    +--------------------------------+
                    |           User Input           |
                    +--------------------------------+
                                   |
                                   v
                    +--------------------------------+
                    |      Input Module (input.c)    |
                    |  - Dynamic line buffer         |
                    |  - malloc() / realloc()        |
                    +--------------------------------+
                                   |
                                   v
                    +--------------------------------+
                    |    Parser Module (parser.c)    |
                    |  - strtok() tokenization       |
                    |  - Dynamic argv[] vector       |
                    +--------------------------------+
                                   |
                                   v
                    +--------------------------------+
                    |      REPL Loop (main.c)        |
                    |  - Display parsed arguments    |
                    |  - Memory deallocation         |
                    +--------------------------------+
```

---

## Core Modules

### 1. Interactive REPL (`src/main.c`)
- **Header:** `include/labrunner.h`
- **Responsibilities:**
  - Initialize the shell session and print the banner with version details.
  - Maintain the continuous prompt loop (`labrunner> `).
  - Intercept built-in control commands (such as `exit`).
  - Coordinate invocation of the input reader and parser.
  - Guarantee cleanup of heap memory allocated during each REPL iteration.

### 2. Dynamic Input Reader (`src/input.c`)
- **Header:** `include/input.h`
- **Responsibilities:**
  - Dynamically captures arbitrary-length input streams from standard input (`stdin`) character-by-character via `getchar()`.
  - Begins with an initial buffer allocation of `INITIAL_SIZE` (64 bytes).
  - Automatically expands the allocation using `realloc()` by doubling the buffer capacity whenever the cursor reaches the current boundary.
  - Detects newline (`\n`) and end-of-file (`EOF`) conditions, null-terminating the resulting string safely.

### 3. Modular Parser (`src/parser.c`)
- **Header:** `include/parser.h`
- **Responsibilities:**
  - Tokenizes raw input strings into individual arguments using POSIX whitespace delimiters (`" \t\r\n\a"`).
  - Allocates a null-terminated pointer array (`argv[]`) starting with `TOKEN_SIZE` (64 pointers).
  - Doubles the token array dynamically via `realloc()` if argument count exceeds the current array bounds.
  - Provides `free_tokens()` to safely release the allocated pointer table without altering the token references.

---

## Memory Management Lifecycle

```
[ REPL Start ]
      |
      v
line = read_line()      --> malloc(64) -> realloc(...) -> returns heap pointer
      |
      v
tokens = parse_line()   --> malloc(64 * sizeof(char*)) -> returns token array
      |
      v
[ Processing / Execution ]
      |
      v
free_tokens(tokens)     --> Releases token pointer vector
free(line)              --> Releases input line buffer
      |
      v
[ Next Iteration ]
```

---

## Planned OS Roadmap

| Week / Milestone | Target OS Feature | Key System Calls |
| :--- | :--- | :--- |
| **Week 4** | Process Creation & Execution | `fork()`, `execvp()`, `waitpid()` |
| **Week 5** | Built-in Shell Commands | `chdir()`, `getcwd()`, internal dispatch table |
| **Week 6** | I/O Redirection | `open()`, `dup2()`, `close()` |
| **Week 7** | Pipelines | `pipe()`, `fork()`, `dup2()` |
| **Week 8** | Signal Handling & Job Control | `sigaction()`, `kill()`, `SIGINT`, `SIGTSTP` |
