fs = require('fs')

LookupServiceBase = require("../lookupservicebase").LookupServiceBase

class JapanLookupService extends LookupServiceBase
  
  constructor:->
    super(81)
    @keyToId = {}
  
  initCarrier:(cb)=>
    fs.readFile "#{__dirname}/carrier.json", (err, data)=>
      if(err)
        return cb(err)
      dict = JSON.parse(data.toString())
      for key,description of dict
        @keyToId[key] = description.carrierid
        @registerCarrier(description.carrierid,description)
      return cb()

  initData:(cb)=>
    fs.readFile "#{__dirname}/data.txt", (err, data)=>
      if(err)
        return cb(err)
      lines = data.toString().split(/\r?\n/)
      for line in lines
        items = line.split(/\t/)
        pre = items.shift()
        for i,key of items
          @registerNumber("#{pre}#{i}",@keyToId[key])
      return cb()

  toLocalNumber : (internationalNumber)=>
    return "0"+internationalNumber.substring(@countryCodeStr.length)
        
  toInternationalNumber : (localNumber)=>
    return @countryCodeStr+localNumber.substring(1)

module.exports = new JapanLookupService()