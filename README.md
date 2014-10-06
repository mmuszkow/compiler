After looking over the coursera's compilers course, I thought it'd be fun to write my own compiler (without using any external libraries). And here it is, it compiles a Java-like language (example in code.mm) into x86 assembler code.

Some of the language characteristics:
* Variables can be passed by value (3 built-in types: Int, Bool, String) or reference (which is basically a pointer to the class attributes).
* String is a pointer to byte sequence ending with \0.
* True value is "greater or equal to 1", false is "less or equal to 0".
* Ids (vars, attribs, methods) names: `[a-z]([a-z]|[0-9]|_)*` (notice **no uppercase letters**)
* Types names: `[A-Z]([a-z]|[A-Z]|[0-9])*`
* Logical operators have precedence before arithmetic, so the result of `2 + 2 == 4` will be `2` (should be `1` - `true`) because  `2` == `4` will return `0` and `2 + 0` will return `2`. That's why you should use the brackets **everywhere**.
* And operator doesn't work as in C, in `if(a && b)` both `a` and `b` will be evaluated.
* Programs are single-threaded.
* Local variables hide class attributes.
* Local variables names must be unique inside method.
* Entry point is the `main` method of the first parsed class.
* Method definitions must be followed by `def`, calls by `call` (this was introduced to simplify the grammar).
* NULL => `cast<YourType>(0)`

The compiler itself is splitted into 4 parts:
* lexer (*Lexer.h*) - Produces a list of tokens from the input string.
It's autogenerated by *gen_lexer.py*.
Tokens (`TYPES`) descriptions are defined by regular expressions (`RULES`) (syntax: `*,|,[a-z],(,),[^a]`), 
Lexer is a state machine and parsing is done using the LUT tables, generating these tables may take a while...
* parser (*Parser.h*) - Creates and validates the AST. 
It's autogenerated by *gen_parser.py* basing on the defined grammar (`GRAMMAR`). 
Non-terminal symbols are in lower-case, terminal in upper-case.
Many simplifications has been taken and the grammar is far from perfect.
* semantic checker (*SemanticCheck.h*) - This is a two-pass semantic check, it uses the AST generated by *gen_parser.py*.
It provides very basic checks and was written mainly to provide information needed by the code generator.
* code generator (*CodeGen.cpp*) - Generates x86 assembler code (FASM syntax), it also uses the AST generated by *gen_parser.py*.
It contains almost **no optimizations**. All variables are processor word size (I used 32-bit assembler so 4 bytes). 
All integers are signed 32-bit values, all arithmetic operations are signed.
Only 4 registers are used: `eax` (as the accumulator), `ebx` (for 2 arguments operators and adresses), `esp` and `ebp` (for method arguments).
There is no "Byte" type, so any operations on strings or arrays need to be implemented in assembler.
The only built-in function is `gc_malloc`, it takes 1 argument: size of memory that needs to be allocated.

Method call layout:
```
Int method(Int arg1, Int arg2, Int arg3) {
    Int loc_var1, loc_var2, loc_var3;
}
# this pointer # ebp+20 # pointer to the class instance in which the method is called
# method arg1  # ebp+16 # method arguments
# method arg2  # ebp+12
# method arg3  # ebp+8  
# ret addr     # ebp+4  # return adress to calling method
# prev fp      # ebp    # previous frame pointer
# method_dsc   # ebp-4  # high 16-bits is the number of method arguments, 
                          low 16-bits is the number of locals, 
                          this was planned to be used by the GC
                          here will be: 0x00030003
# loc_var1     # ebp-8  # local variables
# loc_var2     # ebp-12
# loc_var3     # ebp-16 # here is where stack pointer (esp) points
```
One big thing **missing** is the **garbage collector**. Now I'm simply allocating the new memory and not freeing it at all. 
I was planning to implement mark & sweep GC, but my enthusiasm and fervor ended before I came to that. 
Maybe I'll come back to that one day..

