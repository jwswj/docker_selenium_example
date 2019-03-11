# Docker Rails Selenium Buildkite

An example of how to get tests running in Buildkite with Rails when
your Rails project has a few common complexities.

## Overview

This is a bare-bones Rails app.

Data stores:

* PostgreSQL
* Redis

Testing:

* RSpec
* Capybara

Tests are run on Buildkite. All the details are in the `.buildkite` directory.

## Where to looks

```
.buildkite
spec/support/capybara.rb
```

Everything else is just stock standard Rails.
