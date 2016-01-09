'use strict';
util           = require 'util'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-firebase')
Firebase       = require('firebase')
firebaseRoot = {}
ready = false
response = {}

MESSAGE_SCHEMA =
  type: 'object'
  properties:
    command:
      type: 'string'
      enum: ['set', 'setWithPriority']
      required: true
    value:
      type: 'string'
      required: true
    priority:
      type: 'string'

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    firebaseURL:
      type: 'string'
      required: true
    returnEvents:
      type: 'boolean'
      default: false

class Plugin extends EventEmitter
  constructor: ->
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA

  onMessage: (message) =>
    payload = message.payload
    if ready
      firebaseRoot.set(payload.value) if payload.command == 'set'
      firebaseRoot.setWithPriority(payload.value, payload.priority) if payload.command == 'setWithPriority'

  connectFirebase: (url) =>
    ready = true
    firebaseRoot = new Firebase(url)

    op = @options

    firebaseRoot.on 'value', (dataSnapshot) ->
      response =
        devices: ['*']
        payload:
          dataSnapshot: dataSnapshot


  onConfig: (device) =>
    @setOptions device.options

  sendMessage = (res) ->
    @emit 'message', response

  setOptions: (options={}) =>
    @options = options

    if !ready
      #@poll(options)
      @connectFirebase(@options.firebaseURL) if @options.firebaseURL?

  poll: (options) =>
    setInterval (->
    console.log options.firebaseURL
    if options?
      if options.returnEvents == true
        send(response) if response?
    ), 1000

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
