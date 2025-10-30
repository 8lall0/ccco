module libc::os;

tlocal int _errno_c3 = 0;
fn void errno_set(int err) => _errno_c3 = err;
fn int errno() => _errno_c3;
