venv: .binder/requirements.txt
	python -m venv $@
	$@/bin/pip install -r .binder/requirements.txt
	source $@/bin/activate && .binder/postBuild

.PHONY: start
start: venv
	venv/bin/jupyter lab notebooks
