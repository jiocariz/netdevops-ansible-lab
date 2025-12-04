FROM python:3.12-slim

LABEL maintainer="jiocariz"
LABEL description="Custom Ansible image for network automation with Cisco, Small Business switches, and Raspberry Pi"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    sshpass \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible and network automation dependencies
RUN pip install --no-cache-dir \
    ansible-core \
    ansible-pylibssh \
    paramiko \
    netaddr \
    jmespath

# Install Ansible collections for network devices
RUN ansible-galaxy collection install \
    cisco.ios \
    community.network \
    community.general \
    ansible.netcommon \
    ansible.posix

# Set working directory
WORKDIR /ansible

# Copy ansible configuration
COPY ansible/ /ansible/

# Default command
CMD ["ansible", "--version"]
