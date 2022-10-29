# [Any] SourceIRC Achievement Relay

**Version 1.1.0**

*(Requires SourceIRC)*

## Description:
Announces achievement events to IRC with name and description.

Example:

![](https://content.screencast.com/users/DarthNinja/folders/Jing/media/c3603442-0f86-485d-a1e3-942b31a10e37/2012-07-01_1721.png)
A Few Seconds Later...
![](https://forums.alliedmods.net/image-proxy/98ee35547030b8e0b252178f8c33be80d879a26e/687474703a2f2f636f6e74656e742e73637265656e636173742e636f6d2f75736572732f44617274684e696e6a612f666f6c646572732f4a696e672f6d656469612f39346534633762342d323061642d346237372d626563342d6166666161326539306133642f323031322d30372d30315f313732312e706e67)

## Commands:
sm_reload_achievement_relay - Reloads configs

## Cvars:
- sm_achievementrelay_version - Plugin Version
- sm_achrelay_debug "0" - Set to "1" to print debugging info.
- sm_achrelay_timestamp "1" - Show/hide timestamps
- sm_achrelay_timeoffset "0" - Seconds to change timestamp by

## Install Instructions:
1. Match up the structure of the zip with your server's sourcemod folder.

## Notes:
This plugin supports any game that makes use of the achievement_earned event.
Achievements are indexed in the achievements.kv file. The copy included has data for TF2.
If people want to forward me index files for other games, I will add them to this post. However I probably will not create them myself.

This plugin will post messages to channels tagged with "achievements". See example:

sourceirc.cfg Example:
**Code:**
          `"#MyChannel"
            {
                "relay"            "1" // Tell the RelayAll module to relay messages to this channel
                "cmd_prefix"    "!" // Ontop of calling the bot by name, you can also use "!" in this channel
                "items"            "1"
            }
            "#MyOtherChannel"
            {
                "ticket"        "1" // Tell the ticket module to send tickets to this channel
                "achievements"            "1"  // Prints all achievements to this channel
            }
            "#Ninja"
            {
                "achievements"            "1"  // Prints all achievements to this channel
            }`
            
## Version History:
- **V1.1.0**
	- Initial release