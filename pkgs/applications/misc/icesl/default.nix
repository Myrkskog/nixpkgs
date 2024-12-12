{ stdenv, lib, fetchzip, freeglut, libXmu, libXi, libX11, libICE, libGLU, libGL, libSM
, libXext, gcc-unwrapped, glibc, lua, luabind, libgccjit, dialog, openssl, makeWrapper }:

let
  lpath = lib.makeLibraryPath [ libXmu libXi libX11 freeglut libICE libGLU libGL libSM libXext gcc-unwrapped glibc lua luabind libgccjit openssl ];
  #makeVersionBeta = beta: "${beta}";
in

stdenv.mkDerivation rec {
  pname = "iceSL";
  version = "2.5.4-beta3"; #statically compiles glfw
  _versionType = "version=beta";

  src =  if stdenv.hostPlatform.system == "x86_64-linux" then fetchzip {
    url = "https://icesl.loria.fr/assets/other/download.php?build=${version}&${_versionType}&os=amd64";
    extension = "zip";
    sha256 = "sha256-BtP/lA9EU2H3DvjYny/6842+3nefjZFEz7GP2y+0iJM=";
    #sha256 = "sha256-db4qj7hg0UnrlCnWAijvMWMgncUWPacnip3jdKU6Vl4="; #hash for 2.5.3 stable
  } else if stdenv.hostPlatform.system == "i686-linux" then fetchzip {
    url = "https://icesl.loria.fr/assets/other/download.php?build=${version}&${_versionType}&os=i386";
    extension = "zip";
    sha256 = "sha256-ZXG3ZX8weJ3hgBqyZj2Ynx2vrUKTqWVYqZDRTv9Z61k="; #hash for 2.5.3 stable
    #sha256 = ""; #2.5.4-beta1 unavailable 2024-11-08 check back
  } else throw "Unsupported architecture";

  nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
    cp -r ./ $out
    mkdir $out/oldbin
    mkdir -p $out/icesl-printers/fff/ARES_RED_CUSTOM/{materials,profiles}
    touch $out/icesl-printers/fff/ARES_RED_CUSTOM/{end.g,features.lua,printer.lua,start.g,startpre.g,swap.g,swappre.g,wait.g}
    touch $out/icesl-themes/mymonochrome.icss
    cp $out/bin/liblua.so $out/oldbin/liblua.so
    cp $out/bin/libluabind.so $out/oldbin/libluabind.so
    mv $out/bin/IceSL-slicer $out/oldbin/IceSL-slicer
    runHook postInstall
  '';

  #added $out/oldbin to rpath to reference liblua.so and libluabind.so

  postInstall = ''
   patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$out/oldbin:${lpath}" \
      $out/oldbin/IceSL-slicer
    makeWrapper $out/oldbin/IceSL-slicer $out/bin/icesl --prefix PATH : ${dialog}/bin
 '';

  #installPhase = ''
  #  cp -r ./ $out
  #  rm $out/bin/*.so
  #  mkdir $out/oldbin
  #  mv $out/bin/IceSL-slicer $out/oldbin/IceSL-slicer
  #  runHook postInstall
  #'';

  #postInstall = ''
  #  patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  #    --set-rpath "${lpath}" \
  #    $out/oldbin/IceSL-slicer
  #  makeWrapper $out/oldbin/IceSL-slicer $out/bin/icesl --prefix PATH : ${dialog}/bin
  #'';

  meta = with lib; {
    description = "GPU-accelerated procedural modeler and slicer for 3D printing";
    homepage = "https://icesl.loria.fr/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.inria-icesl;
    platforms = [ "i686-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ mgttlinger ];
  };
}
