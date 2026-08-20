
# LabRunner

LabRunner is a Linux-based laboratory execution and monitoring system developed as part of the Operating Systems and Systems Programming project.

## Week 1 Features

- Interactive REPL loop
- Makefile-based build
- Linux development environment
- Git repository

# OSSP-G9
# SysPilot
## A Modular Unix Shell with Process Management and System Monitoring

SysPilot is a custom Unix shell developed in **C for Linux** using **POSIX system calls and APIs**. It provides an interactive command-line environment for executing Linux commands while implementing core Operating System concepts such as process creation, process synchronization, pipes, I/O redirection, signals, job control, multithreading, and resource monitoring.

> **SysPilot is not intended to replace Bash. It is an educational implementation built to understand and demonstrate how a Unix shell interacts with the Operating System.**

---

## Why SysPilot?

Linux already provides powerful shells such as Bash. However, many of the Operating System mechanisms involved in executing a command remain hidden from the user.

For example, when a user enters:

```bash
ls
                         USER
                          |
                          v
                  +---------------+
                  |    SysPilot   |
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
                 

