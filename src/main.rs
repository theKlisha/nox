#![no_std]
#![no_main]

#[no_mangle]
#[link_section = ".multiboot_header"]
pub static MULTIBOOT_HEADER: [u32; 6] = [
    0xE85250D6, // magic
    0x00000000, // flags
    0x00180000, // header length
    0x1795af2a, // checksum
    0x00000000, // end tag
    0x00000008, // end tag
];

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let hello = b"Hello World!";
    let color_byte = 0x1f; 
    let mut hello_colored = [color_byte; 24];

    for (i, char_byte) in hello.into_iter().enumerate() {
        hello_colored[i * 2] = *char_byte;
    }

    let buffer_ptr = (0xb8000 + 1988) as *mut _;
    unsafe { *buffer_ptr = hello_colored };

    loop {}
}

#[panic_handler]
fn panic(__info: &core::panic::PanicInfo) -> ! {
    loop {}
}
