# bump2version-action
Repository to host automated bump2version CI to run on python repositories

This action will bump package version on merge to a specified branch using bump2version on behalf of github-actions bot.
It will also automatically publish a new release on behalf of the user who created Personal Access Token

## Setup

### Add following workflow to your repository

```yaml
name: 'Bump2version-CI'
on:
  push:
    branches:
      - 'master'
      - 'main'
jobs:
  bump-version:
    runs-on: ubuntu-latest
    name: Bump version and push tags to master
    steps:
      - name: Bump version
        uses: Clinical-Genomics/bump2version-ci@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ github.repository }}
          GITHUB_ACTOR: ${{ github.actor }}
        with:
          release_pat: ${{ secrets.BUMPVERSION_TOKEN }}
```

### Add `.bumpversion.cfg` file to your repository

```
[bumpversion]
current_version = 0.0.0
commit = True
tag = True
tag_name = {new_version}

[bumpversion:file:setup.py]
[bumpversion:file:<package>/__init__.py]
```

### Set up Personal Access Token

* Go to `Account Settings / Developer settings / Personal access tokens` and 
create a new PAT
* Go to `Repository Setting / Secrets` and add the PAT as `BUMPVERSION_TOKEN`

