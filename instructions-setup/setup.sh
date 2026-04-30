#!/usr/bin/env bash
#
# setup_opencircuitdesign.sh
# Environment setup for Magic / Netgen / ngspice / xschem / irsim
# plus open_pdks under:  $HOME/ocd
#
# Default PDK selection:
#   1. gf180mcuD (preferred if installed)
#   2. sky130A   (fallback)
#

# -------------------------------------------------------------------
# Root of your OpenCircuitDesign install
# -------------------------------------------------------------------
export OPEN_CIRCUITDESIGN_ROOT="$HOME/ocd"

# Sanity check
if [ ! -d "$OPEN_CIRCUITDESIGN_ROOT" ]; then
    echo "ERROR: Directory $OPEN_CIRCUITDESIGN_ROOT does not exist."
    return 1 2>/dev/null || exit 1
fi

# -------------------------------------------------------------------
# PATH and library paths
# -------------------------------------------------------------------

# Binaries (magic, netgen, ngspice, xschem, irsim, etc.)
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/bin" ]; then
    export PATH="$OPEN_CIRCUITDESIGN_ROOT/bin:$PATH"
fi

# Shared libraries
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/lib" ]; then
    if [ -z "$LD_LIBRARY_PATH" ]; then
        export LD_LIBRARY_PATH="$OPEN_CIRCUITDESIGN_ROOT/lib"
    else
        export LD_LIBRARY_PATH="$OPEN_CIRCUITDESIGN_ROOT/lib:$LD_LIBRARY_PATH"
    fi
fi

# -------------------------------------------------------------------
# PDK_ROOT for open_pdks
# -------------------------------------------------------------------
# This is the standard install location for open_pdks when configured
# with --with-pdk_root=$OPEN_CIRCUITDESIGN_ROOT/share/pdk
#
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/share/pdk" ]; then
    export PDK_ROOT="$OPEN_CIRCUITDESIGN_ROOT/share/pdk"
else
    echo "WARNING: No PDK directory found under $OPEN_CIRCUITDESIGN_ROOT/share/pdk"
fi

# -------------------------------------------------------------------
# Tool-specific setup (generic)
# -------------------------------------------------------------------

# ngspice shared data
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/share/ngspice" ]; then
    export NGSPICE_SHARE_DIR="$OPEN_CIRCUITDESIGN_ROOT/share/ngspice"
fi

# xschem system libraries (generic symbols, etc.)
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/share/xschem" ]; then
    export XSCHEM_SYSTEM_LIBRARY_PATH="$OPEN_CIRCUITDESIGN_ROOT/share/xschem"
fi

# magic system libraries
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/share/magic" ]; then
    export MAGIC_HOME="$OPEN_CIRCUITDESIGN_ROOT/share/magic"
fi

# netgen system libraries
if [ -d "$OPEN_CIRCUITDESIGN_ROOT/share/netgen" ]; then
    export NETGEN_HOME="$OPEN_CIRCUITDESIGN_ROOT/share/netgen"
fi

# -------------------------------------------------------------------
# PDK selection: prefer gf180mcuD, fall back to sky130A
# -------------------------------------------------------------------
#
# Helper that wires up env vars for whichever PDK we picked.
# Args:
#   $1 = PDK name (e.g. gf180mcuD or sky130A)
#   $2 = PDK directory (e.g. $PDK_ROOT/gf180mcuD)
#
_ocd_setup_pdk() {
    local pdk_name="$1"
    local pdk_dir="$2"

    export PDK="$pdk_name"

    # Also export a name-specific variable, matching open_pdks/SKY130A convention
    # (e.g. SKY130A=..., GF180MCUD=...)
    local upname
    upname="$(echo "$pdk_name" | tr '[:lower:]' '[:upper:]')"
    export "$upname=$pdk_dir"

    # Magic: tech file / rc
    if [ -f "$pdk_dir/libs.tech/magic/${pdk_name}.magicrc" ]; then
        export MAGIC_MAGICRC="$pdk_dir/libs.tech/magic/${pdk_name}.magicrc"
    fi

    # Netgen: LVS setup
    if [ -f "$pdk_dir/libs.tech/netgen/${pdk_name}_setup.tcl" ]; then
        export NETGEN_SETUP="$pdk_dir/libs.tech/netgen/${pdk_name}_setup.tcl"
    fi

    # xschem: PDK-specific libraries + rc
    if [ -d "$pdk_dir/libs.tech/xschem" ]; then
        if [ -z "$XSCHEM_LIBRARY_PATH" ]; then
            export XSCHEM_LIBRARY_PATH="$pdk_dir/libs.tech/xschem"
        else
            export XSCHEM_LIBRARY_PATH="$pdk_dir/libs.tech/xschem:$XSCHEM_LIBRARY_PATH"
        fi

        if [ -f "$pdk_dir/libs.tech/xschem/xschemrc" ]; then
            export XSCHEM_RC="$pdk_dir/libs.tech/xschem/xschemrc"
        fi
    fi
}

if [ -n "$PDK_ROOT" ]; then
    if [ -d "$PDK_ROOT/gf180mcuD" ]; then
        _ocd_setup_pdk "gf180mcuD" "$PDK_ROOT/gf180mcuD"
    elif [ -d "$PDK_ROOT/sky130A" ]; then
        _ocd_setup_pdk "sky130A" "$PDK_ROOT/sky130A"
    else
        echo "WARNING: Neither $PDK_ROOT/gf180mcuD nor $PDK_ROOT/sky130A found"
        echo "         – no PDK selected. Did open_pdks finish installing?"
    fi
fi

# -------------------------------------------------------------------
# Convenience: show what we just did
# -------------------------------------------------------------------
echo "OpenCircuitDesign environment set:"
echo "  OPEN_CIRCUITDESIGN_ROOT = $OPEN_CIRCUITDESIGN_ROOT"
echo "  PATH                    = $OPEN_CIRCUITDESIGN_ROOT/bin:..."
echo "  LD_LIBRARY_PATH         = ${LD_LIBRARY_PATH:-<not set>}"
echo "  PDK_ROOT                = ${PDK_ROOT:-<not set>}"
echo "  PDK                     = ${PDK:-<not selected>}"

command -v magic   >/dev/null 2>&1 && echo "  magic   found:   $(command -v magic)"
command -v netgen  >/dev/null 2>&1 && echo "  netgen  found:   $(command -v netgen)"
command -v ngspice >/dev/null 2>&1 && echo "  ngspice found:   $(command -v ngspice)"
command -v xschem  >/dev/null 2>&1 && echo "  xschem  found:   $(command -v xschem)"

[ -n "$MAGIC_MAGICRC" ]              && echo "  MAGIC_MAGICRC              = $MAGIC_MAGICRC"
[ -n "$NETGEN_SETUP" ]               && echo "  NETGEN_SETUP               = $NETGEN_SETUP"
[ -n "$XSCHEM_SYSTEM_LIBRARY_PATH" ] && echo "  XSCHEM_SYSTEM_LIBRARY_PATH = $XSCHEM_SYSTEM_LIBRARY_PATH"
[ -n "$XSCHEM_LIBRARY_PATH" ]        && echo "  XSCHEM_LIBRARY_PATH        = $XSCHEM_LIBRARY_PATH"
[ -n "$XSCHEM_RC" ]                  && echo "  XSCHEM_RC                  = $XSCHEM_RC"
