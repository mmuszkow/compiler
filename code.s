format PE console
entry _start
include 'fasm\INCLUDE\win32a.inc'

section '.text' code readable executable
_start:
  xor ebp, ebp
  mov [heap_top], heap_ptr
  mov eax, 0
  call gc_malloc
  push 0
  push 0
  push eax
  call Main_main
  add esp, 12
  ret

StrUtils_int2str:
  push ebp
  mov ebp, esp
  push 0x20001
  sub esp, 8
  mov eax, str_const_7
  mov [ebp-8], eax
  mov eax, str_const_9
  mov [ebp-12], eax
  push dword [ebp+8]
  push dword [ebp-12]
  push dword [ebp-8]
  call [sprintf]
  add esp, 12
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  jmp StrUtils_int2str_end
StrUtils_int2str_end:
  mov esp, ebp
  pop ebp
  ret

StrUtils_len:
  push ebp
  mov ebp, esp
  push 0x1
  mov ebx, [ebp+8]
  xor eax, eax
strlen_loop:
  cmp [ebx], byte 0
  je strlen_end
  inc eax
  inc ebx
  jmp strlen_loop
strlen_end:
StrUtils_len_end:
  mov esp, ebp
  pop ebp
  ret

Point_init:
  push ebp
  mov ebp, esp
  push 0x2
  mov ebx, [ebp+16]
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 12
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  mov ebx, [ebp+16]
  add ebx, 4
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
Point_init_end:
  mov esp, ebp
  pop ebp
  ret

Point_distance:
  push ebp
  mov ebp, esp
  push 0x10001
  sub esp, 4
  mov eax, 0
  call gc_malloc
  mov [ebp-8], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  pop ebx
  xchg eax, ebx
  sub eax, ebx
  push eax
  call Math_abs
  add esp, 8
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, [ebp+12]
  add ebx, 4
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  pop ebx
  xchg eax, ebx
  sub eax, ebx
  push eax
  call Math_abs
  add esp, 8
  pop ebx
  add eax, ebx
  jmp Point_distance_end
Point_distance_end:
  mov esp, ebp
  pop ebp
  ret

Math_abs:
  push ebp
  mov ebp, esp
  push 0x1
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  jl logic_lt_2
  xor eax, eax
  jmp logic_lt_2_end
logic_lt_2:
  mov eax, 1
logic_lt_2_end:
  cmp eax, 1
  jl cond_1_else
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, -1
  pop ebx
  imul eax, ebx
  jmp Math_abs_end
  jmp cond_1_end
cond_1_else:
cond_1_end:
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  jmp Math_abs_end
Math_abs_end:
  mov esp, ebp
  pop ebp
  ret

Math_power:
  push ebp
  mov ebp, esp
  push 0x10002
  sub esp, 4
  mov eax, 1
  mov [ebp-8], eax
loop_3:
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  jg logic_gt_4
  xor eax, eax
  jmp logic_gt_4_end
logic_gt_4:
  mov eax, 1
logic_gt_4_end:
  cmp eax, 1
  jl loop_3_end
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  and eax, ebx
  cmp eax, 1
  jl cond_5_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 12
  mov eax, [ebx]
  pop ebx
  imul eax, ebx
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  xchg eax, ebx
  sub eax, ebx
  pop ebx
  mov [ebx], eax
  jmp cond_5_end
cond_5_else:
cond_5_end:
  mov ebx, ebp
  add ebx, 12
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 12
  mov eax, [ebx]
  pop ebx
  imul eax, ebx
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 2
  pop ebx
  xchg eax, ebx
  xor edx, edx
  idiv ebx
  pop ebx
  mov [ebx], eax
  jmp loop_3
loop_3_end:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  jmp Math_power_end
Math_power_end:
  mov esp, ebp
  pop ebp
  ret

Array_init:
  push ebp
  mov ebp, esp
  push 0x1
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  mov eax, [ebp+8]
  shl eax, 2
  call gc_malloc
  mov ebx, [ebp+12]
  mov [ebx], eax
Array_init_end:
  mov esp, ebp
  pop ebp
  ret

Array_get:
  push ebp
  mov ebp, esp
  push 0x1
  mov eax, [ebp+8]
  mov ebx, [ebp+12]
  add ebx, eax
  mov eax, [ebx]
Array_get_end:
  mov esp, ebp
  pop ebp
  ret

IO_puts:
  push ebp
  mov ebp, esp
  push 0x1
  push dword [ebp+8]
  call [puts]
  add esp, 4
IO_puts_end:
  mov esp, ebp
  pop ebp
  ret

IO_printf:
  push ebp
  mov ebp, esp
  push 0x1
  push dword [ebp+8]
  call [printf]
  add esp, 4
IO_printf_end:
  mov esp, ebp
  pop ebp
  ret

IO_scani:
  push ebp
  mov ebp, esp
  push 0x20000
  sub esp, 8
  mov eax, str_const_9
  mov [ebp-8], eax
  push dword [ebp-12]
  push dword [ebp-8]
  call [scanf]
  add esp, 8
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  jmp IO_scani_end
IO_scani_end:
  mov esp, ebp
  pop ebp
  ret

IO_scans:
  push ebp
  mov ebp, esp
  push 0x10001
  sub esp, 4
  mov eax, str_const_66
  mov [ebp-8], eax
  mov eax, [ebp+8]
  call gc_malloc
  push eax
  push dword [ebp-8]
  call [scanf]
  pop eax
  pop eax
IO_scans_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_break_continue:
  push ebp
  mov ebp, esp
  push 0x20000
  sub esp, 8
  mov eax, 1
  mov [ebp-8], eax
  mov eax, 0
  mov [ebp-12], eax
loop_6:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 5
  pop ebx
  cmp ebx, eax
  jle logic_lteq_7
  xor eax, eax
  jmp logic_lteq_7_end
logic_lteq_7:
  mov eax, 1
logic_lteq_7_end:
  cmp eax, 1
  jl loop_6_end
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 4
  pop ebx
  cmp ebx, eax
  je logic_eq_9
  xor eax, eax
  jmp logic_eq_9_end
logic_eq_9:
  mov eax, 1
logic_eq_9_end:
  cmp eax, 1
  jl cond_8_else
  jmp loop_6_end
  jmp cond_8_end
cond_8_else:
cond_8_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_6
loop_6_end:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov eax, 1
  pop ebx
  mov [ebx], eax
loop_10:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 5
  pop ebx
  cmp ebx, eax
  jle logic_lteq_11
  xor eax, eax
  jmp logic_lteq_11_end
logic_lteq_11:
  mov eax, 1
logic_lteq_11_end:
  cmp eax, 1
  jl loop_10_end
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 4
  pop ebx
  cmp ebx, eax
  je logic_eq_13
  xor eax, eax
  jmp logic_eq_13_end
logic_eq_13:
  mov eax, 1
logic_eq_13_end:
  cmp eax, 1
  jl cond_12_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_10
  jmp cond_12_end
cond_12_else:
cond_12_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_10
loop_10_end:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov eax, 1
  pop ebx
  mov [ebx], eax
loop_14:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 5
  pop ebx
  cmp ebx, eax
  jle logic_lteq_15
  xor eax, eax
  jmp logic_lteq_15_end
logic_lteq_15:
  mov eax, 1
logic_lteq_15_end:
  cmp eax, 1
  jl loop_14_end
  jmp loop_14_block
loop_14_post_block:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_14
loop_14_block:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 4
  pop ebx
  cmp ebx, eax
  je logic_eq_17
  xor eax, eax
  jmp logic_eq_17_end
logic_eq_17:
  mov eax, 1
logic_eq_17_end:
  cmp eax, 1
  jl cond_16_else
  jmp loop_14_end
  jmp cond_16_end
cond_16_else:
cond_16_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_14_post_block
loop_14_end:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov eax, 1
  pop ebx
  mov [ebx], eax
loop_18:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 5
  pop ebx
  cmp ebx, eax
  jle logic_lteq_19
  xor eax, eax
  jmp logic_lteq_19_end
logic_lteq_19:
  mov eax, 1
logic_lteq_19_end:
  cmp eax, 1
  jl loop_18_end
  jmp loop_18_block
loop_18_post_block:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_18
loop_18_block:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 4
  pop ebx
  cmp ebx, eax
  je logic_eq_21
  xor eax, eax
  jmp logic_eq_21_end
logic_eq_21:
  mov eax, 1
logic_eq_21_end:
  cmp eax, 1
  jl cond_20_else
  jmp loop_18_post_block
  jmp cond_20_end
cond_20_else:
cond_20_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_18_post_block
loop_18_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  jmp TestClass_test_break_continue_end
TestClass_test_break_continue_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_logic:
  push ebp
  mov ebp, esp
  push 0x40000
  sub esp, 16
  mov eax, 1
  push eax
  mov eax, 1
  pop ebx
  cmp ebx, eax
  je logic_eq_22
  xor eax, eax
  jmp logic_eq_22_end
logic_eq_22:
  mov eax, 1
logic_eq_22_end:
  mov [ebp-8], eax
  mov eax, 1
  push eax
  mov eax, 2
  pop ebx
  cmp ebx, eax
  jne logic_neq_23
  xor eax, eax
  jmp logic_neq_23_end
logic_neq_23:
  mov eax, 1
logic_neq_23_end:
  mov [ebp-20], eax
  mov eax, 4
  push eax
  mov eax, 3
  pop ebx
  cmp ebx, eax
  jg logic_gt_24
  xor eax, eax
  jmp logic_gt_24_end
logic_gt_24:
  mov eax, 1
logic_gt_24_end:
  mov [ebp-12], eax
  mov eax, -10
  push eax
  mov eax, 8
  pop ebx
  cmp ebx, eax
  jl logic_lt_25
  xor eax, eax
  jmp logic_lt_25_end
logic_lt_25:
  mov eax, 1
logic_lt_25_end:
  mov [ebp-16], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  pop ebx
  and eax, ebx
  pop ebx
  and eax, ebx
  pop ebx
  and eax, ebx
  jmp TestClass_test_logic_end
TestClass_test_logic_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_if:
  push ebp
  mov ebp, esp
  push 0x0
  mov eax, 2
  push eax
  mov eax, 2
  pop ebx
  add eax, ebx
  push eax
  mov eax, 4
  pop ebx
  cmp ebx, eax
  je logic_eq_30
  xor eax, eax
  jmp logic_eq_30_end
logic_eq_30:
  mov eax, 1
logic_eq_30_end:
  cmp eax, 1
  jl cond_29_else
  mov eax, 666
  jmp TestClass_test_if_end
  jmp cond_29_end
cond_29_else:
  mov eax, 777
  jmp TestClass_test_if_end
cond_29_end:
TestClass_test_if_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_while:
  push ebp
  mov ebp, esp
  push 0x10000
  sub esp, 4
  mov eax, 0
  mov [ebp-8], eax
loop_31:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 100
  pop ebx
  cmp ebx, eax
  jne logic_neq_32
  xor eax, eax
  jmp logic_neq_32_end
logic_neq_32:
  mov eax, 1
logic_neq_32_end:
  cmp eax, 1
  jl loop_31_end
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_31
loop_31_end:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  jmp TestClass_test_while_end
TestClass_test_while_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_arith:
  push ebp
  mov ebp, esp
  push 0x0
  mov eax, 2
  push eax
  mov eax, 3
  pop ebx
  imul eax, ebx
  push eax
  mov eax, 1
  push eax
  mov eax, 3
  pop ebx
  xchg eax, ebx
  sub eax, ebx
  pop ebx
  add eax, ebx
  push eax
  mov eax, -2
  pop ebx
  imul eax, ebx
  jmp TestClass_test_arith_end
TestClass_test_arith_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_for:
  push ebp
  mov ebp, esp
  push 0x40000
  sub esp, 16
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov eax, 1
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push ebx
  mov eax, 1
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push ebx
  mov eax, 1
  pop ebx
  mov [ebx], eax
loop_33:
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  mov eax, 5
  pop ebx
  cmp ebx, eax
  jle logic_lteq_34
  xor eax, eax
  jmp logic_lteq_34_end
logic_lteq_34:
  mov eax, 1
logic_lteq_34_end:
  cmp eax, 1
  jl loop_33_end
  jmp loop_33_block
loop_33_post_block:
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_33
loop_33_block:
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  jmp loop_33_post_block
loop_33_end:
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  jmp TestClass_test_for_end
TestClass_test_for_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_switch:
  push ebp
  mov ebp, esp
  push 0x10000
  sub esp, 4
  mov eax, 2
  mov [ebp-8], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ecx, eax
  cmp ecx, 0
  jne cond_35_0_next
  mov eax, -1
  jmp TestClass_test_switch_end
  jmp cond_35_end
cond_35_0_next:
  cmp ecx, 1
  jne cond_35_1_next
  mov eax, 0
  jmp TestClass_test_switch_end
  jmp cond_35_end
cond_35_1_next:
  cmp ecx, 2
  jne cond_35_2_next
  mov eax, 1
  jmp TestClass_test_switch_end
  jmp cond_35_end
cond_35_2_next:
  mov eax, -2
  jmp TestClass_test_switch_end
cond_35_end:
TestClass_test_switch_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_method_arg:
  push ebp
  mov ebp, esp
  push 0x3
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  jmp TestClass_test_method_arg_end
TestClass_test_method_arg_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_class:
  push ebp
  mov ebp, esp
  push 0x20000
  sub esp, 8
  mov eax, 8
  call gc_malloc
  mov [ebp-8], eax
  mov eax, 8
  call gc_malloc
  mov [ebp-12], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, -2
  push eax
  mov eax, 4
  push eax
  call Point_init
  add esp, 12
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, 5
  push eax
  mov eax, 1
  push eax
  call Point_init
  add esp, 12
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  call Point_distance
  add esp, 8
  jmp TestClass_test_class_end
TestClass_test_class_end:
  mov esp, ebp
  pop ebp
  ret

TestClass_test_gc:
  push ebp
  mov ebp, esp
  push 0x20000
  sub esp, 8
  mov eax, 1
  mov [ebp-8], eax
loop_36:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 10000
  pop ebx
  cmp ebx, eax
  jl logic_lt_37
  xor eax, eax
  jmp logic_lt_37_end
logic_lt_37:
  mov eax, 1
logic_lt_37_end:
  cmp eax, 1
  jl loop_36_end
  mov eax, 8
  call gc_malloc
  mov [ebp-12], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  pop ebx
  add eax, ebx
  pop ebx
  mov [ebx], eax
  jmp loop_36
loop_36_end:
TestClass_test_gc_end:
  mov esp, ebp
  pop ebp
  ret

LinkedListNode_init:
  push ebp
  mov ebp, esp
  push 0x1
  mov ebx, [ebp+12]
  add ebx, 4
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push ebx
  mov eax, 0
  pop ebx
  mov [ebx], eax
LinkedListNode_init_end:
  mov esp, ebp
  pop ebp
  ret

LinkedList_init:
  push ebp
  mov ebp, esp
  push 0x0
  mov ebx, [ebp+8]
  mov eax, [ebx]
  push ebx
  mov eax, 0
  pop ebx
  mov [ebx], eax
  mov ebx, [ebp+8]
  add ebx, 4
  mov eax, [ebx]
  push ebx
  mov eax, 0
  pop ebx
  mov [ebx], eax
LinkedList_init_end:
  mov esp, ebp
  pop ebp
  ret

LinkedList_add:
  push ebp
  mov ebp, esp
  push 0x10001
  sub esp, 4
  mov eax, 8
  call gc_malloc
  mov [eax+0], dword 0
  mov [ebp-8], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  call LinkedListNode_init
  add esp, 8
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  je logic_eq_39
  xor eax, eax
  jmp logic_eq_39_end
logic_eq_39:
  mov eax, 1
logic_eq_39_end:
  cmp eax, 1
  jl cond_38_else
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  jmp cond_38_end
cond_38_else:
  mov ebx, [ebp+12]
  add ebx, 4
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
cond_38_end:
  mov ebx, [ebp+12]
  add ebx, 4
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
LinkedList_add_end:
  mov esp, ebp
  pop ebp
  ret

LinkedList_print:
  push ebp
  mov ebp, esp
  push 0x30000
  sub esp, 12
  mov eax, 0
  call gc_malloc
  mov [ebp-8], eax
  mov eax, 0
  call gc_malloc
  mov [ebp-12], eax
  mov ebx, [ebp+8]
  mov eax, [ebx]
  mov [ebp-16], eax
loop_40:
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  jne logic_neq_41
  xor eax, eax
  jmp logic_neq_41_end
logic_neq_41:
  mov eax, 1
logic_neq_41_end:
  cmp eax, 1
  jl loop_40_end
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  push eax
  call StrUtils_int2str
  add esp, 8
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, str_const_108
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  jmp loop_40
loop_40_end:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, str_const_0
  push eax
  call IO_puts
  add esp, 8
LinkedList_print_end:
  mov esp, ebp
  pop ebp
  ret

BstNode_init:
  push ebp
  mov ebp, esp
  push 0x1
  mov ebx, [ebp+12]
  add ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push ebx
  mov eax, 0
  pop ebx
  mov [ebx], eax
  mov ebx, [ebp+12]
  add ebx, 4
  mov eax, [ebx]
  push ebx
  mov eax, 0
  pop ebx
  mov [ebx], eax
BstNode_init_end:
  mov esp, ebp
  pop ebp
  ret

Bst_init:
  push ebp
  mov ebp, esp
  push 0x0
  mov ebx, [ebp+8]
  mov eax, [ebx]
  push ebx
  mov eax, 0
  pop ebx
  mov [ebx], eax
Bst_init_end:
  mov esp, ebp
  pop ebp
  ret

Bst_contains:
  push ebp
  mov ebp, esp
  push 0x10001
  sub esp, 4
  mov ebx, [ebp+12]
  mov eax, [ebx]
  mov [ebp-8], eax
loop_42:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  jne logic_neq_43
  xor eax, eax
  jmp logic_neq_43_end
logic_neq_43:
  mov eax, 1
logic_neq_43_end:
  cmp eax, 1
  jl loop_42_end
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  cmp ebx, eax
  jl logic_lt_45
  xor eax, eax
  jmp logic_lt_45_end
logic_lt_45:
  mov eax, 1
logic_lt_45_end:
  cmp eax, 1
  jl cond_44_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  jmp cond_44_end
cond_44_else:
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  cmp ebx, eax
  jg logic_gt_47
  xor eax, eax
  jmp logic_gt_47_end
logic_gt_47:
  mov eax, 1
logic_gt_47_end:
  cmp eax, 1
  jl cond_46_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
  jmp cond_46_end
cond_46_else:
  mov eax, 1
  jmp Bst_contains_end
cond_46_end:
cond_44_end:
  jmp loop_42
loop_42_end:
  mov eax, 0
  jmp Bst_contains_end
Bst_contains_end:
  mov esp, ebp
  pop ebp
  ret

Bst_add:
  push ebp
  mov ebp, esp
  push 0x10001
  sub esp, 4
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  je logic_eq_49
  xor eax, eax
  jmp logic_eq_49_end
logic_eq_49:
  mov eax, 1
logic_eq_49_end:
  cmp eax, 1
  jl cond_48_else
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push ebx
  mov eax, 12
  call gc_malloc
  mov [eax+0], dword 0
  mov [eax+4], dword 0
  pop ebx
  mov [ebx], eax
  mov ebx, [ebp+12]
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  call BstNode_init
  add esp, 8
  jmp cond_48_end
cond_48_else:
  mov ebx, [ebp+12]
  mov eax, [ebx]
  mov [ebp-8], eax
loop_50:
  mov eax, 1
  cmp eax, 1
  jl loop_50_end
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  cmp ebx, eax
  jl logic_lt_52
  xor eax, eax
  jmp logic_lt_52_end
logic_lt_52:
  mov eax, 1
logic_lt_52_end:
  cmp eax, 1
  jl cond_51_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  je logic_eq_54
  xor eax, eax
  jmp logic_eq_54_end
logic_eq_54:
  mov eax, 1
logic_eq_54_end:
  cmp eax, 1
  jl cond_53_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  push ebx
  mov eax, 12
  call gc_malloc
  mov [eax+0], dword 0
  mov [eax+4], dword 0
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  call BstNode_init
  add esp, 8
  jmp Bst_add_end
  jmp cond_53_end
cond_53_else:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
cond_53_end:
  jmp cond_51_end
cond_51_else:
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 8
  mov eax, [ebx]
  pop ebx
  cmp ebx, eax
  jg logic_gt_56
  xor eax, eax
  jmp logic_gt_56_end
logic_gt_56:
  mov eax, 1
logic_gt_56_end:
  cmp eax, 1
  jl cond_55_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  push eax
  mov eax, 0
  pop ebx
  cmp ebx, eax
  je logic_eq_58
  xor eax, eax
  jmp logic_eq_58_end
logic_eq_58:
  mov eax, 1
logic_eq_58_end:
  cmp eax, 1
  jl cond_57_else
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  push ebx
  mov eax, 12
  call gc_malloc
  mov [eax+0], dword 0
  mov [eax+4], dword 0
  pop ebx
  mov [ebx], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  push eax
  mov ebx, ebp
  add ebx, 8
  mov eax, [ebx]
  push eax
  call BstNode_init
  add esp, 8
  jmp Bst_add_end
  jmp cond_57_end
cond_57_else:
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push ebx
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  mov ebx, eax
  add ebx, 4
  mov eax, [ebx]
  pop ebx
  mov [ebx], eax
cond_57_end:
  jmp cond_55_end
cond_55_else:
  jmp Bst_add_end
cond_55_end:
cond_51_end:
  jmp loop_50
loop_50_end:
cond_48_end:
Bst_add_end:
  mov esp, ebp
  pop ebp
  ret

Main_main:
  push ebp
  mov ebp, esp
  push 0x40002
  sub esp, 16
  mov eax, 0
  call gc_malloc
  mov [ebp-12], eax
  mov eax, 0
  call gc_malloc
  mov [ebp-20], eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_120
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_if
  add esp, 4
  push eax
  mov eax, 666
  pop ebx
  cmp ebx, eax
  je logic_eq_60
  xor eax, eax
  jmp logic_eq_60_end
logic_eq_60:
  mov eax, 1
logic_eq_60_end:
  cmp eax, 1
  jl cond_59_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_59_end
cond_59_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_59_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_123
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_while
  add esp, 4
  push eax
  mov eax, 100
  pop ebx
  cmp ebx, eax
  je logic_eq_62
  xor eax, eax
  jmp logic_eq_62_end
logic_eq_62:
  mov eax, 1
logic_eq_62_end:
  cmp eax, 1
  jl cond_61_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_61_end
cond_61_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_61_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_124
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_arith
  add esp, 4
  push eax
  mov eax, -8
  pop ebx
  cmp ebx, eax
  je logic_eq_64
  xor eax, eax
  jmp logic_eq_64_end
logic_eq_64:
  mov eax, 1
logic_eq_64_end:
  cmp eax, 1
  jl cond_63_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_63_end
cond_63_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_63_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_125
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_for
  add esp, 4
  push eax
  mov eax, 13
  pop ebx
  cmp ebx, eax
  je logic_eq_66
  xor eax, eax
  jmp logic_eq_66_end
logic_eq_66:
  mov eax, 1
logic_eq_66_end:
  cmp eax, 1
  jl cond_65_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_65_end
cond_65_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_65_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_126
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_switch
  add esp, 4
  push eax
  mov eax, 1
  pop ebx
  cmp ebx, eax
  je logic_eq_68
  xor eax, eax
  jmp logic_eq_68_end
logic_eq_68:
  mov eax, 1
logic_eq_68_end:
  cmp eax, 1
  jl cond_67_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_67_end
cond_67_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_67_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_127
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_break_continue
  add esp, 4
  push eax
  mov eax, 34
  pop ebx
  cmp ebx, eax
  je logic_eq_70
  xor eax, eax
  jmp logic_eq_70_end
logic_eq_70:
  mov eax, 1
logic_eq_70_end:
  cmp eax, 1
  jl cond_69_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_69_end
cond_69_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_69_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_128
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  mov eax, 2
  push eax
  mov eax, 4
  push eax
  mov eax, 6
  push eax
  call TestClass_test_method_arg
  add esp, 16
  push eax
  mov eax, 6
  pop ebx
  cmp ebx, eax
  je logic_eq_72
  xor eax, eax
  jmp logic_eq_72_end
logic_eq_72:
  mov eax, 1
logic_eq_72_end:
  cmp eax, 1
  jl cond_71_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_71_end
cond_71_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_71_end:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_129
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_class
  add esp, 4
  push eax
  mov eax, 10
  pop ebx
  cmp ebx, eax
  je logic_eq_74
  xor eax, eax
  jmp logic_eq_74_end
logic_eq_74:
  mov eax, 1
logic_eq_74_end:
  cmp eax, 1
  jl cond_73_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_73_end
cond_73_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_73_end:
  mov ebx, ebp
  sub ebx, 20
  mov eax, [ebx]
  push eax
  call TestClass_test_gc
  add esp, 4
  mov eax, 8
  call gc_malloc
  mov [eax+0], dword 0
  mov [eax+4], dword 0
  mov [ebp-16], eax
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_131
  push eax
  call IO_puts
  add esp, 8
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  call LinkedList_init
  add esp, 4
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  mov eax, 1
  push eax
  call LinkedList_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  mov eax, 2
  push eax
  call LinkedList_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  mov eax, 3
  push eax
  call LinkedList_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  mov eax, 4
  push eax
  call LinkedList_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 16
  mov eax, [ebx]
  push eax
  call LinkedList_print
  add esp, 4
  mov eax, 4
  call gc_malloc
  mov [eax+0], dword 0
  mov [ebp-8], eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  call Bst_init
  add esp, 4
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 8
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 9
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 2
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 5
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 5
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 4
  push eax
  call Bst_add
  add esp, 8
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_133
  push eax
  call IO_printf
  add esp, 8
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  push eax
  call Bst_contains
  add esp, 8
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 1
  push eax
  call Bst_contains
  add esp, 8
  push eax
  mov ebx, ebp
  sub ebx, 8
  mov eax, [ebx]
  push eax
  mov eax, 3
  push eax
  call Bst_contains
  add esp, 8
  not eax
  pop ebx
  and eax, ebx
  pop ebx
  and eax, ebx
  cmp eax, 1
  jl cond_75_else
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_121
  push eax
  call IO_puts
  add esp, 8
  jmp cond_75_end
cond_75_else:
  mov ebx, ebp
  sub ebx, 12
  mov eax, [ebx]
  push eax
  mov eax, str_const_122
  push eax
  call IO_puts
  add esp, 8
cond_75_end:
  mov eax, 0
  jmp Main_main_end
Main_main_end:
  mov esp, ebp
  pop ebp
  ret

gc_malloc:
  push [heap_top]
  add [heap_top], eax
  pop eax
  ret

section '.data' data readable writeable
str_const_0 db "", 0
str_const_7 db "                           ", 0
str_const_9 db "%d", 0
str_const_66 db "%s", 0
str_const_108 db " ", 0
str_const_120 db "If, else: ", 0
str_const_121 db "OK", 0
str_const_122 db "FAILED", 0
str_const_123 db "While: ", 0
str_const_124 db "Arithmetic: ", 0
str_const_125 db "For loop: ", 0
str_const_126 db "Switch, case: ", 0
str_const_127 db "Break, continue: ", 0
str_const_128 db "Method args: ", 0
str_const_129 db "Point class ops: ", 0
str_const_131 db "Linked list test:", 0
str_const_133 db "BST: ", 0
heap_top dd 0
heap_ptr rd 65536

section '.idata' data readable import
library msvcrt, 'msvcrt.dll'
import msvcrt, printf, 'printf', puts, 'puts', scanf, 'scanf', itoa, 'itoa', sprintf, 'sprintf'

