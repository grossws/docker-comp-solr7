# Info

[Apache Solr 7][solr] basic [Dockerfiles][df] for automated builds on [docker hub][dhub].

Based on `grossws/java` image.

## Default configuration

Has preconfigured `core0` placed at `/solr/data/core0/` with
*configset* `_default` at `/solr/date/configsets/_default/`,
*datadir* `/solr/data/core0/data/` and
*solrhome* at `/solr/data/`.

Schema includes `id`, `_version_` and `text` fields plus dynamicFields for all present types.

## Included extras

- Support for [DocValuesTextField][dvtf] `FieldType` allowing analyzed fields stored in `docValues`;
- Automatic `gzip` support via [Eclipse Jetty][jetty] [gzip.mod](https://github.com/eclipse/jetty.project/blob/jetty-9.4.x/jetty-server/src/main/config/modules/gzip.mod);
- Updated [Google Guava][guava] (version 20.0 instead of 14.0)

Is part of the [docker-components][dcomp] repo.

[df]: http://docs.docker.com/reference/builder/ "Dockerfile reference"
[dhub]: https://hub.docker.com/u/grossws/
[dcomp]: https://github.com/grossws/docker-components
[dvtf]: https://github.com/grossws/solr-dvtf
[jetty]: https://www.eclipse.org/jetty/
[guava]: https://github.com/google/guava


# Licensing

Licensed under MIT License. See [LICENSE file](LICENSE)


# Thirdparty

Contains:
- [Apache Solr 7][solr], licensed under [Apache License, Version 2.0][apl] and its dependencies.

  Full Solr license can be found in `/solr/LICENSE` in container.
  It's components licensing info can be found in `/solr/NOTICE` and `/solr/licenses/` in container.

- [DocValuesTextField][dvtf], licensed under [MIT License][dvtf-license]

[apl]: http://www.apache.org/licenses/LICENSE-2.0
[dvtf-license]: https://github.com/grossws/solr-dvtf/blob/master/LICENSE
[solr]: http://lucene.apache.org/solr/

