
from pathlib import Path 
import sys
sys.path.append("C:/vunit")
from vunit import VUnit

#ROOT
ROOT = Path(__file__).parent.parent
print(ROOT)
# Source path for DUT
DUT_PATH = ROOT / "svpwm_PL.srcs" / "sources_1" / "new"
print(DUT_PATH)
# Source path for TB
TEST_PATH = ROOT / "vunit_tests" / "test_benches"
print(TEST_PATH)

# create VUnit instance
VU = VUnit.from_argv(compile_builtins=False)
VU.enable_location_preprocessing()

# create design library and add source files
design_lib = VU.add_library("design_lib")
design_lib.add_source_files([DUT_PATH / "*.vhd"])

# create testbench library
testbench_lib = VU.add_library("testbench_lib")
testbench_lib.add_source_files([TEST_PATH / "*.vhd"])


