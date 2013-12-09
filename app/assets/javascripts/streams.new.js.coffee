
window.newStreamForm = (form) ->

  #
  # Variables
  #

  TIME = 250

  descriptions = [
    "First, tell us the basic information which might describe your stream"
    "Now, please fill in the fields below with the technical details of your new stream"
    "Finally, we need you to set up the format and the communication mechanism"
  ]

  stepLabel       = form.find ".step-label"
  stepDescription = form.find ".step-description"

  currentStep = 0
  steps = form.find '.step'

  btnBack   = form.find ".btn-back"
  btnNext   = form.find ".btn-next"
  btnCreate = form.find ".btn-create"

  polling = form.find ".polling"
  updateSwitch = form.find "#update-switch"
  progress = form.find ".progress-bar"

  explanations = form.find '.explanation'
  #
  # Auxiliary Functions
  #

  updateStepInformation = ->
    stepLabel.text "Step #{currentStep+1} / #{steps.length}"
    stepDescription.text descriptions[ currentStep ]

  decreaseBar = ->
    w = progress.width()
    ratio = progress.parent().width() / steps.length
    progress.width(w - ratio)

  increaseBar = ->
    w = progress.width()
    ratio = progress.parent().width() / steps.length
    progress.width(w + ratio)

  setInputFocus = ->
    steps.eq(currentStep).find('input').first().focus()

  moveToNextStep = (next) ->
    steps.eq(currentStep).hide TIME
    currentStep += if next then 1 else -1
    steps.eq(currentStep).show TIME


  #
  # Event Handlers
  #

  back = (event) ->
    do event.preventDefault

    if currentStep > 0
      if currentStep is steps.length-1
        btnCreate.css 'display', 'none'
        btnNext.css 'display', 'inline-block'
        # btnNext.removeClass('btn-disabled').addClass('btn-primary')

      moveToNextStep false
      do decreaseBar
      do updateStepInformation
      do setInputFocus

      if currentStep is 0
        btnBack.css 'display', 'none'


  next = (event) ->
    do event.preventDefault

    if currentStep < steps.length-1
      btnBack.css 'display', 'inline-block'

      moveToNextStep true
      do increaseBar
      do updateStepInformation
      do setInputFocus

      if currentStep is steps.length-1
        btnCreate.css 'display', 'inline-block'
        btnNext.css 'display', 'none'


  create = (event) ->
    do event.preventDefault

    do increaseBar
    setTimeout ->
      form.trigger 'submit'
    , TIME * 2


  switchChanged = (event) ->
    do event.preventDefault
    polling.toggle TIME * 2


  explain = (event) ->
    console.log "explain"
    explanations.hide TIME
    exp = $(this).siblings '.explanation'
    exp.show TIME


  #
  # Initialization
  #

  form.find('input').on 'focus', explain

  btnNext.on 'click', next
  do btnBack.on('click', back).hide
  do btnCreate.on('click', create).hide
  do updateStepInformation
  do setInputFocus

  updateSwitch.on 'switch-change', switchChanged

  steps.each (i, step) ->
    steps.eq(i).css 'display', 'none' if i isnt 0


