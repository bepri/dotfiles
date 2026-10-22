---
name: starcraft-context
description: Starcraft team context for Canonical craft repositories. Use ONLY when working inside a repository whose name contains "star" or "craft" (snapcraft, charmcraft, rockcraft, imagecraft, debcraft, craft-*, starbase, starflow, craft-actions). Provides team conventions, library map, build/test commands, and backward-compatibility rules specific to those repos.
---

# Starcraft Team Context

## Team & Organization

The user works on the **Starcraft team** at **Canonical**, which builds and
maintains a suite of Python CLI tools and shared libraries under the
`canonical` GitHub organization.

## The Craft Tools

Public, user-facing applications (collectively "the craft tools", "our tools",
or "the craft apps"):
- `snapcraft`
- `charmcraft`
- `rockcraft`
- `imagecraft`
- `debcraft`

The team also has **strictly private, internal** craft tools under active
development.

## Craft Apps and Libraries

All craft tools are built on a set of shared libraries:

| Package             | Role                                                                                          |
| ------------------- | --------------------------------------------------------------------------------------------- |
| `craft-application` | Application framework: CLI lifecycle, configuration, service management, remote build support |
| `craft-archives`    | Repository and package archive management (apt sources, keyrings)                             |
| `craft-cli`         | Terminal output, progress reporting, error formatting                                         |
| `craft-grammar`     | Architecture and platform-conditional YAML in project files                                   |
| `craft-parts`       | Part lifecycle (pull, build, overlay, stage, prime) steps, plugins                            |
| `craft-platforms`   | Platform and architecture abstractions                                                        |
| `craft-providers`   | Build environment manager for LXD and Multipass                                               |
| `craft-store`       | Store API client: upload, release, track management                                           |

Fixes or features that are generic or would benefit other craft apps must be
made in the correct craft library. Overriding an upstream function to fix a
bug in the library isn't acceptable.

## Special Repositories

- **`starbase`** — the "base structure" shared by all team repositories: base
  Python configuration, Makefile, docs scaffolding. Periodically merged into
  other repos (called "starbasing" or "updating starbase").
- **`starflow`** — internal GitHub Actions workflows for the team. Public repo.
- **`craft-actions`** — GitHub Actions workflows maintained by the Starcraft
  team for **external users** of the craft tools.

## Development

Most repos use [uv](https://docs.astral.sh/uv/) for dependency management.
Exceptions: non-Python repos like `craft-actions` and `starflow`.

```
make setup          # Install all deps
make test           # Full test suite
make test-fast      # Fast tests only
uv run pytest tests/unit/path/to/test_file.py::test_name  # run one test
```

End-to-end tests (`tests/spread/`) use [spread](https://github.com/canonical/spread/)
and need extra local setup. Run them for comprehensive changes or changes that
can't be fully verified with unit and integration tests. They're expensive, so
extend existing spread tests when appropriate.

Documentation uses [Diátaxis](https://diataxis.fr) and the
[Sphinx Stack](https://github.com/canonical/sphinx-stack). Docs must follow
the [Starcraft style guide](https://documentation.ubuntu.com/starflow/latest/how-to/starcraft-style-guide/)
and the [Canonical style guide](https://documentation.ubuntu.com/style-guide/).

```
make setup-docs
make docs
make lint-docs
```

## Practices

- Backward compatibility is a **hard requirement**. Existing projects must
  continue to build successfully without requiring user modifications.
  Changes that alter behavior, configuration, APIs, defaults, or validation
  rules must be opt-in or gated behind a newer base. When modifying business
  logic, verify that existing behavior is preserved and explain how you
  verified it.
  - Experimental features and development bases (`build-base: devel`) are not
    subject to this requirement.
