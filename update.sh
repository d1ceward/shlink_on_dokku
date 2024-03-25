# Pull upstream changes
echo -e "\033[0;32m====>\033[0m Pull origin..."
git pull

echo -e "\033[0;32m====>\033[0m Initial check..."

# Get current release name
CURRENT_RELEASE=$(git tag --sort=version:refname | tail -1)

# Get lastest release name
RELEASE=$(curl -s https://api.github.com/repos/shlinkio/shlink/releases/latest | jq -r ".tag_name" | sed 's/Shlink@//g; s/\"//g' | sed 's/v//g; s/\"//g')

# Exit script if already up to date
if [ $RELEASE = $CURRENT_RELEASE ]; then
  echo -e "\033[0;32m=>\033[0m Already up to date..."
  exit 0
fi

# Replace "from" line in dockerfile with the new release
sed -i "s#ARG SHLINK_VERSION.*#ARG SHLINK_VERSION=\"${RELEASE}\"#" Dockerfile

# Replace README link to Shlink release
SHLINK_BADGE="[![Shlink](https://img.shields.io/badge/Shlink-${RELEASE}-blue.svg)](https://github.com/shlinkio/shlink/releases/tag/Shlink%40${RELEASE})"
sed -i "s#\[\!\[Shlink\].*#${SHLINK_BADGE}#" README.md

# Push changes
git add Dockerfile README.md
git commit -m "Update to Shlink version ${RELEASE}"
git push origin master

# Create tag
git tag $RELEASE
git push --tags
