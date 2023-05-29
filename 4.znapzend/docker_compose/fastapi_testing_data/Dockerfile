FROM debian

RUN mkdir /fastapi_data/
RUN mkdir /fastapi_testing_data/
WORKDIR   /fastapi_testing_data/
EXPOSE 80

RUN apt update
RUN apt upgrade -y
RUN apt install -y python3 python3-pip npm nodejs curl
RUN apt install -y vim-tiny libpq-dev

RUN curl -fsSL https://deb.nodesource.com/setup_19.x | /bin/bash - && \
    apt install -y nodejs

RUN npm install -g npm

RUN pip3 install --upgrade pip
RUN pip3 install --default-timeout=1000 \
                   fastapi \
                   pydantic \
                   starlette \
                   \
                   SQLAlchemy \
                   psycopg2 \
                   \
                   PyJWT \
                   requests \
                   cryptography \
                   pybase64 \
                   \
                   pytest \
                   pyyaml

RUN pip3  install --default-timeout=1000 authlib paramiko
RUN  apt  install  -y                        ssh sshpass
RUN mkdir          -p  /root/.ssh

RUN npm  install --location=global gritty
RUN npm  install --location=global cloudcmd
RUN pip3 install --upgrade         requests

RUN apt autoremove -y && apt autoclean -y && apt clean -y
RUN sync && rm -rf /var/lib/apt/lists/*

CMD [ "/bin/bash" , "run.sh" ]
