### [S-#] Storing a password on the blockchain make it visible to anyone, the password is not longer private 

**Description:** All the data stored on the blockhain is visible to anyone, and can be read directly from the blockchain . The `PasswordStore::s_password` varible is intended to be a private variable can only accessed throgh the `PasswordStore::getPassword` function , which is intended to be  called by the owner of the contract only . 

We show one such method of reading any data off  chain below.

**Impact:**  Anyone can read the private password , severly breaking the functionality of the protocol

**Proof of Concept:**(Proof of Code)
The below test case shows how anyone can read the password directly from the blockchain

1. Create a locall running chain
```bash
make anvil
```

2. Deploy the contract `PasswordStore`.
```bash
make deploy
```

3. Run the storage tool, to read the storage slot of the contract.
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