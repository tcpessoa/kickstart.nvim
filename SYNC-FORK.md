# Fetch updates from upstream
git checkout master
git fetch upstream
git merge upstream/master

# Merge updates into your custom branch
git checkout my-config
git merge master