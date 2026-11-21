def call(String imageName) {

    echo "Running Trivy security scan: ${imageName}"

    sh """
        trivy image \
        --scanners vuln \
        --severity HIGH,CRITICAL \
        --ignore-unfixed \
        --exit-code 0 \
        ${imageName}
    """
}
