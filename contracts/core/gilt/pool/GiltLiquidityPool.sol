// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../../interfaces/gilt/IGVersion.sol";
import "../../../interfaces/gilt/pool/IGiltLiquidityPool.sol";
import "../../../interfaces/gilt/IGRegister.sol";
import "../../../interfaces/gilt/IGiltContract.sol";
import {Gilt} from "../../../interfaces/gilt/IGStructs.sol";

import "../../../interfaces/IVerithereum.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";


contract GiltLiquidityPool is IGiltLiquidityPool, IGVersion{

    string constant name = "RESERVED_GILT_LIQUIDITY_POOL";
    uint256 constant version = 1; 

    address immutable self;

    IGRegister register; 
    IERC20 erc20; 
    IVerithereum verithereum; 

    uint256 Interest_Rate = 10;
    uint256 Risk_Factor = 7;

    mapping(uint256=>GiltTx) giltTxById;
    mapping(uint256=>LoanTx) loanTxById; 
    mapping(uint256=>LiquidityTx) liquidityTxById;  
    mapping(address=>uint256[]) giltIdsByOwner;
    mapping(uint56=>Gilt) giltById;
    mapping(uint256=>address) ownerByGiltId;

    mapping(uint256=>bool) isCollateralByGiltId;

    
    constructor(address _register){
        register = IGRegister(_register);
        self = address(this);
        initialize(); 
    }


    function getPoolErc20() view external returns (address _erc20){
        return erc20;
    }

    function depositGilt(Gilt memory _gilt) external returns (uint256 _giltTxId){
        IERC721 erc721_ = IERC721(_gilt.giltContract);
        erc721_.transferFrom(msg.sender, self, _gilt.id);
        
        GiltVerificationProof memory proof_ = verithereum.verify(_gilt);
        require(proof_.proof != "", "missing proof");
        proofByGiltId[_gilt.id] = proof_; 
    
        _giltTxId = getIndex(); 
        giltTxById[_giltTxId] = GiltTx({ 
                                        id :_giltTxId,  
                                        gilt : gilt_,
                                        txType : "GILT DEPOSIT",
                                        date : block.timestamp
                                    });
        return _giltTxId;
    }

    function withdrawGilt(uint256 _giltTxId) external returns (uint256 _giltTxId){
        Gilt memory gilt_ = giltTxById[_giltTxId].gilt; 
        require(msg.sender == ownerByGiltId[gilt_.id], "gilt owner only "); 
        require(!isCollateralByGiltId[gilt_.id], "collateral in use");
        IERC721 erc721_ = IERC721(_gilt.giltContract);
        erc721_.transferFrom(self, msg.sender, gilt_.id);
    
        _giltTxId = getIndex(); 
        giltTxById[_giltTxId] = GiltTx({ 
                                        id :_giltTxId,  
                                        gilt : gilt_,
                                        txType : "GILT WITHDRAWAL",
                                        date : block.timestamp
                                    });
        return _giltTxId;

    }

    function getGiltTxId(uint256 _giltTxId) view external returns (GiltTx memory _giltTx){
        return giltTxById[_giltTxId];
    }

    function borrow(uint256 _amount, uint256 _giltId) external returns (uint256 _loanId){
        require(!isCollateral[_giltId], "gilt already collateral");
        
        isCollateralByGiltId[gilt_.id] = true; 
        
        Gilt memory gilt_ = giltById[_giltId];
        require(msg.sender == ownerByGiltId[_giltId], "gilt owner only");

        uint256 giltValue = valueGilt(gilt_);
        
        uint256 loanAmount_ = (giltValue * Risk_Factor)/10;
        _loanId = getIndex();
        loanById[_loanId] = Loan({  
                                    id : _loanId, 
                                    amount : loanAmount_,
                                    balance : loanAmount_,
                                    interest : Interest_Rate,
                                    date : block.timestamp, 
                                    owner : msg.sender,
                                    collateral : gilt_
                                });
        return _loanId;
    }

    function repay(uint256 _amount, uint256 _loanId) external payable returns (uint256 _loanTxId){
        Loan memory loan_ = loanById[_loanId];
        transferFunds(msg.sender, _amount, self);


    }

    function getLoan(uint256 _loanId) external returns (Loan memory _loan){
        return loanById[_loanId];
    }


    function getLiquidity(uint256 _liquidityTxId) view external returns (Liquidity memory _liquidity){
        return liquidityById[_liquidityTxId];
    }


    function getLoan(uint256 _loanId) external returns (Loan memory _loan){
        return loanById[_loanId];
    }

    function getGiltTx(uint256 _txId) view external returns (GiltTx memory _tx){
        return giltTxById[_txId];
    }

    function getLoanTx(uint256 _txId) view external returns (LoanTx memory _tx){
        return loanTxById[_txId];
    }

    function getLiquidityTx(uint256 _txId) view external returns (LiquidityTx memory _tx){
        return liquidityTxById[_txId];
    }


    function addLiquidity(uint256 _amount) external payable returns (uint256 _liquidityAddId){
        transferFunds(msg.sender, _amount, self);
        uint256 liquidityId_ = getindex(); 
        liquidityById[liquidityId_] = Liquidity ({
                                                    id      : liquidityId,
                                                    amount  : _amount, 
                                                    date    : block.timestamp,
                                                    owner   : msg.sender
                                                 });
        _liquidityAddId = getIndex(); 
        liquidityTxById[_liquidityAddId] = LiquidityTx({
                                                            id          : _liquidityAddId, 
                                                            liquidity   : liquidityById[liquidityId_], 
                                                            txType      : "LIQUIDITY ADD",
                                                            date        : block.timestamp
                                                        });
        return _liquidityAddId;
    }

    function removeLiquidity(uint256 _liquidityId) external returns (uint256 _liquidityRemovalId){
        Liquidity memory liquidity_ = liquidityById[_liquidityId];
        require(msg.sender == liquidity_.owner, "liquidity owner only");
        uint256 amount_ = calculateEarnings(liquidity_);
        transferFunds(self, amount_, msg.sender);

        _liquidityRemovalId = getIndex(); 
        liquidityTxById[_liquidityRemovalId] = LiquidityTx({
                                                            id          : _liquidityRemovalId, 
                                                            liquidity   : liquidityById[liquidityId_], 
                                                            txType      : "LIQUIDITY REMOVE",
                                                            date        : block.timestamp
                                                        });
        return _liquidityRemovalId; 
    }

    function notifyChangeOfAddress() external returns (bool _acknowledged){
        register = register.getAddress(REGISTER);
        initialize();
        return true;
    }

    //=================== INTERNAL ======================================================

    function valueGilt(Gilt memory _gilt) internal returns (uint256 value) {
        return _gilt.amount; 
    }

    function intialize() internal returns (bool _initialized){
        verithereum = IVerithereum(register.getAddress(VERITHEREUM));
        erc20 = IERC20(register.getAddress(POOL_TOEN));


        return true; 
    }

    function transferFunds(address owner, uint256 _amount, address _to) internal {

        if(erc20 == NATIVE){
            if(_to == self){
                require(msg.value >= _amount, "insufficient funds transmitted");
            }
            else{
                if(owner == self){
                    payable(_to).transfer(_amount);
                }
            }

        }
        else { 
            erc20.transferFrom(owner, _to, _amount);
        }
    }


}