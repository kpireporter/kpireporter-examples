FROM jupyter/base-notebook:lab-2.2.9

COPY .binder/apt.txt /apt.txt
USER root
RUN apt-get update -y \
    && xargs apt-get install -y </apt.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER $NB_UID

COPY .binder/requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

COPY .binder/postBuild /postBuild
RUN /postBuild
