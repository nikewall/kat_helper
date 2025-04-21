# kat helper

test vectors are pulled from nist: http://csrc.nist.gov/groups/STM/cavp/documents/mac/gcmtestvectors.zip

rsp_parser will read the .rsp file passed to it sectionwise
main will just create temp .bin files for key, iv, aad, tag, ct/pt, and pt/ct.
    - for poc just does the first test case...
