extern "C" int my_printf (const char* str, ...);;

extern "C" int main ()
{
	my_printf ("Hello\n", 6, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

	return 0;
}