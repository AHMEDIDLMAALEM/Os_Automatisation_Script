#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int spawn(char *program, char **arg_list)
{
  
  pid_t child_pid;
  child_pid = fork();
  if (child_pid != 0)
  {
    // printf("PID du processus parent : %d\n", getpid());
    wait(NULL);
    return child_pid;
  }
  else
  {
    // execute program with arg_list[0] as argument list on linux
    // printf("PID du processus enfant : %d\n", getpid());
    // printf("in spawn with program : %s , and arglist %s\n", program,arg_list[0]);

    printf("execution a commence******************");
    execvp(program, arg_list);
    printf("execution a finie******************");
    // fprintf(stderr, "une erreur est survenue au sein de execvp\n");
    // abort();
  }
}

int main(int argc, char *argv[])
{

  
  if (argc < 2)
  {
    fprintf(stderr, "Usage: %s , %s <command>\n", argv[0], argv[1]);
    exit(EXIT_FAILURE);
  }

  char *arg_list[] = {
    "ourapp.sh", // The first argument is the program's name
    argv[1],
    NULL
  };
  // put ./ourapp.sh and the atgv[1] as a char *

  spawn("./ourapp.sh", arg_list);
  return 0;
}
