<*
 The VM module holds code for working with virtual memory on supported platforms (currently Win32 and Posix)
*>
module std::core::mem::vm;
import std::io, libc;

<*
 VirtualMemory is an abstraction for working with an allocated virtual memory area. It will invoke vm:: functions
 but will perform more checks and track its size (required to unmap the memory on Posix)
*>
struct VirtualMemory
{
	void* ptr;
	usz size;
	VirtualMemoryAccess default_access;
}

faultdef RANGE_OVERFLOW, UNKNOWN_ERROR, ACCESS_DENIED, UNMAPPED_ACCESS, UNALIGNED_ADDRESS, RELEASE_FAILED, UPDATE_FAILED, INVALID_ARGS;

enum VirtualMemoryAccess
{
	PROTECTED,
	READ,
	WRITE,
	READWRITE,
	EXEC,
	EXECREAD,
	EXECWRITE,
	ANY
}

fn usz aligned_alloc_size(usz size)
{
	return size > 0 ? mem::aligned_offset(size, mem::os_pagesize()) : mem::os_pagesize();
}

<*
 Allocate virtual memory, size is rounded up to platform granularity (Win32) / page size (Posix).

 @param size : "The size of the memory to allocate, will be rounded up"
 @param access : "The initial access permissions."
 @return? mem::OUT_OF_MEMORY, RANGE_OVERFLOW, UNKNOWN_ERROR, ACCESS_DENIED, INVALID_ARGS
 @return "Pointer to the allocated memory, page aligned"
*>
fn void*? alloc(usz size, VirtualMemoryAccess access)
{
	unsupported("Virtual alloc only available on Win32 and Posix");
}

<*
 Release memory allocated with "alloc".

 @param [&inout] ptr : "Pointer to page to release, should be allocated using vm::alloc"
 @param size : "The size of the allocated pointer"
 @require mem::ptr_is_page_aligned(ptr) : "The pointer should be page aligned"
*>
fn void? release(void* ptr, usz size)
{
	unsupported("Virtual free only available on Win32 and Posix");
}

<*
 Change the access protection of a region in memory. The region must be page aligned.

 @param [&inout] ptr : "Pointer to page to update, must be page aligned"
 @param len : "To what len to update, must be page aligned"
 @param access : "The new access"
 @require mem::ptr_is_page_aligned(ptr) : "The pointer should be page aligned"
 @require mem::ptr_is_page_aligned(ptr + len) : "The length must be page aligned"
 @return? ACCESS_DENIED, UNALIGNED_ADDRESS, RANGE_OVERFLOW, UPDATE_FAILED, UNMAPPED_ACCESS, INVALID_ARGS
*>
fn void? protect(void* ptr, usz len, VirtualMemoryAccess access)
{
    unsupported("'virtual_protect' is only available on Win32 and Posix.");
}

<*
 Makes a region of memory available that was previously retrieved using 'alloc'. This is necessary on Win32,
 but optional on Posix.

 @param [&inout] ptr : "Pointer to page to update, must be page aligned"
 @param len : "To what len to commit, must be page aligned"
 @require mem::ptr_is_page_aligned(ptr) : "The pointer should be page aligned"
 @require mem::ptr_is_page_aligned(ptr + len) : "The length must be page aligned"
 @return? UNKNOWN_ERROR, mem::OUT_OF_MEMORY, ACCESS_DENIED, UNALIGNED_ADDRESS, RANGE_OVERFLOW, UPDATE_FAILED, UNMAPPED_ACCESS, INVALID_ARGS
*>
fn void? commit(void* ptr, usz len, VirtualMemoryAccess access = READWRITE)
{
    unsupported("'virtual_commit' is only available on Win32 and Posix.");
}

<*
 Notifies that the memory in the region can be released back to the OS. On Win32 this decommits the region,
 whereas on Posix it tells the system that it may be reused using madvise. The "block" parameter is only
 respected on Posix, and protects the region from read/write/exec. On Win32 this always happens.

 @param [&inout] ptr : "Pointer to page to update, must be page aligned"
 @param len : "To what len to commit, must be page aligned"
 @param block : "Set the released memory to protected"
 @require mem::ptr_is_page_aligned(ptr) : "The pointer should be page aligned"
 @require mem::ptr_is_page_aligned(ptr + len) : "The length must be page aligned"
 @return? ACCESS_DENIED, UNALIGNED_ADDRESS, RANGE_OVERFLOW, UPDATE_FAILED, UNMAPPED_ACCESS, INVALID_ARGS
*>
fn void? decommit(void* ptr, usz len, bool block = true)
{
    unsupported("'virtual_decommit' is only available on Win32 and Posix.");
}

<*
 Create a VirtualMemory using

 @param size : "The size of the memory to allocate."
 @require size > 0 : "The size must be non-zero"
 @return? mem::OUT_OF_MEMORY, RANGE_OVERFLOW, UNKNOWN_ERROR, ACCESS_DENIED, INVALID_ARGS
*>
fn VirtualMemory? virtual_alloc(usz size, VirtualMemoryAccess access = PROTECTED)
{
	size = aligned_alloc_size(size);
	void* ptr = alloc(size, access)!;
	return { ptr, size, access };
}

<*
 Commits memory, using vm::commit

 @param offset : "Starting from what offset to commit"
 @param len : "To what len to commit"
 @require mem::ptr_is_page_aligned(self.ptr + offset) : "The offset should be page aligned"
 @require mem::ptr_is_page_aligned(self.ptr + offset + len) : "The length must be page aligned"
 @require offset < self.size : "Offset out of range"
 @require offset + len <= self.size : "Length out of range"
 @return? UPDATE_FAILED, ACCESS_DENIED, UNALIGNED_ADDRESS, RANGE_OVERFLOW, UNKNOWN_ERROR
*>
macro void? VirtualMemory.commit(self, usz offset, usz len)
{
	return commit(self.ptr + offset, len, self.default_access);
}

<*
 Changes protection of a part of memory using vm::protect

 @param offset : "Starting from what offset to update"
 @param len : "To what len to update"
 @require mem::ptr_is_page_aligned(self.ptr + offset) : "The offset should be page aligned"
 @require mem::ptr_is_page_aligned(self.ptr + offset + len) : "The length must be page aligned"
 @require offset < self.size : "Offset out of range"
 @require offset + len < self.size : "Length out of range"
 @return? UPDATE_FAILED, ACCESS_DENIED, UNALIGNED_ADDRESS, RANGE_OVERFLOW, UNKNOWN_ERROR
*>
macro void? VirtualMemory.protect(self, usz offset, usz len, VirtualMemoryAccess access)
{
	return protect(self.ptr + offset, len, access);
}
<*
 Decommits a part of memory using vm::decommit

 @param offset : "Starting from what offset to decommit"
 @param len : "To what len to decommit"
 @param block : "Should the memory be blocked from access after decommit"
 @require mem::ptr_is_page_aligned(self.ptr + offset) : "The offset should be page aligned"
 @require mem::ptr_is_page_aligned(self.ptr + offset + len) : "The length must be page aligned"
 @require offset < self.size : "Offset out of range"
 @require offset + len < self.size : "Length out of range"
 @return? UPDATE_FAILED
*>
fn void? VirtualMemory.decommit(self, usz offset, usz len, bool block = true)
{
	return decommit(self.ptr + offset, len, block);
}

<*
 Releases the memory region

 @require self.ptr != null : "Virtual memory must be initialized to call destroy"
*>
fn void? VirtualMemory.destroy(&self)
{
	return release(self.ptr, self.size);
}