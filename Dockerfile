FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Build/runtime packages needed by the Python dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv so provider agent can launch the local MCP server via `uv run`.
RUN pip install --no-cache-dir uv

# Copy application code and install exactly-locked dependencies.
COPY . .
RUN uv sync --frozen

RUN chmod +x /app/start.sh

ENV PORT=8080
EXPOSE 8080

CMD ["/app/start.sh"]
