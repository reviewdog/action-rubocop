# GitHub Action: Run rubocop with reviewdog 🐶

![](https://github.com/reviewdog/action-rubocop/workflows/CI/badge.svg)
![](https://img.shields.io/github/license/reviewdog/action-rubocop)
![](https://img.shields.io/github/v/release/reviewdog/action-rubocop)

This action runs [rubocop](https://github.com/rubocop-hq/rubocop) with
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

### `github_token`

**Required**. Must be in form of `github_token: ${{ secrets.github_token }}`'.

### `rubocop_flags`

Optional. rubocop flags. (rubocop `<rubocop_flags>`)

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-pr-review`].
The default is `github-pr-check`.

### `rubocop_version`

Optional. Set rubocop version. 
By default install latest version.

### `rubocop_extensions`

Optional. Set list of rubocop extensions with versions. 

By default install rubocop-rails rubocop-performance rubocop-rspec rubocop-i18n rubocop-rake with latest versions.

## Example usage

```yml
name: reviewdog
on: [pull_request]
jobs:
  rubocop:
    name: runner / rubocop
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v1
      - name: rubocop
        uses: reviewdog/action-rubocop@v1
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review # Default is github-pr-check
          rubocop_version: 0.80.1
          rubocop_extensions: rubocop-performance:1.5.1 rubocop-minitest
```

## Sponsor

<p>
  <a href="https://evrone.com/?utm_source=action-rubocop">
    <img src="https://www.mgrachev.com/assets/static/evrone-sponsored-300.png" 
      alt="Sponsored by Evrone" width="210">
  </a>
</p>

## License

[MIT](https://choosealicense.com/licenses/mit)
