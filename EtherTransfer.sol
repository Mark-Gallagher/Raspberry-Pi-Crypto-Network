
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ReceiveEther{

  // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendEther {
    function sendViaTransfer(address payable _eth) public payable {
        // This function is no longer recommended for sending Ether.
        _eth.transfer(msg.value);
    }

    function sendViaSend(address payable _eth) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        bool sent = _eth.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _eth) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _eth.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}