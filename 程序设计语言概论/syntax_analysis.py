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
REM_OP = 25

LEFT_PAREN = 25
RIGHT_PAREN = 26

ADD_ASSIGN = 30
SUB_ASSIGN = 31
MUL_ASSIGN = 32
DIV_ASSIGN = 33
REM_ASSIGN = 34

token = 0
nextToken = 0
lexLen = 0
charClass = 0
lexeme = ''
nextChar = ''

def lookup(ch):
    global nextToken
    if ch == '(':
        nextToken = LEFT_PAREN
    elif ch == ')':
        nextToken = RIGHT_PAREN
    elif ch == '+':
        nextToken = ADD_OP
    elif ch == '-':
        nextToken = SUB_OP
    elif ch == '*': 
        nextToken = MUL_OP
    elif ch == '/':
        nextToken = DIV_OP
    elif ch == '%':
        nextToken = REM_OP
    elif ch == '=':
        nextToken = ASSIGN_OP
    else:
        nextToken = EOF
    return nextToken
    
def lookup_assign(op):
    global nextToken
    if op == '+=':
        nextToken = ADD_ASSIGN
    elif op == '-=':
        nextToken = SUB_ASSIGN
    elif op == '*=':
        nextToken = MUL_ASSIGN
    elif op == '/=':
        nextToken = DIV_ASSIGN
    elif op == '%=':
        nextToken = DIV_ASSIGN


def addChar():
    global lexLen
    global lexeme
    global nextChar
    lexeme += nextChar

def getChar():
    global cursor
    global charClass
    global nextChar
    if cursor < len(stmt):
        nextChar = stmt[cursor]
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
    elif charClass == DIGIT:
        addChar()
        getChar()
        while charClass == DIGIT:
            addChar()
            getChar()
        nextToken = INT_LIT
    elif charClass == UNKNOWN:
        addChar()
        lookup(nextChar)
        getChar()
        if charClass == UNKNOWN and nextChar == '=':
            addChar()
            # print(nextToken)
            # print(nextChar)
            lookup_assign(lexeme)
            getChar()
            # print(nextToken)
            # print(nextChar)

    else:
        nextToken = EOF
        lexeme = 'EOF'
    print(f"next Token is {nextToken}, next Lexeme is {lexeme}")
    return nextToken

def expr():
    global nextToken
    print("进入<表达式>")
    [x,y] = tt.pos()
    x_gap = 80
    tt.write('<表达式>', font=("Arial", font_size))
    t = -x_gap
    tt.goto(x+t,y-y_gap)
    term()
    tt.goto(x,y)
    while nextToken == ADD_OP or nextToken == SUB_OP:
        t += x_gap
        tt.goto(x+t,y-y_gap)
        tt.write(lexeme, font=("Arial", font_size))
        tt.goto(x,y)
        lex()
        t += x_gap
        tt.goto(x+t,y-y_gap)
        term()
        tt.goto(x,y)
    print("退出<表达式>")

def term():
    global nextToken
    print("进入<项>")
    [x,y] = tt.pos()
    x_gap = 200
    tt.write('<项>', font=("Arial", font_size))
    t = -x_gap
    tt.goto(x+t,y-y_gap)
    factor()
    tt.goto(x,y)
    while nextToken == MUL_OP or nextToken == DIV_OP or nextToken == REM_OP:
        t += x_gap
        tt.goto(x+t,y-y_gap)
        tt.write(lexeme, font=("Arial", font_size))
        tt.goto(x,y)
        lex()
        t += x_gap
        tt.goto(x+t,y-y_gap)
        factor()
        tt.goto(x,y)
    
    print("退出<项>")
    
def factor():
    print("进入<因子>")
    [x,y] = tt.pos()
    x_gap = 100
    tt.write('<因子>', font=("Arial", font_size))
    if nextToken == IDENT or nextToken == INT_LIT:
        tt.goto(x,y-y_gap)
        tt.write(lexeme, font=("Arial", font_size))
        tt.goto(x,y)
        lex()
    else:
        if nextToken == LEFT_PAREN:
            tt.goto(x-x_gap,y-y_gap)
            tt.write(lexeme, font=("Arial", font_size))
            tt.goto(x,y)
            lex()
            tt.goto(x,y-y_gap)
            expr()
            tt.goto(x,y)
            if nextToken == RIGHT_PAREN:
                tt.goto(x+x_gap,y-y_gap)
                tt.write(lexeme, font=("Arial", font_size))
                tt.goto(x,y)
                lex()
            else:
                err("Token Isn't RIGHT_PAREN")
                lex()
        else:
            err("Token Isn't LEFT_PAREN")
            lex() 
    print("退出<因子>")

def assign():
    print("进入<赋值>")
    tt.write('<赋值>', font=("Arial", font_size))
    [x,y] = tt.pos()
    x_gap = 100
    tt.goto(x-x_gap,y-y_gap)
    tt.write(lexeme, font=("Arial", font_size))
    tt.goto(x,y)

    if nextToken == IDENT:
        lex()
        tt.goto(x,y-y_gap)
        tt.write(lexeme, font=("Arial", font_size))
        tt.goto(x,y)
        if nextToken == ASSIGN_OP or ADD_ASSIGN or SUB_ASSIGN or MUL_ASSIGN or DIV_ASSIGN or REM_ASSIGN:
            lex()
            tt.goto(x+x_gap,y-y_gap)
            expr()
            tt.goto(x,y)

        else:
            err("Token Isn't ASSIGN_OP")
            lex()
    else:
        err("Token Isn't IDENT")
        lex()
    print("退出<赋值>")

def err(err):
    print(f"error: {err}")

def tree_init():
    tt.setup(1500,1500)
    tt.speed(0)
    tt.penup()
    tt.goto(0,400)
    tt.pendown()
    tt.write(f'<语句>: {stmt}', font=("Arial", font_size))
    tt.goto(0,400-y_gap)

import turtle as tt
cursor = 0
font_size = 16
y_gap = 80
stmt = input("输入语句：")
stmt_type = input("输入语句类型编号：1 - factor / 2 - term / 3 - expr / 4 - assign\n")
# stmt = 'sum += (bb * cc + dd / ee + ff) % (gg + hh)'
# stmt_type = 4

getChar()
lex()
tree_init()
if stmt_type == '1':
    factor()
elif stmt_type == '2':
    term()
elif stmt_type == '3':
    expr()
else:
    assign()
tt.mainloop()