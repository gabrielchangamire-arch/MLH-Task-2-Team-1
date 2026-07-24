FROM python:3.9-slim-bookworm

ENV FLASK_APP=app
ENV PYTHONUNBUFFERED=1

WORKDIR /myportfolio

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
