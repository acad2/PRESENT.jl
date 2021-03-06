include("utilities.jl")

################## PRESENT algo and implemetation #######################
#genrateKeys(K) will be a function which will take in intial key
#and generate round keys the algo is
#genKeys(K_initial)
#for i in 1:31
# xor(state,roundkey_i)  --> this will update state
# sLayer(state)          --> this will update state again
# pLaye(state)           --> this will update state again
#end
#xor(state,K_32)

#PRESENTenc will be the actual function which will
#be encrypting initial state (testvector)
#PRESENTenc will be a wrapper around the encrypting algorithm.
#each rounds data will be stored in roundData type
#the input key and the state is expected in the hexadecimal
#hexadecimal starting WITHOUT "0x"
#since the the proposed design is used to encrypt/decrypt 64bits at a times
#the hexadecimal version of inputs will be well acoomodated in 16 units of length
function PRESENTenc(K, inp)
    rounds = 31
    k_seed  = hex2bin(K,80)
    keys = genKeys(k_seed)
    state = hex2bin(inp,64)
    rounds_data = fill(undef_round,32)

    for i in 1:rounds
        round_inp = state
        round_key = keys[i]
        state = xor(state,keys[i])
        state = sLayer(state)
        state = pLayer(state)
        round_outp = state

        rounds_data[i] = roundData(round_inp,round_key,round_outp)
    end
    round_inp = state
    round_key = keys[32]
    state = xor(state,keys[32])
    round_outp = state
    rounds_data[32] = roundData(round_inp,round_key,round_outp)

    #to output the ciphertext
    bin2hex(rounds_data[32].outp,16)
end

#PRESENTdec will be the actual function which will
#be decrypting initial state (testvector)
#PRESENTdec will be a wrapper around the decrypting algorithm.
#each rounds data will be stored in roundData type
#the input key and the state is expected in the hexadecimal
#hexadecimal starting WITHOUT "0x"

#decryption will follow the following scheme of operations
#xorKey        |
#invpLayer     | ---> this happens 31 times
#invsLayer     |
#xorKey
function PRESENTdec(K, inp)
    rounds = 31
    k_seed  = hex2bin(K,80)
    keys = genKeys(k_seed)
    state = hex2bin(inp,64) #this represents the ciphertext
    rounds_data = fill(undef_round,32)

    for i in 1:rounds
        round_inp = state
        round_key = keys[33-i]
        state = xor(state,keys[33-i])
        state = invpLayer(state)
        state = invsLayer(state)
        round_outp = state

        rounds_data[i] = roundData(round_inp,round_key,round_outp)
    end
    round_inp = state
    round_key = keys[33-32]
    state = xor(state,keys[33-32])
    round_outp = state
    rounds_data[32] = roundData(round_inp,round_key,round_outp)

    #to output the plaintext
    bin2hex(rounds_data[32].outp,16)
end
#########################################################################
