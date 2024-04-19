# Makefile CI module

[![License][license-image]][license-url]

> Default makefile workflow for makefiles

## Getting Started

This package provides a common CI workflow for build apps.
By using makefile you will be able :

- to configure easily CI independently from the project technology (ex: `make build` will always build sources wether it is ruby/nodejs/...)
- to launch locally the CI
- to debug the CI easily

## Features

- 🔧 Zero Conf philosophy
  - ✓ Default configuration for most common cases
  - ✓ Override settings in the project `Makefile` if needed
- Supported Technologies :
  - ASDF
  - NodeJS
  - Ruby
  - Docker

## Usage

### Installer

Pre-requisite : [Makefile Core](https://github.com/Captive-Studio/makefile-core)

```console
make self-add url=https://github.com/Captive-Studio/makefile-ci
```

## Documentation

### Display information

`makefile-ci` is compatible with `makefile-core` auto-documentation

**Display all targets and variables**

```shell
make help
```

**Display all variables and their value**

```shell
make print-variables
```

## Contributing

TODO

## Acknowledgement

These repository were inspirations to build makefile-core :

- <https://github.com/ianstormtaylor/makefile-help>
- <https://github.com/tmatis/42make>

## License
<!-- AUTO-GENERATED-CONTENT:START (PKG_JSON:template=[${license}][license-url] © ${author}) -->
[MIT][license-url] © Captive Studio
<!-- AUTO-GENERATED-CONTENT:END -->

<!-- VARIABLES -->

<!-- AUTO-GENERATED-CONTENT:START (PKG_JSON:template=[package-version-svg]: https://img.shields.io/npm/v/${name}.svg?style=flat-square) -->
<!-- AUTO-GENERATED-CONTENT:END -->
<!-- AUTO-GENERATED-CONTENT:START (PKG_JSON:template=[package-url]: https://www.npmjs.com/package/${name}) -->
<!-- AUTO-GENERATED-CONTENT:END -->
<!-- AUTO-GENERATED-CONTENT:START (PKG_JSON:template=[license-image]: https://img.shields.io/badge/license-${license}-green.svg?style=flat-square) -->
[license-image]: https://img.shields.io/badge/license-MIT-green.svg?style=flat-square
<!-- AUTO-GENERATED-CONTENT:END -->
[license-url]: ./LICENSE
