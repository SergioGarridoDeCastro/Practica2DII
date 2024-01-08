// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title Practica 2
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

/*
El ERC-20 introduce un estándar para los tokens fungibles, es decir, tienen una propiedad que hace 
que cada token sea exactamente igual (en tipo y valor) que otro token. Por ejemplo, un token ERC-20 
actúa igual que ETH, es decir, 1 token es y siempre será igual a todos los demás tokens.
*/

// https://eips.ethereum.org/EIPS/eip-20

//Importacion de la biblioteca OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/* 
Referencias:
    https://ethereum.org/es/developers/docs/standards/tokens/erc-20/ 
    https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
    https://eips.ethereum.org/EIPS/eip-20
    https://docs.openzeppelin.com/contracts/3.x/tokens#ERC20
    https://www.alchemy.com/overviews/erc20-solidity
    https://docs.openzeppelin.com/contracts/2.x/api/token/erc20 
*/

contract Practica2 is IERC20, Ownable{
    using SafeMath for uint256;

    //Atributos tipicos de tokens ERC20
    string name; 
    string symbol;
    uint8 decimals;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    //Se emite cada vez que se realiza una transferencia exitosa de tokens. Se comenta por estar incluido en IERC20.sol
    //event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //Se emite cada vez que se otorga o revoca la aprobacion para gastar tokens desde una dirección propietaria a otra que gasta.  Se comenta por estar incluido en IERC20.sol
    //event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    


    constructor(string memory _name, string memory _symbol, uint256 _decimals,  uint256 _totalSupply) Ownable(msg.sender){
        name = _name;
        symbol = _symbol;
        decimals = uint8(_decimals);
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }

    /**
    * @dev Devuelve el nombre del token
    */
    function getTokenName() public view returns (string memory){
        return name;
    }

    /**
    * @dev Devuelve el simbolo del token
    */
    function getTokenSymbol() public view returns (string memory){
        return symbol;
    }

    /**
    * @dev Devuelve los decimales que utiliza el token
    */
    function getTokenDecimals() public view returns (uint8){
        return decimals;
    }

    /**
    * @dev Numero total de tokens existentes
    */
    function getTokenTotalSupply() public view returns (uint256){
        return totalSupply;
    }

    /**
    * @dev Devuelve el saldo de otra cuenta con una direccion especifica 
    * @param owner Direccion de la cuenta
    * @return balance Un uint256 que representa el saldo de la cuenta especificada
    */
    function balanceOf(address owner) public view returns (uint256 balance){
        return balances[owner];
    }

    /**
    * @dev Transfiere la cantidad _value de tokens a la dirección _to, y debe disparar el evento Transfer.
    * La función debería lanzar un mensaje de error si el saldo de la cuenta del emisor no tiene suficientes 
    * tokens para gastar. 
    * @param to Direccion de la cuenta a la que transferir
    * @param value Cantidad de tokens a transferir
    * @return success Un bool que indica si la operacion ha sido exitosa
    */
    function transfer(address to, uint256 value) public returns (bool success){
        require(balances[msg.sender] >= value, "Valor insuficiente");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
    * @dev Transfiere la cantidad _value de tokens de la direccion _from a la dirección _to, y debe disparar el evento 
    * Transfer. La función debería lanzar un mensaje de error si el saldo de la cuenta del emisor no tiene suficientes 
    * tokens para gastar. El método transferFrom se utiliza para un flujo de trabajo de retirada, permitiendo a los 
    * contratos transferir tokens en su nombre. Esto puede usarse, por ejemplo, para permitir a un contrato transferir 
    * tokens en tu nombre y/o cobrar comisiones en submonedas.
    * @param _from Direccion de la cuenta desde la que se transfieren los tokens
    * @param _to Direccion de la cuenta a la que transferir
    * @param _value Cantidad de tokens a transferir
    * @return success Un bool que indica si la operacion ha sido exitosa
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balances[_from] >= _value, "Saldo insuficiente");
        require(allowed[_from][msg.sender] >= _value, "Allowance insuficiente");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Permite a _spender retirar de su cuenta varias veces, hasta la cantidad _value. Si se vuelve 
    * a llamar a esta función, se sobrescribe la cantidad permitida actual con _value.
    * @param _spender Direccion que retira tokens de la cuenta
    * @param _value Cantidad de tokens a retirar
    * @return success Un bool que indica si la operacion ha sido exitosa
    */
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Comprueba el importe que _spender aún puede retirar de _owner.
    * @param _owner Direccion a la que pertenecen los tokens.
    * @param _spender Direccion que gastará los tokens.
    * @return restante Un uint256 que representa la cantidad de tokens restantes.
    */
    function allowance(address _owner, address _spender) public view returns (uint256 restante){
        return allowed[_owner][_spender];
    }

}
