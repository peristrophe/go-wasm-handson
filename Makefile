SOURCEDIR    := src
DOCUMENTROOT := public
TARGET_CTX   := run

.PHONY: prepare run test clean

prepare:
ifeq ($(shell which goexec),)
	go install github.com/shurcooL/goexec@latest
endif

clean:
	-rm -r $(DOCUMENTROOT)

$(DOCUMENTROOT)/wasm_exec.js:
	mkdir -p $(DOCUMENTROOT)
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.js $(DOCUMENTROOT)/

$(DOCUMENTROOT)/index.html:
	mkdir -p $(DOCUMENTROOT)
ifeq ($(TARGET_CTX),test)
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.html $(DOCUMENTROOT)/index.html
else
	cp $(SOURCEDIR)/index.html $(DOCUMENTROOT)/
endif

$(DOCUMENTROOT)/test.wasm:
	GOOS=js GOARCH=wasm go build -o $(DOCUMENTROOT)/test.wasm $(SOURCEDIR)/test.go

$(DOCUMENTROOT)/calc.wasm:
	GOOS=js GOARCH=wasm go build -o $(DOCUMENTROOT)/calc.wasm $(SOURCEDIR)/calc.go

test: prepare
	$(MAKE) clean
	$(MAKE) $(DOCUMENTROOT)/wasm_exec.js $(DOCUMENTROOT)/index.html $(DOCUMENTROOT)/test.wasm TARGET_CTX=test
	@echo
	@echo "ACCESS TO http://localhost:8080/"
	goexec 'http.ListenAndServe(`:8080`, http.FileServer(http.Dir(`$(DOCUMENTROOT)/`)))'

run: prepare
	$(MAKE) clean
	$(MAKE) $(DOCUMENTROOT)/wasm_exec.js $(DOCUMENTROOT)/index.html $(DOCUMENTROOT)/calc.wasm TARGET_CTX=run
	@echo
	@echo "ACCESS TO http://localhost:8080/"
	goexec 'http.ListenAndServe(`:8080`, http.FileServer(http.Dir(`$(DOCUMENTROOT)/`)))'
