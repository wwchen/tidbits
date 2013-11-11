// This is uncompiled, hence untested
// Reversing a linked list

#include <string>
#include <stdlib.h>

using namespace std;

struct Node { 
  int value;
  Node * next;
}

void reverse_linkedlist(Node * root) {
  Node * ptr = root, prev = null;
  while (ptr != null) {
    Node * tmp = ptr;
    ptr->next = prev;
    prev = tmp;
    ptr = tmp->next;
  }
}
