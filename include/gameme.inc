/**
 * gameME Plugin
 * http://www.gameme.com
 * Copyright (C) 2007-2016 TTS Oetzel & Goerz GmbH
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#if defined _gameme_included_
	#endinput
#endif
#define _gameme_included_

// raw message handling
#define RAW_MESSAGE_RANK				1
#define RAW_MESSAGE_PLACE				2
#define RAW_MESSAGE_KDEATH				3
#define RAW_MESSAGE_SESSION_DATA		4
#define RAW_MESSAGE_TOP10				5
#define RAW_MESSAGE_NEXT				6

// callbacks
#define RAW_MESSAGE_CALLBACK_PLAYER		101
#define RAW_MESSAGE_CALLBACK_TOP10		102
#define RAW_MESSAGE_CALLBACK_NEXT		103

// internal usage
#define RAW_MESSAGE_CALLBACK_INT_CLOSE		1000
#define RAW_MESSAGE_CALLBACK_INT_SPECTATOR	1001

forward onGameMEStatsRank(command, client, message_prefix[], &DataPack:datapack);
forward onGameMEStatsPublicCommand(command, client, message_prefix[], &DataPack:datapack);
forward onGameMEStatsTop10(command, client, message_prefix[], &DataPack:datapack);
forward onGameMEStatsNext(command, client, message_prefix[], &DataPack:datapack);

/**
 * Query gameME Stats data from a client
 * 
 * @param request		Request type (only 'playerinfo' available)
 * @param client		Client index.
 * @param func		Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryGameMEStats(request[], client, func[], payload = 0);

/**
 * Query Top10 players from gameME Stats
 * 
 * @param request		Request type (currently only 'top10' available)
 * @param client		Client index.
 * @param func		Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryGameMEStatsTop10(request[], client, func[], payload = 0);

/**
 * Query next players from gameME Stats for s specified client
 * 
 * @param request		Request type (currently only 'next' available)
 * @param client		Client index.
 * @param func		Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryGameMEStatsNext(request[], client, func[], payload = 0);

/**
 * Query internal (preformatted) gameME Stats data
 * 
 * @param request		Request type.
 * @param client		Client index.
 * @param func		Callback function.
 * @param payload		Payload to distinct queries.
 * @noreturn
 */
native QueryIntGameMEStats(request[], client, func[], payload = 0, limit = 0);
