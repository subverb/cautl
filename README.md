[![pipeline status](https://git.dresden.micronet24.de/benjamin/cautl/badges/master/pipeline.svg)](https://git.dresden.micronet24.de/benjamin/cautl/commits/master)

# Cautl #

The *C*ertificate *A*uthority *UT*i*L*s should provide a reasonable toolset
to handle personal as well as server certificates.

While nowadays nearly every tool providing encryption brings there own set
of tools for creating and/or signing certificates, cautl wants to integrate
in a way, that these certificates can be handled via a single interface.
By default, most of the functionality is provided by wrapping around openssl,
but other handlers should be able to integrate as well.

## INSTALLATION ##

### PREREQUISITES ###

Most of cautl is pure shell scripting, but to provide some functionality, the
following software should be available on the machine before using cautl:

* bash
* subverb - https://git.dresden.micronet24.de/benjamin/subverb.git or the local submodule
* openssl
* ruby

With this software availble, `cautl` should do its work and `cautl init` should initialize
your certificate store.
