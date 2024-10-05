// loop-c.cpp: 定义应用程序的入口点。
//

#include <stdio.h>

int main()
{
	char a = 'a';

	int i = 2;
	int j = 13;

	while (i) {
		j = 13;
		while (j) {
			printf("%c", a);
			a++;
			j--;
		}
		printf("\n");
		i--;
	}

	return 0;
}
