extern "C" int my_printf (const char* str, ...);

//const int MAX_LEN_BUFFER = 20;
//const int MAX_LEN_STR    = 47;

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

	my_printf ("otjbotjibithbsp%d------%c%dfjjjjjjjjjlllllllllllllllllllllllllllllllllllo__%b!\n%x---%o\n\n%s!!!1123456789--100%%", 1234567890, '@', 1111122323234232377, 255, 573, 573, "I'am Sasha)\nhhh"); 

	return 0;
}
