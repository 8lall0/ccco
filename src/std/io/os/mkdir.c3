module std::io::os;
import std::io::path;


macro bool? native_mkdir(Path path, MkdirPermissions permissions)
{
	@pool()
	{
        return io::UNSUPPORTED_OPERATION?;
    };
}