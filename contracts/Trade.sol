pragma solidity ^0.4.4;
contract Trade {
  uint public value;
  address public exporter;
  address public importer;

  enum State {Created, Locked, Inactive}

  State public state;

  function Trade() {
    exporter = msg.sender;
    value = msg.value / 2;
    if(2 * value != msg.value) throw;
  }

  modifier require(bool _condition) {
    if(!_condition) throw;
    _;
  }

  modifier onlyImporter() {
    if(msg.sender != importer) throw;
    _;
  }

  modifier onlyExporter() {
    if(msg.sender != exporter) throw;
    _;
  }

  modifier inState(State _state) {
    if(state != _state) throw;
    _;
  }

  event aborted();
  event tradeConfirmed();
  event goodReceived();

  function abort()
    onlyExporter
    inState(State.Created)
  {
    aborted();
    //exporter.sender(this.balance);
    importer.send(value);
    state = State.Inactive;
  }

  function confirmTrade()
    inState(State.Created)
    require(msg.value == 2 * value)
  {
    tradeConfirmed();
    importer = msg.sender;
    state = State.Locked;
  }

  function confirmReceived()
    onlyImporter
    inState(State.Locked)
  {
    goodReceived();
    importer.send(value);
    exporter.send(this.balance);
    //msg.sender.transfer(value);
    state = State.Inactive;
  }

  function() {
    throw;
  }
}
