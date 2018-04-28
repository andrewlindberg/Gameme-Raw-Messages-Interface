/**
 *  Raw Messages Interface
 */

#include <amxmodx>
#include <gameme>

enum callback_data {
	callback_data_id,
	callback_data_plugin,
	callback_data_function,
	callback_data_payload,
	callback_data_limit
};

new Array:QueryCallbackArray;

new gameMEStatsRankForward;
new gameMEStatsPublicCommandForward;
new gameMEStatsTop10Forward;
new gameMEStatsNextForward;
new iRet, g_gameme_message_prefix;

public  plugin_natives() {
	register_native("QueryGameMEStats", "native_query_gameme_stats", false);
	register_native("QueryGameMEStatsTop10", "native_query_gameme_stats", false);
	register_native("QueryGameMEStatsNext", "native_query_gameme_stats", false);
	register_native("QueryIntGameMEStats", 	"native_query_gameme_stats", false);
}

public plugin_init() {
	register_plugin("Gameme: Raw Msg API", "1.0", "mmcs.pro dev team");

	register_srvcmd("gameme_raw_message", "gameme_raw_message");

	QueryCallbackArray = ArrayCreate(callback_data);

	gameMEStatsRankForward = CreateMultiForward("onGameMEStatsRank", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_STRING, FP_ARRAY, FP_ARRAY, FP_STRING);
	gameMEStatsPublicCommandForward = CreateMultiForward("onGameMEStatsPublicCommand", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_STRING, FP_ARRAY, FP_ARRAY, FP_STRING);
	gameMEStatsTop10Forward = CreateMultiForward("onGameMEStatsTop10", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_ARRAY, FP_ARRAY, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING);
	gameMEStatsNextForward = CreateMultiForward("onGameMEStatsNext", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_ARRAY, FP_ARRAY, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING, FP_STRING);
}

public plugin_cfg() {
	g_gameme_message_prefix = get_cvar_pointer("gameme_message_prefix");
}

public native_query_gameme_stats(plugin, numParams) {
	if (plugin == 0 || numParams < 4) {
		log_to_file("gameme_error.log", "use native from unknown plugin");
		return;
	}

	new data[callback_data];

	new cb_type[256];
	get_string(1, cb_type, charsmax(cb_type));
	new cb_client = get_param(2);

	if (cb_client > 0 && (!is_user_connected(cb_client) || get_user_userid(cb_client) < 1)) {
		log_to_file("gameme_error.log", "say native unknown cb_client %N", cb_client);
		return;
	}

	new cb_func[256];
	get_string(3, cb_func, charsmax(cb_func));

	data[callback_data_function] = get_func_id(cb_func, plugin);
	if(data[callback_data_function] == -1) {
		log_to_file("gameme_error.log", "say native unknown function %s", cb_func);
		return;
	}

	data[callback_data_id] = get_query_id();
	data[callback_data_plugin] = plugin;
	data[callback_data_function] = get_func_id(cb_func, plugin);
	data[callback_data_payload] = get_param(4);
	data[callback_data_limit] = (numParams > 4) ? get_param(5) : 1;

	if (QueryCallbackArray != Invalid_Array) {
		ArrayPushArray(QueryCallbackArray, data);
	}

	if(cb_client > 0) {
		log_message("^"%N^" requested ^"%s^" (value ^"%i^")", cb_client, cb_type, data[callback_data_id]);
	} else {
		log_message("^"Server^" requested ^"%s^" (value ^"%i^")", cb_type, data[callback_data_id]);
	}
}

public gameme_raw_message() {
	new argument_count = read_argc();
	if(argument_count < 1) {
		server_print("Usage: gameme_raw_message <type><arraygameme retrieve internal gameME Stats data");
		return PLUGIN_HANDLED;
	}

	new type = read_argv_int(1);
	switch (type) {
		case RAW_MESSAGE_CALLBACK_PLAYER, RAW_MESSAGE_RANK, RAW_MESSAGE_PLACE, RAW_MESSAGE_KDEATH, RAW_MESSAGE_SESSION_DATA: {
			if (argument_count >= 43) {
				new query_id = read_argv_int(2);
				new userid = read_argv_int(3);
				new client = find_player("k", userid);
				if (client > 0) {
					new DataPack:pack = CreateDataPack();

					// total values
					WritePackCell(pack, read_argv_int(4)); 		// rank pos 0
					WritePackCell(pack, read_argv_int(5)); 		// players pos 9
					WritePackCell(pack, read_argv_int(6)); 		// skill pos 18
					WritePackCell(pack, read_argv_int(7)); 		// kills pos 27
					WritePackCell(pack, read_argv_int(8)); 		// deaths pos 36
					WritePackFloat(pack, read_argv_float(9)); 	// kpd pos 45
					WritePackCell(pack, read_argv_int(10)); 	// suicides pos 54
					WritePackCell(pack, read_argv_int(11)); 	// headshots pos 63
					WritePackFloat(pack, read_argv_float(12)); 	// hpk pos 72
					WritePackFloat(pack, read_argv_float(13)); 	// accuracy pos 81
					WritePackCell(pack, read_argv_int(14)); 	// connection_time pos 90
					WritePackCell(pack, read_argv_int(15)); 	// ??? not tested this value pos 99
					WritePackCell(pack, read_argv_int(16)); 	// ??? not tested this value pos 108
					WritePackCell(pack, read_argv_int(17)); 	// ??? not tested this value pos 117
					WritePackCell(pack, read_argv_int(18)); 	// ??? not tested this value pos 126

					// session values
					WritePackCell(pack, read_argv_int(19)); 	// session_pos_change pos 135
					WritePackCell(pack, read_argv_int(20)); 	// session_skill_change pos 144
					WritePackCell(pack, read_argv_int(21)); 	// session_kills pos 153
					WritePackCell(pack, read_argv_int(22)); 	// session_deaths pos 162
					WritePackFloat(pack, read_argv_float(23)); 	// session_kpd pos 171
					WritePackCell(pack, read_argv_int(24)); 	// session_suicides pos 180
					WritePackCell(pack, read_argv_int(25)); 	// session_headshots pos 183
					WritePackFloat(pack, read_argv_float(26)); 	// session_hpk pos 198
					WritePackFloat(pack, read_argv_float(27)); 	// session_accuracy pos 207
					WritePackCell(pack, read_argv_int(28)); 	// session_time pos 216
					WritePackCell(pack, read_argv_int(29)); 	// ??? not tested this value pos 225
					WritePackCell(pack, read_argv_int(30)); 	// ??? not tested this value pos 234
					WritePackCell(pack, read_argv_int(31)); 	// ??? not tested this value pos 243
					WritePackCell(pack, read_argv_int(32)); 	// ??? not tested this value pos 252
					WritePackString(pack, read_argv_string(33)); // session_fav_weapon pos 261

					// global values
					WritePackCell(pack, read_argv_int(34)); 	// global_rank pos 268
					WritePackCell(pack, read_argv_int(35)); 	// global_players pos 277
					WritePackCell(pack, read_argv_int(36)); 	// global_skill ??? not tested this value pos 289
					WritePackCell(pack, read_argv_int(37)); 	// global_kills pos 295
					WritePackCell(pack, read_argv_int(38)); 	// global_deaths pos 304
					WritePackFloat(pack, read_argv_float(39)); 	// global_kpd pos 313
					WritePackCell(pack, read_argv_int(40)); 	// global_headshots pos 322
					WritePackFloat(pack, read_argv_float(41)); 	// global_hpk pos 331

					WritePackString(pack, read_argv_string(42)); // player country; pos

					if (type == RAW_MESSAGE_CALLBACK_PLAYER) {
						if (query_id > 0) {
							new cb_array_index = find_callback(query_id);
							if (cb_array_index >= 0) {
								new data[callback_data];
								ArrayGetArray(QueryCallbackArray, cb_array_index, data, sizeof(data));

								callfunc_begin_i(data[callback_data_function], data[callback_data_plugin]);
								callfunc_push_int(RAW_MESSAGE_CALLBACK_PLAYER);
								callfunc_push_int(data[callback_data_payload]);
								callfunc_push_int(client);
								callfunc_push_intrf(_:pack);
								callfunc_end();

								if (data[callback_data_limit] == 1) {
									ArrayDeleteItem(QueryCallbackArray, cb_array_index);
								}
							}
						}
					} else {
						switch (type) {
							case RAW_MESSAGE_RANK: {
								ExecuteForward(gameMEStatsRankForward, iRet, RAW_MESSAGE_RANK, client, get_pcvar_string_ex(g_gameme_message_prefix), pack);
							}
							case RAW_MESSAGE_PLACE: {
								ExecuteForward(gameMEStatsPublicCommandForward, iRet, RAW_MESSAGE_PLACE, client, get_pcvar_string_ex(g_gameme_message_prefix), pack);
							}
							case RAW_MESSAGE_KDEATH: {
								ExecuteForward(gameMEStatsPublicCommandForward, iRet, RAW_MESSAGE_KDEATH, client, get_pcvar_string_ex(g_gameme_message_prefix), pack);
							}
							case RAW_MESSAGE_SESSION_DATA: {
								ExecuteForward(gameMEStatsPublicCommandForward, iRet, RAW_MESSAGE_SESSION_DATA, client, get_pcvar_string_ex(g_gameme_message_prefix), pack);
							}
						}
					}
				}
			}
		}
		case RAW_MESSAGE_CALLBACK_TOP10, RAW_MESSAGE_TOP10: {
			if (argument_count >= 4) {
				new query_id = read_argv_int(2);
				new userid = read_argv_int(3);
				if (((userid > 0) && (type == RAW_MESSAGE_TOP10)) ||
				((userid == -1) && (type == RAW_MESSAGE_CALLBACK_TOP10))) {
					new client = find_player("k", userid);
   					if ((client < 1) && (type == RAW_MESSAGE_TOP10)) {
						return PLUGIN_HANDLED;
   					}

					new DataPack:pack = CreateDataPack();
					if (argument_count == 4) {
						WritePackCell(pack, -1); // total_players
					} else {
						new count = 0;
						for (new i = 4; (i <= argument_count); i++) {
							if (((i + 3) <= argument_count)) {
								count++;
								i = i + 3;
							}
						}
						WritePackCell(pack, count); // total_players

						new rank, name[64];
						for (new i = 4; (i <= argument_count); i++) {
							if (((i + 3) <= argument_count)) {
								rank++;

								WritePackCell(pack, rank); // rank
								WritePackCell(pack, read_argv_int(i)); // skill

								read_argv((i + 1), name, charsmax(name));
								WritePackString(pack, name);
								WritePackFloat(pack, read_argv_float((i + 2))); // kpd
								WritePackFloat(pack, read_argv_float((i + 3))); // hpk

								i = i + 3;
							}
						}
					}

					if (type == RAW_MESSAGE_CALLBACK_TOP10) {
						if (query_id > 0) {
							new cb_array_index = find_callback(query_id);
							if (cb_array_index >= 0) {
								new data[callback_data];
								ArrayGetArray(QueryCallbackArray, cb_array_index, data, sizeof(data));

								callfunc_begin_i(data[callback_data_function], data[callback_data_plugin]);
								callfunc_push_int(RAW_MESSAGE_CALLBACK_TOP10);
								callfunc_push_int(data[callback_data_payload]);
								callfunc_push_intrf(_:pack);
								callfunc_end();

								if (data[callback_data_limit] == 1) {
									ArrayDeleteItem(QueryCallbackArray, cb_array_index);
								}
							}
						}
					} else {
						ExecuteForward(gameMEStatsTop10Forward, iRet, RAW_MESSAGE_TOP10, client, get_pcvar_string_ex(g_gameme_message_prefix), pack);
					}
				}
			}
		}
		case RAW_MESSAGE_CALLBACK_NEXT, RAW_MESSAGE_NEXT: {
			if (argument_count >= 4) {
				new query_id = read_argv_int(2);
				new userid = read_argv_int(3);
				new client = find_player("k", userid);
				if (client < 1) {
					return PLUGIN_HANDLED;
				}

				new DataPack:pack = CreateDataPack();

				if (argument_count == 4) {
					WritePackCell(pack, -1); // total_players
				} else {
					new count = 0;
					for (new i = 4; (i <= argument_count); i++) {
						if (((i + 4) <= argument_count)) {
							count++;
							i = i + 4;
						}
					}
					WritePackCell(pack, count); // total_players

					new name[64];
					for (new i = 4; (i <= argument_count); i++) {
						if (((i + 4) <= argument_count)) {

							WritePackCell(pack, read_argv_int(i)); // rank
							WritePackCell(pack, read_argv_int((i + 1))); // skill

							read_argv((i + 2), name, charsmax(name));
							WritePackString(pack, name); // name
							WritePackFloat(pack, read_argv_float((i + 3))); // kpd
							WritePackFloat(pack, read_argv_float((i + 4))); // hpk

							i = i + 4;
						}
					}
				}

				if (type == RAW_MESSAGE_CALLBACK_NEXT) {
					if (query_id > 0) {
						new cb_array_index = find_callback(query_id);
						if (cb_array_index >= 0) {
							new data[callback_data];
							ArrayGetArray(QueryCallbackArray, cb_array_index, data, sizeof(data));

							callfunc_begin_i(data[callback_data_function], data[callback_data_plugin]);
							callfunc_push_int(RAW_MESSAGE_CALLBACK_NEXT);
							callfunc_push_int(data[callback_data_payload]);
							callfunc_push_int(client);
							callfunc_push_intrf(_:pack);
							callfunc_end();

							if (data[callback_data_limit] == 1) {
								ArrayDeleteItem(QueryCallbackArray, cb_array_index);
							}
						}
					}
				} else {
					ExecuteForward(gameMEStatsNextForward, iRet, RAW_MESSAGE_NEXT, client, get_pcvar_string_ex(g_gameme_message_prefix), pack);
				}
			}
		}
		case RAW_MESSAGE_CALLBACK_INT_CLOSE: {
			if (argument_count >= 2) {
				new query_id = read_argv_int(2);
				new cb_array_index = find_callback(query_id);
				if (cb_array_index >= 0) {
					ArrayDeleteItem(QueryCallbackArray, cb_array_index);
				}
			}
		}
		case RAW_MESSAGE_CALLBACK_INT_SPECTATOR: {
			if (argument_count >= 5) {
				new query_id = read_argv_int(2);

				new caller[MAX_PLAYERS + 1] = {-1, ...};
				new caller_id[512];
				read_argv(3, caller_id, charsmax(caller_id));
				if (contain(caller_id, ",") > -1) {
					new CallerRecipients[MAX_PLAYERS][16];
					new recipient_count = explode_string(caller_id, ",", CallerRecipients, MAX_PLAYERS, 16);
					for (new i = 0; (i < recipient_count); i++) {
						caller[i] = find_player("k", str_to_num(CallerRecipients[i]));
					}
				} else {
					caller[0] = find_player("k", str_to_num(caller_id));
				}

				new target[MAX_PLAYERS + 1] = {-1, ...};
				new target_id[512];
				read_argv(4, target_id, charsmax(target_id));
				if (contain(target_id, ",") > -1) {
					new TargetRecipients[MAX_PLAYERS][16];
					new recipient_count = explode_string(target_id, ",", TargetRecipients, MAX_PLAYERS, 16);
					for (new i = 0; (i < recipient_count); i++) {
						target[i] = find_player("k", str_to_num(TargetRecipients[i]));
					}
				} else {
					target[0] = find_player("k", str_to_num(target_id));
				}

				if ((caller[0] > -1) && (target[0] > -1) && (query_id > 0)) {
					new message[1024];
					read_argv(5, message, charsmax(message));

					new cb_array_index = find_callback(query_id);
					if (cb_array_index >= 0) {
						new data[callback_data];
						ArrayGetArray(QueryCallbackArray, cb_array_index, data, sizeof(data));

						callfunc_begin_i(data[callback_data_function], data[callback_data_plugin]);
						callfunc_push_int(RAW_MESSAGE_CALLBACK_INT_SPECTATOR);
						callfunc_push_int(data[callback_data_payload]);
						callfunc_push_array(caller, MAX_PLAYERS + 1);
						callfunc_push_array(target, MAX_PLAYERS + 1);
						callfunc_push_str(get_pcvar_string_ex(g_gameme_message_prefix));
						callfunc_push_str(message);
						callfunc_end();

						if (data[callback_data_limit] == 1) {
							ArrayDeleteItem(QueryCallbackArray, cb_array_index);
						}
					}

				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

stock find_callback(query_id) {
	new index = -1;
	new size = ArraySize(QueryCallbackArray);

	for (new i = 0; i < size; i++) {
		new data[callback_data];
		ArrayGetArray(QueryCallbackArray, i, data, sizeof(data));
		if ((data[callback_data_id] == query_id) && (data[callback_data_plugin] != INVALID_HANDLE) && (data[callback_data_function] != -1)) {
			index = i;
			break;
		}
	}
	return index;
}

stock get_query_id() {
	static global_query_id;
	if (global_query_id++ > 65535) {
		global_query_id = 1;
	}
	return global_query_id;
}

stock get_pcvar_string_ex(pcvar) {
	new szString[64];
	get_pcvar_string(pcvar, szString, charsmax(szString));
	return szString;
}

stock read_argv_string(index) {
	new szString[64];
	read_argv(index, szString, charsmax(szString));
	return szString;
}
