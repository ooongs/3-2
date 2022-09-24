LETTER = 0
DIGIT = 1
UNKNOWN = 99
EOF = -1

INT_LIT = 10
IDENT = 11

ASSIGN_OP = 20
ADD_OP = 21
SUB_OP = 22
MUL_OP = 23
DIV_OP = 24
MOD_OP = 25

LEFT_PAREN = 25
RIGHT_PAREN = 26

IF_CODE = 15
ELSE_CODE = 16

ADD_ASSIGN = 30
SUB_ASSIGN = 31
MUL_ASSIGN = 32
DIV_ASSIGN = 33
REM_ASSIGN = 34

# EQL_OP = 30
# LSS_OP = 31
# GTR_OP = 32
# NOT_OP = 33
# NEQ_OP = 34
# LEQ_OP = 35
# GEQ_OP = 36

token = 0
nextToken = 0
lexLen = 0
charClass = 0
lexeme = ''
nextChar = ''

def lookup(ch):
    global nextToken
    if ch == '(':
        addChar()
        nextToken = LEFT_PAREN
    elif ch == ')':
        addChar()
        nextToken = RIGHT_PAREN
    elif ch == '+':
        addChar()
        nextToken = ADD_OP
    elif ch == '-':
        addChar()
        nextToken = SUB_OP
    elif ch == '*': 
        addChar()
        nextToken = MUL_OP
    elif ch == '/':
        addChar()
        nextToken = DIV_OP
    elif ch == '%':
        addChar()
        nextToken = MOD_OP
    elif ch == '=':
        addChar()
        nextToken = ASSIGN_OP
    else:
        addChar()
        nextToken = EOF
    return nextToken
    
def addChar():
    global lexLen
    global lexeme
    global nextChar
    lexeme += nextChar

def getChar():
    global cursor
    global charClass
    global nextChar
    if cursor < len(txt):
        nextChar = txt[cursor]
        cursor += 1
        if (nextChar >= 'a' and nextChar <= 'z') or (nextChar >= 'A' and nextChar <= 'Z'): 
            charClass = LETTER
        elif nextChar >= '0' and nextChar <= '9':
            charClass = DIGIT
        else:
            charClass = UNKNOWN
    else:
        charClass = EOF

def getNonBlack():
    global nextChar
    while nextChar == ' ':
        getChar()

def lex():
    global lexLen
    global charClass
    global nextToken
    global lexeme
    lexeme = ''
    getNonBlack()
    
    if charClass == LETTER:
        addChar()
        getChar()
        while charClass == LETTER or charClass == DIGIT:
            addChar()
            getChar()
        nextToken = IDENT
        # if lexeme == 'if':
        #     nextToken = IF_CODE
        # elif lexeme == 'else':
        #     nextToken == ELSE_CODE
        # else:
        #     nextToken = IDENT
    elif charClass == DIGIT:
        addChar()
        getChar()
        while charClass == DIGIT:
            addChar()
            getChar()
        nextToken = INT_LIT
    elif charClass == UNKNOWN:
        lookup(nextChar)
        getChar()
    else:
        nextToken = EOF
        lexeme = 'EOF'
    print(f"next Token is {nextToken}, next Lexeme is {lexeme}")
    return nextToken

def expr():
    global nextToken
    print("进入<表达式>")
    term()
    while nextToken == ADD_OP or nextToken == SUB_OP:
        lex()
        term()
    print("退出<表达式>")

def term():
    global nextToken
    print("进入<项>")
    factor()
    while nextToken == MUL_OP or nextToken == DIV_OP or nextToken == MOD_OP:
        lex()
        factor()
    print("退出<项>")
    
def factor():
    print("进入<因子>")
    if nextToken == IDENT or nextToken == INT_LIT:
        lex()
    else:
        if nextToken == LEFT_PAREN:
            lex()
            expr()
            if nextToken == RIGHT_PAREN:
                lex()
            else:
                err('no right paren')
        else:
            err('no left paren') 
    print("退出<因子>")

def assign():
    print("进入<赋值>")
    # lex()
    if nextToken == IDENT:
        lex()
        if nextToken == ASSIGN_OP:
            lex()
            expr()
        else:
            err('assign err')
    print("退出<赋值>")


def boolExpr():
    print("")
    print("")

def ifstmt():
    global nextToken
    if nextToken != IF_CODE:
        err()
    else:
        lex()
        if nextToken != LEFT_PAREN:
            err('no left paren')
        else:
            boolExpr()
            if nextToken != RIGHT_PAREN:
                err('no right paren')
            else:
                stmt()
                if nextToken == ELSE_CODE:
                    lex()
                    stmt()

def stmt():
    print("")
    print("")

def err(err):
    print(f"error: {err}")

txt = 'a = (abc - 47) / (c + total)'
cursor = 0
getChar()
lex()
# expr()
assign()

# getChar()
# while nextToken != EOF:
#    lex()
