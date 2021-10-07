ARG IMAGEM=spire:network-shield-python-alpha3
FROM registry.scontain.com:5050/sconecuratedimages/${IMAGEM}
COPY encrypted-files/programa.py /app/programa.py
COPY fspf/volume.fspf /fspf-file/volume.fspf
COPY sessao.yml .
ENTRYPOINT ["python3", "/app/programa.py"]
