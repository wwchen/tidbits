#include <stdio.h>
#include <stdlib.h>

/* Computes N-1 digits of e */
#define N 1000

//main(i, j, q) {
main() {
  int i=0, j=0, q=0;
  int A[N];
  printf("2.");
  for(j=0; j<N; j++)
    A[j] = 1;

  for(i=0; i<N-2; i++) {
    q=0;
    for(j=N-1; j>=0; ) {
      A[j] = 10*A[j]+q;
      q = A[j]/(j+2);

      A[j] %= (j+2);
      j--;
    }
    putchar(q+48);
  }
  printf("\n");
}
