#!/usr/bin/env bash
set -euo pipefail

K8S_VERSION="${K8S_VERSION:="1.22.x"}"
KUBEBUILDER_ASSETS="${KUBEBUILDER_ASSETS:="${HOME}/.kubebuilder/bin"}"

main() {
    tools
    kubebuilder
}

tools() {
    go install sigs.k8s.io/controller-runtime/tools/setup-envtest@v0.0.0-20220421205612-c162794a9b12
    go install sigs.k8s.io/controller-tools/cmd/controller-gen@v0.6.2

    if ! echo "$PATH" | grep -q "${GOPATH:-undefined}/bin\|$HOME/go/bin"; then
        echo "Go workspace's \"bin\" directory is not in PATH. Run 'export PATH=\"\$PATH:\${GOPATH:-\$HOME/go}/bin\"'."
    fi
}

kubebuilder() {
    mkdir -p $KUBEBUILDER_ASSETS
    arch=$(go env GOARCH)
    ## Kubebuilder does not support darwin/arm64, so use amd64 through Rosetta instead
    if [[ $(go env GOOS) == "darwin" ]] && [[ $(go env GOARCH) == "arm64" ]]; then
        arch="amd64"
    fi
    ln -sf $(setup-envtest use -p path "${K8S_VERSION}" --arch="${arch}" --bin-dir="${KUBEBUILDER_ASSETS}")/* ${KUBEBUILDER_ASSETS}
    find $KUBEBUILDER_ASSETS
}

main "$@"
