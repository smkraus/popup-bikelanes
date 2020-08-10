// Load libraries
const fs = require('fs')
const {counters, data} = require('eco-counter-client')
const orgs = require('eco-counter-organisations')
const{counters:fetchCounters} = require('eco-counter-client')

var idlist = []
var datelist = []

// Get Data for single OrgIDs
const counter = fetchCounters(891)
counter.then((c) => {
  c.forEach(function(entry){
    datelist.push(entry)
    datelist.push(data(entry.organisation.id, entry.id, entry.instruments,
                        entry.periodStart, entry.periodEnd))
                      });
    return(datelist)
    })
.then((datelist) => {
  Promise.all(datelist).then((values) => {
    for(var i = 0; i < values.length; i++){
      if(i%2 == 0) {
        var cid = values[i].id
        var oid = values[i].organisation.id
        fs.writeFile('output/' + oid + '-' + cid + '.json', JSON.stringify(values[i]), function(err) {
           if (err) reject(err)
      })} else {
        fs.writeFile('output/' + cid + '.json', JSON.stringify(values[i]), function(err) {
           if (err) reject(err);
           // else resolve(data);
        });
      }
    }
  })
    .catch(console.error)
  })
.catch(console.error)


// COLLECTOR COLLECTION

// Get IDs from orgs constant
/*orgs.forEach(function(entry) {
  if(entry.hasOwnProperty("id")){
    idlist.push(entry["id"]);
  }
});
console.log(idlist)
*/
// Otherwise define idlist manually: idlist = [1,2,3,...]


// Log Org Details
/*
orgs.forEach(function(entry) {
 console.log(entry)
});
*/

// Get all counter details at once
// To Do: This can be made much easier by the example above (l.20 ff)
/*
var data_overview = []
var data_single = []

idlist.forEach(function(id){
 counters(id).then((counters) => {
   //const c = counters[0]
   counters.forEach(function(entry){
    console.log(entry);
   });
//  console.log(counters)
})
 .catch(console.error)
})
*/
/*
idlist.forEach(function(id){
 counters(id).then((counters) => {
   entrylist = []
   counters.forEach(function(entry){
    entrylist.push(entry);
   });
   return(entrylist)
})
.then((entrylist) => {
  Promise.all(entrylist).then((values) => {
    for(var i = 0; i < values.length; i++){
        var oid = values[i].organisation.id
        var cid = values[i].id
        fs.writeFile('output/' + oid + '-' + cid + '.json', JSON.stringify(values[i]), function(err) {
           if (err) reject(err);
        });
      }
    })
  .catch(console.error);
})
.catch(console.error);
})
*/

// Get all counts and dates
// To Do: This can be made much easier by the example above (l.20 ff)
/*
var resolvedList = []
// GET ALL DATE + COUNTS
idlist.forEach(function(id){
  counters(id).then((counters) => {
    //const c = counters[0]
    datelist = []
    counters.forEach(function(entry){
      datelist.push(entry)
      datelist.push(data(entry.organisation.id, entry.id, entry.instruments,
                          entry.periodStart, entry.periodEnd))
      });
    return(datelist)
  })
  .then((datelist) => {
    Promise.all(datelist).then((values) => {
      for(var i = 0; i < values.length; i++){
        if(i%2 == 0) {
          var cid = values[i].id
          var oid = values[i].organisation.id
          fs.writeFile('output/' + oid + '-' + cid + '.json', JSON.stringify(values[i]), function(err) {
             if (err) reject(err)
          // console.log(values[i]);
          // resolvedList.push(Promise.resolve(values[i]));
        })} else {
          fs.writeFile('output/' + cid + '.json', JSON.stringify(values[i]), function(err) {
             if (err) reject(err);
             // else resolve(data);
          });
          // for(var j = 0; j < values[i].length; j++){
            // console.log(values[i][j]);
            // resolvedList.push(Promise.resolve(values[i][j]));
          //}
        }
      }
    })
    .catch((error) => {
      console.log("There has been an error in the Promise.all block" +
                  " for orgid " + id + ".");
      console.error(error);
    });
  })
  .catch((error) => {
    console.log("There has been an error for oid: " + id + ".");
    console.error(error);
  });
})
//*/
