//
//  ZkSyncABI.swift
//  ZKSync
//
//  Created by Eugene Belyakov on 19/01/2021.
//

import Foundation
import web3swift_zksync

extension Web3.Utils {
    public static var zkSyncABI = """
    [
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "blockNumber",
              "type": "uint32"
            }
          ],
          "name": "BlockCommit",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "blockNumber",
              "type": "uint32"
            }
          ],
          "name": "BlockVerification",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "uint32",
              "name": "totalBlocksVerified",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "uint32",
              "name": "totalBlocksCommitted",
              "type": "uint32"
            }
          ],
          "name": "BlocksRevert",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "zkSyncBlockId",
              "type": "uint32"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "accountId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "address",
              "name": "owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "tokenId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "uint128",
              "name": "amount",
              "type": "uint128"
            }
          ],
          "name": "DepositCommit",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [],
          "name": "ExodusMode",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "sender",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "uint32",
              "name": "nonce",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "bytes",
              "name": "fact",
              "type": "bytes"
            }
          ],
          "name": "FactAuth",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "zkSyncBlockId",
              "type": "uint32"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "accountId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "address",
              "name": "owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "tokenId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "uint128",
              "name": "amount",
              "type": "uint128"
            }
          ],
          "name": "FullExitCommit",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "address",
              "name": "sender",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "uint64",
              "name": "serialId",
              "type": "uint64"
            },
            {
              "indexed": false,
              "internalType": "enum Operations.OpType",
              "name": "opType",
              "type": "uint8"
            },
            {
              "indexed": false,
              "internalType": "bytes",
              "name": "pubData",
              "type": "bytes"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "expirationBlock",
              "type": "uint256"
            }
          ],
          "name": "NewPriorityRequest",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "sender",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "tokenId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "uint128",
              "name": "amount",
              "type": "uint128"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "owner",
              "type": "address"
            }
          ],
          "name": "OnchainDeposit",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "tokenId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "uint128",
              "name": "amount",
              "type": "uint128"
            },
            {
              "indexed": false,
              "internalType": "bool",
              "name": "success",
              "type": "bool"
            }
          ],
          "name": "OnchainWithdrawal",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint32",
              "name": "tokenId",
              "type": "uint32"
            },
            {
              "indexed": false,
              "internalType": "uint128",
              "name": "amount",
              "type": "uint128"
            }
          ],
          "name": "RollupWithdrawal",
          "type": "event"
        },
        {
          "inputs": [
            {
              "internalType": "contract IERC20",
              "name": "_token",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "_to",
              "type": "address"
            },
            {
              "internalType": "uint128",
              "name": "_amount",
              "type": "uint128"
            },
            {
              "internalType": "uint128",
              "name": "_maxAmount",
              "type": "uint128"
            }
          ],
          "name": "_transferERC20",
          "outputs": [
            {
              "internalType": "uint128",
              "name": "withdrawnAmount",
              "type": "uint128"
            }
          ],
          "stateMutability": "nonpayable",
          "payable": false,
          "type": "function"
        },
        {
          "inputs": [],
          "name": "activateExodusMode",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            },
            {
              "internalType": "uint32",
              "name": "",
              "type": "uint32"
            }
          ],
          "name": "authFacts",
          "outputs": [
            {
              "internalType": "bytes32",
              "name": "",
              "type": "bytes32"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint64",
              "name": "_n",
              "type": "uint64"
            },
            {
              "internalType": "bytes[]",
              "name": "_depositsPubdata",
              "type": "bytes[]"
            }
          ],
          "name": "cancelOutstandingDepositsForExodusMode",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "components": [
                {
                  "internalType": "uint32",
                  "name": "blockNumber",
                  "type": "uint32"
                },
                {
                  "internalType": "uint64",
                  "name": "priorityOperations",
                  "type": "uint64"
                },
                {
                  "internalType": "bytes32",
                  "name": "pendingOnchainOperationsHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                },
                {
                  "internalType": "bytes32",
                  "name": "stateHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "bytes32",
                  "name": "commitment",
                  "type": "bytes32"
                }
              ],
              "internalType": "struct Storage.StoredBlockInfo",
              "name": "_lastCommittedBlockData",
              "type": "tuple"
            },
            {
              "components": [
                {
                  "internalType": "bytes32",
                  "name": "newStateHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "bytes",
                  "name": "publicData",
                  "type": "bytes"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                },
                {
                  "components": [
                    {
                      "internalType": "bytes",
                      "name": "ethWitness",
                      "type": "bytes"
                    },
                    {
                      "internalType": "uint32",
                      "name": "publicDataOffset",
                      "type": "uint32"
                    }
                  ],
                  "internalType": "struct ZkSync.OnchainOperationData[]",
                  "name": "onchainOperations",
                  "type": "tuple[]"
                },
                {
                  "internalType": "uint32",
                  "name": "blockNumber",
                  "type": "uint32"
                },
                {
                  "internalType": "uint32",
                  "name": "feeAccount",
                  "type": "uint32"
                }
              ],
              "internalType": "struct ZkSync.CommitBlockInfo[]",
              "name": "_newBlocksData",
              "type": "tuple[]"
            }
          ],
          "name": "commitBlocks",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "contract IERC20",
              "name": "_token",
              "type": "address"
            },
            {
              "internalType": "uint104",
              "name": "_amount",
              "type": "uint104"
            },
            {
              "internalType": "address",
              "name": "_zkSyncAddress",
              "type": "address"
            }
          ],
          "name": "depositERC20",
          "payable": false,
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_zkSyncAddress",
              "type": "address"
            }
          ],
          "name": "depositETH",
          "outputs": [],
          "payable": true,
          "stateMutability": "payable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "components": [
                {
                  "components": [
                    {
                      "internalType": "uint32",
                      "name": "blockNumber",
                      "type": "uint32"
                    },
                    {
                      "internalType": "uint64",
                      "name": "priorityOperations",
                      "type": "uint64"
                    },
                    {
                      "internalType": "bytes32",
                      "name": "pendingOnchainOperationsHash",
                      "type": "bytes32"
                    },
                    {
                      "internalType": "uint256",
                      "name": "timestamp",
                      "type": "uint256"
                    },
                    {
                      "internalType": "bytes32",
                      "name": "stateHash",
                      "type": "bytes32"
                    },
                    {
                      "internalType": "bytes32",
                      "name": "commitment",
                      "type": "bytes32"
                    }
                  ],
                  "internalType": "struct Storage.StoredBlockInfo",
                  "name": "storedBlock",
                  "type": "tuple"
                },
                {
                  "internalType": "bytes[]",
                  "name": "pendingOnchainOpsPubdata",
                  "type": "bytes[]"
                }
              ],
              "internalType": "struct ZkSync.ExecuteBlockInfo[]",
              "name": "_blocksData",
              "type": "tuple[]"
            }
          ],
          "name": "executeBlocks",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "exodusMode",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "firstPriorityRequestId",
          "outputs": [
            {
              "internalType": "uint64",
              "name": "",
              "type": "uint64"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "getNoticePeriod",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "payable": false,
          "stateMutability": "pure",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_address",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "_token",
              "type": "address"
            }
          ],
          "name": "getPendingBalance",
          "outputs": [
            {
              "internalType": "uint128",
              "name": "",
              "type": "uint128"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "governance",
          "outputs": [
            {
              "internalType": "contract Governance",
              "name": "",
              "type": "address"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "bytes",
              "name": "initializationParameters",
              "type": "bytes"
            }
          ],
          "name": "initialize",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "isReadyForUpgrade",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "components": [
                {
                  "internalType": "uint32",
                  "name": "blockNumber",
                  "type": "uint32"
                },
                {
                  "internalType": "uint64",
                  "name": "priorityOperations",
                  "type": "uint64"
                },
                {
                  "internalType": "bytes32",
                  "name": "pendingOnchainOperationsHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                },
                {
                  "internalType": "bytes32",
                  "name": "stateHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "bytes32",
                  "name": "commitment",
                  "type": "bytes32"
                }
              ],
              "internalType": "struct Storage.StoredBlockInfo",
              "name": "_storedBlockInfo",
              "type": "tuple"
            },
            {
              "internalType": "address",
              "name": "_owner",
              "type": "address"
            },
            {
              "internalType": "uint32",
              "name": "_accountId",
              "type": "uint32"
            },
            {
              "internalType": "uint32",
              "name": "_tokenId",
              "type": "uint32"
            },
            {
              "internalType": "uint128",
              "name": "_amount",
              "type": "uint128"
            },
            {
              "internalType": "uint256[]",
              "name": "_proof",
              "type": "uint256[]"
            }
          ],
          "name": "performExodus",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint32",
              "name": "",
              "type": "uint32"
            },
            {
              "internalType": "uint16",
              "name": "",
              "type": "uint16"
            }
          ],
          "name": "performedExodus",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "components": [
                {
                  "internalType": "uint32",
                  "name": "blockNumber",
                  "type": "uint32"
                },
                {
                  "internalType": "uint64",
                  "name": "priorityOperations",
                  "type": "uint64"
                },
                {
                  "internalType": "bytes32",
                  "name": "pendingOnchainOperationsHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                },
                {
                  "internalType": "bytes32",
                  "name": "stateHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "bytes32",
                  "name": "commitment",
                  "type": "bytes32"
                }
              ],
              "internalType": "struct Storage.StoredBlockInfo[]",
              "name": "_committedBlocks",
              "type": "tuple[]"
            },
            {
              "components": [
                {
                  "internalType": "uint256[]",
                  "name": "recursiveInput",
                  "type": "uint256[]"
                },
                {
                  "internalType": "uint256[]",
                  "name": "proof",
                  "type": "uint256[]"
                },
                {
                  "internalType": "uint256[]",
                  "name": "commitments",
                  "type": "uint256[]"
                },
                {
                  "internalType": "uint8[]",
                  "name": "vkIndexes",
                  "type": "uint8[]"
                },
                {
                  "internalType": "uint256[16]",
                  "name": "subproofsLimbs",
                  "type": "uint256[16]"
                }
              ],
              "internalType": "struct ZkSync.ProofInput",
              "name": "_proof",
              "type": "tuple"
            }
          ],
          "name": "proveBlocks",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "uint32",
              "name": "_accountId",
              "type": "uint32"
            },
            {
              "internalType": "address",
              "name": "_token",
              "type": "address"
            }
          ],
          "name": "requestFullExit",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "components": [
                {
                  "internalType": "uint32",
                  "name": "blockNumber",
                  "type": "uint32"
                },
                {
                  "internalType": "uint64",
                  "name": "priorityOperations",
                  "type": "uint64"
                },
                {
                  "internalType": "bytes32",
                  "name": "pendingOnchainOperationsHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "uint256",
                  "name": "timestamp",
                  "type": "uint256"
                },
                {
                  "internalType": "bytes32",
                  "name": "stateHash",
                  "type": "bytes32"
                },
                {
                  "internalType": "bytes32",
                  "name": "commitment",
                  "type": "bytes32"
                }
              ],
              "internalType": "struct Storage.StoredBlockInfo[]",
              "name": "_blocksToRevert",
              "type": "tuple[]"
            }
          ],
          "name": "revertBlocks",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "bytes",
              "name": "_pubkey_hash",
              "type": "bytes"
            },
            {
              "internalType": "uint32",
              "name": "_nonce",
              "type": "uint32"
            }
          ],
          "name": "setAuthPubkeyHash",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "totalBlocksCommitted",
          "outputs": [
            {
              "internalType": "uint32",
              "name": "",
              "type": "uint32"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "totalBlocksExecuted",
          "outputs": [
            {
              "internalType": "uint32",
              "name": "",
              "type": "uint32"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "totalBlocksProven",
          "outputs": [
            {
              "internalType": "uint32",
              "name": "",
              "type": "uint32"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "totalCommittedPriorityRequests",
          "outputs": [
            {
              "internalType": "uint64",
              "name": "",
              "type": "uint64"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "totalOpenPriorityRequests",
          "outputs": [
            {
              "internalType": "uint64",
              "name": "",
              "type": "uint64"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "bytes",
              "name": "upgradeParameters",
              "type": "bytes"
            }
          ],
          "name": "upgrade",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "upgradeCanceled",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "upgradeFinishes",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "upgradeNoticePeriodStarted",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "upgradePreparationStarted",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "verifier",
          "outputs": [
            {
              "internalType": "contract Verifier",
              "name": "",
              "type": "address"
            }
          ],
          "payable": false,
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address payable",
              "name": "_owner",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "_token",
              "type": "address"
            },
            {
              "internalType": "uint128",
              "name": "_amount",
              "type": "uint128"
            }
          ],
          "name": "withdrawPendingBalance",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        }
      ]
"""
}
