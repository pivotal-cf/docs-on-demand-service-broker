
# How the branches here work

Use **master** for next the unreleased version, and numbered branches for the corresponding live releases.
The latest version on **master** is routed to "/svc-sdk/odb/0-2n". This is to facilitate ease of access, push quicker to production, and reduce the need for large changes to the associated files.

For example:

| Branch name     | Use for|
|-----------------| ------|
| master          | Unreleased version (edge - 0.24) https://docs-pcf-staging.cfapps.io/svc-sdk/odb/0-2n|
| v0.23.x         | live on Sept 18, 2018 https://docs-pcf-staging.cfapps.io/svc-sdk/odb/0-23|
| v0.22.x         | live |
| v0.21.x         | live |
| v0.20.x         | live |
| v0.19.x         | live | 
| v0.18.x         | live | 
| v0.17.x         | live | 
| v0.16.x         | live |
| v0.15.x         | live |
| v0.14.x         | obsolete, but do not delete the branch | 
| v0.13.x         | obsolete, but do not delete the branch | 
| v0.12.x         | obsolete, but do not delete the branch | 
| v0.11.x         | obsolete, but do not delete the branch | 
| v0.10.x         | obsolete, but do not delete the branch | 
| v0.9.x          | obsolete, but do not delete the branch | 

**Note:** Edits to partials on the v0.18.x branch should be sycned with their corresponding partial in the [Services Partials](https://github.com/pivotal/docs-services-partials) repo. Eventually, `docs-on-demamd-service-broker` partials will sourced from the Services Partials repo and removed here. 

# Book repo for publishing this content

Book repo: **docs-book-services-sdk**

* **edge:** book branch that publishes the next unreleased version, from the **master** content branch. <br>**Pipeline:** https://concourse.run.pivotal.io/teams/cf-docs/pipelines/cf-services-sdk-edge

* **master:** book branch that publishes all the live versions in production. <br>**Pipeline:** https://concourse.run.pivotal.io/teams/cf-docs/pipelines/cf-services-sdk

## Partials

Cross-product partials for **On-Demand Service Broker SDK** are single sourced from the [Services Partials](https://github.com/pivotal-cf/docs-services-partials) repo.

Previously, these partials were sourced from the v018.x branch of the [On Demand Service Broker SDK](https://github.com/pivotal-cf/docs-on-demand-service-broker/tree/v0.18.x) content repo.

# Proccess for working in this repo

## Submit changes to the docs through PRs

Instructions on doing a PR: https://docs.google.com/a/pivotal.io/document/d/14Go0uCj20BFMBzL2ddEKsZp-GONhVp0yr2cEFSskWnQ/edit?usp=sharing

## New (unpublished) releases

1. Commit new feature docs to **master** only.

2. When the release is ready to publish, the docs team will create a new live/production branch from master, for example, 0.19.x.

## Fixes and enhancements on master

1. For fixes and enhancement, make PRs to **master**.

2. Tell the docs team in the PR, if it should be applied to other specific branches (or make additional PRs to those branches).

## Fixes on branch only

If the fix or enhancement is only relevant to a particular branch, then apply the change to that branch only.

# Displaying locally

In order to display our mermaid templates locally (whilst running through `bookbinder watch` for example) the mermaid partials are expected to have file names preprended with an underscore. Unfortunately, this is the exact opposite behaviour to that expected by the templating engine in the live docs.

To help with this we have two scripts to localise, and then revert these diagram files:
* `./scripts/mmd-localise` will prepend each mermaid file with an underscore
* `./scripts/mmd-globalise` will remove the first underscore from each mermaid file

