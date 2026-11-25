FROM dart:stable AS compilacao

WORKDIR /app

COPY bin ./bin

RUN dart compile exe bin/servidor.dart -o /app/servidor

FROM debian:bookworm-slim

RUN useradd --system forca

COPY --from=compilacao /app/servidor /app/servidor

USER forca

CMD ["/app/servidor"]
