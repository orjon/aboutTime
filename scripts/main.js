/* eslint-disable no-unused-vars */
$(() => {

  let theTime = undefined
  let theTimeRandomized = undefined
  let timeString = undefined
  let timeStringRandom = undefined
  const hrs = 0
  const min = 1
  const sec = 2

  const maxVariance = 5
  let variance = 0
  const changeVariance = 5000


  const $displayedTime = $('.time')
  const $displayedTimeRandom = $('.timeRandom')

  onload()


  function onload() {
    updateTime()
    updateClock()
    randomizeTime()
  }

  function updateTime() {
    const time = new Date()
    theTime = [time.getHours(),time.getMinutes(),time.getSeconds()]
  }

  function updateClock() {
    updateTime()
    let hours =   theTime[hrs].toString() //convert to strings for padding
    let minutes = theTime[min].toString()
    let seconds = theTime[sec].toString()
    if (hours.length < 2) {
      hours = '0' + hours     //display padding
    }
    if (minutes.length < 2) {
      minutes = '0' + minutes //display padding
    }
    if (seconds.length < 2) {
      seconds = '0' + seconds //display padding
    }
    timeString = hours + ':' + minutes + ':' + seconds
    console.log('Actual time: ', timeString)
    $displayedTime.text(timeString)
  }



  function randomizeTime() {
    variance = (Math.floor(Math.random() * ((maxVariance*2)+1))-maxVariance)
    console.log('Variance: ', variance)

    let hours =   theTime[hrs]
    let minutes = theTime[min] + variance

    if (minutes > 59) {
      minutes = minutes - 60
      hours = hours + 1
    } else if (minutes < 0) {
      minutes = minutes + 60
      hours = hours - 1
    }

    if (hours > 23) {
      hours = hours - 24
    } else if (hours < 0) {
      hours = hours + 24
    }

    timeStringRandom = hours + ':' + minutes
    console.log('random time: ', timeStringRandom)
    $displayedTimeRandom.text(timeStringRandom)
  }

  setTimeout(function(){
    setInterval(randomizeTime, changeVariance,0)
    setInterval(updateClock, 1000)
  })

})
