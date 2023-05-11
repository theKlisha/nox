use core::arch::global_asm;

#[no_mangle]
#[link_section = "._multiboot_header"]
pub static MULTIBOOT_HEADER: [u32; 6] = [
    0xE85250D6, // magic
    0x00000000, // flags
    0x00180000, // header length
    0x1795af2a, // checksum
    0x00000000, // end tag
    0x00000008, // end tag
];

global_asm!(include_str!("boot.s"));
