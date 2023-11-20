// SPDX-Liscense-Identifier: MIT
pragma solidity ^0.8.0;

import { IAccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControlProxy} from "@openzeppelin/contracts/proxy/AccessControlProxy.sol";
import {IAccessControlProxy} from "@openzeppelin/contracts/proxy/IAccessControlProxy.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {AccessControlProxyUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/AccessControlProxyUpgradeable.sol";
import {IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";      
import {IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

contract MockCurator is Ownable, IAccessControl {
    bytes32 public constant CURATOR_ROLE = keccak256("CURATOR_ROLE");

    error NO_AC_INITIATOR();
    
    address public acInitiator;
    address public accessControlProxy;
    address public curatorAccess;

    function setAcInitiator(address _acInitiator) public onlyOwner returns (address){
        bytes memory accessControlInitiator = abi.encodeWithSelector(
        IAccessControl.grantRole.selector, CURATOR_ROLE, _acInitiator);
        accessControlProxy = new AccessControlProxy(address(this), accessControlInitiator);
        return(curatorAccess, accessControlProxy);
        acInitiator = _acInitiator;
    }

    constructor() {
        _setupRole(CURATOR_ROLE, msg.sender);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return role == CURATOR_ROLE && account == owner();
    }

    function grantRole(bytes32 role, address account) public override {
        require(role == CURATOR_ROLE, "MockCurator: invalid role");
        require(account != address(0), "MockCurator: zero address");
        _setupRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override {
        require(role == CURATOR_ROLE, "MockCurator: invalid role");
        require(account != address(0), "MockCurator: zero address");
        _revokeRole(role, account);
    }
    struct accessLevelInfo {
        IERC721 curatorAccess;
        IERC721 adminAccess;
        IERC721 moderatorAccess;
        IERC721 userAccess;
    }
    string public constant name = "Access Level Registry";//ERC721 AccessControl 

    mapping (address => accessLevelInfo) public accessLevelRegistry;//AccessNFTsMapping

    /////WRITE FUNCIOTNS/////
    function setCuratorAccess(address _curatorAccess) public onlyOwner returns (address){
        accessLevelRegistry[msg.sender].curatorAccess = IERC721(_curatorAccess);
        return accessLevelRegistry[msg.sender].curatorAccess;
    }
    function setAdminAccess(address _adminAccess) public onlyOwner returns (address){
        accessLevelRegistry[msg.sender].adminAccess = IERC721(_adminAccess);
        return accessLevelRegistry[msg.sender].adminAccess;
    }
    function setModeratorAccess(address _moderatorAccess) public onlyOwner returns (address){
        accessLevelRegistry[msg.sender].moderatorAccess = IERC721(_moderatorAccess);
        return accessLevelRegistry[msg.sender].moderatorAccess;
    }

    function setUserAccess(address _userAccess) public onlyOwner returns (address){
        accessLevelRegistry[msg.sender].userAccess = IERC721(_userAccess);
        return accessLevelRegistry[msg.sender].userAccess;
    }

}
