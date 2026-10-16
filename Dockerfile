FROM python:3-alpine

WORKDIR /service

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir --upgrade \
       "msgpack>=1.2.1" \
       "setuptools>=78.1.1" \
       "urllib3>=2.8.0" \
    && python -c "import importlib.metadata as m; print('\n'.join(f'{p}=={m.version(p)}' for p in ['msgpack', 'setuptools', 'urllib3']))" \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

COPY --chown=appuser:appgroup . .

EXPOSE 8080

USER appuser

HEALTHCHECK --interval=30s --timeout=5s \
    --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=3)" || exit 1

ENTRYPOINT ["python", "app.py"]