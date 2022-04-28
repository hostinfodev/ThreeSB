# ThreeSB

> Arma 3 is a horror game.

ThreeSB is a helper-script for creating server-based, hyper-realistic SSB situations in Arma 3 that includes AI that stalks players on foot and in any vehicle, immersive vocalizing and animation, and many configurable options. I (the developer) do not hope to glorify the actions that this script represents and am purely releasing it for the Arma 3 mission scripting community as it adds quite a shocking (and fun) experience to any mission.

*Only supported in MP!*

> [Video](https://www.youtube.com/watch?v=fI5xX6LcxYw)

> [Video](https://www.youtube.com/watch?v=NmDke7k-Ehg)

> ThreeSB - By [Grom](https://github.com/hostinfodev) 

> Based on `fn_taskHunt.sqf` by [nk3nny](https://github.com/nk3nny) 

> ZEN Integration
![](https://github.com/hostinfodev/ThreeSB/blob/main/ThreeSB/docs/create_new_ssb.png?raw=true)


# Installation
- Simply move folder "ThreeSB" to your mission folder.
- Merge "Description.ext" with your own "Description.ext".
- Subscribe to & enable [Zeus Enhanced Mod](https://steamcommunity.com/workshop/filedetails/?id=1779063631) (required).
# Usage
## Spawn a male in a car - 100m
```sqf
[ 
 "CUP_C_TK_Man_04", 
 [getPos player, [0, 100, 0]] call BIS_fnc_vectorAdd, 
 20,
 "CUP_C_Volha_Gray_TKCIV",
 false,
 1000,
 true,
 civilian,
 true,
 true,
 "Bo_GBU12_LGB",
 5,
 false
] execVM "ThreeSB\server\fnc_create_one_3sb.sqf";
```
## Spawn a male on foot - 100m
```sqf
[ 
 "CUP_C_TK_Man_04", 
 [getPos player, [0, 100, 0]] call BIS_fnc_vectorAdd, 
 20,
 false,
 false,
 1000,
 true,
 civilian,
 true,
 true,
 "Bo_GBU12_LGB",
 5,
 false
] execVM "ThreeSB\server\fnc_create_one_3sb.sqf";
```
## Spawn a female on foot - 100m
```sqf
[ 
 "ZEPHIK_Female_Civ_12", 
 [getPos player, [0, 100, 0]] call BIS_fnc_vectorAdd, 
 20,
 false,
 false,
 1000,
 true,
 civilian,
 true,
 true,
 "Bo_GBU12_LGB",
 5,
 true
] execVM "ThreeSB\server\fnc_create_one_3sb.sqf";
```

# Parameters:
> ## Basic
- 0: classname - string
- 1: position - array
- 2: detonation radius - number
> ## Advanced
- 0: classname - string
- 1: position - array
- 2: detonation radius - number
- 3: vehicle - bool or string
- 4: debug - bool
- 5: targeting radius - number
- 6: deadman switch - bool
- 7: side - side
- 8: audio - bool
- 9: add gear - bool
- 10: explosion type - string
- 11: interval - number
- 12: isfemale - bool