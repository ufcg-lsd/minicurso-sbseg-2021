FROM registry.scontain.com:5050/clenimar/test:python3-network-shield

RUN pip install flask requests kafka-python && mkdir /app

COPY ./app/ /app/

ENTRYPOINT ["python3", "/app/consumidor.py"]
