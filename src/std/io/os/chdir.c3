module std::io::os;
import std::io::path, std::os;

macro void? native_chdir(Path path)
{
	@pool()
	{
        return io::UNSUPPORTED_OPERATION?;
	};
}
