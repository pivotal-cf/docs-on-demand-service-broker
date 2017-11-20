
# How the branches here work

Use **master** for next the unreleased version, and numbered branches for the corresponding live releases. For example:

| Branch name | Use for… |
|-------------| ------|
| master      | Next unreleased version (edge)|
| v0.18.x         | live soon | 
| v0.17.x         | live | 
| v0.16.x         | live |
| v0.15.x        | live |


# Book repo for publishing this content

Book repo: **docs-book-services-sdk**

* **edge:** book branch that publishes the next unreleased version, from the **master** content branch. <br>**Pipeline:** https://concourse.run.pivotal.io/teams/cf-docs/pipelines/cf-services-sdk-edge

* **master:** book branch that publishes all the live versions in production. <br>**Pipeline:** https://concourse.run.pivotal.io/teams/cf-docs/pipelines/cf-services-sdk

# Displaying locally

In order to display our mermaid templates locally (whilst running through `bookbinder watch` for example) the mermaid partials are expected to have file names preprended with an underscore. Unfortunately, this is the exact opposite behaviour to that expected by the templating engine in the live docs.

To help with this we have two scripts to localise, and then revert these diagram files:
* `./scripts/mmd-localise` will prepend each mermaid file with an underscore
* `./scripts/mmd-globalise` will remove the first underscore from each mermaid file
