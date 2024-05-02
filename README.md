# GitHub Action: Run rubocop with reviewdog 🐶

[![](https://img.shields.io/github/license/reviewdog/action-rubocop)](./LICENSE)
[![depup](https://github.com/reviewdog/action-rubocop/workflows/depup/badge.svg)](https://github.com/reviewdog/action-rubocop/actions?query=workflow%3Adepup)
[![release](https://github.com/reviewdog/action-rubocop/workflows/release/badge.svg)](https://github.com/reviewdog/action-rubocop/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/reviewdog/action-rubocop?logo=github&sort=semver)](https://github.com/reviewdog/action-rubocop/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

This action runs [rubocop](https://github.com/rubocop/rubocop) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Examples

### With `github-pr-check`

By default, with `reporter: github-pr-check` an annotation is added to the line:

![Example comment made by the action, with github-pr-check](./examples/example-github-pr-check.png)

### With `github-pr-review`

With `reporter: github-pr-review` a comment is added to the Pull Request Conversation:

![Example comment made by the action, with github-pr-review](./examples/example-github-pr-review.png)

## Inputs

<!-- Please maintain inputs in alphabetical order -->

### `fail_on_error`

Optional. Exit code for reviewdog when errors are found [`true`, `false`].
Default is `false`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [`added`, `diff_context`, `file`, `nofilter`].
Default is `added`.

### `github_token`

`GITHUB_TOKEN`. Default is `${{ github.token }}`.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `only_changed`

Optional. Run Rubocop only on changed (and added) files, for speedup [`true`, `false`].
Default: `false`.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-check`, `github-pr-review`].
The default is `github-pr-check`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

### `rubocop_extensions`

Optional. Set list of rubocop extensions with versions.

By default install `rubocop-rails`, `rubocop-performance`, `rubocop-rspec`, `rubocop-i18n`, `rubocop-rake` with latest versions.
Provide desired version delimited by `:` (e.g. `rubocop-rails:1.7.1`)

Possible version values:

- empty or omit (`rubocop-rails rubocop-rspec`): install latest version
- `rubocop-rails:gemfile rubocop-rspec:gemfile`: install version from Gemfile (`Gemfile.lock` should be presented, otherwise it will fallback to latest bundler version)
- version (e.g. `rubocop-rails:1.7.1 rubocop-rspec:2.0.0`): install said version

You can combine `gemfile`, fixed and latest bundle version as you want to.

### `rubocop_flags`

Optional. Rubocop flags. (rubocop `<rubocop_flags>`).

### `rubocop_version`

Optional. Set rubocop version. Possible values:

- empty or omit: install latest version
- `gemfile`: install version from Gemfile (`Gemfile.lock` should be presented, otherwise it will fallback to latest bundler version)
- version (e.g. `0.90.0`): install said version

### `skip_install`

Optional. Do not install Rubocop or its extensions. Default: `false`.

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `use_bundler`

Optional. Run Rubocop with bundle exec. Default: `false`.

### `workdir`

Optional. The directory from which to look for and run Rubocop. Default `.`.

## Example usage

This action will use your [RuboCop Configuration](https://docs.rubocop.org/rubocop/configuration.html) automatically.

In your `Gemfile`, ensure all Rubocop gems are in a named (e.g. rubocop) group:

```ruby
group :development, :rubocop do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  # ...
end
```

Create the following workflow. The `BUNDLE_ONLY` environment variable will tell Bundler to only install the specified group.

```yml
name: reviewdog
on:
  pull_request:
permissions:
  contents: read
  pull-requests: write
jobs:
  rubocop:
    name: runner / rubocop
    runs-on: ubuntu-latest
    env:
      BUNDLE_ONLY: rubocop
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - uses: reviewdog/action-rubocop@v2
        with:
          reporter: github-pr-review # Default is github-pr-check
          skip_install: true
          use_bundler: true
```

## Sponsor

<p>
  <a href="https://evrone.com/?utm_source=github&utm_campaign=action-rubocop">
    <img src="https://www.mgrachev.com/assets/static/sponsored_by_evrone.svg?sanitize=true"
      alt="Sponsored by Evrone">
  </a>
</p>

## License

[MIT](https://choosealicense.com/licenses/mit)
