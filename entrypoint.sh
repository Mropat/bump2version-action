#!/bin/bash

## Required env vars:

# BUMPVERSION_TOKEN: github-actions workflow native token
# AUTHOR: github-actions workflow native user (github-actions[bot])
# GITHUB_REPOSITORY: repository this action runs on
# AUTHOR_EMAIL

# INPUT_RELEASE_PAT: Personal Access Token of the github user who will author the release

# Ensure that when any step of this script fails, the entire job will fail as well
set -eo pipefail

REPOSITORY_URI="https://${AUTHOR}:${BUMPVERSION_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

git clone "${REPOSITORY_URI}"

cd "$(ls)" || exit

git checkout main
git pull origin main
git fetch 

# Fetching the commit message for the latest commit to branch this action is applied to
COMMIT_MSG=$(git log -1 --pretty=%B|sed 's/\r$//g'|sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\\n/g')

# Parsing version update increment from commit message
if [[ $COMMIT_MSG == *'major'* ]]; then
  VERSION='major'
elif [[ $COMMIT_MSG == *'minor'* ]]; then
  VERSION='minor'
else
  VERSION='patch'
fi

# Configure email of the github user to the one of the github-actions bot
git config --global user.email "${AUTHOR_EMAIL}"

# Run bump2version
bump2version --config-file .bumpversion.cfg "${VERSION}"

BUMP_COMMIT_MSG=$(git log -1 --pretty=%B)
git commit --amend -m "${BUMP_COMMIT_MSG} [skip ci]"

git push --tags
git push

# Pull from branch again to update latest tag
git pull
git fetch --tags

# Get the value of latest tag that was just pushed
NEW_TAG="$(git describe --tags)"

# Construct post JSON for publishing release
POST_DATA=$(echo -e {\"tag_name\": \"$NEW_TAG\", \"name\": \"Release $NEW_TAG\", \"draft\": false, \"prerelease\": false, \"body\": \""${COMMIT_MSG}"\"})

echo "Submitting release for ${NEW_TAG}"

curl \
  -X POST \
  -H "Authorization: token ${BUMPVERSION_TOKEN}" \
  -d "${POST_DATA}" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"

