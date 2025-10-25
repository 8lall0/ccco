module std::io;

fn void printf(char *fmt, args...) {
    int ndx = 0;
    while (*fmt != '\0') {
        if (*fmt != '%') {
            putchar(*fmt);
            fmt++;
        } else {
            fmt++;
            switch (*fmt) {
                case '\0':
                    return;
                case 'd': {
                    fmt++;
                    // TODO print numbers greater than 9
                    putchar('0' + (char)(*(int*)args[ndx++]));
                }
            }
        }
    }
}