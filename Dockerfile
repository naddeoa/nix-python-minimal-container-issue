from python:3.12-slim as build

WORKDIR /app

RUN apt-get update && apt-get install -y build-essential pipx

RUN python3.12 -m pip install pipx
RUN pipx ensurepath
RUN pipx install poetry==1.7.1


COPY pyproject.toml ./pyproject.toml 
COPY poetry.lock ./poetry.lock
COPY ./app ./app

RUN pipx --version
RUN pipx run poetry config virtualenvs.in-project true
RUN pipx run poetry install

from python:3.12-slim

WORKDIR /app

COPY --from=build /app /app

CMD bash -c "source .venv/bin/activate && python -m app.main"
