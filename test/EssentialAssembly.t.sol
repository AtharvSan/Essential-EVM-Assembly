// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/EssentialAssembly.sol";

contract CounterTest is Test {
    EssentialAssembly public cheatsheet;

    function setUp() public {
        cheatsheet = new EssentialAssembly();
    }

}
