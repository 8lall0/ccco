module std::math::nolibc;

fn double _sqrtf(double value) @weak @cname("sqrtf") @nostrip
{
    return $$sqrt(value);
}

fn double _sqrt(double value) @weak @cname("sqrt") @nostrip
{
    return $$sqrt(value);
}