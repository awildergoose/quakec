void(float reqid, float responsecode, string resourcebody, int resourcebytes) URI_Get_Callback =
{
    print("request id: ");
    print(ftos(reqid));
    print("\nstatus: ");
    print(ftos(responsecode));
    print("\ndata: ");
    print(resourcebody);
    print("\n");
};

float(string uril, float id, optional string postmimetype, optional string postdata) uri_get = #513;
void() TestHttpGet =
{
    uri_get("http://localhost:3000/?q=2&t=32&p=awesome", 1);
};
