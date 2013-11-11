// This is uncompiled, hence untested
// Reversing a linked list
// This implementation will have undesired effects when the linked list is not linear, i.e. circular
// linked list

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

/* Test cases
 * empty linked list
 * list with only one node
 * list with nodes with the same values
 * single self directed node (i.e. next is pointed to itself)
 * circular list
 */
