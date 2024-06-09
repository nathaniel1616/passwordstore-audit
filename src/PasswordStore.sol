// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // @audit-q is this a safe version of solidity to use?

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */

contract PasswordStore {
    error PasswordStore__NotOwner();

    /*//////////////////////////////////////////////////////////////////////////////////////////
                                      STORAGE VARIABLES                     
    ////////////////////////////////////////////////////////////////////////////////////////////*/

    address private s_owner;

    //  @audit s_password should can be view my anyone on the blockchain , password should be a encrypted with owners private key
    string private s_password;

    /*//////////////////////////////////////////////////////////////////////////////////////////
                                      EVENTS                    
    ////////////////////////////////////////////////////////////////////////////////////////////*/
    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */
    //@audit-q  can other users call this function ?  YES
    //@audit-q  should  others be able to call this function ?  NO
    //@audit any user can set a password
    // missing access control
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     * @param newPassword The new password to set.
     * @audit there is no newPassword parameter
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
