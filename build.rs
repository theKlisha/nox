use std::{env, fs::File, io::Write, path::PathBuf};

fn main() {
    let target = env::var("TARGET").unwrap();

    let out_dir = &PathBuf::from(env::var_os("OUT_DIR").unwrap());

    let mut link_x = File::create(out_dir.join("link.x")).unwrap();
    link_x.write_all(include_bytes!("link.x")).unwrap();

    let (arch, abi) = match target.as_str() {
        "x86_64-unknown-none" => ("x86_64", "none"),
        _ => panic!("unsupported architecture"),
    };

    println!("cargo:rustc-cfg={}", arch);
    println!("cargo:rustc-cfg={}", abi);

    println!("cargo:rustc-link-search={}", out_dir.display());

    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=link.x");
}
