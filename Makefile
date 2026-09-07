.PHONY: build test image deploy

VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

TAG := app_service
ENV := dev

build:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt


test: build
	@echo "Testing"

image:
	docker build -t $(TAG) .

deploy: image
	docker run -p 8080:8080 -d $(TAG)