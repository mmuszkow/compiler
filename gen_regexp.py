from random import randint

gid = 1
ALPHABET_S = 256 # alphabet in range (0..255)

epsClosureCache = {}

# NFA state
class NFAstate:
    def __init__(self):
        global gid
        self.id = gid; gid += 1
        self.action = None # used by lexer        
        self.transitions = {}

    # adds transition
    def addSucc(self, on, to):
        if not on in self.transitions:
            self.transitions[on] = []
        self.transitions[on].append(to)

    # list of states that can be reached using Epsilon (None) transitions
    def epsClosure(self):
        if self in epsClosureCache: return epsClosureCache[self]
        visited = []
        to_visit = [self]
        while len(to_visit) > 0:
            state = to_visit.pop()
            if None in state.transitions:
                for epsTransition in state.transitions[None]:
                    if not epsTransition in visited and not epsTransition in to_visit:
                        if epsTransition in epsClosureCache: visited.extend(epsClosureCache[epsTransition])
                        else: to_visit.append(epsTransition)
            visited.append(state)
        epsClosureCache[self] = visited
        return visited

# Nondeterministic Finite Automaton
class NFA:    
    def __init__(self, c = None): # None = Epsilon
        self.start = NFAstate()
        self.final = NFAstate()
        self.start.addSucc(c, self.final)

    # a|b
    def alternative(self, nfa):
        newStart = NFAstate(); newFinal = NFAstate()
        newStart.addSucc(None, self.start)
        newStart.addSucc(None, nfa.start)                
        self.final.addSucc(None, newFinal)
        nfa.final.addSucc(None, newFinal)
        self.start = newStart; self.final = newFinal
        return self

    # a.b (in short ab)
    def concat(self, nfa):
        self.final.addSucc(None, nfa.start)
        self.final = nfa.final
        return self

    # a*
    def kleene(self):
        newStart = NFAstate(); newFinal = NFAstate()
        newStart.addSucc(None, self.start)
        newStart.addSucc(None, newFinal)
        self.final.addSucc(None, newFinal)
        self.final.addSucc(None, newStart)
        self.start = newStart; self.final = newFinal
        return self

    # to SVG
    def svg(self):
        RADIUS = 30
        to_visit = [self.start]
        states = {self.start: (10*RADIUS, RADIUS, 'green')}
        transitions = []
        row = 2
        while(len(to_visit) > 0):
            nextRound = []
            while(len(to_visit) > 0):
                state = to_visit.pop()                
                for on in state.transitions:
                    for t in state.transitions[on]:
                        if t not in states:
                            if(t == self.final): color = 'gray'
                            else: color = 'white'
                            states[t] = (randint(1,20)*RADIUS, row*RADIUS, color)
                            nextRound.append(t)
                        transitions.append((state, t, on))
            to_visit = nextRound
            row += 2

        str = '<svg height="640" width="640">\n'
        for state in states:
            str += '<circle cx="%d" cy="%d" r="10" stroke="black" stroke-width="3" fill="%s" />\n' % states[state]
        for f, t, on in transitions:
            (x1, y1, _) = states[f]; (x2, y2, _) = states[t]
            str += '<line x1="%d" y1="%d" x2="%d" y2="%d" style="stroke:red; stroke-width:2" />\n' % (x1, y1, x2, y2)
            str += '<text x="%d" y="%d" fill="red" font-size="10px" font-family="sans-serif">%s</text>\n' % ((x1+x2)/2, (y1+y2)/2, on)
        return str + '</svg>'

# Regular expressions recurrent descent parser
#
# Grammar:
# Regex -> Term '|' Regex | Term
# Term -> Factor | eps
# Factor -> Base | Base '*'
# Base -> char | '\' char | '(' Regex ')' | '[' Range ']'
# Range -> char '-' char | '^' char | '^' '\' char
class RegExParser:
    def __init__(self, str):
        self.str = str
        self.pos = 0
        self.nfa = self._Regex()

    # checks if there is something more to read
    def _more(self):
        return self.pos < len(self.str)

    # gets currently processed
    def _peek(self):
        return self.str[self.pos]

    # checks if current char is the expected one (if specified)
    # then moves to next character
    def _accept(self, what = None):
        c = self._peek()
        if what and c != what:
            raise Exception('%c expected at position %d' % (what, self.pos))
        self.pos += 1
        return c

    # Regex -> Term '|' Regex | Term
    def _Regex(self):
        nfa = self._Term()
        if(self._more() and self._peek() == '|'):
            self._accept('|')
            return nfa.alternative(self._Regex())
        else:
            return nfa

    # Term -> Factor | eps
    def _Term(self):
        nfa = NFA()
        while(self._more() and self._peek() != ')' and self._peek() != '|'):
            nfa.concat(self._Factor())
        return nfa

    # Factor -> Base | Base '*'
    def _Factor(self):
        nfa = self._Base()
        while(self._more() and self._peek() == '*'):
            self._accept('*')
            nfa.kleene()
        return nfa

    # Base -> char | '\' char | '(' Regex ')' | '[' Range ']'
    def _Base(self):
        if(self._peek() == '('):
            self._accept('(')
            nfa = self._Regex()
            self._accept(')')
            return nfa
        elif(self._peek() == '['):
            self._accept('[')
            nfa = self._Range()
            self._accept(']')
            return nfa
        elif(self._peek() == '\\'):
            self._accept('\\')
            c = self._accept()
            if c == 'n': return NFA(ord('\n'))
            elif c == 't': return NFA(ord('\t'))
            else: return NFA(ord(c))
        else:
            c = self._accept()
            return NFA(ord(c))

    # Range -> char '-' char | '^' char
    def _Range(self):
        nfa = NFA()
        if(self._peek() == '^'): # [^x]
            self._accept('^')
            if(self._peek() == '\\'):
                self._accept('\\')
                c = self._accept()
                if c == 'n': cexcept = '\n'
                elif c == 't': cexcept = '\t'
                else: cexcept = c
            else:
                cexcept = self._accept()
            for c in range(0, 256):
                if c != ord(cexcept):
                    nfa.alternative(NFA(c))
        else: # [f-t]
            f = self._accept()
            self._accept('-')
            t = self._accept()
            if f >= t:
                raise Exception('Invalid range')
            for c in range(ord(f), ord(t)+1):
                nfa.alternative(NFA(c))
        return nfa

# DFA state
class DFAstate:
    def __init__(self, nfaStates):
        self.nfaStates = set(nfaStates)
        self.transitions = ALPHABET_S*[None]        
        self.unmarked = True
        self.final = False
        self.action = [] # used by lexer

    # adds transition, "to" is a DFA state too
    def add(self, on, to):
        if self.transitions[on] and self.transitions[on] != to:
            raise Exception('Ambigiousity in DFA')
        self.transitions[on] = to

    # returns set of NFA states that can be reached on "on"
    def move(self, on):
        ret = set()
        for nfaState in self.nfaStates:
            if on in nfaState.transitions:
                for t in nfaState.transitions[on]:
                    ret.add(t)
        return ret

# Deterministic Finite Automaton from NFA
class DFA:
    def __init__(self, nfa):             
        self.start = DFAstate(nfa.start.epsClosure())
        self.states = [self.start]

        while self._getUnmarked():
            t = self._getUnmarked()
            t.unmarked = False
            for c in range(0, ALPHABET_S): # in whole alphabet range
                s = self._add(DFAstate(self._epsClosure(t.move(c))))
                t.add(c, s)
        
        for dfaState in self.states:
            if nfa.final in dfaState.nfaStates:
                dfaState.final = True
            for nfaState in dfaState.nfaStates: # used by lexer
                if nfaState.action: dfaState.action.append(nfaState.action)

    # Epsilon closure for multiple NFA states
    def _epsClosure(self, nfaStates):
        ret = set()
        for state in nfaStates:
            ret.add(state)
            for epsC in state.epsClosure():
                ret.add(epsC)
        return ret
    
    # adds new or returns existing DFA state
    def _add(self, state):
        for dfaState in self.states:
            if(dfaState.nfaStates == state.nfaStates):
                return dfaState
        self.states.append(state)
        return state
    
    # return unmarked DFA state
    def _getUnmarked(self):
        for s in self.states:
            if s.unmarked: return s
        return None
    
    def match(self, str):
        state = self.start
        for c in str:
            state = state.transitions[ord(c)]
        return state.final
