async = require('async')
_ = require('underscore')

class LookupService
  constructor:->
    @intialized = false
    @intializing = false
    @intializeCallback = []
    @modules = []

  # Asynchronous intialization
  init:(cb)=>
    if(@intialized)
      return cb and process.nextTick(cb)
    if(@intializing)
      if(cb)
        @intializeCallback.push(cb)
      return
    @intializing = true
    if(cb)
      @intializeCallback.push(cb)
    @initImpl (err)=>
      @intializing = false
      @intialized = !(err?)
      for cb in @intializeCallback
        cb(err)
        
  initImpl:(cb)=>
    @modules.push(require("./jpn"))
    ops = []
    for module in @modules
      ops.push(module.init)
    async.parallel ops,cb
    
  lookupNumber :(number,cb)=>
    unless(number)
      return cb()
    number = "#{number}" #Cast to String
    number = number.replace(/[^\d]/g,'') #Delete non number characters
    ops = []
    for module in @modules
      ops.push(module.opLookupNumber(number))
    async.parallel ops,(err,results)=>
      if(err)
        return cb(err)
      return cb(null,_.compact(results))
      
  lookupCountry :(countrycode,cb)=>
    unless(countrycode)
      return cb()
    countrycode = "#{countrycode}" #Cast to String
    countrycode = countrycode.replace(/[^\d]/g,'') #Delete non number characters
    countrycode = parseInt(countrycode)
    ops = []
    for module in @modules
      ops.push(module.opLookupCountry(countrycode))
    async.parallel ops,(err,results)=>
      if(err)
        return cb(err)
      results = _.compact(results)
      if(results.length == 0)
        return cb()
      return cb(null,results[0])
      
  lookupCarrier :(carrierid,cb)=>
    unless(carrierid)
      return cb()
    ops = []
    for module in @modules
      ops.push(module.opLookupCarrier(carrierid))
    async.parallel ops,(err,results)=>
      if(err)
        return cb(err)
      results = _.compact(results)
      if(results.length == 0)
        return cb()
      return cb(null,results[0])
    
module.exports = new LookupService()