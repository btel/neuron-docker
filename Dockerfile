FROM python:2

RUN pip install --no-cache-dir notebook==5.*

ENV NB_USER bartosz
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

RUN mkdir -p $HOME

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

WORKDIR ${HOME}

# install dependencies

USER root
RUN apt-get update; apt-get install -y libncurses5-dev libreadline-dev libgsl0-dev
USER ${NB_USER}

# install neuron

ENV NRN_VER=7.4
ENV NRN=nrn-$NRN_VER
ENV VENV=$HOME/neuron
ENV PATH=$PATH:$VENV/bin

RUN wget http://www.neuron.yale.edu/ftp/neuron/versions/v$NRN_VER/$NRN.tar.gz
RUN tar xzf $NRN.tar.gz; rm $NRN.tar.gz

RUN mkdir $VENV; mkdir $VENV/build; mkdir $VENV/bin
RUN mkdir $NRN; \
    cd $NRN; \
    ./configure --with-nrnpython=python --disable-rx3d --without-iv --prefix=$VENV; \
    make; make install

RUN cd $VENV/bin; ln -s ../x86_64/bin/nrnivmodl

RUN cd $NRN/src/nrnpython; python setup.py install --user


WORKDIR $HOME

# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
