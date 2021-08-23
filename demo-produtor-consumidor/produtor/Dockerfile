FROM golang:1.15

RUN mkdir -p /build

COPY ./app /build

RUN cd /build && go install . && rm -rf /build

ENTRYPOINT ["produtor"]
