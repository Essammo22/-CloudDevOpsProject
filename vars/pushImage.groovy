def call(String imageName, String ecrRepository) {

    echo "Pushing image to Amazon ECR"

    sh """
        docker tag ${imageName} ${ecrRepository}
        docker push ${ecrRepository}
    """
}
