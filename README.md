# Reverse-Engineering-Basics
شرح احدى اساسيات المصطلحات الهندسة العكسية





# 1 - Local variable storage

يمكن للوظيفة ان تخصص مساحة في stack لمتغيرها المحلي فقط عن طريقdecreasing the stack pointer 

توضيح للمبتدئين : https://eleceng.dit.ie/frank/IntroToC/Memory.html



# 2 - x86bit: alloca();

من المفضل ذكر عن هاذي الوظيفة"alloca"
تعمل هذه الوظيقة مثل "malloc();" لكن الفرق انو بتخصص مكان مباشر في الستاك يعيد "ESP"  الى حالته الاوله ويتم وبعدين يصير allocated memory is just dropped
مثال من كود : 


```cpp
#ifdef __GNUC__
#include <alloca.h> // GCC
#else
#include <malloc.h> // MSVC
#endif
#include <stdio.h>
void X()
{
char *buf=(char*)alloca (600);
#ifdef __GNUC__
snprintf (buf, 600, "hi! %d, %d, %d\n", 1, 2, 3); // GCC
#else
_snprintf (buf, 600, "hi! %d, %d, %d\n", 1, 2, 3); // MSVC
#endif
puts (buf);
};

```


تعمل وظيفة _snprintf(); 
بل ظبط مثل printf();
ولكن بدلا من dumping result stdout 
 (e.g., to console or terminal)

يكتبها الى buf buffer مع وظيفة puts() نسخ محتوايات buf

خلينا نسوي لها كومبايل في MSVC
```asm
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
```

بكل اختصار صار للوظيفة " alloca()" 
passed via EAX
بدل ما يسوي 
PUSHING IT INTO THE STACK
**PUSH** | What is the PUSH "https://en.wikipedia.org/wiki/Stack_(abstract_data_type)" |  "https://www.tutorialspoint.com/cplusplus-program-to-implement-stack-using-array" in C++ 
بعد ال "CALL"
لو تلاحظ ال ESP Points 
الى 600 بايت ويمكننا استخدامها ك memory
array buf

https://diveintosystems.org/book/C8-IA32/arrays.html


**Intel**
 
راح نجرب الان في GCC نفس الاشئ بسوي لكن ما بستدعي وظائف خارجيه without calling external functions
توضيح عن الأداه اكثر: https://wikipedia.org/wiki/GNU_Compiler_Collection
```asm
.LC0:
.string "hi! %d, %d, %d\n"
f:
push ebp
mov ebp, esp
push ebx
sub esp, 660
lea ebx, [esp+39]
and ebx, -16 
mov DWORD PTR [esp], ebx 
mov DWORD PTR [esp+20], 3
mov DWORD PTR [esp+16], 2
mov DWORD PTR [esp+12], 1
mov DWORD PTR [esp+8], OFFSET FLAT:.LC0 
mov DWORD PTR [esp+4], 600 
call _snprintf
mov DWORD PTR [esp], ebx 
call puts
mov ebx, DWORD PTR [ebp-4]
leave
ret
```


تعالو نشوف نفس الكود لكن على GCC AT%T
```asm
LC0:
.string "hi! %d, %d, %d\n"
f:
pushl %ebp
movl %esp, %ebp
pushl %ebx
subl $660, %esp
leal 39(%esp), %ebx
andl $-16, %ebx
movl %ebx, (%esp)
movl $3, 20(%esp)
movl $2, 16(%esp)
movl $1, 12(%esp)
movl $.LC0, 8(%esp)
movl $600, 4(%esp)
call _snprintf
movl %ebx, (%esp)
call puts
movl -4(%ebp), %ebx
leave
ret
```
الكود نفسو ما فرقت هو نفسه زي في القائمة السابقة
btw، movl $3,20(٪esp) يتوافق مع **mov DWORD PTR [esp + 20]** ، 3 في صيغة Intel-syntax. في صيغة AT&T ،
إن تنسيق **register + offset** لعنونة الذاكرة يشبه الإزاحة(register%). 
https://csiflabs.cs.ucdavis.edu/~ssdavis/50/att-syntax.htm
