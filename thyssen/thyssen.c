#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>


int main(int argc, char *argv[])
{
  if (argc<3)
  {
    fprintf(stderr,"Missing command-line argument, syntax: thyssen <input> <output>\n");
    return 1;
  }

  char cFilenameIN[50];
  strcpy(cFilenameIN,argv[1]);
  char cFilenameOUT[50];
  strcpy(cFilenameOUT,argv[2]);

  int  AnzahlGanzzahlen;
  int* Ganzzahlen;
  
  
  FILE* finput = fopen(cFilenameIN,"r");
  if (finput == NULL)
  {
    fprintf(stderr,"Datei %s kann nicht geoeffnet werden.\n",cFilenameIN);
    return 1;
  }  
  FILE* foutput = fopen(cFilenameOUT,"w");
  if (foutput == NULL)
  {
    fprintf(stderr,"Datei %s kann nicht geoeffnet werden.\n",cFilenameOUT);
    return 1;
  }  

  fscanf(finput,"Anzahl Ganzzahlen %d",&AnzahlGanzzahlen);
  Ganzzahlen = (int*) calloc(sizeof(int),AnzahlGanzzahlen);
  
  for (int i=0;i<AnzahlGanzzahlen;i++)
    fscanf(finput,"%d",&Ganzzahlen[i]);

  sleep(20);

  printf("Anzahl der Ganzzahlen = %d\n",AnzahlGanzzahlen);
  for (int i=0;i<AnzahlGanzzahlen;i++)
  {
    printf("Zerlege Ganzzahl Nr. %6d von %6d: %d\n",i+1,AnzahlGanzzahlen,Ganzzahlen[i]);
    fprintf(foutput,"\n%20d : ",Ganzzahlen[i]);
    int Rest = Ganzzahlen[i];
    while (Rest > 1)
      for (int j=2; j<=Rest; j++)
        if (Rest % j == 0)
        {
          fprintf(foutput,"%d ",j);
          Rest = Rest / j;
          break;
        }
  }
  fclose(finput);  
  fclose(foutput);
  return 0;
}

