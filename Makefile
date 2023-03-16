SOURCES := $(wildcard *.cpp)
OBJECTS := $(patsubst %.cpp,%.o,$(SOURCES))
DEPENDS := $(patsubst %.o,%.d,$(OBJECTS))

TARGET   := mboxzilla
CXXFLAGS := -std=c++11
CPPFLAGS := -MMD -DELPP_THREAD_SAFE -DELPP_NO_DEFAULT_LOG_FILE
LDLIBS   := -lcurl -lcrypto -lz

JSON_VERSION        ?= v3.11.2
CXXOPTS_VERSION     ?= v3.1.1
SIMPLEINI_VERSION   ?= 4.19
EASYLOGGING_VERSION ?= v9.97.0

ifdef DEBUG
CXXFLAGS += -g
else
CXXFLAGS += -Os
endif

# If running Windows:
ifdef COMSPEC
    TARGET   := mboxzilla.exe
    CPPFLAGS += -DCURL_STATICLIB
    LDLIBS   += -lpthread -lssl -lssh2 -lws2_32 -lwldap32 -lwinrm -lgdi32
else
    # If running MacOS:
    ifeq ($(shell uname),Darwin)
        OPENSSL_PREFIX := $(shell brew --prefix openssl)
        CPPFLAGS       += -I$(OPENSSL_PREFIX)/include
        LDFLAGS        += -L$(OPENSSL_PREFIX)/lib
    endif
endif

# Define a cross-platform macro for downloading files.
ifdef COMSPEC
   download-file = Invoke-WebRequest -Uri $1 -OutFile $2 | Out-Null
else
   download-file = curl -s -L -o $1 $2
endif

.PHONY: all clean install update

all: $(TARGET)

clean:
	$(RM) $(TARGET) $(OBJECTS) $(DEPENDS)

install: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $@ $^ $(LDFLAGS) $(LDLIBS)

# Include all dependencies.
-include $(DEPENDS)

update: update-json update-cxxopts update-simpleini update-easylogging

update-json:
	$(call download-file, json.hpp, "https://github.com/nlohmann/json/releases/download/$(JSON_VERSION)/json.hpp")

update-cxxopts:
	$(call download-file, cxxopts.hpp, "https://raw.githubusercontent.com/jarro2783/cxxopts/$(CXXOPTS_VERSION)/include/cxxopts.hpp")

update-simpleini:
	$(call download-file, SimpleIni.h, "https://raw.githubusercontent.com/brofield/simpleini/$(SIMPLEINI_VERSION)/SimpleIni.h")
	$(call download-file, ConvertUTF.h, "https://raw.githubusercontent.com/brofield/simpleini/$(SIMPLEINI_VERSION)/ConvertUTF.h")

update-easylogging:
	$(call download-file, easylogging++.cpp, "https://github.com/amrayn/easyloggingpp/raw/$(EASYLOGGING_VERSION)/src/easylogging%2B%2B.cc")
	$(call download-file, easylogging++.h, "https://github.com/amrayn/easyloggingpp/raw/$(EASYLOGGING_VERSION)/src/easylogging%2B%2B.h")
