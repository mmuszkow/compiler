#ifndef __ST_TABLE_H__
#define __ST_TABLE_H__

#include <vector>
#include <string>

class StringsTable {
    std::vector<std::string> data;
public:
    StringsTable() { data.push_back(""); }

    const std::string& get(int index) const {
        return data[index];
    }

    int add(const std::string& str) {
        for(unsigned int i=0; i<data.size(); i++)
            if(data[i] == str) return i;
        data.push_back(str);
        return data.size()-1;
    }
};

#endif
