
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
  btnPreview = form.find ".btn-preview"

  textUri = form.find "#stream_uri"
  areaPreview = form.find "#preview-area"

  polling = form.find ".polling"
  progress = form.find ".progress-bar"

  explanations = form.find '.explanation'

  #
  # Auxiliary Functions
  #

  updateStepInformation = ->
    stepLabel.text "Step #{currentStep+1} / #{steps.length}"
    stepDescription.text descriptions[ currentStep ]

  decreaseBar = -> moveBar false
  increaseBar = -> moveBar true

  moveBar = (increase) ->
    w = progress.width()
    ratio = progress.parent().width() / steps.length
    ratio *= -1 if not increase
    progress.width(w + ratio)

  setInputFocus = -> steps.eq(currentStep).find('.input').first().focus()

  showPollingPanel = -> polling.toggle TIME * 2

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


  preview = (event) ->
    do event.preventDefault
    $.ajax
      type: "post",
      dataType: "json",
      url: "/preview/",
      data: { uri: textUri.val() }
    .done (data) ->
      console.log data
      console.log areaPreview
      areaPreview.val JSON.stringify data, undefined, 2


  switchChanged = (event) ->
    do event.preventDefault
    do showPollingPanel
    do setInputFocus


  explain = (event) ->
    exp = $(this).siblings '.explanation'
    exp = $(this).parent().siblings '.explanation' unless exp.text()
    if exp.css('display') is 'none'
      explanations.hide TIME
      exp.show TIME


  keyup = (event) ->
    inputName = $(this)
    if inputName.val().length is 0
      btnNext.addClass 'disabled'
    else if inputName.val().length > 0
      form.find('#error_explanation').hide()
      btnNext.removeClass 'disabled'


  initBootstrapSwitches = ->
    html = '<div class="make-switch" />'

    sw = form.find('.switch-private').wrap(html).parent().bootstrapSwitch()
    sw.bootstrapSwitch 'setOnLabel', 'Yes'
    sw.bootstrapSwitch 'setOffLabel', 'No'

    sw = form.find('.switch-polling').wrap(html).parent().bootstrapSwitch()
    sw.bootstrapSwitch 'setOnLabel', 'Push'
    sw.bootstrapSwitch 'setOffLabel', 'Poll'
    sw.bootstrapSwitch 'setState', true
    sw.on 'switch-change', switchChanged

  #
  # Initialization
  #

  form.find('.input-name').on 'keyup', keyup
  form.find('.input').on 'focus', explain

  btnNext.on 'click', next
  btnPreview.on 'click', preview
  btnBack.on('click', back).hide()
  btnCreate.on('click', create).hide()

  do updateStepInformation
  do setInputFocus
  do initBootstrapSwitches

  steps.each (i, step) ->
    steps.eq(i).css 'display', 'none' if i isnt 0

  btnNext.addClass 'disabled'
