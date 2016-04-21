#!/bin/bash -eu
set -o pipefail

docs_book_dir=$(dirname $0)/../../docs-book-pivotalcf

if [ ! -d $docs_book_dir ]; then
  echo "$docs_book_dir must exist as a directory" >&2
  exit 1
fi

(cd $docs_book_dir && bundle install && (bundle exec bookbinder bind local || true)) # bookbinder always exits non-zero due to broken links, we don't clone everyone's docs
(cd $docs_book_dir/final_app && rm Gemfile.lock && bundle install && bundle exec rackup)
