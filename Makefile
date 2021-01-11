# Set Project directory
.POSIX:

PROJDIR := .
SOURCEDIR := $(PROJDIR)/src
INCLUDEDIR := $(PROJDIR)/include/csp
BUILDDIR := $(PROJDIR)/build

#Name of the final executable
TARGET = csp_app.elf

# Decide if commands should be shown or not
VERBOSE = TRUE

ifeq ($(VERBOSE),TRUE)
	HIDE =
else
	HIDE = $
endif

# Create the list of directories
DIRS = . rtable interfaces transport drivers drivers/can crypto arch arch/posix
DIRS_H = . interfaces drivers crypto arch arch/posix
SOURCEDIRS = $(foreach dir, $(DIRS), $(addprefix $(SOURCEDIR)/, $(dir)))
TARGETDIRS = $(foreach dir, $(DIRS), $(addprefix $(BUILDDIR)/, $(dir)))
INCDIRS = $(foreach dir, $(DIRS_H), $(addprefix $(INCLUDEDIR)/, $(dir)))

# Generate the GCC include parameters
INCLUDES += -I$(PROJDIR)/include

# Add the list to VPATH
VPATH = $(SOURCEDIRS)

#Create a list of *.c sources in dir
SRC = $(foreach dir, $(SOURCEDIRS), $(wildcard $(dir)/*.c))
RM_SRC = ./src/rtable/csp_rtable_cidr.c  
SRC_S = $(subst $(SOURCEDIR)/,, $(SRC))

OBJS := $(subst $(SOURCEDIR), $(BUILDDIR), $(SRC:.c=.o))
#OBJS := $(addprefix $(BUILDDIR)/, $(notdir $(OBJS)))
OBJ_S := $(subst $(BUILDDIR)/,, $(OBJS)) 

# Define dependencies files for all objects
DEPS = $(OBJS:.o=.d)

# Compiler settings
CC = gcc
CFLAGS = -g -Wall -O2

RM = rm -rf
RMDIR = rm -rf
MKDIR = mkdir -p
ERRIGNORE = 2>/dev/null
SEP =/

PSEP = $(strip $(SEP))

# Define the function that will generate each rule
define generateRules
$(1)/%.o: %.c
	@echo Building $$@
	$(HIDE)$(CC) -c $$(INCLUDES) -o $$(subst /,$$(PSEP),$$@) $$(subst /,$$(PSEP),$$<) -MMD
endef

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.c
	@echo Building $@
	$(HIDE)$(CC) $(CLFAGS) $(INCLUDES) -c $< -o $@ -MMD

.PHONY: all directories clean
all: directories $(TARGET)

$(TARGET): $(OBJS)
	$(HIDE)echo Linking $@
	$(HIDE)$(CC) -pthread $(OBJS) -o $@

# Include dependencies
#-include $(DEPS)

# Generate rules
#$(foreach targetdir, $(TARGETDIRS), $(eval $(call generateRules, $(targetdir))))

directories:
	$(HIDE)$(MKDIR) $(subst /,$(PSEP),$(TARGETDIRS)) $(ERRIGNORE)

.PHONY: test clean
test:
	@echo $(PROJDIR)
	@echo $(SOURCEDIRS)
	@echo $(SRC_o)
	@echo $(OBJ_S)

# Remove all objects, dependencies and executable files generated during the build process
clean:
		@rm -rf build

test_src:
	@echo $(SRC)
