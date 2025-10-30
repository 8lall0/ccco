// Copyright (c) 2021-2023 Christoffer Lerno. All rights reserved.
// Use of this source code is governed by the MIT license
// a copy of which can be found in the LICENSE_STDLIB file.
module std::os::env;
import std::io::path, libc, std::os;


fn String? get_var(Allocator allocator, String name) => @pool()
{
    return "";
}

fn String? tget_var(String name)
{
	return "";
}

<*
 @param [in] name
 @param [in] value
 @require name.len > 0
*>
fn bool set_var(String name, String value, bool overwrite = true) => @pool()
{
    return false;
}

<*
Returns the current user's home directory.
*>
fn String? get_home_dir(Allocator allocator)
{
	String home;
    home = "HOME";
	return get_var(allocator, home);
}


<*
 Returns the current user's config directory.
*>
fn Path? get_config_dir(Allocator allocator) => @pool()
{
    String? config_path = tget_var("XDG_CONFIG_HOME");
    if (try config_path && config_path.len > 0) return path::new(allocator, config_path);
    String home_dir = tget_var("HOME")!;
    const DIR = ".config";

    return path::temp(home_dir).append(allocator, DIR);
}


<*
 @param [in] name
 @require name.len > 0
*>
fn bool clear_var(String name) => @pool()
{
    return false;
}

fn String? executable_path()
{
    return NOT_FOUND?;
}
