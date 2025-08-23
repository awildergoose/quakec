void(float reqid, float responsecode, string resourcebody, int resourcebytes) URI_Get_Callback =
{
    entity e;

    for (e = world; (e = nextent(e)); )
    {
        if (e.http_reqid == reqid && e.classname == "http")
        {
            if (e.http_handler != __NULL__)
                e.http_handler(responsecode, resourcebody);
            remove(e);
            
            return;
        }
    }

    print("unhandled http response id ");
    print(ftos(reqid));
    print("\n");
};

float(string uril, float id, optional string postmimetype, optional string postdata) uri_get = #513;
void(string url, void(float status, string body) cb) HttpGet =
{
    entity e = spawn();
    e.classname = "http";
    e.http_handler = cb;

    uri_get(url, e.http_reqid);
};
