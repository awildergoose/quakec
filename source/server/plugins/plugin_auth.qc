/*
	server/plugins/plugin_auth.qc

	Auth plugin for Dedicated Servers.

	Copyright (C) 2021-2024 NZ:P Team

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
#ifdef FTE

void() PlayerSpawn;
void(entity plr) MarkPlayerAsLoggedIn =
{
    plr.logged_in = TRUE;

    if ((spawn_time > time || !rounds)) {
        self = plr;
        PlayerSpawn();
    }
}

void(float status, string body, entity plr) Register_Handler =
{
    if (http_is_ok(body)) {
        CSQC_SendChatMessageToPlayer(255, "Registered!", plr);
        MarkPlayerAsLoggedIn(plr);
    } else {
        CSQC_SendChatMessageToPlayer(255, sprintf("Error: %s", http_get_err(body)), plr);
    }
};

float(string params) ChatPlugin_Register =
{
    if (self.logged_in) {
        CSQC_SendChatMessageToPlayer(255, "You're already logged in!", self);
        return 1;
    }
    
    string query = sprintf("register?username=%s&password=%s", self.netname, params);
    HttpGetE(query, self, Register_Handler);

    return 0;
};

void(float status, string body, entity plr) Login_Handler =
{
    if (http_is_ok(body)) {
        CSQC_SendChatMessageToPlayer(255, "Logged in!", plr);
        MarkPlayerAsLoggedIn(plr);
    } else {
        CSQC_SendChatMessageToPlayer(255, sprintf("Error: %s", http_get_err(body)), plr);
    }
};

float(string params) ChatPlugin_Login =
{
    if (self.logged_in) {
        CSQC_SendChatMessageToPlayer(255, "You're already logged in!", self);
        return 1;
    }

    string query = sprintf("login?username=%s&password=%s", self.netname, params);
    HttpGetE(query, self, Login_Handler);

    return 0;
};

#endif // FTE