#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../include/labrunner.h"
#include "../include/input.h"
#include "../include/parser.h"
#include "../include/process.h"
#include "../include/builtin.h"
#include "../include/signals.h"
#include "../include/pipes.h"
#include "../include/redirect.h"

static void tokenize(char *str, char **argv)
{
    int i = 0;
    char *token = strtok(str, " \t\n");
    while (token != NULL)
    {
        argv[i++] = token;
        token = strtok(NULL, " \t\n");
    }
    argv[i] = NULL;
}

int main()
{
    char *line;
    char **tokens;

    printf("=====================================\n");
    printf("%s Version %s\n", LABRUNNER_NAME, VERSION);
    printf("=====================================\n");
    initialize_signals();

    while(1)
    {
        printf("labrunner> ");

        line = read_line();

        if (strchr(line, '|') != NULL)
        {
            char *argv1[64];
            char *argv2[64];
            char *left = strtok(line, "|");
            char *right = strtok(NULL, "|");

            if (left == NULL || right == NULL)
            {
                printf("Invalid pipe command\n");
                free(line);
                continue;
            }

            tokenize(left, argv1);
            tokenize(right, argv2);
            execute_pipe(argv1, argv2);
        }
        else
        {
            if (strcmp(line, "exit") == 0)
            {
                free(line);
                break;
            }

            tokens = parse_line(line);

            if (execute_builtin(tokens) == 0)
            {
                if (execute_redirection(tokens) == 0)
                {
                    execute(tokens);
                }
            }

            free_tokens(tokens);
        }
        free(line);
    }

    printf("Goodbye!\n");

    return 0;
}

