# Contributing to Very Good Claude Marketplace

First off, thanks for taking the time to contribute! This guide explains how to add a plugin to the Very Good Claude Marketplace.

## Adding a Plugin

To add a new plugin to the marketplace, you need to update two files:

### 1. Update `marketplace.json`

Add a new entry to the `plugins` array in `.claude-plugin/marketplace.json`:

```json
{
  "name": "your-plugin-name",
  "description": "A short description of what your plugin does",
  "version": "0.0.1",
  "source": {
    "source": "github",
    "repo": "Owner/repository_name"
  },
  "repository": "https://github.com/Owner/repository_name",
  "homepage": "https://github.com/Owner/repository_name",
  "author": {
    "name": "Your Name or Organization",
    "email": "your-email@example.com"
  }
}
```

### 2. Update `README.md`

Add a row to the **Plugins** table in `README.md` with:

- A link to the plugin's GitHub repository (matching the `repository` field in your marketplace entry)
- An accurate description of the plugin

## Keeping Plugin Versions in Sync

Plugin versions in `marketplace.json` are kept up to date automatically. The
[`Sync Plugin Versions`](.github/workflows/sync-plugin-versions.yaml) workflow
runs once a day (and can be triggered manually), reads the latest GitHub release
of every plugin's repository, and opens a single pull request against `main`
whenever a newer release is available. You do not need to bump plugin versions by
hand.

**Metadata version policy:** any sync that bumps one or more plugin versions also
bumps the marketplace `metadata.version` by one patch (`x.y.z` to `x.y.z+1`).
Minor and major bumps of `metadata.version` are manual and reserved for
structural changes, such as adding or removing a plugin or changing the
marketplace schema.

The `README.md` table does not reference plugin versions, so the sync only
touches `marketplace.json`. Adding or removing a plugin is still manual and must
update both files as described above.

## Opening a Pull Request

1. Fork the repository.
2. Create a new branch for your changes.
3. Make your changes following the steps above.
4. Ensure `marketplace.json` is valid JSON.
5. Open a pull request against the `main` branch.

## Reporting Issues

If you find a bug or have a suggestion, please [open an issue](https://github.com/VeryGoodOpenSource/very_good_claude_marketplace/issues/new).

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
