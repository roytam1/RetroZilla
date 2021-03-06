#
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is the Netscape security libraries.
#
# The Initial Developer of the Original Code is
# Netscape Communications Corporation.
# Portions created by the Initial Developer are Copyright (C) 1994-2000
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****

#
# Configuration common to all versions of Windows NT
# and Windows 95
#

DEFAULT_COMPILER = cl

ifdef NS_USE_GCC
	CC           = gcc
	CCC          = g++
	LINK         = ld
	AR           = ar
	AR          += cr $@
	RANLIB       = ranlib
	BSDECHO      = echo
	RC           = windres.exe -O coff --use-temp-file
	LINK_DLL      = $(CC) $(OS_DLLFLAGS) $(DLLFLAGS)
else
	CC           = cl
	CCC          = cl
	LINK         = link
	AR           = lib
	AR          += -NOLOGO -OUT:"$@"
	RANLIB       = echo
	BSDECHO      = echo
	RC           = rc.exe
	MT           = mt.exe
	# Determine compiler version
	_MSC_VER_6   = 1200	# MSVC 6
	_MSC_VER    := $(shell $(CC) 2>&1 | sed -ne \
                       's/.*[^0-9.]\([0-9]\{1,\}\)\.\([0-9]\{1,\}\).*/\1\2/p' )
endif

ifdef BUILD_TREE
NSINSTALL_DIR  = $(BUILD_TREE)/nss
else
NSINSTALL_DIR  = $(CORE_DEPTH)/coreconf/nsinstall
endif
NSINSTALL      = nsinstall

MKDEPEND_DIR    = $(CORE_DEPTH)/coreconf/mkdepend
MKDEPEND        = $(MKDEPEND_DIR)/$(OBJDIR_NAME)/mkdepend.exe
# Note: MKDEPENDENCIES __MUST__ be a relative pathname, not absolute.
# If it is absolute, gmake will crash unless the named file exists.
MKDEPENDENCIES  = $(OBJDIR_NAME)/depend.mk

INSTALL      = $(NSINSTALL)
MAKE_OBJDIR  = mkdir
MAKE_OBJDIR += $(OBJDIR)
GARBAGE     += $(OBJDIR)/vc20.pdb $(OBJDIR)/vc40.pdb
XP_DEFINE   += -DXP_PC
ifdef NS_USE_GCC
LIB_SUFFIX   = a
else
LIB_SUFFIX   = lib
endif
DLL_SUFFIX   = dll

ifdef NS_USE_GCC
    # The -mnop-fun-dllimport flag allows us to avoid a drawback of
    # the dllimport attribute that a pointer to a function marked as
    # dllimport cannot be used as as a constant address.
    OS_CFLAGS += -mno-cygwin -mms-bitfields -mnop-fun-dllimport
    _GEN_IMPORT_LIB=-Wl,--out-implib,$(IMPORT_LIBRARY)
    DLLFLAGS  += -mno-cygwin -o $@ -shared -Wl,--export-all-symbols $(if $(IMPORT_LIBRARY),$(_GEN_IMPORT_LIB))
    ifdef BUILD_OPT
	ifeq (11,$(ALLOW_OPT_CODE_SIZE)$(OPT_CODE_SIZE))
		OPTIMIZER += -Os
	else
		OPTIMIZER += -O2
	endif
	DEFINES    += -UDEBUG -U_DEBUG -DNDEBUG
    else
	OPTIMIZER  += -g
	NULLSTRING :=
	SPACE      := $(NULLSTRING) # end of the line
	USERNAME   := $(subst $(SPACE),_,$(USERNAME))
	USERNAME   := $(subst -,_,$(USERNAME))
	DEFINES    += -DDEBUG -D_DEBUG -UNDEBUG -DDEBUG_$(USERNAME)
    endif
else # !NS_USE_GCC
    OS_CFLAGS += -W3 -nologo -D_CRT_SECURE_NO_WARNINGS
    OS_DLLFLAGS += -nologo -DLL -SUBSYSTEM:WINDOWS
    ifeq ($(_MSC_VER),$(_MSC_VER_6))
    ifndef MOZ_DEBUG_SYMBOLS
	OS_DLLFLAGS += -PDB:NONE
    endif
    endif
    ifdef BUILD_OPT
	OS_CFLAGS  += -MD
	ifeq (11,$(ALLOW_OPT_CODE_SIZE)$(OPT_CODE_SIZE))
		OPTIMIZER += -O1
	else
		OPTIMIZER += -O2
	endif
	DEFINES    += -UDEBUG -U_DEBUG -DNDEBUG
	DLLFLAGS   += -OUT:"$@"
	ifdef MOZ_DEBUG_SYMBOLS
		OPTIMIZER += -Zi -Fd$(OBJDIR)/
		DLLFLAGS += -DEBUG -OPT:REF
		LDFLAGS += -DEBUG -OPT:REF
	endif
    else
	#
	# Define USE_DEBUG_RTL if you want to use the debug runtime library
	# (RTL) in the debug build
	#
	ifdef USE_DEBUG_RTL
		OS_CFLAGS += -MDd
	else
		OS_CFLAGS += -MD
	endif
	OPTIMIZER += -Zi -Fd$(OBJDIR)/ -Od
	NULLSTRING :=
	SPACE      := $(NULLSTRING) # end of the line
	USERNAME   := $(subst $(SPACE),_,$(USERNAME))
	USERNAME   := $(subst -,_,$(USERNAME))
	DEFINES    += -DDEBUG -D_DEBUG -UNDEBUG -DDEBUG_$(USERNAME)
	DLLFLAGS   += -DEBUG -OUT:"$@"
	LDFLAGS    += -DEBUG 
ifeq ($(_MSC_VER),$(_MSC_VER_6))
ifndef MOZ_DEBUG_SYMBOLS
	LDFLAGS    += -PDB:NONE 
endif
endif
	# Purify requires /FIXED:NO when linking EXEs.
	LDFLAGS    += /FIXED:NO
    endif
ifneq ($(_MSC_VER),$(_MSC_VER_6))
    # Convert certain deadly warnings to errors (see list at end of file)
    OS_CFLAGS += -we4002 -we4003 -we4004 -we4006 -we4009 -we4013 \
     -we4015 -we4028 -we4033 -we4035 -we4045 -we4047 -we4053 -we4054 -we4063 \
     -we4064 -we4078 -we4087 -we4098 -we4390 -we4551 -we4553 -we4715
endif # !MSVC6
endif # NS_USE_GCC

ifdef USE_64
DEFINES += -DWIN64
else
DEFINES += -DWIN32
endif

ifeq ($(CPU_ARCH), x386)
ifdef USE_64
	DEFINES += -D_AMD64_
else
	DEFINES += -D_X86_
endif
endif
ifeq ($(CPU_ARCH), ALPHA)
	DEFINES += -D_ALPHA_=1
endif

ifdef MAPFILE
ifndef NS_USE_GCC
DLLFLAGS += -DEF:$(MAPFILE)
endif
endif
# Change PROCESS to put the mapfile in the correct format for this platform
PROCESS_MAP_FILE = cp $< $@


#
#  The following is NOT needed for the NSPR 2.0 library.
#

DEFINES += -D_WINDOWS

# override default, which is ASFLAGS = CFLAGS
ifdef NS_USE_GCC
	AS	= $(CC)
	ASFLAGS = $(INCLUDES)
else
ifdef USE_64
	AS	= ml64.exe
	ASFLAGS = -Cp -Sn -Zi $(INCLUDES)
else
	AS	= ml.exe
	ASFLAGS = -Cp -Sn -Zi -coff $(INCLUDES)
endif
endif

#
# override the definitions of RELEASE_TREE found in tree.mk
#
ifndef RELEASE_TREE
    ifdef BUILD_SHIP
	ifdef USE_SHIPS
	    RELEASE_TREE = $(NTBUILD_SHIP)
	else
	    RELEASE_TREE = //redbuild/components
	endif
    else
	RELEASE_TREE = //redbuild/components
    endif
endif

#
# override the definitions of IMPORT_LIB_PREFIX, LIB_PREFIX, and
# DLL_PREFIX in prefix.mk
#

ifndef IMPORT_LIB_PREFIX
    ifdef NS_USE_GCC
	IMPORT_LIB_PREFIX = lib
    else
	IMPORT_LIB_PREFIX = $(NULL)
    endif
endif

ifndef LIB_PREFIX
    ifdef NS_USE_GCC
	LIB_PREFIX = lib
    else
	LIB_PREFIX = $(NULL)
    endif
endif

ifndef DLL_PREFIX
    DLL_PREFIX =  $(NULL)
endif

#
# override the definitions of various _SUFFIX symbols in suffix.mk
#

#
# Object suffixes
#
ifndef OBJ_SUFFIX
    ifdef NS_USE_GCC
	OBJ_SUFFIX = .o
    else
	OBJ_SUFFIX = .obj
    endif
endif

#
# Assembler source suffixes
#
ifndef ASM_SUFFIX
    ifdef NS_USE_GCC
	ASM_SUFFIX = .s
    else
	ASM_SUFFIX = .asm
    endif
endif

#
# Library suffixes
#

ifndef IMPORT_LIB_SUFFIX
    IMPORT_LIB_SUFFIX = .$(LIB_SUFFIX)
endif

ifndef DYNAMIC_LIB_SUFFIX_FOR_LINKING
    DYNAMIC_LIB_SUFFIX_FOR_LINKING = $(IMPORT_LIB_SUFFIX)
endif

#
# Program suffixes
#
ifndef PROG_SUFFIX
    PROG_SUFFIX = .exe
endif

#
# When the processor is NOT 386-based on Windows NT, override the
# value of $(CPU_TAG).  For WinNT, 95, 16, not CE.
#
ifneq ($(CPU_ARCH),x386)
    CPU_TAG = _$(CPU_ARCH)
endif

#
# override ruleset.mk, removing the "lib" prefix for library names, and
# adding the "32" after the LIBRARY_VERSION.
#
ifdef LIBRARY_NAME
    SHARED_LIBRARY = $(OBJDIR)/$(LIBRARY_NAME)$(LIBRARY_VERSION)32$(JDK_DEBUG_SUFFIX).dll
    IMPORT_LIBRARY = $(OBJDIR)/$(LIBRARY_NAME)$(LIBRARY_VERSION)32$(JDK_DEBUG_SUFFIX).lib
endif

#
# override the TARGETS defined in ruleset.mk, adding IMPORT_LIBRARY
#
ifndef TARGETS
    TARGETS = $(LIBRARY) $(SHARED_LIBRARY) $(IMPORT_LIBRARY) $(PROGRAM)
endif

# list of MSVC warnings converted to errors above:
# 4002: too many actual parameters for macro 'identifier'
# 4003: not enough actual parameters for macro 'identifier'
# 4004: incorrect construction after 'defined'
# 4006: #undef expected an identifier
# 4009: string too big; trailing characters truncated
# 4015: 'identifier' : type of bit field must be integral
# 4028: formal parameter different from declaration
# 4033: 'function' must return a value
# 4035: 'function' : no return value
# 4045: 'identifier' : array bounds overflow
# 4047: 'function' : 'type 1' differs in levels of indirection from 'type 2'
# 4053: one void operand for '?:'
# 4054: 'conversion' : from function pointer 'type1' to data pointer 'type2'
# 4059: pascal string too big, length byte is length % 256
# 4063: case 'identifier' is not a valid value for switch of enum 'identifier'
# 4064: switch of incomplete enum 'identifier'
# 4078: case constant 'value' too big for the type of the switch expression
# 4087: 'function' : declared with 'void' parameter list
# 4098: 'function' : void function returning a value
# 4390: ';' : empty controlled statement found; is this the intent?
# 4541: RTTI train wreck
# 4715: not all control paths return a value
# 4013: function undefined; assuming extern returning int
# 4553: '==' : operator has no effect; did you intend '='?
# 4551: function call missing argument list

