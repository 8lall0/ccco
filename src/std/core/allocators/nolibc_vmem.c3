module std::core::mem::allocator;
import std::math,libc, std::bits;
import std::core::mem;
import std::core::env;



// Virtual Memory allocator

faultdef VMEM_RESERVE_FAILED;

struct Vmem (Allocator)
{
	VirtualMemory memory;
	usz allocated;
	usz pagesize;
	usz page_pot;
	usz last_page;
	usz high_water;
	VmemOptions options;
}

bitstruct VmemOptions : int
{
	<* Release memory on reset *>
	bool shrink_on_reset;
	<* Protect unused pages on reset *>
	bool protect_unused_pages;
	<* Overwrite released data with 0xAA *>
	bool scratch_released_data;
}

<*
 Implements the Allocator interface method.

 @require !reserve_page_size || math::is_power_of_2(reserve_page_size)
 @require reserve_page_size <= preferred_size : "The min reserve_page_size size must be less or equal to the preferred size"
 @require preferred_size >= 1 * mem::KB : "The preferred size must exceed 1 KB"
 @return? mem::INVALID_ALLOC_SIZE, mem::OUT_OF_MEMORY, VMEM_RESERVE_FAILED
*>
fn void? Vmem.init(&self, usz preferred_size, usz reserve_page_size = 0, VmemOptions options = { true, true, env::COMPILER_SAFE_MODE }, usz min_size = 0)
{
    return;
}

<*
 Implements the Allocator interface method.

 @require !alignment || math::is_power_of_2(alignment)
 @require alignment <= mem::MAX_MEMORY_ALIGNMENT : `alignment too big`
 @require size > 0
 @return? mem::INVALID_ALLOC_SIZE, mem::OUT_OF_MEMORY
*>
fn void*? Vmem.acquire(&self, usz size, AllocInitType init_type, usz alignment) @dynamic
{
	return null;
}

fn bool Vmem.owns_pointer(&self, void* ptr) @inline
{
	return false;
}
<*
 Implements the Allocator interface method.

 @require !alignment || math::is_power_of_2(alignment)
 @require alignment <= mem::MAX_MEMORY_ALIGNMENT : `alignment too big`
 @require old_pointer != null
 @require size > 0
 @return? mem::INVALID_ALLOC_SIZE, mem::OUT_OF_MEMORY
*>
fn void*? Vmem.resize(&self, void *old_pointer, usz size, usz alignment) @dynamic
{
	return null;
}

<*
 Implements the Allocator interface method.

 @require ptr != null
*>
fn void Vmem.release(&self, void* ptr, bool) @dynamic
{
    return;
}

fn usz Vmem.mark(&self)
{
	return self.allocated;
}

<*
 @require mark <= self.allocated : "Invalid mark"
*>
fn void Vmem.reset(&self, usz mark)
{
    return;
	//if (mark == self.allocated) return;
	//unprotect(self, mark);
}

fn void Vmem.free(&self)
{
    return;
	/*if (!self.memory.ptr) return;
	$switch:
		$case env::ADDRESS_SANITIZER:
			asan::poison_memory_region(self.memory.ptr, self.memory.size);
		$case env::COMPILER_SAFE_MODE:
    	    ((char*)self.memory.ptr)[0:self.allocated] = 0xAA;
	$endswitch
	(void)self.memory.destroy();
	*self = {};*/
}

// Internal data

struct VmemHeader @local
{
	usz size;
	char[*] data;
}

macro void? protect(Vmem* mem, usz after) @local
{
	usz shift = mem.page_pot;
	usz page_after = (after + mem.pagesize - 1) >> shift;
	usz last_page = mem.last_page;
	bool over_high_water = mem.high_water < after;
	if (page_after > last_page)
	{
		usz page_start = last_page << shift;
		usz page_len = (page_after - last_page) << shift;
		mem.memory.commit(page_start, page_len)!;
		if (mem.options.protect_unused_pages || over_high_water)
		{
			mem.memory.protect(page_start, page_len, READWRITE)!;
		}
		mem.last_page = page_after;
	}
	$if env::ADDRESS_SANITIZER:
		asan::unpoison_memory_region(mem.memory.ptr + mem.allocated, after - mem.allocated);
	$endif
	mem.allocated = after;
	if (over_high_water) mem.high_water = after;
}

macro void unprotect(Vmem* mem, usz after) @local
{
	usz shift = mem.page_pot;
	usz last_page = mem.last_page;
	usz page_after = mem.last_page = (after + mem.pagesize - 1) >> shift;
	$if env::ADDRESS_SANITIZER:
		asan::poison_memory_region(mem.memory.ptr + after, mem.allocated - after);
	$else
		if (mem.options.scratch_released_data)
		{
			mem::set(mem.memory.ptr + after, 0xAA, mem.allocated - after);
		}
	$endif
	if ((mem.options.shrink_on_reset || mem.options.protect_unused_pages) && page_after < last_page)
	{
		usz start = page_after << shift;
		usz len = (last_page - page_after) << shift;
		if (mem.options.shrink_on_reset) (void)mem.memory.decommit(start, len, false);
		if (mem.options.protect_unused_pages) (void)mem.memory.protect(start, len, PROTECTED);
	}
	mem.allocated = after;
}
