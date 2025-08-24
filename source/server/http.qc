// the slash is required!
#define SERVER_URL "http://localhost:3000/"

void(float reqid, float responsecode, string resourcebody, int resourcebytes) URI_Get_Callback =
{
    entity e;

    for (e = world; (e = nextent(e)); )
    {
        if (e.http_reqid == reqid && e.classname == "http")
        {
            if (e.http_handler != __NULL__)
                e.http_handler(responsecode, resourcebody);
            if (e.http_ent_handler != __NULL__)
                e.http_ent_handler(responsecode, resourcebody, e.http_passing_entity);
            remove(e);
            
            return;
        }
    }

    print("unhandled http response id ");
    print(ftos(reqid));
    print("\n");
};

string(string path) GetUrl = 
{
    return strcat(SERVER_URL, path);
};

float(string uril, float id, optional string postmimetype, optional string postdata) uri_get = #513;
void(string url, void(float status, string body) cb) HttpGetDirect =
{
    entity e = spawn();
    e.classname = "http";
    e.http_handler = cb;

    uri_get(url, e.http_reqid);
};
void(string url, void(float status, string body) cb) HttpGet =
{
    HttpGetDirect(GetUrl(url), cb);
};
void(string url, entity passing_entity, void(float status, string body, entity e) cb) HttpGetEDirect =
{
    entity e = spawn();
    e.classname = "http";
    e.http_ent_handler = cb;
    e.http_passing_entity = passing_entity;

    uri_get(url, e.http_reqid);
};
void(string url, entity passing_entity, void(float status, string body, entity e) cb) HttpGetE =
{
    HttpGetEDirect(GetUrl(url), passing_entity, cb);
};