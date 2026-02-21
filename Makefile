VENV = venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip

.PHONY: install lint test format run clean

install:
	python3.11 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r server/requirements.txt
	$(PIP) install -r requirements-dev.txt

active:
	source $(VENV)/bin/activate

lint:
	$(VENV)/bin/flake8 server --max-line-length 90

mypy:
	$(VENV)/bin/mypy . --explicit-package-bases --namespace-packages

format:
	$(PYTHON) -m black .

test:
	echo estamos trabajando en esto
	#$(PYTHON) -m pytest -v tests/ --cov --junitxml=report.xml --cov-report term --cov-report xml:coverage.xml

run:
	PYTHONPATH=. $(PYTHON) server/main.py

clean:
	rm -rf __pycache__ .pytest_cache/
	rm -rf $(VENV)
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	rm -f report.xml .coverage coverage.xml

