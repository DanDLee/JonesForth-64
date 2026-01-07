# JonesForth-64

A complete 64-bit (x86-64) port of JonesForth, with **all comments updated** to reflect 64-bit architecture.

## Overview

This is a literate implementation of FORTH for x86-64 Linux. Unlike other 64-bit ports that preserve the original 32-bit comments, this version has been fully converted so that all documentation, ASCII art diagrams, and explanatory text accurately describe the 64-bit implementation.

## Files

- **`jonesforth.S`** - 64-bit assembly kernel (~2300 lines)
- **`jonesforth.f`** - 64-bit Forth library (~1800 lines)
- **`Makefile`** - Build system

## Building

```bash
make
```

## Running

```bash
# Interactive mode with full library
make run

# Or manually:
cat jonesforth.f - | ./jonesforth
```

## Testing

```bash
# Minimal kernel-only test
make test-minimal

# Full test with library
make test
```

## Key Architectural Changes from 32-bit

### Register Mapping

| 32-bit | 64-bit | Purpose |
|--------|--------|---------|
| %esi | %rsi | Forth instruction pointer |
| %ebp | %rbp | Return stack pointer |
| %esp | %rsp | Data stack pointer |
| %eax | %rax | General purpose / syscall number |
| %ebx | %rbx | General purpose |
| %ecx | %rcx | General purpose |
| %edx | %rdx | General purpose |

### Word/Cell Size

- Cell size: 4 bytes → 8 bytes
- Alignment: 4-byte → 8-byte boundaries
- Data directives: `.int` → `.quad`

### NEXT Macro

```asm
// 32-bit                    // 64-bit
lodsl                        lodsq
jmp *(%eax)                  jmp *(%rax)
```

### Syscall Convention

```
32-bit (int $0x80):          64-bit (syscall):
%eax = syscall#              %rax = syscall#
%ebx = arg1                  %rdi = arg1
%ecx = arg2                  %rsi = arg2
%edx = arg3                  %rdx = arg3
                             %r10 = arg4
```

## Changes in jonesforth.S

- All register references updated (eax→rax, etc.)
- NEXT macro: `lodsl; jmp *(%eax)` → `lodsq; jmp *(%rax)`
- PUSHRSP/POPRSP macros: 4-byte → 8-byte offsets
- All syscalls converted from `int $0x80` to `syscall` with new register convention
- Dictionary macros (defword, defcode, defvar, defconst): `.int` → `.quad`
- Stack operations: `4(%esp)` → `8(%rsp)`, etc.
- Division: `cdq; idivl` → `cqto; idivq`
- All ASCII art diagrams updated for 8-byte cells

### Critical 64-bit Fixes

The x86-64 syscall convention uses `%rsi` for argument 2 and `%rdi` for argument 1, but `%rsi` is the Forth instruction pointer and `%rdi` is used by `_WORD`. These registers must be saved/restored around syscalls:

1. **`_KEY`** - saves/restores `%rsi` and `%rdi` around read syscall
2. **`_EMIT`** - saves/restores `%rsi` around write syscall
3. **`TELL`** - saves/restores `%rsi` around write syscall
4. **INTERPRET error handling** - saves/restores `%rsi` around write syscalls

## Changes in jonesforth.f

| Word/Location | Change |
|---------------|--------|
| CELLS | `4 *` → `8 *` |
| ALIGNED | `3 +` → `7 +`, `3 INVERT` → `7 INVERT` |
| PICK | `4 *` → `8 *` |
| .S | `4+` → `8+` |
| DEPTH | `4 /` → `8 /` |
| ID., ?HIDDEN, ?IMMEDIATE | `4+` → `8+` |
| SEE decompiler | All `4 +` → `8 +` |
| Exception handling | All `4+`/`4-` → `8+`/`8-` |
| TO, +TO | `4+` → `8+` |

### Inline Assembler Updates

- Register names: EAX→RAX, EBX→RBX, ECX→RCX, EDX→RDX, ESI→RSI, EDI→RDI, EBP→RBP, ESP→RSP
- NEXT opcode: `AD FF 20` → `48 AD FF 20` (added REX.W prefix)
- =NEXT check updated for 64-bit opcode pattern

## Test Results

```
Minimal test (kernel only):
  "48 1 2 + + EMIT" → outputs '3' ✓

Full test (with library):
  ": DOUBLE DUP + ; 21 DOUBLE ." → outputs 42 ✓

Recursion test:
  "5 FACTORIAL ." → outputs 120 ✓

Loop test:
  "5 COUNT-DOWN" → outputs "5 4 3 2 1" ✓

SEE decompiler:
  "SEE TEST" → correctly decompiles ✓
```

## Original Source

Based on JonesForth by Richard W.M. Jones <rich@annexia.org>.
Original: http://annexia.org/forth

## License

Public domain (same as original JonesForth).
