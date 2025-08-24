#define HTTP_OK 200
#define HTTP_ERR 500

string http_getv(string src, string key)
{
    string line;
    float i = 0;
    float keylen = strlen(key);
    
    while (i < strlen(src))
    {
        // get next line
        float j = i;
        line = "";
        while (j < strlen(src) && src[j] != '\n')
        {
            line = strcat(line, substring(src, j, 1));
            j += 1;
        }

        // does line start with key=
        if (strlen(line) > keylen + 1)
        {
            float match = 1;
            float m;
            for (m = 0; m < keylen; m++)
                if (line[m] != key[m])
                    match = 0;

            // found k=v match
            if (match && line[keylen] == '=')
                return substring(line, keylen + 1, strlen(line) - keylen - 1);
        }

        // go to the next line
        i = j + 1;
    }

    return "";
}

string http_getvs(string src, string key)
{
    return http_getv(src, key);
}

float http_getvf(string src, string key)
{
    string s = http_getv(src, key);
    if (s == "")
        return 0;
    return stof(s);
}


void(void(float status, string body) cb) get_version =
{
    HttpGet("v", cb);
};
