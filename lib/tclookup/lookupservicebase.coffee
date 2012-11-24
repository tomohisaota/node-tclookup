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
    
  opLookupNumber :(internationalNumber)=>
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
          # clone. Sorry for lazy impl :-)
          result = JSON.parse(JSON.stringify(@carrierDict[carrierId]))
          return cb(null,result)
      return cb()

  opLookupCountry :(countrycode)=>
    return (cb)=>
      if(countrycode != @countryCode)
        return cb()
      result = {
        countrycode : @countryCode
        countrycodeRef : @countryCode
      }
      result.info = {
        
      }
      carriers = {}
      for carrierid,carrier of @carrierDict
        carriers[carrierid] = {
          carrierid : carrierid
        }
      result.refs = {}
      result.refs.carriers = carriers
      return cb(null,result)

  opLookupCarrier :(carrierid)=>
    return (cb)=>
      handler = (carrierid,carrier,cb)=>
        result = {
          carrierid : carrierid
          carrieridRef : carrierid
        }
        result.info = {
          name : carrier.name
        }
        result.refs = {}
        result.refs.countries = {}
        result.refs.countries[@countryCode]={
          countrycode : @countryCode
          countrycodeRef : @countryCode
        }
        result.refs.numbers = {}
        for key,value of @numberDict
          continue if(carrierid != value)
          internationalNumber = @toInternationalNumber(key)
          result.refs.numbers[internationalNumber]={
            number : internationalNumber
            numberRef : internationalNumber
          }
        return cb(null,result)
        
      for key,value of @carrierDict
        if(key == carrierid)
          return handler(key,value,cb)
      return cb()

  initCarrier :(cb)=>
    throw new Error("Abstract method")

  initData :(cb)=>
    throw new Error("Abstract method")

  toLocalNumber : (internationalNumber)=>
    throw new Error("Abstract method")

  toInternationalNumber : (localNumber)=>
    throw new Error("Abstract method")
