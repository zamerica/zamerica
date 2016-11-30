#!/bin/bash

set -e

DATADIR=./benchmark-datadir

function zamerica_rpc {
    ./src/zamerica-cli -rpcwait -rpcuser=user -rpcpassword=password -rpcport=5983 "$@"
}

function zamericad_generate {
    zamerica_rpc generate 101 > /dev/null
}

function zamericad_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR"
    ./src/zamericad -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 -showmetrics=0 &
    ZCASHD_PID=$!
}

function zamericad_stop {
    zamerica_rpc stop > /dev/null
    wait $ZCASH_PID
}

function zamericad_massif_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR"
    rm -f massif.out
    valgrind --tool=massif --time-unit=ms --massif-out-file=massif.out ./src/zamericad -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 -showmetrics=0 &
    ZCASHD_PID=$!
}

function zamericad_massif_stop {
    zamerica_rpc stop > /dev/null
    wait $ZCASHD_PID
    ms_print massif.out
}

function zamericad_valgrind_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR"
    rm -f valgrind.out
    valgrind --leak-check=yes -v --error-limit=no --log-file="valgrind.out" ./src/zamericad -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 -showmetrics=0 &
    ZCASHD_PID=$!
}

function zamericad_valgrind_stop {
    zamerica_rpc stop > /dev/null
    wait $ZCASHD_PID
    cat valgrind.out
}

# Precomputation
case "$1" in
    *)
        case "$2" in
            verifyjoinsplit)
                zamericad_start
                RAWJOINSPLIT=$(zamerica_rpc zcsamplejoinsplit)
                zamericad_stop
        esac
esac

case "$1" in
    time)
        zamericad_start
        case "$2" in
            sleep)
                zamerica_rpc zcbenchmark sleep 10
                ;;
            parameterloading)
                zamerica_rpc zcbenchmark parameterloading 10
                ;;
            createjoinsplit)
                zamerica_rpc zcbenchmark createjoinsplit 10
                ;;
            verifyjoinsplit)
                zamerica_rpc zcbenchmark verifyjoinsplit 1000 "\"$RAWJOINSPLIT\""
                ;;
            solveequihash)
                zamerica_rpc zcbenchmark solveequihash 50 "${@:3}"
                ;;
            verifyequihash)
                zamerica_rpc zcbenchmark verifyequihash 1000
                ;;
            validatelargetx)
                zamerica_rpc zcbenchmark validatelargetx 5
                ;;
            *)
                zamericad_stop
                echo "Bad arguments."
                exit 1
        esac
        zamericad_stop
        ;;
    memory)
        zamericad_massif_start
        case "$2" in
            sleep)
                zamerica_rpc zcbenchmark sleep 1
                ;;
            parameterloading)
                zamerica_rpc zcbenchmark parameterloading 1
                ;;
            createjoinsplit)
                zamerica_rpc zcbenchmark createjoinsplit 1
                ;;
            verifyjoinsplit)
                zamerica_rpc zcbenchmark verifyjoinsplit 1 "\"$RAWJOINSPLIT\""
                ;;
            solveequihash)
                zamerica_rpc zcbenchmark solveequihash 1 "${@:3}"
                ;;
            verifyequihash)
                zamerica_rpc zcbenchmark verifyequihash 1
                ;;
            *)
                zamericad_massif_stop
                echo "Bad arguments."
                exit 1
        esac
        zamericad_massif_stop
        rm -f massif.out
        ;;
    valgrind)
        zamericad_valgrind_start
        case "$2" in
            sleep)
                zamerica_rpc zcbenchmark sleep 1
                ;;
            parameterloading)
                zamerica_rpc zcbenchmark parameterloading 1
                ;;
            createjoinsplit)
                zamerica_rpc zcbenchmark createjoinsplit 1
                ;;
            verifyjoinsplit)
                zamerica_rpc zcbenchmark verifyjoinsplit 1 "\"$RAWJOINSPLIT\""
                ;;
            solveequihash)
                zamerica_rpc zcbenchmark solveequihash 1 "${@:3}"
                ;;
            verifyequihash)
                zamerica_rpc zcbenchmark verifyequihash 1
                ;;
            *)
                zamericad_valgrind_stop
                echo "Bad arguments."
                exit 1
        esac
        zamericad_valgrind_stop
        rm -f valgrind.out
        ;;
    valgrind-tests)
        case "$2" in
            gtest)
                rm -f valgrind.out
                valgrind --leak-check=yes -v --error-limit=no --log-file="valgrind.out" ./src/zamerica-gtest
                cat valgrind.out
                rm -f valgrind.out
                ;;
            test_bitcoin)
                rm -f valgrind.out
                valgrind --leak-check=yes -v --error-limit=no --log-file="valgrind.out" ./src/test/test_bitcoin
                cat valgrind.out
                rm -f valgrind.out
                ;;
            *)
                echo "Bad arguments."
                exit 1
        esac
        ;;
    *)
        echo "Bad arguments."
        exit 1
esac

# Cleanup
rm -rf "$DATADIR"
