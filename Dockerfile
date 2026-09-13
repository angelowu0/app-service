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

RUN addgroup --system --gid 1001 app \
    && adduser --system --uid 1001 --ingroup app app \
    && chown -R 1001:1001 /app
USER 1001:1001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["python", "-c", "import urllib.request,sys; sys.exit(0) if urllib.request.urlopen('http://localhost:8080/healthz').status==200 else sys.exit(1)"]

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
#  docker run -p 8080:8080 -d app_service:latest