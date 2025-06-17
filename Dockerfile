FROM python:3.11-slim-bookworm

# Install uv for faster package management
RUN pip install --upgrade pip uv \
    && rm -rf /root/.cache/pip

WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt pyproject.toml ./

# Install Python dependencies using uv for faster installs
RUN uv pip install --system --no-cache-dir -r requirements.txt \
    && uv pip install --system --no-cache-dir mcpo \
    && mkdir -p /app/chroma_db/current /app/chroma_db/backups

# Copy source code
COPY src/ ./src/
COPY setup.py ./

# Install the package in editable mode
RUN uv pip install --system --no-cache-dir -e .

# Set environment variables
ENV MCP_MEMORY_CHROMA_PATH=/app/chroma_db/current \
    MCP_MEMORY_BACKUPS_PATH=/app/chroma_db/backups \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PYTHONIOENCODING=utf-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_SYSTEM_PYTHON=1

CMD ["mcpo", "--port", "8000", "--name", "Memory Service", "--", "uv", "run", "memory"]