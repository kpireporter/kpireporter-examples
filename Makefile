.PHONY: build
build:
	docker build -t kpireporter-examples:latest .

.PHONY: start
start: build
	docker run --rm -it -v $(PWD):/work -p 127.0.0.1:8888:8888 -w /work \
		kpireporter-examples jupyter lab --NotebookApp.allow_origin='*'

.PHONY: convert
convert: build
	mkdir -p _build
	docker run --rm -it -v $(PWD):/work -w /work \
		kpireporter-examples jupyter nbconvert \
		--to markdown --output-dir _build --template nbconvert/templates/collapse \
		*/*.ipynb
