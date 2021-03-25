
/*
 The value of secboot is 0x1f an integer with an indefinite length. This 
 not-well-formed CBOR that should be caught at the lowest layer in the
 decoder and bubbled up to some top-level error. This is to test
 that path of bubbling up errors. There are lots of other ways
 that CBOR can be invalid here. This is just one to test the error 
 propagation. 
*/

const unsigned char invalid_secboot3[] = {
    0xa1, 0x0f, 0x1f, 
};

