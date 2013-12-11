
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
  pollingSwitch = form.find ".polling-switch"
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
    steps.eq(currentStep).find('.input').first().focus()

  goBack = -> moveToNextStep false
  goNext = -> moveToNextStep true

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

      do goBack
      do decreaseBar
      do updateStepInformation
      do setInputFocus

      btnBack.css 'display', 'none' if currentStep is 0


  next = (event) ->
    do event.preventDefault

    if currentStep < steps.length-1
      btnBack.css 'display', 'inline-block'

      do goNext
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
    do setInputFocus


  explain = (event) ->
    exp = $(this).siblings '.explanation'
    if exp.css('display') is 'none'
      explanations.hide TIME
      exp.show TIME

  initBootstrapSwitches = ->
    input = """<input class="form-control" id="stream_private" name="stream[private]" type="checkbox" value="1">"""
    form.find('.private-switch').empty().append(input).bootstrapSwitch()

    input = """<input checked="checked" class="form-control" id="stream_polling" name="stream[polling]" type="checkbox" value="false">"""
    pollingSwitch.empty().append(input).bootstrapSwitch().on 'switch-change', switchChanged

  #
  # Initialization
  #

  form.find('.input').on 'focus', explain
  btnNext.on 'click', next
  do btnBack.on('click', back).hide
  do btnCreate.on('click', create).hide
  do updateStepInformation
  do setInputFocus
  do initBootstrapSwitches

  steps.each (i, step) ->
    steps.eq(i).css 'display', 'none' if i isnt 0
