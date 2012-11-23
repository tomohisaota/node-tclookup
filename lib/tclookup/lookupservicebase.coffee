async = require('async')

module.exports.LookupServiceBase = class
  constructor:(countryCode)->
    @minlength = Number.MAX_VALUE
    @maxlength = 0
    @numberDict = {}
    @carrierDict = {}
    @countryCode = countryCode
    @countryCodeStr = "#{countryCode}"
  
  init :(cb)=>
    async.series([@initCarrier,@initData],cb)
  
  isTarget : (internationalNumber)=>
    return (internationalNumber.indexOf(@countryCodeStr) == 0)

  registerCarrier : (carrierId,description)=>
    @carrierDict[carrierId] = description

  registerNumber : (code,carrierId)=>
    unless(carrierId)
      return
    unless(@carrierDict[carrierId])
      throw new Error("Carrier id=#{carrierId} is not registered")
    @numberDict[code] = carrierId
    @minlength = Math.min(code.length,@minlength)
    @maxlength = Math.max(code.length,@maxlength)
    
  opLookup :(internationalNumber)=>
    return (cb)=>
      unless(@isTarget(@countryCodeStr))
        return cb()
      #Delete country code, and add domestic prefix
      number = @toLocalNumber(internationalNumber)
      if(number.length < @minlength)
        return cb()
      for matchLength in [Math.min(@maxlength,number.length)..@minlength]
        subnumber = number.substring(0,matchLength)
        carrierId = @numberDict[subnumber]
        if(carrierId)
          result = {
            countrycode : @countryCode
            carrier : @carrierDict[carrierId]
          }
          return cb(null,result)
      return cb()

  initCarrier :(cb)=>
    throw new Error("Abstract method")

  initData :(cb)=>
    throw new Error("Abstract method")

  toLocalNumber : (internationalNumber)=>
    throw new Error("Abstract method")
