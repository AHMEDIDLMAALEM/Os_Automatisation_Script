#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>

int spawn(char *program, char **arg_list)
{
  
  pid_t child_pid;
  child_pid = fork();
  if (child_pid != 0)
  {
    // printf("PID du processus parent : %d\n", getpid());
    // printf("in spawn with program : %s , and arglist %s\n", program,arg_list[0]);
    // execvp(program, arg_list);
    wait(NULL);
    return child_pid;
  }
  else
  {
    // execute program with arg_list[0] as argument list on linux
    // printf("PID du processus enfant : %d\n", getpid());
    printf("in spawn with program : %s , and arglist %s , %s ,%s\n", program,arg_list[0],arg_list[1],arg_list[2]);

    printf("execution a commence******************");
    // concatenate arg_list 0 and 1 to form a single string
    char *args = malloc(strlen(arg_list[0]) + strlen(arg_list[1]) + 1);
    strcpy(args, arg_list[0]);
    strcat(args, arg_list[1]);
    arg_list[0] = args;


    execvp(program, &args);
    printf("execution a finie******************");
    // fprintf(stderr, "une erreur est survenue au sein de execvp\n");
    // abort();
  }
}

int main(int argc, char *argv[])
{

  for(int i = 0; i < argc; i++)
  {
    printf("argv[%d] = %s\n", i, argv[i]);
  }
  
  if (argc < 2)
  {
    fprintf(stderr, "Usage: %s , %s <command>\n", argv[0], argv[1]);
    exit(EXIT_FAILURE);
  }
  char *arg_list[5]; // Increase the size of the array to accommodate the maximum number of arguments

  if (argc > 2)
  {
    printf("argc > 2\n");
    arg_list[0] = "ourapp.sh"; // The first argument is the program's name
    arg_list[1] = argv[1];
    arg_list[2] = argv[2];
    arg_list[3] = argv[3]; // 
    arg_list[4] = NULL; // Add a NULL terminator at the end of the array
  }
  else
  {
    printf("argc = 2\n");
    arg_list[0] = "ourapp.sh"; // The first argument is the program's name
    arg_list[1] = argv[1];
    arg_list[2] = NULL; // Add a NULL terminator at the end of the array
  }
  

  
  // put ./ourapp.sh and the atgv[1] as a char *

  spawn("./ourapp.sh", arg_list);
  return 0;
}
