FROM python:3.10.16 AS base
RUN apt update
RUN apt upgrade -y

# Install terraform
RUN apt-get update
RUN apt-get install -y wget unzip zip
RUN rm -rf /var/lib/apt/lists/*
RUN wget --quiet https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
RUN unzip terraform_1.6.6_linux_amd64.zip
RUN mv terraform /usr/bin/
RUN rm terraform_1.6.6_linux_amd64.zip

RUN adduser --uid 10000 app
RUN mkdir -p /usr/app
RUN chown app:app /usr/app

FROM base AS devcontainer
USER 10000
ENV ISDEVCONTAINER=true

WORKDIR /usr/app
COPY --chown=app:app ./.devcontainer/install_gcloud.sh .
COPY --chown=app:app ./requirements.txt .
COPY --chown=app:app ./.devcontainer/dev-requirements.txt .
COPY --chown=app:app ./.devcontainer/python_setup.sh .

RUN sed -i 's/\r$//' ./install_gcloud.sh && \
    chmod +x ./install_gcloud.sh
RUN sed -i 's/\r$//' ./python_setup.sh && \
    chmod +x ./python_setup.sh
RUN ./install_gcloud.sh
RUN ./python_setup.sh

COPY --chown=app:app ./.devcontainer/post_create_commands.sh .
RUN sed -i 's/\r$//' ./post_create_commands.sh && \
    chmod +x ./post_create_commands.sh

WORKDIR /home/app
COPY ./.devcontainer/bashrc.sh .
RUN sed -i 's/\r$//' ./bashrc.sh && \
    chmod +x ./bashrc.sh
RUN cat ./bashrc.sh >> .bashrc


