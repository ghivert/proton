# Proton — Ruby Electron

Ruby Electron is an experimental work. As an open source project, it should provide a full port of [Electron](http://electron.atom.io), the perfect web desktop app framework. Some parts are currently working, but everything needs really much more work. In its current state, the small "app" is working : compiling, and running it is possible through Node.js. Detailled instructions can be found further.

## How it works ?

Ruby Electron makes its magic with help of Node.js and [Opal](http://opalrb.org). Opal is a transpiler from Ruby to JavaScript. It has few limitations like non mutable string. Otherwise it provides a full transpiler. More details can be found on the page of the project.
Providing Electron to Ruby users, Ruby Electron makes extensive use of Electron, by providing a Ruby-like library. Every functions of Electron will be supported in the future.

At the moment, nothing is automated. It is needed to write some scripts to provide a simple CLI interface.

## How to compile ?

```
cd proton-io
npm install
ruby build.rb
./node_modules/bin/electron .
```

## Remarks ?
PR are welcome. :)
"Hey guy, you're not writing tests!" I know. Proton is mainly a POC as for now, and shouldn't be used into production. If the project goes on, Spectron will probably be used.

## Licence

MIT Licence. Enjoy the work.

## Why ?

Because it's both fun and useful. Electron rocks. Ruby rocks.

Ruby + Electron = <3
