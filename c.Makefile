VERSION=0.0.1

TARGET=mybin

SRCDIR = src
OBJDIR = build

CC ?= gcc
CFLAGS += -Wall -Wextra
CFLAGS += -Wfloat-equal -Wundef -Wshadow -Wpointer-arith -Wcast-align
CFLAGS += -Wstrict-prototypes -Wwrite-strings -ftrapv -Wpadded
CFLAGS += -fsanitize=address
CFLAGS += -march=native
CFLAGS += -DVERSION=\"$(VERSION)\"
SFLAGS = -std=c99 -pedantic
INCLUDES = -I.
LIBS = 

SRCS = $(wildcard $(SRCDIR)/*.c)
OBJS=$(SRCS:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

PREFIX ?= /usr
BINDIR = $(DESTDIR)$(PREFIX)/bin
MANDIR = $(DESTDIR)$(PREFIX)/share/man/man1
BSHDIR = $(DESTDIR)$(PREFIX)/share/bash-completion/completions
ZSHDIR = $(DESTDIR)$(PREFIX)/share/zsh/site-functions


all: CFLAGS += -O2
all: $(TARGET)

debug: CFLAGS += -O0 -g -DDEBUG
debug: $(TARGET)


#automatic recompile when makefile changes
$(OBJS): Makefile

#automatically creates build directory if it doesn't exist
dummy := $(shell test -d $(OBJDIR) || mkdir -p $(OBJDIR))


$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $< $(LIBS)

$(OBJS): $(OBJDIR)/%.o : $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(SFLAGS) $(INCLUDES) -c -o $@ $< $(LIBS)

install:
	install -D -m 755 $(TARGET) "$(BINDIR)/$(TARGET)"
	install -D -m 644 doc/$(TARGET).1 "$(MANDIR)/$(TARGET).1"
	install -D -m 644 extra/$(RULES) "$(UDVDIR)/$(RULES)"
	install -D -m 644 extra/bash_completion "$(BSHDIR)/$(TARGET)"
	#install -D -m 644 extra/zsh_completion "$(ZSHDIR)/_$(TARGET)"

uninstall:
	$(RM) "$(BINDIR)/$(TARGET)"
	$(RM) "$(MANDIR)/$(TARGET).1"
	$(RM) "$(BSHDIR)/$(TARGET)"
	#$(RM) "$(ZSHDIR)/_$(TARGET)"

test:
	$(CC) -o test test/*.c

doc:
	a2x -v -d manpage -f manpage -a revnumber=$(VERSION) doc/$(TARGET).1.txt

clean:
	$(RM) $(OBJDIR)/* $(TARGET)

.PHONY: all debug clean install uninstall test doc
