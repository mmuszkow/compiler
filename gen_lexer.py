from gen_regexp import DFA, NFA, RegExParser

CODE = '''/* autogenerated by lexer.py */
#ifndef __LEXER_H__
#define __LEXER_H__

#include <stdio.h>
#include <cstdlib>
#include <vector>
#include <string>
#include <sstream>

#include "StringsTable.h" /* strings table */

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

/* token type */
enum TokenType {
%s
};

/* single token */
struct Token {
    static StringsTable st;

    TokenType type;
    union {
        int integer;
        bool boolean;
        int strIndex;
    };
    int lineNo;

    Token() {}
    Token(TokenType _type, int line) : type(_type), lineNo(line), strIndex(0) {}
    Token(TokenType _type, int line, const std::string& text) : type(_type), lineNo(line), strIndex(st.add(text)) {}
    Token(TokenType _type, int line, bool trueFalse) : type(_type), lineNo(line), boolean(trueFalse) {}
    Token(TokenType _type, int line, int i) : type(_type), lineNo(line), integer(i) {}

    const std::string& strVal() const {
        return st.get(strIndex);
    }

    static const char* typeToString(TokenType type) {
        switch(type) {
%s
        }
    }
    
    const char* toString() const {
        return typeToString(type);
    }
};

StringsTable Token::st;

#define LEXER_ERR(msg, ...) fprintf(stderr, "[Lexer] at line %%d: " msg "\\n", curr_line_no, __VA_ARGS__)

/* lexer itself */
class Lexer {
protected:
    enum State {%s};
    std::string str;
    int   begin, end; /* internal: begin & end of the current match */
    int   curr_line_no; /* currently analyzed line, for error reporting */
    State lexer_state; /* lexer internal state */
    int   dfa_state; /* DFA automaton state for current lexer state */
    
    /* transition tables */
%s
public:
    std::vector<Token> tokens;
    Lexer() : begin(0), end(0), curr_line_no(1), dfa_state(0) { }
    
protected:
    void addToken(TokenType type) {
        tokens.push_back(Token(type, curr_line_no));
    }
    
    void addTokenWithMatch(TokenType type) {
        tokens.push_back(Token(type, curr_line_no, str.substr(begin, end-begin)));
    }
    
    void addStrConst(const std::string& str) {
        tokens.push_back(Token(STR_CONST, curr_line_no, str));
    }
   
    void addIntConst() {
        std::string intVal = str.substr(begin, end-begin);
        /* TODO: range check */
        int radix = 1;
        Token t(INT_CONST, curr_line_no);        
        for(int i=intVal.size()-1; i>=0; i--) {
            if(intVal[i] == '-')
                t.integer = -t.integer;
            else {
                t.integer += radix * (intVal[i]-'0');
                radix *= 10;
            }
        }
        tokens.push_back(t);
    }
    
    int move(char c) {
        switch(lexer_state) {
%s
            default: LEXER_ERR("invalid lexer state"); return -1;
        }
    }

    void changeState(State state) {
        lexer_state = state;
        dfa_state = 0;
    }

public:
    /* main lexing function */
    bool lex(const std::string& _str) {
        std::ostringstream str_const;
        str = _str;
        begin = 0;
        lexer_state = %s;
        dfa_state = 0;
        const uint8_t* final_state = NULL;
        while(begin < str.size()) {
            /* choose proper final transitions table */        
            switch(lexer_state) {
%s
                default: LEXER_ERR("invalid lexer state"); return false;
            }
            
            dfa_state = move(str[begin]);
            if(final_state[dfa_state]) {
                end = begin;
                int action = dfa_state;
                /* longest match */            
                while(final_state[dfa_state] && end < str.size()) {
                    end++;
                    action = dfa_state;
                    if(end == str.size()) { end++; break; }
                    dfa_state = move(str[end]);
                }
                
                switch(lexer_state) {
%s
                    default: LEXER_ERR("invalid lexer state"); return false;
                }
                begin = end;
                dfa_state = 0;
            } else
                begin++;
        }
        
        /* if we are not in the start state at the end, 
         * that means that we are still parsing some token 
         */
        if(dfa_state) {
            LEXER_ERR("syntax error");
            return false;
        }
        
        return true;
    }
};

/* translation tables */
%s
#endif'''

# token types
TYPES = ['UNK', 'IF', 'ELSE', 'EQ', 'NEQ', 'GTEQ', 'LTEQ', 'GT',\
    'LT', 'LAND', 'LOR', 'LNOT', 'ASSIGN', 'LPARENTH', 'RPARENTH',\
    'LBRACE', 'RBRACE', 'LBRACKET', 'RBRACKET', 'SCOLON',\
    'ADD', 'SUB', 'MUL', 'DIV', 'REMINDER', 'BOOL_CONST', 'INT_CONST',\
    'STR_CONST', 'ID', 'TYPE', 'WHILE', 'FOR', 'RETURN',\
    'CASE', 'SWITCH', 'DEFAULT', 'BREAK', 'CONTINUE', 'COMMA',\
    'DOT', 'INC', 'DEC', 'BNOT', 'BAND', 'BOR', 'SHL', 'SHR',\
    'BXOR', 'SEL', 'COLON', 'CLASS', 'DEF', 'CALL', 'THIS', 'ASM', 
    'NEW', 'CAST', 'IMPORT']

# lexer states, each state has the separate DFA
STATES = ['INITIAL', 'STRING', 'COMMENT']

# rules: (state, token_type, regex, action)
RULES = [
    ('INITIAL', 'if', 'addToken(IF);'),
    ('INITIAL', 'else', 'addToken(ELSE);'),  
    ('INITIAL', 'while', 'addToken(WHILE);'),
    ('INITIAL', 'for', 'addToken(FOR);'),
    ('INITIAL', 'return', 'addToken(RETURN);'),
    ('INITIAL', 'case', 'addToken(CASE);'),
    ('INITIAL', 'switch', 'addToken(SWITCH);'),
    ('INITIAL', 'default', 'addToken(DEFAULT);'),
    ('INITIAL', 'break', 'addToken(BREAK);'),
    ('INITIAL', 'continue', 'addToken(CONTINUE);'),
    ('INITIAL', 'class', 'addToken(CLASS);'),
    ('INITIAL', 'def', 'addToken(DEF);'),
    ('INITIAL', 'call', 'addToken(CALL);'),
    ('INITIAL', 'this', 'addToken(THIS);'),
    ('INITIAL', 'new', 'addToken(NEW);'),
    ('INITIAL', 'cast', 'addToken(CAST);'),
    ('INITIAL', 'import', 'addToken(IMPORT);'),
    ('INITIAL', 'asm', 'addToken(ASM);'),
    ('INITIAL', '<<', 'addToken(SHL);'),
    ('INITIAL', '>>', 'addToken(SHR);'),
    ('INITIAL', '->', 'addToken(SEL);'),
    ('INITIAL', '==', 'addToken(EQ);'),
    ('INITIAL', '!=', 'addToken(NEQ);'),
    ('INITIAL', '>=', 'addToken(GTEQ);'),
    ('INITIAL', '<=', 'addToken(LTEQ);'),
    ('INITIAL', '++', 'addToken(INC);'),
    ('INITIAL', '--', 'addToken(DEC);'),
    ('INITIAL', '>', 'addToken(GT);'),
    ('INITIAL', '<', 'addToken(LT);'),
    ('INITIAL', '&&', 'addToken(LAND);'),
    ('INITIAL', '\|\|', 'addToken(LOR);'),
    ('INITIAL', '!', 'addToken(LNOT);'),
    ('INITIAL', '=', 'addToken(ASSIGN);'),    
    ('INITIAL', '\(', 'addToken(LPARENTH);'),
    ('INITIAL', '\)', 'addToken(RPARENTH);'),
    ('INITIAL', '{', 'addToken(LBRACE);'),
    ('INITIAL', '}', 'addToken(RBRACE);'),
    ('INITIAL', '\[', 'addToken(LBRACKET);'),
    ('INITIAL', '\]', 'addToken(RBRACKET);'),
    ('INITIAL', ';', 'addToken(SCOLON);'),
    ('INITIAL', ':', 'addToken(COLON);'),
    ('INITIAL', ',', 'addToken(COMMA);'),
    ('INITIAL', '.', 'addToken(DOT);'),
    ('INITIAL', '+', 'addToken(ADD);'),
    ('INITIAL', '-', 'addToken(SUB);'),
    ('INITIAL', '\*', 'addToken(MUL);'),
    ('INITIAL', '/', 'addToken(DIV);'),
    ('INITIAL', '%', 'addToken(REMINDER);'),
    ('INITIAL', '~', 'addToken(BNOT);'),
    ('INITIAL', '&', 'addToken(BAND);'),
    ('INITIAL', '\|', 'addToken(BOR);'),
    ('INITIAL', '^', 'addToken(BXOR);'),
    ('INITIAL', 'true', 'Token t(BOOL_CONST, curr_line_no); t.boolean = true; tokens.push_back(t);'),
    ('INITIAL', 'false', 'Token t(BOOL_CONST, curr_line_no); t.boolean = false; tokens.push_back(t);'),
    ('INITIAL', '([0-9]([0-9])*)|(-[0-9]([0-9])*)', 'addIntConst();'),
    ('INITIAL', '[a-z]([a-z]|[0-9]|_)*', 'addTokenWithMatch(ID);'),
    ('INITIAL', '[A-Z]([a-z]|[A-Z]|[0-9])*', 'addTokenWithMatch(TYPE);'),
    ('INITIAL', '//([^\n])*', '/* comment */'),
    ('INITIAL', '/\*', 'changeState(COMMENT);'),
    ('INITIAL', '"', 'str_const.str(""); str_const.clear(); changeState(STRING);'),
    ('INITIAL', '\n', 'curr_line_no++;'),
    ('INITIAL', '( |\t)( |\t)*', '/* whitespace */'),
    ('INITIAL', '[^\n]', 'LEXER_ERR("unexpected character"); return false;'),
    
    ('STRING', '\\\\', 'str_const << \'\\\\\';'),
    ('STRING', '\\n', 'str_const << \'\\n\';'),
    ('STRING', '\\t', 'str_const << \'\\t\';'),
    ('STRING', '\\"', 'str_const << \'"\';'),
    ('STRING', '\n', 'LEXER_ERR("newline inside string"); return false;'),
    ('STRING', '"', 'addStrConst(str_const.str()); changeState(INITIAL);'),
    ('STRING', '[^"]', 'str_const << str[begin];'),    
        
    ('COMMENT', '\*/', 'changeState(INITIAL);'),
    ('COMMENT', '\n', 'curr_line_no++;'),
    ('COMMENT', '[^\n]', '/* comment */'),
]

def wordwrap(str, tabstr):
    ret = ''
    while(len(str) > 70):
        pos = str.find(',', 70)+1
        if(pos == -1): break
        ret += tabstr + str[0:pos] + '\n'
        str = str[pos:]
    ret += tabstr + str
    return ret
    
def tab(count = 1, spaces = 4):
    return ' ' * spaces * count

class TransitionsTable:
    def __init__(self, dfa):
        self.char_map = [c for c in range(0, 256)]
        self.actions = []
        self.table = [[] for c in range(0, 256)]        
        for state in dfa.states:
            for c in range(0, 256):
                t = state.transitions[c]
                self.table[c].append(dfa.states.index(t))
            self.actions.append(state.action)
        self.reverseIndexing()
    
    def reverseIndexing(self):
        newTable = [[] for x in range(0, len(self.table[0]))]
        for x in range(0, len(self.table[0])):
            for y in range(0, len(self.table)):
                newTable[x].append(self.table[y][x])
        self.table = newTable

    def minimize(self):
        charsBefore = len(set(self.char_map))
        statesBefore = len(self.table)
        iter = 0
        while True:
            # minimize cols (transitions, char_map)        
            self.reverseIndexing()
            mincols = []
            newCharMap = [c for c in range(0, 256)]
            for c in range(0, 256):
                if not self.table[self.char_map[c]] in mincols:
                    mincols.append(self.table[self.char_map[c]])
                newCharMap[c] = mincols.index(self.table[self.char_map[c]])
            self.table = mincols
            self.char_map = newCharMap
            
            # minimize rows
            self.reverseIndexing()
            minrows = []
            newActions = []            
            for row in range(0, len(self.table)):
                self.table[row].append(self.actions[row]) # add action for uniqueness
                if not self.table[row] in minrows:
                    minrows.append(self.table[row])
                    newActions.append(self.actions[row])
            
            # reindex
            newTable = []
            for row in minrows:
                newRow = []
                for i in range(0, len(row)-1):
                    newRow.append(minrows.index(self.table[row[i]]))
                newTable.append(newRow)
            
            self.table = newTable
            self.actions = newActions
            
            iter += 1
            charsAfter = len(set(self.char_map))
            statesAfter = len(self.table)
            if charsAfter == charsBefore and statesAfter == statesBefore:
                break
            charsBefore = charsAfter
            statesBefore = statesAfter

def generateTransitionsTables():
    # DFA states table
    tables = {}
    for lex_state in STATES:
        # create DFA
        nfa = NFA()
        for state, regex, action in RULES:
            if not state == lex_state: continue
            rule = RegExParser(regex).nfa
            rule.final.action = action
            nfa.start.addSucc(None, rule.start) # eps connection from start to every rule
        dfa = DFA(nfa)
        for state in dfa.states:
            if state.action: # choose rule with highest priority
                for (internal_state, _, rule) in RULES:
                    found = False
                    for action in state.action:
                        if internal_state == lex_state and action == rule:
                            state.action = rule
                            found = True
                            break
                    if found: break
            else:
                state.action = None
        
        table = TransitionsTable(dfa)
        table.minimize()
        tables[lex_state] = table
    return tables

def generate():
    tables = generateTransitionsTables()
    
    # token types
    token_types_code = ''
    for type in TYPES: token_types_code += '%s,' % type
    token_types_code = wordwrap(token_types_code[:-1], tab())
    
    # token to string function
    token_type2str_code = ''
    for type in TYPES:
        token_type2str_code += '%scase %s: return "%s";\n' % (tab(3), type, type)
    token_type2str_code += '%sdefault: return "UNK";' % tab(3)
    
    # all possible lexer states
    lexer_states_code = ''
    for state in STATES:
        lexer_states_code += '%s,' % state
    lexer_states_code = lexer_states_code[:-1]
    
    # transition tables declarations code
    ttables_decl_code = ''
    for state in STATES:
        ttables_decl_code += '%sstatic const uint8_t %s_CHAR_MAP[256];\n' % (tab(), state)
        ttables_decl_code += '%sstatic const uint8_t %s_FINAL[%d];\n' % (tab(), state, len(tables[state].actions))
        ttables_decl_code += '%sstatic const uint8_t %s_TRANSITIONS[%d][%d];\n' % (tab(), state, len(tables[state].table), len(tables[state].table[0]))
    
    # DFA move method cases
    move_code = ''
    for lex_state in STATES:
        move_code += '%scase %s: return %s_TRANSITIONS[dfa_state][%s_CHAR_MAP[c]];\n'\
                    % (tab(3), lex_state, lex_state, lex_state)
    move_code = move_code[:-1]
    
    # final table pointer assignment
    final_table_ass_code = ''
    for lex_state in STATES:
        final_table_ass_code += '%scase %s: final_state = %s_FINAL; break;\n'\
                                    % (tab(4), lex_state, lex_state)
    final_table_ass_code = final_table_ass_code[:-1]
    
    # state transitions actions
    actions_code = ''
    for lex_state in STATES:
        actions_code += '%scase %s:\n%sswitch(action) {\n' % (tab(5), lex_state, tab(6))
        id = 0        
        for action in tables[lex_state].actions:        
            if(action):
                actions_code += '%scase %d: { %s break; }\n' % (tab(7), id, action)
            id += 1
        actions_code += '%sdefault: LEXER_ERR("invalid DFA action"); return false;\n' % tab(7)
        actions_code += '%s}\n%sbreak;\n' % (tab(6), tab(6))
    
    tables_code = ''
    for state in STATES:
        table = tables[state]
        tables_code += 'const uint8_t Lexer::%s_CHAR_MAP[256] = {\n%s' % (state, tab())
        for c in table.char_map:
            tables_code += '%d,' % c
        tables_code = tables_code[:-1] + '\n};\n\n'
        tables_code += 'const uint8_t Lexer::%s_FINAL[%d] = {\n%s' % (state, len(table.actions), tab())
        for action in table.actions:
            if action: tables_code += '1,'
            else: tables_code += '0,'
        tables_code = tables_code[:-1] + '\n};\n\n'
        tables_code += 'const uint8_t Lexer::%s_TRANSITIONS[%d][%d] = {\n' % (state, len(table.table), len(table.table[0]))
        for row in table.table:
            tables_code += '%s{' % tab()
            for col in row:
                tables_code += '%d,' % col
            tables_code = tables_code[:-1] + '},\n'
        tables_code = tables_code[:-2] + '\n};\n\n'

    print(CODE) % (token_types_code, token_type2str_code, lexer_states_code, ttables_decl_code,\
                    move_code, STATES[0], final_table_ass_code, actions_code, tables_code)

if __name__ == '__main__':
    generate()