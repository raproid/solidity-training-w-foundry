// SPDX-License-Identifier: MIT

// state solidity version
pragma solidity 0.8.19;

// a simple smart contract
contract SimpleStorage {
    // Declare basic data types
    bool hasFavouriteNumber = true;
    uint256 public myFavouriteNumber;
    uint256[] listOfFavouriteNumbers;

    // declare special data types
    string favouriteNumberInText = "eightyfour";
    address myAddress = 0xB9a0c7a92fbf81400E242D28C135B47BFBa72C8B;
    bytes32 favouriteBytes = "cat";

    // create a reference types
    struct Person {
        uint256 favouriteNumber;
        string name;
    }

    // declare an empty dynamic array
    Person[] public listOfPeople;

    // declare a dict 'person's name -> their fav number'
    mapping(string => uint256) public nameToFavouriteNumber;

    // Person public myFriend = Person({favouriteNumber: 0, name: "test"});

    // access and modify the myFavouriteNumber state var
    function store(uint256 _favouriteNumber) public {
        myFavouriteNumber = _favouriteNumber;
    }

    // get the curr myFavouriteNumber value
    function retrieve() public view returns (uint256) {
        return myFavouriteNumber;
    }

    // add people to an array of people and get their fav number by their name
    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        listOfPeople.push(Person(_favouriteNumber, _name));
        nameToFavouriteNumber[_name] = _favouriteNumber;
    }
}
