
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


  hideBackButton = -> btnBack.css 'display', 'none'
  showBackButton = -> btnBack.css 'display', 'inline-block'

  showCreateButton = ->
    btnCreate.css 'display', 'inline-block'
    btnNext.css 'display', 'none'

  showNextButton = ->
    btnCreate.css 'display', 'none'
    btnNext.css 'display', 'inline-block'


  analyzeRequiredField = (input) ->
    if input.val().length is 0
      btnNext.addClass 'disabled'

    else if input.val().length > 0
      form.find('#error_explanation').hide()
      btnNext.removeClass 'disabled'


  post = (url, data) ->
    $.ajax
      type: "post",
      dataType: "json",
      url: url,
      data: data

  #
  # Event Handlers
  #

  back = (event) ->
    do event.preventDefault

    if currentStep > 0
      if currentStep is steps.length-1
        do showNextButton

      do goBack
      do decreaseBar
      do updateStepInformation
      do setInputFocus

      do hideBackButton if currentStep is 0


  next = (event) ->
    do event.preventDefault
    analyzeRequiredField form.find('.input-name')

    if currentStep < steps.length-1
      do showBackButton

      do goNext
      do increaseBar
      do updateStepInformation
      do setInputFocus

      if currentStep is steps.length-1
        do showCreateButton


  create = (event) ->
    do event.preventDefault
    do increaseBar

    setTimeout ->
      form.trigger 'submit'
    , TIME * 2


  preview = (event) ->
    do event.preventDefault

    p = post "/preview", { uri: textUri.val() }
    p.done (data) ->
      json = JSON.stringify data, undefined, 2
      areaPreview.val json


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


  inputChanged = (event) ->
    do event.preventDefault
    analyzeRequiredField $(this)


  initBootstrapSwitches = ->
    html = '<div class="make-switch" />'

    sw = form.find('.switch-private').wrap(html).parent().bootstrapSwitch()
    sw.bootstrapSwitch 'setOnLabel', 'Yes'
    sw.bootstrapSwitch 'setOffLabel', 'No'

    sw = form.find('.switch-polling').wrap(html).parent().bootstrapSwitch()
    sw.bootstrapSwitch 'setOnLabel', 'Push'
    sw.bootstrapSwitch 'setOffLabel', 'Poll'

    if sw.bootstrapSwitch('status') is false
      do showPollingPanel

    sw.on 'switch-change', switchChanged


  #
  # Initialization
  #

  btnNext.addClass 'disabled'
  do btnBack.hide
  do btnCreate.hide

  form.find('.input').on 'focus', explain
  form.find('.input-name')
    .on('keyup', inputChanged)
    .on('input', inputChanged)

  analyzeRequiredField form.find('.input-name')

  btnBack.on    'click', back
  btnNext.on    'click', next
  btnCreate.on  'click', create
  btnPreview.on 'click', preview

  do updateStepInformation
  do setInputFocus
  do initBootstrapSwitches

  steps.each (i) ->
    steps.eq(i).css 'display', 'none' if i isnt 0
