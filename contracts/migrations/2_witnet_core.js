// WARNING: DO NOT DELETE THIS FILE
// This file was auto-generated by the Witnet compiler, any manual changes will be overwritten.
const WitnetRequestBoardProxy = artifacts.require("WitnetRequestBoardProxy")
const WitnetRequestBoard = artifacts.require("WitnetRequestBoard")
const CBOR = artifacts.require("CBOR")
const Witnet = artifacts.require("Witnet")

const addresses = {
  "goerli": {
    "CBOR": "0x9905821089928e5A26841225510cea8B2984F6D8",
    "Witnet": "0x9b42b0D80C428B17A5828dF5C2c96454ca54bD04",
    "WitnetRequestBoardProxy": "0x0C4be6AA667df48de54BA174bE7948875fdf152B",
  },
  "kovan": {
    "CBOR": "0xB4B2E2e00e9d6E5490d55623E4F403EC84c6D33f",
    "Witnet": "0xD9465D38f50f364b3263Cb219e58d4dB2D584530",
    "WitnetRequestBoardProxy": "0xD9a6d1Ea0d0f4795985725C7Bd40C31a667c033d",
  },
  "mainnet": {
    "CBOR": "0x1D9c4a8f8B7b5F9B8e2641D81927f8F8Cc7fF079",
    "Witnet": "0x916aC9636F4Ea9f54f07c9De8fDCd828e1b32c9B",
    "WitnetRequestBoardProxy": "0x400DbF3645b345823124aaB22D04013A46D9ceD5",
  },
  "rinkeby": {
    "CBOR": "0xa3AFD68122a21c7D21Ddd95E5c077f958dA46662",
    "Witnet": "0x5259aCEfF613b37aF35999798A6da60bEF326038",
    "WitnetRequestBoardProxy": "0x9b42b0D80C428B17A5828dF5C2c96454ca54bD04",
  },
}

module.exports = function (deployer, network, accounts) {
  network = network.split("-")[0]
  if (network in addresses) {
    Witnet.address = addresses[network]["Witnet"]
    WitnetRequestBoardProxy.address = addresses[network]["WitnetRequestBoardProxy"]
  } else {
    deployer.deploy(CBOR)
    deployer.link(CBOR, Witnet)
    deployer.deploy(Witnet)
    deployer.deploy(WitnetRequestBoard, [accounts[0]]).then(function() {
      return deployer.deploy(WitnetRequestBoardProxy, WitnetRequestBoard.address)
    })
  }
}
