void() SplatThink =
{
    if (self.damage_timer <= time)
    {
        remove(self);
        return;
    }

    if (!(self.flags & FL_ONGROUND)) 
    {
        self.velocity_x += crandom() * 5;
        self.velocity_y += crandom() * 5;

        self.velocity_z -= 400 * 0.03;

        if (self.velocity_z > 300)
            self.velocity_z = 300;

        self.velocity_x *= 0.98;
        self.velocity_y *= 0.98;

#ifdef FTE
        FTE_RunParticleEffect(world, CSQC_PART_BLOODIMPACT, self.origin, 0, world);
#else
        particle(self.origin, self.velocity * 0.3, 73, 1);
#endif
    } else {
        self.velocity_z = 0;
    }

    self.angles = vectoangles(self.velocity);
    self.nextthink = time + 0.03;
};

void() SplatTouch =
{
    if (other != world)
    {
        remove(self);
        return;
    }

    self.velocity = '0 0 0';
    self.movetype = MOVETYPE_FLY;
    self.touch = SUB_Null;

    self.damage_timer = time + 10 + (5 * random());

    self.think = SplatThink;
    self.nextthink = time + 0.03;
};

void(vector dir, vector org, entity own) ThrowBloodSplat =
{
    if (!((own.flags & FL_MONSTER) || (own.classname == "player")))
        return;

    local entity splat = spawn();
    splat.owner = own;
    splat.movetype = MOVETYPE_TOSS;
    splat.solid = SOLID_BBOX;

    dir = normalize(dir);

    float speed = 300 + 200 * random();
    splat.velocity = dir * speed;
    splat.velocity_x += crandom() * 60;
    splat.velocity_y += crandom() * 60;
    splat.velocity_z += 180 * random() + 100;

    splat.avelocity = '1000 1000 1000';
    splat.avelocity_x += (5000 * crandom());
    splat.avelocity_y += (1000 * crandom());
    splat.avelocity_z += (2000 * crandom());

    splat.touch = SplatTouch;

    splat.nextthink = time + 3;
    splat.think = SUB_Remove;

    setmodel(splat, "models/zom_gib.mdl");
    setsize(splat, '0 0 0', '0 0 0');
    setorigin(splat, org);
};
