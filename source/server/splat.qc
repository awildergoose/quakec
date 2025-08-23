void() SplatThink =
{
    if (self.damage_timer <= time)
    {
        remove(self);
        return;
    }

    // Apply simple physics
    if (!(self.flags & FL_ONGROUND)) 
    {
        // Random horizontal wiggle
        self.velocity_x += crandom() * 5;
        self.velocity_y += crandom() * 5;

        // Gravity pull
        self.velocity_z -= 400 * 0.03; // approximate gravity per think (~time step)

        // Clamp max upward speed
        if (self.velocity_z > 300)
            self.velocity_z = 300;

        // Slight horizontal damping for realism
        self.velocity_x *= 0.98;
        self.velocity_y *= 0.98;

#ifdef FTE
        FTE_RunParticleEffect(world, CSQC_PART_BLOODIMPACT, self.origin, 0, world);
#else
        particle(self.origin, self.velocity * 0.3, 73, 1);
#endif
    }
    else
    {
        // On the ground, stop vertical movement
        self.velocity_z = 0;
    }

    self.angles = vectoangles(self.velocity);
    self.nextthink = time + 0.03; // fast updates for smooth motion
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

    // Give splat a lifetime
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

    // Ensure minimum velocity so splats always move
    float speed = 300 + 200 * random(); // 300-500 units
    splat.velocity = dir * speed;
    splat.velocity_x += crandom() * 60;
    splat.velocity_y += crandom() * 60;
    splat.velocity_z += 180 * random() + 100; // guarantee upward motion

    splat.avelocity = '1000 1000 1000';
    splat.avelocity_x += (5000 * crandom());
    splat.avelocity_y += (1000 * crandom());
    splat.avelocity_z += (2000 * crandom());

    splat.touch = SplatTouch;

    // Initial life before physics touch
    splat.nextthink = time + 3;
    splat.think = SUB_Remove;

    setmodel(splat, "models/zom_gib.mdl");
    setsize(splat, '0 0 0', '0 0 0');
    setorigin(splat, org);
};
