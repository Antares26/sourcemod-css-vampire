#include <sourcemod>
#include <sdktools>
#include <cstrike>

/**
 * Plugin public information.
 */
public Plugin myInfo = {
    name = "Antares Vampire",
    description = "Health interchange on damage dealt",
    author = "Antares",
    version = "0.1.4",
    url = "none.test"
};

ConVar g_vampire_ff_attacker = null;
ConVar g_vampire_ff_victim = null;

ConVar g_vampire_ef_attacker = null;
ConVar g_vampire_ef_victim = null;

ConVar g_vampire_bot_is_peasant = null;

public void OnPluginStart() {
    LoadTranslations("common.phrases.txt"); // Required for FindTarget fail reply
	
	HookEvent("player_hurt", Event_PlayerHurt);

	g_vampire_ff_attacker = CreateConVar(
		"sm_vampire_ff_attacker",
		"0.0",
		"How much health to give to the attacker as a factor of the damage dealt to a teammate",
		_,
		true,
		-2.0,
		true,
		2.0
	);
    g_vampire_ff_victim = CreateConVar(
		"sm_vampire_ff_victim",
		"0.0",
		"How much health to give to the victim as a factor of the damage dealt to a teammate",
		_,
		true,
		-2.0,
		true,
		2.0
	);

    g_vampire_ef_attacker = CreateConVar(
		"sm_vampire_ef_attacker",
		"0.0",
		"How much health to give to the attacker as a factor of the damage dealt to an enemy",
		_,
		true,
		-2.0,
		true,
		2.0
	);
    g_vampire_ef_victim = CreateConVar(
		"sm_vampire_ef_victim",
		"0.0",
		"How much health to give to the victim as a factor of the damage dealt to an enemy",
		_,
		true,
		-2.0,
		true,
		2.0
	);

    g_vampire_bot_is_peasant = CreateConVar(
		"sm_vampire_bot_is_peasant",
		"0",
		"Whether to treat bots as peasants (humans are not punished for friendly fire against them)",
		_,
		true,
		0.0,
		true,
		1.0
	);

	AutoExecConfig(true, "plugin.antares_vampire");
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
   int victim_id = event.GetInt("userid");
   int attacker_id = event.GetInt("attacker");
   int damage = event.GetInt("dmg_health");
 
   int victim = GetClientOfUserId(victim_id);
   int victim_team = GetClientTeam(victim);
   int victim_health = GetClientHealth(victim);
   bool is_victim_bot = IsFakeClient(victim);

   int attacker = GetClientOfUserId(attacker_id);
   int attacker_team = GetClientTeam(attacker);
   int attacker_health = GetClientHealth(attacker);
   bool is_attacker_bot = IsFakeClient(attacker);

   if (attacker_team == CS_TEAM_T || attacker_team == CS_TEAM_CT) {
		if (attacker_team == victim_team) {
			// Friendly Fire!
            if (g_vampire_ff_attacker.FloatValue != 0.00) {
                int new_attacker_health = attacker_health + RoundToFloor(damage * g_vampire_ff_attacker.FloatValue);

				// Don't punish human and don't reward bots if bots are peasants
				bool is_effect_cancelled = 
					g_vampire_bot_is_peasant.BoolValue && (
						(!is_attacker_bot && is_victim_bot && new_attacker_health < attacker_health) ||
						(is_attacker_bot && !is_victim_bot && new_attacker_health > attacker_health)
				);
				
				if (!is_effect_cancelled) {
					if (new_attacker_health <= 0) {
                    	ForcePlayerSuicide(attacker);
                	}
                	if (new_attacker_health < attacker_health) {
                    	SlapPlayer(attacker, 0, true);
                	}
                	SetEntityHealth(attacker, new_attacker_health);
				}
            }
            if (g_vampire_ff_victim.FloatValue != 0.00) {
                int new_victim_health = victim_health + RoundToFloor(damage * g_vampire_ff_victim.FloatValue);

				// Don't punish human and don't reward bots if bots are peasants
				bool is_effect_cancelled = 
					g_vampire_bot_is_peasant.BoolValue && (
						(!is_victim_bot && is_attacker_bot && new_victim_health < victim_health) ||
						(is_victim_bot && !is_attacker_bot && new_victim_health > victim_health)
				);
				
				if (!is_effect_cancelled) {
					if (new_victim_health <= 0) {
                    	ForcePlayerSuicide(victim);
                	}
                	if (new_victim_health < victim_health) {
                    	SlapPlayer(victim, 0, true);
                	}
                	SetEntityHealth(victim, new_victim_health);
				}
            }
		} else {
            // Enemy Fire
            if (g_vampire_ef_attacker.FloatValue != 0.00) {
                int new_attacker_health = attacker_health + RoundToFloor(damage * g_vampire_ef_attacker.FloatValue);

				// Don't punish human and don't reward bots if bots are peasants
				bool is_effect_cancelled = 
					g_vampire_bot_is_peasant.BoolValue && (
						(!is_attacker_bot && is_victim_bot && new_attacker_health < attacker_health) ||
						(is_attacker_bot && !is_victim_bot && new_attacker_health > attacker_health)
				);
				
				if (!is_effect_cancelled) {
					if (new_attacker_health <= 0) {
                    	ForcePlayerSuicide(attacker);
                	}
                	if (new_attacker_health < attacker_health) {
                    	SlapPlayer(attacker, 0, true);
                	}
                	SetEntityHealth(attacker, new_attacker_health);
				}
            }
            if (g_vampire_ef_victim.FloatValue != 0.00) {
                int new_victim_health = victim_health + RoundToFloor(damage * g_vampire_ef_victim.FloatValue);

				// Don't punish human and don't reward bots if bots are peasants
				bool is_effect_cancelled = 
					g_vampire_bot_is_peasant.BoolValue && (
						(!is_victim_bot && is_attacker_bot && new_victim_health < victim_health) ||
						(is_victim_bot && !is_attacker_bot && new_victim_health > victim_health)
				);
				
				if (!is_effect_cancelled) {
					if (new_victim_health <= 0) {
                    	ForcePlayerSuicide(victim);
                	}
                	if (new_victim_health < victim_health) {
                    	SlapPlayer(victim, 0, true);
                	}
                	SetEntityHealth(victim, new_victim_health);
				}
            }
        }
   }
}
