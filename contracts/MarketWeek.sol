pragma solidity 0.5.7;

import "./Market.sol";

contract MarketWeekly is Market {

    function initiate(
     uint[] memory _uintparams,
     string memory _feedsource,
     address payable[] memory _addressParams
    ) 
    public
    payable
    {
      super.initiate(_uintparams, _feedsource, _addressParams);
      expireTime = startTime + 1 weeks;
      betType = uint(IPlotus.MarketType.WeeklyMarket);
      _oraclizeQuery(expireTime, "json(https://financialmodelingprep.com/api/v3/majors-indexes/.DJI).price", "", 0);
    }

    function getPrice(uint _prediction) public view returns(uint) {
      return optionPrice[_prediction];
    }

    function setPrice(uint _prediction) public {
      optionPrice[_prediction] = _calculateOptionPrice(_prediction);
    }

    function _calculateOptionPrice(uint _option) internal view returns(uint _optionPrice) {
      _optionPrice = 0;
      if(address(this).balance > 20 ether) {
        _optionPrice = (optionsAvailable[_option].ethStaked).mul(10000)
                      .div((address(this).balance).mul(40));
      }

      uint timeElapsed = now - startTime;
      timeElapsed = timeElapsed > 28 hours ? timeElapsed: 28 hours;
      _optionPrice = _optionPrice.add(
              (6 - _getDistance(_option)).mul(10000).mul(timeElapsed.div(1 hours))
             )
             .div(
              360 * 24 * 7
             );
    }
}
