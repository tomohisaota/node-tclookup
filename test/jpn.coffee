chai = require("chai")

describe "intialize",->
  it "can intialize",(done)->
    tclookup = require("../lib/tclookup")
    tclookup.init(done)
    
describe "lookup",->
  it "can process docomo number",->
    tclookup = require("../lib/tclookup")
    tclookup.init (err)->
      chai.expect(err).to.not.exist
      tclookup.lookup '8190 8850 0000',(err,results)->
        chai.expect(err).to.not.exist
        chai.expect(results.length).equals(1)
        result = results[0]
        chai.expect(result.countrycode).equals(81)
        chai.expect(result.carrier.carrierid).equals("EFF10FFA-9A30-4D50-9A4B-04C2C19E1953")
        
  it "can process au number",->
    tclookup = require("../lib/tclookup")
    tclookup.init (err)->
      chai.expect(err).to.not.exist
      tclookup.lookup '818090100000',(err,results)->
        chai.expect(err).to.not.exist
        chai.expect(results.length).equals(1)
        result = results[0]
        chai.expect(result.countrycode).equals(81)
        chai.expect(result.carrier.carrierid).equals("CAC83B8E-5C91-4FC5-8B1F-9CD8710FD566")