#!/usr/bin/env bash

# install-r.sh - Install R, GLPK (for Rglpk), and the R packages used by
# FantasyFootballAnalyticsR. No Homebrew required.
#
# Safe to re-run: each step is skipped if already satisfied.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}install-r.sh only supports macOS.${NC}"
    exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" != "arm64" ]]; then
    echo -e "${RED}install-r.sh only supports Apple Silicon (arm64). Detected: ${ARCH}${NC}"
    exit 1
fi

GLPK_PREFIX="$HOME/.local/glpk"

# R packages required by FantasyFootballAnalyticsR (see its README), plus
# languageserver for Neovim LSP support.
R_PACKAGES=(reshape MASS psych Rglpk XML data.table languageserver)

install_r() {
    if command -v R &>/dev/null; then
        echo -e "${GREEN}R is already installed ($(R --version | head -1))${NC}"
        return
    fi

    echo -e "${YELLOW}R not found. Downloading the official CRAN installer...${NC}"
    local latest tmp pkg_url
    latest=$(curl -s https://cran.r-project.org/bin/macosx/ | grep -oE 'sonoma-arm64/base/R-[0-9.]+-arm64\.pkg' | head -1)
    if [[ -z "$latest" ]]; then
        echo -e "${RED}Could not determine latest R version from CRAN. Install manually from https://cran.r-project.org/bin/macosx/${NC}"
        exit 1
    fi
    pkg_url="https://cran.r-project.org/bin/macosx/${latest}"
    tmp=$(mktemp -d)
    curl -sL -o "$tmp/R.pkg" "$pkg_url"

    echo -e "${YELLOW}Opening the R installer. Complete the install (requires your admin password), then press Enter here to continue.${NC}"
    open "$tmp/R.pkg"
    read -r -p "Press Enter once the R installer has finished... "

    if ! command -v R &>/dev/null; then
        echo -e "${RED}R still not found on PATH after install. Aborting.${NC}"
        exit 1
    fi
    echo -e "${GREEN}R installed ($(R --version | head -1))${NC}"
}

install_glpk() {
    if [[ -f "$GLPK_PREFIX/lib/libglpk.dylib" ]]; then
        echo -e "${GREEN}GLPK is already installed at ${GLPK_PREFIX}${NC}"
        return
    fi

    echo -e "${YELLOW}Building GLPK from source into ${GLPK_PREFIX} (needed if Rglpk has to compile from source; CRAN's binary Rglpk usually bundles its own)...${NC}"
    local tmp
    tmp=$(mktemp -d)
    curl -sL -o "$tmp/glpk.tar.gz" https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz
    tar xzf "$tmp/glpk.tar.gz" -C "$tmp"
    (
        cd "$tmp/glpk-5.0"
        ./configure --prefix="$GLPK_PREFIX" >/dev/null
        make -j"$(sysctl -n hw.ncpu)" >/dev/null
        make install >/dev/null
    )
    rm -rf "$tmp"
    echo -e "${GREEN}GLPK installed at ${GLPK_PREFIX}${NC}"
}

install_r_packages() {
    echo -e "${YELLOW}Installing R packages: ${R_PACKAGES[*]}${NC}"
    GLPK_PREFIX="$GLPK_PREFIX" Rscript -e '
        pkgs <- commandArgs(trailingOnly = TRUE)
        needed <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
        if (length(needed)) {
            glpk <- Sys.getenv("GLPK_PREFIX")
            install.packages(
                needed,
                repos = "https://cloud.r-project.org",
                configure.args = c(
                    Rglpk = sprintf(
                        "--with-glpk-include=%s/include --with-glpk-lib=%s/lib",
                        glpk, glpk
                    )
                )
            )
        }
    ' "${R_PACKAGES[@]}"

    local failed=()
    for pkg in "${R_PACKAGES[@]}"; do
        if ! Rscript -e "quit(status = as.integer(!requireNamespace('$pkg', quietly = TRUE)))"; then
            failed+=("$pkg")
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo -e "${RED}Failed to install: ${failed[*]}${NC}"
        exit 1
    fi
    echo -e "${GREEN}All R packages installed and load correctly${NC}"
}

install_r
install_glpk
install_r_packages

echo -e "${GREEN}R setup complete.${NC}"
