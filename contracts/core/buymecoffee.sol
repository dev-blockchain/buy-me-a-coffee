// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


// Import the UsingWitnet library that enables interacting with Witnet
import "https://raw.githubusercontent.com/witnet/witnet-ethereum-bridge/master/contracts/UsingWitnet.sol";
// Import the BitcoinPrice request that you created before
import "randomNumber.sol";

// Your contract needs to inherit from UsingWitnet
contract buymeCup is UsingWitnet {

    using Witnet for Witnet.Result;



    // Organization that wants to receive the funds
    struct Organization {
        string name;
        string description;
        bool isFunded; // is organization funded
        uint256 target; // target funding in wei (1 ether = 10^18 wei)
        address owner; // Owner of the ngo
        uint256 funds;
    }

    uint256 public organizationId;

    // mapping of organizationId to Organization object
    mapping(uint256 => Organization) public organizations;

    // Details of a particular funding
    struct Funding {
        uint256 organizationId;
        uint256 fundAmount;
        address user;
    }

    uint256 public fundingId;

    // mapping of fundingId to Funding object
    mapping(uint256 => Funding) public fundings;

    // This event is emitted when a new organization is put up for funding
    event NewOrganization (
        uint256 indexed organizationId
    );

    // This event is emitted when a NewFunding is made
    event NewFunding (
        uint256 indexed organizationId,
        uint256 indexed fundingId
    );


    uint64 public newNumber;

    /*
   * Token name.
   */
    string internal tokenName;

    /*
     * Token symbol.
     */
    string internal tokenSymbol;

    /*
     * Number of decimals.
     */
    uint8 internal tokenDecimals;

    /*
     * Total supply of tokens.
     */
    uint256 internal tokenTotalSupply;

    /*
     * Balance information map.
     */
    mapping (address => uint256) internal balances;

    /*
     * Token allowance mapping.
     */
    mapping (address => mapping (address => uint256)) internal allowed;

    /*
     * @dev Trigger when tokens are transferred, including zero value transfers.
     */
    event Transfer(address indexed _from,address indexed _to,uint256 _value);

    /*
     * @dev Trigger on any successful call to approve(address _spender, uint256 _value).
     */
    event Approval(address indexed _owner,address indexed _spender,uint256 _value);

    /*
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory _name){
        _name = tokenName;
    }

    /*
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory _symbol){
        _symbol = tokenSymbol;
    }

    /*
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() external view returns (uint8 _decimals){
        _decimals = tokenDecimals;
    }

    /*
     * @dev Returns the total token supply.
     */
    function totalSupply()external view returns (uint256 _totalSupply){
        _totalSupply = tokenTotalSupply;
    }

    /*
     * @dev Returns the account balance of another account with address _owner.
     * @param _owner The address from which the balance will be retrieved.
     */
    function balanceOf(address _owner) external view returns (uint256 _balance){
        _balance = balances[_owner];
    }

    /*
     * @dev Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. The
     * function SHOULD throw if the "from" account balance does not have enough tokens to spend.
     * @param _to The address of the recipient.
     * @param _value The amount of token to be transferred.
     */
    function transfer(address payable _to, uint256 _value) public returns (bool _success){
        require(balances[msg.sender]>=_value, "error: insufficient funds");
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        _success = true;
    }

    /*
     * @dev Allows _spender to withdraw from your account multiple times, up to the _value amount. If
     * this function is called again it overwrites the current allowance with _value. SHOULD emit the Approval event.
     * @param _spender The address of the account able to transfer the tokens.
     * @param _value The amount of tokens to be approved for transfer.
     */
    function approve(address _spender,uint256 _value) public returns (bool _success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        _success = true;
    }

    /*
     * @dev Returns the amount which _spender is still allowed to withdraw from _owner.
     * @param _owner The address of the account owning tokens.
     * @param _spender The address of the account able to transfer the tokens.
     */
    function allowance(address _owner,address _spender) external view returns (uint256 _remaining){
        _remaining = allowed[_owner][_spender];
    }

    /*
     * @dev Transfers _value amount of tokens from address _from to address _to, and MUST fire the
     * Transfer event.
     * @param _from The address of the sender.
     * @param _to The address of the recipient.
     * @param _value The amount of token to be transferred.
     */
    function transferFrom(address _from,address _to,uint256 _value) public returns (bool _success){
        require(balances[_from]>=_value);
        require(allowed[_from][msg.sender]>=_value);
        balances[_from] = balances[_from] - _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        _success = true;
    }


    uint256 public lastRequestId;


    uint256 public timestamp;


    bool public pending;

    // The Witnet request object, is set in the constructor
    Request public request;

    // Emits when the price is updated
    event PriceUpdated(uint64);

    // Emits when found an error decoding request result
    event ResultError(string);
    uint64 public lastPrice;
    // This constructor does a nifty trick to tell the `UsingWitnet` library where
    // to find the Witnet contracts on whatever Ethereum network you use.
    constructor (address _wrb) UsingWitnet(_wrb) {
        // Instantiate the Witnet request
        request = new randomNumberRequest();
    }

    /**
     * @notice Sends `request` to the WitnetRequestBoard.
     * @dev This method will only succeed if `pending` is 0.
     **/
    function requestUpdate() public payable {
        require(!pending, "Complete pending request before requesting a new one");

        // Send the request to Witnet and store the ID for later retrieval of the result
        // The `witnetPostRequest` method comes with `UsingWitnet`
        lastRequestId = witnetPostRequest(request);

        // Signal that there is already a pending request
        pending = true;
    }

    /**
     * @notice Reads the result, if ready, from the WitnetRequestBoard.
     * @dev The `witnetRequestAccepted` modifier comes with `UsingWitnet` and allows to
     * protect your methods from being called before the request has been successfully
     * relayed into Witnet.
     **/
    function completeUpdate() public witnetRequestResolved(lastRequestId) {
        require(pending, "There is no pending update.");

        // Read the result of the Witnet request
        // The `witnetReadResult` method comes with `UsingWitnet`
        Witnet.Result memory result = witnetReadResult(lastRequestId);

        // If the Witnet request succeeded, decode the result and update the price point
        // If it failed, revert the transaction with a pretty-printed error message
        if (result.isOk()) {
            lastPrice = result.asUint64();
            timestamp = block.timestamp;
            emit PriceUpdated(lastPrice);
        } else {
            string memory errorMessage;

            // Try to read the value as an error message, catch error bytes if read fails
            try result.asErrorMessage() returns (Witnet.ErrorCodes, string memory e) {
                errorMessage = e;
            }
            catch (bytes memory errorBytes){
                errorMessage = string(errorBytes);
            }
            emit ResultError(errorMessage);
        }

        // In any case, set `pending` to false so a new update can be requested
        pending = false;
    }
}
