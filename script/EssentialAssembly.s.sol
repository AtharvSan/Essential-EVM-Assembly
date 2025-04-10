// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/EssentialAssembly.sol";

contract CounterScript is Script {
    EssentialAssembly public cheatsheet;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        cheatsheet = new EssentialAssembly();

        vm.stopBroadcast();
    }
}
