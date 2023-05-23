SOURCEDIR    := src
DOCUMENTROOT := public

.PHONY: prepare run clean

prepare:
ifeq ($(shell which goexec),)
	go install github.com/shurcooL/goexec@latest
endif

$(DOCUMENTROOT)/wasm_exec.js:
	mkdir -p $(DOCUMENTROOT)
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.js $(DOCUMENTROOT)/

$(DOCUMENTROOT)/wasm_exec.html:
	mkdir -p $(DOCUMENTROOT)
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.html $(DOCUMENTROOT)/

$(DOCUMENTROOT)/wasm_calc.html:
	mkdir -p $(DOCUMENTROOT)
	cp $(SOURCEDIR)/wasm_calc.html $(DOCUMENTROOT)/

$(DOCUMENTROOT)/test.wasm:
	GOOS=js GOARCH=wasm go build -o $(DOCUMENTROOT)/test.wasm $(SOURCEDIR)/test.go

$(DOCUMENTROOT)/calc.wasm:
	GOOS=js GOARCH=wasm go build -o $(DOCUMENTROOT)/calc.wasm $(SOURCEDIR)/calc.go

run-test: prepare
	$(MAKE) clean
	$(MAKE) $(DOCUMENTROOT)/wasm_exec.js $(DOCUMENTROOT)/wasm_exec.html $(DOCUMENTROOT)/test.wasm
	goexec 'http.ListenAndServe(`:8080`, http.FileServer(http.Dir(`$(DOCUMENTROOT)/`)))'

run-calc: prepare
	$(MAKE) clean
	$(MAKE) $(DOCUMENTROOT)/wasm_exec.js $(DOCUMENTROOT)/wasm_calc.html $(DOCUMENTROOT)/calc.wasm
	goexec 'http.ListenAndServe(`:8080`, http.FileServer(http.Dir(`$(DOCUMENTROOT)/`)))'

clean:
	-rm -r $(DOCUMENTROOT)
