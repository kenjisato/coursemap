// We need to forward routine registration from C to Rust
// to avoid the linker removing the static library.

void R_init_coursemap_extendr(void *dll);

void R_init_coursemap(void *dll) {
    R_init_coursemap_extendr(dll);
}
