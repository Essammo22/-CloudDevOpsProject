def call(String imageName) {

    echo "Scanning Docker image: ${imageName}"

    sh """
        trivy image \
        --severity HIGH,CRITICAL \
        --exit-code 1 \
        ${imageName}
    """
}
