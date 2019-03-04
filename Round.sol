pragma solidity ^0.4.17;

contract Round {
    
    struct Change {
        uint    votes;
        string  state;
        string  demo;
        address creator;
    }
    
    uint        roundNumber;
    bool        active = true;
    string      startState;
    string      startDemo;
    Change      Winner;
    uint        rewardAmount;
    
    Change[]    changePoolList;
    mapping(string=>Change) changePoolMap;     // change to find change info 
    address[]   voterPoolList;
    mapping(address=>string) voterPool;     // address of voter to find address of change
    
    modifier isActive(){
        require(active == true);
        _;
    }
    
    // modifier that ensures that the only party accessing this contract is the Project contract.
    
    function Round(uint roundNumberFRC, string stateFRC, string demoFRC, uint rewardAmountFRC) public payable isActive { // verify that internal works the way u think it does
        roundNumber = roundNumberFRC;
        startState = stateFRC;
        startDemo = demoFRC;
        rewardAmount = rewardAmountFRC;
    }
    
    function submitChange(string incomingState, string incomingDemo, address sender) public isActive {
        require(keccak256(incomingState) != keccak256(startState) && keccak256(incomingDemo) != keccak256(startDemo));
        Change memory incomingChange = Change({
            votes: 0,
            state: incomingState,
            demo: incomingDemo,
            creator: sender
        });
        changePoolList.push(incomingChange);
        changePoolMap[incomingState] = incomingChange;
    }
    
    function submitVote(string incomingChangeID, address sender) public isActive {       // this is the string "state" of the change
        if(keccak256(voterPool[sender]) != keccak256('')){  // if the user has voted
            changePoolMap[voterPool[sender]].votes --;      // decrease the votes of the change they voted for by one
            voterPool[sender] = incomingChangeID;           // set the vote to the incoming change
            changePoolMap[incomingChangeID].votes ++;           // increment the votes of the new change
        }
        else{
            voterPool[sender] = incomingChangeID;           // set the vote to the incoming change
            changePoolMap[incomingChangeID].votes ++;             
            voterPoolList.push(sender);
        }
    }
    
    function getWinner() public isActive {
        Change memory mostVotes;
        for(uint i = 0; i < changePoolList.length; i++){
            if(changePoolList[i].votes > mostVotes.votes){
                mostVotes = changePoolList[i];
            }
        }
        Winner = mostVotes;
        active = false;
    }
    
    function returnWinnerDemo() public view returns(string){
        return Winner.demo;
    }
    
    function returnWinnerState() public view returns(string){
        return Winner.state;
    }
      
}

