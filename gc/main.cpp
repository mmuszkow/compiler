typedef unsigned int WORD;

#define FLAG_MARKED 0x80000000 // block was already visited
#define TAG_FREE    0
#define MAX_ATTR    2 // maximally 2 * sizeof(WORD) attributes in class -> 64

struct class_tag {
    WORD size; // attributes count
    WORD is_ptr[MAX_ATTR]; // bitfield saying if the attrib is a pointer
};

// this contains info about the classes, filled up by gc_init
const class_tag* tags;
WORD free; // total free bytes left
WORD* heap; // memory that can be allocated
WORD size; // size of that memory
WORD zero = 0;

void gc_init(const class_tag* _tags, WORD* _heap, WORD _size) {
    tags = _tags;
    heap = _heap;
    size = _size;
    free = size - 2;
    heap[0] = TAG_FREE;
    heap[1] = free;    
}

void _gc_collect(WORD offset, WORD size) {
    heap[offset] = TAG_FREE;
    heap[offset+1] = size-1;
}

// finds and reserves first free block with sufficient size
WORD* _gc_reserve(WORD allocClassTag) {
    WORD offset = 0;
    const class_tag& act = tags[allocClassTag];
    while(offset < size) {
        WORD blockType = heap[offset];
        switch(blockType) {
        case TAG_FREE: {// empty block
            WORD blockSize = heap[offset+1];
            if(blockSize <= act.size) {
                heap[offset] = allocClassTag;
                if(blockSize - act.size >= 3)
                    _gc_collect(offset+act.size+1, blockSize-act.size-1);
                return &heap[offset+1];
            } else
                offset += blockSize+1;
            break;
            }
        default:
            offset += tags[blockType].size+1;
        }
    }
    return 0;
}

// mark & sweep
void gc_ms(WORD* fp) {
    WORD offset;

    // mark: shitstorm comming, unroll stack
    if(fp == 0) return;
    //gc_ms((WORD*)*(fp+2)); // visit previous frame

    WORD methodArgs = *(fp+3) & 0xFFFF;
    WORD methodLocals = *(fp+3) >> 16;

    // sweep: free memory with non visited instances
    offset = 0;
    while(offset < size) {
        WORD blockType = heap[offset];
        switch(blockType) {
        case TAG_FREE:
            offset += heap[offset+1];
            break;
        default:
            const class_tag& c = tags[blockType];
            if(!(heap[offset] & FLAG_MARKED))
                _gc_collect(offset, c.size);
            heap[offset] &= ~FLAG_MARKED;
            offset += tags[blockType].size+1;
        }
    }
}

/**
  * Tries to allocate the memory for the class instance.
  *
  * @arg ebp frame pointer, used for unrolling the stack
  * @arg classTage the tag of the class that will be allocated, 
  *      it will be used to determine the class size
  *
  * @return 0 if there is no memory left,
  *        for classes that have no attribs it returns pointer to 
  *        the "zero" variable that's shouldn't be written into,
  *        for other classes the pointer to memory that can be written
  */
WORD* gc_malloc(WORD* fp, WORD classTag) {
    if(tags[classTag-1].size == 0)
        return &zero;

    WORD* mem;
    // if cannot get mem, try to collect unused memory
    if((free < tags[classTag-1].size) || ((mem = _gc_reserve(classTag)) == 0)) {
        gc_ms(fp);
        return _gc_reserve(classTag);
    }
    return mem;
}

extern "C" {
    __declspec(dllexport) void gc_init() {
    }

    __declspec(dllexport) WORD* gc_malloc() {
    }
};


int main() {
    class_tag test_tags[2];
    test_tags[0].size = 2;
    test_tags[0].is_ptr[0] = 1; // 1 ptr, 1 val
    test_tags[1].size = 3;
    test_tags[1].is_ptr[0] = 2; // 1 ptr, 2 vals
    return 0;
}
