void myprint(char* msg, int len);

int choose(int a, int b)
{
    if(a >= b) {
        myprint("the 1st num is bigger\n", 13);
    }
    else {
        myprint("the 2nd num is bigger\n", 13);
    }
    return 0;
}
