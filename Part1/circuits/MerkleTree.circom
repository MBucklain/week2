pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template HashingPoseidon(){
    signal input N[2];
    signal output out;

    component Hashing = Poseidon(2);

    for(var i = 0 ; i<2 ; i++){
        Hashing.inputs[i] <== N[i];
    }

    out <== Hashing.out;


}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var Leafs = (2**n)/2; //buttom Leafs
    var HashNum = (2**n)-1; // number of all hashes 
    var Middle = Leafs - 1;// Leavs in the middle
    component HashingPoseidon[HashNum];// where I will store the hashes

    for(var  i =0 ; i<HashNum ; i++)
    {
        HashingPoseidon = HashingPoseidon();   
    }

    for (var i = 0 ; i<Leafs ; i++){
        HashingPoseidon[i].N[0] <== leaves[2*i];
        HashingPoseidon[i].N[1] <== leaves[2*i+1];
    }

    var j = 0;
    for (var i =Leafs ; i<Leafs +  Middle ; i++ ){
        HashingPoseidon[i].N[0] <== leaves[2*j].out;
        HashingPoseidon[i].N[1] <== leaves[2*j+1].out;
        j++;
    }

    root <== HashingPoseidon[HashNum - 1].out;

    
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n][1];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component Hashes[n];
    component mux[n];

    signal Levels[n+1];
    Levels[0] <==leaf;

    for (var i =0 ;i<n;i++){
        path_index[i] * (1 - path_index[i]) === 0;
        Hashes[i] = HashingPoseidon();
        mux[i] = MultiMux1(2);
        mux[i].c[0][0] <== Levels[i];
        mux[i].c[0][1] <== path_elements[i][0];
        mux[i].c[1][0] <== path_elements[i][0];
        mux[i].c[1][1] <== Levels[i];
        mux[i].s <== path_index[i];
        Hashes[i].N[0] <== mux[i].out[0];
        Hashes[i].N[1] <== mux[i].out[1];
        Levels[i + 1] <== Hashes[i].out;
    }

    root <== Levels[n];
}