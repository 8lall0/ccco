module std::io;

typedef Uint8_t = char;
typedef Uint32_t = uint;
typedef SizeT = Uint32_t;

struct Sbiret
{
    long error;
    long value;
}

fn Sbiret sbi_call(int arg0, int arg1, int arg2, int arg3, int arg4,
              int arg5, int fid, int eid) {

    Sbiret output;
    long result;

    asm {
         mv $a0, arg0;
         mv $a1, arg1;
         mv $a2, arg2;
         mv $a3, arg3;
         mv $a4, arg4;
         mv $a5, arg5;
         mv $a6, fid;
         mv $a7, eid;

         ecall;

         sw $a0, [&result];
    }

    output.value = 1;
    output.error = result;

    return output;
}

fn void putchar(char ch) {
    sbi_call(ch, 0, 0, 0, 0, 0, 0, 1);
}