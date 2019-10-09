using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["librsvg"], :librsvg),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Librsvg_jll.jl/releases/download/Librsvg-v2.42.2+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Librsvg.v2.42.2.aarch64-linux-gnu.tar.gz", "c59e8bf9ef3ff9e7f5c39c3c67ac7b64918481971bb93633bb0b52629c377c62"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Librsvg.v2.42.2.aarch64-linux-musl.tar.gz", "c0966693ad19919495da96dc5bcef68b626a5bad0d291cc399358e81ec46b776"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Librsvg.v2.42.2.arm-linux-gnueabihf.tar.gz", "c8c2f4266bd01327672baeb0926ccdd2f32dd26a7d89d340e815b8b68ff3db5a"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Librsvg.v2.42.2.arm-linux-musleabihf.tar.gz", "a56d300cdb30f5af695aa86e3919ef055561bfab7c2ef2801689c3557a4e40a2"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Librsvg.v2.42.2.i686-linux-gnu.tar.gz", "cae92fc9098dfe572555d7eb541204e5043aeb8fbfbace803daffcd7959f798d"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Librsvg.v2.42.2.i686-linux-musl.tar.gz", "5d1304b294399852470c2683e4ecd56977f7f9d9304ae7d19c4ffdec02403e60"),
    Windows(:i686) => ("$bin_prefix/Librsvg.v2.42.2.i686-w64-mingw32.tar.gz", "15cee35b116f30526c1f18260f645ef7a1f8b4c35ad8ea2b9b3e1d537659b3e1"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Librsvg.v2.42.2.powerpc64le-linux-gnu.tar.gz", "af61020f2fd5b0dc46aec22ec4cb76c81af2051a4fe7f35be60cf516fea5671b"),
    MacOS(:x86_64) => ("$bin_prefix/Librsvg.v2.42.2.x86_64-apple-darwin14.tar.gz", "34b54d5df4880bba46318130970eb57efec3aa39ae03fc99c45af1717b559dad"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Librsvg.v2.42.2.x86_64-linux-gnu.tar.gz", "851d040f04c7efd65c32b6a95974998005b698441d219880c51c89496581a62f"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Librsvg.v2.42.2.x86_64-linux-musl.tar.gz", "5a59feef0857031ba4f6c50e8e54c8b79f32502cc480dd79f6b627b67f1f2370"),
    FreeBSD(:x86_64) => ("$bin_prefix/Librsvg.v2.42.2.x86_64-unknown-freebsd11.1.tar.gz", "dcb217c30e0732cee46d796ca58e22e49ca8b87b1b0fd64b9ddbea5037273e7a"),
    Windows(:x86_64) => ("$bin_prefix/Librsvg.v2.42.2.x86_64-w64-mingw32.tar.gz", "0416369d88181931365ec67b169ba2dab6166a1944eb68dd09512b7f2516a79d"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
