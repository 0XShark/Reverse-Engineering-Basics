mov eax, 600
call __alloca_probe_16
mov esi, esp
push 3
push 2
push 1
push OFFSET $SG2672
push 600 
ush esi
call __snprintf
push esi
call _puts
add esp, 28 
