'use strict';
util           = require 'util'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-sxsw')
Kryten         = require 'Kryten'
kryten         = new Kryten({})
Mecanum = require 'Mecanum'
mec = new Mecanum {
    cw: 60
    ccw: 40
    stop: 51
  }

bot_options = require './bot.json'
kryten.configure bot_options

MESSAGE_SCHEMA = {
  type: 'object'
  properties:
    action:
      type: 'string'
      enum: ['pump', 'drive']
      required: true
    direction:
      type: 'string',
      enum: [
        'forward'
        'backward'
        'left'
        'right'
        'ne'
        'nw'
        'se'
        'sw'
        'stop'
        'cw'
        'ccw'
      ]
    pump:
      type: 'string'
      enum: ['one', 'two', 'three', 'four', 'five']
      required: true
    interval:
      type: 'number'
      default: 1000
      required: true
    }

OPTIONS_SCHEMA = {
  type: 'object'
  properties:
    firstExampleOption:
      type: 'string'
      required: true
  }

class Plugin extends EventEmitter
  constructor: ->
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA

  onMessage: (message) =>
    payload = message.payload

    @pump payload.pump, payload.interval if payload.action == 'pump'
    @direction payload.direction if payload.action == 'drive'

  onConfig: (device) =>
    @setOptions device.options

  pump: (num, interval = 1000) =>
    kryten.onMessage({payload: {component: num, state: '1'}});
    setTimeout ->
      kryten.onMessage({payload: {component: num, state: '0'}});
    ,interval

  direction: (dir) =>
    mec.move dir, (data) ->
      debug data
      kryten.onMessage({payload: {component: 'lf', speed: data.LF}});
      kryten.onMessage({payload: {component: 'lb', speed: data.LB}});
      kryten.onMessage({payload: {component: 'rf', speed: data.RF}});
      kryten.onMessage({payload: {component: 'rb', speed: data.RB}});

  setOptions: (options={}) =>
    @options = options


module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
