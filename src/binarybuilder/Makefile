CC = cc
CFLAGS = -std=c11 -fPIC -Wall -Wextra -g -O2 -lm
LDFLAGS = -shared -lm
RM = rm -f
TARGET_LIB = "lib$(SRC_NAME).$(dlext)"

SRCS := $(shell find ./ -name "*.c" ! -name "main.c")

OBJS = $(SRCS:.c=.o)
.PHONY: all;
all: ${TARGET_LIB}
$(TARGET_LIB): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS) $(FLAGS)
$(SRCS:.c=.d):%.d:%.c
	$(CC) $(CFLAGS) $(FLAGS) -MM $< >$@
	include $(SRCbS:.c=.d)
.PHONY: clean
clean:
	$(RM) $(TARGET_LIB) $(OBJS) $(SRCS:.c=.d)
.PHONY: install
install:
	install -Dvm 755 "./lib${SRC_NAME}.$(dlext)" "$(libdir)/lib$(SRC_NAME).$(dlext)"