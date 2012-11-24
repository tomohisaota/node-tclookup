express = require 'express'

tcLookup = require('./tclookup')

app = express.createServer()

app.use express.bodyParser()
app.use express.methodOverride()
app.use require("connect-assets")(src : __dirname+"/assets")
app.set("views", __dirname + "/views")
app.set('view engine', 'jade')
app.use express.static(__dirname + '/public')
app.use app.router

# Routes
#routes.loadRoute app

app.get "/api/v1/number/:number.:type", (req, res) ->  
  tcLookup.lookupNumber req.params.number,(err,results)->
    addRef(results,getApiBaseUrl(req))
    res.render 'number',{
      result : results, 
      resultStr : linkify(JSON.stringify(results,null," "))
    }

app.get "/api/v1/number/:number", (req, res) ->  
  res.redirect req.url+".html"

app.get "/api/v1/carrier/:carrierid.:type", (req, res) ->  
  tcLookup.lookupCarrier req.params.carrierid,(err,results)->
    addRef(results,getApiBaseUrl(req))
    res.render 'number',{
      result : results, 
      resultStr : linkify(JSON.stringify(results,null," "))
    }

app.get "/api/v1/carrier/:carrierid", (req, res) ->  
  res.redirect req.url+".html"

app.get "/api/v1/country/:countrycode.:type", (req, res) ->  
  tcLookup.lookupCountry req.params.countrycode,(err,results)->
    addRef(results,getApiBaseUrl(req))
    res.render 'number',{
      result : results, 
      resultStr : linkify(JSON.stringify(results,null," "))
    }
    
app.get "/api/v1/country/:countrycode", (req, res) ->  
  res.redirect req.url+".html"

app.get "/", (req, res) ->  
   res.render 'index'

port = process.env.PORT or 8080
tcLookup.init (err)->
  app.listen port, -> 
    console.log "Listening on port " + port

getFullUrl = (req)->
  return req.protocol + '://' + req.headers.host  + req.path

getApiBaseUrl = (req)->
  path = req.path
  path = path.replace(/\/[^\/]+\/[^\/]+$/,"")
  return req.protocol + '://' + req.headers.host  + path

addRef = (obj,apiBaseUrl)->
  for key,value of obj
    if(value instanceof Object)
      addRef(value,apiBaseUrl)
    else
      if(key == "countrycode")
        obj.countrycodeRef = "#{apiBaseUrl}/country/#{value}"
      if(key == "carrierid")
        obj.carrieridRef = "#{apiBaseUrl}/carrier/#{value}"
      if(key == "number")
        obj.numberRef = "#{apiBaseUrl}/number/#{value}"

linkify = (str)->
  unless(str)
    return str
  return str.replace(/(\bhttps?:\/\/[-A-Za-z0-9+&@#\/%?=~_\(\)|!:,.;]*[-A-Za-z0-9+&@#\/%=~_|])/g,"<a href=\"$1\">$1</a>")