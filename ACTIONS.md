# Workflow Documentation

## Rough Process Flow

- build image

  - create metadata
  - upload release
  - update global metadata

- get a list of extensions
- check to see if build is required

  - get latest upstream package version
  - check for gh release with that version

- create release

  - build the extension
  - create the metadata
  - upload the release: tag extension-v{version}

  - update extension metadata release tag: extension

- update global metadata
  - get all image + extension metadata
  - create global metadata release tag: SHA256SUMS

## Updating Actions

- Modify .workflow-templates/ as needed
- Modify ./scripts/update_workflows.sh to add/remove workflow steps from templates
- Run ./scripts/update_workflows.sh
- add .github/workflows/\* to your commit and push
