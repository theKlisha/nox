docker-package:
	docker build -t nox-build-container .
	docker run -it -v $$(pwd):/pwd nox-build-container make package

package:
	cargo build --target nox-target.json --release
	mkdir -p ./target/iso/boot/grub
	cp ./grub.cfg ./target/iso/boot/grub/
	cp ./target/nox-target/release/nox ./target/iso/boot/kernel.bin
	grub-mkrescue --verbose -o ./target/nox.iso ./target/iso
