
def call(String manifestPath, String branch) {

    echo "Pushing updated Kubernetes manifests to GitHub"

    withCredentials([usernamePassword(
        credentialsId: 'github-creds',
        usernameVariable: 'GIT_USERNAME',
        passwordVariable: 'GIT_TOKEN'
    )]) {

        withEnv([
            "MANIFEST_PATH=${manifestPath}",
            "BRANCH=${branch}"
        ]) {

            sh '''
                git add "$MANIFEST_PATH"

                if ! git diff --cached --quiet; then

                    git config user.name "Essam Mostafa"
                    git config user.email "essammostafa2222@gmail.com"

                    git commit -m "Update Kubernetes image"

                    cat > git-askpass.sh <<'EOF'
#!/bin/sh
case "$1" in
    *Username*) echo "$GIT_USERNAME" ;;
    *Password*) echo "$GIT_TOKEN" ;;
esac
EOF

                    chmod 700 git-askpass.sh
                    trap 'rm -f git-askpass.sh' EXIT

                    GIT_ASKPASS="$PWD/git-askpass.sh" \
                    GIT_TERMINAL_PROMPT=0 \
                    git push origin HEAD:"$BRANCH"

                else
                    echo "No manifest changes to commit"
                fi
            '''
        }
    }
}

