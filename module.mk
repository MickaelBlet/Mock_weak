##
## Author: Mickaël BLET
##

DEFAULT_VERSION				=	0.0.0

DEFAULT_NAME				=	$(notdir $(CURDIR))
DEFAULT_BINARY_NAME			=	$(DEFAULT_NAME)
DEFAULT_LIBRARY_NAME		=	$(addsuffix .a, $(DEFAULT_NAME))
DEFAULT_BINARY_DIRECTORY	=	bin/
DEFAULT_LIBRARY_DIRECTORY	=	lib/
DEFAULT_SOURCE_DIRECTORY	=	src/
DEFAULT_TEST_DIRECTORY		=	test/
DEFAULT_INCLUDE_DIRECTORY	=	include/
DEFAULT_OBJECT_DIRECTORY	=	obj/
DEFAULT_SOURCE_EXTENTION	=	.c

DEFAULT_BINARY_EXCLUDE_SOURCE =
DEFAULT_LIBRARY_EXCLUDE_SOURCE =
DEFAULT_TEST_EXCLUDE_SOURCE =

DEFAULT_COMPILER			=	$(CC)
DEFAULT_VARIABLES			=
DEFAULT_COMMON_FLAGS		=	$(CFLAGS)
DEFAULT_DEBUG_FLAGS			=
DEFAULT_RELEASE_FLAGS		=
DEFAULT_TEST_FLAGS			=

DEFAULT_DEBUG_ARCHIVES		=
DEFAULT_RELEASE_ARCHIVES	=

DEFAULT_DEBUG_LIBRARIES		=
DEFAULT_RELEASE_LIBRARIES	=
DEFAULT_TEST_LIBRARIES		=	-lgtest -lgtest_main -lgmock -lpthread

#------------------------------------------------------------------------------
# Can be modified out template

VERSION						:=	$(if $(strip $(VERSION)),$(VERSION),$(DEFAULT_VERSION))

NAME						:=	$(if $(strip $(NAME)),$(NAME),$(DEFAULT_NAME))
BINARY_NAME					:=	$(if $(strip $(BINARY_NAME)),$(BINARY_NAME),$(DEFAULT_BINARY_NAME))
LIBRARY_NAME				:=	$(if $(strip $(LIBRARY_NAME)),$(LIBRARY_NAME),$(DEFAULT_LIBRARY_NAME))
BINARY_DIRECTORY			:=	$(if $(strip $(BINARY_DIRECTORY)),$(BINARY_DIRECTORY),$(DEFAULT_BINARY_DIRECTORY))
LIBRARY_DIRECTORY			:=	$(if $(strip $(LIBRARY_DIRECTORY)),$(LIBRARY_DIRECTORY),$(DEFAULT_LIBRARY_DIRECTORY))
SOURCE_DIRECTORY			:=	$(if $(strip $(SOURCE_DIRECTORY)),$(SOURCE_DIRECTORY),$(DEFAULT_SOURCE_DIRECTORY))
TEST_DIRECTORY				:=	$(if $(strip $(TEST_DIRECTORY)),$(TEST_DIRECTORY),$(DEFAULT_TEST_DIRECTORY))
INCLUDE_DIRECTORY			:=	$(if $(strip $(INCLUDE_DIRECTORY)),$(INCLUDE_DIRECTORY),$(DEFAULT_INCLUDE_DIRECTORY))
OBJECT_DIRECTORY			:=	$(if $(strip $(OBJECT_DIRECTORY)),$(OBJECT_DIRECTORY),$(DEFAULT_OBJECT_DIRECTORY))
SOURCE_EXTENTION			:=	$(if $(strip $(SOURCE_EXTENTION)),$(SOURCE_EXTENTION),$(DEFAULT_SOURCE_EXTENTION))

BINARY_EXCLUDE_SOURCE		:=	$(if $(strip $(BINARY_EXCLUDE_SOURCE)),$(BINARY_EXCLUDE_SOURCE),$(DEFAULT_BINARY_EXCLUDE_SOURCE))
LIBRARY_EXCLUDE_SOURCE		:=	$(if $(strip $(LIBRARY_EXCLUDE_SOURCE)),$(LIBRARY_EXCLUDE_SOURCE),$(DEFAULT_LIBRARY_EXCLUDE_SOURCE))
TEST_EXCLUDE_SOURCE			:=	$(if $(strip $(TEST_EXCLUDE_SOURCE)),$(TEST_EXCLUDE_SOURCE),$(DEFAULT_TEST_EXCLUDE_SOURCE))

COMPILER					:=	$(if $(strip $(COMPILER)),$(COMPILER),$(DEFAULT_COMPILER))
VARIABLES					:=	$(if $(strip $(VARIABLES)),$(VARIABLES),$(DEFAULT_VARIABLES))
COMMON_FLAGS				:=	$(if $(strip $(COMMON_FLAGS)),$(COMMON_FLAGS),$(DEFAULT_COMMON_FLAGS))
DEBUG_FLAGS					:=	$(if $(strip $(DEBUG_FLAGS)),$(DEBUG_FLAGS),$(DEFAULT_DEBUG_FLAGS))
RELEASE_FLAGS				:=	$(if $(strip $(RELEASE_FLAGS)),$(RELEASE_FLAGS),$(DEFAULT_RELEASE_FLAGS))
TEST_FLAGS					:=	$(if $(strip $(TEST_FLAGS)),$(TEST_FLAGS),$(DEFAULT_TEST_FLAGS))

DEBUG_ARCHIVES				:=	$(if $(strip $(DEBUG_ARCHIVES)),$(DEBUG_ARCHIVES),$(DEFAULT_DEBUG_ARCHIVES))
RELEASE_ARCHIVES			:=	$(if $(strip $(RELEASE_ARCHIVES)),$(RELEASE_ARCHIVES),$(DEFAULT_RELEASE_ARCHIVES))

# local libraries (example: -lpthread)
DEBUG_LIBRARIES				:=	$(if $(strip $(DEBUG_LIBRARIES)),$(DEBUG_LIBRARIES),$(DEFAULT_DEBUG_LIBRARIES))
RELEASE_LIBRARIES			:=	$(if $(strip $(RELEASE_LIBRARIES)),$(RELEASE_LIBRARIES),$(DEFAULT_RELEASE_LIBRARIES))
TEST_LIBRARIES				:=	$(if $(strip $(TEST_LIBRARIES)),$(TEST_LIBRARIES),$(DEFAULT_TEST_LIBRARIES))

#------------------------------------------------------------------------------

FIND_SOURCE					=	$(shell find $(SOURCE_DIRECTORY) -name "*$(SOURCE_EXTENTION)")
FIND_TEST					=	$(shell find $(TEST_DIRECTORY) -name "*.cpp")
SOURCE						:=	$(subst $(SOURCE_DIRECTORY),,$(FIND_SOURCE))
TEST						:=	$(subst $(TEST_DIRECTORY),,$(FIND_TEST))

OBJECT_DIRECTORIES			:=	$(addprefix $(OBJECT_DIRECTORY),$(sort $(dir $(SOURCE))) $(sort $(dir $(TEST))))

SOURCE_FILTER				:=	$(filter-out $(BINARY_EXCLUDE_SOURCE),$(SOURCE))
LIBRARY_SOURCE_FILTER		:=	$(filter-out $(LIBRARY_EXCLUDE_SOURCE),$(SOURCE))
TEST_SOURCE_FILTER			:=	$(filter-out $(TEST_EXCLUDE_SOURCE),$(TEST))

VARIABLES_DEFINE			:=	$(addprefix -D,$(sort $(VARIABLES)))

OBJECT_DEBUG				:=	$(addprefix $(OBJECT_DIRECTORY),$(SOURCE_FILTER:$(SOURCE_EXTENTION)=-debug-$(VERSION).o))
OBJECT_RELEASE				:=	$(addprefix $(OBJECT_DIRECTORY),$(SOURCE_FILTER:$(SOURCE_EXTENTION)=-release-$(VERSION).o))
LIBRARY_OBJECT_DEBUG		:=	$(addprefix $(OBJECT_DIRECTORY),$(LIBRARY_SOURCE_FILTER:$(SOURCE_EXTENTION)=-debug-$(VERSION).o))
LIBRARY_OBJECT_RELEASE		:=	$(addprefix $(OBJECT_DIRECTORY),$(LIBRARY_SOURCE_FILTER:$(SOURCE_EXTENTION)=-release-$(VERSION).o))
OBJECT_TEST					:=	$(addprefix $(OBJECT_DIRECTORY),$(TEST_SOURCE_FILTER:.cpp=-test-$(VERSION).o))

INCLUDE_PATH				:=	$(addprefix -I, $(INCLUDE_DIRECTORY))

#------------------------------------------------------------------------------

COLOR_SHELL_DEBUG			=	$$(tput setaf 3)
COLOR_SHELL_RELEASE			=	$$(tput setaf 2)
COLOR_SHELL_TEST			=	$$(tput setaf 4)
COLOR_SHELL_RESET			=	$$(tput sgr0)

#------------------------------------------------------------------------------

all:	test

$(LIBRARY_DIRECTORY) $(BINARY_DIRECTORY) $(OBJECT_DIRECTORIES):
	@mkdir -p $@

$(OBJECT_DIRECTORY)%-debug-$(VERSION).o:	$(SOURCE_DIRECTORY)%$(SOURCE_EXTENTION) | $(OBJECT_DIRECTORIES)
	$(COMPILER) $(COMMON_FLAGS) $(DEBUG_FLAGS) $(VARIABLES_DEFINE) -MMD -c $< -o $@ $(INCLUDE_PATH)

$(OBJECT_DIRECTORY)%-release-$(VERSION).o:	$(SOURCE_DIRECTORY)%$(SOURCE_EXTENTION) | $(OBJECT_DIRECTORIES)
	$(COMPILER) $(COMMON_FLAGS) $(RELEASE_FLAGS) $(VARIABLES_DEFINE) -MMD -c $< -o $@ $(INCLUDE_PATH)

$(OBJECT_DIRECTORY)%-test-$(VERSION).o:		$(TEST_DIRECTORY)%.cpp | $(OBJECT_DIRECTORIES)
	g++ $(COMMON_FLAGS) $(TEST_FLAGS) $(VARIABLES_DEFINE) -MMD -c $< -o $@ $(INCLUDE_PATH)

$(LIBRARY_DIRECTORY)$(basename $(LIBRARY_NAME))-debug.a:	$(LIBRARY_OBJECT_DEBUG) | $(LIBRARY_DIRECTORY)
	ar rc $@ $^
	@printf "$(COLOR_SHELL_DEBUG) /---------\\ \n -  DEBUG  - $(COLOR_SHELL_RESET)$(notdir $@)$(COLOR_SHELL_DEBUG)\n \\---------/ $(COLOR_SHELL_RESET)\n"

$(LIBRARY_DIRECTORY)$(basename $(LIBRARY_NAME))-release.a:	$(LIBRARY_OBJECT_RELEASE) | $(LIBRARY_DIRECTORY)
	ar rc $@ $^
	@printf "$(COLOR_SHELL_RELEASE) /---------\\ \n - RELEASE - $(COLOR_SHELL_RESET)$(notdir $@)$(COLOR_SHELL_RELEASE)\n \\---------/ $(COLOR_SHELL_RESET)\n"

$(BINARY_DIRECTORY)$(BINARY_NAME)-debug:					$(OBJECT_DEBUG) $(DEBUG_ARCHIVES) | $(BINARY_DIRECTORY)
	$(COMPILER) $(COMMON_FLAGS) $(DEBUG_FLAGS) -o $@ $^ $(INCLUDE_PATH) $(DEBUG_LIBRARIES)
	@printf "$(COLOR_SHELL_DEBUG) /---------\\ \n -  DEBUG  - $(COLOR_SHELL_RESET)$(notdir $@)$(COLOR_SHELL_DEBUG)\n \\---------/ $(COLOR_SHELL_RESET)\n"

$(BINARY_DIRECTORY)$(BINARY_NAME)-release:					$(OBJECT_RELEASE) $(RELEASE_ARCHIVES) | $(BINARY_DIRECTORY)
	$(COMPILER) $(COMMON_FLAGS) $(DEBUG_FLAGS) -o $@ $^ $(INCLUDE_PATH) $(RELEASE_LIBRARIES)
	@printf "$(COLOR_SHELL_RELEASE) /---------\\ \n - RELEASE - $(COLOR_SHELL_RESET)$(notdir $@)$(COLOR_SHELL_RELEASE)\n \\---------/ $(COLOR_SHELL_RESET)\n"

$(BINARY_DIRECTORY)$(BINARY_NAME)-test:						$(OBJECT_TEST) $(DEBUG_ARCHIVES) $(LIBRARY_DIRECTORY)$(basename $(LIBRARY_NAME))-debug.a | $(BINARY_DIRECTORY)
	g++ $(COMMON_FLAGS) $(TEST_FLAGS) -o $@ $^ $(INCLUDE_PATH) $(TEST_LIBRARIES)
	@printf "$(COLOR_SHELL_TEST) /---------\\ \n -  TEST   - $(COLOR_SHELL_RESET)$(notdir $@)$(COLOR_SHELL_TEST)\n \\---------/ $(COLOR_SHELL_RESET)\n"

debug:			$(BINARY_DIRECTORY)$(BINARY_NAME)-debug
release:		$(BINARY_DIRECTORY)$(BINARY_NAME)-release
test:			$(BINARY_DIRECTORY)$(BINARY_NAME)-test
lib_debug:		$(LIBRARY_DIRECTORY)$(basename $(LIBRARY_NAME))-debug.a
lib_release:	$(LIBRARY_DIRECTORY)$(basename $(LIBRARY_NAME))-release.a

clean:
	$(RM) \
	$(OBJECT_DEBUG) \
	$(OBJECT_DEBUG:.o=.d) \
	$(OBJECT_RELEASE) \
	$(OBJECT_RELEASE:.o=.d) \
	$(OBJECT_TEST) \
	$(OBJECT_TEST:.o=.d)

re:		clean
	$(MAKE) all

PHONY:	all debug release test lib_debug lib_release clean re

#------------------------------------------------------------------------------

-include $(OBJECT_DEBUG:.o=.d)
-include $(OBJECT_RELEASE:.o=.d)
-include $(OBJECT_TEST:.o=.d)