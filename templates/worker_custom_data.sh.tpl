#!/usr/bin/env bash
set -euo pipefail

install_boundary() {

echo "[INFO] Installing Boundary."

echo "[INFO] Creating /opt/boundary."
mkdir /opt/boundary/

echo "[INFO] Adding apt.releases.hashicorp.com and downloading Boundary."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - ;\
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" ;\
sudo apt-get update && sudo apt-get install boundary-worker-hcp=${boundary_worker_version} -y

}

generate_boundary_worker_config() {
  echo "[INFO] Generating /opt/boundary/pki-worker.hcl file."

  cat > /opt/boundary/pki-worker.hcl << EOF
disable_mlock = true

hcp_boundary_cluster_id = "${hcp_boundary_cluster_id}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "${worker_public_address}"
  auth_storage_path = "/opt/boundary/azure-worker"
  tags {
    type = ["azure-worker", "upstream"]
  }
}
EOF
}

start_boundary_pki_worker() {
  echo "[INFO] Starting Boundary PKI Worker."

  boundary-worker server -config="/opt/boundary/pki-worker.hcl"
}

main() {

install_boundary
generate_boundary_worker_config
start_boundary_pki_worker

echo "[INFO] Outputing auth request token."
cat /opt/boundary/azure-worker/auth_request_token

exit 0

}

main "$@"