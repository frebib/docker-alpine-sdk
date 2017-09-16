[hub]: https://hub.docker.com/frebib/alpine-abuild
[abuild-docs]: https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package

# [frebib/alpine-sdk][hub] - Alpine Linux container for `abuild`

This container provides an _almost seamless_ Vanilla Alpine Linux `abuild` environment with many of the creature comforts of your host OS.

Refer to the [Alpine documentation][abuild-docs] on how to build packages using the `abuild` system

## Usage
### Basic usage

Mounting `~/.abuild` within the container ensures persistent keys and other important files

```bash
docker run -ti --rm \
    -e USER \
    -v ~/.abuild:/home/$USER/.abuild \
    frebib/alpine-sdk
```

For convenience, a quick alias can simplify this workflow for you

```bash
alias alpine-sdk="docker run -ti --rm -e USER -v ~/.abuild:/home/$USER/.abuild frebib/alpine-sdk"
```

### Advanced usage

Often it can be useful to add `~/.config/git` and `~/.gnupg` for Git and GPG configuration respectively; the latter of the two particularly useful when using a GPG key to sign git commits.

**Note:** _It can be a good idea to mount these directories read-only to prevent any unwanted changes or alterations to important data or configuration._
**Be aware that most GPG commands/functions won't work correctly when mounted read-only**

```bash
docker run -ti --rm \
    -e USER \
    -v ~/.abuild:/home/$USER/.abuild \
    -v ~/.config/git:/home/$USER/.config/git:ro \
    -v ~/.gnupg:/home/$USER/.gnupg \
    frebib/alpine-sdk
```

## Building

To build the image for the latest version of alpine, run the following commands:

```bash
docker build -t frebib/alpine-sdk .
```

To build for a specific version of alpine, or with a different image, optionally override the `$IMAGE` or `$TAG` arguments:

```bash
docker build -t frebib/alpine-sdk --build-arg IMAGE=alpine-variant --build-arg TAG=3.5 .
```
