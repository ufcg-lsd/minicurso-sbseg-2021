FROM sconecuratedimages/public-apps:python-3.7.3-alpine3.10
COPY programa.py .
ENTRYPOINT ["python3", "programa.py"]
