FROM python:3.11-slim-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && pip install --upgrade pip uv \
    && rm -rf /var/lib/apt/lists/* /root/.cache/pip

WORKDIR /app

COPY requirements.txt pyproject.toml setup.py README.md ./
COPY src/ ./src/

RUN uv venv /opt/venv \
    && uv pip install --python /opt/venv/bin/python --no-cache-dir -r requirements.txt \
    && uv pip install --python /opt/venv/bin/python --no-cache-dir mcpo \
    && uv pip install --python /opt/venv/bin/python --no-cache-dir -e .

FROM python:3.11-slim-bookworm AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app/src ./src
COPY --from=builder /app/setup.py /app/README.md ./

RUN mkdir -p /app/chroma_db/current /app/chroma_db/backups

ENV PATH="/opt/venv/bin:$PATH" \
    MCP_MEMORY_CHROMA_PATH=/app/chroma_db/current \
    MCP_MEMORY_BACKUPS_PATH=/app/chroma_db/backups \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    VIRTUAL_ENV=/opt/venv

CMD ["mcpo", "--port", "8000", "--name", "Memory Service", "--", "memory"]