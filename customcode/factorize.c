#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
  if (argc<3) {
    fprintf(stderr,"Missing command-line argument, syntax: %s <input> <output>\n",argv[0]);
    exit(1);
  }

  char cFilenameIN[50];
  strcpy(cFilenameIN,argv[1]);
  char cFilenameOUT[50];
  strcpy(cFilenameOUT,argv[2]);

  FILE* finput = fopen(cFilenameIN,"r");
  if (finput == NULL) {
    fprintf(stderr,"Cannot open file %s.\n",cFilenameIN);
    exit(1);
  }  
  FILE* foutput = fopen(cFilenameOUT,"w");
  if (foutput == NULL) {
    fprintf(stderr,"Cannot open file %s.\n",cFilenameOUT);
    exit(1);
  }

  int number;
  int counter=0;
  while (!feof(finput)) {
    if (fscanf(finput,"%d",&number)==1) {
      fprintf(foutput,"\n%20d : ",number);
      counter++;
      int rest = number;
      while (rest > 1)
        for (int j=2; j<=rest; j++)
          if (rest % j == 0) {
            fprintf(foutput,"%d ",j);
            rest = rest / j;
            break;
          }
    } else { 
	  if (feof(finput)) break;
      fprintf(stderr,"Invalid input at token #%d\n",counter+1);
      if (counter>0) printf("Processed %d numbers\n",counter);
      exit(2);
    }  
  }
  printf("Processed %d numbers\n",counter);
  fclose(finput);  
  fclose(foutput);
  return 0;
}

