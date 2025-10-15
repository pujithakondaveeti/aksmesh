FROM python:3.11-slim
WORKDIR /app
COPY app.py .
RUN pip install flask
ENV VERSION=v1
EXPOSE 8080
CMD ["python", "app.py"]
