def call(String imageName, String ecrImageName) {

    echo "Deleting local Docker images"

    sh """
        docker rmi ${imageName} ${ecrImageName}
    """
}
