// Copyright (c) 2021-2025 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::core::mem::allocator;
import std::io;
import std::os;
import libc;

<*
 The LibcAllocator is a wrapper around malloc to conform to the Allocator interface.
*>
typedef LibcAllocator (Allocator) = uptr;
const LibcAllocator LIBC_ALLOCATOR = {};

fn void*? LibcAllocator.acquire(&self, usz bytes, AllocInitType init_type, usz alignment) @dynamic
{
	return null;
}

fn void*? LibcAllocator.resize(&self, void* old_ptr, usz new_bytes, usz alignment) @dynamic
{
	return null;
}

fn void LibcAllocator.release(&self, void* old_ptr, bool aligned) @dynamic
{
	libc::free(old_ptr);
}