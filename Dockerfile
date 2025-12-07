FROM python:3.13
WORKDIR /usr/local/kitty-crowd

COPY . .
RUN pip install .

RUN useradd kitty-crowd
USER kitty-crowd

CMD ["flask", "--app", "kitty_crowd", "run", "--host=0.0.0.0"]