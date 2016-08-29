default:.sentinel release
all:default test #debug
vpath %.hpp $(DIR_ROOT_INCLUDE)
vpath %.cpp $(DIR_ROOT_SRC)

.sentinel:
	$(MKDIR) $(SENTINEL_DIRS)
	@touch .sentinel

$(DIR_GL3W)%$(OBJ_EXT): $(DIR_GL3W)$(DIR_SRC)*.c
	$(COMPILE_CC) -fPIC $<\
		-o $@
$(DIR_GL3W)lib%$(OBJ_EXT)$(DIR_GL3W)%$(DLL_EXT): $(DIR_GL3W)$(DIR_SRC)*.c
	$(LINK_CC) $(CFLAGS) -shared $<\
		-o $@

$(DIR_ROOT_LIB)%$(OBJ_EXT):\
		$(DIR_ROOT_SRC)%.cpp $(DIR_ROOT_INCLUDE)%.hpp
	$(COMPILE_CXX) $<\
		-o $@

$(DIR_ROOT_LIB)%$(DEP_EXT):\
		$(DIR_ROOT_SRC)%.cpp $(DIR_ROOT_INCLUDE)%.hpp
	$(DEPEND_CXX) $<\
		-o $@
$(DIR_ROOT_LIB)*/%$(DEP_EXT):\
		$(DIR_ROOT_SRC)*/%.cpp $(DIR_ROOT_INCLUDE)*/%.hpp
	$(DEPEND_CXX) $<\
		-o $@
$(DIR_ROOT_LIB)main$(OBJ_EXT):\
		$(DIR_ROOT_SRC)main.cpp $(DIR_ROOT_INCLUDE)main.hpp
	$(COMPILE_CXX) $<\
		$(RELEASE_CPPFLAGS)\
		-o $@

lib%$(DLL_EXT): $(MAIN_SRCS)
	$(LINK_CXX) -shared $<\
		-o $@ $(LDFLAGS)

%.hpp$(PCH_EXT): %.hpp
	$(COMPILE_HPP) $<\
		-o $@

clean-deps:; $(RM) $(EXE_OBJS:.o=.d) $(MAIN_DEPS) 
clean-pchs:; $(RM) $(MAIN_PCHS)
clean-objs:; $(RM) $(EXE_OBJS) $(MAIN_OBJS)
clean-dlls:; $(RM) $(MAIN_DLLS)
clean-exes:; $(RM) $(EXES)
clean-sentinels:; $(RM) .sentinel
clean-gl3w:; $(RM) $(GL3W_OBJS)
clean: clean-exes clean-dlls clean-deps clean-objs clean-pchs clean-sentinels;

env:; @echo "$(foreach var,CC CXX CFLAGS CPPFLAGS WFLAGS\
		RELEASE_LDFLAGS TEST_LDFLAGS MAIN_OBJS\
		MAIN_DLLS MAIN_DLL_LINKS,\r$(var) = ${$(var)}\n)"

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(MAKECMDGOALS),.sentinel)
ifneq ($(MAKECMDGOALS),env)
	-include $(MAIN_DEPS)
endif
endif
endif

release: $(MAIN_OBJS) $(MAIN_DEPS)\
		$(RELEASE_OBJ) $(GL3W_OBJS) $(RELEASE_EXE);
$(RELEASE_EXE): $(RELEASE_OBJ) $(MAIN_OBJS) $(GL3W_OBJS)
	$(LINK_CXX) -fPIE\
		$(RELEASE_OBJ) $(MAIN_OBJS) $(GL3W_OBJS) $(RELEASE_LDFLAGS)\
		-o $@

test: $(TEST_EXES) ; # use --log_level=error

$(DIR_ROOT_BIN)%$(TEST_EXT)$(EXE_EXT):\
		$(DIR_TEST)$(DIR_SRC)%.cpp $(MAIN_OBJS)
	$(LINK_CXX) -fPIE\
		$< $(MAIN_OBJS) $(GL3W_OBJS)\
		$(TEST_LDFLAGS)\
		-o $@

$(DIR_ROOT_BIN)model$(TEST_EXT)$(EXE_EXT):\
		$(DIR_TEST)$(DIR_SRC)model.cpp $(MAIN_OBJS)
	$(LINK_CXX) -fPIE\
		$< $(MAIN_OBJS) $(GL3W_OBJS)\
		$(TEST_LDFLAGS)\
		$(MODEL_CPPFLAGS)\
		-o $@

.PHONY: all depends env release test debug\
	clean clean-exes clean-dlls clean-deps clean-objs clean-sentinels
