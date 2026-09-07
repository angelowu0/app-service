.PHONY: build test image deploy

VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

TAG := latest
ENV := dev

build:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt


test: build
	$(PYTHON) -m pytest tests/ -v

image:
	docker build -t app-service:$(TAG) .

deploy: image
	docker run -p 8080:8080 -d app-service:$(TAG)