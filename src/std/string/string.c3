module std::string;

fn int strcmp(ichar *s1, ichar *s2) {
    while (*s1 && *s2) {
        if (*s1 != *s2) {
            break;
        }
        s1++;
        s2++;
    }

    return *(char *)s1 - *(char *)s2;
}