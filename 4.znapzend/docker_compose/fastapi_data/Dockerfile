FROM debian

RUN mkdir /fastapi_data/
WORKDIR  /fastapi_data/

EXPOSE 80

RUN apt update
RUN apt upgrade -y

RUN apt install -y software-properties-common
RUN apt-add-repository contrib

RUN apt update
RUN apt upgrade -y

RUN apt install -y python3 python3-pip libpq-dev
RUN apt install -y zfsutils-linux zfs-dkms
RUN apt install -y erlang elixir

RUN pip3 install --upgrade pip
RUN pip3 install --default-timeout=1000 \
                   fastapi \
                   pydantic \
                   starlette \
                   \
                   uvicorn \
                   \
                   SQLAlchemy \
                   psycopg2 \
                   \
                   PyJWT \
                   requests \
                   cryptography \
                   pybase64 \
                   \
                   pyyaml \
                   numpy

RUN pip3 install --default-timeout=1000 authlib paramiko
RUN  apt install  -y                        ssh sshpass

RUN   mkdir                      -p  /root/.ssh
# RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa_fastapi
# RUN touch                         ~/.ssh/known_hosts

RUN pip3 install --upgrade requests
RUN apt autoremove -y && apt autoclean -y && apt clean -y
RUN sync && rm -rf /var/lib/apt/lists/*

CMD [ "/bin/bash" , "run.sh" ]
