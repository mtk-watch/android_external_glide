#!/bin/bash -e
# Pulls down the latest version of Glide from the master branch, merges it with
# the existing version of Glide, and removes unneeded tests, source
# directories, scripts, and build files.
#
# Make sure ANDROID_BRANCH_NAME matches the current branch name, then:
#
# Usage: ./update_files.sh [glide_brach_name|glide_tag_name|glide_commit]
#
# WARNING: This script will rm -rf files in the directory in
# which it is run!

ANDROID_BRANCH_NAME=ub-camera-haleakala

# Validate that we were given something to checkout from Glide's remote.
if [ $# -ne 1 ]
then
  echo "Usage: ./update_files.sh [glide_brach_name|glide_tag_name|glide_commit]"
  exit 1
fi

GLIDE_BRANCH=$1

# We may have already added bump's remote.
if ! git remote | grep bump > /dev/null;
then
  git remote add bump https://github.com/bumptech/glide.git
fi

# Validate that the thing we were given to checkout exists and fetch it if it
# does.
git fetch bump ${GLIDE_BRANCH} || exit 1

# Remove the existing disk cache source so it doesn't conflict with Glide's
# submodule.
rm -rf third_party/disklrucache

# Switch to the branch in Android we want to update and merge.
git checkout ${ANDROID_BRANCH_NAME}
git merge bump/master || true

# Remove source directories we don't care about.
git rm -rf samples || true
git rm -rf integration || true
git rm -rf static || true
git rm -rf glide || true

# Remove test directories we don't care about.
git rm -rf library/src/androidTest || true
git rm -rf third_party/gif_decoder/src/androidTest || true
git rm -rf third_party/gif_encoder/src/androidTest || true

# Special case disklrucache because it's a submodule that we can't keep with
# repo.
git submodule deinit third_party/disklrucache
git rm -rf third_party/disklrucache
rm -rf third_party/disklrucache

# Clone outside of the normal path to avoid conflicts with the submodule.
REMOTE_DISK_PATH=third_party/remote_disklrucache
git clone https://github.com/sjudd/disklrucache $REMOTE_DISK_PATH
# Remove tests we don't care about.
rm -rf $REMOTE_DISK_PATH/src/test
# Remove git related things to avoid re-adding a submodule.
rm -rf $REMOTE_DISK_PATH/.git
rm -rf $REMOTE_DISK_PATH/.gitmodule
# Copy the safe source only code back into the appropriate path.
mv $REMOTE_DISK_PATH third_party/disklrucache
git add third_party/disklrucache

# Remove build/static analysis related files we don't care about.
find . -name "*gradle*" | xargs git rm -rf
find . -name "*checkstyle*.xml" | xargs git rm -rf
find . -name "*pmd*.xml" | xargs git rm -rf
find . -name "*findbugs*.xml" | xargs git rm -rf

GIT_SHA=$(git rev-parse bump/master)
echo "Merged bump/master at ${GIT_SHA}"
echo "Now fix any merge conflicts, commit, and run: git push goog ${ANDROID_BRANCH_NAME}"
