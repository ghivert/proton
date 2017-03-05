'use strict'

/* jshint browser: true */

const ipc = require('electron').ipcRenderer
const remote = require('electron').remote
const values = null; // remote.require('./main.js').values
const doc = document.getElementById("board")

function init() {
  let robots = {
    'target': null,
    'red'   : null,
    'blue'  : null,
    'black' : null,
    'yellow': null,
    'green' : null
  }

  doc.addEventListener("load", function() {

    robots.target = doc.getElementById("target")
    robots.red    = doc.getElementById("robot-red")
    robots.blue   = doc.getElementById("robot-blue")
    robots.yellow = doc.getElementById("robot-yellow")
    robots.green  = doc.getElementById("robot-green")
    robots.black  = doc.getElementById("robot-black")

    updateWalls()
    updateGraphics(robots)
    remote.getGlobal('ready').ready = true

    robots.red.addEventListener("mousedown", function() {
      // alert('hello world!')
    }, false)
  }, false)
}

function updateGraphics(robots) {
  ipc.on('update-graphics', function(event, message) {
    robots.red.setAttributeNS(null, "visibility", "visible")
    robots.blue.setAttributeNS(null, "visibility", "visible")
    robots.yellow.setAttributeNS(null, "visibility", "visible")
    robots.green.setAttributeNS(null, "visibility", "visible")
    robots.target.setAttributeNS(null, "visibility", "visible")

    robots.red.setAttributeNS(null, "cx", (message[0] - 1) * 40 + 17.5)
    robots.red.setAttributeNS(null, "cy", (message[1] - 1) * 40 + 17.5)
    robots.blue.setAttributeNS(null, "cx", (message[2] - 1) * 40 + 17.5)
    robots.blue.setAttributeNS(null, "cy", (message[3] - 1) * 40 + 17.5)
    robots.yellow.setAttributeNS(null, "cx", (message[4] - 1) * 40 + 17.5)
    robots.yellow.setAttributeNS(null, "cy", (message[5] - 1) * 40 + 17.5)
    robots.green.setAttributeNS(null, "cx", (message[6] - 1) * 40 + 17.5)
    robots.green.setAttributeNS(null, "cy", (message[7] - 1) * 40 + 17.5)
    robots.target.setAttributeNS(null, "x", (message[8] - 1) * 40)
    robots.target.setAttributeNS(null, "y", (message[9] - 1) * 40)
    switch(message[10]) {
      case 'B':
      robots.target.setAttributeNS(null, "fill", "blue")
      break
      case 'R':
      robots.target.setAttributeNS(null, "fill", "red")
      break
      case 'V':
      robots.target.setAttributeNS(null, "fill", "green")
      break
      case 'J':
      robots.target.setAttributeNS(null, "fill", "yellow")
      break
    }
  })
}

function updateWalls() {
  ipc.on('update-walls', function(event, message) {
    var aLine = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    aLine.setAttribute('x1', message[0])
    aLine.setAttribute('y1', message[1])
    aLine.setAttribute('x2', message[2])
    aLine.setAttribute('y2', message[3])
    aLine.setAttribute('stroke', 'rgb(0,0,0)')
    aLine.setAttribute('stroke-width', 10)
    doc.appendChild(aLine)
  })
}

function opponents() {
  let players = document.getElementById('players')
  ipc.on('add-opponent', function(event, message) {
    let li = document.createElement("li")
    li.appendChild(document.createTextNode(message))
    li.setAttribute('class', 'sub')
    players.appendChild(li)
  })

  ipc.on('delete-opponent', function(event, message) {
    for (let node in players.childNodes)
      if (node.textContent === message)
        players.removeChild(node)
  })

  ipc.on('chat', function(event, message) {
    let chat = document.getElementById('chatBox')
    chat.innerHTML = chat.innerHTML + message[0] + " : " + message[1] + "<br>"
    chat.scrollTop = chat.scrollHeight;
  })

  ipc.on('update-score', function(event) {
    let temp = []
    for (let node = 1; node < players.childNodes.length; node++) {
      temp.push(players.childNodes[node].textContent.split(' ')[0])
      players.removeChild(players.childNodes[node])
    }

    for (let name in temp) {
      let li = document.createElement("li")
      li.appendChild(document.createTextNode(temp[name] + " " + values.opponents[temp[name]]))
      li.setAttribute('class', 'sub')
      players.appendChild(li)
    }
  })

  ipc.on('echec', function (event, message) {
    alert("Enchère non prise en compte, en conflit avec " + message)
  })

  ipc.on('nouvelle-enchere', function (event, message) {
    alert("Enchère de " + message[0] + " de " + message[1] + " coups.")
  })

  ipc.on('fin-enchere', function (event, message) {
    if (message[0] === null)
      alert('Fin des enchères. Aucun gagnant.')
    else
      alert("Fin des enchères. Main à " + message[0] + " en " + message[1] + " coups.")
  })

  ipc.on('sa-solution', function (event, message) {
    alert("Solution proposée : " + message)
  })

  ipc.on('bonne', () => {
    alert("Solution valide.")
  })

  ipc.on('mauvaise', function(event, message) {
    alert("Solution invalide. Main à " + message + ".")
  })

  ipc.on('trop-long', function(event, message) {
    if (message === null)
      alert("Trop de temps à répondre, nouveau tour.")
    else
      alert("Trop de temps à répondre. Main à " + message + ".")
  })

  ipc.on('il-a-trouve', function(event, message) {
    alert("Solution proposée par " + message[0] + " en " + message[1] + " coups.")
  })

  ipc.on('fin-reflexion', function(event, message) {
    alert('Fin de la période de réflexion. Début des enchères.')
  })
}

function updateChat() {
  let chat = document.getElementById('chatField')
  let text = chat.value
  chat.value = ''
  values.client.write('CHAT/' + values.user + '/' + text + '/')
}

function updateField(event) {
  if (event.keyCode === 13) {
    updateChat()
  }
}

function updateBidding(event) {
  if (values.state === "REFLEXION")
    if (event.keyCode === 13) {
      let bid = document.getElementById('bid')
      values.client.write('SOLUTION/' + values.user + '/' + bid.value + '/')
      delete bid.value
    }
  else if (values.state === "ENCHERES")
    if (event.keyCode === 13) {
      let bid = document.getElementById('bid')
      values.client.write('ENCHERE/' + values.user + '/' + bid.value + '/')
      delete bid.value
    }
}

var activeRobot = null

function redActive() {
  activeRobot = "R"
}
function yellowActive() {
  activeRobot = "J"
}
function greenActive() {
  activeRobot = "V"
}
function blueActive() {
  activeRobot = "B"
}

var solutionArray = []

function solution(button) {
  if (values.state !== "SOLUTION") return
  if (activeRobot === null) return

  switch(button.id) {
    case "orient-button-north":
    solutionArray.push(activeRobot + "H")
    break
    case "orient-button-south":
    solutionArray.push(activeRobot + "B")
    break
    case "orient-button-west":
    solutionArray.push(activeRobot + "G")
    break
    case "orient-button-east":
    solutionArray.push(activeRobot + "D")
    break
  }

  console.log(solutionArray);
}

function toString(array) {
  let string = ""
  console.log(array);
  for (var ind in array)
    string += array[ind]
  console.log(string);

  return string
}

function sendSolution() {
  if (values.state === "SOLUTION") {
    values.client.write("SOLUTION/" + values.user + "/" + toString(solutionArray) + "/")
    solutionArray = []
  }
}

init()
opponents()
