// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

/**
 * @dev Example contract which perform all the computation in `performUpkeep`
 * @notice important to implement {AutomationCompatibleInterface}
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract BalancerOnChain is AutomationCompatibleInterface {
    uint256 public constant SIZE = 1000;
    uint256 public constant LIMIT = 1000;
    uint256[SIZE] public balances;
    uint256 public liquidity = 1000000;

    constructor() {
        // On the initialization of the contract, all the elements have a balance equal to the limit
        for (uint256 i = 0; i < SIZE; i++) {
            balances[i] = LIMIT;
        }
    }

    /// @dev called to increase the liquidity of the contract
    function addLiquidity(uint256 liq) public {
        liquidity += liq;
    }

    /// @dev withdraw an `amount`from multiple elements of `balances` array. The elements are provided in `indexes`
    function withdraw(uint256 amount, uint256[] memory indexes) public {
        for (uint256 i = 0; i < indexes.length; i++) {
            require(indexes[i] < SIZE, "Provided index out of bound");
            balances[indexes[i]] -= amount;
        }
    }

    /// @dev this method is called by the Automation Nodes to check if `performUpkeep` should be performed
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = false;
        for (uint256 i = 0; i < SIZE && !upkeepNeeded; i++) {
            if (balances[i] < LIMIT) {
                // if one element has a balance < LIMIT then rebalancing is needed
                upkeepNeeded = true;
            }
        }
        return (upkeepNeeded, "");
    }

    /// @dev this method is called by the Automation Nodes. it increases all elements which balances are lower than the LIMIT
    function performUpkeep(bytes calldata /* performData */) external override {
        uint256 increment;
        uint256 _balance;
        for (uint256 i = 0; i < SIZE; i++) {
            _balance = balances[i];
            // best practice: reverify the upkeep is needed
            if (_balance < LIMIT) {
                // calculate the increment needed
                increment = LIMIT - _balance;
                // decrease the contract liquidity accordingly
                liquidity -= increment;
                // rebalance the element
                balances[i] = LIMIT;
            }
        }
    }
}
pragma solidity ^0.8.6;

// UpkeepIDConsumerExamplev1.sol imports functions from both ./AutomationRegistryInterface1_2.sol and
// ./interfaces/LinkTokenInterface.sol

import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

interface KeeperRegistrarInterface {
    function register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source,
        address sender
    ) external;
}

contract UpkeepIDConsumerExamplev1 {
    LinkTokenInterface public immutable i_link;
    address public immutable registrar;
    AutomationRegistryInterface public immutable i_registry;
    bytes4 registerSig = KeeperRegistrarInterface.register.selector;

    constructor(
        LinkTokenInterface _link,
        address _registrar,
        AutomationRegistryInterface _registry
    ) {
        i_link = _link;
        registrar = _registrar;
        i_registry = _registry;
    }

    function registerAndPredictID(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source
    ) public {
        (State memory state, , ) = i_registry.getState();
        uint256 oldNonce = state.nonce;
        bytes memory payload = abi.encode(
            name,
            encryptedEmail,
            upkeepContract,
            gasLimit,
            adminAddress,
            checkData,
            amount,
            source,
            address(this)
        );

        i_link.transferAndCall(
            registrar,
            amount,
            bytes.concat(registerSig, payload)
        );
        (state, , ) = i_registry.getState();
        uint256 newNonce = state.nonce;
        if (newNonce == oldNonce + 1) {
            uint256 upkeepID = uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        address(i_registry),
                        uint32(oldNonce)
                    )
                )
            );
            // DEV - Use the upkeepID however you see fit
        } else {
            revert("auto-approve disabled");
        }
    }
}