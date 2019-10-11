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
# 8. Update the new released build script to below list dependencies

# Order matters, because dependency checks
dependencies = [
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl",
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.3/build_libcxxwrap-julia-1.0.v0.5.3.jl",
    "https://github.com/TeroFrondelius/tfelBuilder/releases/download/v0.3.0/build_tfel_binaries.v3.2.1-master.jl",
    "https://github.com/TeroFrondelius/mgisBuilder/releases/download/v0.2.0/build_mgis_binaries.v1.0.0-master.jl"
]
# # Note libcxxwrap version have to match with CxxWrap version in Project.toml
# Also libcxxwrap version need to be changed in https://github.com/TeroFrondelius/mgisBuilder/blob/master/build_tarballs.jl


for build_script in dependencies
    script_name = split(build_script,"/")[end]
    include(download(build_script,script_name))
end
