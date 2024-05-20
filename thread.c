#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>



void *thread_function(void *arg)
{
  char **arg_list = (char **)arg;
  printf("in thread with program: ./ouraapp, and arglist: %s, %s, %s\n", arg_list[0], arg_list[1], arg_list[2]);

  // concatenate arg_list 0 and 1 to form a single string
  char *args = malloc(strlen(arg_list[1]) + strlen(arg_list[2]) + 1);
  strcpy(args, arg_list[1]);
  strcat(args, arg_list[2]);
  arg_list[0] = args;

  execvp("./ourapp", arg);
  printf("execution has finished******************");
  fprintf(stderr, "an error occurred within execvp\n");
  pthread_exit(NULL);
}

int spawn(char *program, char **arg_list)
{
  pthread_t thread;
  int result = pthread_create(&thread, NULL, thread_function, (void *)arg_list);
  if (result != 0)
  {
    fprintf(stderr, "failed to create thread\n");
    return -1;
  }

  result = pthread_join(thread, NULL);
  if (result != 0)
  {
    fprintf(stderr, "failed to join thread\n");
    return -1;
  }

  return 0;
}


int main(int argc, char *argv[])
{
  
  
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
    arg_list[3] = NULL; // Add a NULL terminator at the end of the array
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
