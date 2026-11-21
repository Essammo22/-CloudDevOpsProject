def call(String serviceName, String imageTag) {

    echo "Building Docker image for ${serviceName}"

    sh """
        docker build \
        -t ${serviceName}:${imageTag} \
        Docker/iVolveFinalProject/${serviceName}
    """
}
