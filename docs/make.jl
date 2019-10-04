# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/LICENSE

using Pkg, Documenter, MFrontInterface, Literate, Dates

# automatically generate documentation from tests

"""
    add_datetime(content)

Add page generation time to the end of the content.
"""
function add_datetime(content)
    line =  "\n# Page generated at " * string(DateTime(now())) * "."
    content = content * line
    return content
end

"""
    remove_license(content)

Remove licence strings from source file.
"""
function remove_license(content)
    lines = split(content, '\n')
    function islicense(line)
        occursin("# This file is a part of JuliaFEM.", line) && return false
        occursin("# License is MIT:", line) && return false
        return true
    end
    content = join(filter(islicense, lines), '\n')
    return content
end

function generate_docs(pkg)

    function preprocess(content)
        content = add_datetime(content)
        content = remove_license(content)
    end

    pkg_dir = dirname(dirname(pathof(pkg)))
    testdir = joinpath(pkg_dir, "test")
    outdir = joinpath(pkg_dir, "docs", "src", "tests")
    test_pages = []
    for test_file in readdir(testdir)
        isdir(test_file) || continue
        startswith(test_file, "test_") || continue
        open(test_file) do file occursin("# #", read(file, String)) end || continue
        Literate.markdown(joinpath(testdir, test_file), outdir; documenter=true, preprocess=preprocess)
        generated_test_file = joinpath("tests", first(splitext(test_file)) * ".md")
        push!(test_pages, generated_test_file)
    end
    return test_pages

end

test_pages = generate_docs(MFrontInterface)

makedocs(modules=[MFrontInterface],
         format = Documenter.HTML(),
         checkdocs = :all,
         sitename = "MFrontInterface.jl",
         pages = [
                  "index.md",
                  "Examples" => test_pages
                 ]
        )
