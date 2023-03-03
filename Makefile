SOURCES := $(wildcard *.cpp)
OBJECTS := $(patsubst %.cpp,%.o,$(SOURCES))
DEPENDS := $(patsubst %.o,%.d,$(OBJECTS))

TARGET   := mboxzilla
CXXFLAGS := -std=c++11
CPPFLAGS := -MMD -DELPP_THREAD_SAFE -DELPP_NO_DEFAULT_LOG_FILE
LDLIBS   := -lcurl -lcrypto -lz

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

.PHONY: all clean install

all: $(TARGET)

clean:
	$(RM) $(TARGET) $(OBJECTS) $(DEPENDS)

install: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -o $@ $^ $(LDFLAGS) $(LDLIBS)

# Include all dependencies.
-include $(DEPENDS)
