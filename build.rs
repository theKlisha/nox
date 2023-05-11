use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

fn main() {
    let out_dir = &PathBuf::from(env::var_os("OUT_DIR").unwrap());

    let mut link_x = File::create(out_dir.join("link.x")).unwrap();
    link_x.write_all(include_bytes!("link.x")).unwrap();

    println!("cargo:rustc-link-search={}", out_dir.display());
    println!("cargo:rustc-link-arg=-Tlink.x");
    println!("cargo:rustc-link-arg=--nmagic");

    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=link.x");
}
