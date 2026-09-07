FROM dhi.io/python:3.13-dev AS build-stage

WORKDIR /app

ENV PATH="/app/venv/bin:$PATH"

RUN python -m venv /app/venv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM dhi.io/python:3.13 AS runtime-stage

WORKDIR /app

ENV PATH="/app/venv/bin:$PATH"

COPY --from=build-stage /app/venv /app/venv
COPY app.py .

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]

#  docker run -p 8080:8080 -d app_service:latest