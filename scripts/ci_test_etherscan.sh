#!/usr/bin/env bash

### Test etherscan integration

DIR=$(mktemp -d)
cd "$DIR" || exit 255

solc-select use 0.4.25 --always-install

delay_etherscan () {
    # Perform a small sleep when API key is not available (e.g. on PR CI from external contributor)
    if [ "$GITHUB_ETHERSCAN" = "" ]; then
        sleep 5s
    else
      # Always sleep 2 second in the CI
      # We have a lot of concurrent github action so this is needed
      sleep 2s
    fi
}

echo "::group::Etherscan mainnet"
scryto-compile 0x7F37f78cBD74481E593F9C737776F7113d76B315 --compile-remove-metadata --etherscan-apikey "$GITHUB_ETHERSCAN"

if [ $? -ne 0 ]
then
    echo "Etherscan mainnet test failed"
    exit 255
fi
echo "::endgroup::"

delay_etherscan

# From scryto/slither#1154
echo "::group::Etherscan #3"
scryto-compile 0xcfc1E0968CA08aEe88CbF664D4A1f8B881d90f37 --compile-remove-metadata --etherscan-apikey "$GITHUB_ETHERSCAN"

if [ $? -ne 0 ]
then
    echo "Etherscan #3 test failed"
    exit 255
fi
echo "::endgroup::"

delay_etherscan

# From scryto/scryto-compile#415
echo "::group::Etherscan #4"
scryto-compile 0x19c7d0fbf906c282dedb5543d098f43dfe9f856f --compile-remove-metadata --etherscan-apikey "$GITHUB_ETHERSCAN"

if [ $? -ne 0 ]
then
    echo "Etherscan #4 test failed"
    exit 255
fi
echo "::endgroup::"

delay_etherscan

# From scryto/scryto-compile#150
echo "::group::Etherscan #5"
scryto-compile 0x2a311e451491091d2a1d3c43f4f5744bdb4e773a --compile-remove-metadata --etherscan-apikey "$GITHUB_ETHERSCAN"

if [ $? -ne 0 ]
then
    echo "Etherscan #5 test failed"
    case "$(uname -sr)" in
        CYGWIN*|MINGW*|MSYS*)
            echo "This test is known to fail on Windows"
        ;;
        *)
            exit 255
        ;;
    esac
fi
echo "::endgroup::"

delay_etherscan

# From scryto/scryto-compile#151
echo "::group::Etherscan #6"
scryto-compile 0x4c808e3c011514d5016536af11218eec537eb6f5 --compile-remove-metadata --etherscan-apikey "$GITHUB_ETHERSCAN"

if [ $? -ne 0 ]
then
    echo "Etherscan #6 test failed"
    exit 255
fi
echo "::endgroup::"
