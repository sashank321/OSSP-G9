#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../include/builtin.h"

int execute_builtin(char **args)
{
    if(args[0] == NULL)
    {
        return 1;
    }

    if(strcmp(args[0], "exit") == 0)
    {
        printf("Goodbye!\n");
        exit(EXIT_SUCCESS);
    }

    if(strcmp(args[0], "pwd") == 0)
    {
        char cwd[1024];

        if(getcwd(cwd, sizeof(cwd)) != NULL)
        {
            printf("%s\n", cwd);
        }
        else
        {
            perror("LabRunner");
        }

        return 1;
    }

    if(strcmp(args[0], "cd") == 0)
    {
        if(args[1] == NULL)
        {
            fprintf(stderr, "LabRunner: expected argument to \"cd\"\n");
        }
        else if(chdir(args[1]) != 0)
        {
            perror("LabRunner");
        }

        return 1;
    }

    if(strcmp(args[0], "clear") == 0)
    {
        printf("\033[H\033[J");
        return 1;
    }

    if(strcmp(args[0], "help") == 0)
    {
        printf("LabRunner Built-in Commands:\n");
        printf("  cd <directory>  Change directory\n");
        printf("  pwd             Show current directory\n");
        printf("  help            Show this help message\n");
        printf("  clear           Clear the terminal\n");
        printf("  exit            Exit LabRunner\n");

        return 1;
    }

    if(strcmp(args[0], "env") == 0)
    {
        extern char **environ;
        char **env = environ;

        while(*env != NULL)
        {
            printf("%s\n", *env);
            env++;
        }

        return 1;
    }

    return 0;
}
