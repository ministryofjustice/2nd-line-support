// expose `app` to browser console
window.app = app

app.extend({
  init () {
    console.log('loaded')
  }
})
