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
	@if [ "$(ENV)" = "prod" ]; then \
        docker run --name app-service-prod -p 8080:8080 -d --restart unless-stopped app-service:$(TAG); \
    elif [ "$(ENV)" = "dev" ]; then \
        docker run --name app-service-dev -p 8081:8080 -d app-service:$(TAG); \
    else \
        echo "ERROR: unknown ENV '$(ENV)' (expected dev or prod)"; exit 1; \
    fi