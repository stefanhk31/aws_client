# Aws Client

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A client to call AWS services. Uses [AWS Signature v4](https://pub.dev/packages/aws_signature_v4) package to send signed request to AWS services.

## Installation 💻

**❗ In order to start using Aws Client you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add aws_client
```

---

## Usage 

Using this client requires access credentials to AWS. By default, the `AWSSigV4Signer` injected into this client 
pulls credentials from your environment via the `AWSCredentialsProvider.environment()` provider.

On mobile and web, this means using the Dart environment which is configured by passing the --dart-define flag to your flutter commands, e.g.

```sh
$ flutter run --dart-define=AWS_ACCESS_KEY_ID=... --dart-define=AWS_SECRET_ACCESS_KEY=...
```

On Desktop, credentials are retrieved from the system's environment using [Platform.environment](https://api.dart.dev/stable/dart-io/Platform/environment.html).

The signer works by transforming HTTP requests using your credentials to create _signed_ HTTP requests which can be sent off in the
same way as normal HTTP requests.

To override this default, you can pass your own `AWSSigV4Signer`, and overriding the `credentialsProvider` parameter of the signer.  

## Continuous Integration 🤖

Aws Client comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.2.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
