#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define Number 64
#define Maximum 65536

void main(){
    int input, weight, output;
    FILE *FILE_input;
    FILE *FILE_weight;
    FILE *FILE_output;
    FILE_input = fopen("input.txt", "w+");
    FILE_weight = fopen("weight.txt", "w+");
    FILE_output = fopen("output.txt", "w+");
    srand(time(NULL));
    for(int i = 0; i < Number; i++){
        input = rand()%Maximum;
        weight = rand()%Maximum;
        output = rand()%Maximum;
        fprintf(FILE_input,  "%d\n", input);
        fprintf(FILE_weight, "%d\n", weight);
        fprintf(FILE_output, "%d\n", output);
    }

    fclose(FILE_input);
    fclose(FILE_weight);
    fclose(FILE_output);
    return 0;
}
