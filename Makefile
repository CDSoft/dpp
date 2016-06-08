# DPP
# Copyright (C) 2015, 2016 Christophe Delord
# http://www.cdsoft.fr/dpp
#
# This file is part of DPP.
#
# DPP is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DPP is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DPP.  If not, see <http://www.gnu.org/licenses/>.

#####################################################################
# Platform detection
#####################################################################

OS = $(shell uname)

GHCOPT = -Wall -Werror -O2

ifeq "$(OS)" "Linux"

DPP = dpp
GPP = gpp

all: gpp dpp README.md
all: dpp.tgz
all: doc/gpp.html doc/dpp.html

all: gpp.exe dpp.exe

CCWIN = i686-w64-mingw32-gcc
WINE = wine

else
ifeq "$(OS)" "MINGW32_NT-6.1"

DPP = dpp.exe
GPP = gpp.exe

all: gpp.exe dpp.exe
all: doc/gpp.html doc/dpp.html

CCWIN = gcc
WINE =

else
ifeq "$(OS)" "CYGWIN_NT-6.1-WOW"

DPP = dpp.exe
GPP = gpp.exe

all: gpp.exe dpp.exe
all: doc/gpp.html doc/dpp.html

CCWIN = mingw32-gcc
WINE =

else
$(error "Unknown platform: $(OS)")
endif
endif
endif

BUILD = .build
CACHE = .cache

install: $(DPP) $(GPP)
	install -v -C $^ $(shell (ls -d /usr/local/bin || echo /usr/bin) 2>/dev/null)

clean:
	rm -rf $(BUILD) doc
	rm -f gpp gpp.exe dpp dpp.exe
	rm -f dpp.tgz

.DELETE_ON_ERROR:

#####################################################################
# README
#####################################################################

README.md: $(GPP) $(DPP)
README.md: src/dpp.md
	@mkdir -p doc/img
	./$(GPP) -T -x $< | ./$(DPP) | pandoc -f markdown -t markdown_github > $@

#####################################################################
# archives
#####################################################################

dpp.tgz: Makefile $(wildcard src/*) README.md LICENSE .gitignore
	tar -czf $@ $^

#####################################################################
# GPP
#####################################################################

GPP_URL = http://files.nothingisreal.com/software/gpp/gpp.tar.bz2

gpp: BUILDGPP=$(BUILD)/$@
gpp: $(CACHE)/$(notdir $(GPP_URL))
	@mkdir -p $(BUILDGPP)
	tar xjf $< -C $(BUILDGPP)
	cd $(BUILDGPP)/gpp-* && ./configure && make
	cp $(BUILDGPP)/gpp-*/src/gpp $@
	@strip $@

gpp.exe: BUILDGPP=$(BUILD)/$@
gpp.exe: $(CACHE)/$(notdir $(GPP_URL))
	@mkdir -p $(BUILDGPP)
	tar xjf $< -C $(BUILDGPP)
	export CC=$(CCWIN); cd $(BUILDGPP)/gpp-* && ./configure --host $(shell uname) && make
	cp $(BUILDGPP)/gpp-*/src/gpp.exe $@
	@strip $@

$(CACHE)/$(notdir $(GPP_URL)):
	@mkdir -p $(dir $@)
	wget $(GPP_URL) -O $@

doc/gpp.html: $(GPP)
	@mkdir -p $(dir $@)
	cp $(BUILD)/$</gpp-*/doc/gpp.html $@

#####################################################################
# Dependencies
#####################################################################

PLANTUML = plantuml
PLANTUML_URL = http://heanet.dl.sourceforge.net/project/plantuml/$(PLANTUML).jar

DITAA_VERSION = 0.9
DITAA = ditaa0_9
DITAA_URL = http://freefr.dl.sourceforge.net/project/ditaa/ditaa/$(DITAA_VERSION)/$(DITAA).zip

$(BUILD)/%.o: $(BUILD)/%.c
	gcc -c -o $@ $^

$(BUILD)/%-win.o: $(BUILD)/%.c
	$(CCWIN) -c -o $@ $^

$(BUILD)/%.c: $(CACHE)/%.jar
	@mkdir -p $(dir $@)
	xxd -i $< $@
	sed -i 's/_cache_//g' $@

$(CACHE)/$(PLANTUML).jar:
	@mkdir -p $(dir $@)
	wget $(PLANTUML_URL) -O $@

$(CACHE)/$(DITAA).zip:
	@mkdir -p $(dir $@)
	wget $(DITAA_URL) -O $@

$(CACHE)/$(DITAA).jar: $(CACHE)/$(DITAA).zip
	unzip $< $(notdir $@) -d $(dir $@)
	@touch $@

$(CACHE)/dpp.css:
	@mkdir -p $(dir $@)
	wget http://cdsoft.fr/cdsoft.css -O $@

#####################################################################
# DPP
#####################################################################

dpp: src/dpp.c $(BUILD)/$(PLANTUML).o $(BUILD)/$(DITAA).o
	gcc -Werror -Wall $^ -o $@
	@strip $@

dpp.exe: src/dpp.c $(BUILD)/$(PLANTUML)-win.o $(BUILD)/$(DITAA)-win.o
	$(CCWIN) -Werror -Wall $^ -o $@
	@strip $@

doc/dpp.html: $(GPP) $(DPP) doc/dpp.css
doc/dpp.html: src/dpp.md
	@mkdir -p $(dir $@) doc/img
	./$(GPP) -T -x $< | ./$(DPP) | pandoc -S --toc --self-contained -c doc/dpp.css -f markdown -t html5 > $@

doc/dpp.css: $(CACHE)/dpp.css
	@mkdir -p $(dir $@)
	cp $< $@

