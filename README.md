# docs-on-demand-service-broker

This repo contains the On-Demand Services SDK documentation.

In this README: 

- [docs-on-demand-service-broker](#docs-on-demand-service-broker)
  - [Branches](#branches)
  - [Releasing a new minor version](#releasing-a-new-minor-version)
  - [Partials](#partials)
  - [Contributing to documentation](#contributing-to-documentation)
  - [Publishing docs](#publishing-docs)
    - [Prepare Markdown files](#prepare-markdown-files)
    - [In Docsdash](#in-docsdash)
    - [Promoting to pre-prod and prod](#promoting-to-pre-prod-and-prod)
  - [Troubleshooting Markdown](#troubleshooting-markdown)
  - [Style Guide](#style-guide)

## Branches

The master branch is the tree-trunk, so **always** make changes you want carried forward in this branch. This includes:

* Unreleased features
* Doc bug fixes
* Doc reorganization or enhancement

Then, if necessary, immediately cherry-pick/copy any changes that you want to push immediately to production into the appropriate branches listed below:

| Branch name     | Use for|
|-----------------| ------|
| main          | Unreleased version (edge - 0.44) https://docs-staging.vmware.com/en/draft/On-Demand-Services-SDK-for-VMware-Tanzu/0.44/on-demand-services-sdk/GUID-index.html|
| v0.43.x         | On staging at https://docs-staging.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.43/on-demand-services-sdk/GUID-index.html and at prod at https://docs-staging.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.43/on-demand-services-sdk/GUID-index.html|
| v0.42.x         | On staging at https://docs-staging.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.42/on-demand-services-sdk/GUID-index.html and on prod at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.42/on-demand-services-sdk/GUID-index.html|
| v0.41.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.41/on-demand-services-sdk-0-41.pdf |
| v0.40.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.40/on-demand-services-sdk-0-40.pdf |
| v0.39.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.39/on-demand-services-sdk-0-39.pdf |
| v0.38.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.38/on-demand-services-sdk-0-38.pdf |
| v0.37.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.37/on-demand-services-sdk-0-37.pdf |
| v0.36.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.36/on-demand-services-sdk-0-36.pdf |
| v0.35.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.35/on-demand-services-sdk-0-35.pdf |
| v0.34.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.34/on-demand-services-sdk-0-34.pdf |
| v0.33.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.33/on-demand-services-sdk-0-33.pdf |
| v0.32.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.32/on-demand-services-sdk-0-32.pdf |
| v0.31.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.31/on-demand-services-sdk-0-31.pdf |
| v0.30.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.30/on-demand-services-sdk-0-30.pdf |
| v0.29.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.29/on-demand-services-sdk-0-29.pdf |
| v0.28.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.28/on-demand-services-sdk-0-28.pdf |
| v0.27.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.27/on-demand-services-sdk-0-27.pdf |
| v0.26.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.26/on-demand-services-sdk-0-26.pdf |
| v0.25.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.25/on-demand-services-sdk-0-25.pdf |
| v0.24.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.24/on-demand-services-sdk-0-24.pdf |
| v0.23.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.23/on-demand-services-sdk-0-23.pdf |
| v0.22.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.22/on-demand-services-sdk-0-22.pdf |
| v0.21.x         | PDF available at https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.21/on-demand-services-sdk-0-21.pdf |
| v0.20.x         | obsolete, but do not delete the branch. PDF available at https://docs.pivotal.io/archives/odb-0.20.pdf. |
| v0.19.x         | obsolete, but do not delete the branch. PDF available at https://docs.pivotal.io/archives/odb-0.19.pdf. |
| v0.18.x         | obsolete, but do not delete the branch. PDF available at https://docs.pivotal.io/archives/odb-0.18.pdf. |
| v0.17.x         | obsolete, but do not delete the branch. PDF available at https://docs.pivotal.io/archives/odb-0.17.pdf. |
| v0.16.x         | obsolete, but do not delete the branch. PDF available at https://docs.pivotal.io/archives/odb-0.16.pdf. |
| v0.15.x         | obsolete, but do not delete the branch. PDF available at https://docs.pivotal.io/archives/odb-0.15.pdf. |
| v0.14.x         | obsolete, but do not delete the branch |
| v0.13.x         | obsolete, but do not delete the branch |
| v0.12.x         | obsolete, but do not delete the branch |
| v0.11.x         | obsolete, but do not delete the branch |
| v0.10.x         | obsolete, but do not delete the branch |
| v0.9.x          | obsolete, but do not delete the branch |

## Releasing a new minor version

Because **main** is the latest and greatest documentation, the process is to cut a **x.x**
branch for the version that **main** was targeting during that time.

After this point, **main** is the target for the next version of the On-Demand Services SDK
product.

## Partials

Cross-product partials (if any) for On-Demand Services SDK are single sourced from the [Docs Partials](https://github.com/pivotal-cf/docs-partials) repository.


## Contributing to documentation

If there is some documentation to add for an unreleased patch version of Cloud Service Broker then create a branch off of the **live** branch
you intend to modify and create a pull request against that branch.
After the version that change is targeting is released, the pull request can be merged and will be live
the next time a documentation deployment occurs.

If the documentation is meant to be target several released versions,
then you will need to:
+ create a pull request for each individual minor version
+ or ask the technical writer to cherry-pick to particular branches/versions.

For instructions on how to create a pull request on a branch and instructions on how to create a
pull request using a fork, see
[Creating a PR](https://docs-wiki.sc2-04-pcf1-apps.oc.vmware.com/wiki/external/create-pr.html)
in the documentation team wiki.

## Publishing docs

- [docworks](https://docworks.vmware.com/) is the main tool for managing docs used by writers.
- [docsdash](https://docsdash.vmware.com/) is a deployment UI which manages the promotion from
staging to pre-prod to production. The process below describes how to upload our docs to staging,
replacing the publication with the same version.

### Prepare Markdown files

- Markdown files live in this repo.
- Images should live in an `images` directory at the same level and linked with a relative link.
- Each page requires an entry in [config/toc.md](config/toc.md) for the table of contents.
- Variables live in [config/template_variables.yml](config/template_variables.yml).

### In Docsdash

1. Wait about 1 minute for processing to complete after uploading.
2. Go to https://docsdash.vmware.com/deployment-stage

   There should be an entry with a blue link which says `Documentation` and points to staging.

### Promoting to pre-prod and prod

**Prerequisite** Needs additional privileges - reach out to a manager on the docs team [#tanzu-docs](https://vmware.slack.com/archives/C055V2M0H) or ask a writer to do this step for you.

1. Go to Staging publications in docsdash  
  https://docsdash.vmware.com/deployment-stage

2. Select a publication (make sure it's the latest version)

3. Click "Deploy selected to Pre-Prod" and wait for the pop to turn green (refresh if necessary after about 10s)

4. Go to Pre-Prod list  
  https://docsdash.vmware.com/deployment-pre-prod

5. Select a publication

6. Click "Sign off for Release"

7. Wait for your username to show up in the "Signed off by" column

8. Select the publication again

9. Click "Deploy selected to Prod"

## Troubleshooting Markdown

| Problem | List displays as a paragraph |
|---------|-----------|
| Symptom:| Bulleted or numbered lists look fine on GitHub but display as a single paragraph in HTML.|
| Solution: | Add a blank line after the stem sentence and before the first item in the list.|

| Problem | List numbering is broken: every item is `1.` |
|---------|-----------|
| Symptom:| Each numbered item in a list is a `1.` instead of `1.`, `2.`, `3.`, etc|
| Solution: | Try removing any blank newlines within each step.|

| Problem | Code boxes not showing |
|---------|-----------|
| Symptom:| VMware publishing system doesn't accept code tags after the three back ticks.|
| Solution: | Make sure you're not using `shell` or `bash` or `console` or `yaml` after back ticks.|

## Style Guide

This is a word list for terminology and word usage specific to the On-Demand Services SDK for docs.
