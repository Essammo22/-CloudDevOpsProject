def call(String manifestPath, String branch) {

    echo "Pushing updated Kubernetes manifests to GitHub"

    sh """
        git add ${manifestPath}

        if ! git diff --cached --quiet; then
            git config user.name "Essammo22"
            git config user.email "essammostafa2222@gmail.com"

            git commit -m "Update Kubernetes image"
            git push origin HEAD:${branch}
        else
            echo "No manifest changes to commit"
        fi
    """
}
