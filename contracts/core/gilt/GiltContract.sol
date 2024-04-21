// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../interfaces/gilt/IGVersion.sol";
import "../../interfaces/gilt/IGRegister.sol";
import "../../interfaces/gilt/IGiltVault.sol";
import "../../interfaces/gilt/IGVaultFactory.sol";
import "../../interfaces/gilt/IGiltContract.sol";
import "../../interfaces/gilt/IGAttestationManager.sol";

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import { GiltLiquidation} from "../../interfaces/gilt/IGStructs.sol";

/// @custom:security-contact blockstarlogic@gmail.com
contract GiltContract is IGVersion, IGiltContract, ERC721, ERC721Pausable {
    uint256 private _nextGiltId;
    string constant vname = "RESERVED_GILT_CONTRACT";
    uint256 constant version = 1; 
    address constant NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address immutable self; 

    modifier adminOnly() { 
        require(msg.sender == register.getAddress(GILT_ADMIN), "admin only");
        _;
    }

    string constant GILT_ADMIN = "RESERVED_GILT_ADMIN";
    string constant ATTESTATION_MANAGER = "RESERVED_ATTESTATION_MANAGER";

    string constant GILT_REGISTER = "RESERVED_GILT_REGISTER";
    string constant VAULT_FACTORY = "RESERVED_VAULT_FACTORY";
    string constant CHAIN_ID = "RESERVED_CHAIN_ID";
    

    IGRegister register; 
    IGVaultFactory factory; 
    IGAttestationManager attestations; 

    uint256 [] giltIds;
    mapping(uint256=>Gilt) giltById;
    mapping(uint256=>address) vaultByGiltId;

    mapping(uint256=>GiltLiquidation) liquidationById; 

    constructor(address _register)ERC721("Gilt", "GILT"){
        register = IGRegister(_register);
        self = address(this);
        initialize(); 
    }

    function getName() pure external returns (string memory _name) {
        return vname; 
    }

    function getVersion() pure external returns (uint256 _version) {
        return version; 
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gilt.blockstarlogic.xyz";
    }

    function pause() public adminOnly {
        _pause();
    }

    function unpause() public adminOnly {
        _unpause();
    }

    function getGiltIds() view external returns (uint256 [] memory _ids){
        return giltIds; 
    }

    function getLiquidation(uint256 _liquidationId) view external returns (GiltLiquidation memory _liquidation){
        return liquidationById[_liquidationId];
    }

    function getGilt(uint256 _id) view external returns (Gilt memory _gilt){
        return giltById[_id];
    }

    function getGiltVault(uint256 _giltId) view external returns (address _giltVault){
        return vaultByGiltId[_giltId];
    }
    
    function mintGilt(ProtoGilt memory _protoGilt) external payable returns (uint256 _giltId){
        _giltId = _nextGiltId++;

        giltById[_giltId] = Gilt({
                                    id : _giltId,
                                    erc20 : _protoGilt.erc20,  
                                    amount : _protoGilt.amount, 
                                    giltContract : self,  
                                    createDate : block.timestamp, 
                                    chainId : register.getNValue(CHAIN_ID),
                                    status : "ACTIVE",
                                    attestationId : 0
                                });
        address vault_ = factory.getGiltVault();
        IGiltVault giltVault_ = IGiltVault(vault_);
        if(_protoGilt.erc20 == NATIVE){
            require(msg.value >= _protoGilt.amount, "insufficient funds transmitted");
            giltVault_.deposit{value : _protoGilt.amount}(giltById[_giltId]);
        }
        else {
           IERC20 erc20_ = IERC20(_protoGilt.erc20);
            erc20_.transferFrom(msg.sender, self, _protoGilt.amount);
             
            erc20_.approve(vault_, _protoGilt.amount);
            giltVault_.deposit(giltById[_giltId]);
        }
        uint256 attestationId_ = attestations.issueAttestation(giltById[_giltId], vault_);
        giltById[_giltId].attestationId = attestationId_;

        _safeMint(msg.sender, _giltId);
        return _giltId; 
    }

    function liquidateGilt(uint256 _giltId, address _to) external returns (uint256 _liquidationId){
        require(msg.sender == ownerOf(_giltId), "only Gilt owner can liquidate");
        _liquidationId = getIndex();
        transferFrom(msg.sender,self, _giltId);
        IGiltVault vault_ = IGiltVault(vaultByGiltId[_giltId]);
        
        attestations.revoke(giltById[_giltId].attestationId);
        giltById[_giltId].status = "LIQUIDATED";
        _burn(_giltId);
        vault_.withdraw();
        IERC20 erc20_ = IERC20(giltById[_giltId].erc20); 

        if(giltById[_giltId].erc20 == NATIVE) {
            payable(_to).transfer(giltById[_giltId].amount);
        }
        else {
            erc20_.transferFrom(vaultByGiltId[_giltId], self, giltById[_giltId].amount );
            erc20_.transfer(_to, giltById[_giltId].amount);
        }
        liquidationById[_liquidationId] = GiltLiquidation({
                                                                id  : getIndex(),
                                                                gilt : giltById[_giltId],
                                                                liquidationDate : block.timestamp,
                                                                recipient : _to
                                                            });

        return _liquidationId;
    }

    function notifyChangeOfAddress() external adminOnly returns (bool _acknowledged) {
        register = IGRegister(register.getAddress(GILT_REGISTER));
        initialize(); 
        return true; 
    }

    //============================ INTERNAL ===================================================

    // The following functions are overrides required by Solidity.

    uint256 index;
    function getIndex() internal returns (uint256 _index) {
        _index = index++;
        return _index; 
    }

    function initialize() internal { 
        factory = IGVaultFactory(register.getAddress(VAULT_FACTORY));
        attestations = IGAttestationManager(register.getAddress(ATTESTATION_MANAGER));
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
}
