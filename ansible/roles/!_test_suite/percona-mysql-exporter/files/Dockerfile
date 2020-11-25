FROM python:latest

RUN apt-get update -q && \
apt-get install -y --no-install-recommends \
  build-essential \
  default-libmysqlclient-dev && \
apt-get clean -y && \
rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

#COPY prometheus_mysql_exporter/__init__.py /usr/src/app/prometheus_mysql_exporter/
#COPY prometheus_mysql_exporter/__main__.py /usr/src/app/prometheus_mysql_exporter/
#COPY prometheus_mysql_exporter/parser.py /usr/src/app/prometheus_mysql_exporter/
COPY __init__.py /usr/src/app/prometheus_mysql_exporter/
COPY __main__.py /usr/src/app/prometheus_mysql_exporter/
COPY parser.py /usr/src/app/prometheus_mysql_exporter/
COPY setup.py /usr/src/app/
COPY exporter.cfg /exporter.cfg

RUN pip install -e .

EXPOSE 9207

ENTRYPOINT ["python", "-u", "/usr/local/bin/prometheus-mysql-exporter"]
