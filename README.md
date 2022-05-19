# docs-on-demand-service-broker

This repo contains the On-Demand Services SDK documentation.

In this README: 

- [Branches in this Content Repo](#branches-in-this-content-repo)
- [Releasing a New Minor Version](#releasing-a-new-minor-version)
- [Partials](#partials)
- [Contributing to Documentation](#contributing-to-documentation)
- [Publishing Docs](#publishing-docs)
- [Troubleshooting Markdown](#troubleshooting-markdown)
- [Style Guide](#style-guide)

## Branches in this Content Repo

The master branch is the tree-trunk, so **always** make changes you want carried forward in this branch. This includes:

* Unreleased features
* Doc bug fixes
* Doc reorganization or enhancement

Then, if necessary, immediately cherry-pick/copy any changes that you want to push immediately to production into the appropriate branches listed below:

| Branch name     | Use for|
|-----------------| ------|
| master          | Unreleased version (edge - 0.43) https://docs-staging.vmware.com/en/draft/On-Demand-Services-SDK-for-VMware-Tanzu/0.43/on-demand-services-sdk/GUID-index.html|
| v0.42.x         | live on June 3, 2021 https://docs.vmware.com/en/On-Demand-Services-SDK-for-VMware-Tanzu/0.42/on-demand-services-sdk/GUID-index.html|
| v0.41.x         | live on April 16, 2021 https://docs.pivotal.io/svc-sdk/odb/0-41|
| v0.40.x         | live on July 13, 2020 https://docs.pivotal.io/svc-sdk/odb/0-40|
| v0.39.x         | live on April 3, 2020 https://docs.pivotal.io/svc-sdk/odb/0-39|
| v0.38.x         | live on February, 2020 https://docs.pivotal.io/svc-sdk/odb/0-38|
| v0.37.x         | live on January 30, 2020 https://docs.pivotal.io/svc-sdk/odb/0-37|
| v0.36.x         | live on January 2, 2020 https://docs.pivotal.io/svc-sdk/odb/0-36|
| v0.35.x         | live on November 12, 2019 https://docs.pivotal.io/svc-sdk/odb/0-35|
| v0.34.x         | live on October 15, 2019 https://docs.pivotal.io/svc-sdk/odb/0-34|
| v0.33.x         | live on September 11, 2019 https://docs.pivotal.io/svc-sdk/odb/0-33|
| v0.32.x         | live on August 28, 2019 https://docs.pivotal.io/svc-sdk/odb/0-32|
| v0.31.x         | live on June 12, 2019 https://docs.pivotal.io/svc-sdk/odb/0-31|
| v0.30.x         | live on June 7, 2019 https://docs.pivotal.io/svc-sdk/odb/0-30|
| v0.29.x         | live on May 22, 2019 https://docs.pivotal.io/svc-sdk/odb/0-29|
| v0.28.x         | live on April 26, 2019 https://docs.pivotal.io/svc-sdk/odb/0-28|
| v0.27.x         | live on April 5, 2019 https://docs.pivotal.io/svc-sdk/odb/0-27|
| v0.26.x         | live on Feb 20, 2019 https://docs.pivotal.io/svc-sdk/odb/0-26|
| v0.25.x         | live on Dec 5, 2018 https://docs.pivotal.io/svc-sdk/odb/0-25|
| v0.24.x         | live on Nov 14, 2018 https://docs.pivotal.io/svc-sdk/odb/0-24|
| v0.23.x         | live on Sept 18, 2018 https://docs.pivotal.io/svc-sdk/odb/0-23|
| v0.22.x         | live | https://docs.pivotal.io/svc-sdk/odb/0-22|
| v0.21.x         | live | https://docs.pivotal.io/svc-sdk/odb/0-21|
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

## Releasing a New Minor Version

Because **master** is the latest and greatest documentation, the process would be to cut a **x.x** branch
for the version that **master** was targeting during that time.

After this point, **master** will then be the target for the next version of the On-Demand Services SDK product.


## Partials

Cross-product partials (if any) for On-Demand Services SDK are single sourced from the [Docs Partials](https://github.com/pivotal-cf/docs-partials) repository.


## Contributing to Documentation

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


## Publishing Docs

- [docworks](https://docworks.vmware.com/) is the main tool for managing docs used by writers.
- [docsdash](https://docsdash.vmware.com/) is a deployment UI which manages the promotion from
staging to pre-prod to production. The process below describes how to upload our docs to staging,
replacing the publication with the same version.

### Prepare Markdown Files
- Markdown files live in this repo.
- Images should live in an `images` directory at the same level and linked with a relative link.
- Each page requires an entry in [config/toc.md](config/toc.md) for the table of contents.
- Variables live in [config/template_variables.yml](config/template_variables.yml).

### In Docsdash

1. Wait about 1 minute for processing to complete after uploading.
2. Go to https://docsdash.vmware.com/deployment-stage

   There should be an entry with a blue link which says `Documentation` and points to staging.

### Promoting to Pre-Prod and Prod

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
