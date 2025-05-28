# Stage 1: Build
FROM python:3.11-slim as builder

WORKDIR /app

COPY pyproject.toml ./

RUN pip install --upgrade pip && \
    pip install .[test]

COPY . .

# Stage 2: Production image
FROM python:3.14.0b2-alpine3.21

WORKDIR /app

# Устанавливаем зависимости для psycopg (если используется)
RUN apk add --no-cache libpq postgresql-dev gcc musl-dev

# Копируем из builder
COPY --from=builder /app /app

# Устанавливаем зависимости и приложение
RUN pip install --no-cache-dir . && \
    apk del gcc musl-dev  # Удаляем ненужные для runtime зависимости

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
