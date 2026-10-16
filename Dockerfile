FROM python:3-alpine

WORKDIR /service

# Copy dependency definitions first for better layer caching
COPY requirements.txt .

# Upgrade pip and install dependencies with security fixes
RUN python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir --upgrade \
       "msgpack>=1.2.1" \
       "setuptools>=78.1.1" \
       "urllib3>=2.8.0" \
    && python -m pip check \
    && python -c "import importlib.metadata as m; print('\n'.join('{}=={}'.format(p, m.version(p)) for p in ['msgpack', 'setuptools', 'urllib3']))" \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

# Copy application files with non-root ownership
COPY --chown=appuser:appgroup . .

# Flask application port
EXPOSE 8080

# Run as a non-root user
USER appuser

# Verify application health
HEALTHCHECK --interval=30s --timeout=5s \
    --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=3)" || exit 1

ENTRYPOINT ["python", "app.py"]