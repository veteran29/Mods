/*
 * Author: DaC, Jonpas
 * Gets data from ApolloClient/Athena (Chronos).
 *
 * Arguments:
 * 0: Category <STRING>
 *
 * Return Value:
 * Armory Data <ARRAY>
 *
 * Example:
 * ["category"] call tac_armory_fnc_getDataChronos
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_selectedCategory"];

// Set Chronos to debug if flag set
private _debug = ["", "test"] select (!isNil QEGVAR(chronos,debug) && {EGVAR(chronos,debug)});

// Call Chronos for Data - no further HTTP calls are needed after this one
private _loadData = "ApolloClient" callExtension (format ["%1%2/%3/%4", "loadArmory", _selectedCategory, getPlayerUID player, _debug]);

if (_loadData == "loaded") then {
    private _armoryData = [];
    private _updateInfo = true;
    private _entry = [];

    while {_updateInfo} do {
        // Retrieve the data which is stored in the client's heap
        private _serverReply = "ApolloClient" callExtension "get";
        TRACE_1("Get Chronos Data",_serverReply);

        if (_serverReply == "done") then {
            _updateInfo = false;
        } else {
            _entry pushBack _serverReply;

            // Reset
            if (_serverReply == "next") then {
                _armoryData pushBack _entry;
                _entry = [];
            };
        };
    };
    TRACE_2("Athena Armory Data",_selectedCategory,_armoryData);
    _armoryData
} else {
    [LSTRING(ChronosError), 2.5] call ACE_Common_fnc_displayTextStructured;
    false
};
