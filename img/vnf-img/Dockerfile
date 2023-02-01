FROM ubuntu:20.04
# install required packages
RUN apt-get clean
RUN apt-get update \
    && apt-get install -y \
    net-tools \
    traceroute \
    curl \
    iptables \
    inetutils-ping \
    nano \
    build-essential \
    bridge-utils \
    isc-dhcp-server \
    tcpdump \
    openvswitch-switch \
    openvswitch-common \
    iperf3 \
    iproute2 \
    vim \
    arpwatch \
    git \
    python3.6 \
    python-dev \
    python-setuptools \
    python3-pip

# arpwatch
RUN echo deb http://archive.ubuntu.com/ubuntu trusty main universe restricted multiverse >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y sysv-rc-conf
RUN sysv-rc-conf --level 35 arpwatch on
COPY arpwatch /etc/default/arpwatch

# ryu
RUN git clone https://github.com/osrg/ryu.git 
RUN cd ryu && pip install .
RUN mkdir -p /ryu

COPY vnx_config_nat /usr/bin/
COPY isc-dhcp-server /etc/default/isc-dhcp-server
COPY dhcpd.conf /etc/dhcp/dhcpd.conf
#COPY simple_switch_13.py /ryu/simple_switch_13.py
COPY simple_switch_13.py /ryu/qos_simple_switch_13.py

