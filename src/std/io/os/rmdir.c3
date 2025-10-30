module std::io::os;
import std::io::path;

macro bool? native_rmdir(Path path)
{
	@pool()
	{
	    return io::UNSUPPORTED_OPERATION?;
	};
}
