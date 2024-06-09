// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
    }

    /*
     *
     @notice This test checks if the anyone can set a password.
     A random user can set a password and the but owner can read the password.
    @ notice a fuzz test is written to proof that anyone can set a password
     */

    function test_AnyOne_can_set_password(address anyUser, string memory anyPassword) public {
        if (anyUser == owner) {
            return;
        }
        vm.startPrank(anyUser);
        string memory expectedPassword = anyPassword;
        passwordStore.setPassword(expectedPassword);
        vm.stopPrank();
        //only owner can read password the changed password
        vm.startPrank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }
}
