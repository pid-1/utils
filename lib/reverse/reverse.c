#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]) {
   if (argc != 2) {
      printf("Requires a file path.\n");
      return 1;
   };

   FILE* file;
   if (strcmp(argv[1], "-") == 0) {
      file = stdin;
   } else {
      file = fopen(argv[1], "r");
      if (file == NULL) {
         printf("Can't open file.\n");
         return 2;
      }
   };

   fseek(file, 0, SEEK_END);

   long max_len = ftell(file);
   long EOL, SOL = max_len;

   while (ftell(file) >= 0) {
      fseek(file, -1, SEEK_CUR);
      int cur_char = getc(file);
      int cur_posgs = ftell(file);

      if (cur_char == '\n' && cur_posgs < max_len) {
         EOL = SOL;
         SOL = cur_posgs;
         while (ftell(file) < EOL) {
            putchar(getc(file));
         };
         fflush(file); // TODO--I don't know if this is necessary, look into it.
         fseek(file, SOL, SEEK_SET);
      } else if (cur_posgs == 1) {
         fseek(file, -1, SEEK_CUR);
         EOL = SOL;
         while (ftell(file) < EOL) {
            putchar(getc(file));
         };
         return 0;
      };

      fseek(file, -1, SEEK_CUR);
   };
};
