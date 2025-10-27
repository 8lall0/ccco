module std::mem;

import std::types;

fn void *memset(void *buf, char c, types::Size_t n) {
    types::Uint8_t *p = (types::Uint8_t *) buf;
    while (n--) {
        *p++ = c;
    }
    return buf;
}

fn void *memcpy(void *dst, void *src, types::Size_t n) {
    types::Uint8_t *d = (types::Uint8_t *) dst;
    // This should be const
    types::Uint8_t *s = (types::Uint8_t *) src;
    while (n--) {
        *d++ = *s++;
    }
    return dst;
}