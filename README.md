	
# LabRunner

LabRunner is a Linux-based laboratory execution and monitoring system developed as part of the Operating Systems and Systems Programming project.

## Week 1 Features

- Interactive REPL loop
- Makefile-based build
- Linux development environment
- Git repository

## Week 2 Features

- Dynamic command input
- Memory allocation using malloc()
- Automatic buffer expansion using realloc()
- Proper memory cleanup using free()

## Week 3 Features

- Command parsing using strtok()
- Dynamic argv[] construction
- Modular parser implementation
- Ready for process execution with execvp()

## Week 4 Features

- Process creation using fork()
- Command execution using execvp()
- Parent-child synchronization using waitpid()
- Error handling using perror()

## Week 5 Features

- Built-in command support
- cd
- pwd
- help
- clear
- exit
- Environment variables

## Week 6 Features

- Signal handling
- SIGINT support
- SIGCHLD support
- Zombie process cleanup
- Shell survives Ctrl+C

## Week 7 Features

- Anonymous pipes (`pipe()`)
- Input/output redirection between processes (`dup2()`)
- Two-command pipelines (`cmd1 | cmd2`)
- Inter-Process Communication (IPC) using file descriptors

## Week 8 Features

- Memory leak detection using Valgrind
- Debugging support with GDB flags (`-g`)
- AddressSanitizer (`asan`) build target in Makefile
- Defensive programming practices & system call error checks
- Improved resource cleanup and process handling

## Week 9 Features

- File descriptor management
- Output redirection (`>`)
- Input redirection (`<`)
- Append redirection (`>>`)
- Error redirection (`2>`)
- File handling using `open()`, `close()`, and `dup2()`

## Week 10 Features

- POSIX thread support
- Background monitoring thread
- `pthread_create()` & `pthread_detach()` / `pthread_join()`
- Mutex synchronization principles
- Race condition awareness & dynamic concurrency


## LabRunner Architecture

LabRunner is a Linux-based laboratory execution and monitoring system developed in **C for Linux** using **POSIX system calls and APIs**. It provides an interactive command-line environment for executing and managing laboratory programs while implementing core Operating System concepts such as process creation, process synchronization, pipes, I/O redirection, signals, job control, multithreading, and resource monitoring.

> **LabRunner is an educational implementation built to understand and demonstrate how Linux processes, system calls, and resource management work in a laboratory execution environment.**

---

## Why LabRunner?

Linux already provides powerful shells such as Bash. However, many of the Operating System mechanisms involved in executing a command remain hidden from the user.

For example, when a user enters:

```bash
ls
                         USER
                          |
                          v
                  +---------------+
                  |   LabRunner   |
                  |      Shell    |
                  +-------+-------+
                          |
                          v
                   Command Parser
                          |
              +-----------+-----------+
              |                       |
              v                       v
        Built-in Command       External Command
              |                       |
              v                     fork()
          Execute                    /   \
                                   /     \
                              Parent       Child
                                |            |
                            waitpid()      execvp()
                                |            |
                                |         Program
                                |            |
                                +-----+------+
                                      |
                                      v
                                    Output


                 +-------------------------+
                 |    Process Manager      |
                 |                         |
                 | fork / exec / waitpid   |
                 | pipes / redirection     |
                 | signals / job control  |
                 +-------------------------+

                 +-------------------------+
                 |    Resource Monitor     |
                 |                         |
                 | /proc                    |
                 | CPU                      |
                 | Memory                   |
                 | Processes                |
                 | Threads + Mutex         |
                 +-------------------------+
                 

