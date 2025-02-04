

###  [H-1] Storing a password on the blockchain make it visible to anyone, the password is not longer private 


**Description:** All the data stored on the blockhain is visible to anyone, and can be read directly from the blockchain . The `PasswordStore::s_password` varible is intended to be a private variable can only accessed throgh the `PasswordStore::getPassword` function , which is intended to be  called by the owner of the contract only . 

We show one such method of reading any data off  chain below.

**Impact:**  Anyone can read the private password , severly breaking the functionality of the protocol

**Proof of Concept:**(Proof of Code)
The below test case shows how anyone can read the password directly from the blockchain

1. Create a locall running chain
```bash
make anvil
```

1. Deploy the contract `PasswordStore`.
```bash
make deploy
```

1. Run the storage tool, to read the storage slot of the contract.
We use `1` because the `s_password` variable is stored at that storage slot
```bash
cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
```

You wil get an output that looks lie this:
`0x6d7950617373776f726400000000000000000000000000000000000000000014`

You can then parse that hex to a string with this command:
```bash
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```
You will get an output of 
`myPassword`


**Recommended Mitigation:** Due to this , the overall archieture of the contract should be rethought. One can encrypt the password before storing it on the blockchain, and then decrypt it when needed.This would require the user to remember another password off chain to decrypt the onchain password.How you also want ot remove the view function as you wouldnt wantthe user to accidentally send a transaction with the password that decrupts your password.



###  [H-2] `PasswordStore::setPassword`  has no access control,which can make non-owner to set the password of the contract 


**Description:** A non-owner can set the password of the `PasswordStore` contract by calling the `PasswordStore::setPassword` function. This is because the `PasswordStore::setPassword` function does not have a modifier  or a logic to check if the caller is the owner of the contract.
```javascript
  function setPassword(string memory newPassword) external {
@>      s_password = newPassword;
        emit SetNetPassword();
    }

```


**Impact:** An user can set the password of the `PasswordStore` contract, which is not the intended functionality of the contract.

**Proof of Concept:** 

<details>
<summary> Code details here </summary>
1. Create a locall running chain
```bash
make anvil
```

2. Deploy the contract `PasswordStore`.
```bash
make deploy
```
This returns a deployed `PasswordStore` address which in our case was
`0x5FbDB2315678afecb367f032d93F642f64180aa3`

3. Set the password of the `PasswordStore` contract by calling the `PasswordStore::setPassword` function with a random  private key apart from the default private key in the makeFile. We selected `0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a` as our private key.
   
```bash
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "setPassword(string  newPassword)" "changePassword"  --private-key 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a 
```
This transaction does not revert and the password of the `PasswordStore` contract is set to `changePassword`.
</details>

**Recommended Mitigation:** We recommend to either
1. Use OpenZeppelin Ownable contracts to the contract. This will allow you to add an only owner modifier to the `PasswordStore::setPassword` function to check if the caller is the owner of the contract. 
2. you can create your own modifier to the `PasswordStore::setPassword` function to check if the caller is the owner of the contract.
This can be done by adding a modifier like `onlyOwner` to the `PasswordStore::setPassword` function. The `onlyOwner` modifier can be implemented as follows:

```solidity
modifier onlyOwner(){
    if (msg.sender != s_owner){
        revert("Only owner can call this function");
    }
}
```
Add the `onlyOwner` modifier to the `PasswordStore::setPassword` function as follows:

```solidity
function setPassword(string memory newPassword) external onlyOwner {
        s_password = newPassword;
        emit SetNetPassword();
    }
```


### [I-1] The nat spec document on `PasswordStore:getPassword` function indicates a parameter that does not exist, causing the natspec to be incorrect

**Description:** 
```javascript
    /**
     * @dev Get the password of the contract
-->   * @param password The password of the contract
     */
    function getPassword() external view returns (string memory password) {
        return s_password;
    }
```
The `PasswordStore::getPassword` function does not take any parameter, but the nat spec document indicates that the function takes a parameter `password`. This causes the nat spec document to be incorrect.

**Impact:** The nat spec document is incorrect and can cause confusion to the users of the contract.


**Recommended Mitigation:**  Remove the nat spec document on the `PasswordStore::getPassword` function.

```diff
-  * @param newPassword The new password to set.
```
