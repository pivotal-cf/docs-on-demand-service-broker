
# How the branches here work

Use **master** for next the unreleased version, and numbered branches for the corresponding live releases.
The latest version on **master** is routed to "/svc-sdk/odb/0-n". This is to facilitate ease of access, push quicker to production, and reduce the need for large changes to the associated files.

For example:

| Branch name     | Use for|
|-----------------| ------|
| master          | Unreleased version (edge - 0.41) https://docs-pcf-staging.cfapps.io/svc-sdk/odb/0-n|
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

# Book repo for publishing this content

The book repo is [**docs-book-odb**](https://github.com/pivotal-cf/docs-book-odb).


## Partials

Cross-product partials for **On-Demand Service Broker SDK** v0.23.x branch are single sourced from the [Docs Partials](https://github.com/pivotal-cf/docs-partials) repo.

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
