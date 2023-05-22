GOOS         := js
GOARCH       := wasm
DOCUMENTROOT := docs

.PHONY: prepare run clean

prepare: $(DOCUMENTROOT)/wasm_exec.js $(DOCUMENTROOT)/wasm_exec.html
ifeq ($(shell which goexec),)
	#go install github.com/shurcooL/goexec@latest
endif

$(DOCUMENTROOT)/wasm_exec.js:
	mkdir -p $(DOCUMENTROOT)
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.js $(DOCUMENTROOT)/

$(DOCUMENTROOT)/wasm_exec.html:
	mkdir -p $(DOCUMENTROOT)
	cp $(shell go env GOROOT)/misc/wasm/wasm_exec.html $(DOCUMENTROOT)/

$(DOCUMENTROOT)/test.wasm:
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(DOCUMENTROOT)/test.wasm main.go

run: prepare $(DOCUMENTROOT)/test.wasm
	goexec 'http.ListenAndServe(`:8080`, http.FileServer(http.Dir(`$(DOCUMENTROOT)/`)))'

clean:
	rm -r $(DOCUMENTROOT)
