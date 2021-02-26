CC = gcc
CFLAGS = -std=c99 -fPIC -Wall -Wextra -O2 -g
LDFLAGS = -shared
RM = rm -f
TARGET_LIB = "libcatch22.dylib"

SRCS = main.c CO_AutoCorr.c DN_HistogramMode_10.c DN_HistogramMode_5.c DN_OutlierInclude.c FC_LocalSimple.c IN_AutoMutualInfoStats.c MD_hrv.c PD_PeriodicityWang.c SB_BinaryStats.c SB_CoarseGrain.c SB_MotifThree.c SB_TransitionMatrix.c SC_FluctAnal.c SP_Summaries.c butterworth.c fft.c helper_functions.c histcounts.c splinefit.c stats.c

OBJS = $(SRCS:.c=.o)
.PHONY: all;
all: ${TARGET_LIB}
$(TARGET_LIB): $(OBJS)
	$(CC) ${LDFLAGS} -o $@ $^
$(SRCS:.c=.d):%.d:%.c
	$(CC) $(CFLAGS) -MM $< >$@\ninclude $(SRCS:.c=.d)
.PHONY: clean
clean:-${RM} ${TARGET_LIB} ${OBJS} $(SRCS:.c=.d)