TARGET = x86_64-unknown-none

package-release:
	cargo build --target ${TARGET} --release
	docker build -t nox-build-container .
	docker run -it -v $$(pwd):/pwd nox-build-container make native-package-release

package-debug:
	cargo build --target ${TARGET}
	docker build -t nox-build-container .
	docker run -it -v $$(pwd):/pwd nox-build-container make native-package-debug

native-package-release:
	mkdir -p ./target/iso/boot/grub
	cp ./grub.cfg ./target/iso/boot/grub/
	cp ./target/${TARGET}/release/nox ./target/iso/boot/kernel.bin
	grub-mkrescue --verbose -o ./target/nox-release.iso ./target/iso

native-package-debug:
	mkdir -p ./target/iso/boot/grub
	cp ./grub.cfg ./target/iso/boot/grub/
	cp ./target/${TARGET}/debug/nox ./target/iso/boot/kernel.bin
	grub-mkrescue --verbose -o ./target/nox-debug.iso ./target/iso

verify-multiboot:
	cargo build --target ${TARGET}
	cargo build --target ${TARGET} --release
	docker run -it -v $$(pwd):/pwd nox-build-container make native-verify-multiboot    

native-verify-multiboot:   
	$(shell grub-file --is-x86-multiboot ./target/x86_64-unknown-none/release/nox)
	@echo 'exit code for multiboot: $(.SHELLSTATUS)'
	$(shell grub-file --is-x86-multiboot2 ./target/x86_64-unknown-none/release/nox)
	@echo 'exit code for multiboot2: $(.SHELLSTATUS)'
	$(shell grub-file --is-x86-multiboot ./target/x86_64-unknown-none/debug/nox)
	@echo 'exit code for multiboot: $(.SHELLSTATUS)'
	$(shell grub-file --is-x86-multiboot2 ./target/x86_64-unknown-none/debug/nox)
	@echo 'exit code for multiboot2: $(.SHELLSTATUS)'

# run: package
# 	qemu-system-x86_64 -cdrom ./target/nox.iso -boot d -no-reboot

