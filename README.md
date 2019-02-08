# Proton — Ruby Electron — Desktop app using Ruby and Node!

Ruby Electron is an experimental work. As an open source project, it should provide a full port of [Electron](https://electronjs.org), the perfect web desktop app framework. Some parts are currently working, but everything needs more work. As time is passing, more and more features will be added, and examples will be provided in the future. [They can be found here](https://github.com/ghivert/proton-sample-apps).

Right now, Proton can be bundled as a gem, but is not purposefully. It is still at a really early stage, and eveything can change or break previous code at any moment. When stable, Proton will be released on RubyGems.

## How does it work ?

Ruby Electron makes its magic with help of Node.js and [Opal](http://opalrb.com). Opal is a transpiler from Ruby to JavaScript. It has few limitations like non mutable string. Otherwise it provides a full transpiler. More details can be found on the page of the project.
Providing Electron to Ruby users, Proton makes extensive use of Electron, by providing a Ruby-like library.

## How to compile ?

```
git clone https://github.com/ghivert/proton.git
cd proton
gem build proton.gemspec
gem install ./proton-0.1.0.gem
```

## How can I use it ?

Once you cloned and locally installed the gem, you can simple use `proton main.rb` on a correct file (see the examples or sources). Everything is automated to give the perfect Proton experience !

## Remarks ?
### PR ? Contributing ?
PR are welcome. :) You can else mail me, or come and contribute if you like the project and want to help ! Any help is welcome, even docs !

### Tests
"Hey guy, you're not writing tests!" I know. Proton is mainly a POC as for now, and shouldn't be used into production. If the project goes on, Spectron will probably be used.

### Issues
Any issues ? Let me know, I'll fix it as soon as I can !

## Licence

MIT Licence. Enjoy the work.

## Why ?

Because it's both fun and useful. Electron rocks. Ruby rocks.

Ruby + Electron = <3

## Support on Beerpay
Hey dude! Help me out for a couple of :beers:!

[![Beerpay](https://beerpay.io/ghivert/proton/badge.svg?style=beer-square)](https://beerpay.io/ghivert/proton)  [![Beerpay](https://beerpay.io/ghivert/proton/make-wish.svg?style=flat-square)](https://beerpay.io/ghivert/proton?focus=wish)
