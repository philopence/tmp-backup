with import <nixpkgs> {};
{
  myProject = stdenv.mkDerivation {
    name = "myProject";
    version = "1";
    src = if lib.inNixShell then null else nix;

    buildInputs = with rPackages; [
      R
      openair
      mice readr ggplot2 openair tseries plyr reshape
      UpSetR RColorBrewer openxlsx tidyverse
      dada2
    ];
  };
}
