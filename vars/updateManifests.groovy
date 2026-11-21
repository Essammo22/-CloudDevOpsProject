def call(String manifestPath, String containerName, String newImage) {

    echo "Updating Kubernetes manifest"

    sh """
        sed -i '/name: ${containerName}/,/image:/s|image:.*|image: ${newImage}|' ${manifestPath}
    """
}
