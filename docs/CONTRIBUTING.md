# Contributing to LabRunner (OSSP-G9)

Thank you for contributing to the **LabRunner** Operating Systems and Systems Programming project! To maintain high code quality and collaboration standards, please review the following guidelines before submitting code.

---

## 1. Development Guidelines

- **Language Standard:** ANSI C / POSIX standard (C99 or C11 compatible).
- **Target OS:** Linux (Ubuntu 20.04+ LTS recommended).
- **Compiler:** `gcc` with flags `-Wall -Wextra -g -Iinclude`.
- **Formatting:** 4-space indentation, consistent K&R or Allman brace style, descriptive variable naming.

---

## 2. Memory Safety & Resource Management

Since LabRunner operates as a long-running process (REPL), memory leaks and undefined behavior must be strictly prevented:

- Any buffer allocated with `malloc()` or `realloc()` must have an unambiguous and guaranteed `free()` path.
- Check all return values from system calls and memory allocators:
  ```c
  char *buf = malloc(size);
  if (buf == NULL) {
      perror("malloc");
      exit(EXIT_FAILURE);
  }
  ```
- Before pushing changes, verify zero memory leaks with **Valgrind**:
  ```bash
  printf "exit\n" | valgrind --leak-check=full --error-exitcode=1 ./bin/labrunner
  ```

---

## 3. Testing Local Changes

Always run the automated test suite before creating a pull request:

```bash
# Compile the project
make clean && make all

# Run the test runner
chmod +x tests/test_runner.sh
./tests/test_runner.sh
```

Ensure all tests pass with zero failures.

---

## 4. Git Commit Guidelines

Write clear, structured commit messages describing the milestone and rationale:

- **Format:** `<Milestone/Scope>: <Short description>`
- **Examples:**
  - `Week 3: Add modular command parser using strtok`
  - `Docs: Add POSIX architecture and system call roadmap`
  - `CI: Configure automated build and test runner workflow`

---

## 5. Pull Request Workflow

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/week-4-process-execution
   ```
2. Commit your modular changes.
3. Verify that CI passes on your branch.
4. Request review from project team members before merging into `main`.
