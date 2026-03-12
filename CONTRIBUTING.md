# Contributing

## Development

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0

### Setup

```bash
git clone https://github.com/aashishvanand/airport-data-dart.git
cd airport-data-dart
dart pub get
```

### Running Tests

```bash
dart test
```

### Running Analysis

```bash
dart analyze --fatal-infos
dart format --output=none --set-exit-if-changed .
```

## CI/CD

### How CI Works

Every push to `main` and every pull request targeting `main` triggers the **CI** workflow, which runs:

- `dart analyze --fatal-infos`
- `dart format --output=none --set-exit-if-changed .`
- `dart test`

### How Publishing Works

Publishing to [pub.dev](https://pub.dev/packages/airport_data) is fully automated via GitHub Actions using [OIDC authentication](https://dart.dev/tools/pub/automated-publishing). It is triggered by pushing a git tag that matches the pattern `v*.*.*`.

pub.dev requires the publish to come from a **tag ref** (not a branch). The `pub.dev` GitHub Actions environment is configured with required reviewers, so every publish requires manual approval.

## Releasing a New Version

### Step 1: Update the version

Edit `pubspec.yaml` and bump the `version` field:

```yaml
version: 1.1.0  # bump from previous version
```

### Step 2: Update the changelog

Add a new section at the top of `CHANGELOG.md`:

```markdown
## 1.1.0

- Description of what changed
```

### Step 3: Commit and push to main

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "release: v1.1.0"
git push origin main
```

This triggers CI. Wait for it to pass.

### Step 4: Create and push the tag

The tag **must** match the version in `pubspec.yaml` and follow the pattern `v<version>`:

```bash
git tag v1.1.0
git push origin v1.1.0
```

This triggers the **Publish to pub.dev** workflow.

### Step 5: Approve the deployment

1. Go to [GitHub Actions](https://github.com/aashishvanand/airport-data-dart/actions)
2. Click the **"Publish to pub.dev"** run for your tag
3. Click **"Review deployments"**
4. Approve the `pub.dev` environment

The package will be published to [pub.dev/packages/airport_data](https://pub.dev/packages/airport_data).

### Quick Reference

```bash
# Full release flow (after editing pubspec.yaml and CHANGELOG.md)
git add pubspec.yaml CHANGELOG.md
git commit -m "release: v1.1.0"
git push origin main
# Wait for CI to pass, then:
git tag v1.1.0
git push origin v1.1.0
# Go to GitHub Actions → Approve the deployment
```

## Updating Airport Data

To regenerate the embedded airport data from an updated `data/airports.json`:

```bash
dart run tool/generate_embedded_data.dart
```

This regenerates `lib/src/airport_data_embedded.dart`. Include it in your commit.
