// Copyright (c) 2021-2025 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module libc;

import libc::os;
import std::core::mem;

// Constants need to be per os/arch
const int EXIT_FAILURE = 1;
const int EXIT_SUCCESS = 0;
const int RAND_MAX = 0x7fffffff;

alias WChar = Char32;

struct DivResult
{
	CInt quot;
	CInt rem;
}

struct LongDivResult
{
	CLong quot;
	CLong rem;
}

struct Fpos_t
{
	long __pos;
	Mbstate_t __state;
}

struct Mbstate_t
{
	int __count;
	union __value
	{
		uint __wch;
		char[4] __wcb;
	}
}

fn Errno errno()
{
	return (Errno)os::errno();
}

fn void errno_set(Errno e)
{
	os::errno_set((int)e);
}

typedef Errno = inline CInt;
alias TerminateFunction = fn void();
alias CompareFunction = fn int(void*, void*);
alias JmpBuf = uptr[$$JMP_BUF_SIZE];
alias Fd = CInt;
alias Fpos_t @if(env::WIN32) = long;
alias SignalFunction = fn void(CInt);

const CInt SIGHUP = 1;
const CInt SIGINT = 2;
const CInt SIGQUIT = 3;
const CInt SIGILL = 4;
const CInt SIGTRAP = 5;
const CInt SIGABRT = 6;
const CInt SIGBUS = BSD_FLAVOR_SIG ? 10 : 7; // Or Mips
const CInt SIGFPE = 8;
const CInt SIGKILL = 9;
const CInt SIGSEGV = 11;
const CInt SIGSYS = BSD_FLAVOR_SIG ? 12 : 31;
const CInt SIGPIPE = 13;
const CInt SIGALRM = 14;
const CInt SIGTERM = 15;
const CInt SIGURG = BSD_FLAVOR_SIG ? 16 : 23;
const CInt SIGSTOP = BSD_FLAVOR_SIG ? 17 : 19;
const CInt SIGTSTP = BSD_FLAVOR_SIG ? 18 : 20;
const CInt SIGCONT = BSD_FLAVOR_SIG ? 19 : 18;
const CInt SIGCHLD = BSD_FLAVOR_SIG ? 20 : 17;

const bool BSD_FLAVOR_SIG @local = env::DARWIN || env::BSD_FAMILY;

alias Time_t = $typefrom(env::WIN32 ? long.typeid : CLong.typeid);
alias Off_t = $typefrom(env::WIN32 ? int.typeid : usz.typeid);



fn void longjmp(JmpBuf* buffer, CInt value) @weak @cname("longjmp") @nostrip
{
	unreachable("longjmp unavailable");
}

fn CInt setjmp(JmpBuf* buffer) @weak @cname("setjmp") @nostrip
{
	unreachable("setjmp unavailable");
}

fn void* malloc(usz size) @weak @cname("malloc") @nostrip
{
	unreachable("malloc unavailable");
}
fn void* calloc(usz count, usz size) @weak @cname("calloc") @nostrip
{
	unreachable("calloc unavailable");
}
fn void* free(void*) @weak @cname("free")
{
	unreachable("free unavailable");
}

fn void* realloc(void* ptr, usz size) @weak @cname("realloc") @nostrip
{
	unreachable("realloc unavailable");
}

alias memcpy = mem::__memcpy;
alias memmove = mem::__memcpy;
alias memset = mem::__memset;

fn int fseek(CFile stream, SeekIndex offset, int whence) @weak @cname("fseek") @nostrip
{
	unreachable("'fseek' not available.");
}
fn CFile fopen(ZString filename, ZString mode) @weak @cname("fopen") @nostrip
{
	unreachable("'fopen' not available.");
}

fn CFile freopen(ZString filename, ZString mode, CFile stream) @weak @cname("fopen") @nostrip
{
	unreachable("'freopen' not available.");
}

fn usz fwrite(void* ptr, usz size, usz nmemb, CFile stream) @weak @cname("fwrite") @nostrip
{
	unreachable("'fwrite' not available.");
}

fn usz fread(void* ptr, usz size, usz nmemb, CFile stream) @weak @cname("fread") @nostrip
{
	unreachable("'fread' not available.");
}

fn CFile fclose(CFile) @weak @cname("fclose") @nostrip
{
	unreachable("'fclose' not available.");
}

fn int fflush(CFile stream) @weak @cname("fflush") @nostrip
{
	unreachable("'fflush' not available.");
}

fn int fputc(int c, CFile stream) @weak @cname("fputc") @nostrip
{
	unreachable("'fputc' not available.");
}

fn char* fgets(ZString str, int n, CFile stream) @weak @cname("fgets") @nostrip
{
	unreachable("'fgets' not available.");
}

fn int fgetc(CFile stream) @weak @cname("fgetc") @nostrip
{
	unreachable("'fgetc' not available.");
}

fn int feof(CFile stream) @weak @cname("feof") @nostrip
{
	unreachable("'feof' not available.");
}

fn int putc(int c, CFile stream) @weak @cname("putc") @nostrip
{
	unreachable("'putc' not available.");
}
fn int putchar(int c) @weak @cname("putchar") @nostrip
{
    return os::putchar(c);
}
fn int puts(ZString str) @weak @cname("puts") @nostrip
{
	unreachable("'puts' not available.");
}

alias CFile = void*;


const HAS_MALLOC_SIZE = env::LINUX || env::ANDROID || env::WIN32 || env::DARWIN;

// The following needs to be set per arch+os
// For now I have simply pulled the defaults from MacOS
const int SEEK_SET = 0;
const int SEEK_CUR = 1;
const int SEEK_END = 2;
const int _IOFBF = 0; // Fully buffered
const int _IOLBF = 1; // Line buffered
const int _IONBF = 2; // Unbuffered
const int BUFSIZ = 1024;
const int EOF = -1;
const int FOPEN_MAX = 20;
const int FILENAME_MAX = 1024;

macro bool libc_S_ISTYPE(value, mask) @builtin => (value & S_IFMT) == mask;
const S_IFMT   = 0o170000; // type of file mask
const S_IFIFO  = 0o010000; // named pipe (fifo)
const S_IFCHR  = 0o020000; // character special
const S_IFDIR  = 0o040000; // directory
const S_IFBLK  = 0o060000; // block special
const S_IFREG  = 0o100000; // regular
const S_IFLNK  = 0o120000; // symbolic link
const S_IFSOCK = 0o140000; // socket
const S_ISUID  = 0o004000; // Set user id on execution
const S_ISGID  = 0o002000; // Set group id on execution
const S_ISVTX  = 0o001000; // Save swapped text even after use
const S_IRUSR  = 0o000400; // Read permission, owner
const S_IWUSR  = 0o000200; // Write permission, owner
const S_IXUSR  = 0o000100; // Execute/search permission, owner

alias SeekIndex = CLong;

// vsprintf vprintf not supported

// time.h

struct Tm
{
	<* seconds after the minute [0-60] *>
	CInt	tm_sec;
	<* minutes after the hour [0-59] *>
	CInt	tm_min;
	<* hours since midnight [0-23] *>
	CInt	tm_hour;
	<* day of the month [1-31] *>
	CInt	tm_mday;
	<* months since January [0-11] *>
	CInt	tm_mon;
	<* years since 1900 *>
	CInt	tm_year;
	<* days since Sunday [0-6] *>
	CInt	tm_wday;
	<* days since January 1 [0-365] *>
	CInt	tm_yday;
	<* Daylight Savings Time flag *>
	CInt	tm_isdst;
	<* offset from UTC in seconds *>
	TimeOffset tm_gmtoff;
	<* timezone abbreviation *>
	char* tm_zone;
}

struct TimeSpec
{
	Time_t s;
	CLong ns;
}

alias Clock_t = CLong;
alias TimeOffset = CLong;

const int TIME_UTC = 1;

// This is a best-effort approximation, but the C standard does not enforce
// that this is a compile-time standard.
const CLOCKS_PER_SEC = 1000000;

module libc::errno;

const Errno OK                       = 0;
const Errno EPERM                    = 1; // Operation not permitted
const Errno ENOENT                   = 2; // No such file or directory
const Errno ESRCH                    = 3; // No such process
const Errno EINTR                    = 4; // Interrupted system call
const Errno EIO                      = 5; // I/O error
const Errno ENXIO                    = 6; // No such device or address
const Errno E2BIG                    = 7; // Argument list too long
const Errno ENOEXEC                  = 8; // Exec format error
const Errno EBADF                    = 9; // Bad file number
const Errno ECHILD                   = 10; // No child processes
const Errno EAGAIN = 11; // Try again
const Errno ENOMEM                   = 12; // Out of memory
const Errno EACCES                   = 13; // Permission denied
const Errno EFAULT                   = 14; // Bad address
const Errno ENOTBLK                  = 15; // Block device required, not on Win32
const Errno EBUSY                    = 16; // Device or resource busy
const Errno EEXIST                   = 17; // File exists
const Errno EXDEV                    = 18; // Cross-device link
const Errno ENODEV                   = 19; // No such device
const Errno ENOTDIR                  = 20; // Not a directory
const Errno EISDIR                   = 21; // Is a directory
const Errno EINVAL                   = 22; // Invalid argument
const Errno ENFILE                   = 23; // File table overflow
const Errno EMFILE                   = 24; // Too many open files
const Errno ENOTTY                   = 25; // Not a typewriter
const Errno ETXTBSY                  = 26; // Text file busy, not on Win32
const Errno EFBIG                    = 27; // File too large
const Errno ENOSPC                   = 28; // No space left on device
const Errno ESPIPE                   = 29; // Illegal seek
const Errno EROFS                    = 30; // Read-only file system
const Errno EMLINK                   = 31; // Too many links
const Errno EPIPE                    = 32; // Broken pipe
const Errno EDOM                     = 33; // Math argument out of domain of func
const Errno ERANGE                   = 34; // Math result not representable

const Errno EDEADLK                  = 35; // Resource deadlock would occur Linux (others?)
const Errno ENAMETOOLONG             = 36; // File name too long Linux (others?)
const Errno ENOTEMPTY                = 39; // Directory not empty
const Errno ELOOP                    = 40; // Too many symbolic links encountered
const Errno EWOULDBLOCK              = EAGAIN; // Operation would block
const Errno EOVERFLOW                = 75; // Value too large for defined data type
const Errno ENOTSOCK                 = 88; // Socket operation on non-socket
const Errno EOPNOTSUPP               = 95; // Operation not supported on transport endpoint
const Errno EADDRINUSE               = 98; // Address already in use
const Errno EADDRNOTAVAIL            = 99; // Cannot assign requested address
const Errno ENETDOWN                 = 100; // Network is down
const Errno ENETUNREACH              = 101; // Network is unreachable
const Errno ENETRESET                = 102; // Network dropped connection because of reset
const Errno ECONNRESET               = 104; // Connection reset by peer
const Errno EISCONN                  = 106; // Socket is already connected
const Errno ETIMEDOUT                = 110; // Connection timed out
const Errno ECONNREFUSED             = 111; // Connection refused
const Errno EALREADY                 = 114; // Operation already in progress
const Errno EINPROGRESS              = 115; // Operation now in progress
const Errno EDQUOT                   = 122; // Quota exceeded

