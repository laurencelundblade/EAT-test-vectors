
/*
The submod section is an integer lacking its CBOR argument. That is the
integer is truncated. The CBOR decoder should find that the submodules
section is not well formed. 

(In theory some CBOR decoders might  
*/

const char not_well_formed_submod_section[] = {
    0xa1, 0x14, 0x1f, 
};

