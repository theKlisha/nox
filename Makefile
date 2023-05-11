TARGET = x86_64-unknown-none
TARGET_DIR = ./target/${TARGET}

${TARGET_DIR}/debug/nox:
	cargo build

${TARGET_DIR}/release/nox:
	cargo build --release

${TARGET_DIR}/debug/nox.iso: ${TARGET_DIR}/debug/nox
	docker build -t nox-build-container .
	docker run -it -v $$(pwd):/pwd nox-build-container make __native-package-debug

${TARGET_DIR}/release/nox.iso: ${TARGET_DIR}/release/nox
	docker build -t nox-build-container .
	docker run -it -v $$(pwd):/pwd nox-build-container make __native-package-release

run-debug: ${TARGET_DIR}/debug/nox.iso
	qemu-system-x86_64 -cdrom ${TARGET_DIR}/debug/nox.iso -boot d -no-reboot

run-release: ${TARGET_DIR}/release/nox.iso
	qemu-system-x86_64 -cdrom ${TARGET_DIR}/release/nox.iso -boot d -no-reboot

verify-multiboot:
	docker run -it -v $$(pwd):/pwd nox-build-container make __native-verify-multiboot    

__native-package-release:
	mkdir -p ./target/iso/boot/grub
	cp ./grub.cfg ./target/iso/boot/grub/
	cp ${TARGET_DIR}/release/nox ./target/iso/boot/kernel.bin
	grub-mkrescue --verbose -o ${TARGET_DIR}/release/nox.iso ./target/iso

__native-package-debug:
	mkdir -p ./target/iso/boot/grub
	cp ./grub.cfg ./target/iso/boot/grub/
	cp ${TARGET_DIR}/debug/nox ./target/iso/boot/kernel.bin
	grub-mkrescue --verbose -o ${TARGET_DIR}/debug/nox.iso ./target/iso

__native-verify-multiboot:   
	$(shell grub-file --is-x86-multiboot ./target/x86_64-unknown-none/release/nox)
	@echo 'exit code for multiboot: $(.SHELLSTATUS)'
	$(shell grub-file --is-x86-multiboot2 ./target/x86_64-unknown-none/release/nox)
	@echo 'exit code for multiboot2: $(.SHELLSTATUS)'
	$(shell grub-file --is-x86-multiboot ./target/x86_64-unknown-none/debug/nox)
	@echo 'exit code for multiboot: $(.SHELLSTATUS)'
	$(shell grub-file --is-x86-multiboot2 ./target/x86_64-unknown-none/debug/nox)
	@echo 'exit code for multiboot2: $(.SHELLSTATUS)'
