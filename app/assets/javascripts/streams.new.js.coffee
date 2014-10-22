
window.newStreamForm = (form) ->

  #
  # Variables
  #

  TIME = 250

  descriptions = [
    "First, tell us the basic information which might describe your stream"
    "Now, please fill in the fields below with technical details of your stream"
  ]

  stepLabel       = form.find ".step-label"
  stepDescription = form.find ".step-description"

  currentStep = 0
  steps = form.find '.step'

  btnBack   = form.find ".btn-back"
  btnNext   = form.find ".btn-next"
  btnCreate = form.find ".btn-create"

  progress = form.find ".progress-bar"

  explanations = form.find '.explanation'

  numericInputs = ['#min_val', '#max_val', '#accuracy']

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
      btnNext.removeClass 'disabled'


  post = (url, data) ->
    $.ajax
      type: "post"
      dataType: "json"
      url: url
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


  explain = (event) ->
    exp = $(this).siblings '.explanation'
    exp = $(this).parent().siblings '.explanation' unless exp.text()

    if exp.css('display') is 'none'
      explanations.hide TIME
      exp.show TIME


  checkRequiredField = (event) ->
    do event.preventDefault
    analyzeRequiredField $(this)


  checkNumericField = (event) ->
    key = event.key
    validNumber  = "0" <= key <= "9"
    validCtrlOp  = event.ctrlKey and "/a|c|v|x".match key
    validSpecial = "/,|.|-|".match key or key is "Tab"

    valid = validNumber or validCtrlOp or validSpecial
    do event.preventDefault unless valid


  initBootstrapSwitches = ->
    html = '<div class="make-switch" />'

    sw = form.find('.switch-private').wrap(html).parent().bootstrapSwitch()
    sw.bootstrapSwitch 'setOnLabel', 'Yes'
    sw.bootstrapSwitch 'setOffLabel', 'No'


  #
  # Initialization
  #

  btnNext.addClass 'disabled'
  do btnBack.hide
  do btnCreate.hide

  form.find('.input').on 'focus', explain
  form.find('.input-name')
    .on('keyup', checkRequiredField)
    .on('input', checkRequiredField)

  analyzeRequiredField form.find('.input-name')
  numericInputs.forEach (elem) -> $(elem).on 'keypress', checkNumericField

  btnBack.on    'click', back
  btnNext.on    'click', next
  btnCreate.on  'click', create

  do updateStepInformation
  do setInputFocus
  do initBootstrapSwitches

  steps.each (i) ->
    steps.eq(i).css 'display', 'none' if i isnt 0
