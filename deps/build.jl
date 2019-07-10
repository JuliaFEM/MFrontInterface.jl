# To upgrade binaries
# 1. Udate the correct git uuid here for TFEL/MFront:
#    https://github.com/TeroFrondelius/tfelBuilder/blob/master/build_tarballs.jl#L11
# 2. Push the changes to the master TeroFrondelius/tfelBuilder
# 3. Make a new release here: https://github.com/TeroFrondelius/tfelBuilder/releases
# 4. Update the correct git uuid here for MGIS:
#    https://github.com/TeroFrondelius/mgisBuilder/blob/master/build_tarballs.jl#L11
# 5. Update the correct TFEL binaries link here (from previous release point):
#    https://github.com/TeroFrondelius/mgisBuilder/blob/master/build_tarballs.jl#L50
# 6. Push the changes to the master TeroFrondelius/mgisBuilder
# 7. Make a new release here: https://github.com/TeroFrondelius/mgisBuilder/releases
# 8. Update the new released build script to below download-command

download("https://github.com/TeroFrondelius/mgisBuilder/releases/download/v0.1.0/build_mgis_binaries.v1.0.0-master.jl", "build_mgis_binaries.jl")
include("build_mgis_binaries.jl")
