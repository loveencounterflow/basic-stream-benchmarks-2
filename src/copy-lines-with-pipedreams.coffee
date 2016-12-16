

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'BASIC-STREAM-BENCHMARKS-2/COPY-LINES-WITH-PIPEDREAMS'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
PATH                      = require 'path'
FS                        = require 'fs'
# OS                        = require 'os'
#...........................................................................................................
new_numeral               = require 'numeral'
format_float              = ( x ) -> ( new_numeral x ).format '0,0.000'
format_integer            = ( x ) -> ( new_numeral x ).format '0,0'
#...........................................................................................................
O                         = require './options'
D                         = require 'pipedreams'
{ $, $async, }            = D
through2                  = require 'through2'
$split                    = require 'binary-split'
mkdirp                    = require 'mkdirp'
STREAM                    = require 'readable-stream'



#-----------------------------------------------------------------------------------------------------------
@main = ( handler ) ->

  #---------------------------------------------------------------------------------------------------------
  if O.pass_through_asynchronous
    $pass = ->
      return $async ( data, send, end ) ->
        if data?
          setImmediate ->
            send.done data
        if end?
          end()
  else
    $pass = D.$pass.bind D
  #---------------------------------------------------------------------------------------------------------
  $count           = -> $ ( data        ) -> item_count += +1
  $trim            = -> $ ( line, send  ) -> send line.trim()
  $filter_empty    = -> $ ( line, send  ) -> send line unless line.length is 0
  $filter_comments = -> $ ( line, send  ) -> send line unless line.startsWith '#'
  $split_fields    = -> $ ( line, send  ) -> send line.split '\t'

  #---------------------------------------------------------------------------------------------------------
  $select_fields = ->
    return $ ( fields, send ) ->
      [ _, glyph, formula, ] = fields
      send [ glyph, formula, ]

  #---------------------------------------------------------------------------------------------------------
  mkdirp.sync PATH.dirname O.outputs.pipedreams
  input_stream              = FS.createReadStream   O.inputs.ids
  output_stream             = FS.createWriteStream  O.outputs.pipedreams

  #---------------------------------------------------------------------------------------------------------
  t0                        = null
  t1                        = null
  item_count                = 0

  #---------------------------------------------------------------------------------------------------------
  input_stream.on 'open', ->
    t0 = Date.now()

  #---------------------------------------------------------------------------------------------------------
  output_stream.on 'close', ->
    t1              = Date.now()
    dts             = ( t1 - t0 ) / 1000
    dts_txt         = format_float dts
    item_count_txt  = format_integer item_count
    ips             = item_count / dts
    ips_txt         = format_float ips
    help PATH.basename __filename
    help "pass-through count: #{O.pass_through_count}"
    help "#{item_count_txt} items; dts: #{dts_txt}, ips: #{ips_txt}"
    handler()

  #---------------------------------------------------------------------------------------------------------
  s = input_stream
  s = s.pipe D.$split()
  # s = s.pipe $decode()
  s = s.pipe $count()
  s = s.pipe $trim()
  s = s.pipe $filter_empty()
  s = s.pipe $filter_comments()
  s = s.pipe $split_fields()
  s = s.pipe $select_fields()
  s = s.pipe D.$as_line()
  s = s.pipe $pass() for idx in [ 1 .. O.pass_through_count ] by +1
  s = s.pipe output_stream










