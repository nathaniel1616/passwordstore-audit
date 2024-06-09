---
title: PasswordStoreAudit Report
author: Nathaniel Yeboah
date: June 9, 2024
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
        \includegraphics[width=0.5\textwidth]{logo.pdf} 
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries PasswordStore Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape Nathaniel Yeboah\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: Nathaniel Yeboah
 Auditor: 
- Nathaniel Yeboah


# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
    - [\[H-1\] Storing a password on the blockchain make it visible to anyone, the password is not longer private](#h-1-storing-a-password-on-the-blockchain-make-it-visible-to-anyone-the-password-is-not-longer-private)
    - [\[H-2\] `PasswordStore::setPassword`  has no access control,which can make non-owner to set the password of the contract](#h-2-passwordstoresetpassword--has-no-access-controlwhich-can-make-non-owner-to-set-the-password-of-the-contract)
  - [Informational](#informational)
    - [\[I-1\] The nat spec document on `PasswordStore:getPassword` function indicates a parameter that does not exist, causing the natspec to be incorrect](#i-1-the-nat-spec-document-on-passwordstoregetpassword-function-indicates-a-parameter-that-does-not-exist-causing-the-natspec-to-be-incorrect)

# Protocol Summary

This is a password store contract where users can store their passwords. Only the owner can set the password and view the password . The contract emits an event when a password is set.

# Disclaimer

The Security Researcher makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 

** The findings described in this report are based on the code at the following commit hash: **
```
Commit hash: 7d55682ddc4301a7b13ae9413095feffd9924566

```

## Scope 
** The audit report is based on the following files: **

```
src/PasswordStore.sol
```

## Roles

- **Owner:** The owner of the contract can set the password of the contract and view the password of the contract.
- **Others:** No one else can set the password of the contract or view the password of the contract.
  
# Executive Summary

* Add some notes about how the audit went, what was found, types of things you found *

* We spend about 5 hours with 1 auditors using foundry *

## Issues found
 | Severity | Number of issues found |
 | -------- | ---------------------- |
 | High     | 2                      |
 | Medium   | 0                      |
 | Low      | 0                      |
 | Info     | 1                      |
 | Total    | 3                      |


# Findings
## High
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



### [H-2] `PasswordStore::setPassword`  has no access control,which can make non-owner to set the password of the contract 

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


## Informational

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

