FROM python:3.11-slim-bookworm

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install mcpo uvx && \
    mkdir -p /app/chroma_db/current /app/chroma_db/backups && \
    rm -rf /root/.cache/pip

COPY . .

RUN pip install -e .

ENV MCP_MEMORY_CHROMA_PATH=/app/chroma_db/current \
    MCP_MEMORY_BACKUPS_PATH=/app/chroma_db/backups \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1

CMD ["mcpo", "--port", "8000", "--name", "Memory Service", "--", "uv", "run", "memory"]