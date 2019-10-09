using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgraphite2"], :libgraphite2),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Graphite2_jll.jl/releases/download/Graphite2-v1.3.13+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Graphite2.v1.3.13.aarch64-linux-gnu.tar.gz", "acf585744bbc606ba332902e33cc46e4f35684c02b781eb118f2bcf9c22d5bd9"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Graphite2.v1.3.13.aarch64-linux-musl.tar.gz", "803391b274d1b158166f373f3230ca92a4d880503e5450577d7843e4b749de15"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Graphite2.v1.3.13.arm-linux-gnueabihf.tar.gz", "934978ae1792d401d6e862b7ffc58db69192bc01c0f9dc89d975573dd461d74a"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Graphite2.v1.3.13.arm-linux-musleabihf.tar.gz", "cb5c17dd0bfcdfdb73e9a313c104f06cf555244a5e045cf852a5461d3ce7c870"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Graphite2.v1.3.13.i686-linux-gnu.tar.gz", "7bc20a1e9d5273e1770fb76faf0e9c86161108d4d2f7f4a62797bbcfb6eda799"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Graphite2.v1.3.13.i686-linux-musl.tar.gz", "fadc98c4cbb9f1fe5005af34bcf8b4f058bfbeaeff13844f825025a89f1a284c"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Graphite2.v1.3.13.powerpc64le-linux-gnu.tar.gz", "3575fc2291a143ad588250e514e7e0831549346539167c972455f3712a0e3943"),
    MacOS(:x86_64) => ("$bin_prefix/Graphite2.v1.3.13.x86_64-apple-darwin14.tar.gz", "4b963c856705132e2da4a7ea2af209946dfb54bd041a19d2d258bb022603a4fd"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Graphite2.v1.3.13.x86_64-linux-gnu.tar.gz", "8ff8e87ce7aef15d41a50ed3ca0d9498c4357d2698dd7db26ae6d07bbcb734cb"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Graphite2.v1.3.13.x86_64-linux-musl.tar.gz", "5f14dad8a9431fe6ee4b3862e806c2b814d701476e57d49e6b880a84afa53a5e"),
    FreeBSD(:x86_64) => ("$bin_prefix/Graphite2.v1.3.13.x86_64-unknown-freebsd11.1.tar.gz", "c7953a9fe91f7a7ca4e8de964825878d6594d511cda884507acd9d3d482d22f5"),
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
