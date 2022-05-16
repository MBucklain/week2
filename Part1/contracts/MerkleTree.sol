//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    int public leafs = 8;
    int public levls = 4;


    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        
        
        for(uint256 i  = 0;i<15;i++){
            hashes.push(0);
        }
        for(uint256 i  = 0;i<7;i++){
            hashes.push(PoseidonT3.poseidon([hashes[i*2],hashes[i*2+1]]));
        }
        
        
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        
       
        hashes[index]=hashedLeaf;
      
       
        uint256 j =index/2+8;
        uint256 temp = index;
        for(int i = 0; i<levls-1;i++){
            
            if(temp%2 ==0 ){
                 hashes[j]=PoseidonT3.poseidon([hashes[temp],hashes[temp+1]]);
            }
            else{
                hashes[j]=PoseidonT3.poseidon([hashes[temp-1],hashes[temp]]);
            }
            temp =j;
            j=j/2+8;

        }
    

        index++;
        root = hashes[14];
        return hashes[14];

    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return super.verifyProof(a,b,c,input) && input[0] == root;
    }
}
