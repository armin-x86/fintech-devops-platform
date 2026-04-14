### Backend (FastAPI) Dockerfile
#
# - Multi-stage for small runtime image
# - Runs as non-root
# - Emits logs to stdout/stderr (12-factor)

FROM python:3.12-slim AS base
RUN apt-get update && apt-get upgrade -y --no-install-recommends && rm -rf /var/lib/apt/lists/*
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app
WORKDIR /app

FROM base AS builder
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
COPY backend/requirements.txt ./requirements.txt
RUN python -m pip install --upgrade pip && \
    python -m pip wheel --wheel-dir /wheels -r requirements.txt

FROM base AS runtime
RUN addgroup --system app && adduser --system --ingroup app app
COPY --from=builder /wheels /wheels
COPY backend/requirements.txt ./requirements.txt
RUN python -m pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && rm -rf /wheels

COPY backend/app ./app
RUN chown -R app:app /app
USER app

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health').read()" || exit 1

# Gunicorn with Uvicorn workers is a common production baseline for FastAPI
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-w", "2", "-b", "0.0.0.0:8000", "app.main:app"]

FROM runtime AS dev
ENV RUFF_CACHE_DIR=/tmp/ruff_cache
USER root
RUN python -m pip install --no-cache-dir --upgrade pip && \
    python -m pip install --no-cache-dir pytest httpx==0.27.0 ruff
USER app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
