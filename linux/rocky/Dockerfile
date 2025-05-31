FROM rockylinux:9.3

WORKDIR /root

RUN dnf update --refresh -y && \
    dnf groupinstall -y --setopt=install_weak_deps=false "Minimal Install" --skip-broken && \
    dnf install -y epel-release vim && \
    dnf clean all -y
