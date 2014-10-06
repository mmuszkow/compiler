#ifndef __SEMANTIC_CHECK_H__
#define __SEMANTIC_CHECK_H__

#include <cstdarg>
#include <vector>
#include <map>

#include "Parser.h"

class FmtString : public std::string {
public:
    FmtString(const char* fmt, ...) {
        char buffer[1024];
        va_list args;
        va_start(args, fmt);
        vsprintf(buffer,fmt, args);
        va_end(args);
        this->assign(buffer);
    }
};

struct Var {
    std::string type;
    std::string name;
};

struct Method {
    std::string retType;
    std::string name;
    std::map<std::string, Var> params;
    std::map<std::string, Var> local_vars;

    int paramOffset(const std::string& name) const {
        return std::distance(params.begin(), params.find(name));
    }

    int localOffset(const std::string& name) const {
        return std::distance(local_vars.begin(), local_vars.find(name));
    }
};

struct Class {
    std::string name;
    std::string inherits;
    std::map<std::string, Var> attributes;
    std::map<std::string, Method> methods;

    int attribOffset(const std::string& name) const {
        return std::distance(attributes.begin(), attributes.find(name));
    }
};

#define SEMANTIC_ERR(msg, ...) fprintf(stderr, "[Semantic] at line %d: " msg "\n", curr().lineNo, __VA_ARGS__)

class SemanticCheck {
    friend class FirstPass;
    friend class SecondPass;
protected:
    std::map<std::string, Class> classes;
    std::pair<std::string, std::string> entryPoint;
public:
    const std::pair<std::string, std::string>& getEntryPoint() const {
        return entryPoint;
    }

    const std::map<std::string, Class>& getClasses() const {
        return classes;
    }

    int getClassTag(const std::string& name) const {
        return std::distance(classes.begin(), classes.find(name)) + 1;
    }

    bool isLocalVar(const std::string& clazz, const std::string& method, const std::string& id) const {
        const std::map<std::string, Var>& lv = classes.at(clazz).methods.at(method).local_vars;
        return lv.find(id) != lv.end();
    }

    bool isAttribute(const std::string& clazz, const std::string& id) const {
        const std::map<std::string, Var>& atts = classes.at(clazz).attributes;
        return atts.find(id) != atts.end();
    }

    bool isMethod(const std::string& clazz, const std::string& id) const {
        const std::map<std::string, Method>& methods = classes.at(clazz).methods;
        return methods.find(id) != methods.end();
    }

    bool isMethodArg(const std::string& clazz, const std::string& method, const std::string& id) const {
        const std::map<std::string, Var>& args = classes.at(clazz).methods.at(method).params;
        return args.find(id) != args.end();
    }

    const std::string& getType(const std::string& clazz, const std::string& method, const std::string& id) const {
        if(isMethodArg(clazz, method, id))
            return classes.at(clazz).methods.at(method).params.at(id).type;
        else if(isLocalVar(clazz, method, id))
            return classes.at(clazz).methods.at(method).local_vars.at(id).type;
        else
            return classes.at(clazz).attributes.at(id).type;
    }

    const Method& getMethod(const std::string& clazz, const std::string& method) const {
        return classes.at(clazz).methods.at(method);
    }

    const Class& getClass(const std::string& clazz) const {
        return classes.at(clazz);
    }

    bool isClassDefined(const std::string& clazz) const {
        return classes.find(clazz) != classes.end();
    }

    bool parse(const std::string& str);
};

class FirstPass : public Parser {
    SemanticCheck& sc;
public:
    FirstPass(SemanticCheck& _sc) : sc(_sc) {}
protected:

     /* class attributes and methods */
    bool p_program() {
        while(peek(CLASS)) {
            accept(CLASS);
            className = curr().strVal();
            if(sc.isClassDefined(className)) {
                SEMANTIC_ERR("class %s is already defined", className.c_str());
                return false;
            }
            Class& c = sc.classes[className];
            c.name = className;
            accept(TYPE);
            if(peek(COLON)) {
                accept(COLON);
                c.inherits = curr().strVal();
                if(sc.isClassDefined(c.inherits)) {
                    SEMANTIC_ERR("%s cannot inherit from %s because it was not defined", c.name.c_str(), c.inherits.c_str());
                    return false;
                }
                accept(TYPE);
            }
            accept(LBRACE);
            while(peek(TYPE)) {
                if(!p_attrib_decl())
                    return false;
            }
            while(peek(DEF)) {
                accept(DEF);
                Method m;
                m.retType = curr().strVal();
                accept(TYPE);
                methodName = curr().strVal();
                if(c.methods.find(m.name) != c.methods.end()) {
                    SEMANTIC_ERR("method %s is already defined", m.name.c_str());
                    return false;
                }
                m.name = methodName;
                if(m.name == "main" && sc.entryPoint.second == "")
                    sc.entryPoint = std::make_pair(c.name, m.name);
                accept(ID);
                accept(LPARENTH);
                if(peek(TYPE)) {
                    Var param;
                    param.type = curr().strVal();
                    accept(TYPE);
                    param.name = curr().strVal();
                    if(m.params.find(param.name) != m.params.end()) {
                        SEMANTIC_ERR("param %s is already defined", param.name.c_str());
                        return false;
                    }
                    m.params[param.name] = param;
                    accept(ID);
                    while(peek(COMMA)) {
                        accept(COMMA);
                        param.type = curr().strVal();
                        accept(TYPE);
                        param.name = curr().strVal();
                        if(m.params.find(param.name) != m.params.end()) {
                            SEMANTIC_ERR("param %s is already defined", param.name.c_str());
                            return false;
                        }
                        m.params[param.name] = param;
                        accept(ID);
                    }
                }
                c.methods[m.name] = m;
                accept(RPARENTH);
                if(!p_block())
                    return false;
                methodName = "";
            }
            accept(RBRACE);
            className = "";
        }

        if(sc.entryPoint.second == "") {
            SEMANTIC_ERR("main method not defined");
            return false;
        }
            
        return true;
    }

    bool p_attrib_decl() {
        Class &c = sc.classes[className];
        Var v;
        v.type = curr().strVal();
        if(v.type == "Void") {
            SEMANTIC_ERR("attribute cannot have type Void");
            return false;
        }
        accept(TYPE);
        v.name = curr().strVal();
        if(c.attributes.find(v.name) != c.attributes.end()) {
            /* TODO check inherited too */
            SEMANTIC_ERR("attribute %s is already defined", v.name.c_str());
            return false;
        }
        accept(ID);
        c.attributes[v.name] = v;
        while(peek(COMMA)) {
            Var nextV;
            nextV.type = v.type;
            accept(COMMA);
            nextV.name = curr().strVal();
            if(c.attributes.find(nextV.name) != c.attributes.end()) {
                /* TODO check inherited too */
                SEMANTIC_ERR("attribute %s is already defined", nextV.name.c_str());
                return false;
            }
            accept(ID);
            c.attributes[nextV.name] = nextV;
        }
        accept(SCOLON);
        return true;
    }

    bool p_var_decl() {
        Var v;
        v.type = curr().strVal();
        accept(TYPE);
        v.name = curr().strVal();
        if(sc.isLocalVar(className, methodName, v.name)) {
            SEMANTIC_ERR("local variable %s is already defined", v.name.c_str());
            return false;
        }
        accept(ID);
        if(peek(ASSIGN))
            p_initialization();
        sc.classes[className].methods[methodName].local_vars[v.name] = v;
        while(peek(COMMA)) {
            Var nextV;
            nextV.type = v.type;
            accept(COMMA);
            nextV.name = curr().strVal();
            if(sc.isLocalVar(className, methodName, nextV.name)) {
                SEMANTIC_ERR("local variable %s is already defined", nextV.name.c_str());
                return false;
            }
            accept(ID);
            if(peek(ASSIGN))
                p_initialization();
            sc.classes[className].methods[methodName].local_vars[nextV.name] = nextV;
        }
        accept(SCOLON);
        return true;
    }
};


class SecondPass : public Parser {
    SemanticCheck& sc;
public:
    SecondPass(SemanticCheck& _sc) : sc(_sc) {}
protected:
    std::string type, id;

    bool deduceType() {
        if(type == className) {
            if(sc.isLocalVar(className, methodName, id) || sc.isMethodArg(className, methodName, id) || sc.isAttribute(className, id))
                type = sc.getType(className, methodName, id);
            else if(sc.isMethod(className, id))
                type = sc.getMethod(className, id).retType;
            else {
                SEMANTIC_ERR("%s is undefined", id.c_str());
                return false;
            }
        } else {
            if(sc.isAttribute(type, id))
                type = sc.getClass(type).attributes.at(id).type;
            else if(sc.isMethod(type, id))
                type = sc.getMethod(type, id).retType;
            else {
                SEMANTIC_ERR("%s is undefined", id.c_str());
                return false;
            }
        }
        return true;
    }

    bool p_ptr() {
        if(peek(ID)) {
            id = curr().strVal();
            type = className;
            accept(ID);
            while(peek(DOT)) {
                accept(DOT);
                if(!deduceType()) return false;
                id = curr().strVal();
                accept(ID);
            }
            return deduceType();
        }
        return Parser::p_ptr();
    }

    bool p_call() {
        accept(CALL);
        if(!p_ptr()) return false;
        std::string methodRetType = type;
        accept(LPARENTH);
        if((peek(COMMA) || peek(NEW) || peek(LNOT) || peek(BNOT) || peek(LPARENTH) || peek(THIS) || peek(CAST) || peek(INT_CONST) || peek(STR_CONST) || peek(BOOL_CONST) || peek(ID) || peek(CALL)) && !p_args()) return false;
        accept(RPARENTH);
        type = methodRetType;
        return true;
    }

    bool p_arithm_tail() {
        if(type != "Int") {
            SEMANTIC_ERR("arithmetic operations can be permormed only on Int type");
            return false;
        }
        p_arithm_op();
        p_rval();
        if(type != "Int") {
            SEMANTIC_ERR("arithmetic operations can be permormed only on Int type");
            return false;
        }
        return true;
    }

    bool p_logic_tail() {
        const std::string leftType = type;
        TokenType op = curr().type;
        p_logic_op();
        p_rval_tail();
        switch(op) {
        case LAND:
        case LOR:
            if(leftType != "Bool" || type != "Bool") {
                SEMANTIC_ERR("logical AND and OR operations can be permormed on Bool type");
                return false;
            }
            break;
        case EQ:
        case NEQ:
        case LT:
        case GT:
        case LTEQ:
        case GTEQ:
            if(leftType != type) {
                SEMANTIC_ERR("comparision operations can be permormed on on the same type, %s is different than %s", leftType.c_str(), type.c_str());
                return false;
            }
            type = "Bool";
            break;
        }
        return true;
    }
    
    bool p_factor() {
        if(peek(LNOT)) {
            accept(LNOT);
            p_rval();
            if(type != "Bool") {
                SEMANTIC_ERR("logical NOT operation can be permormed on Bool type");
                return false;
            }
            return true;
        }
        if(peek(BNOT)) {
            accept(BNOT);
            p_rval();
            if(type != "Bool") {
                SEMANTIC_ERR("arithmetic NOT operation can be permormed on Int type");
                return false;
            }
            return true;
        }
        return Parser::p_factor();
    }

    bool p_var_decl() {
        const std::string varType = curr().strVal();
        accept(TYPE);
        accept(ID);
        if(peek(ASSIGN)) {
            accept(ASSIGN);
            p_rval();
            if(varType != type) {
                SEMANTIC_ERR("wrong type, %s expected but %s found", varType.c_str(), type.c_str());
                return false;
            }
        }
        while(peek(COMMA)) {
            accept(COMMA);
            accept(ID);
            if(peek(ASSIGN)) {
                accept(ASSIGN);
                p_rval();
                if(varType != type) {
                    SEMANTIC_ERR("wrong type, %s expected but %s found", varType.c_str(), type.c_str());
                    return false;
                }
            }
        }
        accept(SCOLON);
        return true;
    }

    bool p_const() {
        if(peek(INT_CONST)) 
            type = "Int";
        else if(peek(STR_CONST))
            type = "String";
        else if(peek(BOOL_CONST))
            type = "Bool";
        return Parser::p_const();
    }

    bool p_alloc() {
        accept(NEW);
        type = curr().strVal();
        accept(TYPE);
        return true;
    }

    bool p_cast() {
        accept(CAST);
        accept(LT);
        std::string casted = curr().strVal();
        accept(TYPE);
        accept(GT);
        accept(LPARENTH);
        p_rval();
        accept(RPARENTH);
        type = casted;
        return true;
    }
};

bool SemanticCheck::parse(const std::string& str) {
    /* first check if the AST is correct, then check the semantics */
    return Parser().parse(str) && FirstPass(*this).parse(str) && SecondPass(*this).parse(str);
}

#endif
