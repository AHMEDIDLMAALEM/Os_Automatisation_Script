#include  <stdio.h>
#include  <stdlib.h>
#include  <sys/types.h>
#include  <sys/wait.h>
#include  <unistd.h>

int spawn(char* program, char** arg_list)
{
  pid_t child_pid;
  child_pid = fork ();
  if (child_pid != 0){
     printf("PID du processus parent : %d\n", getpid());
     wait(NULL);
     return child_pid;
  }
  else {
     printf("PID du processus fils : %d\n", getpid());
     execvp (program, arg_list);
     fprintf (stderr, "une erreur est survenue au sein de execvp\n");
     abort ();
  }
}

int main(int argc, char *argv[])
{
  if (argc != 2) {
    fprintf(stderr, "Utilisation Incorecte \n", argv[0]);
    exit(EXIT_FAILURE);
  }

  char* arg_list[] = {
     "./ourapp.sh",     
     argv[1],   
     NULL
  };

  spawn("./ourapp.sh", arg_list);
  return 0;
}
