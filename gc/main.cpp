#include <stdio.h>
#include <windows.h>

#define GC_EXPORT extern "C" __declspec(dllexport)
#define GC_CALL_CONV __cdecl

typedef unsigned int mem_word;

#define FLAG_MARKED 0x80000000 // block was already visited
#define TAG_MASK    0x7FFFFFFF // max tag (class id) range
#define TAG_FREE    0
#define MAX_PTR     1 // maximally 1 * sizeof(WORD) attributes in class/local vars/method arguments -> 32

struct class_tag {
    mem_word size; // attributes count
    mem_word is_ptr[MAX_PTR]; // bitfield saying if the attrib is a pointer
};

struct method_tag {
    mem_word locals;
    mem_word l_is_ptr[MAX_PTR];
    mem_word args;
    mem_word a_is_ptr[MAX_PTR];
};

#define HEAP_SIZE 64
mem_word heap[HEAP_SIZE]; // memory that can be allocated
mem_word zero = 0;
const class_tag* tags; // this contains info about the classes, it's filled up by gc_init

// debug dump
void _gc_dump() {
    mem_word offset = 0;
    puts("heap dump:");
    while(offset < HEAP_SIZE-1) {
        if(heap[offset] == TAG_FREE) { // empty block
            printf("  empty block: %d words\n", heap[offset+1]);
            offset += heap[offset+1]+1;
        } else { // non-empty block
            printf("  class %d instance: %d words\n", heap[offset], tags[heap[offset]-1].size);
            offset += tags[heap[offset]-1].size+1;
        }
    }
}

// inits the heap
GC_EXPORT void GC_CALL_CONV gc_init(const class_tag* _tags) {
    heap[0] = TAG_FREE;
    heap[1] = HEAP_SIZE-1;
    tags = _tags;
}

// returns the occupied memory to the pool
void _gc_collect(mem_word offset, mem_word size) {
    heap[offset] = TAG_FREE;
    heap[offset+1] = size;
}

// finds and reserves first free block with sufficient size
void* _gc_reserve(mem_word classTag) {
    mem_word offset = 0;
    while(offset < HEAP_SIZE-1) {
        if(heap[offset] == TAG_FREE) { // empty block
            mem_word blockSize = heap[offset+1];
            const class_tag& c = tags[classTag-1];
            if(c.size <= blockSize) {
                heap[offset] = classTag;
                if(blockSize - c.size >= 3)
                    _gc_collect(offset+c.size+1, blockSize-c.size-1);
                return &heap[offset+1];
            } else
                offset += blockSize+1;
        } else // non-empty block
            offset += tags[heap[offset]-1].size+1;
    }
    return 0;
}

// marks instance and all it attributes as visited (recurrential)
void _gc_mark_instance(void* addr) {
    if(addr && addr > heap && addr < heap + HEAP_SIZE) {
        mem_word* block = (mem_word*)addr-1;
        if(!(*block & FLAG_MARKED)) {
            const class_tag& c = tags[*block-1];
            mem_word mask = c.is_ptr[0];
            for(int attr=c.size-1; attr>=0; attr--) {
                void** attr_ptr = (void**)addr+attr;
                if(mask & 1)
                    _gc_mark_instance(*attr_ptr);
                mask >>= 1;
            }
            *block |= FLAG_MARKED;
        }
    } /*else if(addr)
        printf("Someting went wrong: %p\n", addr);*/
}

// marks memory still in use
void _gc_mark(void* fp) {
    if(fp == 0)
        return;
    
    // local variables in current method
    method_tag* m = (method_tag*) (*((void**)fp-1)); // yeah, that's dirty
    mem_word local_mask = m->l_is_ptr[0];
    for(int local_index=m->locals-1; local_index>=0; local_index--) {
        void* local = *((void**)fp-local_index-2);
        if(local_mask & 1)
            _gc_mark_instance(local);
        local_mask >>= 1;
    }
    // arguments for current method
    mem_word arg_mask = m->a_is_ptr[0];
    for(int arg_index=m->args-1; arg_index>=0; arg_index--) {
        void* arg = *((void**)fp+arg_index+2);
        if(arg_mask & 1)
            _gc_mark_instance(arg);
        arg_mask >>= 1;
    }
    // current class pointer
    void* thisPtr = *((void**)fp+m->args+2);
    _gc_mark_instance(thisPtr);

    _gc_mark(*(void**)fp); // visit previous frame
}

// releases unused (unmarked) memory
void _gc_sweep() {
    mem_word offset = 0;
    while(offset < HEAP_SIZE-1) {
        if(heap[offset] == TAG_FREE) // empty block
            offset += heap[offset+1];
        else { // non-empty block
            const class_tag& c = tags[(heap[offset] & TAG_MASK)-1];
            if(!(heap[offset] & FLAG_MARKED))
                _gc_collect(offset, c.size);
            heap[offset] &= ~FLAG_MARKED;
            offset += c.size+1;
        }
    }

    // merge small free memory blocks into bigger blocks
    offset = 0;
    while(offset < HEAP_SIZE-1) {
        if(heap[offset] == TAG_FREE) { // empty block
            mem_word blockSize = heap[offset+1];
            while(offset + blockSize + 1 < HEAP_SIZE-1 && heap[offset+blockSize+1] == TAG_FREE) {
                mem_word nextBlockSize = heap[offset+blockSize+2];
                blockSize += nextBlockSize + 1;
                heap[offset+1] = blockSize;
            }
            offset += blockSize+1;
        } else // non-empty block
            offset += tags[heap[offset]-1].size+1;
    }
}

/**
  * Tries to allocate the memory for the class instance.
  *
  * @arg ebp frame pointer, used for unrolling the stack
  * @arg classTag the tag of the class that will be allocated, 
  *      it will be used to determine the class size
  *
  * @return 0 if there is no memory left,
  *        for classes that have no attribs it returns pointer to 
  *        the "zero" variable that's shouldn't be written into,
  *        for other classes the pointer to memory that can be written
  */
GC_EXPORT void* GC_CALL_CONV gc_malloc(void* fp, mem_word classTag) {
    const class_tag& c = tags[classTag-1];
    if(c.size == 0)
        return &zero;

    void* mem;
    // if cannot get mem, try to collect unused memory
    if((mem = _gc_reserve(classTag)) == 0) {
        _gc_mark(fp);
        _gc_sweep();
        //puts("Mark & Sweep");
        //_gc_dump();
        return _gc_reserve(classTag);
    }
    return mem;
}

BOOL APIENTRY DllMain(HANDLE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    return TRUE;
}
