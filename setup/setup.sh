#!/usr/bin/env bash
#!/usr/bin/env bash
#
# ============================================================================
# setup_opencircuitdesign.sh
#
# Open-Source VLSI Environment Setup Script
#
# Author: James E. Stine, Jr.
# Edward Joullian Endowed Chair in Engineering
# Professor, Electrical and Computer Engineering
#
# Research Areas:
# Computer Architecture | VLSI Design | RISC-V Systems | Open-Source Silicon
#
# This script configures the environment for:
#   - Magic      (layout editor and extraction)
#   - Netgen     (LVS verification)
#   - ngspice    (circuit simulation)
#   - Xschem     (schematic capture)
#   - IRSIM      (switch-level simulation)
#   - open_pdks  (PDK installation and technology support)
#
# Default installation location:
#   $HOME/opencircuitdesign
#
# Supported PDK Example:
#   sky130A (via open_pdks)
#
# Intended for educational, research, and open-source VLSI development flows.
#
# ============================================================================

# -------------------------------------------------------------------
# Root of your OpenCircuitDesign install
# -------------------------------------------------------------------
export OPEN_CIRCUITDESIGN_ROOT="$HOME/opencircuitdesign"

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
# SKY130A PDK (from open_pdks)
# -------------------------------------------------------------------
if [ -n "$PDK_ROOT" ] && [ -d "$PDK_ROOT/sky130A" ]; then
    export PDK="sky130A"
    export SKY130A="$PDK_ROOT/sky130A"

    # Magic: use sky130A tech file / rc
    if [ -f "$SKY130A/libs.tech/magic/sky130A.magicrc" ]; then
        export MAGIC_MAGICRC="$SKY130A/libs.tech/magic/sky130A.magicrc"
    fi

    # Netgen: LVS setup
    if [ -f "$SKY130A/libs.tech/netgen/sky130A_setup.tcl" ]; then
        export NETGEN_SETUP="$SKY130A/libs.tech/netgen/sky130A_setup.tcl"
    fi

    # xschem: sky130 libraries + rc
    if [ -d "$SKY130A/libs.tech/xschem" ]; then
        # PDK-specific libs (on top of any system libs)
        if [ -z "$XSCHEM_LIBRARY_PATH" ]; then
            export XSCHEM_LIBRARY_PATH="$SKY130A/libs.tech/xschem"
        else
            export XSCHEM_LIBRARY_PATH="$SKY130A/libs.tech/xschem:$XSCHEM_LIBRARY_PATH"
        fi

        if [ -f "$SKY130A/libs.tech/xschem/xschemrc" ]; then
            export XSCHEM_RC="$SKY130A/libs.tech/xschem/xschemrc"
        fi
    fi
else
    if [ -n "$PDK_ROOT" ]; then
        echo "WARNING: $PDK_ROOT/sky130A not found – sky130A PDK not installed?"
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

[ -n "$MAGIC_MAGICRC" ]      && echo "  MAGIC_MAGICRC     = $MAGIC_MAGICRC"
[ -n "$NETGEN_SETUP" ]       && echo "  NETGEN_SETUP      = $NETGEN_SETUP"
[ -n "$XSCHEM_SYSTEM_LIBRARY_PATH" ] && echo "  XSCHEM_SYSTEM_LIBRARY_PATH = $XSCHEM_SYSTEM_LIBRARY_PATH"
[ -n "$XSCHEM_LIBRARY_PATH" ]        && echo "  XSCHEM_LIBRARY_PATH        = $XSCHEM_LIBRARY_PATH"
[ -n "$XSCHEM_RC" ]          && echo "  XSCHEM_RC         = $XSCHEM_RC"
