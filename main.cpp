extern "C" int my_printf (const char* str, ...);

const int MAX_LEN_BUFFER = 20;
const int MAX_LEN_STR    = 47;

extern "C" int main ()
{
	//my_printf ("Hello\n", 6, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

	// char str[MAX_LEN_STR] = "";

	// int index = 0;

	// for (; index < MAX_LEN_BUFFER; index++)
	// {
	// 	str[index] = 'a';
	// }

	// for (; index < 2 * MAX_LEN_BUFFER; index++)
	// {
	// 	str[index] = 'b';
	// }

	// str[index]     = 'c';
	// str[index + 1] = 'd';
	// str[index + 2] = 'e';
	// str[index + 3] = '\n';

	my_printf ("Pello--%c\n", '1', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);

	return 0;
}