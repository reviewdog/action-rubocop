# GitHub Action: Run rubocop with reviewdog

This action runs [rubocop](https://github.com/rubocop-hq/rubocop) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Inputs

### `github_token`

**Required**. Must be in form of `github_token: ${{ secrets.github_token }}`'.

### `rubocop_flags`

Optional. rubocop flags. (rubocop `<rubocop_flags>`)

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

## Example usage

```yml
name: reviewdog
on: [pull_request]
jobs:
  misspell:
    name: runner / rubocop
    runs-on: ubuntu-latest
    steps:
      - name: Check out code.
        uses: actions/checkout@v1
      - name: rubocop
        uses: mgrachev/action-rubocop@v0.1.3
        with:
          github_token: ${{ secrets.github_token }}
```

## Sponsor

<p>
  <a href="https://evrone.com/?utm_source=action-rubocop">
    <img src="https://solovev.one/static/evrone-sponsored-300.png" 
      alt="Sponsored by Evrone" width="210">
  </a>
</p>
