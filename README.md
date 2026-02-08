# rootless-libvirt

This project provides an OCI image allowing to run qemu images inside rootless
podman, with or without kvm acceleration available.

The main driver for this project is to enable users to run VMs in CI when
using gitlab-runners with the podman executor. It enables complete isolation of
the entire VM stack, and only requires the gitlab-runner user to be part of the
kvm group for it to work, leading to an almost complete isolation and lack of
privileges for the running containers and ensures networks on the hosts are not
affected by what the test user is doing.

For some examples of how to use this image, see [the Makefile](./Makefile).

⚠️⚠️ This only works when using the user session of libvirt, and not the system one ⚠️⚠️

## Running without kvm

This image can be used to run libvirt without kvm and start images for any user.

You can, for example get a shell with:

```bash
# - --privileged is required to be able to setup networking
# - --userns=keep-id:uid=1000,gid=1000 maps your current user to uid/gid 1000 in
#   the container, allowing seemless access to mounted directories if needed
podman \
    run \
    --rm \
    -it \
    --name libvirtd \
    --privileged \
    --userns=keep-id:uid=1000,gid=1000 \
    ghcr.io/benjaminschubert/rootless-libvirt
```

## Running with kvm

For running with kvm acceleration, you need to ensure that your user on the host
is in the `kvm` group, and that `/dev/kvm` is present on your machine.

Then you can get a shell with:

```bash
# - --privileged is required to be able to setup networking
# - --userns=keep-id:uid=1000,gid=1000 maps your current user to uid/gid 1000 in
#   the container, allowing the default container user to access /dev/kvm, and
#   seemless access to mounted directories if needed
# - --group-add=kvm ensures that the default user in the container keeps its
#   membership of the kvm group, even inside the container namespace
# - --device /dev/kvm mounts /dev/kvm inside the container to allow libvirt to
#   leverage it
podman \
    run \
    --rm \
    --name libvirtd-kvm \
    --privileged \
    --userns=keep-id:uid=1000,gid=1000 \
    --group-add=keep-groups \
    --device /dev/kvm \
    ghcr.io/benjaminschubert/rootless-libvirt

```
