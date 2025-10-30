module std::io::os;
import std::os, std::io;

fn void? native_stat(Stat* stat, String path) @if(env::DARWIN || env::LINUX || env::ANDROID || env::BSD_FAMILY) => @pool()
{
    unreachable("Stat unimplemented");
    int res = 0;
	if (res != 0)
	{
		switch (libc::errno())
		{
			case errno::EBADF:
				return io::FILE_NOT_VALID?;
			case errno::EFAULT:
				unreachable("Invalid stat");
			case errno::EIO:
				return io::GENERAL_ERROR?;
			case errno::EACCES:
				return io::NO_PERMISSION?;
			case errno::ELOOP:
				return io::NO_PERMISSION?;
			case errno::ENAMETOOLONG:
				return io::NAME_TOO_LONG?;
			case errno::ENOENT:
				return io::FILE_NOT_FOUND?;
			case errno::ENOTDIR:
				return io::FILE_NOT_DIR?;
			case errno::EOVERFLOW:
				return io::GENERAL_ERROR?;
			default:
				return io::UNKNOWN_ERROR?;
		}
	}
}

fn usz? native_file_size(String path) @if(!env::WIN32 && !env::DARWIN)
{
	File f = file::open(path, "r")!;
	defer (void)f.close();
	return f.seek(0, Seek.END)!;
}

fn bool native_file_or_dir_exists(String path)
{
    unreachable("Not supported");
}

fn bool native_is_file(String path)
{
File? f = file::open(path, "r");
			defer (void)f.close();
			return @ok(f);
}

fn bool native_is_dir(String path)
{
	return native_file_or_dir_exists(path) && !native_is_file(path);
}


