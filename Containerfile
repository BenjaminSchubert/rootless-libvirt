FROM docker.io/debian:stable-slim

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends \
        cloud-image-utils \
        libvirt-daemon-system \
        ovmf \
        sudo \
        tini \
        virt-install \
        && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/qemu && \
    echo "allow virbr0" > /etc/qemu/bridge.conf && \
    chmod u+s /usr/lib/qemu/qemu-bridge-helper && \
    ln -s /etc/libvirt/qemu/networks/default.xml /etc/libvirt/qemu/networks/autostart/default.xml

RUN useradd -m testuser --groups libvirt && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

USER testuser
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
