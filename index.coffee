'use strict';
util           = require 'util'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-firebase')
firebaseRoot = {}
ready = false

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

class Plugin extends EventEmitter
  constructor: ->
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA

  onMessage: (message) =>
    payload = message.payload
    firebaseRoot.set(payload.value) if payload.command == 'set'
    firebaseRoot.setWithPriority(payload.value, payload.priority) if payload.command == 'setWithPriority'

  connectFirebase: (url) =>
    ready = true
    firebaseRoot = new Firebase(url)
    firebaseRoot.on 'value', (dataSnapshot) ->
      response =
        devices: ['*']
        payload:
          dataSnapshot: dataSnapshot
      @emit 'message', response

  onConfig: (device) =>
    @setOptions device.options

  setOptions: (options={}) =>
    @options = options
    if !ready
      connectFirebase(@options.url) if @options.url?

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
