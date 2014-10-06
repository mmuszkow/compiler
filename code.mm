// since we don't have the Byte type, routines are written in assembler
class StrUtils {
    def String int2str(Int i) {
        String buff = "                           ";
        String fmt = "%d";
        asm("  push dword [ebp+8]"); // i
        asm("  push dword [ebp-12]"); // buff
        asm("  push dword [ebp-8]"); // fmt
        asm("  call [sprintf]");
        asm("  add esp, 12");
        return buff;
    }
    
    def Int len(String s) {
        asm("  mov ebx, [ebp+8]");
        asm("  xor eax, eax");
        asm("strlen_loop:");
        asm("  cmp [ebx], byte 0");
        asm("  je strlen_end");
        asm("  inc eax");
        asm("  inc ebx");
        asm("  jmp strlen_loop");
        asm("strlen_end:");
    }
    
    /*def String concat(String s1, String s2) {
        Int concated = call len(s1) + call len(s2) + 1;
        asm("  mov eax, [var_StrUtils_concat_concated]");
        asm("  call gc_malloc");
        asm("  mov ebx, [ebp+12]");
        asm("concat_loop_1:");
        asm("  cmp [ebx], byte 0");
        asm("  je concat_loop_2");
        asm("  mov [eax], byte [ebx]");
        asm("  inc ebx");
        asm("  inc eax");
        asm("  jmp concat_loop_1");
        asm("concat_2:");
        asm("  mov ebx, [ebp+8]");
        asm("concat_loop_2:");
        asm("  cmp [ebx], byte 0");
        asm("  je concat_end");
        asm("  mov [eax], byte [ebx]");
        asm("  inc ebx");
        asm("  inc eax");
        asm("  jmp concat_loop_1");
        asm("concat_end:");
        asm("  mov [eax], byte 0");
    }*/
}

class Point {
    Int x, y;
    
    def Void init(Int _x, Int _y) {
        x = _x;
        y = _y;
    }
    
    def Int distance(Point p2) {
        Math m = new Math;
        return call m.abs(x - p2.x) + call m.abs(y - p2.y);
    }
}

class Math {
    def Int abs(Int val) {
        if(val < 0) return val * -1;
        return val;
    }
    
    // exp >= 0
    def Int power(Int base, Int exp) {
        Int ret = 1;
        while(exp > 0) {
            if(exp & 1) {
                ret = ret * base;
                exp = exp - 1;
            }
            base = base * base;
            exp = exp / 2;
        }
        return ret;
    }
}

// I removed the array type from the grammar to make it simpler
class Array {
    String ptr; // this will be the pointer
    Int len;
    
    def Void init(Int _len) {
        len = _len;
        asm("  mov eax, [ebp+8]");
        asm("  shl eax, 2"); // * WORD_SIZE
        asm("  call gc_malloc");
        asm("  mov ebx, [ebp+12]");
        asm("  mov [ebx], eax");
    }
    
    def Int get(Int index) {
        asm("  mov eax, [ebp+8]");
        asm("  mov ebx, [ebp+12]");        
        asm("  add ebx, eax");
        asm("  mov eax, [ebx]");
    }
}

class IO {
    // prints string to stdout with new line
    def Void puts(String s) {
        asm("  push dword [ebp+8]");
        asm("  call [puts]");
        asm("  add esp, 4");
    }
    
    // prints string to stdout
    def Void printf(String s) {
        asm("  push dword [ebp+8]");
        asm("  call [printf]");
        asm("  add esp, 4");
    }
    
    // returns integer from stdin
    def Int scani() {
        Int i;
        String fmt = "%d";
        asm("  push dword [ebp-12]"); // i
        asm("  push dword [ebp-8]"); // fmt
        asm("  call [scanf]");
        asm("  add esp, 8");
        return i;
    }
    
    // returns string read from stdin
    def String scans(Int max) {
        String fmt = "%s";
        asm("  mov eax, [ebp+8]");
        asm("  call gc_malloc");
        asm("  push eax");
        asm("  push dword [ebp-8]"); // fmt
        asm("  call [scanf]");
        asm("  pop eax");
        asm("  pop eax");
    }
}

class TestClass {   
    def Int test_break_continue() {
        Int i = 1;
        Int sum = 0;
        while(i <= 5) { // 1 + 2 + 3 = 6
            if(i == 4) break;
            sum = sum + i;            
            i = i + 1;
        }
        
        i = 1;
        while(i <= 5) { // 6 + 1 + 2 + 3 + 5 = 17
            if(i == 4) {
                i = i + 1;
                continue;
            }
            sum = sum + i;            
            i = i + 1;
        }
        
        for(i = 1; i <= 5; i = i + 1;) { // 17 + 1 + 2 + 3 = 23
            if(i == 4) break;
            sum = sum + i;
        }
        
        for(i = 1; i <= 5; i = i + 1;) { // 23 + 1 + 2 + 3 + 5 = 34
            if(i == 4) continue;
            sum = sum + i;
        }
        
        return sum;
    }
    
    def Bool test_logic() {
        Bool eq_val = (1 == 1);
        Bool neq_val = (1 != 2);
        Bool gt_val = (4 > 3);
        Bool lt_val = (-10 < 8);        
        return (eq_val && neq_val && gt_val && lt_val); // expected: True
    }
    
    def Int test_if() { // expected: 666
        if((2 + 2) == 4)
            return 666;
        else
            return 777;
    }
    
    def Int test_while() { // expected 100
        Int i = 0;
        while(i != 100)
            i = i + 1;
        return i;
    }
    
    def Int test_arith() { // -8 expected
        return (((2 * 3) + (1 - 3)) * -2);
    }
    
    def Int test_for() { // 13 expected
        Int fib1, fib2, fib3, n;
        fib1 = 1;
        fib2 = 1;
        for(n = 1; n <= 5; n = n + 1;) {        
            fib3 = fib1 + fib2;
            fib1 = fib2;
            fib2 = fib3;
        }
        return fib3;
    }
    
    def Int test_switch() { // 1 expected
        Int z = 2;
        switch(z) {
            case 0: return -1;
            case 1: return 0;
            case 2: return 1;
            default: return -2;
        }
    }
    
    def Int test_method_arg(Int first, Int second, Int third) {
        return third;
    }
    
    def Int test_class() {
        Point p1 = new Point, p2 = new Point;
        call p1.init(-2, 4);
        call p2.init(5, 1);
        return call p1.distance(p2);
    }
    
    def Void test_gc() {
        Int n = 1;
        while(n < 10000) {
            Point p = new Point;
            n = n + 1;
        }
    }
}

class LinkedListNode {
    Int val;
    LinkedList next;
    
    def Void init(Int _val) {
        val = _val;
        next = cast<LinkedList>(0);
    }
}

class LinkedList {
    LinkedListNode head, tail;
    
    def Void init() {
        head = cast<LinkedList>(0);
        tail = cast<LinkedList>(0);
    }
    
    def Void add(Int val) {
        LinkedListNode new_tail = new LinkedListNode;
        call new_tail.init(val);
        if(head == cast<LinkedListNode>(0))
            head = new_tail;
        else
            tail.next = new_tail;
        tail = new_tail;
    }
    
    def Void print() {
        IO io = new IO;
        StrUtils su = new StrUtils;
        LinkedListNode tmp = head;
        while(tmp != cast<LinkedListNode>(0)) {
            call io.printf(call su.int2str(tmp.val));
            call io.printf(" ");
            tmp = tmp.next;
        }
        call io.puts("");
    }
}

class BstNode {
    Int val;
    BstNode left, right;
    
    def Void init(Int _val) {
        val = _val;
        left = cast<BstNode>(0);
        right = cast<BstNode>(0);
    }
}

class Bst {
    BstNode root;
    
    def Void init() {
        root = cast<BstNode>(0);
    }
    
    def Bool contains(Int val) {
        BstNode tmp = root;
        while(tmp != cast<BstNode>(0)) {
            if(val < tmp.val)
                tmp = tmp.left;
            else if(val > tmp.val)
                tmp = tmp.right;
            else
                return true;
        }
        return false;
    }
    
    def Void add(Int val) {     
        if(root == cast<BstNode>(0)) {
            root = new BstNode;
            call root.init(val);
        } else {
            BstNode tmp = root;
            while(true) {               
                if(val < tmp.val) {
                    if(tmp.left == cast<BstNode>(0)) {
                        tmp.left = new BstNode;
                        call tmp.left.init(val);
                        return;
                    } else
                        tmp = tmp.left;
                } else if(val > tmp.val) {
                    if(tmp.right == cast<BstNode>(0)) {                         
                        tmp.right = new BstNode;
                        call tmp.right.init(val);
                        return;
                    } else
                        tmp = tmp.right;
                } else
                    return;
            }
        }
    }
}

class Main {
    def Int main(Int argc, Void argv) {  
        IO io = new IO;
        TestClass test = new TestClass;
        
        call io.printf("If, else: ");
        if(call test.test_if() == 666) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("While: ");
        if(call test.test_while() == 100) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("Arithmetic: ");
        if(call test.test_arith() == -8) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("For loop: ");
        if(call test.test_for() == 13) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("Switch, case: ");
        if(call test.test_switch() == 1) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("Break, continue: ");
        if(call test.test_break_continue() == 34) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("Method args: ");
        if(call test.test_method_arg(2, 4, 6) == 6) call io.puts("OK");
        else call io.puts("FAILED");
        
        call io.printf("Point class ops: ");
        if(call test.test_class() == 10) call io.puts("OK");
        else call io.puts("FAILED");
        
        call test.test_gc();
        
        LinkedList ll = new LinkedList;
        call io.puts("Linked list test:");
        
        call ll.init();
        call ll.add(1);
        call ll.add(2);
        call ll.add(3);
        call ll.add(4);
        call ll.print();
        
        Bst bst = new Bst;
        call bst.init();        
        call bst.add(8);
        call bst.add(1);
        call bst.add(9);
        call bst.add(2);
        call bst.add(5);
        call bst.add(5);
        call bst.add(4);
        call io.printf("BST: ");
        if(call bst.contains(1) && call bst.contains(1) && (!call bst.contains(3))) 
        call io.puts("OK"); else call io.puts("FAILED");

        return 0;
    }
}
