void(float status, string body) register_handler =
{
    if (http_is_ok(body))
    {
        string msg = http_getvs(body, "data");
        print(strcat("Register succeeded: ", msg));
    } else {
        string err = http_getvs(body, "data");
        print(strcat("Register failed: ", err));
    }
};

void(string username, string password) auth_register =
{
    string query = strcat("register?username=", username);
    query = strcat(query, "&password=");
    query = strcat(query, password);

    HttpGet(query, register_handler);
};

void(string username, string password, void(float status, string body) cb) auth_login =
{
    string query = strcat("login?username=", username);
    query = strcat(query, "&password=");
    query = strcat(query, password);

    HttpGet(query, cb);
};