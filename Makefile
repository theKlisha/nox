TARGET = x86_64-unknown-none
TARGET_DIR = ./target/${TARGET}

DOCKER_BUILD = docker build --platform linux/amd64 --tag nox-build-container .
DOCKER_RUN = docker run -it -v $$(pwd):/pwd nox-build-container
QEMU_RUN = qemu-system-x86_64 -boot d -no-reboot -cdrom

${TARGET_DIR}/debug/nox:
	cargo build

${TARGET_DIR}/release/nox:
	cargo build --release

${TARGET_DIR}/debug/nox.iso: ${TARGET_DIR}/debug/nox Dockerfile
	${DOCKER_BUILD}
	${DOCKER_RUN} make __native-package-debug

${TARGET_DIR}/release/nox.iso: ${TARGET_DIR}/release/nox Dockerfile
	${DOCKER_BUILD}
	${DOCKER_RUN} make __native-package-release

run-debug: ${TARGET_DIR}/debug/nox.iso
	${QEMU_RUN} ${TARGET_DIR}/debug/nox.iso

run-release: ${TARGET_DIR}/release/nox.iso
	${QEMU_RUN} ${TARGET_DIR}/release/nox.iso

verify-multiboot:
	${DOCKER_RUN} make __native-verify-multiboot    

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
