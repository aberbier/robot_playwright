FROM mcr.microsoft.com/playwright:v1.58.0-noble

WORKDIR /app

COPY requirements.txt ./requirements.txt

RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --break-system-packages -r requirements.txt && rm requirements.txt

RUN rfbrowser init --skip-browsers