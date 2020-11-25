FROM python
RUN mkdir /allure
ARG APP_NAME
ENV PYTHONUNBUFFERED 1
WORKDIR /$APP_NAME
RUN	apt-get update -qq \
    && apt install -qq -y --no-install-recommends wget \
    && apt install libgbm1 unzip fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 libxtst6 lsb-release xdg-utils -y -f\
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb \
    && apt-get update -qq \
    && apt-get install -qq -y --no-install-recommends google-chrome-stable \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get install google-chrome-stable -y

RUN wget https://repo1.maven.org/maven2/io/qameta/allure/allure-commandline/2.13.3/allure-commandline-2.13.3.zip
RUN unzip allure-commandline-2.13.3.zip -d /allure

COPY ${APP_NAME}/requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY $APP_NAME/* /$APP_NAME/

RUN rm /$APP_NAME/google-chrome-stable_current_amd64.deb 
RUN rm /$APP_NAME/Dockerfile 
RUN rm /$APP_NAME/.gitignore 
RUN rm /$APP_NAME/requirements.txt
RUN rm /${APP_NAME}/localhost_development_only_build.sh
RUN mv /${APP_NAME} /app
RUN ls -la /${APP_NAME}


RUN ls -la 
# RUN ls -la /
# RUN ls -la /app
