FROM debian:bullseye-slim as installer

ENV PATH /usr/local/bin/texlive:$PATH

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
           ca-certificates \
           perl \
           wget \
           xz-utils \
           fontconfig
RUN wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN tar -xzf ./install-tl-unx.tar.gz --strip-components=1
COPY ./install.profile ./
RUN ./install-tl -profile=install.profile
RUN ln -sf /usr/local/texlive/*/bin/* /usr/local/bin/texlive
RUN tlmgr install \
  lm \
  amsfonts \
  amsmath \
  mathtools \
  rsfs \
  jknapltx \
  tools \
  physics \
  braket \
  graphics \
  subfiles \
  standalone \
  jsclasses \
  everyhook \
  filehook \
  svn-prov \
  kvoptions \
  infwarerr \
  pgf \
  pxpgfmark \
  pxjahyper \
  plautopatch \
  platex-tools \
  jlreq \
  japanese-otf \
  jlreq-deluxe \
  beamer \
  bxdpx-beamer \
  uplatex \
  dvipdfmx \
  adobemapping \
  haranoaji \
  haranoaji-extra \
  ptex-fontmaps \
  cluttex
RUN kanji-config-updmap-sys haranoaji
RUN wget https://github.com/jgm/pandoc/releases/download/3.1.2/pandoc-3.1.2-linux-amd64.tar.gz
RUN tar -xzf pandoc-3.1.2-linux-amd64.tar.gz
RUN cp ./pandoc-3.1.2/bin/pandoc /usr/local/bin/

FROM debian:bullseye-slim

ENV PATH=/usr/local/bin/texlive:$PATH
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=installer /usr/local/texlive /usr/local/texlive
COPY --from=installer /usr/local/bin/pandoc /usr/local/bin/pandoc
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    perl \
    wget \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && ln -sf /usr/local/texlive/*/bin/* /usr/local/bin/texlive