/* eslint-disable no-unused-vars */
$(() => {

  let theTime = undefined
  // let timeString = undefined
  const hrs = 0
  const min = 1
  const sec = 2

  let maxVariance = 5
  let variance = 0
  let frequency = 15000


  const $displayedTime = $('.time')
  const $displayedTimeHours = $('.timeHours')
  const $displayedTimeMinutes = $('.timeMinutes')
  const $displayedTimeColon = $('.timeColon')
  const $displayedDetails = $('.timeRandom')
  const $secondBlinker = $('.secondBlinker')

  let intRandom = setInterval(randomizeTime, frequency,0)
  let intClock = setInterval(updateClock, 1000)
  let intSeconds = setInterval(seconds, 500)

  onload()

  function onload() {
    updateTime()
    updateClock()
    randomizeTime()
    $displayedDetails.text('± 0…' + maxVariance + 'mins / ' + frequency/1000 + 'secs')
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

    // timeString = hours + ':' + minutes
    // console.log('Actual time: ', timeString)
    // $displayedTime.text(timeString)
    $displayedTimeHours.text(hours)
    $displayedTimeMinutes.text(minutes)
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
    const hoursx10 = Math.floor(hours/10)
    const hoursx01 = hours%10
    const minutesx10 = Math.floor(minutes/10)
    const minutesx01 = minutes%10
    $('div.hoursx10').html('<img src="./images/D1-' + hoursx10 + '.png">')
    $('div.hoursx01').html('<img src="./images/D2-' + hoursx01 + '.png">')
    $('div.minutesx10').html('<img src="./images/D3-' + minutesx10 + '.png">')
    $('div.minutesx01').html('<img src="./images/D4-' + minutesx01 + '.png">')
  }

  function seconds() {
    $secondBlinker.toggle()
    $displayedTimeColon.toggleClass('colorBackground')
  }

  $('#varianceKnob').jsRapKnob({
    position: 0.5,
    onChange: function(value){
      value = Math.floor(value * 10)
      $('.rapKnobCaption',this).text('± 0…' + value + 'min')
    },


    onMouseUp: function(value){
      maxVariance = Math.floor(value * 10)
      console.log('maxVariance: '+ maxVariance)
      clearIntervals()
      setInternvals()
    }
  })

  $('#frequnecyKnob').jsRapKnob({
    position: 0.5,
    onChange: function(value){
      $('.rapKnobCaption',this).text('@ ' + Math.floor(value * 30) + 'sec')
    },
    onMouseUp: function(value){
      frequency = Math.floor(value * 30000)
      console.log('freq: '+ Math.floor(frequency/1000))
      clearIntervals()
      setInternvals()
    }
  })


  function setInternvals(){
    intRandom = setInterval(randomizeTime, frequency,0)
    intClock = setInterval(updateClock, 1000)
    intSeconds = setInterval(seconds, 500)
  }

  function clearIntervals(){
    clearInterval(intRandom)
    clearInterval(intClock)
    clearInterval(intSeconds)
  }

})
