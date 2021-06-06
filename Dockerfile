FROM ubuntu

RUN apt-get update && \
        apt-get --yes install \
                libxml-xpath-perl \
                make \
                curl \
                ruby \
                vim

RUN gem install cddl cbor-diag

CMD ["bash"]
