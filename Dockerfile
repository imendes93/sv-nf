FROM continuumio/miniconda3@sha256:456e3196bf3ffb13fee7c9216db4b18b5e6f4d37090b31df3e0309926e98cfe2

LABEL description="Dockerfile containing basic R and Python requirements for the lifebit-ai/sv-nf pipeline" \
      author="ines@lifebit.ai"

RUN apt-get update -y \ 
    && apt-get install -y zip procps libxt-dev \
    && rm -rf /var/lib/apt/lists/*

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/sv-nf/bin:$PATH

# Copy script files for Rmd report
RUN mkdir /opt/bin
COPY bin/* /opt/bin/
RUN chmod +x /opt/bin/*
ENV PATH="$PATH:/opt/bin/"

USER root

WORKDIR /data/

CMD ["bash"]
