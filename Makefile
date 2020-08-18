FDK_DIR=$(CURDIR)/fdk-aac

DIST_DIR=$(FDK_DIR)/dist
FDK_LIB=$(DIST_DIR)/lib/libfdk-aac.so

default: dist/daac.js

dist/daac.js: $(FDK_LIB)
	@mkdir -p dist
	emcc $^ -Oz -Os \
		-s WASM=1 -s NODEJS_CATCH_EXIT=0 \
		-s EXPORTED_FUNCTIONS="['_malloc', '_calloc', '_free']" \
		-o $@
	@[ -f dist/daac.js ]
	@echo "module.exports = Module" >> dist/daac.js

$(FDK_LIB): fdk-aac/configure
	emmake $(MAKE) -j8 -C $(FDK_DIR)
	emmake $(MAKE) -C $(FDK_DIR) install

fdk-aac/configure: fdk-aac/autogen.sh
	cd $(FDK_DIR) && \
	emconfigure ./configure CFLAGS="-Oz" --prefix="$(DIST_DIR)" --host=x86-none-linux

fdk-aac/autogen.sh:
	git submodule update --init
	cd $(FDK_DIR) && ./autogen.sh

clean:
	$(MAKE) -C $(FDK_DIR) clean
	rm -rf $(DIST_DIR) dist

.PHONY: clean