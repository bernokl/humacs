ARG BASE_IMAGE=registry.gitlab.com/humacs/humacs/humacs:2021.01.20
FROM $BASE_IMAGE
ENV HUMACS_DISTRO=ii \
  DOCKER_VERSION=20.10.2 \
  KIND_VERSION=0.10.0 \
  KUBECTL_VERSION=1.20.2 \
  GO_VERSION=1.15 \
  TILT_VERSION=0.18.5 \
  TMATE_VERSION=2.4.0 \
  BAZEL_VERSION=3.4.1 \
  HELM_VERSION=3.5.0 \
  GH_VERSION=1.5.0 \
  LEIN_VERSION=stable \
  CLOJURE_VERSION=1.10.1.697 \
  CLUSTERCTL_VERSION=0.3.13 \
  TALOSCTL_VERSION=0.8.1 \
  TERRAFORM_VERSION=0.14.5 \
  DIVE_VERSION=0.9.2 \
  CRICTL_VERSION=1.20.0 \
# GOLANG, path vars
  GOROOT=/usr/local/go \
  PATH="$PATH:/usr/local/go/bin"
# Software
RUN apt-get update --yes && DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
  tree \
  iproute2 \
  net-tools \
  tcpdump \
  htop \
  iftop \
  tmux \
  language-pack-en \
  openjdk-14-jdk \
  rlwrap \
  fonts-powerline \
  dnsutils \
  python3-pip \
  npm \
  ripgrep \
  python-is-python3 \
  shellcheck \
  pipenv \
  fd-find \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd
# docker client binary
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
  | tar --directory=/usr/local/bin --extract --ungzip \
  --strip-components=1 docker/docker
# kind binary
RUN curl -Lo /usr/local/bin/kind \
    https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64 \
    && chmod +x /usr/local/bin/kind
# kubectl binary
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl
# tilt binary
RUN curl -fsSL \
    https://github.com/windmilleng/tilt/releases/download/v${TILT_VERSION}/tilt.${TILT_VERSION}.linux.x86_64.tar.gz \
    | tar --directory /usr/local/bin --extract --ungzip tilt
# another approach to golang
RUN curl -sLo /usr/local/bin/gimme \
  https://raw.githubusercontent.com/travis-ci/gimme/master/gimme \
  && chmod +x /usr/local/bin/gimme
# golang binary
RUN curl -L https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar --directory /usr/local --extract --ungzip
# gh cli
RUN curl -sSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz \
    | tar --directory /usr/local --extract --ungzip \
     --strip-components 1 gh_${GH_VERSION}_linux_amd64/bin/gh \
    && chmod +x /usr/local/bin/gh
# tmate allows others to connect to your session
# they support using self hosted / though we default to using their hosted service
RUN curl -L \
    https://github.com/tmate-io/tmate/releases/download/${TMATE_VERSION}/tmate-${TMATE_VERSION}-static-linux-amd64.tar.xz \
    | tar --directory /usr/local/bin --extract --xz \
  --strip-components 1 tmate-${TMATE_VERSION}-static-linux-amd64/tmate
# helm binary
RUN curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar --directory /usr/local/bin --extract -xz --strip-components 1 linux-amd64/helm
# bazel binary
RUN curl -L -o /usr/local/bin/bazel https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 && \
  chmod +x /usr/local/bin/bazel && bazel version
# clusterctl
RUN curl -L -o /usr/local/bin/clusterctl https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-linux-amd64 && \
  chmod +x /usr/local/bin/clusterctl
# talosctl
RUN curl -L -o /usr/local/bin/talosctl https://github.com/talos-systems/talos/releases/download/v${TALOSCTL_VERSION}/talosctl-linux-amd64 && \
  chmod +x /usr/local/bin/talosctl
# terraform
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  | gunzip -c - > /usr/local/bin/terraform && \
  chmod +x /usr/local/bin/terraform
# dive
RUN curl -L https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz \
  | tar --directory /usr/local/bin/ --extract --ungzip dive
RUN curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz \
  | tar --directory /usr/local/bin --extract --gunzip crictl
# gopls binary
RUN /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get golang.org/x/tools/gopls@latest \
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get -u github.com/owenthereal/upterm \
# gocode binary
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get -u github.com/stamblerre/gocode \
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get -u github.com/go-delve/delve/cmd/dlv \
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get github.com/fatih/gomodifytags \
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get -u github.com/cweill/gotests/... \
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get github.com/motemen/gore/cmd/gore \
  && /bin/env GO111MODULE=on GOPATH=/usr/local/go /usr/local/go/bin/go get golang.org/x/tools/cmd/guru
# Leiningen for clojure
RUN curl -fsSL https://raw.githubusercontent.com/technomancy/leiningen/${LEIN_VERSION}/bin/lein \
    -o /usr/local/bin/lein \
    && chmod +x /usr/local/bin/lein \
    && /usr/local/bin/lein version
# Install Clojure
RUN curl -OL https://download.clojure.org/install/linux-install-${CLOJURE_VERSION}.sh \
    && bash linux-install-${CLOJURE_VERSION}.sh \
    && rm ./linux-install-${CLOJURE_VERSION}.sh
RUN pip3 install yq
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
USER ii
