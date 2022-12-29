typedef struct {
	char len;
	char str[255];
} Pstring;


char pstrlen(Pstring* pstr);

Pstring* replaceChar(Pstring* pstr, char oldChar, char newChar);

Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j);

Pstring* swapCase(Pstring* pstr);

int pstrijcmp(Pstring* pstr1, Pstring* psrt2, char i, char j);

