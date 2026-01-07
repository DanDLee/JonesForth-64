# Makefile for JonesForth-64
# 64-bit x86-64 version of JonesForth

JONESFORTH = jonesforth
JONESFORTHF = jonesforth.f
JONESFORTH_S = jonesforth.S

# Linker flags for 64-bit build
# -nostdlib: Don't link standard library (we use raw syscalls)
# -static: Static linking (no dynamic linker needed)
# -Wl,--build-id=none: Don't add build-id section
# Note: We don't use -Ttext,0 on 64-bit because address 0 is protected
LDFLAGS = -nostdlib -static -Wl,--build-id=none

.PHONY: all clean test test-minimal run

all: $(JONESFORTH)

$(JONESFORTH): $(JONESFORTH_S)
	gcc $(LDFLAGS) -o $@ $<

clean:
	rm -f $(JONESFORTH)

# Minimal test - just the kernel, no library
# Note: . CR BYE are defined in jonesforth.f, so use EMIT for output
test-minimal: $(JONESFORTH)
	@echo "=== Minimal Test (kernel only) ==="
	@echo "48 1 2 + + EMIT" | ./$(JONESFORTH)
	@echo ""
	@echo "(Expected: '3' - ASCII 48 + 3 = 51 = '3')"

# Full test with library loaded
test: $(JONESFORTH)
	@echo "=== Full Test (with library) ==="
	@echo ": DOUBLE DUP + ; 21 DOUBLE . CR BYE" | cat $(JONESFORTHF) - | ./$(JONESFORTH)

# Interactive mode with library
run: $(JONESFORTH)
	cat $(JONESFORTHF) - | ./$(JONESFORTH)
