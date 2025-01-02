{
  lib,
  stdenv,
  SDL2,
  fetchurl,
  gzip,
  libvorbis,
  libmad,
  flac,
  libopus,
  opusfile,
  libogg,
  curl,
  libxmp,
  mpg123,
  vulkan-headers,
  vulkan-loader,
  copyDesktopItems,
  makeDesktopItem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sprawl96";
  version = "1.2";

  src = fetchurl {
    url = "https://github.com/VoidForce/sprawl96_QC/archive/refs/tags/${finalAttrs.version}.tar.gz";
    hash = "sha256-V83VTxmy341iPCJo+yo1iUIzh/AtsW69omfQ3jlMWAs=";
  };

  sourceRoot = "sprawl96_QC-${finalAttrs.version}/Quake";

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    vulkan-headers
    gzip
    libvorbis
    libmad
    flac
    curl
    libopus
    opusfile
    libogg
    libxmp
    mpg123
    vulkan-loader
    SDL2
  ];

  buildFlags = [
    "DO_USERDIRS=1"
    # Makefile defaults, set here to enforce consistency on Darwin build
    "USE_CODEC_WAVE=1"
    "USE_CODEC_MP3=1"
    "USE_CODEC_VORBIS=1"
    "USE_CODEC_FLAC=1"
    "USE_CODEC_OPUS=1"
    "USE_CODEC_MIKMOD=0"
    "USE_CODEC_UMX=0"
    "USE_CODEC_XMP=1"
    "MP3LIB=mad"
    "VORBISLIB=vorbis"
    "SDL_CONFIG=sdl2-config"
    "USE_SDL2=1"
  ];

  preInstall = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/share/quake"
    substituteInPlace Makefile --replace-fail "cp sprawl96.pak /usr/local/games/quake" "cp sprawl96.pak $out/share/quake/sprawl96.pak"
    substituteInPlace Makefile --replace-fail "/usr/local/games/quake" "$out/bin/sprawl96"
  '';

  enableParallelBuilding = true;

  desktopItems = [
    (makeDesktopItem {
      name = "sprawl96";
      exec = "sprawl96";
      desktopName = "Sprawl96";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Fork of the QuakeSpasm engine for iD software's Quake";
    homepage = "https://github.com/andrei-drexler/ironwail";
    longDescription = ''
      Ironwail is a fork of QuakeSpasm with focus on high performance instead of
      compatibility.
      It features the ability to play the 2021 re-release content with no setup
      required, a mods menu for quick access to installation of mods, and ease of
      switching to installed mods.
      It also include various visual features as well as improved limits for playing
      larger levels with less performance impacts.
    '';

    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.necrophcodr ];
    mainProgram = "sprawl96";
  };
})
