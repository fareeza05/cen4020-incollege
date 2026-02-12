FROM alpine:latest

WORKDIR /app
COPY . /app

# Use Alpine edge repos (including testing) so gnucobol exists
RUN printf "%s\n" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/testing" \
  > /etc/apk/repositories \
 && apk update \
 && apk add --no-cache gnucobol

CMD ["sh", "-lc", "cobc -x -free -o program src/InCollege.cob && ./program"]