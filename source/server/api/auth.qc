void(float status, string body) register_handler =
{
    if (status == HTTP_OK)
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
