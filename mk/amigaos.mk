# GNU -*-Makefile-*- to build GNU Make on Amiga with the m68k-amigaos-gcc
# cross compiler (bebbo's amiga-gcc / AmigaDev).
#
# Amiga overrides for use with Basic.mk.  Selected by MAKE_HOST=m68k-amigaos
# (Basic.mk loads mk/<last word of MAKE_HOST>.mk).  For the native SAS/C
# build see mk/Amiga.mk.
#
# Example:
#   PATH=/opt/amiga/bin:$PATH make -f Basic.mk MAKE_HOST=m68k-amigaos OUTDIR=out/
#
# OUTDIR must end in a slash if set.
#
# This file is part of GNU Make.
#
# GNU Make is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# GNU Make is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <https://www.gnu.org/licenses/>.

CC = m68k-amigaos-gcc
LD = $(CC)

CFLAGS = -O2 -noixemul
LDFLAGS = -noixemul
LDLIBS = -lm

# src/config.ami includes "src/mkcustom.h" relative to the source root.
CPPFLAGS = -D_AMIGA -I$(SRCDIR)

prog_SOURCES += $(alloca_SOURCES) $(loadavg_SOURCES) $(glob_SOURCES) $(amiga_SOURCES)

BUILT_SOURCES += $(lib)alloca.h $(lib)fnmatch.h $(lib)glob.h

$(OUTDIR)src/config.h: $(SRCDIR)/src/config.ami | $(OUTDIR)src
	$(call CP.cmd,$<,$@)

$(OUTDIR)src:
	$(call MKDIR.cmd,$@)

$(OBJECTS): $(OUTDIR)src/config.h
