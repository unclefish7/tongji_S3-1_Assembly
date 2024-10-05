#include <stdio.h>

int main()
{
	int a = 1;
	int ans = 0;

	while (a <= 100) {
		ans += a;
		a++;
	}

	printf("%d", ans);
	return 0;
}