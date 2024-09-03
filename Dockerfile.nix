from app:latest as build

RUN find /nix -type f -name "*.pyc" -delete


from scratch

COPY --from=build / /

